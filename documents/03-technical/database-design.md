# 同频搭子 - 数据库设计文档

## 1. 数据库架构概览

### 1.1 架构设计原则
- **读写分离**：主从数据库架构，读多写少的业务特点
- **数据分离**：结构化数据与非结构化数据分离存储
- **数据安全**：敏感数据加密存储，访问权限控制
- **性能优化**：合理的索引设计和查询优化

### 1.2 数据库选型

**主数据库 - PostgreSQL**
- **用途**：用户基础信息、关系数据、事务性数据
- **优势**：强一致性、复杂查询支持、JSON数据类型
- **版本**：PostgreSQL 14+

**文档数据库 - MongoDB**
- **用途**：用户动态、聊天记录、灵魂回答内容
- **优势**：灵活的文档结构、水平扩展能力
- **版本**：MongoDB 5.0+

**缓存数据库 - Redis**
- **用途**：会话管理、热点数据缓存、实时计数
- **优势**：高性能、丰富的数据结构
- **版本**：Redis 7.0+

## 2. PostgreSQL 主数据库设计

### 2.1 用户相关表

#### 2.1.1 用户基础信息表 (users)
```sql
CREATE TABLE users (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone               VARCHAR(20) UNIQUE NOT NULL,
    email               VARCHAR(255) UNIQUE,
    password_hash       VARCHAR(255) NOT NULL,
    nickname            VARCHAR(50) NOT NULL,
    avatar_url          TEXT,
    age                 INTEGER CHECK (age >= 18 AND age <= 99),
    gender              VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    
    -- 位置信息
    city                VARCHAR(100),
    district            VARCHAR(100),
    latitude            DECIMAL(10, 8),
    longitude           DECIMAL(11, 8),
    
    -- 认证状态
    phone_verified      BOOLEAN DEFAULT FALSE,
    email_verified      BOOLEAN DEFAULT FALSE,
    
    -- 账户状态
    status              VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'deleted')),
    last_active_at      TIMESTAMP WITH TIME ZONE,
    
    -- 时间戳
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_location ON users(latitude, longitude);
CREATE INDEX idx_users_status_active ON users(status, last_active_at) WHERE status = 'active';
```

#### 2.1.2 用户详细资料表 (user_profiles)
```sql
CREATE TABLE user_profiles (
    user_id             UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    
    -- 基本信息
    occupation          VARCHAR(100),
    company             VARCHAR(200),
    education           VARCHAR(100),
    bio                 TEXT CHECK (char_length(bio) <= 500),
    
    -- 兴趣和标签 (JSON格式)
    interests           JSONB DEFAULT '[]',
    lifestyle           JSONB DEFAULT '{}', -- 生活方式数据
    personality_traits  JSONB DEFAULT '{}', -- 性格特征
    values              JSONB DEFAULT '{}', -- 价值观数据
    
    -- 偏好设置
    match_preferences   JSONB DEFAULT '{}', -- 匹配偏好
    
    -- 隐私设置
    privacy_settings    JSONB DEFAULT '{
        "show_location": true,
        "show_online_status": true,
        "allow_stranger_message": true
    }',
    
    -- 完整度
    completeness_score  INTEGER DEFAULT 0 CHECK (completeness_score >= 0 AND completeness_score <= 100),
    
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_user_profiles_interests ON user_profiles USING GIN(interests);
CREATE INDEX idx_user_profiles_completeness ON user_profiles(completeness_score);
```

### 2.2 搭子邀约相关表

#### 2.2.1 搭子邀约表 (posts)
```sql
CREATE TABLE posts (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- 基本信息
    title               VARCHAR(200) NOT NULL,
    content             TEXT CHECK (char_length(content) <= 2000),
    category            VARCHAR(50) NOT NULL,
    tags                TEXT[] DEFAULT '{}',
    
    -- 图片信息
    images              TEXT[] DEFAULT '{}',
    
    -- 时间和地点
    activity_time       TIMESTAMP WITH TIME ZONE,
    location_name       VARCHAR(200),
    location_address    TEXT,
    latitude            DECIMAL(10, 8),
    longitude           DECIMAL(11, 8),
    
    -- 参与者限制
    max_participants    INTEGER DEFAULT 2 CHECK (max_participants > 0),
    current_participants INTEGER DEFAULT 0 CHECK (current_participants >= 0),
    
    -- 状态
    status              VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'full', 'closed', 'completed')),
    
    -- 时间戳
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at          TIMESTAMP WITH TIME ZONE
);

-- 索引
CREATE INDEX idx_posts_user_id ON posts(user_id, created_at);
CREATE INDEX idx_posts_location ON posts(latitude, longitude);
CREATE INDEX idx_posts_time ON posts(activity_time);
CREATE INDEX idx_posts_category ON posts(category, status);
CREATE INDEX idx_posts_status ON posts(status, created_at);
CREATE INDEX idx_posts_tags ON posts USING GIN(tags);
```

