#!/bin/bash

path=$1
ta=${path:$((${#path}-1)):1}
if ! [ "$ta" == "/" ]
then
	path=${path}/
fi


function backup
{
	echo '============================'
	echo "Начинаю работу в каталоге $1"
	check=$(cd $1 && find ./* -maxdepth 0 -type d) 
	if [ -z "$check" ]
	then
		echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
		echo "ВНИМАНИЕ! ВНИМАНИЕ! ВНИМАНИЕ!"
		echo "Не найдены бэкапы в каталоге $1"
		#echo "Отправляю сообщение об ошибке на адрес $mail"
		echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
	else
		check=$(cd $1 && find ./* -maxdepth 0 -type d -name 0*)
		if [ -z "$check" ]
		then
                	echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
                	echo "ВНИМАНИЕ! ВНИМАНИЕ! ВНИМАНИЕ!"
                	echo "Не найден полный бэкап в каталоге $1"
                	#echo "Отправляю сообщение об ошибке на адрес $mail"
        	        echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
	        fi

		echo 'Бэкапы найдены, приступаю к архивированнию'
		cd $1 && find ./* -maxdepth 0  -type d -exec /usr/bin/zip -r $(date +%y-%m-%d) {} \; -exec rm -r {} \;
		echo '>>>>>>>>>>>>>>>>>>'
		echo 'Архивированние завершено'

	fi
	echo -e "============================ \n"
}

function del
{
	target_dir=$1
	limit=3
	n=1
	for i in `ls $target_dir -t | grep zip`
	do
		if [ $n -gt $limit ]
		then
			rm -Rvf $target_dir/$i
		fi
		n=$(($n+1))
	done
}


echo "" > /tmp/report.log
echo "" > /tmp/list_dir.txt

cd $path && find ./* -name _autobackup > /tmp/list_dir.txt

while read line; do
	line=${line##./} 
	line="${path}${line}"
	backup $line >> /tmp/report.log
	del $line     

done < /tmp/list_dir.txt

mail  -a /tmp/list_dir.txt -s "Backup server report" STF < /tmp/report.log

rm /tmp/report.log
rm /tmp/list_dir.txt


#heirloom-mailx
