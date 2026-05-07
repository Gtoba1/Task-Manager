// controllers/dmController.js
const pool = require('../db/pool');

// GET /api/dm/:userId — fetch conversation with another user (last 50 messages)
// Also marks all unread messages from that user as read
async function getConversation(req, res) {
  const myId    = req.user.id;
  const otherId = parseInt(req.params.userId);
  if (!otherId || isNaN(otherId)) return res.status(400).json({ error: 'Invalid user ID.' });
  try {
    const result = await pool.query(
      `SELECT dm.id, dm.sender_id, dm.receiver_id, dm.content, dm.is_read, dm.created_at,
              u.name AS sender_name, u.initials AS sender_initials
       FROM direct_messages dm
       JOIN users u ON u.id = dm.sender_id
       WHERE (dm.sender_id = $1 AND dm.receiver_id = $2)
          OR (dm.sender_id = $2 AND dm.receiver_id = $1)
       ORDER BY dm.created_at ASC
       LIMIT 50`,
      [myId, otherId]
    );
    await pool.query(
      `UPDATE direct_messages SET is_read = TRUE
       WHERE receiver_id = $1 AND sender_id = $2 AND is_read = FALSE`,
      [myId, otherId]
    );
    res.json({ messages: result.rows });
  } catch (err) {
    console.error('getConversation error:', err.message);
    res.status(500).json({ error: 'Failed to load conversation.' });
  }
}

// GET /api/dm/unread — count of unread DMs per sender for the logged-in user
async function getUnreadCounts(req, res) {
  const myId = req.user.id;
  try {
    const result = await pool.query(
      `SELECT sender_id, COUNT(*) AS count
       FROM direct_messages
       WHERE receiver_id = $1 AND is_read = FALSE
       GROUP BY sender_id`,
      [myId]
    );
    const counts = {};
    for (const row of result.rows) counts[row.sender_id] = parseInt(row.count);
    res.json({ counts });
  } catch (err) {
    console.error('getUnreadCounts error:', err.message);
    res.status(500).json({ error: 'Failed to load unread counts.' });
  }
}

module.exports = { getConversation, getUnreadCounts };
