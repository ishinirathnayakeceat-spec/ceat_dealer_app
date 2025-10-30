
const express = require('express');
const router = express.Router();
const claimController = require('../controllers/claimController');


router.get('/claims/:zsDelCode', claimController.getClaimDetails);


router.post('/claims/filter', claimController.getClaimDetailsByDateAndDocket);


router.post('/claims/filter-by-docketNo', claimController.getClaimDetailsByDocket);


router.post('/claims/filter-by-dateRange', claimController.getClaimDetailsByDateRange);





module.exports = router;
