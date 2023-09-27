#!/bin/bash
DIR=$(cd `dirname $0`;pwd)

BIN_PATH=/opt/openGemini/bin
LOG_PATH=/opt/openGemini/logs
config=/opt/openGemini/config/openGemini.conf

cp /opt/openGemini/config/openGemini.conf.default /opt/openGemini/config/openGemini.conf
sed -i "s/addr-placeholder/$MY_POD_IP/g" $config

# 替换CPU 和 内存配置
sed -i "s/cpu-num-placeholder/$CPU_NUMBER/g" $config
sed -i "s/memory-size-placeholder/$MEMORY_SIZE/g" $config

# 替换 meta_addr_1，meta_addr_2，meta_addr_3
sed -i "s/meta_addr_1/meta-sql-store-0.meta-sql-store.$NAMESPACE.svc.cluster.local/g" $config
sed -i "s/meta_addr_2/meta-sql-0.meta-sql.$NAMESPACE.svc.cluster.local/g" $config
sed -i "s/meta_addr_3/meta-store-0.meta-store.$NAMESPACE.svc.cluster.local/g" $config

# 替换domain
sed -i "s/pod-domain/$HOSTNAME.${HOSTNAME%??}.$NAMESPACE.svc.cluster.local/g" $config

if [[ ! -d "/opt/openGemini/data/meta" ]]
then
    mkdir -p /opt/openGemini/data/meta
fi

function startApp() {
	app=$1
    
	ok=`echo $OPEN_GEMINI_LAUNCH|grep "$app"`
	if [ -n "$ok" ]; then
		echo "start: ts-$app"
		nohup $BIN_PATH/ts-$app -config ${config} >> $LOG_PATH/${app}_extra.log 2>&1 &
	fi
}

startApp meta
sleep 5s
startApp store
startApp sql

function checkApp() {
	app=$1

	ok=`echo $OPEN_GEMINI_LAUNCH|grep "$app"`
	if [ ! -n "$ok" ]; then
		return
	fi

	n=`ps axu|grep "ts-$app"|grep -v grep|wc -l`
	if [[ $n -eq 0 ]]; then
		echo "Process ts-$app has exited"
		# exit 1
	fi
}

while true; do

	sleep 3s
	checkApp meta
	checkApp sql
	checkApp store
done