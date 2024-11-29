const Necklace = require("../models/necklace_model");

// Controller to get necklace data by idNecklace
const getNecklaceData = async (req, res) => {
  const { idNecklace } = req.params;

  try {
    const necklace = await Necklace.findOne({ idNecklace });
    if (!necklace) {
      return res.status(404).json({ message: "Necklace not found" });
    }
    res.status(200).json(necklace);
  } catch (error) {
    res.status(500).json({ message: "Error fetching necklace data", error });
  }
};

// Controller to add a new necklace entry or update existing
const addNecklace = async (req, res) => {
  const { idNecklace, data } = req.body;

  if (!idNecklace || !data || !Array.isArray(data)) {
    return res.status(400).json({ message: "Invalid request body" });
  }

  try {
    const necklace = await Necklace.findOne({ idNecklace });

    if (necklace) {
      // Append new data to the existing necklace document
      necklace.data.push(...data);
      await necklace.save();
    } else {
      // Create a new necklace document
      await Necklace.create({ idNecklace, data });
    }

    res.status(200).json({ message: "Data added successfully" });
  } catch (error) {
    res.status(500).json({ message: "Error adding data", error });
  }
};

module.exports = {
  getNecklaceData,
  addNecklace,
};
