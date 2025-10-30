const crypto = require('crypto');

function decryptPassword(encryptedPassword, password) {
  const method = 'aes-256-cbc';

  // Decode Base64 password
  const decoded = Buffer.from(encryptedPassword, 'base64');

  // The first 16 bytes (128 bits) are the IV
  const iv = decoded.slice(0, 16);

  // The next 32 bytes (256 bits) are the HMAC hash
  const hash = decoded.slice(16, 48).toString('hex');

  // The remaining part is the ciphertext
  const ciphertext = decoded.slice(48);

  // Generate key from password using SHA-256 hash
  const key = crypto.createHash('sha256').update(password).digest();

  // Validate the HMAC to ensure integrity
  const hmac = crypto.createHmac('sha256', key).update(ciphertext).digest('hex');
  if (hmac !== hash) {
    throw new Error('Invalid hash: HMAC validation failed.');
  }

  // Decrypt the ciphertext
  const decipher = crypto.createDecipheriv(method, key, iv);
  let decrypted = decipher.update(ciphertext, 'binary', 'utf8');
  decrypted += decipher.final('utf8');

  return decrypted;
}

module.exports = { decryptPassword };