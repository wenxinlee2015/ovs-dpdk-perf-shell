#!/bin/bash
set -x

IP=192.168.5.118
NETMASK=255.255.255.0
GATEWAY=192.168.5.1
DEV=eth0
##calc NETWORK and PREFIX
eval $(ipcalc -np ${IP} ${NETMASK})

yum install -y arptables
yum install -y initscripts

while [ true ];
do
	exist=`ps -ef | grep policy.sh | grep -v grep`

	if [ -n "$exist" ]; then
		sleep 3
	else
		break
	fi

done

## if doesn't exist default route, exit. else set policy route.
exist=`ip route | grep default | grep ${GATEWAY}`
if [ -z "$exist" ]; then
	/sbin/ip route add default via ${GATEWAY} dev ${DEV}
	exit
fi

##get rule table id
line_before=0
##/sbin/ip rule | awk -F ':' '{print $1}' | sort -nr | while read line
cat /etc/iproute2/rt_tables | grep -v "#" | awk '{print $1}' | sort -nr | while read line
do
	let dif=$line_before-$line

	if [ $dif -eq $line_before ]; then
		let line_new=$line_before-1
		break
	fi

	line_before=$line
done

echo -e '${line_new}\ttable_${line_new}' >> /etc/iproute2/rt_tables
/sbin/ip route add default via ${GATEWAY} dev ${DEV} table ${line_new}
/sbin/ip route add ${NETWORK}/${PREFIX} dev ${DEV} proto kernel scope link src ${IP} table table_${line_new}

/sbin/ip rule add from ${IP} table ${line_new}
/sbin/ip rule add to ${IP} table ${line_new}
/sbin/ip rule add oif ${DEV} table ${line_new}
/sbin/ip rule add iif ${DEV} table ${line_new}

