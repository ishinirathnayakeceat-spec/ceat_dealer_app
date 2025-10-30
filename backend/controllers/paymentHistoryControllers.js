const db = require('../models/db');

exports.getPaymentHistory = (req, res) => {
    const { zsDelCode } = req.params; 
   

    const query = `
        SELECT 
            tblpayment.zsPayDocNo AS paymentNo,
            tblpayment.zsChqNo AS chequeNo,
            DATE_FORMAT(tblpayment.zdtDocDate, '%Y-%m-%d') AS receivedDate,
            tblpayment.zdChqAmt AS receivedAmount,
            DATE_FORMAT(tblpaymentreturn.ZdtDocDate ,'%Y-%m-%d') AS returnDate,
            tblpaymentreturn.ZsChqAmount AS returnAmount
        FROM tblpayment
        LEFT JOIN tblpaymentreturn
        ON tblpayment.zsPayDocNo = tblpaymentreturn.zsPayDoc
        WHERE tblpayment.zsDelCode = ?
        ORDER BY tblpayment.zdtDocDate DESC
        LIMIT 5
    `;

    db.query(query, [zsDelCode], (err, results) => {
        if (err) {
            console.error('Error fetching payment history:', err.message);
            return res.status(500).json({ message: 'Server error' });
        }

        const payHistoryCount = results.length;

        res.status(200).json({
            message: 'Latest 5 Payment History details fetched successfully',
            payHistoryCount,
            results,
          });
    });
};



exports.searchPaymentHistory = (req, res) => {
    const { paymentNo, fromDate, toDate, zsDelCode } = req.body;

    let query = `
        SELECT 
            tblpayment.zsPayDocNo AS paymentNo,
            tblpayment.zsChqNo AS chequeNo,
            DATE_FORMAT(tblpayment.zdtDocDate, '%Y-%m-%d') AS receivedDate,
            tblpayment.zdChqAmt AS receivedAmount,
            DATE_FORMAT(tblpaymentreturn.ZdtDocDate, '%Y-%m-%d') AS returnDate,
            tblpaymentreturn.ZsChqAmount AS returnAmount
        FROM tblpayment
        LEFT JOIN tblpaymentreturn
        ON tblpayment.zsPayDocNo = tblpaymentreturn.zsPayDoc
        WHERE tblpayment.zsDelCode = ?
    `;

    const queryParams = [zsDelCode];

    if (paymentNo) {
        query += ` AND tblpayment.zsPayDocNo = ?`;
        queryParams.push(paymentNo);
    }
    if (fromDate && toDate) {
        query += ` AND tblpayment.zdtDocDate BETWEEN ? AND ?`;
        queryParams.push(fromDate, toDate);
    }

    db.query(query, queryParams, (err, results) => {
        if (err) {
            console.error('Error fetching payment history:', err.message);
            return res.status(500).json({ message: 'Server error' });
        }

        res.status(200).json({
            message: 'Payment history fetched successfully',
            results,
        });
    });
};