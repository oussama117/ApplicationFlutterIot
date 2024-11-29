// models/necklace.js
const mongoose = require("mongoose");

const necklaceSchema = new mongoose.Schema({
  idNecklace: { type: String, required: true },
  data: [
    {
      time: { type: Number, required: true },
      acc: { type: Number, required: true },
      gyr: { type: Number, required: true },
      temp: { type: Number, required: true },
      pulse: { type: Number, required: true },
    },
  ],
});

module.exports = mongoose.model("necklaceData", necklaceSchema);
