const db = require('../models/db');


exports.getPurchaseVolume = (req, res) => {
  const { zsDelCode } = req.params;

  
  const totalQuery = `
    SELECT 
        zsmonth,
        SUM(zdqty) AS total_quantity,
        SUM(zdamount) AS total_amount
    FROM tblsales_month
    WHERE zsdelcode = ?
    GROUP BY zsmonth
    ORDER BY zsmonth DESC
    LIMIT 3
  `;

  
  const materialGroupQuery = `
    SELECT 
        sm.zsmonth,
        sm.zsmat_grp,
        mg.zsgrp_des AS material_name,
        SUM(sm.zdqty) AS group_quantity,
        SUM(sm.zdamount) AS group_amount
    FROM tblsales_month sm
    JOIN tblmat_group mg 
        ON sm.zsmat_grp = mg.zsmat_grp
    WHERE sm.zsdelcode = ?
    GROUP BY sm.zsmonth, sm.zsmat_grp, mg.zsgrp_des
    ORDER BY sm.zsmonth DESC, sm.zsmat_grp ASC
  `;

  
  const subMaterialGroupQuery = `
    SELECT 
        sm.zsmonth,
        sm.zsmat_grp,
        sm.zsmat_num,
        m.zsmat_des AS sub_material_name,
        SUM(sm.zdqty) AS sub_group_quantity,
        SUM(sm.zdamount) AS sub_group_amount
    FROM tblsales_month sm
    JOIN tblmaterial m 
        ON sm.zsmat_num = m.zsmat_num
    WHERE sm.zsdelcode = ?
    GROUP BY sm.zsmonth, sm.zsmat_grp, sm.zsmat_num, m.zsmat_des
    ORDER BY sm.zsmonth DESC, sm.zsmat_grp ASC, sm.zsmat_num ASC
  `;

  db.query(totalQuery, [zsDelCode], (err, totalResults) => {
    if (err) {
      console.error('Error fetching total purchase volume:', err.message);
      return res.status(500).json({ message: 'Server error', error: err.message });
    }

    db.query(materialGroupQuery, [zsDelCode], (err, materialGroupResults) => {
      if (err) {
        console.error('Error fetching material group data:', err.message);
        return res.status(500).json({ message: 'Server error', error: err.message });
      }

      db.query(subMaterialGroupQuery, [zsDelCode], (err, subMaterialGroupResults) => {
        if (err) {
          console.error('Error fetching sub-material group data:', err.message);
          return res.status(500).json({ message: 'Server error', error: err.message });
        }

       
        const groupedData = totalResults.map((total) => {
          return {
            zsmonth: total.zsmonth,
            totalQuantity: total.total_quantity,
            totalAmount: total.total_amount,
            materialGroups: materialGroupResults
              .filter((mg) => mg.zsmonth === total.zsmonth)
              .map((mg) => ({
                materialGroup: mg.zsmat_grp,
                materialName: mg.material_name,
                groupQuantity: mg.group_quantity,
                groupAmount: mg.group_amount,
                subMaterials: subMaterialGroupResults
                  .filter(
                    (smg) =>
                      smg.zsmonth === mg.zsmonth && smg.zsmat_grp === mg.zsmat_grp
                  )
                  .map((smg) => ({
                    subMaterialGroup: smg.zsmat_num,
                    subMaterialName: smg.sub_material_name,
                    subGroupQuantity: smg.sub_group_quantity,
                    subGroupAmount: smg.sub_group_amount,
                  })),
              })),
          };
        });

        res.status(200).json({
          message: 'Purchase volume data fetched successfully',
          data: groupedData,
        });
      });
    });
  });
};



