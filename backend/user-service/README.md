# User Service

用户服务是同频搭子社交平台的微服务之一，负责用户认证、用户资料管理等核心功能。

## 功能特性

- 🔐 用户注册和登录（手机号 + 密码）
- 🔑 JWT Token 认证
- 👤 用户资料管理
- 📸 头像上传
- 🔍 用户搜索
- 🛡️ 安全中间件和请求限流

## 技术栈

- **运行时**: Node.js 18+
- **语言**: TypeScript
- **框架**: Express.js
- **数据库**: PostgreSQL
- **缓存**: Redis
- **认证**: JWT

## 快速开始

### 环境要求

- Node.js 18+
- PostgreSQL 14+
- Redis 7+
- npm 或 yarn

### 安装依赖

```bash
# 安装pnpm（如果没有安装）
npm install -g pnpm

# 安装依赖
pnpm install
```

### 环境配置

1. 复制环境配置文件：
```bash
cp .env.example .env
```

2. 修改 `.env` 文件中的配置项：
```env
NODE_ENV=development
PORT=3001
DB_HOST=localhost
DB_PORT=5432
DB_NAME=tongpin_db
DB_USER=postgres
DB_PASSWORD=password
JWT_SECRET=your-secret-key
```

### 数据库设置

1. 创建数据库：
```sql
CREATE DATABASE tongpin_db;
```

2. 运行数据库迁移（需要先创建迁移脚本）

### 启动服务

开发模式：
```bash
pnpm run dev
```

生产模式：
```bash
pnpm run build
pnpm start
```

服务将在 `http://localhost:3001` 启动

## API 接口

### 认证相关

- `POST /api/v1/auth/register` - 用户注册
- `POST /api/v1/auth/login` - 用户登录
- `POST /api/v1/auth/refresh-token` - 刷新令牌
- `POST /api/v1/auth/logout` - 用户登出

### 用户相关

- `GET /api/v1/users/profile` - 获取用户资料
- `PUT /api/v1/users/profile` - 更新用户资料
- `POST /api/v1/users/avatar` - 上传头像
- `GET /api/v1/users/search` - 搜索用户
- `GET /api/v1/users/:id` - 获取特定用户信息

## 项目结构

```
src/
├── config/          # 配置文件
├── controllers/     # 控制器
├── middleware/      # 中间件
├── models/          # 数据模型
├── routes/          # 路由定义
├── services/        # 业务逻辑
└── index.ts         # 应用入口
```

## 开发规范

### 代码规范

- 使用 TypeScript 编写
- 遵循 ESLint 配置
- 使用 Prettier 格式化代码

### 提交规范

- feat: 新功能
- fix: 修复bug
- docs: 文档更新
- style: 代码格式化
- refactor: 重构
- test: 测试相关

### 测试

```bash
# 运行单元测试
npm test

# 运行测试覆盖率
npm run test:coverage
```

## 部署

### Docker 部署

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3001
CMD ["npm", "start"]
```

### Kubernetes 部署

参考 `infrastructure/k8s/` 目录下的配置文件

## 监控和日志

- 健康检查: `GET /health`
- 日志文件: `logs/` 目录
- 错误日志: `logs/error.log`
- 综合日志: `logs/combined.log`

## 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 联系方式

- 项目维护者：TongPin DaZi Team
- 技术支持：dev@tongpin.com