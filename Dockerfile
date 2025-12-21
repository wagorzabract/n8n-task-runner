# 阶段1: 从 Debian 镜像获取 ffmpeg
FROM debian:bookworm-slim AS ffmpeg-builder
RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg && rm -rf /var/lib/apt/lists/*

# 阶段2: 主镜像
FROM n8nio/runners:2.1.1
USER root

# 从 builder 阶段复制 ffmpeg 及其依赖库
COPY --from=ffmpeg-builder /usr/bin/ffmpeg /usr/bin/ffmpeg
COPY --from=ffmpeg-builder /usr/bin/ffprobe /usr/bin/ffprobe
COPY --from=ffmpeg-builder /usr/lib/ /usr/lib/

# 安装外部库
RUN cd /opt/runners/task-runner-python && uv pip install numpy pandas requests

# 复制配置文件
COPY n8n-task-runners.json /etc/n8n-task-runners.json
USER runner