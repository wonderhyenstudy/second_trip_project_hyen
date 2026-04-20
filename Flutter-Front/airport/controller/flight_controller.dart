import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../common/constants/api_constants.dart';
import '../model/flight_item.dart';

class FlightController with ChangeNotifier {

  // ── 항공편 목록 상태 ──────────────────────────────────────
  // _items      : 서버에서 조회한 가는편 목록
  // _isLoading  : 첫 로딩 중 여부
  // _errorMessage: 에러 발생 시 화면에 표시할 메시지
  final List<FlightItem> _items = [];
  bool    _isLoading    = false;
  String? _errorMessage;

  List<FlightItem> get items        => _items;
  bool             get isLoading    => _isLoading;
  String?          get errorMessage => _errorMessage;

  // ── 페이지네이션 (무한스크롤) ────────────────────────────
  // 현재 스프링부트는 전체 데이터 한번에 반환 → hasMore = false 고정
  // TAGO API 페이지 방식에서 구조 유지 중 (추후 페이지 방식 전환 가능)
  bool _isFetchingMore = false;
  bool _hasMore        = true;
  int  _currentPage    = 1;

  bool get isFetchingMore => _isFetchingMore;
  bool get hasMore        => _hasMore;

  // ── 검색 조건 ────────────────────────────────────────────
  // fetchInitial() 호출 시 저장되어 FlightListScreen/FlightDetailScreen 에서 참조
  String    _depAirportId = ''; // 출발 공항코드 (예: GIMHAE)
  String    _arrAirportId = ''; // 도착 공항코드 (예: JEJU)
  String    _depPlandTime = ''; // 출발 날짜 (예: 20260421)
  bool      _isRoundTrip  = false;
  int       _adultCount   = 1;
  int       _childCount   = 0;
  int       _infantCount  = 0;
  DateTime? _retDate;           // 왕복 오는편 날짜 (편도일 때 null)
  String    _depAirportNm = ''; // 출발 공항명 (화면 표시용)
  String    _arrAirportNm = ''; // 도착 공항명 (화면 표시용)

  String    get depAirportId => _depAirportId;
  String    get arrAirportId => _arrAirportId;
  String    get depPlandTime => _depPlandTime;
  bool      get isRoundTrip  => _isRoundTrip;
  int       get adultCount   => _adultCount;
  int       get childCount   => _childCount;
  int       get infantCount  => _infantCount;
  DateTime? get retDate      => _retDate;
  String    get depAirportNm => _depAirportNm;
  String    get arrAirportNm => _arrAirportNm;

  // ── 왕복 오는편 목록 ─────────────────────────────────────
  // fetchReturnFlights() 호출 시 채워짐
  // 출발/도착 공항을 반전시켜 조회 (GIMHAE → JEJU 반대)
  final List<FlightItem> _retItems = [];
  List<FlightItem> get retItems => _retItems;

  // ── 선택한 항공편 ────────────────────────────────────────
  // FlightListScreen 에서 카드 클릭 시 selectDep() 호출
  // FlightDetailScreen 에서 오는편 카드 클릭 시 selectRet() 호출
  FlightItem? _selectedDep; // 선택한 가는편
  FlightItem? _selectedRet; // 선택한 오는편 (왕복일 때)

  FlightItem? get selectedDep => _selectedDep;
  FlightItem? get selectedRet => _selectedRet;

  // 가는편 선택 → FlightDetailScreen 으로 이동 전 호출
  void selectDep(FlightItem item) {
    _selectedDep = item;
    debugPrint('[FlightController] 가는편 선택: ${item.airlineNm} ${item.flightNo}');
    notifyListeners();
  }

  // 오는편 선택 → FlightDetailScreen 오는편 리스트에서 호출
  void selectRet(FlightItem item) {
    _selectedRet = item;
    debugPrint('[FlightController] 오는편 선택: ${item.airlineNm} ${item.flightNo}');
    notifyListeners();
  }

