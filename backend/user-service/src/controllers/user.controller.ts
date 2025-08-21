import { Request, Response } from 'express';
import { validationResult } from 'express-validator';

// Get user profile
export const getProfile = async (req: Request, res: Response): Promise<void> => {
  try {
    // User should be attached by auth middleware
    const userId = (req as any).user?.id;

    if (!userId) {
      res.status(401).json({ error: 'User not authenticated' });
      return;
    }

    // TODO: Implement database query to get user profile
    const user = {
      id: userId,
      phone: '***',
      nickname: 'User',
      bio: '',
      age: null,
      city: '',
      avatar: null,
      createdAt: new Date()
    };

    res.json({
      success: true,
      data: user
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Update user profile
export const updateProfile = async (req: Request, res: Response): Promise<void> => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      res.status(400).json({ errors: errors.array() });
      return;
    }

    const userId = (req as any).user?.id;
    if (!userId) {
      res.status(401).json({ error: 'User not authenticated' });
      return;
    }

    const { nickname, bio, age, city } = req.body;

    // TODO: Implement database update
    const updatedUser = {
      id: userId,
      nickname: nickname || 'User',
      bio: bio || '',
      age: age || null,
      city: city || '',
      updatedAt: new Date()
    };

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: updatedUser
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Upload user avatar
export const uploadAvatar = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = (req as any).user?.id;
    if (!userId) {
      res.status(401).json({ error: 'User not authenticated' });
      return;
    }

    // TODO: Implement file upload logic
    const avatarUrl = 'https://example.com/avatar.jpg';

    res.json({
      success: true,
      message: 'Avatar uploaded successfully',
      data: { avatar: avatarUrl }
    });
  } catch (error) {
    console.error('Upload avatar error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Get user by ID
export const getUserById = async (req: Request, res: Response): Promise<void> => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      res.status(400).json({ errors: errors.array() });
      return;
    }

    const { id } = req.params;

    // TODO: Implement database query
    const user = {
      id: id,
      phone: '***',
      nickname: 'User',
      bio: '',
      age: null,
      city: '',
      avatar: null,
      createdAt: new Date()
    };

    res.json({
      success: true,
      data: user
    });
  } catch (error) {
    console.error('Get user by ID error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Search users
export const searchUsers = async (req: Request, res: Response): Promise<void> => {
  try {
    const { q, limit = 10, offset = 0 } = req.query;

    if (!q) {
      res.status(400).json({ error: 'Search query is required' });
      return;
    }

    // TODO: Implement user search logic
    const users = [
      {
        id: '1',
        nickname: 'Test User',
        bio: 'Test bio',
        city: 'Test City'
      }
    ];

    res.json({
      success: true,
      data: {
        users,
        total: users.length,
        limit: Number(limit),
        offset: Number(offset)
      }
    });
  } catch (error) {
    console.error('Search users error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};