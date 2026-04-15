// server/utils/email.js
// Email notification utility using nodemailer.
//
// HOW IT WORKS:
//   • If SMTP_HOST is set in your .env, emails are sent via your mail server.
//   • If SMTP_HOST is NOT set, the email content is logged to the server console
//     instead — so you can copy and forward manually. Nothing breaks.
//
// REQUIRED .env VARIABLES (only needed if you want real emails):
//   SMTP_HOST   — e.g. smtp.gmail.com
//   SMTP_PORT   — e.g. 587 (TLS) or 465 (SSL)
//   SMTP_USER   — your sending email address
//   SMTP_PASS   — your email password or app-specific password
//   SMTP_FROM   — display name + address, e.g. "Data Team <noreply@tdafrica.com>"
//
// GMAIL TIP: Use an App Password (not your account password).
//   Google Account → Security → 2-Step Verification → App Passwords

const nodemailer = require('nodemailer');

// ── Build transporter (only once at module load) ──────────────────────────────
let transporter = null;

if (process.env.SMTP_HOST) {
  transporter = nodemailer.createTransport({
    host:   process.env.SMTP_HOST,
    port:   parseInt(process.env.SMTP_PORT || '587'),
    secure: parseInt(process.env.SMTP_PORT || '587') === 465, // true = SSL, false = TLS/STARTTLS
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });
  console.log(`📧  Email transport configured via ${process.env.SMTP_HOST}`);
} else {
  console.log('📧  SMTP_HOST not set — emails will be logged to console only.');
}

// ── sendEmail({ to, subject, html, text }) ────────────────────────────────────
// to      — recipient email address (string) or array of addresses
// subject — email subject line
// html    — HTML body (optional but recommended)
// text    — plain-text fallback (optional, auto-generated from subject if omitted)
//
// This function never throws — failures are caught and logged so that
// a broken mail config can't take down task/project creation.
async function sendEmail({ to, subject, html, text }) {
  const recipients = Array.isArray(to) ? to.join(', ') : to;

  if (!transporter) {
    // ── Fallback: log to console so admin can copy + forward ──
    console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📧  EMAIL (SMTP not configured — console only)');
    console.log(`    To      : ${recipients}`);
    console.log(`    Subject : ${subject}`);
    console.log(`    Body    : ${text || subject}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    return;
  }

  try {
    const info = await transporter.sendMail({
      from:    process.env.SMTP_FROM || process.env.SMTP_USER,
      to:      recipients,
      subject,
      text:    text || subject,
      html:    html || `<p>${text || subject}</p>`,
    });
    console.log(`📧  Email sent to ${recipients} — ${info.messageId}`);
  } catch (err) {
    // Non-fatal — log and carry on
    console.error(`📧  Email failed to ${recipients}:`, err.message);
  }
}

module.exports = { sendEmail };
