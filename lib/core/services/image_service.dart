import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// ImageService - Зураг авах, компресс хийх, хадгалах
///
/// Offline-first architecture-д зориулсан image handling service.
/// Зургийг эхлээд local-д хадгалж, дараа нь server рүү sync хийнэ.
class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Зураг сонгох (камер эсвэл галерей)
  ///
  /// [source] - ImageSource.camera эсвэл ImageSource.gallery
  /// [maxWidth] - Зургийн max өргөн (default: 1024)
  /// [maxHeight] - Зургийн max өндөр (default: 1024)
  /// [quality] - JPEG quality (0-100, default: 85)
  Future<File?> pickImage({
    required ImageSource source,
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 85,
  }) async {
    try {
      final XFile? xFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );

      if (xFile == null) return null;
      return File(xFile.path);
    } catch (e) {
      // Хэрэглэгч permission өгөхгүй бол алдаа гарна
      return null;
    }
  }

  /// Зураг компресс хийх
  ///
  /// Зургийг JPEG формат руу хөрвүүлж, хэмжээг багасгана.
  /// [file] - Анхны зураг файл
  /// [quality] - JPEG quality (0-100, default: 70)
  /// [minWidth] - Зургийн min өргөн (default: 800)
  /// [minHeight] - Зургийн min өндөр (default: 800)
  Future<Uint8List?> compressImage(
    File file, {
    int quality = 70,
    int minWidth = 800,
    int minHeight = 800,
  }) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
        format: CompressFormat.jpeg,
      );
      return result;
    } catch (e) {
      return null;
    }
  }

  /// Local storage-д зураг хадгалах (offline-first)
  ///
  /// Зургийг app documents directory-д хадгална.
  /// [imageBytes] - Компресс хийсэн зургийн bytes
  /// [productId] - Product ID (файл нэрэнд ашиглах)
  /// Returns: Local файлын path
  Future<String> saveImageLocally(
    Uint8List imageBytes,
    String productId,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(directory.path, 'product_images'));

    // Хавтас байхгүй бол үүсгэх
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final fileName = '${productId}_${const Uuid().v4()}.jpg';
    final file = File(p.join(imagesDir.path, fileName));
    await file.writeAsBytes(imageBytes);

    return file.path;
  }

  /// Зургийн MD5 hash тооцоолох
  ///
  /// Sync conflict detection-д ашиглах.
  /// [imageBytes] - Зургийн bytes
  String calculateImageHash(Uint8List imageBytes) {
    return md5.convert(imageBytes).toString();
  }

  /// Local зураг устгах
  ///
  /// [localPath] - Local файлын path
  Future<void> deleteLocalImage(String localPath) async {
    final file = File(localPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Local зураг байгаа эсэхийг шалгах
  Future<bool> localImageExists(String localPath) async {
    final file = File(localPath);
    return await file.exists();
  }

  /// Бүх local зургуудыг авах (debugging/cleanup-д)
  Future<List<File>> getAllLocalImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(directory.path, 'product_images'));

    if (!await imagesDir.exists()) {
      return [];
    }

    return imagesDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.jpg'))
        .toList();
  }

  /// Local зургуудын нийт хэмжээг авах (storage monitoring)
  Future<int> getLocalImagesTotalSize() async {
    final images = await getAllLocalImages();
    int totalSize = 0;

    for (final image in images) {
      totalSize += await image.length();
    }

    return totalSize;
  }
}