exports.getPurchaseVolumeByYearMonth = (req, res) => {
  
  const { zsDelCode, selectedYear, selectedMonth } = req.body; 


 
  const totalQuery = `
    SELECT 
        zsmonth,
        SUM(zdqty) AS total_quantity,
        SUM(zdamount) AS total_amount
    FROM tblsales_month
    WHERE zsdelcode = ? 
      AND zsmonth = CONCAT(?, LPAD(?, 2, '0')) 
    GROUP BY zsmonth
    ORDER BY zsmonth DESC
  `;

 
  const materialGroupQuery = `
    SELECT 
        sm.zsmonth,
        sm.zsmat_grp,
        mg.zsgrp_des AS material_name,
        SUM(sm.zdqty) AS group_quantity,
        SUM(sm.zdamount) AS group_amount
    FROM tblsales_month sm
    JOIN tblmat_group mg 
        ON sm.zsmat_grp = mg.zsmat_grp
    WHERE sm.zsdelcode = ? 
      AND zsmonth = CONCAT(?, LPAD(?, 2, '0')) 
    GROUP BY sm.zsmonth, sm.zsmat_grp, mg.zsgrp_des
    ORDER BY sm.zsmonth DESC, sm.zsmat_grp ASC
  `;

 
  const subMaterialGroupQuery = `
    SELECT 
        sm.zsmonth,
        sm.zsmat_grp,
        sm.zsmat_num,
        m.zsmat_des AS sub_material_name,
        SUM(sm.zdqty) AS sub_group_quantity,
        SUM(sm.zdamount) AS sub_group_amount
    FROM tblsales_month sm
    JOIN tblmaterial m 
        ON sm.zsmat_num = m.zsmat_num
    WHERE sm.zsdelcode = ? 
      AND zsmonth = CONCAT(?, LPAD(?, 2, '0')) 
    GROUP BY sm.zsmonth, sm.zsmat_grp, sm.zsmat_num, m.zsmat_des
    ORDER BY sm.zsmonth DESC, sm.zsmat_grp ASC, sm.zsmat_num ASC
  `;

  // Execute queries
  db.query(
    totalQuery,
    [zsDelCode, selectedYear, selectedMonth],
    (err, totalResults) => {
      if (err) {
        console.error('Error fetching total purchase volume:', err.message);
        return res
          .status(500)
          .json({ message: 'Server error', error: err.message });
      }

      db.query(
        materialGroupQuery,
        [zsDelCode, selectedYear, selectedMonth],
        (err, materialGroupResults) => {
          if (err) {
            console.error('Error fetching material group data:', err.message);
            return res
              .status(500)
              .json({ message: 'Server error', error: err.message });
          }

          db.query(
            subMaterialGroupQuery,
            [zsDelCode, selectedYear, selectedMonth],
            (err, subMaterialGroupResults) => {
              if (err) {
                console.error(
                  'Error fetching sub-material group data:',
                  err.message
                );
                return res
                  .status(500)
                  .json({ message: 'Server error', error: err.message });
              }

              
              const groupedData = totalResults.map((total) => {
                return {
                  zsmonth: total.zsmonth,
                  totalQuantity: total.total_quantity,
                  totalAmount: total.total_amount,
                  materialGroups: materialGroupResults
                    .filter((mg) => mg.zsmonth === total.zsmonth)
                    .map((mg) => ({
                      materialGroup: mg.zsmat_grp,
                      materialName: mg.material_name,
                      groupQuantity: mg.group_quantity,
                      groupAmount: mg.group_amount,
                      subMaterials: subMaterialGroupResults
                        .filter(
                          (smg) =>
                            smg.zsmonth === mg.zsmonth &&
                            smg.zsmat_grp === mg.zsmat_grp
                        )
                        .map((smg) => ({
                          subMaterialGroup: smg.zsmat_num,
                          subMaterialName: smg.sub_material_name,
                          subGroupQuantity: smg.sub_group_quantity,
                          subGroupAmount: smg.sub_group_amount,
                        })),
                    })),
                };
              });

              res.status(200).json({
                message: 'Purchase volume data for the selected year & month fetched successfully',
                data: groupedData,
              });
            }
          );
        }
      );
    }
  );
};

