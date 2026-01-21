# n8n 数据备份指南

## 概述

n8n 默认使用 SQLite 数据库，数据存储在 Docker volume `n8n_data` 中，挂载路径为 `/home/node/.n8n`。

## 备份内容

`/home/node/.n8n` 目录下主要包含：

| 文件/目录 | 说明 |
|-----------|------|
| `database.sqlite` | 核心数据库（workflows、credentials、执行历史等） |
| `binaryData/` | 二进制文件数据（图片、文件等） |
| `config` | 配置文件 |

## 备份方法

### 方法1：直接复制 volume 数据（推荐）

```bash
# 1. 停止 n8n 容器（避免数据损坏）
docker stop n8n-main

# 2. 查看 volume 实际路径
docker volume inspect n8n-task-runner_n8n_data

# 3. 复制整个目录（需要 sudo）
sudo cp -r /var/lib/docker/volumes/n8n-task-runner_n8n_data/_data ./n8n_backup_$(date +%Y%m%d)

# 4. 启动容器
docker start n8n-main
```

### 方法2：使用 docker 命令导出

无需知道 volume 具体路径，直接通过临时容器导出：

```bash
# 导出为 tar.gz 压缩包
docker run --rm \
  -v n8n-task-runner_n8n_data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/n8n_backup_$(date +%Y%m%d).tar.gz /data
```

### 方法3：使用本地目录挂载（便于日常备份）

修改 `docker-compose.yaml`，将 named volume 改为本地目录挂载：

```yaml
services:
  n8n:
    # ... 其他配置
    volumes:
      - ./n8n_data:/home/node/.n8n  # 改为本地目录
```

这样备份时直接复制 `n8n_data` 文件夹即可：

```bash
cp -r ./n8n_data ./n8n_backup_$(date +%Y%m%d)
```

## 恢复数据

### 从备份目录恢复

```bash
# 1. 停止容器
docker stop n8n-main

# 2. 清空现有数据（谨慎操作）
sudo rm -rf /var/lib/docker/volumes/n8n-task-runner_n8n_data/_data/*

# 3. 复制备份数据
sudo cp -r ./n8n_backup_20240119/* /var/lib/docker/volumes/n8n-task-runner_n8n_data/_data/

# 4. 启动容器
docker start n8n-main
```

### 从 tar.gz 恢复

```bash
docker run --rm \
  -v n8n-task-runner_n8n_data:/data \
  -v $(pwd):/backup \
  alpine sh -c "rm -rf /data/* && tar xzf /backup/n8n_backup_20240119.tar.gz -C /"
```

## 注意事项

1. **备份前务必停止容器** - SQLite 在运行时直接复制可能导致数据不一致或损坏
2. **定期备份** - 建议设置 cron 定时任务自动备份
3. **异地备份** - 重要数据建议同步到云存储或其他服务器
4. **测试恢复** - 定期验证备份文件是否可以正常恢复

## 自动备份脚本示例

创建 `backup.sh`：

```bash
#!/bin/bash
BACKUP_DIR="/path/to/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# 停止容器
docker stop n8n-main

# 备份
docker run --rm \
  -v n8n-task-runner_n8n_data:/data \
  -v $BACKUP_DIR:/backup \
  alpine tar czf /backup/n8n_backup_$DATE.tar.gz /data

# 启动容器
docker start n8n-main

# 保留最近 7 天的备份
find $BACKUP_DIR -name "n8n_backup_*.tar.gz" -mtime +7 -delete

echo "备份完成: n8n_backup_$DATE.tar.gz"
```

添加到 crontab（每天凌晨 3 点执行）：

```bash
0 3 * * * /path/to/backup.sh >> /var/log/n8n_backup.log 2>&1
```
