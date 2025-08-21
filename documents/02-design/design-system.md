# 同频搭子 - 设计系统规范文档

## 📖 文档概述

本文档定义了"同频搭子"应用的完整设计系统，包括视觉风格、组件规范、交互模式等，确保产品在所有页面和功能中保持一致的用户体验。

---

## 🎨 1. 视觉风格指南

### 1.1 设计理念

**核心价值观**：
- **温暖连接**：营造温暖、友好的社交氛围
- **现代简洁**：采用当代扁平化设计语言
- **情感共鸣**：通过设计传达"同频"的概念
- **易用性优先**：降低用户操作成本，提升体验流畅度

**设计关键词**：
- 温暖 (Warm)
- 现代 (Modern) 
- 简洁 (Clean)
- 友好 (Friendly)
- 可信赖 (Trustworthy)

### 1.2 色彩系统

#### 主色调 (Primary Colors)
```css
:root {
    /* 主品牌色 - 温暖珊瑚粉 */
    --primary-color: #FF6B6B;          /* 主要操作、强调元素 */
    --primary-hover: #FF5252;          /* 悬停状态 */
    --primary-light: rgba(255, 107, 107, 0.1);  /* 浅色背景 */
    
    /* 辅助色 - 清新薄荷绿 */
    --secondary-color: #4ECDC4;        /* 分类标签、辅助信息 */
    --secondary-hover: #45B7B8;        /* 悬停状态 */
}
```

#### 中性色 (Neutral Colors)
```css
:root {
    /* 背景色系 */
    --background: #FAFAFA;             /* 页面背景 */
    --surface: #FFFFFF;               /* 卡片、表单背景 */
    
    /* 文字色系 */
    --text-primary: #212121;          /* 主要文字 */
    --text-secondary: #757575;        /* 次要文字 */
    --text-hint: #BDBDBD;            /* 提示文字、占位符 */
    
    /* 边框色系 */
    --border-color: #E0E0E0;          /* 分割线、边框 */
    --border-light: #F5F5F5;         /* 浅色边框 */
}
```

#### 功能色 (Functional Colors)
```css
:root {
    /* 状态色 */
    --success-color: #4CAF50;         /* 成功状态 */
    --warning-color: #FF9800;         /* 警告状态 */
    --error-color: #F44336;           /* 错误状态 */
    --info-color: #2196F3;            /* 信息状态 */
}
```

#### 色彩使用原则
- **主色调**：用于主要操作按钮、品牌元素、重要状态指示
- **辅助色**：用于分类标签、二级操作、装饰元素
- **中性色**：用于文字、背景、边框等基础元素
- **功能色**：仅用于特定的状态反馈，不可滥用

### 1.3 字体系统

#### 字体族
```css
font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Noto Sans SC', sans-serif;
```

#### 字重规范
```css
/* 字重层级 */
--font-weight-light: 300;      /* 装饰性文字 */
--font-weight-regular: 400;    /* 正文 */
--font-weight-medium: 500;     /* 次级标题 */
--font-weight-semibold: 600;   /* 重要信息 */
--font-weight-bold: 700;       /* 主标题 */
```

#### 字号层级
```css
/* 标题层级 */
--font-size-h1: 28px;          /* 页面主标题 */
--font-size-h2: 24px;          /* 区块标题 */
--font-size-h3: 20px;          /* 子标题 */
--font-size-h4: 18px;          /* 小标题 */

/* 正文层级 */
--font-size-body1: 16px;       /* 主要正文 */
--font-size-body2: 14px;       /* 次要正文 */
--font-size-caption: 12px;     /* 说明文字 */
--font-size-overline: 11px;    /* 标签文字 */
```

#### 行高规范
```css
/* 行高比例 */
--line-height-tight: 1.2;      /* 标题 */
--line-height-normal: 1.5;     /* 正文 */
--line-height-loose: 1.6;      /* 长文本 */
```

---

## 🧩 2. 组件设计规范

### 2.1 按钮系统

