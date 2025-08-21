import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { logger } from '../config/database';

// Extend Request interface to include user
declare global {
  namespace Express {
    interface Request {
      user?: any;
      id?: string;
    }
  }
}

export interface AuthRequest extends Request {
  user?: {
    userId: string;
    phone: string;
    scope: string[];
  };
}

export const authenticateToken = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    logger.warn('Access attempt without token', {
      ip: req.ip,
      path: req.path
    });
    res.status(401).json({
      success: false,
      error: { message: 'Access token required' }
    });
    return;
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as any;

    req.user = {
      userId: decoded.sub,
      phone: decoded.phone,
      scope: decoded.scope || []
    };

    logger.info('Token authenticated successfully', {
      userId: req.user.userId,
      path: req.path
    });

    next();
  } catch (error) {
    logger.warn('Token verification failed', {
      error: (error as Error).message,
      ip: req.ip,
      path: req.path
    });

    if ((error as Error).name === 'TokenExpiredError') {
      res.status(401).json({
        success: false,
        error: { message: 'Token expired' }
      });
    } else {
      res.status(403).json({
        success: false,
        error: { message: 'Invalid token' }
      });
    }
  }
};

// Optional authentication (doesn't fail if no token)
export const optionalAuth = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    next();
    return;
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as any;
    req.user = {
      userId: decoded.sub,
      phone: decoded.phone,
      scope: decoded.scope || []
    };
  } catch (error) {
    // Ignore auth errors for optional auth
    logger.debug('Optional auth failed', { error: (error as Error).message });
  }

  next();
};