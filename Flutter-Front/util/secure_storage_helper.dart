import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageHelper {
  // 싱글톤 패턴
  static final SecureStorageHelper _instance =
  SecureStorageHelper._internal();

  factory SecureStorageHelper() => _instance;

  SecureStorageHelper._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // ─── 키 상수 ──────────────────────────────────────
  static const String accessTokenKey = 'accessToken';
  static const String refreshTokenKey = 'refreshToken';
  static const String userMidKey = 'userMid';
  static const String userNameKey = 'userName';
  static const String userEmailKey = 'userEmail';
  static const String isLoggedInKey = 'isLoggedIn';

  // ─── 토큰 저장 ────────────────────────────────────
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: accessTokenKey, value: token);
    // SharedPreferences에도 저장 (팀원 코드 호환)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: refreshTokenKey, value: token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refreshToken', token);
  }

  // ─── 토큰 조회 ────────────────────────────────────
  Future<String?> getAccessToken() async {
    // SecureStorage 먼저 확인
    final secureToken = await _storage.read(key: accessTokenKey);
    if (secureToken != null) return secureToken;

    // 없으면 SharedPreferences 확인 (팀원 코드 호환)
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<String?> getRefreshToken() async {
    final secureToken = await _storage.read(key: refreshTokenKey);
    if (secureToken != null) return secureToken;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  // ─── 회원 정보 저장 ───────────────────────────────
  Future<void> saveUserInfo({
    required String mid,
    required String name,
    required String email,
  }) async {
    // SecureStorage에 저장
    await _storage.write(key: userMidKey, value: mid);
    await _storage.write(key: userNameKey, value: name);
    await _storage.write(key: userEmailKey, value: email);
    await _storage.write(key: isLoggedInKey, value: 'true');

    // SharedPreferences에도 저장 (팀원 코드 호환)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userMid', mid);
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
  }

  // ─── 회원 정보 조회 ───────────────────────────────
  Future<String?> getUserMid() async {
    final secureValue = await _storage.read(key: userMidKey);
    if (secureValue != null) return secureValue;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userMid');
  }

  Future<String?> getUserName() async {
    final secureValue = await _storage.read(key: userNameKey);
    if (secureValue != null) return secureValue;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  Future<String?> getUserEmail() async {
    final secureValue = await _storage.read(key: userEmailKey);
    if (secureValue != null) return secureValue;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  // ─── 로그인 여부 확인 ─────────────────────────────
  Future<bool> isLoggedIn() async {
    // SecureStorage 확인
    final secureValue = await _storage.read(key: isLoggedInKey);
    if (secureValue == 'true') return true;

    // SharedPreferences 확인 (팀원 코드 호환)
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // ─── 로그아웃 (전체 삭제) ─────────────────────────
  Future<void> logout() async {
    // SecureStorage 삭제
    await _storage.deleteAll();

    // SharedPreferences도 삭제 (팀원 코드 호환)
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    print('로그아웃 완료: 전체 데이터 삭제됨');
  }

  // ─── 특정 키 삭제 ────────────────────────────────
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}