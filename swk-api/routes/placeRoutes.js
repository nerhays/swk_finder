const router = require("express").Router();
const Place = require("../models/Place");

router.get("/", async (req, res) => {
  try {
    const categoryId = req.query.category_id;

    let places;

    if (categoryId) {
      places = await Place.find({
        category_id: categoryId,
      });
    } else {
      places = await Place.find();
    }

    res.json(places);
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
});
router.get("/:id", async (req, res) => {
  try {
    const place = await Place.findById(req.params.id);

    res.json(place);
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
});
module.exports = router;
