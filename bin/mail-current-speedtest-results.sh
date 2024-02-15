#!/usr/bin/bash

RECIPIENTNAME="Paul Pearce"
RECIPIENTADDR=paul@pearceful.net
SENDER=pi-speed-mon@pearceful.net
TMPFILE=$(/bin/mktemp)

export PATH=$HOME/bin:$PATH

# Any timecrage overrides ?
if [ -z "$RANGE" ]
then
   RANGE="${1:-6h}"
fi

echo "To: \"$RECIPIENTNAME\" $RECIPIENTADDR" > $TMPFILE
echo "From: $SENDER" >> $TMPFILE
echo "Subject: Prometheus Stats" >> $TMPFILE

get-metric-stats-from-prometheus.sh speedtest_download_bits_per_second $RANGE "speedtest_download Mb/s" 1000000 >> $TMPFILE
echo "#====================================" >> $TMPFILE

get-metric-stats-from-prometheus.sh speedtest_upload_bits_per_second   $RANGE "speedtest_upload Mb/s"   1000000 >> $TMPFILE
echo "#====================================" >> $TMPFILE

get-metric-stats-from-prometheus.sh node_thermal_zone_temp $RANGE "node_thermal_zone_temp deg. C" >> $TMPFILE
echo "#====================================" >> $TMPFILE

get-metric-stats-from-prometheus.sh node_memory_Active_bytes $RANGE "Active memory Mb" 1000000 >> $TMPFILE
echo "#====================================" >> $TMPFILE

get-metric-stats-from-prometheus.sh node_load5 $RANGE "5 minute load" >> $TMPFILE
echo "#====================================" >> $TMPFILE

cat $TMPFILE | /usr/sbin/ssmtp paul@pearceful.net

rm $TMPFILE
