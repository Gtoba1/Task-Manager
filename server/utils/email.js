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

// ── buildEmailHtml({ greeting, intro, rows, buttonText, buttonUrl }) ──────────
// Builds a clean, mobile-friendly HTML email with an optional call-to-action
// button. rows is an array of [label, value] pairs for the detail table.
// buttonUrl defaults to APP_URL from .env if not provided.
function buildEmailHtml({ greeting, intro, rows = [], buttonText = 'Open Task Manager', buttonUrl }) {
  const appUrl = buttonUrl || process.env.APP_URL || 'http://localhost:5173';
  const tableRows = rows
    .filter(([, v]) => v)
    .map(([l, v]) =>
      `<tr><td style="padding:6px 20px 6px 0;color:#666;font-size:13px;white-space:nowrap;vertical-align:top">${l}</td>` +
      `<td style="padding:6px 0;font-size:13px;color:#2A2829">${v}</td></tr>`
    ).join('');

  return `<!DOCTYPE html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
<body style="margin:0;padding:0;background:#F4F3F5;font-family:'Helvetica Neue',Arial,sans-serif">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#F4F3F5;padding:32px 0">
    <tr><td align="center">
      <table width="560" cellpadding="0" cellspacing="0" style="background:#fff;border-radius:10px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.07)">
        <!-- Header -->
        <tr><td style="background:#8B1A1A;padding:20px 32px">
          <span style="color:#fff;font-size:16px;font-weight:700;letter-spacing:0.5px">TD Africa · Data Team</span>
        </td></tr>
        <!-- Body -->
        <tr><td style="padding:28px 32px">
          <p style="margin:0 0 8px;font-size:15px;color:#2A2829">${greeting}</p>
          <p style="margin:0 0 20px;font-size:14px;color:#5A5860;line-height:1.6">${intro}</p>
          ${tableRows ? `<table cellpadding="0" cellspacing="0" style="margin-bottom:24px">${tableRows}</table>` : ''}
          <!-- CTA Button -->
          <table cellpadding="0" cellspacing="0">
            <tr><td style="background:#8B1A1A;border-radius:6px">
              <a href="${appUrl}" target="_blank"
                 style="display:inline-block;padding:10px 24px;color:#fff;font-size:13px;font-weight:600;text-decoration:none">${buttonText}</a>
            </td></tr>
          </table>
        </td></tr>
        <!-- Footer -->
        <tr><td style="padding:16px 32px;border-top:1px solid #E2E0E5;background:#FAFAFA">
          <p style="margin:0;font-size:11px;color:#918E98">
            This is an automated notification from the TD Africa Data Team Task Manager.<br>
            If you were not expecting this email, please contact your team administrator.
          </p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body></html>`;
}

module.exports = { sendEmail, buildEmailHtml };
