import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtils {
  static const String userInfo = "userInfo";
  static const String accessToken = "ACCESSTOKEN";
  static const String hasLimitReached = "hasLimitReached";
  static const String supervisorPermissionsKey = "supervisorPermissions";

  static late SharedPreferences pref;

  init() async {
    pref = await SharedPreferences.getInstance();
  }

  setAccessToken(String value) {
    pref.setString(accessToken, value);
  }

  setUserInfo(String value) {
    pref.setString(userInfo, value);
  }

  String getUserInfo() {
    return pref.getString(userInfo) ?? "";
  }

  String getSessionToken() {
    return pref.getString(accessToken) ?? "";
  }

  setHasReachedLimit(bool value) {
    pref.setBool(hasLimitReached, value);
  }

  bool getHasReachedLimit() {
    return pref.getBool(hasLimitReached) ?? false;
  }

  /// Save supervisor permissions JSON string
  setSupervisorPermissions(String value) {
    pref.setString(supervisorPermissionsKey, value);
  }

  /// Get cached supervisor permissions JSON string (empty string if none)
  String getSupervisorPermissions() {
    return pref.getString(supervisorPermissionsKey) ?? "";
  }

  /// Clear only supervisor permissions (e.g. on logout)
  clearSupervisorPermissions() {
    pref.remove(supervisorPermissionsKey);
  }

  clear() {
    pref.clear();
  }
}