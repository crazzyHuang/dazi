# 同频搭子后端微服务

基于 pnpm workspace 的微服务架构，使用 TypeScript + Node.js 构建。

## 🏗️ 项目架构

```
backend/
├── user-service/          # 用户服务 (已完成)
├── post-service/          # 搭子服务 (框架已搭建)
├── chat-service/          # 聊天服务 (框架已搭建)
├── soul-service/          # 灵魂服务 (框架已搭建)
├── recommend-service/     # 推荐服务 (框架已搭建)
├── api-gateway/           # API网关 (框架已搭建)
├── package.json           # 工作区配置
├── pnpm-workspace.yaml    # pnpm工作区配置
├── docker-compose.yml     # Docker编排配置
└── start-services.sh      # 启动脚本
```

## 📦 包管理 (pnpm)

### 安装 pnpm

```bash
# 安装 pnpm
npm install -g pnpm

# 验证安装
pnpm --version
```

### 工作区特性

- **依赖共享**: 所有服务共享相同版本的依赖
- **快速安装**: 并行安装，速度更快
- **空间优化**: 硬链接减少重复安装
- **版本一致性**: 通过 catalog 确保版本统一

### 常用命令

```bash
# 安装所有依赖
pnpm install

# 安装特定服务依赖
pnpm install --filter user-service

# 运行所有服务开发模式
pnpm dev

# 构建所有服务
pnpm build

# 运行所有服务
pnpm start

# 运行测试
pnpm test

# 代码检查
pnpm lint

# 清理所有 node_modules
pnpm clean
```

## 🚀 快速开始

### 1. 环境准备

```bash
# 安装 pnpm
npm install -g pnpm

# 克隆项目 (假设)
# cd backend

# 安装依赖
pnpm install
```

### 2. 环境配置

```bash
# 复制环境文件
cp user-service/.env.example user-service/.env

# 编辑配置
vim user-service/.env
```

### 3. 启动服务

#### 方式一：使用 Docker (推荐)
```bash
./start-services.sh
```

#### 方式二：本地开发
```bash
# 启动数据库
docker-compose up -d postgres redis

# 安装依赖
pnpm install

# 启动用户服务
cd user-service && pnpm run dev
```

### 4. 验证服务

```bash
# 健康检查
curl http://localhost:3001/health

# 用户注册
curl -X POST http://localhost:3001/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"phone": "13800138001", "password": "123456", "nickname": "测试用户"}'
```

## 🔧 服务配置

### 用户服务 (Port: 3001)
- **功能**: 用户认证、资料管理
- **数据库**: PostgreSQL
- **缓存**: Redis
- **API**: `/api/v1/users/*`

### 其他服务
- **搭子服务**: Port 3002 - `/api/v1/posts/*`
- **聊天服务**: Port 3003 - `/api/v1/chat/*`
- **灵魂服务**: Port 3004 - `/api/v1/soul/*`
- **推荐服务**: Port 3005 - `/api/v1/recommend/*`
- **API网关**: Port 3000 - 统一入口

## 🗄️ 数据库配置

### PostgreSQL
- **主机**: localhost:5432
- **数据库**: tongpin_db
- **用户**: postgres
- **密码**: password

### Redis
- **主机**: localhost:6379
- **用途**: 缓存、会话存储

### MongoDB
- **主机**: localhost:27017
- **数据库**: tongpin_chat
- **用途**: 聊天记录、动态内容

## 🔐 环境变量

### 必需变量
```env
NODE_ENV=development
PORT=3001
DB_HOST=localhost
DB_NAME=tongpin_db
JWT_SECRET=your-secret-key
```

### 可选变量
```env
REDIS_URL=redis://localhost:6379
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:3001
LOG_LEVEL=info
```

## 📋 开发规范

### 代码规范
- 使用 TypeScript 编写
- 遵循 ESLint + Prettier 配置
- 使用 pnpm 管理依赖

### 提交规范
```bash
feat: 新功能
fix: 修复bug
docs: 文档更新
style: 代码格式化
refactor: 重构
test: 测试相关
```

### 目录结构规范
```
service-name/
├── src/
│   ├── config/        # 配置文件
│   ├── controllers/   # 控制器
│   ├── middleware/    # 中间件
│   ├── models/        # 数据模型
│   ├── routes/        # 路由定义
│   ├── services/      # 业务逻辑
│   └── index.ts       # 应用入口
├── tests/             # 测试文件
├── docs/              # 文档
├── Dockerfile         # Docker配置
├── package.json       # 依赖配置
└── README.md          # 服务说明
```

## 🐳 Docker 部署

### 构建镜像
```bash
# 构建用户服务镜像
docker build -t tongpin/user-service ./user-service

# 构建所有服务镜像
docker-compose build
```

### 运行容器
```bash
# 启动所有服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

## 🔍 监控和调试

### 日志查看
```bash
# 服务日志
docker-compose logs -f user-service

# 数据库日志
docker-compose logs -f postgres

# 所有日志
docker-compose logs -f
```

### 性能监控
- **健康检查**: `GET /health`
- **指标监控**: Prometheus + Grafana (待配置)
- **日志分析**: ELK Stack (待配置)

## 🚀 部署流程

### 开发环境
1. 本地开发测试
2. 提交代码到 Git
3. 自动构建 Docker 镜像
4. 部署到开发服务器

### 生产环境
1. 代码审查
2. 构建生产镜像
3. 运行测试套件
4. 部署到生产服务器
5. 监控和告警

## 📚 相关文档

- [用户服务 API 文档](./user-service/README.md)
- [数据库设计文档](../../documents/03-technical/database-design.md)
- [API 设计规范](../../documents/03-technical/api-documentation.md)
- [Docker 部署指南](../../documents/03-technical/architecture.md)

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](../LICENSE) 文件了解详情

---

**🎉 使用 pnpm workspace 让微服务开发更高效！**