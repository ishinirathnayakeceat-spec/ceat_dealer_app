const db = require("../models/db");
const db1 = require("../models/dispatchdb");

exports.getDispatchHistory = (req, res) => {
  const { zsDelCode } = req.params; // Extract zsDelCode from request params

  if (!zsDelCode) {
    return res.status(400).json({ message: "zsDelCode is required." });
  }

  // Query to fetch dispatch summary
  const query = `
    SELECT 
        dispatch_no, 
        invoice_date, 
        status, 
        CASE 
          WHEN status = '' THEN 'Goods On the way' 
          ELSE 'Delivered' 
        END AS dispStatus, 
        DATE_FORMAT(delivery_date, '%Y-%m-%d') AS delivery_date, 
        invoice_no
    FROM dispatch_item 
    WHERE dealer_code = ? 
    GROUP BY dispatch_no 
    ORDER BY dispatch_no DESC 
    LIMIT 5;
  `;

  // Query to fetch detailed dispatch records by dispatch_no and dealer_code
  const detailsQuery = `
    SELECT 
        a.dispatch_no, 
        a.invoice_no, 
        a.invoice_date, 
        a.product_code, 
        b.description, 
        a.quantity, 
        a.delivery_date 
    FROM dispatch_item AS a 
    INNER JOIN maradata AS b ON a.product_code = b.product_code
    WHERE a.dispatch_no = ? AND a.dealer_code = ? 
    ORDER BY a.invoice_no DESC;
  `;

  db1.query(query, [zsDelCode], (err, results) => {
    if (err) {
      console.error("Error fetching dispatch summary:", err.message);
      return res.status(500).json({ message: "Server error while fetching dispatch summary", error: err.message });
    }

    if (results.length === 0) {
      return res.status(200).json({
        message: "No dispatch found",
        DispatchSummary: [],
      });
    }

    // Process each summary to fetch its associated details
    const groupedData = results.map((summary) => {
      // Log the dispatch status to the console
     // console.log(`Dispatch No: ${summary.dispatch_no}, Status: ${summary.dispStatus}`);
      
      return new Promise((resolve, reject) => {
        // Fetch details for each dispatch_no while matching zsDelCode with dealer_code
        db1.query(detailsQuery, [summary.dispatch_no, zsDelCode], (err, dispatchDetails) => {
          if (err) {
            reject(err);
          } else {
            resolve({
              dispatch_no: summary.dispatch_no,
              invoice_date: summary.invoice_date,
              status: summary.dispStatus, // Use dispStatus from the SQL query
              delivery_date: summary.delivery_date,
              invoice_no: summary.invoice_no,
              dispatchDetails: dispatchDetails.map((detail) => ({
                invoice_no: detail.invoice_no,
                invoice_date: detail.invoice_date,
                description: detail.description,
                product_code: detail.product_code,
                quantity: detail.quantity,
                delivery_date: detail.delivery_date,
              })),
            });
          }
        });
      });
    });

    // Resolve all promises to return a grouped hierarchical structure
    Promise.all(groupedData)
      .then((results) => {
        res.status(200).json({
          message: "Dispatch details fetched successfully",
          DispatchSummary: results,
        });
      })
      .catch((error) => {
        console.error("Error processing dispatch details:", error.message);
        res.status(500).json({ message: "Server error while processing dispatch details", error: error.message });
      });
  });
};

exports.searchDispatchHistory = (req, res) => {
  const { zsDelCode, dispatch_no, fromDate, toDate } = req.body; // Request body

  // Query to fetch dispatch summary with delivery date filtering (DATE only)
  const summaryQuery = `
   SELECT 
        dispatch_no, 
        invoice_date, 
        status, 
        CASE 
          WHEN status = '' THEN 'Goods On the way' 
          ELSE 'Delivered' 
        END AS status, 
        DATE_FORMAT(delivery_date, '%Y-%m-%d') AS delivery_date, 
        invoice_no
    FROM dispatch_item 
    WHERE dealer_code = ? 
      AND (? IS NULL OR dispatch_no = ?) 
      AND (? IS NULL OR DATE(delivery_date) >= ?) 
      AND (? IS NULL OR DATE(delivery_date) <= ?)
    GROUP BY dispatch_no 
    ORDER BY dispatch_no DESC 
  `;

  // Execute query
  db1.query(
    summaryQuery,
    [zsDelCode, dispatch_no, dispatch_no, fromDate, fromDate, toDate, toDate],
    (err, DispatchSummary) => {
      if (err) {
        console.error('Error fetching dispatch summary:', err.message);
        return res.status(500).json({ message: 'Server error', error: err.message });
      }

      if (DispatchSummary.length === 0) {
        return res.status(200).json({
          message: 'No dispatch found for the provided Dispatch No and Date range',
          DispatchSummary: [],
        });
      }

      // Fetch claim details for each group with delivery date filtering
      const detailsQuery = `
          SELECT 
            a.dispatch_no, 
            a.invoice_no, 
            a.invoice_date, 
            a.product_code, 
            b.description, 
            a.quantity, 
            a.delivery_date 
          FROM dispatch_item AS a 
          INNER JOIN maradata AS b ON a.product_code = b.product_code
          WHERE a.dealer_code = ? 
            AND a.dispatch_no = ? 
            AND (? IS NULL OR DATE(a.delivery_date) >= ?) 
            AND (? IS NULL OR DATE(a.delivery_date) <= ?)
          ORDER BY a.invoice_no DESC
      `;

      const promises = DispatchSummary.map((dispatch) => {
        return new Promise((resolve, reject) => {
          db1.query(
            detailsQuery,
            [zsDelCode, dispatch.dispatch_no, fromDate, fromDate, toDate, toDate],
            (err, dispatchDetails) => {
              if (err) {
                reject(err);
              } else {
                resolve({ ...dispatch, dispatchDetails });
              }
            }
          );
        });
      });

      Promise.all(promises)
        .then((results) => {
          res.status(200).json({
            message: 'Dispatch details fetched successfully',
            DispatchSummary: results,
          });
        })
        .catch((err) => {
          console.error('Error fetching dispatch details:', err.message);
          res.status(500).json({ message: 'Server error', error: err.message });
        });
    }
  );
};



