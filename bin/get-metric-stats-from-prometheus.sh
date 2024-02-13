#!/usr/bin/bash
#
##############################################################
# A script to calculate stats. for a metric in Prometheus
#
# Calculate the average and display the maximum and minimum values.
#
##############################################################
if [ $# -lt 3 ]
then
   echo "ERROR: Too few parameters" >&2
   echo "Need metric  range  label  {divider}" >&2
   echo "" >&2
   exit 1
fi

METRIC="$1"   # The Prometheus metric to retrieve.
RANGE="$2"    # The time range to retrieve.
LABEL="$3"    # The text to display for the stats.
DIVIDER="$4"  # The (optional) divider to apply to the values retrieved.
              # Useful to reduce large number e.g. bits/s to Mb/s (use 1000000)

echo "########################"
echo "# Stats. of ${LABEL}."
echo "# over the last ${RANGE}."
echo "########################"

source prometheus-lib.sh

prometheus-lib-get-stats-from-list "$(prometheus-lib-get-history-as-list $METRIC ${RANGE} ${DIVIDER})" "$LABEL"
