#!/usr/bin/bash

RANGE="${1:-6h}"

echo "########################"
echo "# Stats. of download/upload speeds"
echo "# over the last $RANGE"
echo "########################"

source prometheus-lib.sh

prometheus-lib-get-stats-from-list "$(prometheus-lib-get-history-as-list speedtest_download_bits_per_second ${RANGE} | awk '{printf "%4.0f\n", $1/1000000}')" "speedtest_download Mb/s"

prometheus-lib-get-stats-from-list "$(prometheus-lib-get-history-as-list speedtest_upload_bits_per_second ${RANGE} | awk '{printf "%4.0f\n", $1/1000000}')" "speedtest_upload Mb/s"
