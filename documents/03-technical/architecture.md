# 同频搭子 - 技术架构文档

## 1. 架构概览

### 1.1 系统架构设计原则

- **高可用性**: 99.9%以上系统可用性，多地域部署容灾
- **高扩展性**: 微服务架构，支持水平扩展和弹性伸缩
- **高性能**: API响应<200ms，页面加载<2s
- **安全性**: 端到端加密，多层安全防护
- **可维护性**: 模块化设计，清晰的代码结构

### 1.2 技术栈选型

**后端技术栈**
- 运行时：Node.js 18+
- 开发语言：TypeScript
- Web框架：Express.js / Fastify
- 数据库：PostgreSQL + MongoDB + Redis
- 消息队列：RabbitMQ
- 容器化：Docker + Kubernetes

**前端技术栈**
- 移动端：Flutter + Dart
- Web端：React + Next.js
- 状态管理：Riverpod / Bloc
- UI组件：Material Design 3

**基础设施**
- 云平台：AWS / 阿里云
- CDN：CloudFront / 阿里云CDN
- 监控：Prometheus + Grafana
- 日志：ELK Stack

## 2. 系统架构图

```
┌─────────────────────────────────────────────────────────────┐
│                    客户端层 (Client Layer)                    │
├─────────────────────┬─────────────────────┬─────────────────┤
│     iOS App         │    Android App      │     Web App     │
│      Flutter        │      Flutter        │      React      │
└─────────────────────┴─────────────────────┴─────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                   网关层 (Gateway Layer)                      │
├─────────────────────┬─────────────────────┬─────────────────┤
│       CDN           │   Load Balancer     │   API Gateway   │
│   CloudFront        │       Nginx         │      Kong       │
└─────────────────────┴─────────────────────┴─────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                  应用服务层 (Service Layer)                   │
├───────────┬───────────┬───────────┬───────────┬─────────────┤
│ 用户服务   │ 搭子服务   │ 灵魂服务   │ 聊天服务   │  推荐服务    │
│User API   │Post API   │Soul API   │Chat API   │Recommend   │
│Node.js    │Node.js    │Node.js    │Node.js    │Python      │
└───────────┴───────────┴───────────┴───────────┴─────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                    数据层 (Data Layer)                       │
├─────────────────────┬─────────────────────┬─────────────────┤
│   PostgreSQL        │      MongoDB        │      Redis      │
│  (结构化数据)        │   (文档数据)         │     (缓存)      │
│用户、搭子、回答      │  聊天、动态、日志     │  会话、热点数据  │
└─────────────────────┴─────────────────────┴─────────────────┘
```

## 3. 核心服务设计

### 3.1 用户服务 (User Service)

**服务职责**
- 用户注册、登录认证
- 用户资料管理
- 权限控制

**技术实现**
```typescript
// 用户认证服务
interface AuthService {
  register(userData: RegisterRequest): Promise<AuthResponse>
  login(credentials: LoginRequest): Promise<AuthResponse>
  refreshToken(token: string): Promise<TokenResponse>
  logout(userId: string): Promise<void>
}

// 用户资料服务
interface UserService {
  getProfile(userId: string): Promise<UserProfile>
  updateProfile(userId: string, data: UpdateProfileRequest): Promise<UserProfile>
  uploadAvatar(userId: string, file: File): Promise<string>
}
```

**数据模型**
```sql
-- 用户基础表
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    nickname VARCHAR(50) NOT NULL,
    avatar_url TEXT,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 用户详细资料表
CREATE TABLE user_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id),
    age INTEGER,
    gender VARCHAR(10),
    city VARCHAR(100),
    occupation VARCHAR(100),
    bio TEXT,
    interests JSONB DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 3.2 搭子服务 (Post Service)

**服务职责**
- 搭子邀约的CRUD操作
- 地理位置搜索
- 搭子申请管理

**核心API**
```typescript
interface PostService {
  createPost(userId: string, postData: CreatePostRequest): Promise<Post>
  getPostsByLocation(location: GeoLocation, radius: number): Promise<Post[]>
  applyForPost(postId: string, userId: string, message: string): Promise<Application>
  approveApplication(applicationId: string): Promise<void>
}

