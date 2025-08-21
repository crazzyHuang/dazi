# 同频搭子 - 测试计划文档

## 1. 测试概述

### 1.1 测试目标
- **功能验证**：确保所有功能按照需求正确实现
- **性能保证**：验证系统在预期负载下的性能表现
- **安全防护**：确保用户数据和系统安全
- **用户体验**：验证产品的易用性和用户满意度

### 1.2 测试范围

**包含范围**：
- 用户注册、登录、资料管理功能
- 搭子邀约发布和申请功能
- 灵魂回响问答功能
- 聊天通信和实时消息功能
- 推荐匹配功能
- 系统管理和配置功能

**排除范围**：
- 第三方服务的内部逻辑测试
- 底层操作系统和硬件测试

### 1.3 测试策略

#### 1.3.1 测试金字塔
```
                    E2E测试 (10%)
                  端到端用户场景测试
                
               集成测试 (30%)
             API集成、服务间通信测试
           
          单元测试 (60%)
        函数、方法、组件级别测试
```

### 1.4 测试环境

#### 1.4.1 环境配置
```
开发环境 (DEV)：
- 用途：开发人员日常测试
- 数据：模拟数据
- 更新频率：实时

测试环境 (TEST)：
- 用途：功能测试、集成测试
- 数据：测试专用数据集
- 更新频率：每日构建

预生产环境 (STAGING)：
- 用途：最终验证、用户验收测试
- 数据：生产数据的脱敏副本
- 更新频率：版本发布前
```

## 2. 单元测试计划

### 2.1 后端单元测试

#### 2.1.1 用户服务测试
```javascript
// 用户注册功能测试
describe('User Registration', () => {
  test('should register user with valid phone number', async () => {
    const userData = {
      phone: '13800138000',
      password: 'password123',
      nickname: 'testuser'
    };
    
    const result = await userService.register(userData);
    
    expect(result.success).toBe(true);
    expect(result.user.phone).toBe(userData.phone);
    expect(result.user.id).toBeDefined();
  });
  
  test('should reject registration with invalid phone', async () => {
    const userData = {
      phone: '1234567890', // 无效手机号
      password: 'password123',
      nickname: 'testuser'
    };
    
    await expect(userService.register(userData))
      .rejects.toThrow('Invalid phone number');
  });
});

// 用户认证测试
describe('User Authentication', () => {
  test('should authenticate user with correct credentials', async () => {
    const credentials = {
      phone: '13800138000',
      password: 'password123'
    };
    
    const result = await authService.login(credentials);
    
    expect(result.success).toBe(true);
    expect(result.token).toBeDefined();
    expect(result.user).toBeDefined();
  });
});
```

#### 2.1.2 搭子邀约服务测试
```javascript
// 搭子邀约创建测试
describe('Post Creation', () => {
  test('should create post with valid data', async () => {
    const postData = {
      title: '周末一起去看展览',
      content: '想找个人一起去看艺术展',
      category: 'culture',
      location: {
        name: '798艺术区',
        latitude: 39.9888,
        longitude: 116.4979
      },
      activity_time: '2024-03-16T14:00:00Z',
      max_participants: 2
    };
    
    const result = await postService.createPost('user_123', postData);
    
    expect(result.success).toBe(true);
    expect(result.post.title).toBe(postData.title);
    expect(result.post.status).toBe('open');
  });
  
  test('should validate required fields', async () => {
    const invalidPostData = {
      content: '缺少标题的邀约'
    };
    
    await expect(postService.createPost('user_123', invalidPostData))
      .rejects.toThrow('Title is required');
  });
});

// 搭子申请测试
describe('Post Application', () => {
  test('should allow user to apply for post', async () => {
    const result = await postService.applyForPost('post_123', 'user_456', {
      message: '我也想参加'
    });
    
    expect(result.success).toBe(true);
    expect(result.application.status).toBe('pending');
  });
  
  test('should prevent duplicate applications', async () => {
    await postService.applyForPost('post_123', 'user_456', {
      message: '第一次申请'
    });
    
    await expect(postService.applyForPost('post_123', 'user_456', {
      message: '重复申请'
    })).rejects.toThrow('Already applied for this post');
  });
});
```

