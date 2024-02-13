#!/usr/bin/bash

if [ $# -lt 3 ]
then
   echo "ERROR: Too few parameters" >&2
   echo "Need metric  range  label  {divider}" >&2
   echo "" >&2
   exit 1
fi

METRIC="$1"
RANGE="$2"
LABEL="$3"
DIVIDER="$4"

echo "########################"
echo "# Stats. of ${LABEL}."
echo "# over the last ${RANGE}."
echo "########################"

source $HOME/bin/prometheus-lib.sh

prometheus-lib-get-stats-from-list "$(prometheus-lib-get-history-as-list $METRIC ${RANGE} ${DIVIDER})" "$LABEL"
