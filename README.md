# 同频搭子 (TongPin DaZi)

🎯 **基于深度匹配算法的社交平台，让用户找到真正"同频"的搭子**

![Node.js](https://img.shields.io/badge/Node.js-18+-green)
![TypeScript](https://img.shields.io/badge/TypeScript-5.2+-blue)
![pnpm](https://img.shields.io/badge/pnpm-8.0+-yellow)
![Docker](https://img.shields.io/badge/Docker-Ready-blue)

## 📋 项目简介

同频搭子是一个基于深度匹配算法的社交平台，旨在让用户找到真正"同频"的搭子。不仅仅是表面的兴趣相同，更是生活轨迹、思维模式、价值观念的深层契合。

### 🎯 核心特性

- **深度匹配算法**：从"兴趣匹配"升级到"轨迹同频+思维共振"
- **多元搭子生态**：活动搭子、心灵搭子、成长搭子
- **智能破冰助手**：AI驱动的个性化推荐和话题建议
- **线下连接导向**：促进真实见面而非停留在线上
- **微服务架构**：支持快速迭代和水平扩展

## 🏗️ 技术架构

### 后端技术栈
- **运行时**: Node.js 18+
- **语言**: TypeScript 5.2+
- **框架**: Express.js
- **包管理**: pnpm workspace
- **数据库**: PostgreSQL + MongoDB + Redis + Elasticsearch
- **容器化**: Docker + Docker Compose
- **部署**: 支持本地和云服务器部署

### 微服务架构
```
┌─────────────────┐    ┌─────────────────┐
│   API Gateway   │────│   用户服务       │
│   (Port 3000)   │    │   (Port 3001)   │
└─────────────────┘    └─────────────────┘
         │                       │
         │                       │
         ▼                       ▼
┌─────────────────┐    ┌─────────────────┐
│   搭子服务       │────│   聊天服务       │
│   (Port 3002)   │    │   (Port 3003)   │
└─────────────────┘    └─────────────────┘
         │                       │
         │                       │
         ▼                       ▼
┌─────────────────┐    ┌─────────────────┐
│   灵魂服务       │────│   推荐服务       │
│   (Port 3004)   │    │   (Port 3005)   │
└─────────────────┘    └─────────────────┘
         │                       │
         ▼                       ▼
┌───────────────────────────────────────┐
│           数据库集群                   │
│   PostgreSQL + MongoDB + Redis + ES   │
└───────────────────────────────────────┘
```

## 🚀 快速开始

### 环境要求
- Node.js 18+
- pnpm 8.0+
- Docker & Docker Compose
- Git

### 本地开发

1. **克隆项目**
```bash
git clone https://github.com/your-username/tongpin-dazi.git
cd tongpin-dazi
```

2. **安装依赖**
```bash
cd backend
pnpm install
```

3. **启动服务**
```bash
# 启动所有基础服务
./start-services.sh

# 或手动启动
docker-compose up -d postgres redis mongodb elasticsearch
cd user-service && pnpm run dev
```

4. **测试API**
```bash
# 健康检查
curl http://localhost:3001/health

# 用户注册
curl -X POST http://localhost:3001/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"phone": "13800138001", "password": "123456", "nickname": "测试用户"}'
```

### 云服务器部署

1. **上传部署脚本**
```bash
scp deploy.sh root@your-server-ip:/root/
```

2. **运行自动部署**
```bash
# 在服务器上
chmod +x deploy.sh
sudo ./deploy.sh production
```

3. **配置环境变量**
```bash
nano user-service/.env
# 编辑数据库和JWT配置
```

4. **启动服务**
```bash
cd backend
docker-compose up -d
```

## 📁 项目结构

```
tongpin-dazi/
├── backend/                    # 后端微服务
│   ├── user-service/          # 用户服务
│   ├── post-service/          # 搭子服务
│   ├── chat-service/          # 聊天服务
│   ├── soul-service/          # 灵魂服务
│   ├── recommend-service/     # 推荐服务
│   ├── api-gateway/           # API网关
│   ├── docker-compose.yml     # 容器编排
│   ├── pnpm-workspace.yaml    # pnpm配置
│   └── start-services.sh      # 启动脚本
├── frontend/                   # 前端应用（待开发）
├── documents/                  # 项目文档
├── .gitignore                 # Git忽略文件
├── deploy.sh                  # 部署脚本
├── CLOUD_DEPLOYMENT.md        # 云部署指南
└── README.md                  # 项目说明
```

## 🔧 API 接口

### 用户认证
- `POST /api/v1/auth/register` - 用户注册
- `POST /api/v1/auth/login` - 用户登录
- `POST /api/v1/auth/logout` - 用户登出
- `GET /api/v1/auth/refresh-token` - 刷新令牌

### 用户管理
- `GET /api/v1/users/profile` - 获取用户资料
- `PUT /api/v1/users/profile` - 更新用户资料
- `GET /api/v1/users/search` - 搜索用户

### 健康检查
- `GET /health` - 服务健康状态

## 🗄️ 数据库设计

### PostgreSQL
- **用户基础信息**：users, user_interests, user_locations
- **搭子邀约**：posts, post_participants
- **匹配历史**：user_matches, user_behaviors

### MongoDB
- **聊天记录**：chat_messages, chat_rooms
- **用户动态**：user_feeds, user_activities

### Redis
- **会话管理**：user_sessions
- **缓存数据**：api_cache, hot_data
- **计数器**：user_stats, post_stats

## 🚀 部署方案

### 开发环境
```bash
# 使用Docker Compose
docker-compose up -d
```

### 生产环境
```bash
# 使用部署脚本
./deploy.sh production

# 或使用systemd
systemctl start tongpin-dazi
```

### 容器化部署
```bash
# 构建镜像
docker build -t tongpin/user-service ./backend/user-service

# 运行容器
docker-compose up -d
```

## 🔐 环境配置

### 必需环境变量
```env
NODE_ENV=production
PORT=3001
DB_HOST=localhost
DB_NAME=tongpin_db
JWT_SECRET=your-secret-key
```

### 可选环境变量
```env
REDIS_URL=redis://localhost:6379
ALLOWED_ORIGINS=https://your-domain.com
LOG_LEVEL=info
```

## 📈 监控和日志

### 日志文件
- `logs/combined.log` - 综合日志
- `logs/error.log` - 错误日志
- `logs/err.log` - PM2错误日志

### 监控指标
```bash
# 服务健康
curl http://localhost:3001/health

# Docker状态
docker-compose ps

# PM2状态（如果使用）
pm2 status
```

## 🤝 开发指南

### 代码规范
- 使用TypeScript编写
- 遵循ESLint + Prettier配置
- 使用pnpm管理依赖

### 提交规范
```bash
feat: 新功能
fix: 修复bug
docs: 文档更新
style: 代码格式化
refactor: 重构
test: 测试相关
```

### 分支策略
- `main` - 主分支
- `develop` - 开发分支
- `feature/*` - 功能分支
- `hotfix/*` - 紧急修复

## 📚 相关文档

- [技术架构文档](./documents/03-technical/architecture.md)
- [API设计规范](./documents/03-technical/api-documentation.md)
- [数据库设计](./documents/03-technical/database-design.md)
- [云部署指南](./CLOUD_DEPLOYMENT.md)
- [后端开发指南](./backend/README.md)

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📞 联系方式

- 项目维护者：TongPin DaZi Team
- 技术支持：dev@tongpin.com
- 项目主页：[GitHub](https://github.com/your-username/tongpin-dazi)

---

**🎉 让每一个孤独的灵魂都能找到同频的伙伴！**