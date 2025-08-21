#!/bin/bash
set -e

echo "🚀 配置 Docker 国内镜像加速..."

# 确保目录存在
sudo mkdir -p /etc/docker

# 写入 daemon.json
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
EOF

echo "✅ 已写入 /etc/docker/daemon.json"

# 重新加载并重启 Docker
echo "🔄 重启 Docker 服务..."
sudo systemctl daemon-reexec
sudo systemctl restart docker

# 验证配置
echo "📋 当前配置的镜像源："
docker info | grep -i "Registry Mirrors" -A 3

echo "🎉 Docker 镜像加速配置完成！"
echo "请尝试拉取一个镜像以验证配置是否生效，例如："
echo "  docker pull hello-world"