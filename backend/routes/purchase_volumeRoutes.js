const express = require('express');
const router = express.Router();
const purchase_volume_detailsController = require('../controllers/purchase_volume_detailsController');


router.get('/purchase-volume/:zsDelCode', purchase_volume_detailsController.getPurchaseVolume);
router.post('/purchase-volume', purchase_volume_detailsController.getPurchaseVolumeByYearMonth);

module.exports = router;