// search for Dispatch No

exports.searchDispatchByNo = (req, res) => {
  const { zsDelCode, dispatch_no} = req.body; // Request body

  // Query to fetch claim summary with delivery date filtering (DATE only)
  const summaryQuery = `
   SELECT 
        dispatch_no, 
        invoice_date, 
        status, 
        CASE 
          WHEN status = '' THEN 'Goods On the way' 
          ELSE 'Delivered' 
        END AS status, 
        DATE_FORMAT(delivery_date, '%Y-%m-%d') AS delivery_date, 
        invoice_no
    FROM dispatch_item 
    WHERE dealer_code = ? 
      AND (? IS NULL OR dispatch_no = ?) 
    GROUP BY dispatch_no 
    ORDER BY dispatch_no DESC 
  `;

  // Execute query
  db1.query(
    summaryQuery,
    [zsDelCode, dispatch_no, dispatch_no],
    (err, DispatchSummary) => {
      if (err) {
        console.error('Error fetching dispatch summary:', err.message);
        return res.status(500).json({ message: 'Server error', error: err.message });
      }

      if (DispatchSummary.length === 0) {
        return res.status(200).json({
          message: 'No dispatch found for the provided Dispatch No and Date range',
          DispatchSummary: [],
        });
      }

      // Fetch claim details for each group with delivery date filtering
      const detailsQuery = `
          SELECT 
            a.dispatch_no, 
            a.invoice_no, 
            a.invoice_date, 
            a.product_code, 
            b.description, 
            a.quantity, 
            a.delivery_date 
          FROM dispatch_item AS a 
          INNER JOIN maradata AS b ON a.product_code = b.product_code
          WHERE a.dealer_code = ? 
            AND a.dispatch_no = ? 
          ORDER BY a.invoice_no DESC
      `;

      const promises = DispatchSummary.map((dispatch) => {
        return new Promise((resolve, reject) => {
          db1.query(
            detailsQuery,
            [zsDelCode, dispatch.dispatch_no],
            (err, dispatchDetails) => {
              if (err) {
                reject(err);
              } else {
                resolve({ ...dispatch, dispatchDetails });
              }
            }
          );
        });
      });

      Promise.all(promises)
        .then((results) => {
          res.status(200).json({
            message: 'Dispatch details fetched successfully',
            DispatchSummary: results,
          });
        })
        .catch((err) => {
          console.error('Error fetching dispatch details:', err.message);
          res.status(500).json({ message: 'Server error', error: err.message });
        });
    }
  );
};

