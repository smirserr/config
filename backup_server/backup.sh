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
arch_type="--gzip"
arch_extension=gz

# pwd - текущий рабочий каталог
SCRIPT_DIR=`pwd`

# Что бекапим
DIR_SOURCE="/mnt/backup_dir"

# Лог-файл
LOG="/var/log/backup.log"

# Где храним бекапы. 
DIR_TARGET_MONTH="/var/spool/backup/$PCNAME/month"
DIR_TARGET_DAY="/var/spool/backup/$PCNAME/day"

#Файлы инкримента
increment="/var/spool/backup/$PCNAME/increment.inc"
increment_day="/var/spool/backup/$PCNAME/increment_day.inc"

PATH=/usr/local/bin:/usr/bin:/bin
# текущее число
DOM=`date +%d`

#Включаем комп
echo "$(date)"
echo "Приступаем $PCNAME"
echo "Приступаем $PCNAME" >> $LOG
wakeonlan -p 8 $MAC
sleep 120
echo "Монтируем шару"
#sudo mount -t cifs  '//'$1'.ds/C$' -o user=$USER,password=$PASSWORD,dom=$DOMAIN,sec=ntlm /mnt/backup_dir -v
#монтируем шару
if mount -t cifs  "//$PCNAME.$DOMAIN/D$" -o user=$USER,password=$PASSWORD,sec=ntlm $DIR_SOURCE -v; then
	if [ $DOM = "01" ]; then
		echo "Делаем полный бэкап"
		echo "Делаем полный бэкап" >> $LOG
	# если первое число - делаем полный бэкап, предварительно переименовав предыдущий месячный бэкап, и удалив его инкремент
		mv $DIR_TARGET_MONTH/full.tar.$arch_extension $DIR_TARGET_MONTH/full.tar.$arch_extension.1
		rm $increment
		$TAR --create --ignore-failed-read --one-file-system --recursion --preserve-permissions --sparse --listed-incremental=$increment $arch_type --verbose --file=$DIR_TARGET_MONTH/full.tar.$arch_extension $DIR_SOURCE
		# переименовываем дневные инкрементные бэкапы, старые бекапы удаляем.
		for i in $( find $DIR_TARGET_DAY/ -name "*tar.$arch_extension.1" ); do rm -f $i; done
		for i in $( find $DIR_TARGET_DAY/ -name "*tar.$arch_extension" ); do mv $i $i.1; done
	else
		echo "Делаем инкрементный бэкап"
		echo "Делаем инкрементный бэкап" >> $LOG
		#если не первое число - делаем инкрементные (только изменения) дневные бекапы
		cp $increment $increment_day
		$TAR --create --ignore-failed-read --one-file-system --recursion --preserve-permissions --sparse --listed-incremental=$increment_day $arch_type --verbose --file $DIR_TARGET_DAY/day$DOM.tar.$arch_extension $DIR_SOURCE
	fi
	umount $DIR_SOURCE
else 
	echo "Ошибка монтирования шары $PCNAME.$DOMAIN"
	echo "$(date +%F_%R:%S) Ошибка монтирования шары $PCNAME.$DOMAIN" >> $LOG
fi

sleep 30
#Выключаем комп!
echo "Выключаем $PCNAME"
echo "Выключаем $PCNAME" >> $LOG
net rpc SHUTDOWN -I $PCNAME.$DOMAIN -f -U "$PCNAME\\\\$USER%$PASSWORD"


