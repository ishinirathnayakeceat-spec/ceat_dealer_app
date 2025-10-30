const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profileController');


router.get('/profile/:zsDelCode', profileController.getProfileDetails);

module.exports = router;