// 地理位置搜索
interface GeoService {
  findNearbyPosts(lat: number, lng: number, radius: number): Promise<Post[]>
  calculateDistance(point1: GeoPoint, point2: GeoPoint): number
}
```

**数据模型**
```sql
-- 搭子邀约表
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    title VARCHAR(200) NOT NULL,
    content TEXT,
    category VARCHAR(50) NOT NULL,
    location_name VARCHAR(200),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    activity_time TIMESTAMP WITH TIME ZONE,
    max_participants INTEGER DEFAULT 2,
    status VARCHAR(20) DEFAULT 'open',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 地理位置索引
CREATE INDEX idx_posts_location ON posts USING GIST (ST_Point(longitude, latitude));
```

### 3.3 灵魂回响服务 (Soul Service)

**服务职责**
- 每日灵魂问题管理
- 用户回答存储
- 灵魂契合度计算

**算法设计**
```typescript
interface SoulService {
  getDailyQuestion(): Promise<SoulQuestion>
  submitAnswer(userId: string, answer: AnswerRequest): Promise<SoulAnswer>
  calculateCompatibility(user1Id: string, user2Id: string): Promise<number>
}

// 契合度计算算法
class CompatibilityCalculator {
  calculateSimilarity(answer1: string, answer2: string): number {
    // 1. 文本预处理
    const processed1 = this.preprocessText(answer1)
    const processed2 = this.preprocessText(answer2)
    
    // 2. 语义相似度计算
    const semanticScore = this.calculateSemanticSimilarity(processed1, processed2)
    
    // 3. 情感倾向分析
    const sentimentScore = this.calculateSentimentSimilarity(processed1, processed2)
    
    // 4. 综合评分
    return semanticScore * 0.7 + sentimentScore * 0.3
  }
}
```

### 3.4 聊天服务 (Chat Service)

**服务职责**
- 实时消息传输
- 对话管理
- 消息历史存储

**WebSocket架构**
```typescript
// WebSocket服务器
class ChatServer {
  private connections = new Map<string, WebSocket>()
  
  handleConnection(ws: WebSocket, userId: string) {
    this.connections.set(userId, ws)
    this.notifyUserOnline(userId)
  }
  
  sendMessage(senderId: string, receiverId: string, message: ChatMessage) {
    // 存储消息到MongoDB
    this.saveMessage(message)
    
    // 实时推送给接收者
    const receiverWs = this.connections.get(receiverId)
    if (receiverWs && receiverWs.readyState === WebSocket.OPEN) {
      receiverWs.send(JSON.stringify({
        type: 'new_message',
        data: message
      }))
    }
  }
}
```

### 3.5 推荐服务 (Recommendation Service)

**推荐算法**
```python
# Python推荐服务
class RecommendationEngine:
    def __init__(self):
        self.collaborative_filter = CollaborativeFiltering()
        self.content_filter = ContentBasedFiltering()
        self.location_filter = LocationBasedFiltering()
    
    def recommend_users(self, user_id: str, count: int = 10):
        # 获取用户特征
        user_features = self.get_user_features(user_id)
        
        # 多种推荐算法融合
        collab_scores = self.collaborative_filter.recommend(user_id)
        content_scores = self.content_filter.recommend(user_features)
        location_scores = self.location_filter.recommend(user_features)
        
        # 加权融合
        final_scores = self.merge_scores(collab_scores, content_scores, location_scores)
        return final_scores[:count]
```

## 4. 数据架构设计

### 4.1 数据库分工

**PostgreSQL - 关系型数据**
- 用户基础信息
- 搭子邀约数据
- 灵魂问题和回答
- 对话基础信息

**MongoDB - 文档数据**
- 聊天消息记录
- 用户动态内容
- 行为日志数据
- 推荐结果缓存

**Redis - 缓存数据**
- 用户会话信息
- 热点数据缓存
- 实时计数器
- 地理位置索引

### 4.2 缓存策略

```typescript
// 多级缓存架构
class CacheManager {
  private l1Cache: Map<string, any> = new Map() // 内存缓存
  private l2Cache: RedisClient                   // Redis缓存
  
