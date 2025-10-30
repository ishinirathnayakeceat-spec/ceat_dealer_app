const db = require('../models/db');

exports.getPPDDetailsAndSummary = (req, res) => {
  const { zsDelCode } = req.body;

 
  const summaryQuery = `
    SELECT 
        YearMonth,
        SUM(NetPPD_Amt) AS Total_NetPPD_Amt
    FROM 
        ppd_dtl
    WHERE 
        DelCode = ?
    GROUP BY 
        YearMonth
    ORDER BY 
        YearMonth DESC
    LIMIT 3;
  `;

  db.query(summaryQuery, [zsDelCode], (summaryErr, summaryResults) => {
    if (summaryErr) {
      console.error('Error fetching PPD summary:', summaryErr.message);
      return res.status(500).json({ message: 'Server error' });
    }

    if (summaryResults.length === 0) {
      return res.status(404).json({ message: 'No data found for the given dealer code' });
    }

  
    const yearMonths = summaryResults.map((row) => row.YearMonth);

   
    const detailsQuery = `
      SELECT 
          YearMonth,
          Inv_DocNumber AS "Invoice Number",
          DATE_FORMAT(Inv_Date, '%Y-%m-%d') AS "Invoice Date",
          DATE_FORMAT(ppd_date, '%Y-%m-%d') AS "PPD Cal Date",
          DATE_FORMAT(Due_date, '%Y-%m-%d') AS "Due Date",
          Inv_Amt AS "Invoice Amount",
          DATE_FORMAT(Account_postDate, '%Y-%m-%d') AS "Acc.Posting Date",
          Acc_Ref_No AS "Acc.Ref.Doc Number",
          Settle_Amt AS "Settle Amount",
          PPD_Amt AS "PPD Amount",
          Panalty_Amt AS "Panalty Amount",
          NetPPD_Amt AS "Net PPD Amount"
      FROM 
          ppd_dtl
      WHERE 
          DelCode = ? AND YearMonth IN (?);
    `;

    db.query(detailsQuery, [zsDelCode, yearMonths], (detailsErr, detailsResults) => {
      if (detailsErr) {
        console.error('Error fetching PPD details:', detailsErr.message);
        return res.status(500).json({ message: 'Server error' });
      }

      
      const groupedDetails = yearMonths.map((ym) => ({
        YearMonth: ym,
        Total_NetPPD_Amt: summaryResults.find((row) => row.YearMonth === ym)?.Total_NetPPD_Amt || 0,
        Details: detailsResults.filter((row) => row.YearMonth === ym),
      }));

      res.status(200).json({
        message: 'PPD summary and details fetched successfully',
        data: groupedDetails,
      });
    });
  });
};
