#!/usr/bin/bash

RECIPIENTADDR="${3:-paul@pearceful.net}"
RECIPIENTNAME="${4:-Paul Pearce}"
HOST="$(hostname -s)"
SENDER="${HOSTNAME}@pearceful.net"
TMPFILE=$(/bin/mktemp)
SUBJECT="${2:-Content from $HOSTNAME}"

if [ "$1" == "--help" -o "$1" == "-h" ]
then
   echo "Usage: file_name  subject  recipient_address  recipient_name"
   echo "Note:  Set DRY_RUN=0 to actually send the email"

   exit 0
fi

export PATH=$HOME/bin:$PATH

echo "To: \"$RECIPIENTNAME\" $RECIPIENTADDR" > $TMPFILE
echo "From: $SENDER" >> $TMPFILE
echo "Subject: $SUBJECT" >> $TMPFILE

if [ ! -z "$1" -a -f "$1" ]
then
   cat "$1" >> $TMPFILE
fi

if [ "0" == "$DRY_RUN" ]
then
   cat $TMPFILE | /usr/sbin/ssmtp $RECIPIENTADDR
else
   echo "DRY_RUN: Start - Email that would have been sent is below"
   cat $TMPFILE
   echo "DRY_RUN: End"
fi

rm $TMPFILE
