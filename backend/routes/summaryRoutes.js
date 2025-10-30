
const express = require('express');
const router = express.Router();
const SummaryController = require('../controllers/SummaryController');

router.get('/summary/:zsDelCode', SummaryController.getSummaryDetails);
router.get('/chequeReceived/:zsDelCode', SummaryController.getTotalChequesReceived);

module.exports = router;
