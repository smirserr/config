#Первого числа каждого месяца делается полный бэкап. 
#При этом предыдущий полный бэкап и дневные бекапы переименовываются добавлением в конец .1, 
#а еще более старые - удаляются. 
#В остальные дни месяца делается только бэкап изменений, т.е. инкрементный бэкап.

#!/bin/bash
#передаваемые скрипту параметры
MAC=$1
PCNAME=$2
DOMAIN=$3
USER=$4
PASSWORD=$5
# имя и расположение программы tar
TAR=/bin/tar
# Тип архиватора и расширение. Выбрать либо gzip, либо bzip2
#gzip
arch_type=""
arch_extension=""

# pwd - текущий рабочий каталог
SCRIPT_DIR=`pwd`

# Что бекапим
DIR_SOURCE="/mnt/backup_dir"

# Лог-файл
LOG="/mnt/tcfi_local/_backups/backup.log"

# Где храним бекапы. 
DIR_TARGET_MONTH="/mnt/tcfi_local/_backups/$PCNAME/month"
DIR_TARGET_DAY="/mnt/tcfi_local/_backups/$PCNAME/day"

#Файлы инкримента
increment="/mnt/tcfi_local/_backups/$PCNAME/increment.inc"
increment_day="/mnt/tcfi_local/_backups/$PCNAME/increment_day.inc"

PATH=/usr/local/bin:/usr/bin:/bin
# текущее число
DOM=`date +%d`

#Включаем комп
echo "$(date)" >> $LOG
echo "Приступаем $PCNAME"
echo "Приступаем $PCNAME" >> $LOG
wakeonlan -p 8 $MAC
sleep 200
echo "Монтируем шару"
#smbmount "//$PCNAME.$DOMAIN/D$" $DIR_SOURCE -o username=$USER,password=$PASSWORD,domain=$PCNAME,iocharset=cp1251
#mount -t cifs  "//$PCNAME.$DOMAIN/D$" -o user=$USER,password=$PASSWORD,sec=ntlm $DIR_SOURCE -v
#монтируем шару
if mount -t cifs  "//$PCNAME.$DOMAIN/D$" -o user=$USER,password=$PASSWORD,sec=ntlm $DIR_SOURCE -v; then
	if [ $DOM = "06" ]; then
		echo "Делаем полный бэкап"
		echo "Делаем полный бэкап" >> $LOG
	# если первое число - делаем полный бэкап, предварительно переименовав предыдущий месячный бэкап, и удалив его инкремент
		mv $DIR_TARGET_MONTH/full.tar $DIR_TARGET_MONTH/full.tar.1
		rm $increment
		$TAR --create --ignore-failed-read --one-file-system --recursion --preserve-permissions --sparse --listed-incremental=$increment --verbose --file=$DIR_TARGET_MONTH/full.tar --exclude "Admin/*" --exclude "admin/*" --exclude "RECYCLER/*" --exclude "System Volume Information/*" $DIR_SOURCE
		# переименовываем дневные инкрементные бэкапы, старые бекапы удаляем.
		for i in $( find $DIR_TARGET_DAY/ -name "*tar.1" ); do rm -f $i; done
		for i in $( find $DIR_TARGET_DAY/ -name "*tar" ); do mv $i $i.1; done
	else
		echo "Делаем инкрементный бэкап"
		echo "Делаем инкрементный бэкап" >> $LOG
		#если не первое число - делаем инкрементные (только изменения) дневные бекапы
		cp $increment $increment_day
		$TAR --create --ignore-failed-read --one-file-system --recursion --preserve-permissions --sparse --listed-incremental=$increment_day --verbose --file $DIR_TARGET_DAY/day$DOM.tar --exclude "Admin/*" --exclude "admin/*" --exclude "RECYCLER/*" --exclude "System Volume Information/*" $DIR_SOURCE
	fi
	umount $DIR_SOURCE
else 
	echo "Ошибка монтирования шары $PCNAME.$DOMAIN"
	echo "$(date +%F_%R:%S) Ошибка монтирования шары $PCNAME.$DOMAIN" >> $LOG
fi

sleep 30
#Выключаем комп!
echo "Выключаем $PCNAME"
echo "Выключаем $PCNAME" >> 
echo "$(date)" >> $LOG
net rpc SHUTDOWN -I $PCNAME.$DOMAIN -f -U $PCNAME/$USER%$PASSWORD
sleep 30
net rpc SHUTDOWN -I $PCNAME.$DOMAIN -f -U $PCNAME/$USER%$PASSWORD
