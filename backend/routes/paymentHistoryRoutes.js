const express = require('express');
const router = express.Router();
const paymentHistoryController = require('../controllers/paymentHistoryControllers');


router.get('/payment-history/:zsDelCode', paymentHistoryController.getPaymentHistory);



router.post('/search-payment-history', paymentHistoryController.searchPaymentHistory);

module.exports = router;
