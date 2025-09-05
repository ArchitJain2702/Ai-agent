import express from 'express';
const router = express.Router();
const RecomendationController = require('../controllers/recomendation');
router.post('/get-recomendation',RecomendationController.getRecomendation);

module.exports = router;