-- 同频搭子数据库初始化脚本
-- 数据库: tongpin_db

-- 创建UUID扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    nickname VARCHAR(50) NOT NULL,
    avatar_url TEXT,
    bio TEXT,
    age INTEGER,
    gender VARCHAR(10),
    city VARCHAR(100),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'banned')),
    last_active_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建用户索引
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- 创建用户兴趣标签表
CREATE TABLE IF NOT EXISTS user_interests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    interest VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, interest)
);

-- 创建用户兴趣索引
CREATE INDEX IF NOT EXISTS idx_user_interests_user_id ON user_interests(user_id);
CREATE INDEX IF NOT EXISTS idx_user_interests_interest ON user_interests(interest);

-- 创建用户位置表（用于地理位置搜索）
CREATE TABLE IF NOT EXISTS user_locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    location_name VARCHAR(200),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- 创建地理位置索引
CREATE INDEX IF NOT EXISTS idx_user_locations_coords ON user_locations USING GIST (ST_Point(longitude, latitude));

-- 创建搭子邀约表
CREATE TABLE IF NOT EXISTS posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    category VARCHAR(50) NOT NULL,
    activity_type VARCHAR(50),
    location_name VARCHAR(200),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    activity_time TIMESTAMP WITH TIME ZONE,
    max_participants INTEGER DEFAULT 2,
    current_participants INTEGER DEFAULT 1,
    min_participants INTEGER DEFAULT 1,
    status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'closed', 'cancelled', 'completed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建搭子邀约索引
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_category ON posts(category);
CREATE INDEX IF NOT EXISTS idx_posts_status ON posts(status);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at);
CREATE INDEX IF NOT EXISTS idx_posts_activity_time ON posts(activity_time);
CREATE INDEX IF NOT EXISTS idx_posts_location ON posts USING GIST (ST_Point(longitude, latitude)) WHERE latitude IS NOT NULL;

-- 创建搭子参与表
CREATE TABLE IF NOT EXISTS post_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(post_id, user_id)
);

-- 创建参与者索引
CREATE INDEX IF NOT EXISTS idx_post_participants_post_id ON post_participants(post_id);
CREATE INDEX IF NOT EXISTS idx_post_participants_user_id ON post_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_post_participants_status ON post_participants(status);

-- 创建用户匹配历史表
CREATE TABLE IF NOT EXISTS user_matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user1_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user2_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    match_type VARCHAR(50) DEFAULT 'swipe',
    compatibility_score DECIMAL(3,2),
    matched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user1_id, user2_id)
);

-- 创建匹配历史索引
CREATE INDEX IF NOT EXISTS idx_user_matches_user1_id ON user_matches(user1_id);
CREATE INDEX IF NOT EXISTS idx_user_matches_user2_id ON user_matches(user2_id);
CREATE INDEX IF NOT EXISTS idx_user_matches_matched_at ON user_matches(matched_at);

-- 创建用户行为日志表（用于推荐算法）
CREATE TABLE IF NOT EXISTS user_behaviors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    action_type VARCHAR(50) NOT NULL, -- view, like, dislike, join, message
    target_type VARCHAR(50) NOT NULL, -- user, post
    target_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建行为日志索引
CREATE INDEX IF NOT EXISTS idx_user_behaviors_user_id ON user_behaviors(user_id);
CREATE INDEX IF NOT EXISTS idx_user_behaviors_action_type ON user_behaviors(action_type);
CREATE INDEX IF NOT EXISTS idx_user_behaviors_created_at ON user_behaviors(created_at);

-- 创建更新时间触发器
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 插入测试数据（可选）
-- INSERT INTO users (phone, password_hash, nickname, city) VALUES
-- ('13800138001', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqyPuN7TjK1IwLxE8wWZ1bS', '测试用户1', '北京'),
-- ('13800138002', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqyPuN7TjK1IwLxE8wWZ1bS', '测试用户2', '上海');

-- 插入兴趣标签数据
-- INSERT INTO user_interests (user_id, interest) SELECT id, '美食' FROM users WHERE phone = '13800138001';
-- INSERT INTO user_interests (user_id, interest) SELECT id, '摄影' FROM users WHERE phone = '13800138001';
-- INSERT INTO user_interests (user_id, interest) SELECT id, '运动' FROM users WHERE phone = '13800138002';

COMMENT ON TABLE users IS '用户基础信息表';
COMMENT ON TABLE posts IS '搭子邀约表';
COMMENT ON TABLE user_matches IS '用户匹配历史表';
COMMENT ON TABLE user_behaviors IS '用户行为日志表';

-- 完成初始化
SELECT 'Database initialization completed successfully!' as message;