import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { pgPool, redisClient, logger } from '../config/database';

interface RegisterRequest {
  phone: string;
  password: string;
  nickname: string;
}

interface LoginRequest {
  phone: string;
  password: string;
}

export const register = async (req: Request, res: Response): Promise<void> => {
  try {
    const { phone, password, nickname }: RegisterRequest = req.body;

    // Check if user already exists
    const existingUser = await pgPool.query(
      'SELECT id FROM users WHERE phone = $1',
      [phone]
    );

    if (existingUser.rows.length > 0) {
      res.status(400).json({
        success: false,
        error: { message: 'Phone number already registered' }
      });
      return;
    }

    // Hash password
    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Create user
    const userId = uuidv4();
    const result = await pgPool.query(
      'INSERT INTO users (id, phone, password_hash, nickname, status) VALUES ($1, $2, $3, $4, $5) RETURNING id, phone, nickname',
      [userId, phone, hashedPassword, nickname, 'active']
    );

    const user = result.rows[0];

    // Generate JWT token
    const token = jwt.sign(
      {
        sub: user.id,
        phone: user.phone,
        scope: ['user']
      },
      process.env.JWT_SECRET!,
      { expiresIn: '7d' }
    );

    logger.info('User registered successfully', { userId: user.id, phone: user.phone });

    res.status(201).json({
      success: true,
      data: {
        user,
        token,
        message: 'Registration successful'
      }
    });

  } catch (error) {
    logger.error('Registration error:', error);
    res.status(500).json({
      success: false,
      error: { message: 'Registration failed' }
    });
  }
};

export const login = async (req: Request, res: Response): Promise<void> => {
  try {
    const { phone, password }: LoginRequest = req.body;

    // Find user
    const result = await pgPool.query(
      'SELECT id, phone, password_hash, nickname, status FROM users WHERE phone = $1',
      [phone]
    );

    if (result.rows.length === 0) {
      res.status(401).json({
        success: false,
        error: { message: 'Invalid phone or password' }
      });
      return;
    }

    const user = result.rows[0];

    // Check password
    const isValidPassword = await bcrypt.compare(password, user.password_hash);
    if (!isValidPassword) {
      res.status(401).json({
        success: false,
        error: { message: 'Invalid phone or password' }
      });
      return;
    }

    // Generate JWT token
    const token = jwt.sign(
      {
        sub: user.id,
        phone: user.phone,
        scope: ['user']
      },
      process.env.JWT_SECRET!,
      { expiresIn: '7d' }
    );

    // Store session in Redis
    await redisClient.setEx(`session:${user.id}`, 604800, token); // 7 days

    logger.info('User logged in successfully', { userId: user.id, phone: user.phone });

    res.json({
      success: true,
      data: {
        user: {
          id: user.id,
          phone: user.phone,
          nickname: user.nickname
        },
        token,
        message: 'Login successful'
      }
    });

  } catch (error) {
    logger.error('Login error:', error);
    res.status(500).json({
      success: false,
      error: { message: 'Login failed' }
    });
  }
};

export const refreshToken = async (req: Request, res: Response): Promise<void> => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      res.status(400).json({
        success: false,
        error: { message: 'Refresh token required' }
      });
      return;
    }

    // Verify refresh token and generate new access token
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET!) as any;

    const newToken = jwt.sign(
      {
        sub: decoded.sub,
        phone: decoded.phone,
        scope: decoded.scope
      },
      process.env.JWT_SECRET!,
      { expiresIn: '7d' }
    );

    res.json({
      success: true,
      data: { token: newToken }
    });

  } catch (error) {
    logger.error('Token refresh error:', error);
    res.status(401).json({
      success: false,
      error: { message: 'Invalid refresh token' }
    });
  }
};

export const logout = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = req.user?.userId;

    if (userId) {
      await redisClient.del(`session:${userId}`);
      logger.info('User logged out', { userId });
    }

    res.json({
      success: true,
      data: { message: 'Logout successful' }
    });

  } catch (error) {
    logger.error('Logout error:', error);
    res.status(500).json({
      success: false,
      error: { message: 'Logout failed' }
    });
  }
};