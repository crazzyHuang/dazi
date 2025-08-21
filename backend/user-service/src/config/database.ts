import { Pool } from 'pg';
import { createClient } from 'redis';
import winston from 'winston';

// PostgreSQL connection pool
const pgPool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'tongpin_db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'password',
  max: 20, // Maximum number of clients in the pool
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Redis client
const redisClient: ReturnType<typeof createClient> = createClient({
  url: process.env.REDIS_URL || 'redis://localhost:6379'
});

redisClient.on('error', (err) => {
  console.error('Redis Client Error', err);
});

// Logger configuration
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'user-service' },
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ]
});

export const connectDatabase = async (): Promise<void> => {
  try {
    // Test PostgreSQL connection
    const client = await pgPool.connect();
    logger.info('✅ PostgreSQL connected successfully');
    client.release();

    // Connect to Redis
    await redisClient.connect();
    logger.info('✅ Redis connected successfully');

  } catch (error) {
    logger.warn('⚠️ Database connection failed, but continuing in development mode:', error);
    // Don't throw error in development to allow the server to start
    if (process.env.NODE_ENV === 'production') {
      throw error;
    }
  }
};

export const disconnectDatabase = async (): Promise<void> => {
  try {
    await pgPool.end();
    await redisClient.disconnect();
    logger.info('✅ Database connections closed');
  } catch (error) {
    logger.error('❌ Error closing database connections:', error);
    throw error;
  }
};

export { pgPool, redisClient, logger };