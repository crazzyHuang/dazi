FROM node:18-alpine

# 创建应用目录
WORKDIR /app

# 安装系统依赖
RUN apk add --no-cache python3 make g++ curl

# 安装pnpm和nodemon
RUN npm install -g pnpm nodemon

# 创建非root用户
RUN addgroup -g 1001 -S nodejs && \
  adduser -S nextjs -u 1001

# 复制 workspace 根目录的配置文件
COPY --chown=nextjs:nodejs pnpm-workspace.yaml ./
COPY --chown=nextjs:nodejs package.json ./
COPY --chown=nextjs:nodejs pnpm-lock.yaml ./

# 复制所有服务的 package.json 文件（workspace 需要）
COPY --chown=nextjs:nodejs user-service/package.json ./user-service/
COPY --chown=nextjs:nodejs post-service/package.json ./post-service/
COPY --chown=nextjs:nodejs chat-service/package.json ./chat-service/
COPY --chown=nextjs:nodejs soul-service/package.json ./soul-service/
COPY --chown=nextjs:nodejs recommend-service/package.json ./recommend-service/
COPY --chown=nextjs:nodejs api-gateway/package.json ./api-gateway/

# 安装所有workspace依赖
RUN pnpm install --frozen-lockfile

# 复制当前服务的源代码
COPY --chown=nextjs:nodejs user-service/src ./user-service/src
COPY --chown=nextjs:nodejs user-service/tsconfig.json ./user-service/

# 设置工作目录为当前服务
WORKDIR /app/user-service

# 创建日志目录
RUN mkdir -p logs

# 切换到非root用户
USER nextjs

# 暴露端口
EXPOSE 3001

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3001/health || exit 1

# 启动命令 - 使用workspace命令
CMD ["pnpm", "dev"]
