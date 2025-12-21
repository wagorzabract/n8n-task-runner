FROM n8nio/runners:2.1.1
USER root

# 安装系统依赖 (Alpine Linux)
RUN apk add --no-cache ffmpeg

# 安装外部库
RUN cd /opt/runners/task-runner-python && uv pip install numpy pandas requests

# 复制配置文件
COPY n8n-task-runners.json /etc/n8n-task-runners.json
USER runner