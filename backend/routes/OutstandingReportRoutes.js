const express = require('express');
const router = express.Router();
const outstandingReportController = require('../controllers/OutstandingReportControllers');


router.post('/outstanding-reports', outstandingReportController.getOutstandingReports);

module.exports = router;