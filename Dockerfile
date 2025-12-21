# 阶段1: 从专门提供静态 ffmpeg 的镜像中获取
FROM mwader/static-ffmpeg:6.1.1 AS ffmpeg-source

# 阶段2: 主镜像
FROM n8nio/runners:2.1.1
USER root

# 只需要复制这一个文件即可，它没有外部依赖
COPY --from=ffmpeg-source /ffmpeg /usr/local/bin/ffmpeg
COPY --from=ffmpeg-source /ffprobe /usr/local/bin/ffprobe

# 安装外部库
RUN cd /opt/runners/task-runner-python && uv pip install numpy pandas requests

# 复制配置文件
COPY n8n-task-runners.json /etc/n8n-task-runners.json
USER runner