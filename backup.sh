#!/bin/bash

# 编辑计划任务
# crontab -e
# 添加以下内容(不含#)
# 0 1 1 * * /path/backup.sh

# 1GB = 1024MB * 1024KB * 1024B
# 每月备份量约为 2000000 * 200 * 30 / 1024 / 1024 / 1024 = 11GB

DB_Host=127.0.0.1
DB_Port=27017
DB_Username=username
DB_Password=paaword
Mongo_DB="test"
Mongo_Collection="user_logs"

Current_Date=$(date +%Y%m%d)
Backup_Dir="/data/backups"
Remote_Server="bak@bak.ipo.com"
Remote_Backup_Dir="/backups/mongo"
Webhook="https://monitor.ipo.com/webhook/mongodb"

# 设置异常处理

handle_signal() {
    echo "An error occurred during backup or cleanup."
    curl -X POST $Webhook
    exit 1
}

trap handle_signal ERR

# 创建备份目录
mkdir -p "$Backup_Dir"

# 检查磁盘空间是否足够,取两倍备份量
Local_Free_Space=$(df --output=avail "$BACKUP_DIR" | tail -n 1)
Local_Free_Space_GB=$((Local_Free_Space / 1024 / 1024))
Remote_Free_Space=$(ssh $Remote_Server "df --output=avail $Remote_Backup_Dir | tail -n 1")
Remote_Free_Space_GB=$((Remote_Free_Space / 1024 / 1024))

# 如果空间不足,则停止备份脚本, 调用webhook
if [ $Local_Free_Space_GB -lt 22 ]; then
    echo "Local free space is less than 22GB. Exit."
    curl -X POST $Webhook
    exit 1
fi
if [ $Remote_Free_Space_GB -lt 22 ]; then
    echo "Remote free space is less than 22GB. Exit."
    curl -X POST $Webhook
    exit 1
fi

# 备份数据库
mongodump --host $DB_Host --port $DB_Port --username $DB_Username --password $DB_Password -d $Mongo_DB --collection $Mongo_Collection --out "$Backup_Dir/$Current_Date"

# 压缩备份文件
tar -czf "$Backup_Dir/$Current_Date.tar.gz" -C "$Backup_Dir" "$Current_Date"

# 上传备份到远程服务器
sftp $Remote_Server << EOF
put "$Backup_Dir/$Current_Date.tar.gz" "$Remote_Backup_Dir/$Current_Date.tar.gz"
exit
EOF

# 清理旧数据
mongo --host $DB_Host --port $DB_Port --username $DB_Username --password $DB_Password -d $Mongo_DB --eval "db.$Mongo_Collection.remove({create_on: {$lt: ISODate(\"2024-01-01T03:33:11Z\")}});"
