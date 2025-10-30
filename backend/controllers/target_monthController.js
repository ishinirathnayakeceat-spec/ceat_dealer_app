const db = require('../models/db');

const allowedGroups = [
  'FG0001', 'FG0002', 'FG0003', 'FG0004', 'FG0005', 'FG0006', 'FG0007', 
  'FG0010', 'FG0011', 'FG0020', 'FG0021', 'FG0022', 'FG0023', 'FG0024'
];


exports.getMaterialGroupPerformance = (req, res) => {
  const { zsDelCode } = req.params;

  const query = `
    SELECT 
      CASE 
        WHEN mg.zsmat_grp IN ('FG0010', 'FG0011') THEN 'Agri Front & Rear'
        ELSE mg.zsmat_grp
      END AS MaterialGroup,
      CASE 
        WHEN mg.zsmat_grp IN ('FG0010', 'FG0011') THEN 'Agri Front & Rear'
        ELSE mg.zsgrp_des 
      END AS materialName,
      GREATEST(SUM(sm.zdtargetQty), 0) AS TotalTarget,
      GREATEST(SUM(sm.zdqty), 0) AS TotalAchievement
    FROM tblsales_month sm
    INNER JOIN tblmat_group mg 
      ON sm.zsmat_grp = mg.zsmat_grp
    WHERE sm.zsdelcode = ? 
      AND sm.zsmonth = (
        SELECT MAX(zsmonth) 
        FROM tblsales_month 
        WHERE zsdelcode = ?
      )
      AND sm.zsmat_grp IN (${allowedGroups.map(() => '?').join(',')})
    GROUP BY MaterialGroup, materialName
    ORDER BY CASE 
        WHEN MaterialGroup = 'FG0001' THEN 1
        WHEN MaterialGroup = 'FG0002' THEN 2
        WHEN MaterialGroup = 'FG0003' THEN 3
        WHEN MaterialGroup = 'FG0004' THEN 4
        WHEN MaterialGroup = 'FG0005' THEN 5
        WHEN MaterialGroup = 'FG0006' THEN 6
        WHEN MaterialGroup = 'FG0007' THEN 7
        WHEN MaterialGroup = 'Agri Front & Rear' THEN 8
        ELSE CAST(SUBSTRING(MaterialGroup, 3) AS UNSIGNED) + 9
      END;
  `;

  db.query(query, [zsDelCode, zsDelCode, ...allowedGroups], (err, results) => {
    if (err) {
      console.error('Error fetching material group performance:', err.message);
      return res.status(500).json({ message: 'Server error', error: err.message });
    }

    
    const materialGroupCount = results.length;

    
    res.status(200).json({
      message: materialGroupCount === 0 
        ? 'No material group performance data found' 
        : 'Material group performance data fetched successfully',
      materialGroupCount,
      data: results,
    });
  });
};
