#!/bin/bash

# 同频搭子项目云服务器一键部署和运维脚本
# 用法:
#   ./deploy.sh                    # 交互式部署
#   ./deploy.sh --deploy dev       # 部署开发环境
#   ./deploy.sh --deploy staging   # 部署测试环境
#   ./deploy.sh --deploy prod      # 部署生产环境
#   ./deploy.sh --update           # 只更新代码和重启服务
#   ./deploy.sh --start            # 启动所有服务
#   ./deploy.sh --stop             # 停止所有服务
#   ./deploy.sh --restart          # 重启所有服务
#   ./deploy.sh --status           # 查看服务状态
#   ./deploy.sh --logs             # 查看实时日志
#   ./deploy.sh --clean            # 清理未使用的Docker资源

set -e

echo "🎯 同频搭子项目部署和运维工具"
echo "================================="

# 检查是否为root用户
if [[ $EUID -ne 0 ]]; then
   echo "❌ 此脚本需要root权限运行"
   echo "💡 请使用: sudo ./deploy.sh"
   exit 1
fi

# 解析命令行参数
if [[ $# -eq 0 ]]; then
    # 交互式选择部署模式
    echo "请选择部署模式："
    echo "1) 开发环境 (development) - 适合开发调试"
    echo "2) 测试环境 (staging) - 适合功能测试"
    echo "3) 生产环境 (production) - 适合线上部署"
    echo "4) 跳过安装，只更新代码和重启服务"
    echo ""

    read -p "请输入选择 (1-4): " MODE_CHOICE
else
    case $1 in
        --deploy)
            case $2 in
                dev|development)
                    MODE_CHOICE=1
                    ;;
                staging|staging)
                    MODE_CHOICE=2
                    ;;
                prod|production)
                    MODE_CHOICE=3
                    ;;
                *)
                    echo "❌ 无效的环境参数: $2"
                    echo "💡 可用环境: dev, staging, prod"
                    exit 1
                    ;;
            esac
            ;;
        --update)
            MODE_CHOICE=4
            ;;
        --start)
            MODE_CHOICE=5
            ;;
        --stop)
            MODE_CHOICE=6
            ;;
        --restart)
            MODE_CHOICE=7
            ;;
        --status)
            MODE_CHOICE=8
            ;;
        --logs)
            MODE_CHOICE=9
            ;;
        --clean)
            MODE_CHOICE=10
            ;;
        --help|-h)
            echo "同频搭子项目部署和运维工具"
            echo "================================="
            echo ""
            echo "部署命令:"
            echo "  $0                    # 交互式部署"
            echo "  $0 --deploy dev       # 部署开发环境"
            echo "  $0 --deploy staging   # 部署测试环境"
            echo "  $0 --deploy prod      # 部署生产环境"
            echo "  $0 --update           # 只更新代码和重启服务"
            echo ""
            echo "运维命令:"
            echo "  $0 --start            # 启动所有服务"
            echo "  $0 --stop             # 停止所有服务"
            echo "  $0 --restart          # 重启所有服务"
            echo "  $0 --status           # 查看服务状态"
            echo "  $0 --logs             # 查看实时日志"
            echo "  $0 --clean            # 清理Docker资源"
            echo ""
            echo "其他命令:"
            echo "  $0 --help             # 显示此帮助信息"
            echo ""
            echo "示例:"
            echo "  sudo ./deploy.sh --deploy dev    # 部署开发环境"
            echo "  sudo ./deploy.sh --start         # 启动服务"
            echo "  sudo ./deploy.sh --logs          # 查看日志"
            exit 0
            ;;
        *)
            echo "❌ 未知参数: $1"
            echo "💡 使用 $0 --help 查看帮助"
            exit 1
            ;;
    esac
fi

case $MODE_CHOICE in
     1)
         ENVIRONMENT="development"
         PROJECT_NAME="dazi-dev"
         PROJECT_DIR="/home/app/dazi/${PROJECT_NAME}"
         ;;
     2)
         ENVIRONMENT="staging"
         PROJECT_NAME="dazi-staging"
         PROJECT_DIR="/home/app/dazi/${PROJECT_NAME}"
         ;;
     3)
         ENVIRONMENT="production"
         PROJECT_NAME="dazi-prod"
         PROJECT_DIR="/home/app/dazi/${PROJECT_NAME}"
         ;;
     4)
         ENVIRONMENT="update"
         # 查找现有的项目目录
         if [[ -d "/home/app/dazi/dazi-dev" ]]; then
             PROJECT_DIR="/home/app/dazi/dazi-dev"
         elif [[ -d "/home/app/dazi/dazi-staging" ]]; then
             PROJECT_DIR="/home/app/dazi/dazi-staging"
         elif [[ -d "/home/app/dazi/dazi-prod" ]]; then
             PROJECT_DIR="/home/app/dazi/dazi-prod"
         else
             echo "❌ 未找到现有项目目录"
             exit 1
         fi
         ;;
     5)
         OPERATION="start"
         # 查找现有的项目目录
         find_project_dir
         ;;
     6)
         OPERATION="stop"
         find_project_dir
         ;;
     7)
         OPERATION="restart"
         find_project_dir
         ;;
     8)
         OPERATION="status"
         find_project_dir
         ;;
     9)
         OPERATION="logs"
         find_project_dir
         ;;
     10)
         OPERATION="clean"
         ;;
     *)
         echo "❌ 无效选择"
         exit 1
         ;;
