#!/bin/sh
#
# Written by Maikel van Leeuwen <maikel@tiny-host.nl>
#

KEYID="7ABD20E6"
SERVERNAME="contra-mail"
INCREMENTS=21
LOGFILE=" --log-file /var/log/duplicity.log"
MOUNTDIR="/srv/stack"
LOG_LOCATION="/etc/duplicity"
test -x $(which duplicity) || exit 0
. /etc/duplicity/.passphrase
#Umount stackmount 
if mount | grep "stack"  
then
#echo "Unmount already mounted stack directory, just to be sure"
umount  $MOUNTDIR  
fi
export PASSPHRASE
if mount $MOUNTDIR 
then
	##Don't forget to define with three /// for local directories!
	#/etc
	$(which duplicity)  --encrypt-key $KEYID $LOGFILE --num-retries 3 --sign-key $KEYID  /etc file:///$MOUNTDIR/$SERVERNAME/etc
	$(which duplicity) remove-all-but-n-full $INCREMENTS --force file:///$MOUNTDIR/$SERVERNAME/etc 
	
        
	
	#Umount stackmount                                                                      
		if mount | grep "stack" 
		then 
		umount  $MOUNTDIR 
		fi    
else
	echo "Mount failed, please check $MOUNTDIR" 
fi
