#############################################################
# A simple library of functions to get values from prometheus
#############################################################
#
# Written by Paul Pearce - Febuary 2024
#
#######################################
# Designed to be referenced in scipts as 
#
# source ~/bin/Prometheus-lib.sh
#
#
# These functions can also be called directly on the command line
# in a sub-shell e.g. for the metrics 
#
export PROMETHEUS_IAM="prometheus-lib.sh"
export PROMETHEUS_API="${PROMETHEUS_API:-http://localhost:9090/api/v1}"

#################
# Display usage and examples.
#
function prometheus-lib-help() {
#################
   echo -e "Example usage of functions in this library, note the use of a sub-shell () to preserve the current envionment.\n\n"

   echo "(source $PROMETHEUS_IAM ; prometheus-lib-help)"
   echo ""
   echo "(source $PROMETHEUS_IAM ; prometheus-lib-get-latest-value node_thermal_zone_temp 1m)"
   echo "(source $PROMETHEUS_IAM ; prometheus-lib-get-history-as-list node_thermal_zone_temp 1m)"
   echo "(source $PROMETHEUS_IAM ; prometheus-lib-get-stats-from-list \"\$(prometheus-lib-get-history-as-list node_thermal_zone_temp 1h)\" "History")"
   echo ""
   echo ""
   echo "For the following examples, we need to massage the output to Mb/s using awk."
   echo "Since the upload/download speed is only captured once an hour, we need to go back a"
   echo "few hours."
   echo ""
   echo "(source $PROMETHEUS_IAM ; prometheus-lib-get-latest-value speedtest_download_bits_per_second 1h | awk '{printf \"%4.0f\\n\", \$1/1000000}')"
   echo "(source $PROMETHEUS_IAM ; prometheus-lib-get-history-as-list speedtest_download_bits_per_second 6h | awk '{printf \"%4.0f\\n\", \$1/1000000}')"
   echo "(source $PROMETHEUS_IAM ; prometheus-lib-get-stats-from-list \"\$(prometheus-lib-get-history-as-list speedtest_download_bits_per_second 6h | awk '{printf \"%4.0f\\n\", \$1/1000000}')\" \"History\")"
}

#################
# Also call usage and examples
#
function prometheus-lib() {
#################
   prometheus-lib-help
} 

##################
# Write to stdout if the environment values
# PROMETHEUS_LIB_DEBUG is not empty. Useful
# to see the raw output from curl and jq
# commands.
#
function prometheus-lib-debug() {
##################
   label="$1"  # The text to display for the debug output.
   data="$2"   # The data to display.

   if [ ! -z "$PROMETHEUS_LIB_DEBUG" ]
   then
      echo  "${label}"
      echo  "${data}"
   fi
}

##########################
# Given a Prometheus metric and time range
# (s,m,h,d) return a list of all the value
# in that time range (oldest first).
#
function prometheus-lib-get-history-as-list() {
##########################
   local metric="$1"       # The metric to retrieve from Prometheus.
   local range="$2"        # The time range to retrieve.
   local divider="${3:-1}" # The (optional) divider to apply to the values retrieved.
                           # Useful to reduce large number e.g. bits/s to Mb/s (use 1000000)
   local curl_output=""    # Hold the curl output from Prometheus.
   local jq_output=""      # Hold the jq output after processing the curl output.

   if [ $# -lt 2 ]
   then
      echo "Too few parameters, need metric & range" >&2
   else
      curl_output=$(curl -s "${PROMETHEUS_API}/query?query=${metric}\[${range}\]")
      prometheus-lib-debug "curl_output" "$curl_output"

      jq_output="$(echo $curl_output | jq -r '.data.result[0].values| map(.[1])')"
      prometheus-lib-debug "jq_output" "$jq_output"

      echo "$jq_output" | tr -d '[],"' | grep -v '^$' | awk -v divider="$divider" '{printf "%3.1f\n", $1/divider}'
   fi
}

#######################
# Given a Prometheus metric and time range
# (s,m,h,d) return the latest value from
# now going back the across the time range.
#
function prometheus-lib-get-latest-value() {
#######################
   local metric="$1"       # The metric to retrieve from Prometheus.
   local range="$2"        # The time range to retrieve.
   local curl_output=""    # Hold the curl output from Prometheus.
   local jq_output=""      # Hold the jq output after processing the curl output.

   if [ $# -lt 2 ]
   then
      echo "Too few parameters, need metric & range" >&2
   else
      curl_output=$(curl -s "${PROMETHEUS_API}/query?query=last_over_time(${metric}\[${range}\])")
      prometheus-lib-debug "curl_output" "$curl_output"

      jq_output="$(echo "$curl_output" | jq -r '.data.result[0].value[1]')"
      prometheus-lib-debug "jq_output" "$jq_output"

      echo "$jq_output"
   fi
}

##################################
# Given a list of numerical values
# calculate the average and display
# this and the maximum and minimum values.
#
function prometheus-lib-calc-stats-from-list() {
##################################
   local list="$1"   # A list of numerical values.
   local label="$2"  # Text to display in the stats heading.

   echo "$list" | sort -n | awk -v label="${label:-Not specified}" '
  BEGIN {
    c = 0;
    sum = 0;
  }
  $1 ~ /^(\-)?[0-9]*(\.[0-9]*)?$/ {
    a[c++] = $1;
    sum += $1;
  }
  END {
    ave = sum / c;
    printf "# Label : %s\n", label ;
    printf "%-7s %9s %9s %9s\n", "# Count", "Avg", "Min", "Max" ;
    printf "%7d %9.1f %9.1f %9.1f\n", c, ave, a[0], a[c-1];
  }
'
}

######################
# front-end function for prometheus-lib-calc-stats-from-list
# with parameter count validation.
#
function prometheus-lib-get-stats-from-list() {
######################
   local list="$1"   # A list of numerical values.
   local label="$2"  # Text to display in the stats heading.

   if [ $# -lt 2 ]
   then
      echo "Too few parameters, need list & label" >&2
   else
      prometheus-lib-calc-stats-from-list "$list" "$label"
   fi
}

