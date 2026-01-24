import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// DeviceUtils - Төхөөрөмжийн ID болон итгэмжлэл удирдах
/// Trust device feature-д ашиглана
class DeviceUtils {
  static const _storage = FlutterSecureStorage();
  static const _deviceIdKey = 'device_id';
  static const _trustedPhonesKey = 'trusted_phones';

  /// Device ID авах (байхгүй бол үүсгэх)
  static Future<String> getDeviceId() async {
    String? deviceId = await _storage.read(key: _deviceIdKey);
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await _storage.write(key: _deviceIdKey, value: deviceId);
    }
    return deviceId;
  }

  /// Тухайн утасны дугаарт энэ төхөөрөмж итгэмжлэгдсэн эсэх шалгах
  static Future<bool> isDeviceTrusted(String phone) async {
    final trusted = await _storage.read(key: _trustedPhonesKey);
    if (trusted == null || trusted.isEmpty) return false;

    // Утасны дугаарыг форматлах (+976 байгаа эсэх)
    final normalizedPhone = _normalizePhone(phone);
    final trustedList = trusted.split(',');

    return trustedList.contains(normalizedPhone);
  }

  /// Төхөөрөмжийг тухайн утасны дугаарт итгэмжлэх
  static Future<void> trustDevice(String phone) async {
    final normalizedPhone = _normalizePhone(phone);
    final trusted = await _storage.read(key: _trustedPhonesKey) ?? '';

    if (!trusted.contains(normalizedPhone)) {
      final newTrusted = trusted.isEmpty
          ? normalizedPhone
          : '$trusted,$normalizedPhone';
      await _storage.write(key: _trustedPhonesKey, value: newTrusted);
    }
  }

  /// Тухайн утасны дугаарын итгэмжлэлийг устгах
  static Future<void> untrustDevice(String phone) async {
    final normalizedPhone = _normalizePhone(phone);
    final trusted = await _storage.read(key: _trustedPhonesKey);

    if (trusted != null && trusted.isNotEmpty) {
      final trustedList = trusted.split(',');
      trustedList.remove(normalizedPhone);
      await _storage.write(
        key: _trustedPhonesKey,
        value: trustedList.join(','),
      );
    }
  }

  /// Бүх итгэмжлэлийг устгах (logout үед)
  static Future<void> clearAllTrust() async {
    await _storage.delete(key: _trustedPhonesKey);
  }

  /// Утасны дугаарыг +976 форматт хөрвүүлэх
  static String _normalizePhone(String phone) {
    if (phone.startsWith('+976')) {
      return phone;
    }
    return '+976$phone';
  }
}
