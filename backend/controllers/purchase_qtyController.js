const db = require('../models/db');

const allowedGroups = [
  'FG0001', 'FG0002', 'FG0003', 'FG0004', 'FG0005', 'FG0006', 'FG0007', 
  'FG0010', 'FG0011', 'FG0020', 'FG0021', 'FG0022', 'FG0023', 'FG0024'
];

const defaultResponse = allowedGroups.map(group => ({
  zsmat_grp: group === 'FG0010' || group === 'FG0011' ? 'Agri Front & Rear' : group,
  materialName: group === 'FG0010' || group === 'FG0011' ? 'Agri Front & Rear' : '',
  latestMonthQuantity: 0,
  secondLatestMonthQuantity: 0,
  thirdLatestMonthQuantity: 0
}));


exports.getPurchaseQtyDetails = (req, res) => {
  const { zsDelCode } = req.params;

  const purchaseQtyQuery = `
    WITH LatestMonths AS (
      SELECT DISTINCT zsmonth
      FROM tblsales_month
      WHERE zsdelcode = ?
      ORDER BY zsmonth DESC
      LIMIT 3
    ),
    GroupedData AS (
      SELECT
        tsm.zsmonth,
        CASE 
          WHEN tsm.zsmat_grp IN ('FG0010', 'FG0011') THEN 'Agri Front & Rear'
          ELSE mg.zsmat_grp
        END AS zsmat_grp,
        CASE 
          WHEN tsm.zsmat_grp IN ('FG0010', 'FG0011') THEN 'Agri Front & Rear'
          ELSE mg.zsgrp_des 
        END AS materialName,
        SUM(tsm.zdqty) AS totalQuantity
      FROM tblsales_month tsm
      INNER JOIN tblmat_group mg ON tsm.zsmat_grp = mg.zsmat_grp
      WHERE tsm.zsdelcode = ? AND (tsm.zsmat_grp IN (${allowedGroups.map(() => '?').join(',')}))
      GROUP BY tsm.zsmonth, zsmat_grp, materialName
    )
    SELECT
      gd.zsmat_grp,
      gd.materialName,
      COALESCE(SUM(CASE WHEN gd.zsmonth = (SELECT zsmonth FROM LatestMonths LIMIT 1) THEN 
        CASE WHEN gd.totalQuantity < 0 THEN 0 ELSE gd.totalQuantity END END), 0) AS latestMonthQuantity,
      COALESCE(SUM(CASE WHEN gd.zsmonth = (SELECT zsmonth FROM LatestMonths LIMIT 1 OFFSET 1) THEN 
        CASE WHEN gd.totalQuantity < 0 THEN 0 ELSE gd.totalQuantity END END), 0) AS secondLatestMonthQuantity,
      COALESCE(SUM(CASE WHEN gd.zsmonth = (SELECT zsmonth FROM LatestMonths LIMIT 1 OFFSET 2) THEN 
        CASE WHEN gd.totalQuantity < 0 THEN 0 ELSE gd.totalQuantity END END), 0) AS thirdLatestMonthQuantity
    FROM GroupedData gd
    GROUP BY gd.zsmat_grp, gd.materialName
    ORDER BY CASE 
        WHEN zsmat_grp = 'FG0001' THEN 1
        WHEN zsmat_grp = 'FG0002' THEN 2
        WHEN zsmat_grp = 'FG0003' THEN 3
        WHEN zsmat_grp = 'FG0004' THEN 4
        WHEN zsmat_grp = 'FG0005' THEN 5
        WHEN zsmat_grp = 'FG0006' THEN 6
        WHEN zsmat_grp = 'FG0007' THEN 7
        WHEN zsmat_grp = 'Agri Front & Rear' THEN 8
        ELSE CAST(SUBSTRING(zsmat_grp, 3) AS UNSIGNED) + 9
      END;
  `;

  db.query(purchaseQtyQuery, [zsDelCode, zsDelCode, ...allowedGroups], (err, results) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ message: 'Server error', error: err.message });
    }

    const finalResults = results.length > 0 ? results : defaultResponse;
    res.status(200).json({
      message: 'Purchase volume details fetched successfully',
      data: finalResults,
    });
  });
};