#### 2.2.2 搭子申请表 (post_applications)
```sql
CREATE TABLE post_applications (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id             UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- 申请信息
    message             TEXT,
    status              VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled')),
    
    -- 时间戳
    applied_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status_updated_at   TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- 约束：一个用户只能申请一次同一个邀约
    CONSTRAINT unique_application UNIQUE(post_id, user_id)
);

-- 索引
CREATE INDEX idx_post_applications_post ON post_applications(post_id, status);
CREATE INDEX idx_post_applications_user ON post_applications(user_id, status);
```

### 2.3 灵魂回响相关表

#### 2.3.1 灵魂问题表 (soul_questions)
```sql
CREATE TABLE soul_questions (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- 问题内容
    question            TEXT NOT NULL,
    category            VARCHAR(50) NOT NULL,
    difficulty_level    INTEGER DEFAULT 1 CHECK (difficulty_level >= 1 AND difficulty_level <= 5),
    
    -- 问题标签
    tags                TEXT[] DEFAULT '{}',
    
    -- 状态
    status              VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'archived')),
    
    -- 统计信息
    answer_count        INTEGER DEFAULT 0,
    view_count          INTEGER DEFAULT 0,
    
    -- 时间戳
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_soul_questions_category ON soul_questions(category, status);
CREATE INDEX idx_soul_questions_status ON soul_questions(status, created_at);
CREATE INDEX idx_soul_questions_tags ON soul_questions USING GIN(tags);
```

#### 2.3.2 用户灵魂回答表 (soul_answers)
```sql
CREATE TABLE soul_answers (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id         UUID NOT NULL REFERENCES soul_questions(id) ON DELETE CASCADE,
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- 回答内容
    answer              TEXT NOT NULL CHECK (char_length(answer) <= 5000),
    is_public           BOOLEAN DEFAULT TRUE,
    
    -- 互动统计
    like_count          INTEGER DEFAULT 0,
    comment_count       INTEGER DEFAULT 0,
    
    -- 时间戳
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- 约束：一个用户对一个问题只能回答一次
    CONSTRAINT unique_user_answer UNIQUE(question_id, user_id)
);

-- 索引
CREATE INDEX idx_soul_answers_question ON soul_answers(question_id, is_public);
CREATE INDEX idx_soul_answers_user ON soul_answers(user_id, created_at);
CREATE INDEX idx_soul_answers_public ON soul_answers(is_public, created_at) WHERE is_public = true;
```

### 2.4 聊天相关表

#### 2.4.1 对话表 (conversations)
```sql
CREATE TABLE conversations (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    participant1_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    participant2_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- 对话状态
    status              VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'archived', 'blocked')),
    
    -- 最后消息信息
    last_message_id     UUID,
    last_message_at     TIMESTAMP WITH TIME ZONE,
    
    -- 时间戳
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- 约束：确保不重复创建对话
    CONSTRAINT unique_conversation CHECK (participant1_id < participant2_id)
);

-- 索引
CREATE INDEX idx_conversations_participant1 ON conversations(participant1_id, status);
CREATE INDEX idx_conversations_participant2 ON conversations(participant2_id, status);
CREATE INDEX idx_conversations_last_message ON conversations(last_message_at);
CREATE UNIQUE INDEX idx_unique_conversation ON conversations(LEAST(participant1_id, participant2_id), GREATEST(participant1_id, participant2_id)) WHERE status = 'active';
```

### 2.5 系统配置表

#### 2.5.1 系统配置表 (system_configs)
```sql
CREATE TABLE system_configs (
    key                 VARCHAR(100) PRIMARY KEY,
    value               JSONB NOT NULL,
    description         TEXT,
    category            VARCHAR(50) DEFAULT 'general',
    is_public           BOOLEAN DEFAULT FALSE,
    
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 插入初始配置
INSERT INTO system_configs (key, value, description, category, is_public) VALUES
('app_version', '{"latest": "1.0.0", "minimum": "1.0.0"}', '应用版本信息', 'app', true),
('daily_question_enabled', 'true', '每日灵魂问题功能开关', 'features', false),
('max_posts_per_day', '5', '用户每日最大发布邀约数', 'limits', false),
('soul_match_threshold', '80', '灵魂契合度最低阈值', 'algorithm', false);
```

