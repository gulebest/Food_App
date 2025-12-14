const Address = require("../models/Address");

// ✅ GET USER ADDRESSES
exports.getMyAddresses = async (req, res) => {
  try {
    const addresses = await Address.find({ user: req.user.id }).sort({
      isDefault: -1,
      createdAt: -1,
    });

    res.json(addresses);
  } catch (error) {
    res.status(500).json({ message: "Failed to load addresses" });
  }
};

// ✅ ADD NEW ADDRESS
exports.addAddress = async (req, res) => {
  try {
    const {
      label,
      fullName,
      phone,
      street,
      city,
      state,
      postalCode,
      country,
      isDefault,
    } = req.body;

    if (!fullName || !phone || !street || !city) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    // If new address is default → unset others
    if (isDefault) {
      await Address.updateMany(
        { user: req.user.id },
        { isDefault: false }
      );
    }

    const address = await Address.create({
      user: req.user.id,
      label,
      fullName,
      phone,
      street,
      city,
      state,
      postalCode,
      country,
      isDefault,
    });

    res.status(201).json(address);
  } catch (error) {
    res.status(500).json({ message: "Failed to add address" });
  }
};

// ✅ DELETE ADDRESS
exports.deleteAddress = async (req, res) => {
  try {
    const address = await Address.findOne({
      _id: req.params.id,
      user: req.user.id,
    });

    if (!address) {
      return res.status(404).json({ message: "Address not found" });
    }

    await address.deleteOne();

    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ message: "Failed to delete address" });
  }
};

// ✅ SET DEFAULT ADDRESS
exports.setDefaultAddress = async (req, res) => {
  try {
    await Address.updateMany(
      { user: req.user.id },
      { isDefault: false }
    );

    const address = await Address.findOneAndUpdate(
      { _id: req.params.id, user: req.user.id },
      { isDefault: true },
      { new: true }
    );

    res.json(address);
  } catch (error) {
    res.status(500).json({ message: "Failed to set default address" });
  }
};
