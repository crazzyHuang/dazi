# 同频搭子 - API接口文档 (V2.0)

**版本：2.0**
**关联技术文档：architecture_v2.md, database-design_v2.md**

## 1. 概述

本文档定义了“同频搭子”App客户端与服务端之间通信的RESTful API。所有API请求和响应的主体均为JSON格式，所有API端点都以 `https://api.tongpindazi.com/v1` 为基础URL。

## 2. 认证 (Authentication)

本API使用 **JWT (JSON Web Token)** 进行认证。用户通过 `/auth/login` 获取token，后续所有需要认证的请求，都必须在HTTP Header中加入 `Authorization` 字段。

`Authorization: Bearer <your_jwt_token>`

## 3. API端点定义

--- 

### 模块一：用户与认证 (`/auth`, `/users`)

#### **1. 用户注册**
- **Endpoint**: `POST /auth/register`
- **描述**: 创建一个新用户账户。
- **认证**: 否
- **请求体**:
  ```json
  {
    "email": "user@example.com",
    "password": "your_strong_password",
    "nickname": "阿同"
  }
  ```
- **成功响应 (201 Created)**:
  ```json
  {
    "message": "User created successfully"
  }
  ```

#### **2. 用户登录**
- **Endpoint**: `POST /auth/login`
- **描述**: 用户登录并获取JWT。
- **认证**: 否
- **请求体**:
  ```json
  {
    "email": "user@example.com",
    "password": "your_strong_password"
  }
  ```
- **成功响应 (200 OK)**:
  ```json
  {
    "accessToken": "ey...your_jwt_token..."
  }
  ```

#### **3. 获取当前用户信息**
- **Endpoint**: `GET /users/me`
- **描述**: 获取当前已登录用户的详细信息。
- **认证**: 是
- **成功响应 (200 OK)**:
  ```json
  {
    "id": "1",
    "email": "user@example.com",
    "nickname": "阿同",
    "avatar_url": "https://..."
  }
  ```

--- 

### 模块二：“搭子”系统 (`/posts`)

#### **1. 获取搭子邀约列表**
- **Endpoint**: `GET /posts`
- **描述**: 获取“搭子广场”的邀约列表，支持分页和筛选。
- **认证**: 否
- **查询参数**:
  - `page` (可选, number): 页码，默认1。
  - `limit` (可选, number): 每页数量，默认20。
  - `activity_type` (可选, string): 按活动类型筛选。
- **成功响应 (200 OK)**:
  ```json
  {
    "data": [
      {
        "id": "101",
        "author": { "nickname": "小明", "avatar_url": "..." },
        "title": "一起打羽毛球，新手局",
        "activity_type": "运动",
        "event_timestamp": "2025-09-10T19:00:00Z"
      }
    ],
    "pagination": { "page": 1, "limit": 20, "total": 150 }
  }
  ```

#### **2. 创建搭子邀约**
- **Endpoint**: `POST /posts`
- **描述**: 发布一个新的搭子邀约。
- **认证**: 是
- **请求体**:
  ```json
  {
    "title": "看XX美术馆的新展览",
    "description": "希望你懂一点点艺术，可以一起聊聊。",
    "activity_type": "看展",
    "event_timestamp": "2025-09-12T14:00:00Z",
    "location": "XX美术馆"
  }
  ```
- **成功响应 (201 Created)**:
  ```json
  {
    "id": "102",
    "message": "Post created successfully"
  }
  ```

--- 

### 模块三：“灵魂”系统 (`/soul`)

#### **1. 回答一个灵魂问题**
- **Endpoint**: `POST /soul/answers`
- **描述**: 用户提交对一个灵魂问题的回答。
- **认证**: 是
- **请求体**:
  ```json
  {
    "question_id": 1,
    "answer_text": "我18岁时很迷茫，想告诉他，别怕，你走的每一步都算数。"
  }
  ```
- **成功响应 (201 Created)**:
  ```json
  {
    "id": "501",
    "message": "Answer saved successfully"
  }
  ```

#### **2. 查看他人的灵魂回响**
- **Endpoint**: `GET /users/{userId}/soul-profile`
- **描述**: 查看目标用户与当前用户共同回答过的问题列表（答案是锁住的）。
- **认证**: 是
- **URL参数**: `userId` (目标用户的ID)
- **成功响应 (200 OK)**:
  ```json
  {
    "common_questions": [
      {
        "question_id": 1,
        "question_text": "如果能回到过去，你会对18岁的自己说什么？",
        "is_unlocked": false
      },
      {
        "question_id": 2,
        "question_text": "最近哪一首歌，让你单曲循环了很久？",
        "is_unlocked": true, // 假设这个问题已经解锁
        "my_answer": "...",
        "their_answer": "..."
      }
    ]
  }
  ```

#### **3. 解锁一个灵魂回答**
- **Endpoint**: `POST /soul/questions/{questionId}/unlock`
- **描述**: 用自己的回答去解锁目标用户对同一个问题的回答。
- **认证**: 是
- **URL参数**: `questionId` (要解锁的问题ID)
- **请求体**:
  ```json
  {
    "target_user_id": "2"
  }
  ```
- **成功响应 (200 OK)**:
  ```json
  {
    "question_id": 1,
    "their_answer": "他/她的答案文本..."
  }
  ```
