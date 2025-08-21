#!/bin/bash
set -e

echo "🚀 配置终端代理..."

# ===== 配置参数 =====
# 改成你自己的代理地址和端口
PROXY_HOST="127.0.0.1"
PROXY_PORT="7897"

# 支持 http/https/socks5
HTTP_PROXY="http://${PROXY_HOST}:${PROXY_PORT}"
HTTPS_PROXY="http://${PROXY_HOST}:${PROXY_PORT}"
ALL_PROXY="socks5://${PROXY_HOST}:${PROXY_PORT}"

# ===== 写入配置 =====
CONFIG_FILE="$HOME/.bashrc"

echo "" >> $CONFIG_FILE
echo "# ===== Proxy Settings (added by setup-proxy.sh) =====" >> $CONFIG_FILE
echo "export http_proxy=${HTTP_PROXY}" >> $CONFIG_FILE
echo "export https_proxy=${HTTPS_PROXY}" >> $CONFIG_FILE
echo "export all_proxy=${ALL_PROXY}" >> $CONFIG_FILE
echo "export HTTP_PROXY=${HTTP_PROXY}" >> $CONFIG_FILE
echo "export HTTPS_PROXY=${HTTPS_PROXY}" >> $CONFIG_FILE
echo "export ALL_PROXY=${ALL_PROXY}" >> $CONFIG_FILE
echo "# ===== End Proxy Settings =====" >> $CONFIG_FILE

# 让配置立即生效
source $CONFIG_FILE

echo "✅ 代理已配置成功！"
echo "📋 当前代理环境变量："
env | grep -i proxy
