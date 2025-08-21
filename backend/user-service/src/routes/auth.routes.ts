import { Router } from 'express';
import { body, validationResult } from 'express-validator';
import { register, login, refreshToken, logout } from '../controllers/auth.controller';

const router = Router();

// Validation rules
const registerValidation = [
  body('phone').isMobilePhone('any').withMessage('Please provide a valid phone number'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters long'),
  body('nickname').trim().notEmpty().withMessage('Nickname is required')
];

const loginValidation = [
  body('phone').isMobilePhone('any').withMessage('Please provide a valid phone number'),
  body('password').notEmpty().withMessage('Password is required')
];

// Routes
router.post('/register', registerValidation, register);
router.post('/login', loginValidation, login);
router.post('/refresh-token', refreshToken);
router.post('/logout', logout);

export default router;