  // ── 첫 검색 ──────────────────────────────────────────────
  // SearchScreen 검색 버튼 클릭 시 호출
  // 검색 조건 저장 → 상태 초기화 → _fetchPage(1) 호출
  // 재설정 모달에서 조건 변경 후 재검색 시에도 이 메서드 호출
  Future<void> fetchInitial({
    required String depAirportId,
    required String arrAirportId,
    required String depPlandTime,
    required bool   isRoundTrip,
    required int    adultCount,
    required int    childCount,
    required int    infantCount,
    DateTime?       retDate,
  }) async {
    if (_isLoading) return;

    // 검색 조건 저장
    _depAirportId = depAirportId;
    _arrAirportId = arrAirportId;
    _depPlandTime = depPlandTime;
    _isRoundTrip  = isRoundTrip;
    _adultCount   = adultCount;
    _childCount   = childCount;
    _infantCount  = infantCount;
    _retDate      = retDate;
    _depAirportNm = FlightItem.getAirportName(depAirportId);
    _arrAirportNm = FlightItem.getAirportName(arrAirportId);

    // 상태 초기화
    _isLoading    = true;
    _errorMessage = null;
    _currentPage  = 1;
    _hasMore      = true;
    _items.clear();
    _selectedDep  = null;
    _selectedRet  = null;
    notifyListeners();

    debugPrint('[FlightController] 검색 시작 → '
        '출발: $depAirportId / 도착: $arrAirportId / 날짜: $depPlandTime / '
        '왕복: $isRoundTrip / 성인: $adultCount / 소아: $childCount / 유아: $infantCount');

    await _fetchPage(_currentPage);

    _isLoading = false;
    notifyListeners();
  }

  // ── 무한스크롤 추가 로드 ─────────────────────────────────
  // FlightListScreen 스크롤 끝 도달 시 호출
  // 현재 스프링부트 전체 반환 방식이라 실질적으로 동작하지 않음 (hasMore = false)
  Future<void> fetchMore() async {
    if (_isFetchingMore || !_hasMore || _isLoading) return;

    _isFetchingMore = true;
    _currentPage++;
    notifyListeners();
    debugPrint('[FlightController] 추가 로드 → 페이지: $_currentPage');

    await _fetchPage(_currentPage);

    _isFetchingMore = false;
    notifyListeners();
  }

