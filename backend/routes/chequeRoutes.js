const express = require('express');
const chequeController = require('../controllers/chequeController');

const router = express.Router();

router.get('/cheques', chequeController.getCheques);

module.exports = router;