#### 主要按钮 (Primary Button)
```css
.btn-primary {
    background: var(--primary-color);
    color: white;
    border: none;
    border-radius: 12px;
    padding: 16px 24px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s ease;
}

.btn-primary:hover {
    background: var(--primary-hover);
    transform: translateY(-1px);
}

.btn-primary:disabled {
    background: var(--text-hint);
    cursor: not-allowed;
    transform: none;
}
```

#### 次要按钮 (Secondary Button)
```css
.btn-secondary {
    background: transparent;
    color: var(--primary-color);
    border: 1px solid var(--primary-color);
    border-radius: 12px;
    padding: 16px 24px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s ease;
}

.btn-secondary:hover {
    background: var(--primary-color);
    color: white;
}
```

#### 按钮尺寸规范
```css
/* 大按钮 - 主要操作 */
.btn-large { padding: 18px 32px; font-size: 18px; }

/* 标准按钮 - 常规操作 */
.btn-normal { padding: 16px 24px; font-size: 16px; }

/* 小按钮 - 次要操作 */
.btn-small { padding: 12px 20px; font-size: 14px; }

/* 迷你按钮 - 辅助操作 */
.btn-mini { padding: 8px 16px; font-size: 12px; }
```

### 2.2 卡片系统

#### 基础卡片
```css
.card {
    background: var(--surface);
    border-radius: 12px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.12), 0 1px 2px rgba(0, 0, 0, 0.24);
    padding: 16px;
    transition: all 0.2s ease;
}

.card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}
```

#### 搭子邀约卡片
```css
.post-card {
    background: var(--surface);
    border-radius: 12px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.12);
    margin-bottom: 16px;
    overflow: hidden;
    cursor: pointer;
}

.post-card .header {
    padding: 16px 16px 12px;
    display: flex;
    align-items: center;
}

.post-card .content {
    padding: 0 16px 12px;
}

.post-card .footer {
    padding: 12px 16px;
    background: var(--background);
    border-top: 1px solid var(--border-color);
}
```

### 2.3 表单组件

#### 输入框
```css
.form-input {
    width: 100%;
    padding: 16px;
    border: 1px solid var(--border-color);
    border-radius: 12px;
    font-size: 16px;
    background: var(--surface);
    transition: all 0.2s ease;
}

.form-input:focus {
    outline: none;
    border-color: var(--primary-color);
    box-shadow: 0 0 0 3px rgba(255, 107, 107, 0.1);
}

.form-input::placeholder {
    color: var(--text-hint);
}

.form-input.error {
    border-color: var(--error-color);
}
```

#### 标签
```css
.form-label {
    display: block;
    font-size: 14px;
    font-weight: 600;
    margin-bottom: 8px;
    color: var(--text-primary);
}
```

### 2.4 导航组件

#### 底部导航栏
```css
.bottom-nav {
    background: var(--surface);
    border-top: 1px solid var(--border-color);
    padding: 12px 0 8px;
    display: flex;
    justify-content: space-around;
}

.nav-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    cursor: pointer;
    padding: 4px 12px;
    transition: all 0.2s ease;
}

.nav-icon {
    font-size: 22px;
    margin-bottom: 4px;
    color: var(--text-hint);
}

.nav-label {
    font-size: 11px;
    color: var(--text-hint);
    font-weight: 500;
}

.nav-item.active .nav-icon,
.nav-item.active .nav-label {
    color: var(--primary-color);
}
```

---

## 📐 3. 布局规范

### 3.1 网格系统

#### 移动端规范
```css
/* 标准移动端画布 */
.mobile-frame {
    width: 375px;
    height: 812px;
    background: var(--surface);
    border-radius: 24px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
}

/* 内容区域边距 */
.container {
    padding: 0 20px;
}

/* 区块间距 */
.section {
    margin-bottom: 24px;
}
```

#### 间距系统
```css
/* 间距规范 */
--spacing-xs: 4px;      /* 微小间距 */
--spacing-sm: 8px;      /* 小间距 */
--spacing-md: 12px;     /* 中等间距 */
--spacing-lg: 16px;     /* 大间距 */
--spacing-xl: 24px;     /* 超大间距 */
--spacing-xxl: 32px;    /* 巨大间距 */
```

