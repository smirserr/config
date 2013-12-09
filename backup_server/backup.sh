#Pervogo chisla kazhdogo mesyatsa delayetsya polny bekap. 
#Pri etom predydushchy polny bekap i dnevnye bekapy pereimenovyvayutsya dobavleniyem v konets .1, 
#a eshche boleye starye - udalyayutsya. 
#V ostalnye dni mesyatsa delayetsya tolko bekap izmeneny, t.e. inkrementny bekap.

#!/bin/bash
#peredavayemye skriptu parametry
MAC=$1
PCNAME=$2
DOMAIN=$3
USER=$4
PASSWORD=$5
# imya i raspolozheniye programmy tar
TAR=/bin/tar
# Tip arkhivatora i rasshireniye. Vybrat libo gzip, libo bzip2
#gzip
arch_type=""
arch_extension=""

# pwd - tekushchy rabochy katalog
SCRIPT_DIR=`pwd`

# Chto bekapim
DIR_SOURCE="/mnt/backup_dir"

# Log-fayl
LOG="/mnt/tcfi_local/_backups/backup.log"

# Gde khranim bekapy. 
DIR_TARGET_MONTH="/mnt/tcfi_local/_backups/$PCNAME/month"
DIR_TARGET_DAY="/mnt/tcfi_local/_backups/$PCNAME/day"

#Fayly inkrimenta
increment="/mnt/tcfi_local/_backups/$PCNAME/increment.inc"
increment_day="/mnt/tcfi_local/_backups/$PCNAME/increment_day.inc"

PATH=/usr/local/bin:/usr/bin:/bin
# tekushcheye chislo
DOM=`date +%d`

#Vklyuchayem komp
echo "$(date)" >> $LOG
echo "Pristupayem $PCNAME"
echo "Pristupayem $PCNAME" >> $LOG
wakeonlan -p 8 $MAC
sleep 240
echo "Montiruyem sharu"
#mount -t cifs  "//$PCNAME.$DOMAIN/D$" -o user=$USER,password=$PASSWORD,sec=ntlm $DIR_SOURCE -v; then
#montiruyem sharu
if smbmount "//$PCNAME.$DOMAIN/D$" $DIR_SOURCE -o username=$USER,password=$PASSWORD,domain=$PCNAME,iocharset=cp1251,codepage=cp866; then	
	if [ $DOM = "06" ]; then
		echo "Delayem polny bekap"
		echo "Delayem polny bekap" >> $LOG
	# esli pervoye chislo - delayem polny bekap, predvaritelno pereimenovav predydushchy mesyachny bekap, i udaliv ego inkrement
		mv $DIR_TARGET_MONTH/full.tar $DIR_TARGET_MONTH/full.tar.1
		rm $increment
		$TAR --create --ignore-failed-read --one-file-system --recursion --preserve-permissions --sparse --listed-incremental=$increment --verbose --file=$DIR_TARGET_MONTH/full.tar --exclude "Admin/*" --exclude "admin/*" --exclude "RECYCLER/*" --exclude "System Volume Information/*" $DIR_SOURCE
		# pereimenovyvayem dnevnye inkrementnye bekapy, starye bekapy udalyaem.
		for i in $( find $DIR_TARGET_DAY/ -name "*tar.1" ); do rm -f $i; done
		for i in $( find $DIR_TARGET_DAY/ -name "*tar" ); do mv $i $i.1; done
	else
		echo "Delayem inkrementny bekap"
		echo "Delayem inkrementny bekap" >> $LOG
		#esli ne pervoye chislo - delayem inkrementnye (tolko izmeneniya) dnevnye bekapy
		cp $increment $increment_day
		$TAR --create --ignore-failed-read --one-file-system --recursion --preserve-permissions --sparse --listed-incremental=$increment_day --verbose --file $DIR_TARGET_DAY/day$DOM.tar --exclude "Admin/*" --exclude "admin/*" --exclude "RECYCLER/*" --exclude "System Volume Information/*" $DIR_SOURCE
	fi
	umount $DIR_SOURCE
else 
	echo "Oshibka montirovaniya shary $PCNAME.$DOMAIN"
	echo "$(date +%F_%R:%S) Oshibka montirovaniya shary $PCNAME.$DOMAIN" >> $LOG
fi

sleep 30
#Vyklyuchayem komp!
echo "Vyklyuchayem $PCNAME"
echo "Vyklyuchayem $PCNAME" >>$LOG 
echo "$(date)" >> $LOG
echo "###############################" >> $LOG
net rpc SHUTDOWN -I $PCNAME.$DOMAIN -f -U $PCNAME/$USER%$PASSWORD
sleep 30
net rpc SHUTDOWN -I $PCNAME.$DOMAIN -f -U $PCNAME/$USER%$PASSWORD
