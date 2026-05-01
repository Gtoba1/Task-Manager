// routes/auth.js
// Auth endpoints — login, current user, forgot password, reset password.

const router    = require('express').Router();
const rateLimit = require('express-rate-limit');
const { login, getMe, forgotPassword, resetPassword } = require('../controllers/authController');
const { requireAuth } = require('../middleware/auth');

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  message: { error: 'Too many login attempts. Please wait 15 minutes and try again.' },
  standardHeaders: true,
  legacyHeaders: false,
});

// POST /api/auth/login            — public
router.post('/login', loginLimiter, login);

// GET  /api/auth/me               — protected
router.get('/me', requireAuth, getMe);

// POST /api/auth/forgot-password  — public (user not logged in)
router.post('/forgot-password', forgotPassword);

// POST /api/auth/reset-password   — public (user not logged in, has token)
router.post('/reset-password', resetPassword);

module.exports = router;
