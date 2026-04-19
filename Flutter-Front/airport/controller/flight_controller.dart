import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../common/constants/api_constants.dart';
import '../model/flight_item.dart';

class FlightController with ChangeNotifier {

  // ── 상태 변수 ─────────────────────────────────────────────
  final List<FlightItem> _items = [];
  bool    _isLoading     = false;
  String? _errorMessage;

  List<FlightItem> get items        => _items;
  bool             get isLoading    => _isLoading;
  String?          get errorMessage => _errorMessage;

  // ── 페이지네이션 ──────────────────────────────────────────
  bool _isFetchingMore = false;
  bool _hasMore        = true;
  int  _currentPage    = 1;

  bool get isFetchingMore => _isFetchingMore;
  bool get hasMore        => _hasMore;

  // ── 검색 조건 저장 ────────────────────────────────────────
  String    _depAirportId = '';
  String    _arrAirportId = '';
  String    _depPlandTime = '';
  bool      _isRoundTrip  = false;
  int       _adultCount   = 1;
  int       _childCount   = 0;
  int       _infantCount  = 0;
  DateTime? _retDate;
  String    _depAirportNm = '';
  String    _arrAirportNm = '';

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

  // ── 왕복 오는편 ───────────────────────────────────────────
  final List<FlightItem> _retItems = [];
  List<FlightItem> get retItems => _retItems;

  // ── 선택한 가는편 / 오는편 ────────────────────────────────
  FlightItem? _selectedDep;
  FlightItem? _selectedRet;

  FlightItem? get selectedDep => _selectedDep;
  FlightItem? get selectedRet => _selectedRet;

  void selectDep(FlightItem item) {
    _selectedDep = item;
    debugPrint('[FlightController] 가는편 선택: '
        '${item.airlineNm} ${item.flightNo}');
    notifyListeners();
  }

  void selectRet(FlightItem item) {
    _selectedRet = item;
    debugPrint('[FlightController] 오는편 선택: '
        '${item.airlineNm} ${item.flightNo}');
    notifyListeners();
  }

  // ── 첫 검색 ───────────────────────────────────────────────
  Future<void> fetchInitial({
    required String depAirportId,
    required String arrAirportId,
    required String depPlandTime,
    required bool isRoundTrip,
    required int adultCount,
    required int childCount,
    required int infantCount,
    DateTime? retDate,
  }) async {
    if (_isLoading) return;

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

    _isLoading    = true;
    _errorMessage = null;
    _currentPage  = 1;
    _hasMore      = true;
    _items.clear();
    _selectedDep  = null;
    _selectedRet  = null;
    notifyListeners();

    debugPrint('[FlightController] 검색 시작 → '
        '출발: $depAirportId / 도착: $arrAirportId / 날짜: $depPlandTime');

    await _fetchPage(_currentPage);

    _isLoading = false;
    notifyListeners();
  }

  // ── 무한스크롤 ────────────────────────────────────────────
  Future<void> fetchMore() async {
    if (_isFetchingMore) return;
    if (!_hasMore)       return;
    if (_isLoading)      return;

    _isFetchingMore = true;
    _currentPage++;
    notifyListeners();

    await _fetchPage(_currentPage);

    _isFetchingMore = false;
    notifyListeners();
  }

  // ── 왕복 오는편 조회 ──────────────────────────────────────
  Future<void> fetchReturnFlights({
    required String retPlandTime,
  }) async {
    _retItems.clear();
    notifyListeners();

    debugPrint('[FlightController] 오는편 조회 → '
        '출발: $_arrAirportId / 도착: $_depAirportId / 날짜: $retPlandTime');

    try {
      // final baseUrl = dotenv.env['SPRING_BASE_URL'] ?? '';
      // final url = '$baseUrl/airport/flights'
      final baseUrl = ApiConstants.baseUrl;
      // final url = '${baseUrl}api/airport/flights'
      final url = '$baseUrl/api/airport/flights'
          '?depAirportId=$_arrAirportId'
          '&arrAirportId=$_depAirportId'
          '&depPlandTime=$retPlandTime';

      debugPrint('[FlightController] 오는편 요청 URL: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes));
        _retItems.addAll(
          data.map((e) => FlightItem.fromJson(e)).toList(),
        );
        debugPrint('[FlightController] 오는편 조회 완료 → ${_retItems.length}건');
      } else {
        debugPrint('[FlightController] 오는편 오류: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[FlightController] 오는편 네트워크 오류: $e');
    }
    notifyListeners();
  }

  // ── 실제 API 호출 (스프링부트) ────────────────────────────
  // ✅ [변경 전] TAGO API
  // Future<void> _fetchPage(int page) async {
  //   final apiKey = dotenv.env['TAGO_API_KEY'] ?? '';
  //   final uri = Uri.http(
  //     'apis.data.go.kr',
  //     '/1613000/DmstcFlightNvgInfoService/getFlightOpratInfoList',
  //     {
  //       'serviceKey'   : apiKey,
  //       'pageNo'       : page.toString(),
  //       'numOfRows'    : '10',
  //       'depAirportId' : _depAirportId,
  //       'arrAirportId' : _arrAirportId,
  //       'depPlandTime' : _depPlandTime,
  //       '_type'        : 'json',
  //     },
  //   );
  // }
  // ✅ [변경 후] 스프링부트 API
  Future<void> _fetchPage(int page) async {
    // final baseUrl = dotenv.env['SPRING_BASE_URL'] ?? '';
    // final url = '$baseUrl/airport/flights'
    final baseUrl = ApiConstants.baseUrl;

    // final url = '${baseUrl}api/airport/flights'
    final url = '$baseUrl/api/airport/flights'
        '?depAirportId=$_depAirportId'
        '&arrAirportId=$_arrAirportId'
        '&depPlandTime=$_depPlandTime';

    debugPrint('[FlightController] 요청 URL: $url');

    try {
      final response = await http.get(Uri.parse(url));
      debugPrint('[FlightController] 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes));

        debugPrint('[FlightController] 응답 데이터: ${data.length}건');

        _items.addAll(
          data.map((e) => FlightItem.fromJson(e)).toList(),
        );

        // ✅ 스프링부트는 전체 데이터 한번에 반환
        _hasMore = false;

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