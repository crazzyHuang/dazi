#!/bin/bash

# 同频搭子项目云服务器一键部署脚本
# 用法: ./deploy.sh

set -e

echo "🎯 同频搭子项目部署工具"
echo "================================="

# 检查是否为root用户
if [[ $EUID -ne 0 ]]; then
   echo "❌ 此脚本需要root权限运行"
   echo "💡 请使用: sudo ./deploy.sh"
   exit 1
fi

# 交互式选择部署模式
echo "请选择部署模式："
echo "1) 开发环境 (development) - 适合开发调试"
echo "2) 测试环境 (staging) - 适合功能测试"
echo "3) 生产环境 (production) - 适合线上部署"
echo "4) 跳过安装，只更新代码和重启服务"
echo ""

read -p "请输入选择 (1-4): " MODE_CHOICE

case $MODE_CHOICE in
    1)
        ENVIRONMENT="development"
        PROJECT_NAME="dazi-dev"
        PROJECT_DIR="/home/app/${PROJECT_NAME}"
        ;;
    2)
        ENVIRONMENT="staging"
        PROJECT_NAME="dazi-staging"
        PROJECT_DIR="/home/app/${PROJECT_NAME}"
        ;;
    3)
        ENVIRONMENT="production"
        PROJECT_NAME="dazi-prod"
        PROJECT_DIR="/home/app/${PROJECT_NAME}"
        ;;
    4)
        ENVIRONMENT="update"
        # 查找现有的项目目录
        if [[ -d "/home/app/dazi-dev" ]]; then
            PROJECT_DIR="/home/app/dazi-dev"
        elif [[ -d "/home/app/dazi-staging" ]]; then
            PROJECT_DIR="/home/app/dazi-staging"
        elif [[ -d "/home/app/dazi-prod" ]]; then
            PROJECT_DIR="/home/app/dazi-prod"
        else
            echo "❌ 未找到现有项目目录"
            exit 1
        fi
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

echo "🚀 开始部署到 ${ENVIRONMENT} 环境"
echo "📁 项目目录: ${PROJECT_DIR}"

# 如果是跳过安装模式，直接进入更新流程
if [[ "${ENVIRONMENT}" == "update" ]]; then
    echo "🔄 更新模式：只更新代码和重启服务"
    cd ${PROJECT_DIR}

    # 更新代码
    echo "📥 更新项目代码..."
    git pull origin main
    git checkout main

    # 进入后端目录
    cd backend

    # 重新安装依赖
    echo "📦 更新项目依赖..."
    pnpm install --frozen-lockfile

    # 重启所有服务
    echo "🔄 重启所有服务..."
    docker-compose down
    docker-compose up -d postgres redis mongodb elasticsearch
    sleep 10
    docker-compose up -d user-service

    echo "✅ 更新完成！"
    echo ""
    echo "🔍 服务状态："
    echo "   docker-compose ps"
    echo ""
    echo "📝 查看日志："
    echo "   docker-compose logs -f"

    exit 0
fi

# 完整部署流程
echo "📦 开始完整部署流程..."

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
echo "📥 克隆项目代码..."
if [[ -d ".git" ]]; then
    echo "🔄 更新现有代码..."
    git pull origin main
    git checkout main
else
    echo "📥 克隆项目代码..."
    echo "请输入Git仓库地址 (留空使用示例地址):"
    read -p "Git URL: " GIT_URL

    if [[ -z "$GIT_URL" ]]; then
        GIT_URL="https://github.com/crazzyHuang/dazi.git"
    fi

    git clone $GIT_URL .
    git checkout main
fi

# 进入后端目录
cd backend

# 安装项目依赖
echo "📦 安装项目依赖..."
pnpm install --frozen-lockfile

# 配置环境变量
echo "⚙️ 配置环境变量..."
if [[ ! -f "user-service/.env" ]]; then
    cp user-service/.env.example user-service/.env
    echo "✅ 已创建环境配置文件"
else
    echo "ℹ️  环境配置文件已存在"
fi

