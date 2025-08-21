# 同频搭子云服务器部署指南

本指南提供多种在云服务器上部署同频搭子后端服务的方案。

## 📋 部署方案对比

| 方案 | 优点 | 缺点 | 推荐场景 |
|------|------|------|----------|
| **Docker + Docker Compose** | 简单快速，环境隔离 | 需要Docker环境 | 开发/测试环境 |
| **直接部署** | 性能最好，资源利用率高 | 配置复杂，依赖管理难 | 生产环境 |
| **PM2进程管理** | 自动重启，日志管理 | 需要手动管理依赖 | 小型生产环境 |

## 🚀 方案一：Docker + Docker Compose（推荐）

### 前置要求
- Ubuntu 20.04+ / CentOS 7+ / Debian 10+
- Root权限或sudo权限
- 稳定的网络连接

### 自动部署步骤

1. **上传部署脚本**
```bash
# 在本地
scp deploy.sh root@your-server-ip:/root/

# 在服务器上
chmod +x deploy.sh
```

2. **运行自动部署**
```bash
# 开发环境
sudo ./deploy.sh development

# 生产环境
sudo ./deploy.sh production
```

3. **配置环境变量**
```bash
# 编辑环境配置文件
nano user-service/.env

# 必需配置
NODE_ENV=production
PORT=3000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=tongpin_db
DB_USER=postgres
DB_PASSWORD=your_secure_password
JWT_SECRET=your_super_secret_jwt_key
JWT_REFRESH_SECRET=your_refresh_secret_key
REDIS_URL=redis://localhost:6379
```

4. **启动服务**
```bash
cd backend

# 启动数据库服务
docker-compose up -d postgres redis mongodb elasticsearch

# 等待数据库启动
sleep 15

# 启动用户服务
docker-compose up -d user-service
```

5. **验证部署**
```bash
# 检查服务状态
docker-compose ps

# 测试API
curl http://localhost:3000/health

# 查看日志
docker-compose logs -f user-service
```

## 🛠️ 方案二：直接部署（生产环境优化）

### 步骤详解

1. **系统准备**
```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# 安装pnpm
sudo npm install -g pnpm

# 安装Git
sudo apt install -y git

# 安装数据库（可选，如果不使用Docker）
sudo apt install -y postgresql-14 redis-server mongodb
```

2. **部署应用**
```bash
# 创建项目目录
sudo mkdir -p /opt/tongpin-dazi
sudo chown $USER:$USER /opt/tongpin-dazi
cd /opt/tongpin-dazi

# 克隆代码
git clone https://github.com/your-username/tongpin-dazi.git .
cd backend

# 安装依赖
pnpm install --frozen-lockfile

# 配置环境
cp user-service/.env.example user-service/.env
nano user-service/.env
```

3. **配置数据库**
```bash
# 如果使用本地数据库
sudo -u postgres createdb tongpin_db
sudo -u postgres psql -c "CREATE USER tongpin_user WITH PASSWORD 'your_password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE tongpin_db TO tongpin_user;"
```

4. **启动应用**
```bash
# 开发模式
cd user-service
pnpm run dev

# 生产模式
pnpm run build
pnpm start
```

## 📊 方案三：PM2进程管理

### 安装和配置PM2

1. **安装PM2**
```bash
sudo npm install -g pm2
```

2. **创建PM2配置文件**
```bash
# ecosystem.config.js
module.exports = {
  apps: [{
    name: 'tongpin-user-service',
    script: 'dist/index.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true
  }]
};
```

3. **启动服务**
```bash
# 构建应用
pnpm run build

# 启动服务
pm2 start ecosystem.config.js

# 查看状态
pm2 status

# 查看日志
pm2 logs tongpin-user-service
```

## 🔒 安全配置

### 防火墙配置
```bash
# 开放服务端口
sudo ufw allow 3000
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443

# 启用防火墙
sudo ufw --force enable
```

### SSL证书配置（可选）
```bash
# 安装Certbot
sudo apt install -y certbot

# 获取SSL证书
sudo certbot certonly --standalone -d your-domain.com

# 配置HTTPS（在应用中）
# 使用环境变量配置SSL
SSL_CERT=/etc/letsencrypt/live/your-domain.com/fullchain.pem
SSL_KEY=/etc/letsencrypt/live/your-domain.com/privkey.pem
```

## 📈 监控和日志

### 日志配置
```bash
# 查看应用日志
tail -f user-service/logs/combined.log

# Docker日志
docker-compose logs -f

# PM2日志
pm2 logs
```

### 监控配置
```bash
# 安装监控工具（可选）
sudo apt install -y htop iotop ncdu

# 应用健康检查
curl http://localhost:3000/health
```

## 🔄 CI/CD 配置（可选）

### GitHub Actions 示例
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Deploy to server
      uses: appleboy/ssh-action@master
      with:
        host: ${{ secrets.SERVER_HOST }}
        username: ${{ secrets.SERVER_USER }}
        key: ${{ secrets.SERVER_KEY }}
        script: |
          cd /opt/tongpin-dazi
          git pull origin main
          cd backend
          pnpm install --frozen-lockfile
          pnpm run build
          pm2 restart ecosystem.config.js
```

## 🚀 域名和反向代理

### Nginx 配置示例
```nginx
server {
    listen 80;
    server_name your-domain.com;

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

## 📋 常见问题

### 1. 端口被占用
```bash
# 检查端口占用
sudo lsof -i :3000

# 杀掉进程
sudo kill -9 PID
```

### 2. 数据库连接失败
```bash
# 检查数据库状态
sudo systemctl status postgresql

# 检查Docker容器
docker-compose ps
```

### 3. 内存不足
```bash
# 增加swap空间
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### 4. 权限问题
```bash
# 修复权限
sudo chown -R $USER:$USER /opt/tongpin-dazi
chmod +x deploy.sh
```

## 📞 技术支持

如果遇到部署问题，请检查：
1. 系统要求是否满足
2. 环境变量是否正确配置
3. 端口是否被占用
4. 日志文件是否有错误信息

---

**🎉 选择合适的部署方案，让你的应用快速上线！**