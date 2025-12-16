const multer = require("multer");
const path = require("path");
const fs = require("fs");

// Set storage engine
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = path.join(__dirname, "..", "uploads", "avatars");
    fs.mkdirSync(uploadDir, { recursive: true });
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname);
    cb(null, `${req.user.id}-${Date.now()}${ext}`);
  },
});

// Filter to accept only JPG / PNG
function fileFilter(req, file, cb) {
  const allowedTypes = /jpeg|jpg|png/;
  const extname = allowedTypes.test(
    path.extname(file.originalname).toLowerCase()
  );
  const mimetype = allowedTypes.test(file.mimetype.toLowerCase());

  if (extname && mimetype) {
    cb(null, true);
  } else {
    cb(new Error("Only images of type jpeg, jpg, png are allowed"));
  }
}

const upload = multer({
  storage,
  limits: { fileSize: 2 * 1024 * 1024 },
  fileFilter,
});

module.exports = upload;
