const express = require('express');
const router = express.Router();
const dispatchController = require('../controllers/dispatchController');

// Route for fetching dispatch history
router.get('/dispatch-history/:zsDelCode', dispatchController.getDispatchHistory);


// New route for searching dispatch history
router.post('/search-dispatch-history', dispatchController.searchDispatchHistory);


// New route for searching dispatch no history
router.post('/search-dispatch-number', dispatchController.searchDispatchByNo);


// New route for searching dispatch history status
router.post('/search-dispatch-status', dispatchController.searchDispatchStatus);

// New route for searching material description
router.post('/search-material', dispatchController.searchMaterialDescription);

router.get('/material-list', dispatchController.getMaterialDes);
module.exports = router;
