// src/passwordValidator.js
// Password strength rules applied when a USER sets their own password.
// NOT used when an admin sets/resets a password for someone else.

const COMMON = [
  'password','password1','password12','password123','12345678','123456789',
  '1234567890','qwerty123','admin1234','letmein1','welcome1','monkey123',
  'iloveyou1','sunshine1','princess1','football1','abc12345','pass1234',
];

const SEQUENTIAL = /012|123|234|345|456|567|678|789|890|abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz/i;

// Returns an array of { rule, pass } objects for UI display.
// pass = true means the rule is satisfied.
export function checkRules(password, { name = '', email = '' } = {}) {
  const lower      = password.toLowerCase();
  const firstName  = name.trim().split(/\s+/)[0].toLowerCase();
  const emailLocal = email.split('@')[0].toLowerCase();

  return [
    { rule: 'At least 12 characters',                    pass: password.length >= 12 },
    { rule: 'At least one uppercase letter (A–Z)',        pass: /[A-Z]/.test(password) },
    { rule: 'At least one lowercase letter (a–z)',        pass: /[a-z]/.test(password) },
    { rule: 'At least one number (0–9)',                  pass: /[0-9]/.test(password) },
    { rule: 'At least one special character (@#$%&*!?)', pass: /[@#$%&*!?^()\-_+=~|]/.test(password) },
    { rule: 'Does not contain your name',                 pass: !firstName || firstName.length < 3 || !lower.includes(firstName) },
    { rule: 'Does not contain your email address',        pass: !emailLocal || emailLocal.length < 3 || !lower.includes(emailLocal) },
    { rule: 'Not a commonly used password',               pass: !COMMON.includes(lower) },
    { rule: 'No repeated characters (e.g. "aaa")',        pass: !(/(.)\1{2,}/.test(password)) },
    { rule: 'No sequential characters (e.g. "123")',      pass: !SEQUENTIAL.test(lower) },
  ];
}

// Returns an array of failed rule strings (empty = valid).
export function validatePassword(password, context = {}) {
  return checkRules(password, context).filter(r => !r.pass).map(r => r.rule);
}
