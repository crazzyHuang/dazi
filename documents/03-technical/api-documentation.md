# 同频搭子 - API接口文档

## 1. API概览

### 1.1 接口设计原则
- **RESTful设计**：遵循REST架构风格
- **GraphQL补充**：复杂查询使用GraphQL
- **版本管理**：使用URL版本控制
- **统一响应**：标准化的响应格式
- **安全认证**：JWT Token认证机制

### 1.2 基础信息
- **Base URL**: `https://api.tongpin.com`
- **API版本**: `v1`
- **数据格式**: JSON
- **字符编码**: UTF-8
- **认证方式**: Bearer Token (JWT)

### 1.3 通用响应格式

#### 成功响应
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

#### 错误响应
```json
{
  "code": 400,
  "message": "Invalid request parameters",
  "error": {
    "type": "ValidationError",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  },
  "timestamp": "2024-03-15T10:30:00Z"
}
```

### 1.4 状态码说明
```
2xx 成功：
200 OK - 请求成功
201 Created - 资源创建成功
204 No Content - 请求成功但无返回内容

4xx 客户端错误：
400 Bad Request - 请求参数错误
401 Unauthorized - 未认证
403 Forbidden - 权限不足
404 Not Found - 资源不存在
422 Unprocessable Entity - 请求格式正确但语义错误

5xx 服务器错误：
500 Internal Server Error - 服务器内部错误
502 Bad Gateway - 网关错误
503 Service Unavailable - 服务不可用
```

## 2. 认证与授权

### 2.1 用户认证

#### 2.1.1 手机号注册
```http
POST /api/v1/auth/register/phone
Content-Type: application/json

{
  "phone": "13800138000",
  "code": "123456",
  "password": "password123",
  "nickname": "用户昵称"
}
```

**响应示例**：
```json
{
  "code": 201,
  "message": "Registration successful",
  "data": {
    "user": {
      "id": "user_123456789",
      "phone": "13800138000",
      "nickname": "用户昵称",
      "avatar": null,
      "created_at": "2024-03-15T10:30:00Z"
    },
    "tokens": {
      "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "expires_in": 7200
    }
  }
}
```

#### 2.1.2 用户登录
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "phone": "13800138000",
  "password": "password123"
}
```

#### 2.1.3 发送验证码
```http
POST /api/v1/auth/sms/send
Content-Type: application/json

{
  "phone": "13800138000",
  "type": "register" // register, login, reset_password
}
```

## 3. 用户管理API

### 3.1 用户资料管理

#### 3.1.1 获取用户信息
```http
GET /api/v1/users/me
Authorization: Bearer {access_token}
```

**响应示例**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "user_123456789",
    "phone": "13800138000",
    "nickname": "用户昵称",
    "avatar": "https://cdn.tongpin.com/avatars/user_123456789.jpg",
    "age": 25,
    "gender": "male",
    "location": {
      "city": "北京",
      "district": "朝阳区"
    },
    "profile": {
      "occupation": "产品经理",
      "bio": "一句话介绍自己",
      "interests": ["摄影", "旅行", "美食"]
    },
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

#### 3.1.2 更新用户资料
```http
PUT /api/v1/users/me
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "nickname": "新昵称",
  "age": 26,
  "bio": "更新的个人介绍",
  "interests": ["摄影", "旅行", "美食", "健身"]
}
```

### 3.2 搭子邀约API

#### 3.2.1 发布搭子邀约
```http
POST /api/v1/posts
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "title": "周末一起去看展览",
  "content": "想找个人一起去看艺术展，有相同兴趣的小伙伴吗？",
  "category": "culture",
  "location": {
    "name": "798艺术区",
    "latitude": 39.9888,
    "longitude": 116.4979
  },
  "time": "2024-03-16T14:00:00Z",
  "max_participants": 2,
  "tags": ["艺术", "展览", "文化"]
}
```

#### 3.2.2 获取搭子邀约列表
```http
GET /api/v1/posts
Authorization: Bearer {access_token}
Query Parameters:
  - category: culture (可选，分类筛选)
  - location: 39.9042,116.4074 (可选，经纬度)
  - radius: 10 (可选，搜索半径km)
  - limit: 20
  - offset: 0