## 3. MongoDB 文档数据库设计

### 3.1 聊天消息集合 (chat_messages)

```javascript
// 聊天消息文档结构
{
  _id: ObjectId("..."),
  conversation_id: "conv_123456789",
  
  // 发送者信息
  sender_id: "user_123456789",
  receiver_id: "user_987654321",
  
  // 消息内容
  message_type: "text", // text, image, voice, system
  content: "你好！很高兴认识你",
  
  // 媒体信息（根据消息类型）
  media: {
    url: "https://cdn.tongpin.com/messages/image_123.jpg",
    thumbnail: "https://cdn.tongpin.com/messages/image_123_thumb.jpg",
    size: 2048576,
    format: "jpeg"
  },
  
  // 消息状态
  status: "sent", // sent, delivered, read
  read_at: ISODate("2024-03-15T10:35:00Z"),
  
  // 时间戳
  created_at: ISODate("2024-03-15T10:30:00Z"),
  updated_at: ISODate("2024-03-15T10:35:00Z")
}

// 索引
db.chat_messages.createIndex({"conversation_id": 1, "created_at": -1})
db.chat_messages.createIndex({"sender_id": 1, "created_at": -1})
db.chat_messages.createIndex({"receiver_id": 1, "status": 1})
```

### 3.2 用户动态集合 (user_moments)

```javascript
// 用户动态文档结构
{
  _id: ObjectId("..."),
  user_id: "user_123456789",
  
  // 动态类型和内容
  type: "mood", // mood, activity, thought, photo
  content: "今天心情很好，想找个人一起去看电影",
  
  // 媒体内容
  media: [
    {
      type: "image",
      url: "https://cdn.tongpin.com/moments/image_123.jpg",
      thumbnail: "https://cdn.tongpin.com/moments/image_123_thumb.jpg"
    }
  ],
  
  // 位置信息
  location: {
    name: "三里屯",
    coordinates: [116.4074, 39.9042], // [longitude, latitude]
    city: "北京"
  },
  
  // 标签和分类
  tags: ["电影", "放松", "社交"],
  mood_score: 8, // 1-10心情评分
  
  // 可见性设置
  visibility: "public", // public, friends, private
  
  // 互动数据
  interactions: {
    likes: ["user_987654321", "user_111111111"],
    comments: [
      {
        user_id: "user_987654321",
        content: "我也想去看电影！",
        created_at: ISODate("2024-03-15T10:30:00Z")
      }
    ],
    views: 25
  },
  
  // 时间戳
  created_at: ISODate("2024-03-15T10:00:00Z"),
  updated_at: ISODate("2024-03-15T10:30:00Z")
}

// 索引
db.user_moments.createIndex({"user_id": 1, "created_at": -1})
db.user_moments.createIndex({"type": 1, "created_at": -1})
db.user_moments.createIndex({"tags": 1, "visibility": 1})
db.user_moments.createIndex({"location.coordinates": "2dsphere"})
```

### 3.3 用户行为日志集合 (user_behavior_logs)

```javascript
// 用户行为日志文档结构
{
  _id: ObjectId("..."),
  user_id: "user_123456789",
  session_id: "session_987654321",
  
  // 行为信息
  action: "view_post", // view_post, apply_post, send_message, view_profile
  category: "post", // auth, profile, post, chat, soul
  
  // 行为对象
  target: {
    type: "post", // user, post, message, question
    id: "post_987654321"
  },
  
  // 行为上下文
  context: {
    screen: "post_list",
    source: "recommendation", // recommendation, search, manual
    additional_data: {}
  },
  
  // 设备信息
  device: {
    platform: "ios",
    app_version: "1.0.0",
    os_version: "iOS 17.0"
  },
  
  // 时间戳
  timestamp: ISODate("2024-03-15T10:30:00Z")
}

// 索引
db.user_behavior_logs.createIndex({"user_id": 1, "timestamp": -1})
db.user_behavior_logs.createIndex({"action": 1, "timestamp": -1})
db.user_behavior_logs.createIndex({"timestamp": -1}) // TTL索引，保留90天
```

## 4. Redis 缓存设计

### 4.1 缓存键命名规范

