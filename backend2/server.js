const express = require("express");
const dotenv = require("dotenv");
const connectDB = require("./config/db");
const cors = require("cors");

const sheepRoutes = require("./routes/sheepRoutes");
const necklaceRoutes = require("./routes/necklace_routes");

dotenv.config();
connectDB();

const app = express();
app.use(cors());
app.use(express.json());
app.use("/api/users", require("./routes/userRoutes"));
app.use("/api/sheep", sheepRoutes);
app.use("/api/necklace", necklaceRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
