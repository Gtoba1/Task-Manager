// server/middleware/upload.js
// Multer configuration for avatar photo uploads.
//
// NON-DEVELOPER GUIDE:
//   • Uploaded photos are saved to: server/public/uploads/avatars/
//   • Max file size is 3 MB — large photos are rejected with a clear error
//   • Accepted types: JPG, PNG, GIF, WebP
//   • Old avatar files are NOT automatically deleted — clean up manually if needed

const multer = require('multer');
const path   = require('path');

// ── Where to save files and how to name them ─────────────────
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '../public/uploads/avatars'));
  },
  filename: (req, file, cb) => {
    // Format: userId-timestamp.ext  (e.g. 3-1712345678.jpg)
    // Using the user ID + timestamp prevents name collisions and cache issues
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, `${req.params.id}-${Date.now()}${ext}`);
  },
});

// ── Only accept image files ───────────────────────────────────
const fileFilter = (req, file, cb) => {
  const allowed = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
  if (allowed.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Only image files are allowed (JPG, PNG, GIF, WebP).'));
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 3 * 1024 * 1024 }, // 3 MB maximum
});

module.exports = upload;
