const express = require('express');
const router = express.Router();
const claimRequestController = require('../controllers/claimRequestController');

router.get('/claimrequest-history/:zsDelCode', claimRequestController.getClaimRequestHistory);

module.exports = router;
