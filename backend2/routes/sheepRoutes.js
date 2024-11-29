const express = require('express');
const router = express.Router();
const {
  addSheep,
  getAllSheep,
  getSheepById,
  updateSheep,
  deleteSheep,
} = require('../controllers/sheepController');

router.post('/', addSheep);

router.get('/', getAllSheep);


router.get('/:id', getSheepById);

router.put('/:id', updateSheep);

router.delete('/:id', deleteSheep);

module.exports = router;