```
命名规范：{service}:{type}:{key}

用户相关：
user:session:{user_id}              # 用户会话信息
user:profile:{user_id}              # 用户资料缓存
user:online:{user_id}               # 用户在线状态

搭子相关：
post:hot                            # 热门搭子邀约
post:nearby:{user_id}               # 附近的邀约
post:recommendations:{user_id}      # 推荐邀约

聊天相关：
chat:conversation:{conv_id}         # 对话信息
chat:unread:{user_id}               # 未读消息数

灵魂回响相关：
soul:daily_question                 # 每日问题
soul:answers:{question_id}          # 问题回答列表

系统相关：
system:config                       # 系统配置
api:rate_limit:{user_id}           # API限流
```

### 4.2 具体缓存结构

#### 4.2.1 用户会话缓存
```redis
# 用户会话信息
HSET user:session:user_123456789
  "user_id" "user_123456789"
  "nickname" "用户昵称"
  "avatar" "https://cdn.tongpin.com/avatars/user_123456789.jpg"
  "login_time" "2024-03-15T10:00:00Z"
  "last_activity" "2024-03-15T10:30:00Z"

EXPIRE user:session:user_123456789 86400  # 24小时过期
```

#### 4.2.2 热门内容缓存
```redis
# 热门搭子邀约（有序集合，按热度排序）
ZADD post:hot
  95 "post_123456789"
  88 "post_987654321"
  82 "post_111111111"

EXPIRE post:hot 3600  # 1小时过期

# 每日灵魂问题
SET soul:daily_question "soul_q_001"
EXPIRE soul:daily_question 86400  # 24小时过期
```

#### 4.2.3 实时计数器
```redis
# 用户未读消息数
SET chat:unread:user_123456789 3
EXPIRE chat:unread:user_123456789 3600

# 在线用户计数
SADD system:online_users "user_123456789"
EXPIRE system:online_users 300  # 5分钟过期
```

## 5. 数据安全与隐私

### 5.1 数据加密策略

#### 5.1.1 敏感字段加密
```sql
-- 创建加密函数
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 敏感数据加密存储
CREATE OR REPLACE FUNCTION encrypt_sensitive_data(data TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN encode(pgp_sym_encrypt(data, current_setting('app.encryption_key')), 'base64');
END;
$$ LANGUAGE plpgsql;

-- 解密函数
CREATE OR REPLACE FUNCTION decrypt_sensitive_data(encrypted_data TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN pgp_sym_decrypt(decode(encrypted_data, 'base64'), current_setting('app.encryption_key'));
END;
$$ LANGUAGE plpgsql;
```

### 5.2 访问控制

#### 5.2.1 行级安全策略
```sql
-- 启用行级安全
ALTER TABLE soul_answers ENABLE ROW LEVEL SECURITY;

-- 创建安全策略：用户只能访问自己的私有回答
CREATE POLICY soul_answers_privacy_policy ON soul_answers
    FOR ALL
    TO application_role
    USING (
        user_id = current_setting('app.current_user_id')::UUID 
        OR is_public = true
    );
```

## 6. 性能优化

### 6.1 查询优化

#### 6.1.1 常用查询的索引优化
```sql
-- 搭子邀约地理位置查询优化
CREATE INDEX CONCURRENTLY idx_posts_location_active 
ON posts (latitude, longitude, status) 
WHERE status = 'open';

-- 用户活跃度查询优化
CREATE INDEX CONCURRENTLY idx_users_active 
ON users (status, last_active_at) 
WHERE status = 'active';

-- 灵魂回答公开查询优化
CREATE INDEX CONCURRENTLY idx_soul_answers_public_recent 
ON soul_answers (is_public, created_at DESC) 
WHERE is_public = true;
```

### 6.2 数据归档策略

#### 6.2.1 历史数据归档
```sql
-- 创建归档表
CREATE TABLE chat_messages_archive (LIKE chat_messages INCLUDING ALL);

-- 归档90天前的聊天记录
INSERT INTO chat_messages_archive 
SELECT * FROM chat_messages 
WHERE created_at < NOW() - INTERVAL '90 days';

DELETE FROM chat_messages 
WHERE created_at < NOW() - INTERVAL '90 days';
```

---

**数据库设计总结**：本数据库设计采用PostgreSQL作为主数据库存储结构化数据，MongoDB存储非结构化内容，Redis提供高性能缓存。通过合理的表结构设计、索引优化和安全策略，确保系统的高性能运行和数据安全。