```

#### 3.2.3 申请加入搭子
```http
POST /api/v1/posts/{post_id}/join
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "message": "我也很喜欢艺术展，可以一起去吗？"
}
```

## 4. 灵魂回响API

### 4.1 灵魂问题管理

#### 4.1.1 获取每日灵魂问题
```http
GET /api/v1/soul/daily-question
Authorization: Bearer {access_token}
```

**响应示例**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "soul_q_001",
    "question": "如果可以回到过去，你最想对年轻的自己说什么？",
    "category": "reflection",
    "date": "2024-03-15"
  }
}
```

#### 4.1.2 提交灵魂回答
```http
POST /api/v1/soul/answers
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "question_id": "soul_q_001",
  "answer": "我想告诉年轻的自己，勇敢地去尝试，不要害怕失败...",
  "is_public": true
}
```

#### 4.1.3 查看他人的灵魂回答
```http
GET /api/v1/soul/answers
Authorization: Bearer {access_token}
Query Parameters:
  - question_id: soul_q_001 (可选)
  - user_id: user_123456 (可选)
  - limit: 20
```

## 5. 匹配推荐API

### 5.1 获取推荐用户

#### 5.1.1 基于兴趣的推荐
```http
GET /api/v1/recommendations/users
Authorization: Bearer {access_token}
Query Parameters:
  - type: interest (interest, location, soul)
  - limit: 10
```

#### 5.1.2 基于地理位置的推荐
```http
GET /api/v1/recommendations/nearby
Authorization: Bearer {access_token}
Query Parameters:
  - radius: 5 (半径，公里)
  - limit: 10
```

#### 5.1.3 基于灵魂契合度的推荐
```http
GET /api/v1/recommendations/soul-match
Authorization: Bearer {access_token}
Query Parameters:
  - min_score: 80 (最低契合度分数)
  - limit: 10
```

## 6. 聊天通信API

### 6.1 对话管理

#### 6.1.1 发起对话
```http
POST /api/v1/conversations
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "participant_id": "user_987654321",
  "first_message": "你好！看到你也喜欢摄影"
}
```

#### 6.1.2 获取对话列表
```http
GET /api/v1/conversations
Authorization: Bearer {access_token}
```

#### 6.1.3 发送消息
```http
POST /api/v1/conversations/{conversation_id}/messages
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "type": "text",
  "content": "你好！很高兴认识你"
}
```

## 7. 文件上传API

### 7.1 图片上传

#### 7.1.1 上传头像
```http
POST /api/v1/upload/avatar
Authorization: Bearer {access_token}
Content-Type: multipart/form-data

avatar: [binary file data]
```

#### 7.1.2 上传聊天图片
```http
POST /api/v1/upload/chat-image
Authorization: Bearer {access_token}
Content-Type: multipart/form-data

image: [binary file data]
```

## 8. WebSocket实时通信

### 8.1 连接管理

#### 8.1.1 建立WebSocket连接
```
wss://api.tongpin.com/ws?token={access_token}
```

#### 8.1.2 实时事件

**新消息通知**：
```json
{
  "type": "new_message",
  "data": {
    "conversation_id": "conv_123456789",
    "message": {
      "id": "msg_987654321",
      "sender_id": "user_987654321",
      "content": "你好！",
      "created_at": "2024-03-15T10:30:00Z"
    }
  }
}
```

**在线状态更新**：
```json
{
  "type": "user_status",
  "data": {
    "user_id": "user_987654321",
    "status": "online"
  }
}
```

## 9. 系统API

### 9.1 应用配置

#### 9.1.1 获取应用配置
```http
GET /api/v1/config
```

#### 9.1.2 健康检查
```http
GET /api/v1/health
```

## 10. 错误处理

### 10.1 错误码定义

```
认证相关错误 (1000-1099):
1001 - Invalid credentials
1002 - Token expired
1003 - Token invalid

用户相关错误 (1100-1199):
1101 - User not found
1102 - Profile incomplete
1103 - Invalid user data

业务相关错误 (1200-1299):
1201 - Post not found
1202 - Cannot join own post
1203 - Post already full

系统相关错误 (5000-5099):
5001 - Internal server error
5002 - Service unavailable
```

---

**API文档说明**：本文档定义了同频搭子应用的核心API接口，采用RESTful设计规范，支持JWT认证，提供完整的用户管理、搭子邀约、灵魂回响等功能接口。