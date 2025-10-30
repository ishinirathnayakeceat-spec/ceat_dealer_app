const db = require('../models/db');


const allowedGroups = [
  'FG0001', 'FG0002', 'FG0003', 'FG0004', 'FG0005', 'FG0006', 'FG0007',
  'FG0010', 'FG0011', 'FG0020', 'FG0021', 'FG0022', 'FG0023', 'FG0024'
];

exports.getMaterialGroupPerformanceYear = (req, res) => {
  const { zsDelCode } = req.params;

  const query = `
    WITH YearlyData AS (
      SELECT 
        CASE 
          WHEN sm.zsmat_grp IN ('FG0010', 'FG0011') THEN 'Agri Front & Rear'
          ELSE sm.zsmat_grp
        END AS MaterialGroup,
        CASE 
          WHEN sm.zsmat_grp IN ('FG0010', 'FG0011') THEN 'Agri Front & Rear'
          ELSE mg.zsgrp_des
        END AS materialName,
        SUM(sm.zdtargetQty) AS TotalTarget,
        SUM(sm.zdqty) AS TotalAchievement
      FROM tblsales_month sm
      INNER JOIN tblmat_group mg 
        ON sm.zsmat_grp = mg.zsmat_grp
      WHERE sm.zsdelcode = ? 
        AND LEFT(sm.zsmonth, 4) = (
          SELECT LEFT(MAX(zsmonth), 4) 
          FROM tblsales_month 
          WHERE zsdelcode = ?
        )
        AND sm.zsmat_grp IN (${allowedGroups.map(() => '?').join(',')})
      GROUP BY MaterialGroup, materialName
    )
    SELECT 
      MaterialGroup, 
      materialName, 
      GREATEST(TotalTarget, 0) AS TotalTarget,
      GREATEST(TotalAchievement, 0) AS TotalAchievement
    FROM YearlyData
    ORDER BY 
      CASE 
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
      console.error('Error fetching material group performance for the latest year:', err.message);
      return res.status(500).json({ message: 'Server error', error: err.message });
    }

    const materialGroupCount = results.length;

    res.status(200).json({
      message: materialGroupCount === 0 
        ? 'No material group performance data found for the latest year' 
        : 'Material group performance data fetched successfully for the latest year',
      materialGroupCount,
      data: results,
    });
  });
};
