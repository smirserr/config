#Автоматический Бэкап содержимого папки home 
#
LOG="/home/serr/.backup/backup.log"

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> $LOG
date
date >> $LOG

# tar
TAR=/bin/tar
# Что бэкапим 
DIR_SOURCE="/home/serr"
#Исключения
EXCLUDE_FILE="/home/serr/.backup/exclude_file"

# Хранилище
DIR_TARGET="/home/serr/Yandex"
# Число
DOM=`date +20%y_%m_%d`

# Задаем переменную, в которой вычисляем размер папки с бекапом
spacebackup=`du -sm $DIR_TARGET/home/ | awk '{print$1}'`
# Если папка с бекапом занимает больше max_du Мб
max_du=7000

echo ">>>>>>>>>> DEL OLD BACKUP >>>>>>>>>>>>>>>"
echo ">>>>>>>>>> DEL OLD BACKUP >>>>>>>>>>>>>>>" >> $LOG
if [ $spacebackup -gt $max_du ];
then
	cd $DIR_TARGET/home/
	# То до тех пор пока размер папки с бэкапами будет больше $max_du Мб
	while [ `du -sm /$DIR_TARGET/home/ | awk '{print$1}'` -gt "$max_du" ]
	do
	# Будем в папке с бэкапами удалять все файлы с расширением "tar", начиная с самых старых
		find /$DIR_TARGET/home/ -name "*.tar" -and -type f | sort -r | tail -n1 | xargs -i rm '{}' >> $LOG
	done
	echo "Нет подходящих файлов для удаления"
	echo "Нет подходящих файлов для удаления" >> $LOG
else
	echo "Удаление файлов не требуется"
	echo "Удаление файлов не требуется" >> $LOG
fi

echo ">>>>>>>>>> START BACKUP >>>>>>>>>>>>>>>"
echo ">>>>>>>>>> START BACKUP >>>>>>>>>>>>>>>" >> $LOG
date +%H:%M:%S
date +%H:%M:%S >> $LOG


$TAR --create --ignore-failed-read --one-file-system --recursion --preserve-permissions --sparse --verbose --exclude=$DIR_TARGET  --file=$DIR_TARGET/home/home_$DOM.tar -X $EXCLUDE_FILE $DIR_SOURCE 2>>$LOG

$TAR --create --ignore-failed-read --one-file-system --recursion --preserve-permissions --sparse --verbose  --file=$DIR_TARGET/etc/etc_$DOM.tar -X 2>>$LOG

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> $LOG
date +%H:%M:%S
date +%H:%M:%S >> $LOG
echo ">>>>>>>>>> START SYNC >>>>>>>>>>>>>>>>>" 
echo ">>>>>>>>>> START SYNC >>>>>>>>>>>>>>>>>" >> $LOG
yandex-disk sync

date +%H:%M:%S
date +%H:%M:%S >> $LOG
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> $LOG
echo ""
echo "" >> $LOG


