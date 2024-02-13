#!/usr/bin/bash

RECIPIENTNAME="Paul Pearce"
RECIPIENTADDR=paul@pearceful.net
SENDER=pi-speed-mon@pearceful.net
SPEED_FILE="/tmp/speed.txt"
TMPFILE=$(/bin/mktemp)

# Any timecrage overrides ?
if [ -z "$RANGE" ]
then
   RANGE="${1:-6h}"
fi

echo "To: \"$RECIPIENTNAME\" $RECIPIENTADDR" > $TMPFILE
echo "From: $SENDER" >> $TMPFILE
echo "Subject: Prometheus Stats" >> $TMPFILE

$HOME/bin/get-speed-history-summaries-from-prometheus.sh $RANGE >> $TMPFILE
echo "#====================================" >> $TMPFILE

$HOME/bin/get-cpu-temp-history-from-prometheus.sh $RANGE >> $TMPFILE
echo "#====================================" >> $TMPFILE

cat $TMPFILE | /usr/sbin/ssmtp paul@pearceful.net

rm $TMPFILE
