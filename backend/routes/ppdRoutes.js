const express = require('express');
const router = express.Router();
const ppdController = require('../controllers/ppdController');


router.post('/getPPDDetailsAndSummary', ppdController.getPPDDetailsAndSummary);


module.exports = router;