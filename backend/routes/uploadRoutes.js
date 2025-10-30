const express = require('express');
const multer = require('multer');
const path = require('path');
const { uploadImages } = require('../controllers/uploadController'); // Ensure this is correct
const router = express.Router();

// Configure Multer for file storage
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, path.join(__dirname, '../uploads')); // Use a local directory instead
    },
    filename: (req, file, cb) => {
        cb(null, file.fieldname + '-' + Date.now() + path.extname(file.originalname));
    }
});

// File filter to allow only images
const fileFilter = (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/jpg', 'image/webp'];
    if (allowedTypes.includes(file.mimetype)) {
        cb(null, true);
    } else {
        cb(new Error('Only images (JPEG, PNG, JPG, WEBP) are allowed'), false);
    }
};

const upload = multer({
    storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // Limit file size to 5MB
    fileFilter
});

// Allow multiple images with text fields
const uploadFields = upload.fields([
    { name: 'images', maxCount: 5 },
    { name: 'zsDelCode', maxCount: 1 },
    { name: 'tyre_size', maxCount: 1 },
    { name: 'tyre_serial_number', maxCount: 1 },
    { name: 'estimated_non_skid_depth', maxCount: 1 },
    { name: 'defect_type', maxCount: 1 }
]);

// Route for uploading images
router.post('/upload', uploadFields, uploadImages);

module.exports = router;
