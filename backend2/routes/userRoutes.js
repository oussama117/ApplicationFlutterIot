const express = require('express'); 
const { loginUser, addUser, getUsers, getUserById, updateUser, deleteUser } = require('../controllers/userController'); // Ensure all methods are imported
const router = express.Router();

// Login route
router.post('/login', loginUser);

// Add user route
router.post('/add', addUser);

// Get users route
router.get('/', getUsers);

// Get user by ID route (added)
router.get('/:id', getUserById);  // GET method to fetch user by ID

// Update user route
router.put('/:id', updateUser); // PUT method for updating user

// Delete user route
router.delete('/:id', deleteUser); // DELETE method for deleting user

module.exports = router;