#### 2.1.3 灵魂回响服务测试
```javascript
// 灵魂问题服务测试
describe('Soul Questions Service', () => {
  test('should get daily question', async () => {
    const question = await soulService.getDailyQuestion();
    
    expect(question).toBeDefined();
    expect(question.question).toBeTruthy();
    expect(question.category).toBeTruthy();
  });
  
  test('should save user answer', async () => {
    const answerData = {
      question_id: 'soul_q_001',
      answer: '我想告诉年轻的自己，勇敢地去尝试',
      is_public: true
    };
    
    const result = await soulService.saveAnswer('user_123', answerData);
    
    expect(result.success).toBe(true);
    expect(result.answer.answer).toBe(answerData.answer);
  });
});

// 灵魂契合度计算测试
describe('Soul Compatibility', () => {
  test('should calculate compatibility based on answers', () => {
    const user1Answers = [
      { question_id: 'q1', answer: '我喜欢安静的环境' },
      { question_id: 'q2', answer: '我重视家庭关系' }
    ];
    
    const user2Answers = [
      { question_id: 'q1', answer: '我也喜欢安静的地方' },
      { question_id: 'q2', answer: '家庭对我来说很重要' }
    ];
    
    const compatibility = soulService.calculateCompatibility(user1Answers, user2Answers);
    
    expect(compatibility).toBeGreaterThan(70);
  });
});
```

### 2.2 前端单元测试

#### 2.2.1 React组件测试
```jsx
// 搭子邀约卡片组件测试
import { render, screen, fireEvent } from '@testing-library/react';
import PostCard from './PostCard';

describe('PostCard Component', () => {
  const mockPost = {
    id: 'post_123',
    title: '周末一起去看展览',
    content: '想找个人一起去看艺术展',
    category: 'culture',
    location: {
      name: '798艺术区'
    },
    activity_time: '2024-03-16T14:00:00Z',
    max_participants: 2,
    current_participants: 0,
    user: {
      nickname: '小明',
      avatar: 'https://example.com/avatar.jpg'
    }
  };
  
  test('should render post information correctly', () => {
    render(<PostCard post={mockPost} onApply={jest.fn()} />);
    
    expect(screen.getByText('周末一起去看展览')).toBeInTheDocument();
    expect(screen.getByText('798艺术区')).toBeInTheDocument();
    expect(screen.getByText('小明')).toBeInTheDocument();
  });
  
  test('should call onApply when apply button is clicked', () => {
    const mockOnApply = jest.fn();
    render(<PostCard post={mockPost} onApply={mockOnApply} />);
    
    const applyButton = screen.getByTestId('apply-button');
    fireEvent.click(applyButton);
    
    expect(mockOnApply).toHaveBeenCalledWith(mockPost.id);
  });
});

// 灵魂问题组件测试
describe('SoulQuestion Component', () => {
  test('should submit answer on form submission', async () => {
    const mockQuestion = {
      id: 'soul_q_001',
      question: '如果可以回到过去，你最想对年轻的自己说什么？',
      category: 'reflection'
    };
    
    const mockOnSubmit = jest.fn();
    render(<SoulQuestion question={mockQuestion} onSubmit={mockOnSubmit} />);
    
    const textarea = screen.getByPlaceholderText('写下你的回答...');
    const submitButton = screen.getByTestId('submit-button');
    
    fireEvent.change(textarea, { target: { value: '要勇敢地去尝试' } });
    fireEvent.click(submitButton);
    
    expect(mockOnSubmit).toHaveBeenCalledWith({
      question_id: mockQuestion.id,
      answer: '要勇敢地去尝试',
      is_public: true
    });
  });
});
```

