
const db = require('../models/db'); 


exports.getClaimDetails = (req, res) => {
    const { zsDelCode } = req.params; 

    if (!zsDelCode) {
        return res.status(400).json({ message: 'Dealer code is required' });
    }

   
    const summaryQuery = `
        SELECT 
            zsDocketNo AS cl1_number, 
            DATE_FORMAT(ZDDATE, '%Y-%m-%d') AS received_date, 
            COUNT(zsCliamNo) AS total_received_qty
        FROM tblclaimregistrysf
        WHERE zsdelcode = ?
        GROUP BY zsDocketNo, ZDDATE
        ORDER BY ZDDATE DESC
        LIMIT 5;
    `;

    
    const detailsQuery = `
        SELECT 
            c.zsDocketNo AS cl1_number,
            c.zsCliamNo AS claim_no,
            m.zsmat_des AS material_description,
            c.ZSERIALNR AS serial_number,
            c.WEAR AS tread_wear,
            CASE 
                WHEN c.FEGRP IN ('ACCEPTTY', 'ACCEPTTU', 'ACCEPTFL', 'NDDT1', 'POLICY.K') THEN 'Adjusted'
                WHEN c.FEGRP IN ('REJECTTY', 'REJECTTU', 'REJECTFL') THEN 'Rejected'
                ELSE c.FEGRP
            END AS disposition,
            c.KURZTEXT AS defect,
            c.VBELN AS invoice_number,
            DATE_FORMAT(c.FKDAT, '%Y-%m-%d') AS invoice_date,
            CASE 
                WHEN c.FKART IN ('ZWO2', 'ZWF3') THEN 'Claim Invoice'
                WHEN c.FKART = 'ZWMA' THEN 'Claim Com. Invoice'
                WHEN c.FKART = 'ZWC2' THEN 'Claim Credit Note'
                WHEN c.FKART = 'ZWC3' THEN 'Claim Return Credit Note'
                WHEN c.FKART = 'ZG' THEN 'Claim Com. Credit Note'
                ELSE c.FKART
            END AS billing_type,
            c.INVVAL AS offer_value
        FROM tblclaimregistrysf c
        JOIN tblmaterial m ON c.zsmat_num = m.zsmat_num
        WHERE c.zsDocketNo = ?
        ORDER BY c.zdtChangeDate DESC;
    `;

    db.query(summaryQuery, [zsDelCode], (err, claimSummaryResults) => {
        if (err) {
            console.error('Error fetching claim summary:', err.message);
            return res.status(500).json({ message: 'Server error', error: err.message });
        }

        if (claimSummaryResults.length === 0) {
            return res.status(200).json({
                message: 'No claims found',
                claimSummary: [],
            });
        }

        
        const groupedData = claimSummaryResults.map((summary) => {
            return new Promise((resolve, reject) => {
                db.query(detailsQuery, [summary.cl1_number], (err, claimDetails) => {
                    if (err) {
                        reject(err);
                    } else {
                        resolve({
                            cl1_number: summary.cl1_number,
                            received_date: summary.received_date,
                            total_received_qty: summary.total_received_qty,
                            claimDetails: claimDetails.map((detail) => ({
                                claimNo: detail.claim_no,
                                materialDescription: detail.material_description,
                                serialNumber: detail.serial_number,
                                treadWear: detail.tread_wear,
                                disposition: detail.disposition,
                                defect: detail.defect,
                                invoiceNumber: detail.invoice_number,
                                invoiceDate: detail.invoice_date,
                                billingType: detail.billing_type,
                                offerValue: detail.offer_value,
                            })),
                        });
                    }
                });
            });
        });

       
        Promise.all(groupedData)
            .then((results) => {
                res.status(200).json({
                    message: 'Claim details fetched successfully',
                    claimSummary: results,
                });
            })
            .catch((error) => {
                console.error('Error processing claim details:', error.message);
                res.status(500).json({ message: 'Server error while processing claim details' });
            });
    });
};


