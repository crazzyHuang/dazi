FROM node:18-alpine

# 创建应用目录
WORKDIR /app

# 安装系统依赖
RUN apk add --no-cache python3 make g++ curl

# 安装pnpm
RUN npm install -g pnpm
# 安装 nodemon
RUN npm install -g nodemon

# 复制package文件
COPY package*.json ./

# 安装依赖（包含开发依赖）
RUN if [ -f pnpm-lock.yaml ]; then \
  pnpm install --frozen-lockfile; \
  else \
  pnpm install; \
  fi 

# 复制源代码
COPY . .

# 创建日志目录
RUN mkdir -p logs

# 创建非root用户
RUN addgroup -g 1001 -S nodejs && \
  adduser -S nextjs -u 1001

# 更改文件所有权
RUN chown -R nextjs:nodejs /app
USER nextjs

# 暴露端口
EXPOSE 3001

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3001/health || exit 1

# 启动命令
CMD ["pnpm", "dev"]