## 3. 集成测试计划

### 3.1 API集成测试

#### 3.1.1 用户管理API测试
```javascript
describe('User Management API Integration', () => {
  test('complete user registration flow', async () => {
    // 1. 发送验证码
    const smsResponse = await request(app)
      .post('/api/v1/auth/sms/send')
      .send({ phone: '13800138000', type: 'register' })
      .expect(200);
    
    // 2. 用户注册
    const registerResponse = await request(app)
      .post('/api/v1/auth/register/phone')
      .send({
        phone: '13800138000',
        code: '123456', // 测试环境固定验证码
        password: 'password123',
        nickname: '集成测试用户'
      })
      .expect(201);
    
    expect(registerResponse.body.data.user).toBeDefined();
    expect(registerResponse.body.data.tokens.access_token).toBeDefined();
    
    // 3. 获取用户信息
    const userResponse = await request(app)
      .get('/api/v1/users/me')
      .set('Authorization', `Bearer ${registerResponse.body.data.tokens.access_token}`)
      .expect(200);
    
    expect(userResponse.body.data.nickname).toBe('集成测试用户');
  });
});
```

#### 3.1.2 搭子邀约API测试
```javascript
describe('Posts API Integration', () => {
  test('complete post creation and application flow', async () => {
    const userToken = await getTestUserToken();
    const applicantToken = await getTestUserToken('applicant');
    
    // 1. 创建搭子邀约
    const postResponse = await request(app)
      .post('/api/v1/posts')
      .set('Authorization', `Bearer ${userToken}`)
      .send({
        title: '周末摄影外拍',
        content: '寻找摄影爱好者一起外拍',
        category: 'photography',
        location: {
          name: '朝阳公园',
          latitude: 39.9388,
          longitude: 116.4644
        },
        activity_time: '2024-03-16T14:00:00Z',
        max_participants: 3
      })
      .expect(201);
    
    const postId = postResponse.body.data.id;
    
    // 2. 申请加入搭子
    const applicationResponse = await request(app)
      .post(`/api/v1/posts/${postId}/join`)
      .set('Authorization', `Bearer ${applicantToken}`)
      .send({
        message: '我也喜欢摄影，想一起去'
      })
      .expect(201);
    
    expect(applicationResponse.body.data.status).toBe('pending');
    
    // 3. 查看搭子申请列表
    const applicationsResponse = await request(app)
      .get(`/api/v1/posts/${postId}/applications`)
      .set('Authorization', `Bearer ${userToken}`)
      .expect(200);
    
    expect(applicationsResponse.body.data.length).toBe(1);
  });
});
```

#### 3.1.3 灵魂回响API测试
```javascript
describe('Soul API Integration', () => {
  test('complete soul question and answer flow', async () => {
    const userToken = await getTestUserToken();
    
    // 1. 获取每日问题
    const questionResponse = await request(app)
      .get('/api/v1/soul/daily-question')
      .set('Authorization', `Bearer ${userToken}`)
      .expect(200);
    
    const question = questionResponse.body.data;
    
    // 2. 提交回答
    const answerResponse = await request(app)
      .post('/api/v1/soul/answers')
      .set('Authorization', `Bearer ${userToken}`)
      .send({
        question_id: question.id,
        answer: '我想告诉年轻的自己要勇敢',
        is_public: true
      })
      .expect(201);
    
    // 3. 查看公开回答
    const answersResponse = await request(app)
      .get('/api/v1/soul/answers')
      .set('Authorization', `Bearer ${userToken}`)
      .query({ question_id: question.id })
      .expect(200);
    
    expect(answersResponse.body.data.length).toBeGreaterThan(0);
  });
});
```

## 4. 系统测试计划

### 4.1 功能测试

