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
#    node_thermal_zone_temp
#    speedtest_download_bits_per_second 
#    speedtest_upload_bits_per_second 
#
export PROMETHEUS_IAM="prometheus-lib.sh"
export PROMETHEUS_API="http://localhost:9090/api/v1"

#################
function prometheus-lib-help() {
#################
   echo -e "Example usage of functions in this library :-\n\n"

   echo "(source ~/bin/$PROMETHEUS_IAM ; prometheus-lib-help)"
   echo ""
   echo "(source ~/bin/$PROMETHEUS_IAM ; prometheus-lib-get-latest-value node_thermal_zone_temp 1m)"
   echo "(source ~/bin/$PROMETHEUS_IAM ; prometheus-lib-get-history-as-list node_thermal_zone_temp 1m)"
   echo "(source ~/bin/$PROMETHEUS_IAM ; prometheus-lib-get-stats-from-list \"\$(prometheus-lib-get-history-as-list node_thermal_zone_temp 1h)\" "History")"
   echo ""
   echo ""
   echo "For the following examples, we need to massage the output to Mb/s using awk."
   echo "Since the upload/download speed is only captured once an hour, we need to go back a"
   echo "few hours."
   echo ""
   echo "(source ~/bin/$PROMETHEUS_IAM ; prometheus-lib-get-latest-value speedtest_download_bits_per_second 1h | awk '{printf \"%4.0f\\n\", \$1/1000000}')"
   echo "(source ~/bin/$PROMETHEUS_IAM ; prometheus-lib-get-history-as-list speedtest_download_bits_per_second 6h | awk '{printf \"%4.0f\\n\", \$1/1000000}')"
   echo "(source ~/bin/$PROMETHEUS_IAM ; prometheus-lib-get-stats-from-list \"\$(prometheus-lib-get-history-as-list speedtest_download_bits_per_second 6h | awk '{printf \"%4.0f\\n\", \$1/1000000}')\" \"History\")"
}

#################
function prometheus-lib() {
#################
   prometheus-lib-help
} 

##################
function prometheus-lib-debug() {
##################
   label="$1"
   data="$2"

   if [ ! -z "$PROMETHEUS_LIB_DEBUG" ]
   then
      echo  "${label}"
      echo  "${data}"
   fi
}

##########################
function prometheus-lib-get-history-as-list() {
##########################
   local metric="$1"
   local range="$2"
   local divider="${3:-1}"
   local curl_output=""
   local jq_output=""

   if [ $# -lt 2 ]
   then
      echo "Too few parameters, need metric & range" >&2
   else
      # curl -s  "${H/30 * * * *API}/query?query=${metric}\[${range}\]" | jq -r '.data.result[0].values| map(.[1])' | tr -d '[],"' | grep -v '^$' | awk '{printf "%3.1f\n", $1}'

      curl_output=$(curl -s "${PROMETHEUS_API}/query?query=${metric}\[${range}\]")
      prometheus-lib-debug "curl_output" "$curl_output"

      jq_output="$(echo $curl_output | jq -r '.data.result[0].values| map(.[1])')"
      prometheus-lib-debug "jq_output" "$jq_output"

      echo "$jq_output" | tr -d '[],"' | grep -v '^$' | awk -v divider="$divider" '{printf "%3.1f\n", $1/divider}'
   fi
}

#######################
function prometheus-lib-get-latest-value() {
#######################
   local metric="$1"
   local range="$2"
   local curl_output=""
   local jq_output=""

   if [ $# -lt 2 ]
   then
      echo "Too few parameters, need metric & range" >&2
   else
      #curl -s "${PROMETHEUS_API}/query?query=last_over_time(${metric}\[${range}\])" | jq -r '.data.result[0].value[1]'

      curl_output=$(curl -s "${PROMETHEUS_API}/query?query=last_over_time(${metric}\[${range}\])")
      prometheus-lib-debug "curl_output" "$curl_output"

      jq_output="$(echo "$curl_output" | jq -r '.data.result[0].value[1]')"
      prometheus-lib-debug "jq_output" "$jq_output"

      echo "$jq_output"
   fi

}

##################################
function prometheus-calc-stats-from-list() {
##################################
   local list="$1"
   local label="$2"

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
function prometheus-lib-get-stats-from-list() {
######################
   local list="$1"
   local label="$2"

   if [ $# -lt 2 ]
   then
      echo "Too few parameters, need list & label" >&2
   else
      # echo "$list" | ~/bin/calc-stats.sh "$label"
      prometheus-calc-stats-from-list "$list" "$label"
   fi
}

