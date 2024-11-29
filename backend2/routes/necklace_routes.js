const express = require("express");
const {
  getNecklaceData,
  addNecklace,
} = require("../controllers/necklace_controller");

const router = express.Router();

// Route to get necklace data by ID
router.get("/:idNecklace", getNecklaceData);

// Route to add a new necklace entry
router.post("/", addNecklace);

module.exports = router;
