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

# 复制package文件，并指定用户权限
COPY --chown=nextjs:nodejs package*.json pnpm-lock.yaml* ./

# 安装依赖（包含开发依赖）
RUN pnpm install 

# 复制源代码（同时保证文件权限属于 nextjs）
COPY --chown=nextjs:nodejs . .

# 创建日志目录
RUN mkdir -p logs

# 切换到非root用户
USER nextjs

# 暴露端口
EXPOSE 3001

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3001/health || exit 1

# 启动命令
CMD ["pnpm", "dev"]
