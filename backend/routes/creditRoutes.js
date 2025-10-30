const express = require('express');
const router = express.Router();
const creditController = require('../controllers/creditController');

router.get('/credit-limit/:zsDelCode', creditController.getCreditLimit);

module.exports = router;