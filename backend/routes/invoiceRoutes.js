const express = require('express');
const router = express.Router();
const invoiceController = require('../controllers/invoiceController');


router.get('/due-invoices/:zsDelCode', invoiceController.getDueInvoices);

module.exports = router;
