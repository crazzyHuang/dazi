# 同频搭子项目云服务器部署指南

## 📋 环境要求

### 系统要求
- **操作系统**: Ubuntu 20.04 LTS / 22.04 LTS
- **内存**: 至少 4GB RAM
- **存储**: 至少 20GB 可用空间
- **网络**: 公网 IP 和必要的端口开放

### 必需软件
- Docker
- Docker Compose
- Node.js 18+
- pnpm
- git

## 🚀 一键部署

### 1. 服务器准备
```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装基础工具
sudo apt install -y curl wget git htop vim nano

# 安装 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh

# 安装 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 安装 Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 安装 pnpm
sudo npm install -g pnpm

# 添加当前用户到docker组（需要重新登录后生效）
sudo usermod -aG docker $USER
```

### 2. 项目部署

#### 方法一：使用增强版部署脚本（推荐）
```bash
# 克隆项目
git clone https://github.com/crazzyHuang/dazi.git
cd dazi

# 运行部署脚本
sudo ./deploy.sh

# 或者使用命令行参数
sudo ./deploy.sh --deploy dev    # 开发环境
sudo ./deploy.sh --deploy staging  # 测试环境
sudo ./deploy.sh --deploy prod     # 生产环境
```

#### 方法二：手动部署
```bash
# 克隆项目
git clone https://github.com/crazzyHuang/dazi.git
cd dazi

# 进入后端目录
cd backend

# 安装依赖
pnpm install

# 配置环境变量
cp user-service/.env.example user-service/.env

# 启动数据库服务
docker-compose up -d postgres redis mongodb elasticsearch

# 等待数据库启动
sleep 15

# 启动用户服务
docker-compose up -d user-service
```

## 🔧 环境配置

### 开发环境配置
```bash
# 编辑环境配置文件
sudo nano user-service/.env

# 基本配置
NODE_ENV=development
PORT=3001
DB_HOST=postgres
DB_PORT=5432
DB_NAME=tongpin_db_dev
DB_USER=postgres
DB_PASSWORD=your_password

REDIS_URL=redis://redis:6379
JWT_SECRET=your-jwt-secret-key
JWT_REFRESH_SECRET=your-refresh-secret-key

# 允许的域名
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:3001
```

### 生产环境配置
```bash
# 使用更强的密钥
JWT_SECRET=your-super-secure-jwt-key-here-make-it-long-and-random
JWT_REFRESH_SECRET=your-super-secure-refresh-key-here-make-it-long-and-random

# 使用生产数据库配置
DB_NAME=tongpin_db_prod
DB_PASSWORD=your-strong-production-password

# 配置生产域名
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
```

## 📊 服务管理

### 使用部署脚本管理（推荐）
```bash
# 启动服务
sudo ./deploy.sh --start

# 停止服务
sudo ./deploy.sh --stop

# 重启服务
sudo ./deploy.sh --restart

# 查看状态
sudo ./deploy.sh --status

# 查看日志
sudo ./deploy.sh --logs

# 更新代码
sudo ./deploy.sh --update

# 清理资源
sudo ./deploy.sh --clean
```

### 手动管理
```bash
cd backend

# 启动所有服务
docker-compose up -d

# 停止所有服务
docker-compose down

# 重启特定服务
docker-compose restart user-service

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f
docker-compose logs -f user-service

# 更新代码后重启
git pull origin main
pnpm install
docker-compose restart user-service
```

## 🔍 监控和日志

### 服务状态检查
```bash
# 检查所有服务状态
docker-compose ps

# 检查特定服务
docker-compose ps user-service

# 检查服务健康
curl http://localhost:3001/health

# 检查数据库连接
docker-compose exec postgres pg_isready -h localhost -p 5432
docker-compose exec redis redis-cli ping
```

### 日志查看
```bash
# 查看所有服务日志
docker-compose logs -f

# 查看用户服务日志
docker-compose logs -f user-service

# 查看最近100行日志
docker-compose logs --tail=100 user-service

# 按时间范围查看日志
docker-compose logs --since="2024-01-01T00:00:00" user-service
```

### 资源监控
```bash
# Docker 资源使用情况
docker stats

# 系统资源监控
htop
docker system df

# 清理未使用资源
docker system prune -a
docker volume prune
docker image prune
```

