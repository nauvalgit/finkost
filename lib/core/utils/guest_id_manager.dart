import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class GuestIdManager {
  static const _guestIdKey = 'guestId';
  static final Uuid _uuid = const Uuid();

  static Future<String> getGuestId() async {
    final prefs = await SharedPreferences.getInstance();
    String? guestId = prefs.getString(_guestIdKey);

    if (guestId == null) {
      guestId = _uuid.v4(); 
      await prefs.setString(_guestIdKey, guestId);
    }
    return guestId;
  }
}