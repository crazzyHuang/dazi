#!/bin/bash

# 同频搭子后端服务启动脚本

set -e

echo "🚀 启动同频搭子后端服务..."

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker未运行，请先启动Docker"
    exit 1
fi

# 检查docker-compose是否存在
if ! command -v docker-compose > /dev/null 2>&1; then
    echo "❌ docker-compose未安装"
    exit 1
fi

echo "📦 构建并启动基础服务..."
docker-compose up -d postgres redis mongodb elasticsearch

echo "⏳ 等待数据库服务启动..."
sleep 10

# 检查PostgreSQL是否准备就绪
echo "🔍 检查PostgreSQL连接..."
until docker-compose exec postgres pg_isready -h localhost -p 5432 > /dev/null 2>&1; do
    echo "⏳ 等待PostgreSQL..."
    sleep 2
done

echo "✅ PostgreSQL已就绪"

# 检查Redis是否准备就绪
echo "🔍 检查Redis连接..."
until docker-compose exec redis redis-cli ping > /dev/null 2>&1; do
    echo "⏳ 等待Redis..."
    sleep 2
done

echo "✅ Redis已就绪"

echo "🔧 构建并启动用户服务..."
docker-compose up -d user-service

echo "⏳ 等待用户服务启动..."
sleep 5

# 检查用户服务健康状态
echo "🔍 检查用户服务健康状态..."
until curl -f http://localhost:3001/health > /dev/null 2>&1; do
    echo "⏳ 等待用户服务..."
    sleep 2
done

echo "✅ 用户服务已就绪"

# 安装项目依赖（如果需要）
echo "📦 安装项目依赖..."
cd user-service && pnpm install && cd ..

echo ""
echo "🎉 所有服务启动成功！"
echo ""
echo "📊 服务状态："
echo "  • PostgreSQL:  http://localhost:5432"
echo "  • Redis:       http://localhost:6379"
echo "  • MongoDB:     http://localhost:27017"
echo "  • Elasticsearch: http://localhost:9200"
echo "  • 用户服务:    http://localhost:3001"
echo "  • 健康检查:    http://localhost:3001/health"
echo ""
echo "🔧 可用命令："
echo "  • 查看日志:    docker-compose logs -f"
echo "  • 停止服务:    docker-compose down"
echo "  • 重启服务:    docker-compose restart"
echo ""
echo "📝 API测试："
echo "  • 用户注册: POST http://localhost:3001/api/v1/auth/register"
echo "  • 用户登录: POST http://localhost:3001/api/v1/auth/login"
echo ""