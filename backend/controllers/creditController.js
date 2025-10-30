const db = require('../models/db');

exports.getCreditLimit = (req, res) => {
    const { zsDelCode } = req.params;

    if (!zsDelCode) {
        return res.status(400).json({ message: 'zsDelCode is required' });
    }

    const query = `
        SELECT zdCreditLmt 
        FROM tbldealermaster 
        WHERE zsDelCode = ?
    `;
    
    db.query(query, [zsDelCode], (err, results) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        if (results.length === 0) {
            return res.status(404).json({ message: 'Dealer not found' });
        }
        res.status(200).json(results[0]);
    });
};