#### 4.1.1 用户注册登录测试用例
```
测试用例ID: TC_001
测试标题: 用户手机号注册
前置条件: 应用已启动，网络连接正常
测试步骤:
1. 打开注册页面
2. 输入有效手机号 "13800138000"
3. 点击"获取验证码"按钮
4. 输入收到的验证码
5. 设置密码 "password123"
6. 输入昵称 "测试用户"
7. 点击"注册"按钮
预期结果: 
- 注册成功，跳转到主页面
- 显示用户昵称
- 自动登录状态

测试用例ID: TC_002
测试标题: 搭子邀约发布
前置条件: 用户已登录
测试步骤:
1. 进入发布页面
2. 输入标题"周末一起去看展览"
3. 输入内容描述
4. 选择分类"文化艺术"
5. 设置时间和地点
6. 设置参与人数限制
7. 点击发布
预期结果:
- 邀约发布成功
- 显示在邀约列表中
- 状态为"开放中"
```

#### 4.1.2 灵魂回响功能测试用例
```
测试用例ID: TC_101
测试标题: 每日灵魂问题回答
前置条件: 用户已登录
测试步骤:
1. 进入灵魂回响页面
2. 查看当日问题
3. 在回答框输入内容
4. 选择公开/私密设置
5. 点击提交回答
预期结果:
- 回答提交成功
- 显示提交成功提示
- 可以查看自己的回答

测试用例ID: TC_102
测试标题: 查看他人灵魂回答
前置条件: 已有用户回答了问题
测试步骤:
1. 进入灵魂回响页面
2. 点击"查看其他回答"
3. 浏览其他用户的回答
4. 为喜欢的回答点赞
预期结果:
- 能看到其他用户的公开回答
- 点赞功能正常
- 回答按时间或热度排序
```

### 4.2 性能测试

#### 4.2.1 负载测试计划
```
测试目标: 验证系统在预期负载下的性能表现

测试场景1: 用户登录负载测试
- 并发用户数: 500
- 持续时间: 30分钟
- 成功率要求: >99%
- 响应时间要求: <2秒

测试场景2: 搭子邀约浏览负载测试
- 并发用户数: 300
- 每分钟请求数: 5000
- 持续时间: 45分钟
- 响应时间要求: <3秒

测试场景3: 聊天系统负载测试
- 并发连接数: 1000
- 消息发送频率: 每秒500条
- 持续时间: 30分钟
- 消息延迟要求: <1秒
```

#### 4.2.2 性能测试脚本示例
```javascript
// K6性能测试脚本
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 100 },
    { duration: '5m', target: 300 },
    { duration: '2m', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'],
    http_req_failed: ['rate<0.01'],
  },
};

export default function() {
  // 用户登录
  let loginResponse = http.post('https://api.tongpin.com/api/v1/auth/login', {
    phone: '13800138000',
    password: 'password123'
  });
  
  check(loginResponse, {
    'login status is 200': (r) => r.status === 200,
    'login response time < 2s': (r) => r.timings.duration < 2000,
  });
  
  let token = loginResponse.json('data.tokens.access_token');
  
  // 获取搭子邀约列表
  let postsResponse = http.get('https://api.tongpin.com/api/v1/posts', {
    headers: { 'Authorization': `Bearer ${token}` },
  });
  
  check(postsResponse, {
    'posts status is 200': (r) => r.status === 200,
    'posts response time < 3s': (r) => r.timings.duration < 3000,
  });
  
  sleep(1);
}
```

### 4.3 安全测试

#### 4.3.1 认证授权测试
```
测试内容: JWT Token安全性

测试用例SA_001: Token篡改测试
步骤:
1. 获取有效Token
2. 修改Token中的用户ID
3. 使用篡改的Token访问API
预期结果: 返回401未授权错误

测试用例SA_002: 无Token访问测试
步骤:
1. 不携带Token访问需要认证的API
2. 检查服务器响应
预期结果: 返回401未认证错误
```

