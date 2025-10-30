


const db = require('../models/db');


exports.getDueInvoices = (req, res) => {
  const { zsDelCode } = req.params; 

  const query = `
    SELECT 
      o.InvDocNo,
      DATE_FORMAT(o.dtdocdate, '%Y-%m-%d') AS dtdocdate,
      o.zsDocType,
      o.dbAmount,
      DATE_FORMAT(o.DelivDate, '%Y-%m-%d') AS DelivDate,
      DATE_FORMAT(o.DuDate, '%Y-%m-%d') AS DuDate,
      o.DaysDue,
      c.ChqNumber, 
      c.ChequeAmt, 
      DATE_FORMAT(c.DepDate, '%Y-%m-%d') AS DepDate
    FROM tbldeloutstanding o
    LEFT JOIN tblrecv_cheque c 
      ON o.InvDocNo = c.zDocNo
    WHERE o.zsDelCode = ? 
      AND o.zsDocType IN ('RV21', 'RV22', 'RV23', 'RV24') 
      AND o.DaysDue >= -20 AND o.DaysDue < 0
    ORDER BY o.dtdocdate DESC, o.zDocNo ASC
  `;

  db.query(query, [zsDelCode], (err, results) => {
    if (err) {
      console.error('Error fetching due invoices:', err.message);
      return res.status(500).json({ message: 'Server error', error: err.message });
    }

    
    const dueInvoiceCount = results.length;

  
    res.status(200).json({
      message: dueInvoiceCount === 0 ? 'No due invoices found' : 'Due invoices fetched successfully',
      dueInvoiceCount,
      invoices: results,
    });
  });
};