## 🔒 安全配置

### 防火墙配置
```bash
# 开放必要端口
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw allow 3000  # 生产环境端口
sudo ufw allow 3001  # 开发环境端口

# 启用防火墙
sudo ufw enable
```

### SSL 配置（生产环境）
```bash
# 安装 Certbot
sudo apt install -y certbot

# 获取 SSL 证书（以 Nginx 为例）
sudo certbot certonly --standalone -d yourdomain.com

# 自动续期
sudo crontab -e
# 添加：0 12 * * * /usr/bin/certbot renew --quiet
```

### 数据库安全
```bash
# 修改默认密码
docker-compose exec postgres psql -U postgres -c "ALTER USER postgres PASSWORD 'your-strong-password';"

# 创建应用专用用户
docker-compose exec postgres psql -U postgres -c "CREATE USER app_user WITH PASSWORD 'app_password';"
docker-compose exec postgres psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE tongpin_db TO app_user;"
```

## 🚀 生产环境部署

### 1. 服务器优化
```bash
# 禁用 swap（Docker 推荐）
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

# 配置 Docker 守护进程
sudo nano /etc/docker/daemon.json
```
添加内容：
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
```

### 2. 部署生产环境
```bash
# 部署生产环境
sudo ./deploy.sh --deploy prod

# 配置反向代理（Nginx 示例）
sudo apt install -y nginx
sudo nano /etc/nginx/sites-available/tongpin
```

添加 Nginx 配置：
```nginx
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# 启用配置
sudo ln -s /etc/nginx/sites-available/tongpin /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## 📝 故障排除

### 常见问题

#### 1. 端口被占用
```bash
# 查看端口使用情况
sudo netstat -tlnp | grep :3001

# 杀掉占用进程
sudo kill -9 PID
```

#### 2. Docker 权限问题
```bash
# 添加用户到docker组
sudo usermod -aG docker $USER

# 重新登录或运行
newgrp docker
```

#### 3. 内存不足
```bash
# 检查内存使用
free -h

# 增加 swap（临时）
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

#### 4. 数据库连接失败
```bash
# 检查数据库状态
docker-compose ps postgres

# 查看数据库日志
docker-compose logs postgres

# 重启数据库
docker-compose restart postgres
```

#### 5. 服务启动失败
```bash
# 检查服务日志
docker-compose logs user-service

# 检查环境配置
cat user-service/.env

# 验证依赖安装
cd user-service && pnpm list --depth=0
```

## 🔄 备份和恢复

### 数据库备份
```bash
# 备份 PostgreSQL
docker-compose exec postgres pg_dump -U postgres tongpin_db > backup_$(date +%Y%m%d_%H%M%S).sql

# 备份 Redis
docker-compose exec redis redis-cli SAVE

# 备份 MongoDB
docker-compose exec mongodb mongodump --out /data/backup

# 备份所有数据卷
docker run --rm -v tongpin_postgres_data:/source -v $(pwd):/backup alpine tar czf /backup/postgres_backup.tar.gz -C /source .

# 定期备份（添加到 crontab）
0 2 * * * cd /home/app/dazi && ./backup.sh
```

### 备份脚本示例
```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="/home/app/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# 备份数据库
cd /home/app/dazi/backend
docker-compose exec postgres pg_dump -U postgres tongpin_db > $BACKUP_DIR/db_backup_$DATE.sql

# 备份配置
cp user-service/.env $BACKUP_DIR/env_backup_$DATE

# 保留最近7天的备份
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "env_backup_*" -mtime +7 -delete

echo "✅ 备份完成: $BACKUP_DIR"
```

## 📞 联系和支持

如遇部署问题，请提供：
1. 操作系统版本
2. Docker 版本
3. 错误日志
4. 配置文件（敏感信息请脱敏）

## 🎯 快速开始

```bash
# 1. 准备服务器
sudo apt update && sudo apt upgrade -y

# 2. 安装 Docker
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh

# 3. 克隆项目
git clone https://github.com/crazzyHuang/dazi.git && cd dazi

# 4. 一键部署
sudo ./deploy.sh --deploy dev

# 5. 验证部署
sudo ./deploy.sh --status
curl http://localhost:3001/health
```

🎉 部署完成！现在可以开始开发和测试了！