# 设置环境特定配置
case ${ENVIRONMENT} in
    "development")
        USER_SERVICE_PORT=3001
        DB_NAME="tongpin_db_dev"
        NODE_ENV="development"
        ;;
    "staging")
        USER_SERVICE_PORT=3002
        DB_NAME="tongpin_db_staging"
        NODE_ENV="staging"
        ;;
    "production")
        USER_SERVICE_PORT=3000
        DB_NAME="tongpin_db_prod"
        NODE_ENV="production"
        ;;
esac

# 更新环境配置
echo "🔧 更新环境配置..."
sed -i "s/NODE_ENV=.*/NODE_ENV=${NODE_ENV}/" user-service/.env
sed -i "s/PORT=.*/PORT=${USER_SERVICE_PORT}/" user-service/.env
sed -i "s/DB_NAME=.*/DB_NAME=${DB_NAME}/" user-service/.env

# 创建日志目录
mkdir -p user-service/logs

# 启动数据库服务
echo "🗄️  启动数据库服务..."
docker-compose up -d postgres redis mongodb elasticsearch

# 等待数据库启动
echo "⏳ 等待数据库服务启动..."
sleep 15

# 检查数据库状态
echo "🔍 检查数据库状态..."
if docker-compose exec postgres pg_isready -h localhost -p 5432 > /dev/null 2>&1; then
    echo "✅ PostgreSQL 已就绪"
else
    echo "❌ PostgreSQL 连接失败"
fi

if docker-compose exec redis redis-cli ping > /dev/null 2>&1; then
    echo "✅ Redis 已就绪"
else
    echo "❌ Redis 连接失败"
fi

# 启动用户服务
echo "🚀 启动用户服务..."
docker-compose up -d user-service

# 等待服务启动
echo "⏳ 等待用户服务启动..."
sleep 10

# 检查服务健康状态
echo "🔍 检查服务健康状态..."
if curl -f http://localhost:${USER_SERVICE_PORT}/health > /dev/null 2>&1; then
    echo "✅ 用户服务已就绪"
else
    echo "❌ 用户服务启动失败"
fi

# 创建 systemd 服务（生产环境）
if [[ "${ENVIRONMENT}" == "production" ]]; then
    echo "🔧 创建系统服务..."

    cat > /etc/systemd/system/${PROJECT_NAME}.service << EOF
[Unit]
Description=同频搭子后端服务 (${ENVIRONMENT})
After=network.target docker.service
Requires=docker.service

[Service]
Type=simple
User=root
WorkingDirectory=${PROJECT_DIR}
ExecStart=${PROJECT_DIR}/backend/start-services.sh
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=${PROJECT_NAME}

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable ${PROJECT_NAME}.service
    echo "✅ 系统服务已创建"
fi

echo ""
echo "🎉 部署完成！"
echo "================================="
echo ""
echo "📊 部署信息："
echo "   环境: ${ENVIRONMENT}"
echo "   端口: ${USER_SERVICE_PORT}"
echo "   目录: ${PROJECT_DIR}"
echo ""
echo "🔗 服务地址："
echo "   用户服务: http://localhost:${USER_SERVICE_PORT}"
echo "   健康检查: http://localhost:${USER_SERVICE_PORT}/health"
echo "   API文档:  http://localhost:${USER_SERVICE_PORT}/api/v1"
echo ""
echo "🛠️  管理命令："
echo "   查看状态: docker-compose ps"
echo "   查看日志: docker-compose logs -f"
echo "   重启服务: docker-compose restart user-service"
echo "   停止服务: docker-compose down"
echo ""

if [[ "${ENVIRONMENT}" == "production" ]]; then
    echo "🔧 生产环境管理："
    echo "   启动服务: systemctl start ${PROJECT_NAME}"
    echo "   停止服务: systemctl stop ${PROJECT_NAME}"
    echo "   查看状态: systemctl status ${PROJECT_NAME}"
    echo "   查看日志: journalctl -u ${PROJECT_NAME} -f"
    echo ""
fi

echo "📝 常用操作："
echo "   重新部署: sudo ./deploy.sh"
echo "   只更新代码: sudo ./deploy.sh (选择选项4)"
echo ""
echo "🎯 现在你可以开始开发和测试了！"