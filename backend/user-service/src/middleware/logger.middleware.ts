import { Request, Response, NextFunction } from 'express';
import { logger } from '../config/database';

export const requestLogger = (req: Request, res: Response, next: NextFunction): void => {
  const start = Date.now();

  // Log request
  logger.info('Incoming request', {
    method: req.method,
    path: req.path,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    query: req.query,
    body: req.method !== 'GET' ? req.body : undefined
  });

  // Log response
  res.on('finish', () => {
    const duration = Date.now() - start;
    const statusCode = res.statusCode;
    const level = statusCode >= 400 ? 'warn' : 'info';

    logger.log(level, 'Request completed', {
      method: req.method,
      path: req.path,
      statusCode,
      duration: `${duration}ms`,
      contentLength: res.get('Content-Length'),
      ip: req.ip
    });
  });

  next();
};

// Request ID middleware
export const requestId = (req: Request, res: Response, next: NextFunction): void => {
  const requestId = req.get('X-Request-ID') || generateRequestId();
  req.id = requestId;
  res.set('X-Request-ID', requestId);

  logger.info('Request ID assigned', { requestId });
  next();
};

function generateRequestId(): string {
  return Date.now().toString(36) + Math.random().toString(36).substr(2);
}