esac

# 查找项目目录的函数
find_project_dir() {
    if [[ -d "/home/app/dazi/dazi-dev" ]]; then
        PROJECT_DIR="/home/app/dazi/dazi-dev"
    elif [[ -d "/home/app/dazi/dazi-staging" ]]; then
        PROJECT_DIR="/home/app/dazi/dazi-staging"
    elif [[ -d "/home/app/dazi/dazi-prod" ]]; then
        PROJECT_DIR="/home/app/dazi/dazi-prod"
    else
        echo "❌ 未找到现有项目目录"
        exit 1
    fi
}

# 检查Docker和Docker Compose
check_docker_compose() {
    if ! docker info > /dev/null 2>&1; then
        echo "❌ Docker未运行，请先启动Docker"
        exit 1
    fi

    if ! command -v docker-compose > /dev/null 2>&1; then
        echo "❌ docker-compose未安装"
        exit 1
    fi
}

# 服务管理函数
manage_services() {
    cd ${PROJECT_DIR}/backend

    case $OPERATION in
        "start")
            echo "🚀 启动所有服务..."
            docker-compose up -d postgres redis mongodb elasticsearch
            echo "⏳ 等待数据库服务启动..."
            sleep 10
            check_database_connectivity
            docker-compose up -d --build user-service
            echo "⏳ 等待用户服务启动..."
            sleep 5
            check_service_health
            echo "✅ 所有服务启动成功！"
            ;;
        "stop")
            echo "🛑 停止所有服务..."
            docker-compose down
            echo "✅ 所有服务已停止"
            ;;
        "restart")
            echo "🔄 重启所有服务..."
            docker-compose restart postgres redis mongodb elasticsearch
            echo "🔧 重建并重启用户服务..."
            docker-compose up -d --build user-service
            echo "✅ 所有服务已重启"
            ;;
        "status")
            echo "📊 服务状态："
            docker-compose ps
            ;;
        "logs")
            echo "📋 实时日志（按 Ctrl+C 退出）："
            docker-compose logs -f
            ;;
        "clean")
            echo "🧹 清理Docker资源..."
            docker system prune -f
            docker volume prune -f
            docker image prune -f
            echo "✅ Docker资源清理完成"
            ;;
    esac
}

# 检查数据库连接
check_database_connectivity() {
    echo "🔍 检查数据库连接..."

    # 检查PostgreSQL
    if docker-compose exec postgres pg_isready -h localhost -p 5432 > /dev/null 2>&1; then
        echo "✅ PostgreSQL 已就绪"
    else
        echo "❌ PostgreSQL 连接失败"
    fi

    # 检查Redis
    if docker-compose exec redis redis-cli ping > /dev/null 2>&1; then
        echo "✅ Redis 已就绪"
    else
        echo "❌ Redis 连接失败"
    fi
}

# 检查服务健康状态
check_service_health() {
    if curl -f http://localhost:3001/health > /dev/null 2>&1; then
        echo "✅ 用户服务已就绪"
    else
        echo "❌ 用户服务启动失败"
    fi
}

# 如果是运维操作模式
if [[ -n "$OPERATION" ]]; then
    echo "🔧 执行运维操作: ${OPERATION}"
    echo "📁 项目目录: ${PROJECT_DIR}"
    check_docker_compose
    manage_services
    exit 0
fi

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
    if [[ -f "pnpm-lock.yaml" ]]; then
        pnpm install --frozen-lockfile
    else
        pnpm install
    fi

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
if [[ -f "pnpm-lock.yaml" ]]; then
    echo "🔒 检测到lockfile，使用锁定版本安装"
    pnpm install --frozen-lockfile
else
    echo "📦 未检测到lockfile，执行全新安装"
    pnpm install
    echo "🔒 生成lockfile文件"
fi

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
docker-compose up -d --build user-service

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
ExecStart=${PROJECT_DIR}/deploy.sh --start
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
echo "   重新部署:           sudo ./deploy.sh --deploy dev"
echo "   只更新代码:         sudo ./deploy.sh --update"
echo "   启动服务:           sudo ./deploy.sh --start"
echo "   停止服务:           sudo ./deploy.sh --stop"
echo "   查看状态:           sudo ./deploy.sh --status"
echo "   查看日志:           sudo ./deploy.sh --logs"
echo "   清理Docker资源:     sudo ./deploy.sh --clean"
echo ""
echo "🎯 现在你可以开始开发和测试了！"