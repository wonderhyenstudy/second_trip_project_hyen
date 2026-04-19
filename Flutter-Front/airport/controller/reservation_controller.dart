import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';  // ✅ [추가]
import '../../common/constants/api_constants.dart';
import '../model/reservation_item.dart';

// 토큰 사용으로 변경 20250416
// ✅ shared_preferences import 추가
// ✅ _getHeaders() 메서드 추가
// ✅ fetchReservations() 토큰 헤더 추가
// ✅ addReservation() 토큰 헤더 추가
// ✅ cancelReservation() 토큰 헤더 추가
// ✅ URL 앞에 api/ 추가

class ReservationController with ChangeNotifier {

  // ── 상태 변수 ─────────────────────────────────────────────
  final List<ReservationItem> _items = [];
  bool    _isLoading    = false;
  String? _errorMessage;

  List<ReservationItem> get items        => _items;
  bool                  get isLoading    => _isLoading;
  String?               get errorMessage => _errorMessage;

  // ✅ [추가] 토큰 헤더 가져오기
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    // ✅ [추가] 토큰 확인 로그
    debugPrint('[ReservationController] 토큰: $token');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── 예약 목록 조회 (스프링부트 GET) ──────────────────────
  Future<void> fetchReservations(String mid) async {
    _isLoading = true;
    notifyListeners();

    debugPrint('[ReservationController] 예약 목록 조회 → mid: $mid');

    try {
      final baseUrl = ApiConstants.baseUrl;
      // final url = '${baseUrl}api/airport/reservations/my?mid=$mid';
      final url = '$baseUrl/api/airport/reservations/my?mid=$mid';

      debugPrint('[ReservationController] 요청 URL: $url');

      // ✅ [변경 전] http.get(Uri.parse(url))
      // ✅ [변경 후] 토큰 헤더 추가
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      debugPrint('[ReservationController] 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes));

        // ✅ [추가] 탑승객 정보 디버그
        for (var item in data) {
          debugPrint('[ReservationController] 예약 id: ${item['id']} / '
              '탑승객: ${item['passengers']}');
        }


        _items.clear();
        _items.addAll(
          data.map((e) => ReservationItem.fromJson(e)).toList(),
        );
        debugPrint('[ReservationController] 조회 완료 → ${_items.length}건');
      } else {
        _errorMessage = '서버 오류: ${response.statusCode}';
        debugPrint('[ReservationController] 서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = '네트워크 오류: $e';
      debugPrint('[ReservationController] 네트워크 오류: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── 예약 추가 (스프링부트 POST) ───────────────────────────
  Future<String?> addReservation(ReservationItem item) async {
    // ✅ passengers 첫 번째 탑승객 이름
    final firstName = item.passengers.isNotEmpty
        ? item.passengers[0].passengerName
        : '-';
    debugPrint('[ReservationController] 예약 등록 → 탑승객: $firstName');
    debugPrint('[ReservationController] 탑승객 수: ${item.passengers.length}');
    for (var p in item.passengers) {
      debugPrint('[ReservationController] 탑승객: ${p.passengerName} / ${p.passengerType}');
    }
    debugPrint('[ReservationController] JSON: ${jsonEncode(item.toJson())}');

    try {
      final baseUrl = ApiConstants.baseUrl;
      final url = '$baseUrl/api/airport/reservations';

      debugPrint('[ReservationController] 요청 URL: $url');

      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(item.toJson()),
      );

      debugPrint('[ReservationController] 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (item.mid != null) {
          await fetchReservations(item.mid!);
        }
        debugPrint('[ReservationController] 예약 등록 완료');
        return null; // ✅ 성공

      } else if (response.statusCode == 400) {
        try {
          final body = jsonDecode(utf8.decode(response.bodyBytes));
          _errorMessage = body['message'] ?? '이미 예약된 항공편입니다!';
        } catch (e) {
          _errorMessage = '이미 예약된 항공편입니다!';
        }
        debugPrint('[ReservationController] 중복 예약: $_errorMessage');
        return _errorMessage; // ✅ 에러 메시지 반환

      } else {
        _errorMessage = '서버 오류: ${response.statusCode}';
        debugPrint('[ReservationController] 서버 오류: ${response.statusCode}');
        return _errorMessage;
      }

    } catch (e) {
      _errorMessage = '네트워크 오류: $e';
      debugPrint('[ReservationController] 네트워크 오류: $e');
      return _errorMessage;
    } finally {
      notifyListeners();
    }
  }

  // ── 예약 취소 (스프링부트 DELETE) ────────────────────────
  Future<void> cancelReservation(int index) async {
    final item = _items[index];

    debugPrint('[ReservationController] 예약 취소 → id: ${item.id}');

    try {
      final baseUrl = ApiConstants.baseUrl;
      // final url = '${baseUrl}api/airport/reservations/${item.id}';
      final url = '$baseUrl/api/airport/reservations/${item.id}';

      debugPrint('[ReservationController] 요청 URL: $url');

      // ✅ [변경 전] http.delete(Uri.parse(url))
      // ✅ [변경 후] 토큰 헤더 추가
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );
      debugPrint('[ReservationController] 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        _items.removeAt(index);
        debugPrint('[ReservationController] 취소 완료 → '
            '남은 예약: ${_items.length}건');
        // ✅ [추가] 토큰 만료 처리
      } else if (response.statusCode == 401 ||
          response.statusCode == 403) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        _errorMessage = '로그인이 만료되었습니다.\n다시 로그인해주세요.';
        debugPrint('[ReservationController] 토큰 만료 → 로그아웃 처리');
      } else {
        _errorMessage = '서버 오류: ${response.statusCode}';
        debugPrint('[ReservationController] 서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = '네트워크 오류: $e';
      debugPrint('[ReservationController] 네트워크 오류: $e');
    }

    notifyListeners();
  }

  // ── 국내 예약만 필터 ──────────────────────────────────────
  List<ReservationItem> get domesticItems =>
      _items.where((e) => !e.isRoundTrip || e.depAirportId != null).toList();
}