exports.getClaimDetailsByDateAndDocket = (req, res) => {
    const { zsDelCode, docketNo, fromDate, toDate } = req.body; 
  
  
    const summaryQuery = `
      SELECT 
        c.zsDocketNo AS cl1_number,
        DATE_FORMAT(c.ZDDATE, '%Y-%m-%d') AS received_date,
        COUNT(c.zsCliamNo) AS total_received_qty
      FROM tblclaimregistrysf c
      WHERE c.zsdelcode = ? 
        AND c.zsDocketNo = ? 
        AND c.ZDDATE BETWEEN ? AND ?
      GROUP BY c.zsDocketNo, c.ZDDATE
      ORDER BY c.ZDDATE DESC
    `;
  
    
    db.query(summaryQuery, [zsDelCode, docketNo, fromDate, toDate], (err, claimSummary) => {
      if (err) {
        console.error('Error fetching claim summary:', err.message);
        return res.status(500).json({ message: 'Server error', error: err.message });
      }
  
      if (claimSummary.length === 0) {
        return res.status(200).json({
          message: 'No claims found for the provided DocketNo and Date range',
          claimSummary: [],
        });
      }
  
    
      const detailsQuery = `
        SELECT 
          c.zsCliamNo AS claimNo,
          m.zsmat_des AS materialDescription,
          c.ZSERIALNR AS serialNumber,
          c.WEAR AS treadWear,
          CASE 
            WHEN c.FEGRP IN ('ACCEPTTY', 'ACCEPTTU', 'ACCEPTFL', 'NDDT1', 'POLICY.K') THEN 'Adjusted'
            WHEN c.FEGRP IN ('REJECTTY', 'REJECTTU', 'REJECTFL') THEN 'Rejected'
            ELSE c.FEGRP
          END AS disposition,
          c.KURZTEXT AS defect,
          c.VBELN AS invoiceNumber,
          DATE_FORMAT(c.FKDAT, '%Y-%m-%d') AS invoiceDate,
          CASE 
            WHEN c.FKART IN ('ZWO2', 'ZWF3') THEN 'Claim Invoice'
            WHEN c.FKART = 'ZWMA' THEN 'Claim Com. Invoice'
            WHEN c.FKART = 'ZWC2' THEN 'Claim Credit Note'
            WHEN c.FKART = 'ZWC3' THEN 'Claim Return Credit Note'
            WHEN c.FKART = 'ZG' THEN 'Claim Com. Credit Note'
            ELSE c.FKART
          END AS billingType,
          c.INVVAL AS offerValue
        FROM tblclaimregistrysf c
        JOIN tblmaterial m ON c.zsmat_num = m.zsmat_num
        WHERE c.zsdelcode = ? 
          AND c.zsDocketNo = ? 
          AND c.ZDDATE BETWEEN ? AND ?
        ORDER BY c.zdtChangeDate DESC
      `;
  
      const promises = claimSummary.map((claim) => {
        return new Promise((resolve, reject) => {
          db.query(detailsQuery, [zsDelCode, claim.cl1_number, fromDate, toDate], (err, claimDetails) => {
            if (err) {
              reject(err);
            } else {
              resolve({ ...claim, claimDetails });
            }
          });
        });
      });
  
      Promise.all(promises).then((results) => {
        res.status(200).json({
          message: 'Claim details fetched successfully',
          claimSummary: results,
        });
      }).catch((err) => {
        console.error('Error fetching claim details:', err.message);
        res.status(500).json({ message: 'Server error', error: err.message });
      });
    });
  };


  
  exports.getClaimDetailsByDocket = (req, res) => {
    const { zsDelCode, docketNo } = req.body; 
  
    
    const summaryQuery = `
      SELECT 
        c.zsDocketNo AS cl1_number,
        DATE_FORMAT(c.ZDDATE, '%Y-%m-%d') AS received_date,
        COUNT(c.zsCliamNo) AS total_received_qty
      FROM tblclaimregistrysf c
      WHERE c.zsdelcode = ? 
        AND c.zsDocketNo = ? 
      GROUP BY c.zsDocketNo, c.ZDDATE
      ORDER BY c.ZDDATE DESC
    `;
  
    
    db.query(summaryQuery, [zsDelCode, docketNo], (err, claimSummary) => {
      if (err) {
        console.error('Error fetching claim summary:', err.message);
        return res.status(500).json({ message: 'Server error', error: err.message });
      }
  
      if (claimSummary.length === 0) {
        return res.status(200).json({
          message: 'No claims found for the provided DocketNo and Date range',
          claimSummary: [],
        });
      }
  
      
      const detailsQuery = `
        SELECT 
          c.zsCliamNo AS claimNo,
          m.zsmat_des AS materialDescription,
          c.ZSERIALNR AS serialNumber,
          c.WEAR AS treadWear,
          CASE 
            WHEN c.FEGRP IN ('ACCEPTTY', 'ACCEPTTU', 'ACCEPTFL', 'NDDT1', 'POLICY.K') THEN 'Adjusted'
            WHEN c.FEGRP IN ('REJECTTY', 'REJECTTU', 'REJECTFL') THEN 'Rejected'
            ELSE c.FEGRP
          END AS disposition,
          c.KURZTEXT AS defect,
          c.VBELN AS invoiceNumber,
          DATE_FORMAT(c.FKDAT, '%Y-%m-%d') AS invoiceDate,
          CASE 
            WHEN c.FKART IN ('ZWO2', 'ZWF3') THEN 'Claim Invoice'
            WHEN c.FKART = 'ZWMA' THEN 'Claim Com. Invoice'
            WHEN c.FKART = 'ZWC2' THEN 'Claim Credit Note'
            WHEN c.FKART = 'ZWC3' THEN 'Claim Return Credit Note'
            WHEN c.FKART = 'ZG' THEN 'Claim Com. Credit Note'
            ELSE c.FKART
          END AS billingType,
          c.INVVAL AS offerValue
        FROM tblclaimregistrysf c
        JOIN tblmaterial m ON c.zsmat_num = m.zsmat_num
        WHERE c.zsdelcode = ? 
          AND c.zsDocketNo = ? 
        ORDER BY c.zdtChangeDate DESC
      `;
  
      const promises = claimSummary.map((claim) => {
        return new Promise((resolve, reject) => {
          db.query(detailsQuery, [zsDelCode, claim.cl1_number], (err, claimDetails) => {
            if (err) {
              reject(err);
            } else {
              resolve({ ...claim, claimDetails });
            }
          });
        });
      });
  
      Promise.all(promises).then((results) => {
        res.status(200).json({
          message: 'Claim details fetched successfully',
          claimSummary: results,
        });
      }).catch((err) => {
        console.error('Error fetching claim details:', err.message);
        res.status(500).json({ message: 'Server error', error: err.message });
      });
    });

  };



  exports.getClaimDetailsByDateRange = (req, res) => {
    const { zsDelCode, fromDate, toDate } = req.body; 
  
  
    const summaryQuery = `
      SELECT 
        c.zsDocketNo AS cl1_number,
        DATE_FORMAT(c.ZDDATE, '%Y-%m-%d') AS received_date,
        COUNT(c.zsCliamNo) AS total_received_qty
      FROM tblclaimregistrysf c
      WHERE c.zsdelcode = ? 
        AND c.ZDDATE BETWEEN ? AND ?
      GROUP BY c.zsDocketNo, c.ZDDATE
      ORDER BY c.ZDDATE DESC
    `;
  
    
    db.query(summaryQuery, [zsDelCode, fromDate, toDate], (err, claimSummary) => {
      if (err) {
        console.error('Error fetching claim summary:', err.message);
        return res.status(500).json({ message: 'Server error', error: err.message });
      }
  
      if (claimSummary.length === 0) {
        return res.status(200).json({
          message: 'No claims found for the provided DocketNo and Date range',
          claimSummary: [],
        });
      }
  
      
      const detailsQuery = `
        SELECT 
          c.zsCliamNo AS claimNo,
          m.zsmat_des AS materialDescription,
          c.ZSERIALNR AS serialNumber,
          c.WEAR AS treadWear,
          CASE 
            WHEN c.FEGRP IN ('ACCEPTTY', 'ACCEPTTU', 'ACCEPTFL', 'NDDT1', 'POLICY.K') THEN 'Adjusted'
            WHEN c.FEGRP IN ('REJECTTY', 'REJECTTU', 'REJECTFL') THEN 'Rejected'
            ELSE c.FEGRP
          END AS disposition,
          c.KURZTEXT AS defect,
          c.VBELN AS invoiceNumber,
          DATE_FORMAT(c.FKDAT, '%Y-%m-%d') AS invoiceDate,
          CASE 
            WHEN c.FKART IN ('ZWO2', 'ZWF3') THEN 'Claim Invoice'
            WHEN c.FKART = 'ZWMA' THEN 'Claim Com. Invoice'
            WHEN c.FKART = 'ZWC2' THEN 'Claim Credit Note'
            WHEN c.FKART = 'ZWC3' THEN 'Claim Return Credit Note'
            WHEN c.FKART = 'ZG' THEN 'Claim Com. Credit Note'
            ELSE c.FKART
          END AS billingType,
          c.INVVAL AS offerValue
        FROM tblclaimregistrysf c
        JOIN tblmaterial m ON c.zsmat_num = m.zsmat_num
        WHERE c.zsdelcode = ? 
          AND c.ZDDATE BETWEEN ? AND ?
          AND c.zsDocketNo = ?
        ORDER BY c.zdtChangeDate DESC
      `;
  
      const promises = claimSummary.map((claim) => {
        return new Promise((resolve, reject) => {
          db.query(detailsQuery, [zsDelCode, fromDate, toDate, claim.cl1_number], (err, claimDetails) => {
            if (err) {
              reject(err);
            } else {
              resolve({ ...claim, claimDetails });
            }
          });
        });
      });
  
      Promise.all(promises).then((results) => {
        res.status(200).json({
          message: 'Claim details fetched successfully',
          claimSummary: results,
        });
      }).catch((err) => {
        console.error('Error fetching claim details:', err.message);
        res.status(500).json({ message: 'Server error', error: err.message });
      });
    });
  }