#### 4.3.2 数据安全测试
```
测试内容: SQL注入防护

测试用例SA_101: 登录SQL注入测试
步骤:
1. 在手机号字段输入: "'; DROP TABLE users; --"
2. 提交登录请求
3. 检查数据库状态
预期结果: 登录失败，数据库无变化

测试内容: XSS攻击防护

测试用例SA_201: 存储型XSS测试
步骤:
1. 在个人介绍中输入: "<script>alert('XSS')</script>"
2. 保存并查看资料
3. 其他用户查看该资料
预期结果: 脚本不执行，内容被转义显示
```

## 5. 自动化测试策略

### 5.1 CI/CD集成测试

#### 5.1.1 GitHub Actions配置
```yaml
name: Automated Testing Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run unit tests
      run: npm run test:unit
    
    - name: Upload coverage reports
      uses: codecov/codecov-action@v3
  
  integration-tests:
    runs-on: ubuntu-latest
    needs: unit-tests
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: tongpin_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Run integration tests
      run: npm run test:integration
```

### 5.2 测试覆盖率要求

```
代码覆盖率目标:
- 单元测试覆盖率: >75%
- 集成测试覆盖率: >60%
- 关键业务逻辑覆盖率: >90%

质量门禁:
- 所有测试必须通过
- 代码覆盖率不能下降
- 静态代码分析无严重问题
```

## 6. 测试执行与报告

### 6.1 测试执行计划

#### 6.1.1 测试阶段安排
```
第一阶段 - 单元测试 (Week 1-2):
- 后端服务单元测试
- 前端组件单元测试
- 测试覆盖率达到75%以上

第二阶段 - 集成测试 (Week 3-4):
- API集成测试
- 数据库集成测试
- 第三方服务集成测试

第三阶段 - 系统测试 (Week 5-6):
- 功能测试
- 性能测试
- 安全测试

第四阶段 - 用户验收测试 (Week 7):
- 内部UAT测试
- Beta用户测试
- 用户体验测试
```

### 6.2 缺陷管理

#### 6.2.1 缺陷分级标准
```
P0 - 阻断性缺陷:
- 系统崩溃或无法启动
- 核心功能完全不可用
- 数据丢失或严重安全漏洞
- 处理时间: 2小时内修复

P1 - 严重缺陷:
- 主要功能异常
- 影响用户体验的性能问题
- 重要页面无法访问
- 处理时间: 24小时内修复

P2 - 一般缺陷:
- 次要功能异常
- 界面显示问题
- 非关键流程错误
- 处理时间: 72小时内修复
```

### 6.3 测试报告

#### 6.3.1 测试总结报告模板
```
系统测试阶段总结报告

测试概述:
- 测试周期: 2024/03/01 - 2024/03/15
- 测试范围: 全功能系统测试
- 测试环境: 测试环境 + 预生产环境
- 参与人员: 6人

测试执行统计:
- 计划用例总数: 456个
- 实际执行用例: 445个
- 用例执行率: 97.6%
- 用例通过率: 93.8%

缺陷统计:
- 缺陷总数: 42个
- P0缺陷: 1个 (已修复)
- P1缺陷: 8个 (已修复7个)
- P2缺陷: 18个 (已修复12个)
- P3缺陷: 15个 (已修复5个)

质量评估:
- 功能完整性: 94%
- 性能达标率: 88%
- 安全问题: 无高危漏洞
- 用户体验: 满意度4.1/5.0

发布建议:
- 建议发布: 核心功能稳定，性能满足要求
- 遗留风险: 11个P2/P3缺陷，不影响主要功能
- 后续计划: 下个版本优化用户体验细节
```

---

**测试计划总结**：本测试计划文档提供了同频搭子应用的全面测试策略，覆盖了从单元测试到用户验收测试的完整测试体系。通过系统化的测试方法、自动化测试流程和严格的质量标准，确保产品在功能性、性能、安全性等各方面都能达到高质量标准。