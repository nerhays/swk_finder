const mongoose = require("mongoose");

const PlaceSchema = new mongoose.Schema({
  category_id: String,

  name: String,

  addres: String,

  latitude: Number,

  longitude: Number,

  description: String,

  //rating: Number,
});

module.exports = mongoose.model("Place", PlaceSchema);
