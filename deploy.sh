#!/bin/bash

# 同频搭子项目云服务器自动部署脚本
# 用法: ./deploy.sh [environment]
# 环境参数: development, staging, production

set -e

# 默认环境
ENVIRONMENT=${1:-development}
PROJECT_NAME="tongpin-dazi"
PROJECT_DIR="/opt/${PROJECT_NAME}"

echo "🚀 开始部署 ${PROJECT_NAME} 到 ${ENVIRONMENT} 环境"

# 检查是否为root用户
if [[ $EUID -ne 0 ]]; then
   echo "❌ 此脚本需要root权限运行"
   echo "💡 请使用: sudo ./deploy.sh ${ENVIRONMENT}"
   exit 1
fi

# 更新系统包
echo "📦 更新系统包..."
apt update && apt upgrade -y

# 安装基础依赖
echo "🔧 安装系统依赖..."
apt install -y curl wget git htop vim nano

# 安装 Node.js 18+
echo "🐢 安装 Node.js 18+..."
if ! command -v node &> /dev/null || [[ "$(node -v | cut -d'.' -f1)" -lt 18 ]]; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt install -y nodejs
fi

# 安装 pnpm
echo "📦 安装 pnpm..."
if ! command -v pnpm &> /dev/null; then
    npm install -g pnpm
fi

# 安装 Docker 和 Docker Compose
echo "🐳 安装 Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh

    # 添加当前用户到docker组
    usermod -aG docker $SUDO_USER || true
fi

# 安装 Docker Compose
if ! command -v docker-compose &> /dev/null; then
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# 创建项目目录
echo "📁 创建项目目录..."
mkdir -p ${PROJECT_DIR}
cd ${PROJECT_DIR}

# 克隆或更新代码
echo "📥 克隆/更新项目代码..."
if [[ -d ".git" ]]; then
    echo "🔄 更新现有代码..."
    git pull origin main
    git checkout main
else
    echo "📥 克隆项目代码..."
    # 注意：这里需要替换为实际的Git仓库地址
    git clone https://github.com/your-username/tongpin-dazi.git .
    git checkout main
fi

# 进入后端目录
cd backend

# 安装项目依赖
echo "📦 安装项目依赖..."
pnpm install --frozen-lockfile

# 复制环境配置文件
echo "⚙️ 配置环境变量..."
if [[ ! -f ".env" ]]; then
    cp user-service/.env.example user-service/.env
    echo "⚠️ 请编辑 user-service/.env 文件，配置数据库和JWT密钥"
    echo "   nano user-service/.env"
fi

# 创建日志目录
mkdir -p user-service/logs

# 根据环境设置端口和配置
case ${ENVIRONMENT} in
    "development")
        USER_SERVICE_PORT=3001
        DB_NAME="tongpin_db_dev"
        ;;
    "staging")
        USER_SERVICE_PORT=3002
        DB_NAME="tongpin_db_staging"
        ;;
    "production")
        USER_SERVICE_PORT=3000
        DB_NAME="tongpin_db_prod"
        ;;
    *)
        echo "❌ 无效的环境参数: ${ENVIRONMENT}"
        echo "💡 可用环境: development, staging, production"
        exit 1
        ;;
esac

# 更新环境配置
sed -i "s/PORT=.*/PORT=${USER_SERVICE_PORT}/" user-service/.env
sed -i "s/DB_NAME=.*/DB_NAME=${DB_NAME}/" user-service/.env

# 创建 systemd 服务（可选，用于生产环境）
if [[ "${ENVIRONMENT}" == "production" ]]; then
    echo "🔧 创建 systemd 服务..."

    cat > /etc/systemd/system/${PROJECT_NAME}.service << EOF
[Unit]
Description=同频搭子后端服务
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=${PROJECT_DIR}/backend
ExecStart=/usr/bin/pnpm start
Restart=always
RestartSec=5
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=${PROJECT_NAME}

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable ${PROJECT_NAME}.service
fi

echo "🎉 部署完成！"
echo ""
echo "📋 下一步操作："
echo "1. 编辑环境配置文件："
echo "   nano user-service/.env"
echo ""
echo "2. 启动数据库服务："
echo "   cd backend"
echo "   docker-compose up -d postgres redis mongodb elasticsearch"
echo ""
echo "3. 启动用户服务："
if [[ "${ENVIRONMENT}" == "production" ]]; then
    echo "   systemctl start ${PROJECT_NAME}"
    echo "   systemctl status ${PROJECT_NAME}"
else
    echo "   cd user-service && pnpm run dev"
fi
echo ""
echo "4. 测试服务："
echo "   curl http://localhost:${USER_SERVICE_PORT}/health"
echo ""
echo "🔍 服务状态检查："
echo "   docker-compose ps"
if [[ "${ENVIRONMENT}" == "production" ]]; then
    echo "   systemctl status ${PROJECT_NAME}"
fi
echo ""
echo "📝 日志查看："
echo "   docker-compose logs -f"
if [[ "${ENVIRONMENT}" == "production" ]]; then
    echo "   journalctl -u ${PROJECT_NAME} -f"
fi