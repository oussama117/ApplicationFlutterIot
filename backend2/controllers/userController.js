const User = require('../models/User');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

const loginUser = async (req, res) => {
  const { email, password } = req.body;
  const user = await User.findOne({ email });

  if (user && (await bcrypt.compare(password, user.password))) {
    const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, {
      expiresIn: '30d',
    });
    res.json({ id: user._id, role: user.role, token });
  } else {
    res.status(401).json({ message: 'Invalid credentials' });
  }
};

const addUser = async (req, res) => {
  const { name, lastName, email, password, role } = req.body;

  try {
    const user = new User({ name, lastName, email, password, role });
    await user.save();
    res.status(201).json({ message: 'User added successfully' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

const getUsers = async (req, res) => {
  const users = await User.find();
  res.json(users);
};


// Update User Method
const updateUser = async (req, res) => {
  const { id } = req.params; // Get user ID from params
  const { name, lastName, email, password, role } = req.body;

  try {
    const user = await User.findById(id);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Update user data
    if (name) user.name = name;
    if (lastName) user.lastName = lastName;
    if (email) user.email = email;
    if (password) user.password = await bcrypt.hash(password, 10); // Hash password if it is provided
    if (role) user.role = role;

    await user.save(); // Save updated user
    res.status(200).json({ message: 'User updated successfully' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};
// Get user by ID (added)
const getUserById = async (req, res) => {
  const { id } = req.params;

  try {
    const user = await User.findById(id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


// Delete User
const deleteUser = async (req, res) => {
  const { id } = req.params;

  try {
    const user = await User.findByIdAndDelete(id);  // Using findByIdAndDelete

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({ message: 'User deleted successfully' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};


module.exports = { loginUser, addUser,getUsers, updateUser,getUserById, deleteUser };