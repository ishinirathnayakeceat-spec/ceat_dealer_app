const db = require('../models/db');

exports.getOutstandingReports = (req, res) => {
    const { zsDelCode } = req.body;

    const queryDueInvoice = `
        SELECT
            DATE_FORMAT(dtdocdate, '%Y-%m-%d') AS docDate,
            InvDocNo AS docNo,
            zsDocType AS docType,
            dbAmount AS amount,
            DATE_FORMAT(DelivDate, '%Y-%m-%d') AS delDate,
            DATE_FORMAT(dueDate30, '%Y-%m-%d') AS dueDate30,
            DATE_FORMAT(Dudate, '%Y-%m-%d') AS dueDate,
            DaysDue AS daysDue,
            r.ChqNumber AS chqNo,
            r.ChequeAmt AS chqAmt,
            DATE_FORMAT(r.DepDate, '%Y-%m-%d') AS chqDepDate
        FROM tbldeloutstanding o
        LEFT JOIN tblrecv_cheque r ON o.InvDocNo = r.zDocNo
        WHERE o.zsDelCode = ? AND
              o.zsDocType IN ('RV21', 'RV22', 'RV23', 'RV24') AND
              o.DaysDue != 0
    `;

    const queryCreditNote = `
        SELECT
            DATE_FORMAT(dtdocdate, '%Y-%m-%d') AS docDate,
            InvDocNo AS docNo,
            zsDocType AS docType,
            dbAmount AS amount,
            sgtxt AS reason1,  -- Merged column for Del Date, 30 Due, Due Date, Days Due
            XBLNR AS reason2   -- Merged column for Chq No, Chq Amt, Chq Dep Date
        FROM tbldeloutstanding o
        WHERE o.zsDelCode = ? AND
              o.zsDocType NOT IN ('RV21', 'RV22', 'RV23', 'RV24')
    `;

    db.query(queryDueInvoice, [zsDelCode], (err, dueInvoiceResults) => {
        if (err) {
            console.error('Error fetching due invoices:', err.message);
            return res.status(500).json({ message: 'Server error' });
        }

        db.query(queryCreditNote, [zsDelCode], (err, creditNoteResults) => {
            if (err) {
                console.error('Error fetching credit notes:', err.message);
                return res.status(500).json({ message: 'Server error' });
            }

            
            const dueInvoiceTotal = dueInvoiceResults.reduce((acc, curr) => acc + parseFloat(curr.amount), 0);
            const creditNoteTotal = creditNoteResults.reduce((acc, curr) => acc + parseFloat(curr.amount), 0);
            const total = dueInvoiceTotal + creditNoteTotal;

            res.status(200).json({
                message: 'Outstanding reports fetched successfully',
                dueInvoices: dueInvoiceResults,
                creditNotes: creditNoteResults,
                total: total.toFixed(2) 
            });
        });
    });
};