  async get<T>(key: string): Promise<T | null> {
    // L1 内存缓存检查
    if (this.l1Cache.has(key)) {
      return this.l1Cache.get(key)
    }
    
    // L2 Redis缓存检查
    const cached = await this.l2Cache.get(key)
    if (cached) {
      const data = JSON.parse(cached)
      this.l1Cache.set(key, data)
      return data
    }
    
    return null
  }
  
  async set(key: string, value: any, ttl: number = 3600) {
    // 同时写入两级缓存
    this.l1Cache.set(key, value)
    await this.l2Cache.setex(key, ttl, JSON.stringify(value))
  }
}
```

## 5. API设计规范

### 5.1 RESTful API设计

**URL设计规范**
```
# 资源型API
GET    /api/v1/users              # 获取用户列表
GET    /api/v1/users/{id}         # 获取特定用户
POST   /api/v1/users              # 创建用户
PUT    /api/v1/users/{id}         # 更新用户
DELETE /api/v1/users/{id}         # 删除用户

# 行为型API
POST   /api/v1/posts/{id}/join    # 申请加入搭子
POST   /api/v1/auth/login         # 用户登录
POST   /api/v1/auth/logout        # 用户登出
```

**统一响应格式**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    // 具体数据内容
  },
  "timestamp": "2024-03-15T10:30:00Z"
}
```

### 5.2 认证授权

**JWT Token设计**
```typescript
interface JWTPayload {
  sub: string      // 用户ID
  iat: number      // 签发时间
  exp: number      // 过期时间
  scope: string[]  // 权限范围
}

// 认证中间件
const authenticateToken = (req: Request, res: Response, next: NextFunction) => {
  const authHeader = req.headers['authorization']
  const token = authHeader && authHeader.split(' ')[1]
  
  if (!token) {
    return res.status(401).json({ error: 'Access token required' })
  }
  
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'Invalid token' })
    req.user = user
    next()
  })
}
```

## 6. 安全架构

### 6.1 数据安全

**敏感数据加密**
```typescript
class SecurityService {
  // 密码哈希
  hashPassword(password: string): string {
    return bcrypt.hashSync(password, 12)
  }
  
  // 敏感字段加密
  encryptSensitiveData(data: string): string {
    const cipher = crypto.createCipher('aes-256-gcm', process.env.ENCRYPTION_KEY)
    let encrypted = cipher.update(data, 'utf8', 'hex')
    encrypted += cipher.final('hex')
    return encrypted
  }
  
  // 消息端到端加密
  encryptMessage(message: string, publicKey: string): string {
    return crypto.publicEncrypt(publicKey, Buffer.from(message)).toString('base64')
  }
}
```

### 6.2 安全防护

```typescript
// 安全中间件
app.use(helmet()) // 设置安全HTTP头
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(','),
  credentials: true
}))

// 限流防护
app.use('/api', rateLimit({
  windowMs: 15 * 60 * 1000, // 15分钟
  max: 100, // 每IP限制100次请求
  message: 'Too many requests'
}))

// 输入验证
app.use('/api', (req, res, next) => {
  // XSS防护
  req.body = sanitize(req.body)
  next()
})
```

## 7. 性能优化

### 7.1 数据库优化

**索引策略**
```sql
-- 复合索引优化搭子查询
CREATE INDEX idx_posts_category_location ON posts (category, latitude, longitude) 
WHERE status = 'open';

-- 部分索引优化活跃用户查询
CREATE INDEX idx_users_active ON users (last_active_at) 
WHERE status = 'active';

-- 全文索引优化搜索
CREATE INDEX idx_posts_search ON posts USING gin(to_tsvector('chinese', title || ' ' || content));
```

**查询优化**
```typescript
// 分页查询优化
class PostRepository {
  async findPosts(params: FindPostsParams) {
    const { category, location, limit = 20, offset = 0 } = params
    
    return this.db.query(`
      SELECT p.*, u.nickname, u.avatar_url
      FROM posts p
      JOIN users u ON p.user_id = u.id
      WHERE p.category = $1
        AND ST_DWithin(ST_Point(p.longitude, p.latitude), ST_Point($2, $3), $4)
        AND p.status = 'open'
      ORDER BY p.created_at DESC
      LIMIT $5 OFFSET $6
    `, [category, location.lng, location.lat, 10000, limit, offset])
  }
}
```