### 3.2 圆角规范
```css
/* 圆角层级 */
--border-radius-sm: 8px;    /* 小圆角 - 标签、小按钮 */
--border-radius-md: 12px;   /* 标准圆角 - 按钮、卡片 */
--border-radius-lg: 16px;   /* 大圆角 - 大卡片 */
--border-radius-xl: 20px;   /* 超大圆角 - 特殊容器 */
--border-radius-full: 50%;  /* 圆形 - 头像、图标按钮 */
```

### 3.3 阴影系统
```css
/* 阴影层级 */
--shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.1);                    /* 微阴影 */
--shadow-md: 0 1px 3px rgba(0, 0, 0, 0.12), 0 1px 2px rgba(0, 0, 0, 0.24);  /* 标准阴影 */
--shadow-lg: 0 4px 12px rgba(0, 0, 0, 0.15);                  /* 大阴影 */
--shadow-xl: 0 8px 32px rgba(0, 0, 0, 0.12);                  /* 超大阴影 */
```

---

## 🎭 4. 交互设计规范

### 4.1 动画效果

#### 基础过渡
```css
/* 标准过渡时间 */
--transition-fast: 0.15s ease;      /* 快速反馈 */
--transition-normal: 0.2s ease;     /* 标准过渡 */
--transition-slow: 0.3s ease;       /* 慢速过渡 */

/* 常用动画 */
.fade-in {
    animation: fadeIn 0.4s ease-out;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
}

.slide-in {
    animation: slideIn 0.3s ease-out;
}

@keyframes slideIn {
    from { transform: translateX(100%); }
    to { transform: translateX(0); }
}
```

#### 悬停效果
```css
/* 悬停提升效果 */
.hover-lift {
    transition: transform 0.2s ease;
}

.hover-lift:hover {
    transform: translateY(-2px);
}

/* 按钮悬停效果 */
.btn:hover {
    transform: translateY(-1px);
    box-shadow: var(--shadow-lg);
}
```

### 4.2 加载状态

#### 骨架屏
```css
.skeleton {
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: loading 1.5s infinite;
}

@keyframes loading {
    0% { background-position: 200% 0; }
    100% { background-position: -200% 0; }
}
```

#### 加载指示器
```css
.spinner {
    width: 24px;
    height: 24px;
    border: 2px solid var(--border-color);
    border-top: 2px solid var(--primary-color);
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}
```

### 4.3 反馈机制

#### 状态指示
```css
/* 在线状态 */
.status-online { color: var(--success-color); }
.status-offline { color: var(--text-hint); }
.status-busy { color: var(--warning-color); }

/* 热门标识 */
.status-hot {
    color: var(--warning-color);
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.7; }
}
```

---

## 📱 5. 页面布局模板

### 5.1 标准页面结构
```html
<div class="mobile-frame">
    <!-- 页面头部 -->
    <header class="header">
        <div class="header-left">
            <button class="back-btn">←</button>
            <span class="header-title">页面标题</span>
        </div>
        <div class="header-actions">
            <button class="header-btn">🔍</button>
        </div>
    </header>
    
    <!-- 主要内容 -->
    <main class="main-content">
        <!-- 内容区域 -->
    </main>
    
    <!-- 底部导航 -->
    <nav class="bottom-nav">
        <!-- 导航项 -->
    </nav>
</div>
```

### 5.2 表单页面模板
```html
<div class="page">
    <header class="header">
        <div class="header-left">
            <button class="back-btn">←</button>
            <span class="header-title">表单标题</span>
        </div>
    </header>
    
    <div class="form-section">
        <div class="form-group">
            <label class="form-label">字段标签</label>
            <input type="text" class="form-input" placeholder="占位符文字">
        </div>
        <!-- 更多表单字段 -->
    </div>
    
    <div class="form-actions">
        <button class="btn btn-primary">主要操作</button>
    </div>
</div>
```

---

## 🎯 6. 图标系统

### 6.1 图标风格
- **风格**：使用Emoji作为主要图标系统，保证跨平台一致性
- **备选**：Material Icons 或 Feather Icons
- **尺寸**：16px, 20px, 24px, 32px

