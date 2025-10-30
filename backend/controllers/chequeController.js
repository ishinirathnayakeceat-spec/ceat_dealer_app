const db = require('../models/db');

async function getCheques(req, res) {
    const { selectedOption, chequeNo, fromDate, toDate, zsDelCode } = req.query;

    if (!zsDelCode) { 
        return res.status(400).json({ message: 'zsDelCode is required' });
    }

    let query;
    let params = [zsDelCode];

    switch (selectedOption) {
        case 'Return':
            query = 
         

                    `SELECT 
                    pr.zsRPayDoc AS zsRPayDoc,
                    pr.ZsChqNo AS ZsChqNo,
                    DATE_FORMAT(pr.ZdtDocDate, '%Y-%m-%d') AS ZdtDocDate,
                    pr.ZsChqAmount AS ZsChqAmount,
                    pr.zsReason AS zsReason,
                    ref.zsinvnum AS zsinvnum,
                    ref.zsInvAmt AS zsInvAmt
                FROM tblpaymentreturn pr
                LEFT JOIN tblreturnrefPay ref
                    ON pr.zsPayDoc = ref.zsPayDoc AND pr.zscompany = ref.zscompany
                WHERE pr.zsDelCode = ?
                    ${chequeNo ? `AND pr.ZsChqNo LIKE ?` : ''}
                    ${fromDate ? `AND pr.ZdtDocDate >= ?` : ''}
                    ${toDate ? `AND pr.ZdtDocDate <= ?` : ''}
            `;
            if (chequeNo) params.push(`%${chequeNo}%`);
            if (fromDate) params.push(fromDate);
            if (toDate) params.push(toDate);
            break;         
        case 'Collect':
            query = `
                SELECT zsChqNo, zsChqAmount, DATE_FORMAT(zsdtCrtDate, '%Y-%m-%d') AS zsdtCrtDate, DATE_FORMAT(zsdtDocDate, '%Y-%m-%d') AS zsdtDocDate, zsBankName, zsLocation
                FROM tbl_cheque_collections
                WHERE zsDelCode = ?
                    ${chequeNo ? `AND zsChqNo LIKE ?` : ''}
                    ${fromDate ? `AND zsdtDocDate >= ?` : ''}
                    ${toDate ? `AND zsdtDocDate <= ?` : ''}
            `;
            if (chequeNo) params.push(`%${chequeNo}%`);
            if (fromDate) params.push(fromDate);
            if (toDate) params.push(toDate);
            break;
        case 'Realized':
            query = `
                SELECT ZsChqNo, ZsChqAmount, DATE_FORMAT(ZdtDocDate, '%Y-%m-%d') AS ZdtDocDate, zsPayDoc, ZsInv
                FROM tbl_realized_chq
                WHERE zsDelCode = ?
                    ${chequeNo ? `AND ZsChqNo LIKE ?` : ''}
                    ${fromDate ? `AND ZdtDocDate >= ?` : ''}
                    ${toDate ? `AND ZdtDocDate <= ?` : ''}
            `;
            if (chequeNo) params.push(`%${chequeNo}%`);
            if (fromDate) params.push(fromDate);
            if (toDate) params.push(toDate);
            break;
        default:
            return res.status(400).json({ message: 'Invalid option selected' });
    }

    db.query(query, params, (err, rows) => { 
      if (err) {
        console.error("Database Error:", err);
        return res.status(500).json({ message: 'Error fetching cheques', error: err.message });
      }
      res.json(rows);
    });
}

module.exports = { getCheques };