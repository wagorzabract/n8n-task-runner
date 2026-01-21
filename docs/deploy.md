# 部署指南

## 快速部署

```bash
# 克隆项目
git clone <repo-url>
cd n8n-task-runner

# 启动服务
docker-compose up -d --build
```

## 常用命令

```bash
# 启动
docker-compose up -d

# 重新构建并启动
docker-compose up -d --build

# 停止
docker-compose down

# 查看日志
docker-compose logs -f

# 查看状态
docker-compose ps
```

## 服务说明

| 服务 | 端口 | 说明 |
|------|------|------|
| n8n | 5678 | n8n 主服务，访问 http://localhost:5678 |
| task-runner | - | Python 代码执行器，自动连接 n8n |

## 配置

修改 `docker-compose.yaml` 中的环境变量：

```yaml
N8N_RUNNERS_AUTH_TOKEN=your-secret-here  # 两个服务需保持一致
```

## 目录结构

```
.
├── docker-compose.yaml    # 服务编排
├── Dockerfile             # runner 镜像构建
├── n8n-task-runners.json  # runner 配置
└── fonts/                 # 字体文件
```
