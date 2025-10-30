const db = require("../models/db");

// Get claim request history by zsDelCode
exports.getClaimRequestHistory = (req, res) => {
  const { zsDelCode } = req.params;

  if (!zsDelCode) {
    return res.status(400).json({ message: "zsDelCode is required." });
  }

  // Query to fetch claim request summary (tyre records)
  const query = `
    SELECT 
      tr.id AS tyre_id,
      tr.zsDelCode,
      tr.tyre_size,
      tr.tyre_serial_number,
      tr.estimated_non_skid_depth,
      tr.defect_type,
      DATE_FORMAT(tr.created_at, '%Y-%m-%d') AS tyre_created_at
    FROM tyre_records tr
    WHERE tr.zsDelCode = ?
    ORDER BY tr.created_at DESC
    LIMIT 5;
  `;

  // Query to fetch detailed claim records (images) by tyre_id and zsDelCode
  const detailsQuery = `
    SELECT 
      tr.id AS tyre_id,
      tr.zsDelCode,
      tr.tyre_size,
      tr.tyre_serial_number,
      tr.estimated_non_skid_depth,
      tr.defect_type,
      DATE_FORMAT(tr.created_at, '%Y-%m-%d') AS tyre_created_at,
      ti.id AS image_id,
      ti.filename,
      ti.filepath
    FROM tyre_records tr
    LEFT JOIN images ti ON tr.id = ti.tyre_record_id
    WHERE tr.zsDelCode = ? AND tr.id = ?
    ORDER BY tr.created_at DESC;
  `;

  db.query(query, [zsDelCode], (err, results) => {
    if (err) {
      console.error("Error fetching claim request summary:", err.message);
      return res.status(500).json({ 
        message: "Server error while fetching claim request summary", 
        error: err.message 
      });
    }

    if (results.length === 0) {
      return res.status(200).json({
        message: "No claim requests found",
        ClaimRequests: [],
      });
    }

    const BASE_URL = "http://20.33.35.180/ceat_dealer_app/backend/uploads";

    // Process each tyre record to fetch associated images
    const groupedData = results.map((tyre) => {
      return new Promise((resolve, reject) => {
        db.query(detailsQuery, [tyre.zsDelCode, tyre.tyre_id], (err, imageDetails) => {
          if (err) {
            reject(err);
          } else {
            resolve({
              tyre_id: tyre.tyre_id,
              zsDelCode: tyre.zsDelCode,
              tyre_size: tyre.tyre_size,
              tyre_serial_number: tyre.tyre_serial_number,
              estimated_non_skid_depth: tyre.estimated_non_skid_depth,
              defect_type: tyre.defect_type,
              tyre_created_at: tyre.tyre_created_at,
            
              images: imageDetails.map((img) => ({
                image_id: img.image_id,
                filename: img.filename,
                filepath: `${BASE_URL}/${img.filename}`, // ✅ Ensures correct URL format
              })),
              
            });
          }
        });
      });
    });

    Promise.all(groupedData)
      .then((results) => {
        res.status(200).json({
          message: "Claim request history fetched successfully",
          ClaimRequests: results,
        });
      })
      .catch((error) => {
        console.error("Error processing claim request details:", error.message);
        res.status(500).json({ 
          message: "Server error while processing claim request details", 
          error: error.message 
        });
      });
  });
};
