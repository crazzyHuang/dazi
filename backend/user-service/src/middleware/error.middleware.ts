import { Request, Response, NextFunction } from 'express';
import { logger } from '../config/database';

export interface AppError extends Error {
  statusCode?: number;
  isOperational?: boolean;
}

export const errorHandler = (
   error: AppError,
   req: Request,
   res: Response,
   _next: NextFunction
 ): void => {
  let statusCode = error.statusCode || 500;
  let message = error.message || 'Internal Server Error';

  // Log error
  logger.error('Error occurred:', {
    message: error.message,
    stack: error.stack,
    statusCode,
    path: req.path,
    method: req.method,
    ip: req.ip,
    userAgent: req.get('User-Agent')
  });

  // Mongoose validation error
  if (error.name === 'ValidationError') {
    statusCode = 400;
    message = 'Validation Error';
  }

  // Mongoose duplicate key error
  if (error.name === 'MongoError' && (error as any).code === 11000) {
    statusCode = 400;
    message = 'Duplicate field value entered';
  }

  // JWT errors
  if (error.name === 'JsonWebTokenError') {
    statusCode = 401;
    message = 'Invalid token';
  }

  if (error.name === 'TokenExpiredError') {
    statusCode = 401;
    message = 'Token expired';
  }

  // Development vs production error response
  if (process.env.NODE_ENV === 'development') {
    res.status(statusCode).json({
      success: false,
      error: {
        message,
        stack: error.stack,
        statusCode
      }
    });
  } else {
    // Production: don't leak error details
    res.status(statusCode).json({
      success: false,
      error: {
        message: statusCode >= 500 ? 'Internal Server Error' : message,
        statusCode
      }
    });
  }
};

// 404 handler
export const notFound = (req: Request, _res: Response, next: NextFunction): void => {
  const error: AppError = new Error(`Not found - ${req.originalUrl}`);
  error.statusCode = 404;
  next(error);
};