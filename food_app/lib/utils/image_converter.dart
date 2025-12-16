import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageConverter {
  static Future<File> ensureJpg(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);

      // ❗ If decode fails, return original file (DON’T CRASH)
      if (decoded == null) {
        print("⚠️ Image decode failed, using original file");
        return file;
      }

      final tempDir = await getTemporaryDirectory();
      final jpgPath = path.join(
        tempDir.path,
        '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final jpgFile = File(jpgPath)
        ..writeAsBytesSync(img.encodeJpg(decoded, quality: 85));

      return jpgFile;
    } catch (e) {
      print("❌ Image conversion error: $e");
      return file; // 🔥 NEVER throw
    }
  }
}
