const db = require('../models/db');
const { decryptPassword } = require('../utils/decryptUtils');

const loginUser  = async (req, res) => {
  try {
    const { zsDelCode, password } = req.body;

    if (!zsDelCode || !password) {
      return res.status(400).json({ login: 'failed', message: 'Dealer code and password are required.' });
    }

   
    const query = 'SELECT password FROM tbldealer_login WHERE zsDelCode = ?';
    db.query(query, [zsDelCode], (err, results) => {
      if (err) {
        console.error('Database error:', err.message);
        return res.status(500).json({ login: 'failed', message: 'Internal server error.' });
      }

      if (results.length === 0) {
        return res.status(401).json({ login: 'failed', message: 'Invalid dealer code or password.' });
      }

      const encryptedPassword = results[0].password;

    
      const decryptedPassword = decryptPassword(encryptedPassword, 'L0BFbkw41A7AFC75A7BB2219DiPQv9');

      if (decryptedPassword !== password) {
        return res.status(401).json({ login: 'failed', message: 'Invalid dealer code or password.' });
      }

     
      const dealerQuery = 'SELECT * FROM tbldealermaster WHERE zsDelCode = ?';
      db.query(dealerQuery, [zsDelCode], (dealerErr, dealerResults) => {
        if (dealerErr) {
          console.error('Database error:', dealerErr.message);
          return res.status(500).json({ login: 'failed', message: 'Internal server error.' });
        }

        if (dealerResults.length === 0) {
          return res.status(404).json({ login: 'failed', message: 'Dealer information not found.' });
        }

        const dealerInfo = dealerResults[0];
        return res.status(200).json({
          login: 'success',
          'login-details': {
            zsDelCode: dealerInfo.zsDelCode,
            zsSRepNo: dealerInfo.zsSRepNo,
            zsName: dealerInfo.zsName,
            zsAddress1: dealerInfo.zsAddress1,
            zsAddress2: dealerInfo.zsAddress2,
            zsAddress3: dealerInfo.zsAddress3,
            zdCreditLmt: dealerInfo.zdCreditLmt,
            zsContact1: dealerInfo.zsContact1,
            salesname: dealerInfo.salesname,
            ZsSds: dealerInfo.ZsSds,
          },
        });
      });
    });
  } catch (error) {
    console.error('Error during login:', error.message);
    return res.status(500).json({ login: 'failed', message: 'Internal server error.' });
  }
};

module.exports = { loginUser  };