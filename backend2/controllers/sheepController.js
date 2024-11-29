const Sheep = require('../models/sheep');


const addSheep = async (req, res) => {
  const {  necklaceID, age, race, healthStatus, weight, vaccinated } = req.body;

  // Check if all required fields are provided
  if (! necklaceID || !age || !race || !healthStatus || !weight) {
    return res.status(400).json({ message: 'Please provide all required fields' });
  }

  try {
    // Create a new sheep
    const newSheep = new Sheep({
        necklaceID,
      age,
      race,
      healthStatus,
      weight,
      vaccinated,
    });

    // Save the sheep to the database
    await newSheep.save();

    res.status(201).json({
      message: 'Sheep added successfully!',
      sheep: newSheep,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};


const getAllSheep = async (req, res) => {
  try {
    const sheepList = await Sheep.find(); // Fetch all sheep from DB
    res.status(200).json(sheepList);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};


const getSheepById = async (req, res) => {
  const { id } = req.params;

  try {
    const sheep = await Sheep.findById(id);
    
    if (!sheep) {
      return res.status(404).json({ message: 'Sheep not found' });
    }

    res.status(200).json(sheep);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};


const updateSheep = async (req, res) => {
  const { id } = req.params;
  const {  necklaceID, age, race, healthStatus, weight, vaccinated } = req.body;

  try {
    const updatedSheep = await Sheep.findByIdAndUpdate(
      id,
      {
        necklaceID,
        age,
        race,
        healthStatus,
        weight,
        vaccinated,
      },
      { new: true }
    );

    if (!updatedSheep) {
      return res.status(404).json({ message: 'Sheep not found' });
    }

    res.status(200).json({
      message: 'Sheep updated successfully!',
      sheep: updatedSheep,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};


const deleteSheep = async (req, res) => {
  const { id } = req.params;

  try {
    const sheep = await Sheep.findByIdAndDelete(id);

    if (!sheep) {
      return res.status(404).json({ message: 'Sheep not found' });
    }

    res.status(200).json({ message: 'Sheep deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

module.exports = {
  addSheep,
  getAllSheep,
  getSheepById,
  updateSheep,
  deleteSheep,
};
