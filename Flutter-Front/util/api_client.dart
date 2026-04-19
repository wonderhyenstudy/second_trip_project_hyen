import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'secure_storage_helper.dart';

class ApiClient {
  // 싱글톤 패턴
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _storage = SecureStorageHelper();
  late final Dio _dio;

  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8080';

  // ─── 초기화 ───────────────────────────────────────
  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    // 요청 인터셉터 → 모든 요청에 자동으로 토큰 추가
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getAccessToken();
        print('===== API 호출 토큰: $token ====='); // 로그 추가
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print('===== 헤더: ${options.headers} ====='); // 로그 추가
        return handler.next(options);
      },
      // 응답 에러 처리
      onError: (error, handler) async {
        // 토큰 만료 (401) 시 로그아웃
        if (error.response?.statusCode == 401) {
          await _storage.logout();
          print('토큰 만료 → 로그아웃 처리');
        }
        return handler.next(error);
      },
    ));
  }

  // ─── 찜 추가 ──────────────────────────────────────
  Future<Map<String, dynamic>?> addFavorite({
    required String contentId,
    required String accommodationTitle,
    required String firstImage,
    required String addr1,
  }) async {
    try {
      final response = await _dio.post(
        '/api/favorites',
        data: {
          'contentId': contentId,
          'accommodationTitle': accommodationTitle,
          'firstImage': firstImage,
          'addr1': addr1,
        },
      );
      return response.data;
    } on DioException catch (e) {
      print('찜 추가 에러: ${e.message}');
      return null;
    }
  }

  // ─── 찜 삭제 ──────────────────────────────────────
  Future<bool> removeFavorite(String contentId) async {
    try {
      await _dio.delete('/api/favorites/$contentId');
      return true;
    } on DioException catch (e) {
      print('찜 삭제 에러: ${e.message}');
      return false;
    }
  }

  // ─── 내 찜 목록 조회 ──────────────────────────────
  Future<List<dynamic>?> getMyFavorites() async {
    try {
      final response = await _dio.get('/api/favorites');
      return response.data;
    } on DioException catch (e) {
      print('찜 목록 조회 에러: ${e.message}');
      return null;
    }
  }

  // ─── 찜 여부 확인 ─────────────────────────────────
  Future<bool> checkFavorite(String contentId) async {
    try {
      final response =
      await _dio.get('/api/favorites/check/$contentId');
      return response.data as bool;
    } on DioException catch (e) {
      print('찜 여부 확인 에러: ${e.message}');
      return false;
    }
  }

  // ─── 예약 생성 ────────────────────────────────────
  Future<Map<String, dynamic>?> createReservation({
    required String contentId,
    required String roomCode,
    required String accommodationTitle,
    required String roomTitle,
    required String checkInDate,
    required String checkOutDate,
    required int guestCount,
    required int totalPrice,
  }) async {
    try {
      final response = await _dio.post(
        '/api/reservations',
        data: {
          'contentId': contentId,
          'roomCode': roomCode,
          'accommodationTitle': accommodationTitle,
          'roomTitle': roomTitle,
          'checkInDate': checkInDate,
          'checkOutDate': checkOutDate,
          'guestCount': guestCount,
          'totalPrice': totalPrice,
        },
      );
      return response.data;
    } on DioException catch (e) {
      // 에러 메시지 반환
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data ?? '예약에 실패했습니다.');
      }
      throw Exception('예약에 실패했습니다.');
    }
  }

  // ─── 내 예약 목록 조회 ────────────────────────────
  Future<List<dynamic>?> getMyReservations() async {
    try {
      final response = await _dio.get('/api/reservations');
      return response.data;
    } on DioException catch (e) {
      print('예약 목록 조회 에러: ${e.message}');
      return null;
    }
  }

  // ─── 예약 취소 ────────────────────────────────────
  Future<bool> cancelReservation(int reservationId) async {
    try {
      await _dio.delete('/api/reservations/$reservationId');
      return true;
    } on DioException catch (e) {
      print('예약 취소 에러: ${e.message}');
      return false;
    }
  }
}