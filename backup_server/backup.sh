#Первого числа каждого месяца делается полный бэкап. 
#При этом предыдущий полный бэкап и дневные бекапы переименовываются добавлением в конец .1, 
#а еще более старые - удаляются. 
#В остальные дни месяца делается только бэкап изменений, т.е. инкрементный бэкап.

#!/bin/bash

MAC=$1
PCNAME=$2
DOMAIN=$3
USER=$4
PASSWORD=$5
#sudo mount -t cifs  '//'$1'.ds/C$' -o user=$USER,password=$PASSWORD,dom=$DOMAIN,sec=ntlm /mnt/backup_dir -v

# имя и расположение программы tar
TAR=/bin/tar

# Тип архиватора и расширение. Выбрать либо gzip, либо bzip2
#gzip
arch_type="--gzip"
arch_extension=gz

#bzip
#arch_type="--bzip2"
#arch_extension=bz2


# pwd - текущий рабочий каталог
SCRIPT_DIR=`pwd`

# Что бекапим
DIR_SOURCE="/mnt/backup_dir"

# Лог-файл
LOG="/var/log/archive.log"

# Где храним бекапы. 
DIR_TARGET_MONTH="/mnt/storag/$PCNAME/month"
DIR_TARGET_DAY="/mnt/storag/$PCNAME/day"

#Файлы инкримента
increment="/mnt/storag/$PCNAME/increment.inc"
increment_day="/mnt/storag/$PCNAME/increment_day.inc"

PATH=/usr/local/bin:/usr/bin:/bin
# текущее число
DOM=`date +%d`
# монтируем шару
if smbmount "//$PCNAME.DOMAIN/D$" $DIR_SOURSE -o username=$USER,password=$PASSWORD,domain=$DOMAIN then
	if [ $DOM = "01" ]; then
	# если первое число - делаем полный бэкап, предварительно переименовав предыдущий месячный бэкап, и удалив его инкремент
		mv $DIR_TARGET_MONTH/full.tar.$arch_extension $DIR_TARGET_MONTH/full.tar.$arch_extension.1
		rm $increment
		$TAR --create --ignore-failed-read --one-file-system --recursion --preserve-permissions --sparse --listed-incremental=$increment $arch_type --verbose --file=$DIR_TARGET_MONTH/full.tar.$arch_extension $DIR_SOURCE
		# переименовываем дневные инкрементные бэкапы, старые бекапы удаляем.
		for i in $( find $DIR_TARGET_DAY/ -name "*tar.$arch_extension.1" ); do rm -f $i; done
		for i in $( find $DIR_TARGET_DAY/ -name "*tar.$arch_extension" ); do mv $i $i.1; done
	else
		#если не первое число - делаем инкрементные (только изменения) дневные бекапы
		cp $increment $increment_day
		$TAR --create --ignore-failed-read --one-file-system --recursion --preserve-permissions --sparse --listed-incremental=$increment_day $arch_type --verbose --file $DIR_TARGET_DAY/day$DOM.tar.$arch_extension $DIR_SOURCE
	fi
	umount /mnt/
else 
	echo "$(date +%F_%R:%S) Ошибка монтирования шары $PCNAME.$DOMAIN" >> $LOG
fi


