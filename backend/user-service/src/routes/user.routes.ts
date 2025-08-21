import { Router } from 'express';
import { body, param } from 'express-validator';
import { authenticateToken } from '../middleware/auth.middleware';
import {
  getProfile,
  updateProfile,
  uploadAvatar,
  getUserById,
  searchUsers
} from '../controllers/user.controller';

const router = Router();

// Validation rules
const updateProfileValidation = [
  body('nickname').optional().trim().notEmpty().withMessage('Nickname cannot be empty'),
  body('bio').optional().trim().isLength({ max: 500 }).withMessage('Bio must be less than 500 characters'),
  body('age').optional().isInt({ min: 18, max: 100 }).withMessage('Age must be between 18 and 100'),
  body('city').optional().trim().notEmpty().withMessage('City cannot be empty')
];

const userIdValidation = [
  param('id').isUUID().withMessage('Invalid user ID format')
];

// Protected routes (require authentication)
router.use(authenticateToken);

router.get('/profile', getProfile);
router.put('/profile', updateProfileValidation, updateProfile);
router.post('/avatar', uploadAvatar);
router.get('/search', searchUsers);
router.get('/:id', userIdValidation, getUserById);

export default router;