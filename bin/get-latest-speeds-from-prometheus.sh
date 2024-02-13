#!/bin/bash

###########################
# The files to check/create
#
SPEED_FILE="${1:-/tmp/speed.txt}"
SPEED_FILE_TMP="${SPEED_FILE}.from-prometheus"

###################################################################
# Create the temp. speed file with the latest stats from Prometheus
#
source prometheus-lib.sh

dl="$(prometheus-lib-get-latest-value speedtest_download_bits_per_second 1h | awk '{printf "%4.0f\n", $1/1000000}')"

ul="$(prometheus-lib-get-latest-value speedtest_upload_bits_per_second 1h | awk '{printf "%4.0f\n", $1/1000000}')"

echo "speedtest_download $dl" | tee    $SPEED_FILE_TMP
echo "speedtest_upload   $ul" | tee -a $SPEED_FILE_TMP

#########################################################
# Have the speed outputs changed since the last check ?
#
diff -q $SPEED_FILE $SPEED_FILE_TMP > /dev/null 2>&1
   
if [ $? -gt 0 ]
then
   #################
   # Yes, update the speed file
   #
   cp $SPEED_FILE_TMP $SPEED_FILE
fi
