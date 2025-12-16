const User = require("../models/User");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

// ---------------- REGISTER ----------------
exports.register = async (req, res) => {
  try {
    const { name, email, password, phone } = req.body;

    let existing = await User.findOne({ email });
    if (existing) {
      return res.status(400).json({ message: "User already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = new User({
      name,
      email,
      phone,
      password: hashedPassword,
      profileImage: "assets/profile.png", // ✅ default
    });

    await user.save();

    const token = jwt.sign(
      { id: user._id },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.status(201).json({
      token,
      user: user.toJSON(),
    });
  } catch (err) {
    console.error("Register Error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

// ---------------- LOGIN ----------------
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ message: "Invalid credentials" });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch)
      return res.status(400).json({ message: "Invalid credentials" });

    const token = jwt.sign(
      { id: user._id },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({ token, user: user.toJSON() });
  } catch (err) {
    console.error("Login Error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

// ---------------- ME ----------------
exports.me = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select("-password");
    if (!user) return res.status(404).json({ message: "User not found" });
    res.json(user);
  } catch (err) {
    console.error("Me Error:", err);
    res.status(500).json({ message: "Server error" });
  }
};

// ---------------- UPDATE PROFILE ----------------
exports.updateProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const { name, address, password } = req.body;

    const updateData = {};

    if (name) updateData.name = name;
    if (address) updateData.address = address;

    if (password && password.trim().length > 0) {
      updateData.password = await bcrypt.hash(password, 10);
    }

    // ✅ SAVE IMAGE PATH CORRECTLY
    if (req.file) {
      updateData.profileImage = `/uploads/avatars/${req.file.filename}`;
    }

    const updatedUser = await User.findByIdAndUpdate(
      userId,
      { $set: updateData },
      { new: true, select: "-password" }
    );

    if (!updatedUser) {
      return res.status(404).json({ message: "User not found" });
    }

    res.status(200).json({ user: updatedUser });
  } catch (err) {
    console.error("Update Profile Error:", err);
    res.status(500).json({ message: "Server error" });
  }
};
