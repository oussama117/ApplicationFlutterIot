const User = require('../models/User');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const nodemailer = require('nodemailer');  // Importer nodemailer
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

//adduser with mail

const addUser = async (req, res) => {
  const { name, lastName, email, password, role } = req.body;

  try {
    const user = new User({ name, lastName, email, password, role });
    await user.save();

    // Créer un transporteur pour Nodemailer (en utilisant un service SMTP comme Gmail ou SendGrid)
    const transporter = nodemailer.createTransport({
      service: 'gmail', // Par exemple, Gmail
      auth: {
        user: process.env.EMAIL_USER,  // Votre email ici
        pass: process.env.EMAIL_PASS,  // Votre mot de passe email ou un mot de passe d'application
      },
    });

    // Définir les options de l'email
    const mailOptions = {
      from: process.env.EMAIL_USER,  // L'email de l'expéditeur
      to: user.email,  // L'email du destinataire (l'utilisateur nouvellement ajouté)
      subject: 'Votre compte a été créé',
      text: `Bonjour ${user.name} ${user.lastName},\n\nVotre compte a été créé avec succès.\nVoici vos informations de connexion :\n\nEmail: ${user.email}\nMot de passe: ${password}\n\nCordialement,\nL'équipe`,  // Message de l'email
    };

    // Envoyer l'email
    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        console.log('Erreur d\'envoi de l\'email: ', error);
        return res.status(500).json({ error: 'Erreur lors de l\'envoi de l\'email' });
      }
      console.log('Email envoyé: ' + info.response);
    });

    res.status(201).json({ message: 'Utilisateur ajouté avec succès' });
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