const db = require("../models/db");
const path = require('path');



exports.uploadImages = (req, res) => {
    try {
        if (!req.files || !req.files['images'] || req.files['images'].length === 0) {
            return res.status(400).json({ message: 'No images uploaded' });
        }

        // Get form data
        const { zsDelCode, tyre_size, tyre_serial_number, estimated_non_skid_depth, defect_type } = req.body;

        if (!zsDelCode || !tyre_size || !tyre_serial_number || !estimated_non_skid_depth || !defect_type) {
            return res.status(400).json({ message: 'All tyre details are required' });
        }

        // Insert tyre record first
        const tyreSql = `INSERT INTO tyre_records (zsDelCode, tyre_size, tyre_serial_number, estimated_non_skid_depth, defect_type) 
                         VALUES (?, ?, ?, ?, ?)`;

        db.query(tyreSql, [zsDelCode, tyre_size, tyre_serial_number, estimated_non_skid_depth, defect_type], (err, result) => {
            if (err) {
                console.error(err);
                return res.status(500).json({ message: 'Database error' });
            }

            const tyreRecordId = result.insertId;

            // Base URL for uploaded images
            const baseURL = 'http://20.33.35.180/ceat_dealer_app/uploads/';

            // Insert images
            const imageSql = `INSERT INTO images (tyre_record_id, filename, filepath) VALUES ?`;
            const imageValues = req.files['images'].map(file => [
                tyreRecordId,
                file.filename,
                `${baseURL}${file.filename}`  // Correct way to store file URL
            ]);

            db.query(imageSql, [imageValues], (err) => {
                if (err) {
                    console.error(err);
                    return res.status(500).json({ message: 'Error saving images' });
                }

                res.json({
                    message: 'Tyre record and images uploaded successfully',
                    tyreRecordId,
                    images: req.files['images'].map(file => ({
                        filename: file.filename,
                        path: `${baseURL}${file.filename}` // Return correct image URL
                    }))
                });
            });
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};



