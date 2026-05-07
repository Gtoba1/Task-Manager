// routes/dm.js
const router = require('express').Router();
const { requireAuth } = require('../middleware/auth');
const { getConversation, getUnreadCounts } = require('../controllers/dmController');

router.use(requireAuth);

// IMPORTANT: /unread must be registered BEFORE /:userId so Express doesn't
// treat the word "unread" as a userId parameter.
router.get('/unread',  getUnreadCounts); // GET /api/dm/unread
router.get('/:userId', getConversation); // GET /api/dm/:userId

module.exports = router;