  // ── 왕복 오는편 조회 ─────────────────────────────────────
  // FlightDetailScreen 진입 시 자동 호출 (왕복일 때만)
  // 출발/도착 공항 반전 후 retPlandTime 날짜로 조회
  Future<void> fetchReturnFlights({required String retPlandTime}) async {
    _retItems.clear();
    notifyListeners();

    debugPrint('[FlightController] 오는편 조회 시작 → '
        '출발: $_arrAirportId / 도착: $_depAirportId / 날짜: $retPlandTime');

    try {
      final url = '${ApiConstants.baseUrl}/api/airport/flights'
          '?depAirportId=$_arrAirportId'
          '&arrAirportId=$_depAirportId'
          '&depPlandTime=$retPlandTime';

      debugPrint('[FlightController] 오는편 요청 URL: $url');

      final response = await http.get(Uri.parse(url));
      debugPrint('[FlightController] 오는편 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        _retItems.addAll(data.map((e) => FlightItem.fromJson(e)).toList());
        debugPrint('[FlightController] 오는편 조회 완료 → ${_retItems.length}건');
      } else {
        debugPrint('[FlightController] 오는편 서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[FlightController] 오는편 네트워크 오류: $e');
    }

    notifyListeners();
  }

  // ── 내부 API 호출 ────────────────────────────────────────
  // fetchInitial / fetchMore 에서 공통으로 호출
  // 스프링부트 GET /api/airport/flights?depAirportId=&arrAirportId=&depPlandTime=
  // 현재 전체 데이터 한번에 반환 → _hasMore = false 고정
  Future<void> _fetchPage(int page) async {
    final url = '${ApiConstants.baseUrl}/api/airport/flights'
        '?depAirportId=$_depAirportId'
        '&arrAirportId=$_arrAirportId'
        '&depPlandTime=$_depPlandTime';

    debugPrint('[FlightController] 요청 URL: $url (페이지: $page)');

    try {
      final response = await http.get(Uri.parse(url));
      debugPrint('[FlightController] 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint('[FlightController] 응답 데이터: ${data.length}건');
        _items.addAll(data.map((e) => FlightItem.fromJson(e)).toList());
        _hasMore = false; // 스프링부트 전체 반환 방식
      } else {
        _errorMessage = '서버 오류: ${response.statusCode}';
        debugPrint('[FlightController] 서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = '네트워크 오류: $e';
      debugPrint('[FlightController] 네트워크 오류: $e');
    }
  }
}

// =============================================================================
// [파일 정보]
// 위치  : lib/airport/controller/flight_controller.dart
// 역할  : 항공편 검색 / 목록 조회 / 선택 상태 관리
// 사용처 : SearchScreen (검색 실행), FlightListScreen (목록), FlightDetailScreen (선택/오는편)
// -----------------------------------------------------------------------------
// [연관 파일]
// - flight_item.dart        : 항공편 데이터 모델 (fromJson)
// - api_constants.dart      : baseUrl 관리
// - search_screen.dart      : fetchInitial() 호출
// - flight_list_screen.dart : items, fetchMore(), 재설정 시 fetchInitial() 호출
// - flight_detail_screen.dart : selectedDep, selectedRet, fetchReturnFlights() 호출
// - reservation_screen.dart : adultCount, childCount, infantCount, selectedDep/Ret 참조
// -----------------------------------------------------------------------------
// [변경 이력]
// - 최초 작성 : TAGO 공공 API 연동, 페이지 단위 무한스크롤
// - 변경       : 스프링부트 API 로 전환 (전체 데이터 1회 반환)
//               hasMore = false 고정 (무한스크롤 구조 유지, 실질 동작 없음)
//               fetchReturnFlights() 추가 (왕복 오는편 조회)
//               재설정 모달 오는편 날짜(retDate) 변경 지원
//               flutter_dotenv 제거 → ApiConstants.baseUrl 통일
// -----------------------------------------------------------------------------
// [메서드 목록]
// - fetchInitial(...)        : 첫 검색 실행, 검색 조건 저장 + 상태 초기화
// - fetchMore()              : 무한스크롤 추가 로드 (현재 미동작)
// - fetchReturnFlights(...)  : 왕복 오는편 조회 (공항 반전)
// - selectDep(item)          : 가는편 선택
// - selectRet(item)          : 오는편 선택
// - _fetchPage(page)         : 내부 API 호출 (fetchInitial/fetchMore 공통)
// -----------------------------------------------------------------------------
// [파일 흐름과 순서]
// 1. SearchScreen 검색 버튼 → fetchInitial() 호출
//    → 검색 조건 저장 → 상태 초기화 → _fetchPage(1)
//    → GET /api/airport/flights → _items 채움 → FlightListScreen 표시
// 2. FlightListScreen 카드 클릭 → selectDep() 호출 → FlightDetailScreen 이동
// 3. FlightDetailScreen 진입 (왕복) → fetchReturnFlights() 자동 호출
//    → 공항 반전 후 오는편 조회 → _retItems 채움 → 오는편 목록 표시
// 4. 오는편 카드 클릭 → selectRet() → 항공권 요약 + 예약 버튼 표시
// 5. 재설정 모달 검색 버튼 → fetchInitial() 재호출 → 새 조건으로 재검색
// -----------------------------------------------------------------------------
// [주의사항 / 참고]
// - 스프링부트는 전체 데이터 한번에 반환 → hasMore = false 고정
// - TAGO API 페이지 방식 구조는 추후 서버 페이지 방식 전환 시 재활용 가능
// - fetchReturnFlights() 는 출발/도착 공항을 반전시켜 호출함에 주의
// - retDate 는 왕복일 때만 전달 (편도 시 null)
// =============================================================================