// server/utils/passwordValidator.js
// Applied when a USER sets their own password. NOT used for admin-set passwords.

const COMMON = [
  'password','password1','password12','password123','12345678','123456789',
  '1234567890','qwerty123','admin1234','letmein1','welcome1','monkey123',
  'iloveyou1','sunshine1','princess1','football1','abc12345','pass1234',
];

const SEQUENTIAL = /012|123|234|345|456|567|678|789|890|abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz/i;

function validatePassword(password, { name = '', email = '' } = {}) {
  const errors  = [];
  const lower   = password.toLowerCase();
  const first   = name.trim().split(/\s+/)[0].toLowerCase();
  const emailLo = email.split('@')[0].toLowerCase();

  if (password.length < 12)                          errors.push('At least 12 characters long.');
  if (!/[A-Z]/.test(password))                      errors.push('At least one uppercase letter (A–Z).');
  if (!/[a-z]/.test(password))                      errors.push('At least one lowercase letter (a–z).');
  if (!/[0-9]/.test(password))                      errors.push('At least one number (0–9).');
  if (!/[@#$%&*!?^()\-_+=~|]/.test(password))      errors.push('At least one special character (@, #, $, %, &, *, !).');
  if (first.length >= 3 && lower.includes(first))   errors.push('Cannot contain your name.');
  if (emailLo.length >= 3 && lower.includes(emailLo)) errors.push('Cannot contain your email address.');
  if (COMMON.includes(lower))                        errors.push('Too common — choose a unique password.');
  if (/(.)\1{2,}/.test(password))                   errors.push('Avoid repeating the same character 3+ times.');
  if (SEQUENTIAL.test(lower))                        errors.push('Avoid sequential characters (e.g. "123" or "abc").');

  return errors;
}

module.exports = { validatePassword };
