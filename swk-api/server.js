const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const placeRoutes = require("./routes/placeRoutes");
const categoryRoutes = require("./routes/categoryRoutes");
require("dotenv").config();

const app = express();

app.use(cors());
app.use(express.json());

app.use("/api/places", placeRoutes);
app.use("/api/categories", categoryRoutes);
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("Mongo Connected"))
  .catch((err) => console.log(err));

app.listen(process.env.PORT, () => {
  console.log("Server Running");
});
