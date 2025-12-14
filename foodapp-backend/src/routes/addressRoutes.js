const express = require("express");
const router = express.Router();

const {
  getMyAddresses,
  addAddress,
  deleteAddress,
  setDefaultAddress,
} = require("../controllers/addressController");

const auth = require("../middleware/auth");

router.get("/", auth, getMyAddresses);
router.post("/", auth, addAddress);
router.delete("/:id", auth, deleteAddress);
router.put("/:id/default", auth, setDefaultAddress);

module.exports = router;
