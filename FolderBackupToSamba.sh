#!/bin/bash

# Script for take a folder snapshot and save it to a Windows/Samba share
# Config should be under /usr/local/etc/FolderBackupToSamba.cfg
#
# @author Christoph S. Ackermann <info@acki.be>

source /usr/local/etc/FolderBackupToSamba.cfg

if [ ! -d $MOUNTFOLDER ]; then
	mkdir $MOUNTFOLDER
fi

mount -t cifs $SMBFOLDER $MOUNTFOLDER -o user=$SMBUSER,password=$SMBPASS

ndate=`date +%Y%m%d`
date=`date -d "$ndate 00:00" +%s`

tdate=$(($KEEPDAYS*86400))

if [ -f $MOUNTFOLDER/backup.${BACKUPFOLDER//\//}.$ndate.tgz ]; then
	echo "Backup from today already exists. Do nothing."
	exit 1
fi

files=$(find $MOUNTFOLDER -type f -name "*${BACKUPFOLDER//\//}*")

for file in $files
do
	arr=(${file//./ })
	compare=`date -d ${arr[2]} +%s`
	limit=$(($date-$tdate))
	if [[ $compare < $limit ]]; then
		rm $file
	fi
done

tar cfz $MOUNTFOLDER/backup.${BACKUPFOLDER//\//}.$ndate.tgz $BACKUPFOLDER > /dev/null

umount $MOUNTFOLDER

sleep 1

rm -rf $MOUNTFOLDER

echo "Created backup from folder \"$BACKUPFOLDER\" to \"$SMBFOLDER\" named backup.${BACKUPFOLDER//\//}.$ndate.tgz"
exit 0