### 6.2 常用图标
```
导航图标：
🏠 首页    💫 灵魂    💬 聊天    👤 个人

功能图标：
🔍 搜索    📍 位置    ⏰ 时间    👥 人员
❤️ 喜欢    📤 分享    🔔 通知    ⚙️ 设置

状态图标：
✅ 成功    ⚠️ 警告    ❌ 错误    ℹ️ 信息
🔥 热门    ⭐ 推荐    🆕 新内容

分类图标：
🏃‍♂️ 运动    🍔 美食    🎨 文化    ✈️ 旅行
🎬 娱乐    📚 学习    🎵 音乐    📷 摄影
```

---

## 🔧 7. 响应式设计

### 7.1 断点系统
```css
/* 移动端优先 */
@media (min-width: 576px) { /* 大屏手机 */ }
@media (min-width: 768px) { /* 平板 */ }
@media (min-width: 992px) { /* 桌面 */ }
```

### 7.2 适配原则
- **移动端优先**：以375px为基准设计
- **触摸友好**：最小点击区域44px×44px
- **内容优先**：确保核心内容在任何尺寸下都清晰可见

---

## ✅ 8. 可访问性规范

### 8.1 对比度要求
- **正文与背景**：对比度 ≥ 4.5:1
- **大文本与背景**：对比度 ≥ 3:1
- **界面元素**：对比度 ≥ 3:1

### 8.2 交互规范
- **焦点指示**：所有可交互元素都有清晰的焦点状态
- **替代文本**：所有图像都有有意义的alt属性
- **键盘导航**：支持Tab键导航

---

## 📝 9. 设计规范使用指南

### 9.1 设计流程
1. **确定页面类型**：参考页面布局模板
2. **选择组件**：从组件库中选择合适的组件
3. **应用样式**：使用CSS变量确保一致性
4. **添加交互**：根据交互规范添加动效
5. **测试验证**：检查对比度和可访问性

### 9.2 代码规范
```css
/* 使用CSS变量 */
.my-component {
    color: var(--text-primary);
    background: var(--surface);
    border-radius: var(--border-radius-md);
    padding: var(--spacing-lg);
    transition: var(--transition-normal);
}

/* 避免硬编码 */
.bad-example {
    color: #212121;           /* ❌ 硬编码颜色 */
    border-radius: 12px;      /* ❌ 硬编码数值 */
}

.good-example {
    color: var(--text-primary);          /* ✅ 使用变量 */
    border-radius: var(--border-radius-md);  /* ✅ 使用变量 */
}
```

### 9.3 设计交付
- **设计稿**：包含完整的状态设计（默认、悬停、禁用等）
- **切图资源**：提供@1x、@2x、@3x三套图片资源
- **动效说明**：详细描述动画效果和时长
- **边界情况**：考虑空状态、错误状态、加载状态

---

## 🎨 10. 设计系统维护

### 10.1 版本管理
- **主版本**：重大设计语言变更
- **次版本**：新增组件或重要更新
- **修订版本**：bug修复和微调

### 10.2 更新流程
1. **需求评估**：评估设计变更的必要性
2. **影响分析**：分析对现有页面的影响
3. **设计更新**：更新设计系统文档
4. **组件升级**：更新相关组件和页面
5. **测试验证**：确保更改不影响用户体验

---

## 📚 11. 参考资源

### 11.1 设计灵感
- **Material Design 3**：现代化设计语言参考
- **Human Interface Guidelines**：iOS设计规范
- **Airbnb Design System**：卡片式布局参考
- **Dribbble**：视觉设计灵感

### 11.2 开发资源
- **Inter字体**：https://fonts.google.com/specimen/Inter
- **CSS变量文档**：https://developer.mozilla.org/en-US/docs/Web/CSS/var
- **无障碍指南**：https://www.w3.org/WAI/WCAG21/quickref/

---

**设计系统文档版本**：v1.0  
**最后更新时间**：2024年3月  
**维护团队**：同频搭子设计团队

---

> 💡 **使用提示**：在开发新功能或页面时，请优先参考本设计系统文档，确保产品视觉和交互的一致性。如有疑问或需要添加新组件，请联系设计团队进行评估和更新。