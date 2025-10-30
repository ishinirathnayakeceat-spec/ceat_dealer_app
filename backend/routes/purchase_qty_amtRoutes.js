
const express = require('express');
const router = express.Router();
const purchaseQtyController = require('../controllers/purchase_qtyController');
const purchaseAmtController = require('../controllers/purchase_amtController');



router.get('/purchase-qty/:zsDelCode', purchaseQtyController.getPurchaseQtyDetails);
router.post('/purchase-qty', purchaseQtyController.getPurchaseQtyBySearch);



router.get('/purchase-amt/:zsDelCode', purchaseAmtController.getPurchaseAmtDetails);
router.post('/purchase-amt', purchaseAmtController.getPurchaseAmtBySearch);



module.exports = router;