exports.getPurchaseQtyBySearch = (req, res) => {
  const { zsDelCode, selectedYear, selectedMonth } = req.body;
  const monthNumber = String(selectedMonth).padStart(2, '0');
  const currentMonth = `${selectedYear}${monthNumber}`;
  let previousMonthYear = parseInt(selectedYear);
  let previousMonth = parseInt(monthNumber) - 1;

  if (previousMonth === 0) {
    previousMonth = 12;
    previousMonthYear -= 1;
  }
  const previousMonthFormatted = `${previousMonthYear}${String(previousMonth).padStart(2, '0')}`;

  let thirdLatestMonthYear = previousMonthYear;
  let thirdLatestMonth = previousMonth - 1;

  if (thirdLatestMonth === 0) {
    thirdLatestMonth = 12;
    thirdLatestMonthYear -= 1;
  }
  const thirdLatestMonthFormatted = `${thirdLatestMonthYear}${String(thirdLatestMonth).padStart(2, '0')}`;

  const purchaseQtyQuery = `
    WITH GroupedData AS (
      SELECT
        tsm.zsmonth,
        CASE 
          WHEN tsm.zsmat_grp IN ('FG0010', 'FG0011') THEN 'Agri Front & Rear'
          ELSE mg.zsmat_grp
        END AS zsmat_grp,
        CASE 
          WHEN tsm.zsmat_grp IN ('FG0010', 'FG0011') THEN 'Agri Front & Rear'
          ELSE mg.zsgrp_des 
        END AS materialName,
        SUM(tsm.zdqty) AS totalQuantity
      FROM tblsales_month tsm
      INNER JOIN tblmat_group mg ON tsm.zsmat_grp = mg.zsmat_grp
      WHERE tsm.zsdelcode = ? AND tsm.zsmat_grp IN (${allowedGroups.map(() => '?').join(',')})
      GROUP BY tsm.zsmonth, zsmat_grp, materialName
    )
    SELECT
      gd.zsmat_grp,
      gd.materialName,
      COALESCE(SUM(CASE WHEN gd.zsmonth = ? THEN 
        CASE WHEN gd.totalQuantity < 0 THEN 0 ELSE gd.totalQuantity END END), 0) AS latestMonthQuantity,
      COALESCE(SUM(CASE WHEN gd.zsmonth = ? THEN 
        CASE WHEN gd.totalQuantity < 0 THEN 0 ELSE gd.totalQuantity END END), 0) AS secondLatestMonthQuantity,
      COALESCE(SUM(CASE WHEN gd.zsmonth = ? THEN 
        CASE WHEN gd.totalQuantity < 0 THEN 0 ELSE gd.totalQuantity END END), 0) AS thirdLatestMonthQuantity
    FROM GroupedData gd
    GROUP BY gd.zsmat_grp, gd.materialName
    ORDER BY 
      CASE 
        WHEN zsmat_grp = 'FG0001' THEN 1
        WHEN zsmat_grp = 'FG0002' THEN 2
        WHEN zsmat_grp = 'FG0003' THEN 3
        WHEN zsmat_grp = 'FG0004' THEN 4
        WHEN zsmat_grp = 'FG0005' THEN 5
        WHEN zsmat_grp = 'FG0006' THEN 6
        WHEN zsmat_grp = 'FG0007' THEN 7
        WHEN zsmat_grp = 'Agri Front & Rear' THEN 8
        ELSE CAST(SUBSTRING(zsmat_grp, 3) AS UNSIGNED) + 9
      END;
  `;

  db.query(purchaseQtyQuery, [zsDelCode, ...allowedGroups, currentMonth, previousMonthFormatted, thirdLatestMonthFormatted], (err, results) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({ message: 'Server error', error: err.message });
    }
    if (!results || results.length === 0) {
      return res.status(200).json({ message: 'No data available', data: [] });
    }
    res.status(200).json({
      message: 'Purchase volume details fetched successfully',
      data: results,
    });
  });
};
