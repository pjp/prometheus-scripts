#!/usr/bin/bash

RANGE="${1:-60m}"

echo "########################"
echo "# Stats. of CPU temp."
echo "# over the last $RANGE"
echo "########################"

source prometheus-lib.sh

prometheus-lib-get-stats-from-list "$(prometheus-lib-get-history-as-list node_thermal_zone_temp ${RANGE})" "node_thermal_zone_temp deg. C"
