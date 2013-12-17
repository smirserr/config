#!/bin/sh
PINGRESORCE1="google.com"
PINGRESORCE2="ya.ru"
PINGRESORCE3="8.8.8.8"

if (! ping -q -c3 ${PINGRESORCE1} > /dev/null 2>&1) then
	echo 'error 1'
	if (! ping -q -c3 ${PINGRESORCE2} > /dev/null 2>&1) then
		echo 'error 2'
		if (! ping -q -c3 ${PINGRESORCE3} > /dev/null 2>&1) then
			echo 'error 3'
			echo 'reboot 10 sec'
			sleep 10
			reboot

		else echo 'internet ok'
		fi
	else echo 'internet ok'
	fi
else echo 'internet ok'
fi
