const express = require('express');
const router = express.Router();
const target_monthController = require('../controllers/target_monthController');
const target_yearController = require('../controllers/target_yearController');

router.get('/material-performance/:zsDelCode', target_monthController.getMaterialGroupPerformance);
router.get('/target-year/:zsDelCode', target_yearController.getMaterialGroupPerformanceYear);

module.exports = router;