//search by status and date range
exports.searchDispatchStatus = (req, res) => {
  const { zsDelCode, status, fromDate, toDate } = req.body;

  // Convert status input to database values
  let dbStatus = null;
  if (status === "Delivered") {
    dbStatus = "L"; // In the database, "Delivered" is stored as 'L'
  } else if (status === "Goods On the way") {
    dbStatus = ""; // Empty string represents "Goods On the way"
  }

  // Query to fetch dispatch summary with correct status mapping
  const summaryQuery = `
    SELECT 
        dispatch_no, 
        invoice_date, 
        status, 
        CASE 
          WHEN TRIM(status) = '' THEN 'Goods On the way' 
          ELSE 'Delivered' 
        END AS status, 
        DATE_FORMAT(delivery_date, '%Y-%m-%d') AS delivery_date, 
        invoice_no
    FROM dispatch_item 
    WHERE dealer_code = ? 
      AND (? IS NULL OR TRIM(status) = ?) 
      AND (? IS NULL OR (delivery_date IS NOT NULL AND DATE(delivery_date) >= ?)) 
      AND (? IS NULL OR (delivery_date IS NOT NULL AND DATE(delivery_date) <= ?))
    ORDER BY dispatch_no DESC 
  `;

  db1.query(
    summaryQuery,
    [zsDelCode, dbStatus, dbStatus, fromDate || null, fromDate || null, toDate || null, toDate || null],
    (err, DispatchSummary) => {
      if (err) {
        console.error("Error fetching dispatch summary:", err.message);
        return res.status(500).json({ message: "Server error", error: err.message });
      }

      if (DispatchSummary.length === 0) {
        return res.status(200).json({
          message: "No dispatch found for the provided Dispatch status and Date range",
          DispatchSummary: [],
        });
      }

      // Fetch details in a single query using dispatch_no list
      const dispatchNos = DispatchSummary.map(d => d.dispatch_no);
      if (dispatchNos.length === 0) {
        return res.status(200).json({
          message: "Dispatch details fetched successfully",
          DispatchSummary,
        });
      }

      const detailsQuery = `
          SELECT 
            a.dispatch_no, 
            a.invoice_no, 
            a.invoice_date, 
            a.product_code, 
            b.description, 
            a.quantity, 
            DATE_FORMAT(a.delivery_date, '%Y-%m-%d') AS delivery_date 
          FROM dispatch_item AS a 
          INNER JOIN maradata AS b ON a.product_code = b.product_code
          WHERE a.dispatch_no IN (${dispatchNos.map(() => "?").join(",")})
          ORDER BY a.invoice_no DESC
      `;

      db1.query(detailsQuery, dispatchNos, (err, dispatchDetails) => {
        if (err) {
          console.error("Error fetching dispatch details:", err.message);
          return res.status(500).json({ message: "Server error", error: err.message });
        }

        // Group dispatch details under each dispatch_no
        const dispatchMap = {};
        DispatchSummary.forEach(dispatch => {
          dispatchMap[dispatch.dispatch_no] = { ...dispatch, dispatchDetails: [] };
        });

        dispatchDetails.forEach(detail => {
          if (dispatchMap[detail.dispatch_no]) {
            dispatchMap[detail.dispatch_no].dispatchDetails.push(detail);
          }
        });

        res.status(200).json({
          message: "Dispatch details fetched successfully",
          DispatchSummary: Object.values(dispatchMap),
        });
      });
    }
  );
};

// get data for dropdown
exports.getMaterialDes = (req, res) => {
  const query = 'SELECT * FROM maradata';

  db1.query(query, (err, results) => {
    if (err) {
      console.error('Error fetching material:', err.message);
      return res.status(500).json({ message: 'Server error', error: err.message });
    }

    if (results.length === 0) {
      return res.status(404).json({ message: 'No materials found' });
    }

    res.status(200).json({ materials: results });
  });
};



// search by material des

exports.searchMaterialDescription = async (req, res) => {
  try {
    const { zsDelCode, description } = req.body;

    if (!zsDelCode || !description) {
      return res.status(400).json({ message: 'Missing required parameters' });
    }

    // Query to fetch dispatch summary based on dealer code and description
    const summaryQuery = `
      SELECT 
          a.dispatch_no, 
          a.invoice_no, 
          DATE_FORMAT(a.invoice_date, '%Y-%m-%d') AS invoice_date, 
          a.product_code, 
          b.description, 
          a.quantity,
          a.status, 
        CASE 
          WHEN TRIM(status) = '' THEN 'Goods On the way' 
          ELSE 'Delivered' 
        END AS status, 
          DATE_FORMAT(a.delivery_date, '%Y-%m-%d') AS delivery_date
      FROM dispatch_item AS a 
      INNER JOIN maradata AS b ON a.product_code = b.product_code
      WHERE a.dealer_code = ? 
        AND b.description LIKE ?  ORDER BY a.delivery_date DESC;
    `;

    // Fetch summary
    const DispatchSummary = await new Promise((resolve, reject) => {
      db1.query(summaryQuery, [zsDelCode, `%${description}%`], (err, results) => {
        if (err) {
          reject(err);
        } else {
          resolve(results);
        }
      });
    });

    if (DispatchSummary.length === 0) {
      return res.status(200).json({
        message: 'No dispatch records found',
        DispatchSummary: [],
      });
    }

    // Fetch dispatch details for each dispatch_no
    const detailsQuery = `
      SELECT 
          a.dispatch_no, 
          a.product_code, 
          a.invoice_no, 
          a.invoice_date,
          b.description, 
          a.quantity
      FROM dispatch_item AS a 
      INNER JOIN maradata AS b ON a.product_code = b.product_code
      WHERE a.dealer_code = ? 
        AND a.dispatch_no = ?;
    `;

    for (const dispatch of DispatchSummary) {
      const dispatchDetails = await new Promise((resolve, reject) => {
        db1.query(detailsQuery, [zsDelCode, dispatch.dispatch_no], (err, details) => {
          if (err) {
            reject(err);
          } else {
            resolve(details);
          }
        });
      });

      dispatch.dispatchDetails = dispatchDetails;
    }

    return res.status(200).json({
      message: 'Dispatch details fetched successfully',
      DispatchSummary,
    });
  } catch (error) {
    console.error('Error fetching dispatch details:', error.message);
    return res.status(500).json({ message: 'Server error', error: error.message });
  }
};

