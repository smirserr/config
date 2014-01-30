#Pervogo chisla kazhdogo mesyatsa delayetsya polny bekap. 
#Pri etom predydushchy polny bekap i dnevnye bekapy pereimenovyvayutsya dobavleniyem v konets .1, 
#a eshche boleye starye - udalyayutsya. 
#V ostalnye dni mesyatsa delayetsya tolko bekap izmeneny, t.e. inkrementny bekap.

#!/bin/bash
#############################################################################################
#peredavayemye skriptu parametry
MAC=$1
PCNAME=$2
IP=$3
DOMAIN=$4
USER=$5
PASSWORD=$6
# imya i raspolozheniye programmy tar
TAR=/bin/tar
# Chto bekapim
DIR_SOURCE="/mnt/backup_dir"
#fail isklucheniy
EXCLUDE_FILE="/mnt/storage/_backups_pc/backup_server/exclude_file"
# Log-fayl
LOG="/mnt/storage/_backups_pc/backup.log"
# Gde khranim bekapy. 
DIR_TARGET_MONTH="/mnt/storage/_backups_pc/$PCNAME/month"
DIR_TARGET_DAY="/mnt/storage/_backups_pc/$PCNAME/day"
#Fayly inkrimenta
increment="/mnt/storage/_backups_pc/$PCNAME/increment.inc"
increment_day="/mnt/storage/_backups_pc/$PCNAME/increment_day.inc"
PATH=/usr/local/bin:/usr/bin:/bin
# tekushcheye chislo
DOM=`date +%d`
###########################################################################################

echo "$(date)" >> $LOG
echo "Pristupayem $PCNAME"
echo "Pristupayem $PCNAME" >> $LOG
#Vklyuchayem komp
#wakeonlan -p 8 $MAC
#sleep 330
echo "Montiruyem sharu"

#smbmount "//$PCNAME.$DOMAIN/D$" $DIR_SOURCE -o username=$USER,password=$PASSWORD,domain=$PCNAME,iocharset=cp1251,codepage=cp866; then
#mount -t cifs  "//$PCNAME.$DOMAIN/D$" -o user=$USER,password=$PASSWORD,sec=ntlm $DIR_SOURCE -v; then
#montiruyem sharu
cd $DIR_SOURCE
mkdir -p $DIR_TARGET_MONTH
mkdir -p $DIR_TARGET_DAY
umount $DIR_SOURCE
if mount -t cifs  "//$IP/D$" $DIR_SOURCE -o user=$USER,password=$PASSWORD,sec=ntlm,iocharset=cp1251 -v; then	
	if [ $DOM = "01" ]; then
		echo "Delayem polny bekap"
		echo "Delayem polny bekap" >> $LOG
	# esli pervoye chislo - delayem polny bekap, predvaritelno pereimenovav predydushchy mesyachny bekap, i udaliv ego inkrement
		mv $DIR_TARGET_MONTH/full.tar $DIR_TARGET_MONTH/full.tar.1
		rm $increment
		$TAR --create --ignore-failed-read --one-file-system --recursion --preserve-permissions --sparse --listed-incremental=$increment --verbose --file=$DIR_TARGET_MONTH/full.tar -X $EXCLUDE_FILE  $DIR_SOURCE
		# pereimenovyvayem dnevnye inkrementnye bekapy, starye bekapy udalyaem.
		for i in $( find $DIR_TARGET_DAY/ -name "*tar.1" ); do rm -f $i; done
		for i in $( find $DIR_TARGET_DAY/ -name "*tar" ); do mv $i $i.1; done
	else
		echo "Delayem inkrementny bekap"
		echo "Delayem inkrementny bekap" >> $LOG
		#esli ne pervoye chislo - delayem inkrementnye (tolko izmeneniya) dnevnye bekapy
		cp $increment $increment_day
		$TAR --create --ignore-failed-read --one-file-system --recursion --preserve-permissions --sparse --listed-incremental=$increment_day --verbose --file $DIR_TARGET_DAY/day$DOM.tar -X $EXCLUDE_FILE $DIR_SOURCE
	fi
	umount $DIR_SOURCE
else 
	echo "Oshibka montirovaniya shary $PCNAME.$DOMAIN"
	echo "$(date +%F_%R:%S) Oshibka montirovaniya shary $PCNAME.$DOMAIN" >> $LOG
fi

sleep 5
#Vyklyuchayem komp!
echo "Vyklyuchayem $PCNAME"
echo "Vyklyuchayem $PCNAME" >>$LOG 
echo "$(date)" >> $LOG
echo "###############################" >> $LOG
net rpc SHUTDOWN -I $IP -f -U $PCNAME/$USER%$PASSWORD

