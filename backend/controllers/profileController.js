const db = require('../models/db');

exports.getProfileDetails = (req, res) => {
  const { zsDelCode } = req.params; 
  const query = 'SELECT dm.*, sr.* FROM tbldealermaster dm JOIN sms_tbl_registry sr ON dm.zsSRepNo = sr.usercode WHERE dm.zsDelCode = ?';

  db.query(query, [zsDelCode], (err, results) => {
    if (err) {
      console.error('Error fetching profile details:', err.message);
      return res.status(500).json({ message: 'Server error', error: err.message });
    }

    if (results.length === 0) {
      return res.status(404).json({ message: 'Profile not found' });
    }

    res.status(200).json({ profile: results[0] });
  });
};
