const db = require('../models/db');

exports.getSummaryDetails = (req, res) => {
    const { zsDelCode } = req.params; 

    if (!zsDelCode) {
        return res.status(400).json({ message: 'zsDelCode is required' });
    }

    const query = `
        SELECT 
            SUM(CASE WHEN DATEDIFF(CURDATE(), dtdocdate) BETWEEN 0 AND 45 THEN dbAmount ELSE 0 END) AS days_45,
            SUM(CASE WHEN DATEDIFF(CURDATE(), dtdocdate) BETWEEN 46 AND 60 THEN dbAmount ELSE 0 END) AS days_60,
            SUM(CASE WHEN DATEDIFF(CURDATE(), dtdocdate) BETWEEN 61 AND 90 THEN dbAmount ELSE 0 END) AS days_90,
            SUM(CASE WHEN DATEDIFF(CURDATE(), dtdocdate) BETWEEN 91 AND 120 THEN dbAmount ELSE 0 END) AS days_120,
            SUM(CASE WHEN DATEDIFF(CURDATE(), dtdocdate) BETWEEN 121 AND 180 THEN dbAmount ELSE 0 END) AS days_180,
            SUM(CASE WHEN DATEDIFF(CURDATE(), dtdocdate) > 180 THEN dbAmount ELSE 0 END) AS more_than_180,
            -- Calculating 'actual_outstanding'
            SUM(CASE WHEN DATEDIFF(CURDATE(), dtdocdate) BETWEEN 0 AND 45 THEN dbAmount ELSE 0 END) +
            SUM(CASE WHEN DATEDIFF(CURDATE(), dtdocdate) BETWEEN 46 AND 60 THEN dbAmount ELSE 0 END) +
            SUM(CASE WHEN DATEDIFF(CURDATE(), dtdocdate) BETWEEN 61 AND 90 THEN dbAmount ELSE 0 END) +
            SUM(CASE WHEN DATEDIFF(CURDATE(), dtdocdate) BETWEEN 91 AND 120 THEN dbAmount ELSE 0 END) +
            SUM(CASE WHEN DATEDIFF(CURDATE(), dtdocdate) BETWEEN 121 AND 180 THEN dbAmount ELSE 0 END) +
            SUM(CASE WHEN DATEDIFF(CURDATE(), dtdocdate) > 180 THEN dbAmount ELSE 0 END) AS actual_outstanding,
            SUM(CASE WHEN zsDocType IN ('ZG21', 'ZG22') THEN dbAmount ELSE 0 END) AS credit_notes_total,
            SUM(CASE WHEN zsDocType IN ('AB21', 'AB22') THEN dbAmount ELSE 0 END) AS balance_amount_total,
            
            -- Calculating 'balance_of_cr_notes_adv'
            SUM(CASE WHEN zsDocType IN ('ZG21', 'ZG22') THEN dbAmount ELSE 0 END) +
            SUM(CASE WHEN zsDocType IN ('AB21', 'AB22') THEN dbAmount ELSE 0 END) AS balance_of_cr_notes_adv
        FROM tbldeloutstanding
        WHERE zsDelCode = ? AND zsDocType IN ('ZG21', 'ZG22', 'AB21', 'AB22');
    `;
    
    db.query(query, [zsDelCode], (err, results) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.status(200).json(results[0]);
    });
};

exports.getTotalChequesReceived = (req, res) => {
    const { zsDelCode } = req.params; 

    if (!zsDelCode) {
        return res.status(400).json({ message: 'zsDelCode is required' });
    }

    const query = `
        SELECT SUM(zsChqAmount) AS total_cheques 
        FROM tbl_cheque_collections 
        WHERE zsDelCode = ?
    `;
    
    db.query(query, [zsDelCode], (err, results) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.status(200).json(results[0]);
    });
};
