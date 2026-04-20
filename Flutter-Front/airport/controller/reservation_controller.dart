import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/constants/api_constants.dart';
import '../../services/member_service.dart';
import '../model/reservation_item.dart';

class ReservationController with ChangeNotifier {

  // ── 상태 변수 ─────────────────────────────────────────────
  // _items      : 서버에서 조회한 예약 목록
  // _isLoading  : 로딩 중 여부 (화면에서 로딩 인디케이터 표시용)
  // _errorMessage: 에러 발생 시 화면에 표시할 메시지
  final List<ReservationItem> _items = [];
  bool    _isLoading    = false;
  String? _errorMessage;

  List<ReservationItem> get items        => _items;
  bool                  get isLoading    => _isLoading;
  String?               get errorMessage => _errorMessage;

  // ── JWT 토큰 헤더 생성 ────────────────────────────────────
  // MemberService → SecureStorageHelper 순으로 토큰 조회
  // 모든 API 요청 전에 호출해서 헤더에 포함
  Future<Map<String, String>> _getHeaders() async {
    final memberService = MemberService();
    final token = await memberService.getAccessToken() ?? '';
    debugPrint('[ReservationController] 토큰: $token');
    return {
      'Content-Type' : 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── 예약 목록 조회 ────────────────────────────────────────
  // GET /api/airport/reservations/my?mid={mid}
  // MyReservationScreen 진입 시 호출
  // mid 는 SharedPreferences 에서 가져온 값 사용 (직접 하드코딩 금지)
  Future<void> fetchReservations(String mid) async {
    _isLoading = true;
    notifyListeners();

    debugPrint('[ReservationController] 예약 목록 조회 시작 → mid: $mid');

    try {
      final url = '${ApiConstants.baseUrl}/api/airport/reservations/my?mid=$mid';
      debugPrint('[ReservationController] 요청 URL: $url');

      final headers  = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      debugPrint('[ReservationController] 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        // 탑승객 정보 디버그 (예약 id 별 탑승객 확인용)
        for (var item in data) {
          debugPrint('[ReservationController] 예약 id: ${item['id']} / '
              '탑승객: ${item['passengers']}');
        }

        _items.clear();
        _items.addAll(data.map((e) => ReservationItem.fromJson(e)).toList());
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

  // ── 예약 등록 ─────────────────────────────────────────────
  // POST /api/airport/reservations
  // 성공 시 null 반환, 실패 시 에러 메시지 반환
  // 200: 등록 성공 → 목록 자동 갱신
  // 400: 중복 예약 → 서버 메시지 반환
  // 그 외: 서버 오류 메시지 반환
  Future<String?> addReservation(ReservationItem item) async {
    final firstName = item.passengers.isNotEmpty
        ? item.passengers[0].passengerName : '-';
    debugPrint('[ReservationController] 예약 등록 시작 → 첫 탑승객: $firstName');
    debugPrint('[ReservationController] 탑승객 수: ${item.passengers.length}');
    for (var p in item.passengers) {
      debugPrint('[ReservationController] 탑승객 상세: ${p.passengerName} / ${p.passengerType}');
    }
    debugPrint('[ReservationController] 전송 JSON: ${jsonEncode(item.toJson())}');

    try {
      final url = '${ApiConstants.baseUrl}/api/airport/reservations';
      debugPrint('[ReservationController] 요청 URL: $url');

      final headers  = await _getHeaders();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(item.toJson()),
      );
      debugPrint('[ReservationController] 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        // 등록 성공 → 목록 자동 갱신
        if (item.mid != null) await fetchReservations(item.mid!);
        debugPrint('[ReservationController] 예약 등록 완료');
        return null; // 성공

      } else if (response.statusCode == 400) {
        // 중복 예약 처리
        try {
          final body = jsonDecode(utf8.decode(response.bodyBytes));
          _errorMessage = body['message'] ?? '이미 예약된 항공편입니다!';
        } catch (e) {
          _errorMessage = '이미 예약된 항공편입니다!';
        }
        debugPrint('[ReservationController] 중복 예약 감지: $_errorMessage');
        return _errorMessage;

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

  // ── 예약 취소 ─────────────────────────────────────────────
  // DELETE /api/airport/reservations/{id}
  // 200: 취소 성공 → 목록에서 즉시 제거
  // 401/403: 토큰 만료 → SharedPreferences 초기화 후 재로그인 안내
  Future<void> cancelReservation(int index) async {
    final item = _items[index];
    debugPrint('[ReservationController] 예약 취소 시작 → id: ${item.id}');

    try {
      final url = '${ApiConstants.baseUrl}/api/airport/reservations/${item.id}';
      debugPrint('[ReservationController] 요청 URL: $url');

      final headers  = await _getHeaders();
      final response = await http.delete(Uri.parse(url), headers: headers);
      debugPrint('[ReservationController] 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        _items.removeAt(index);
        debugPrint('[ReservationController] 취소 완료 → 남은 예약: ${_items.length}건');

      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // 토큰 만료 → 로컬 데이터 초기화
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        _errorMessage = '로그인이 만료되었습니다.\n다시 로그인해주세요.';
        debugPrint('[ReservationController] 토큰 만료 → SharedPreferences 초기화');

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

  // ── 국내선 예약 필터 ─────────────────────────────────────
  // depAirportId 가 있는 항목만 반환 (국내선 구분용)
  List<ReservationItem> get domesticItems =>
      _items.where((e) => !e.isRoundTrip || e.depAirportId != null).toList();
}

// =============================================================================
// [파일 정보]
// 위치  : lib/airport/controller/reservation_controller.dart
// 역할  : 항공 예약 목록 조회 / 등록 / 취소 상태 관리
// 사용처 : ReservationScreen (예약 등록), MyReservationScreen (목록/취소)
// -----------------------------------------------------------------------------
// [연관 파일]
// - reservation_item.dart  : 예약 데이터 모델 (toJson/fromJson)
// - passenger_item.dart    : 탑승객 데이터 모델
// - member_service.dart    : JWT 토큰 조회
// - api_constants.dart     : baseUrl 관리
// - reservation_screen.dart    : addReservation() 호출
// - my_reservation_screen.dart : fetchReservations(), cancelReservation() 호출
// -----------------------------------------------------------------------------
// [변경 이력]
// - 최초 작성 : 예약 목록 조회, 등록, 취소 기본 구조
// - 변경       : JWT 토큰 헤더 추가 (_getHeaders)
//               MemberService 통해 토큰 조회 (SecureStorage 기반)
//               401/403 토큰 만료 처리 추가 (SharedPreferences 초기화)
//               URL api/ 경로 통일
// -----------------------------------------------------------------------------
// [메서드 목록]
// - _getHeaders()           : JWT 토큰 포함 헤더 생성 (내부 전용)
// - fetchReservations(mid)  : 예약 목록 조회 GET
// - addReservation(item)    : 예약 등록 POST, 성공 null / 실패 에러메시지 반환
// - cancelReservation(index): 예약 취소 DELETE
// - domesticItems           : 국내선 예약만 필터링 (getter)
// -----------------------------------------------------------------------------
// [파일 흐름과 순서]
// 1. ReservationScreen 에서 addReservation() 호출
//    → _getHeaders() 로 토큰 헤더 생성
//    → POST /api/airport/reservations
//    → 성공 시 fetchReservations() 로 목록 자동 갱신
// 2. MyReservationScreen 진입 시 fetchReservations(mid) 호출
//    → GET /api/airport/reservations/my?mid={mid}
//    → _items 갱신 → notifyListeners() → 화면 자동 갱신
// 3. 예약 취소 버튼 클릭 시 cancelReservation(index) 호출
//    → DELETE /api/airport/reservations/{id}
//    → 성공 시 _items 에서 즉시 제거
//    → 401/403 시 토큰 만료 처리
// -----------------------------------------------------------------------------
// [주의사항 / 참고]
// - mid 는 반드시 SharedPreferences 에서 가져올 것 (하드코딩 금지)
// - 토큰은 MemberService 통해서만 조회 (SecureStorage + SharedPreferences 이중 저장)
// - addReservation() 반환값: 성공 = null, 실패 = 에러 메시지 문자열
// - 서버는 중복 예약 시 400 + message 반환
// =============================================================================