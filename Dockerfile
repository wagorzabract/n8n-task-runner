# 阶段1: 获取静态 ffmpeg
FROM mwader/static-ffmpeg:6.1.1 AS ffmpeg-source

# 阶段2: 主镜像
FROM n8nio/runners:2.1.1
USER root

# 1. 复制 ffmpeg 静态二进制文件
COPY --from=ffmpeg-source /ffmpeg /usr/local/bin/ffmpeg
COPY --from=ffmpeg-source /ffprobe /usr/local/bin/ffprobe

# 2. 安装系统依赖：fontconfig (用于管理字体)
# 注意：n8nio/runners 是基于 Alpine 的，使用 apk
RUN apk add --no-cache fontconfig

# 3. 安装字体到系统目录
# 创建字体目录并复制本地 fonts 文件夹中的所有字体
RUN mkdir -p /usr/share/fonts/custom
COPY fonts/* /usr/share/fonts/custom/

# 刷新系统字体缓存
RUN fc-cache -fv

# 4. 安装 Python 库 (包含 Pillow, numpy 等)
RUN cd /opt/runners/task-runner-python && uv pip install numpy pandas requests Pillow

# 5. 复制配置文件
COPY n8n-task-runners.json /etc/n8n-task-runners.json

# 切换回 runner 用户
USER runner
WORKDIR /home/runner