### 7.2 前端性能优化

**Flutter性能优化**
```dart
// 图片懒加载
class LazyNetworkImage extends StatelessWidget {
  final String imageUrl;
  
  const LazyNetworkImage({Key? key, required this.imageUrl}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      memCacheWidth: 300,
      memCacheHeight: 300,
    );
  }
}

// 列表虚拟化
class VirtualizedListView extends StatelessWidget {
  final List<dynamic> items;
  final Widget Function(BuildContext, int) itemBuilder;
  
  const VirtualizedListView({
    Key? key,
    required this.items,
    required this.itemBuilder,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: itemBuilder,
      cacheExtent: 1000,
      addRepaintBoundaries: true,
      addAutomaticKeepAlives: true,
    );
  }
}

// 状态管理优化（使用Riverpod）
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(const UserState.loading());
  
  Future<void> loadUser(String userId) async {
    try {
      state = const UserState.loading();
      final user = await userRepository.getUser(userId);
      state = UserState.data(user);
    } catch (e) {
      state = UserState.error(e.toString());
    }
  }
}
```

## 8. 部署运维

### 8.1 容器化部署

**Dockerfile**
```dockerfile
FROM node:18-alpine

WORKDIR /app

# 安装依赖
COPY package*.json ./
RUN npm ci --only=production

# 复制源码
COPY . .

# 构建应用
RUN npm run build

# 暴露端口
EXPOSE 3000

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:3000/health || exit 1

# 启动应用
CMD ["npm", "start"]
```

**Kubernetes部署**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-service
        image: tongpin/user-service:latest
        ports:
        - containerPort: 3000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

### 8.2 监控告警

**Prometheus监控**
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'user-service'
    static_configs:
      - targets: ['user-service:3000']
    metrics_path: '/metrics'
    
  - job_name: 'post-service'
    static_configs:
      - targets: ['post-service:3000']
    metrics_path: '/metrics'
```

**应用监控指标**
```typescript
// 自定义监控指标
const promClient = require('prom-client')

// API响应时间
const httpDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status']
})

// 业务指标
const userRegistrations = new promClient.Counter({
  name: 'user_registrations_total',
  help: 'Total number of user registrations'
})

const activeConnections = new promClient.Gauge({
  name: 'websocket_connections_active',
  help: 'Number of active WebSocket connections'
})
```

## 9. CI/CD流程

### 9.1 自动化部署

**GitHub Actions**
```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
    - name: Install dependencies
      run: npm ci
    - name: Run tests
      run: npm test
    - name: Run lint
      run: npm run lint

  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Build Docker image
      run: docker build -t tongpin/user-service:${{ github.sha }} .
    - name: Deploy to Kubernetes
      run: |
        kubectl set image deployment/user-service user-service=tongpin/user-service:${{ github.sha }}
        kubectl rollout status deployment/user-service
```

## 10. 技术演进规划

### 10.1 短期优化目标 (3-6个月)

- **性能优化**: 实现API响应时间<100ms目标
- **监控完善**: 建立完整的APM监控体系
- **安全加固**: 实施零信任安全架构
- **缓存优化**: 引入分布式缓存集群

### 10.2 中期发展规划 (6-12个月)

- **AI集成**: 集成大语言模型优化推荐算法
- **微服务拆分**: 进一步细化服务边界
- **数据湖建设**: 构建用户行为数据分析平台
- **国际化支持**: 支持多语言和多地域部署

### 10.3 长期技术愿景 (1-2年)

- **边缘计算**: 引入边缘节点降低延迟
- **区块链集成**: 探索去中心化用户身份认证
- **AR/VR支持**: 为元宇宙社交做技术储备
- **量子加密**: 前瞻性的安全技术研究

---

**架构文档总结**: 本技术架构文档为同频搭子应用定义了完整的技术实施方案，采用现代化的微服务架构、多数据库存储策略和容器化部署，确保系统具备高可用性、高扩展性和高性能，为产品的长期发展奠定坚实的技术基础。