import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/constants/app_colors.dart';
import '../../common/widget/app_base_layout.dart';
import '../../common/widget/common_button.dart';
import '../controller/flight_controller.dart';
import '../model/flight_item.dart';
import '../utils/format_utils.dart';
import 'flight_list_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  // ── 상태 변수 ─────────────────────────────────────────────
  // _isRoundTrip   : 편도(false) / 왕복(true) 선택 상태
  // _selectedDep   : 선택한 출발 공항코드 (예: GIMHAE)
  // _selectedArr   : 선택한 도착 공항코드 (예: JEJU)
  // _depDate       : 출발 날짜
  // _retDate       : 귀환 날짜 (왕복일 때만 사용, 기본 출발일 +3일)
  // _recentSearches: 최근 검색 기록 (최대 5개, 앱 재시작 시 초기화됨)
  bool    _isRoundTrip = false;
  String? _selectedDep;
  String? _selectedArr;
  DateTime _depDate = DateTime.now();
  DateTime _retDate = DateTime.now().add(const Duration(days: 3));
  int _adultCount  = 1;
  int _childCount  = 0;
  int _infantCount = 0;
  final List<Map<String, String>> _recentSearches = [];

  // ── 출발 날짜 선택 ────────────────────────────────────────
  // 출발일 변경 시 귀환일이 이전이면 자동으로 출발일 +3일로 조정
  Future<void> _pickDepDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _depDate,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _depDate = picked;
        if (_retDate.isBefore(picked)) {
          _retDate = picked.add(const Duration(days: 3));
        }
      });
      debugPrint('[SearchScreen] 출발 날짜 선택: ${FormatUtils.dateApi(picked)}');
    }
  }

  // ── 귀환 날짜 선택 (왕복일 때만 표시) ───────────────────
  // firstDate 를 출발일로 설정하여 출발일보다 이전 날짜 선택 불가
  Future<void> _pickRetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _retDate,
      firstDate: _depDate,
      lastDate: DateTime(_depDate.year + 1),
    );
    if (picked != null) {
      setState(() => _retDate = picked);
      debugPrint('[SearchScreen] 귀환 날짜 선택: ${FormatUtils.dateApi(picked)}');
    }
  }

  // ── 출발지/도착지 교차 ────────────────────────────────────
  // 교차 버튼 클릭 시 출발/도착 공항코드 스왑
  void _swapAirports() {
    setState(() {
      final temp   = _selectedDep;
      _selectedDep = _selectedArr;
      _selectedArr = temp;
    });
    debugPrint('[SearchScreen] 교차 후 → 출발: $_selectedDep / 도착: $_selectedArr');
  }

  // ── 인원 선택 바텀시트 ────────────────────────────────────
  // 성인(최소 1명) / 소아(만 2~12세) / 유아(만 24개월 미만) 선택
  // setModalState + setState 동시 호출로 모달 내부 + 외부 화면 동시 갱신
  void _showPassengerDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '인원을 선택해주세요.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                _passengerRow(
                  label: '성인', sub: '만 12세 이상', count: _adultCount,
                  onMinus: () {
                    if (_adultCount > 1) {
                      setModalState(() => _adultCount--);
                      setState(() {});
                    }
                  },
                  onPlus: () {
                    setModalState(() => _adultCount++);
                    setState(() {});
                  },
                ),
                const Divider(height: 32),
                _passengerRow(
                  label: '소아', sub: '만 2세 ~ 12세 미만', count: _childCount,
                  onMinus: () {
                    if (_childCount > 0) {
                      setModalState(() => _childCount--);
                      setState(() {});
                    }
                  },
                  onPlus: () {
                    setModalState(() => _childCount++);
                    setState(() {});
                  },
                ),
                const Divider(height: 32),
                _passengerRow(
                  label: '유아', sub: '만 24개월 미만', count: _infantCount,
                  onMinus: () {
                    if (_infantCount > 0) {
                      setModalState(() => _infantCount--);
                      setState(() {});
                    }
                  },
                  onPlus: () {
                    setModalState(() => _infantCount++);
                    setState(() {});
                  },
                ),

                const SizedBox(height: 24),
                CommonButton(
                  text: '적용',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── 인원 행 위젯 ──────────────────────────────────────────
  // label: 성인/소아/유아, sub: 나이 기준 설명
  // count: 현재 선택 수, onMinus/onPlus: 감소/증가 콜백
  Widget _passengerRow({
    required String label,
    required String sub,
    required int count,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(sub, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: onMinus,
              icon: const Icon(Icons.remove_circle_outline),
              color: count > 0 ? AppColors.primary : AppColors.textSecondary,
            ),
            Text('$count', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: onPlus,
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  // ── 검색 실행 ─────────────────────────────────────────────
  // 유효성 검사(출발/도착/중복) → 최근 검색 저장 →
  // FlightController.fetchInitial() 호출 → FlightListScreen 이동
  void _onSearch() {
    debugPrint('[SearchScreen] 검색 버튼 눌림');
    debugPrint('[SearchScreen] 출발: $_selectedDep / 도착: $_selectedArr');
    debugPrint('[SearchScreen] 날짜: ${FormatUtils.dateApi(_depDate)}');
    debugPrint('[SearchScreen] 왕복: $_isRoundTrip / 성인: $_adultCount / 소아: $_childCount / 유아: $_infantCount');

    // 유효성 검사
    if (_selectedDep == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('출발 공항을 선택해주세요')));
      return;
    }
    if (_selectedArr == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('도착 공항을 선택해주세요')));
      return;
    }
    if (_selectedDep == _selectedArr) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('출발지와 도착지가 같습니다')));
      return;
    }

    // 최근 검색 기록 저장 (맨 앞에 추가, 최대 5개 유지)
    setState(() {
      _recentSearches.insert(0, {
        'dep'        : FlightItem.getAirportName(_selectedDep),
        'arr'        : FlightItem.getAirportName(_selectedArr),
        'date'       : FormatUtils.dateDisplay(_depDate),
        'isRoundTrip': _isRoundTrip ? '왕복' : '편도',
      });
      if (_recentSearches.length > 5) _recentSearches.removeLast();
    });

    // FlightController 에 검색 조건 전달 후 목록 조회
    context.read<FlightController>().fetchInitial(
      depAirportId: _selectedDep!,
      arrAirportId: _selectedArr!,
      depPlandTime: FormatUtils.dateApi(_depDate),
      isRoundTrip:  _isRoundTrip,
      adultCount:   _adultCount,
      childCount:   _childCount,
      infantCount:  _infantCount,
      retDate:      _isRoundTrip ? _retDate : null,
    );

    debugPrint('[SearchScreen] FlightListScreen 으로 이동');
    Navigator.push(context, MaterialPageRoute(builder: (_) => const FlightListScreen()));
  }

  // ── 공항 선택 바텀시트 ────────────────────────────────────
  // isDep: true = 출발지 선택 / false = 도착지 선택
  // FlightItem.airportCodes 에서 공항 목록 로드
  void _showAirportPicker({required bool isDep}) {
    final airports = FlightItem.airportCodes.entries.toList();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ListView.builder(
        itemCount: airports.length,
        itemBuilder: (_, i) => ListTile(
          title: Text(airports[i].value),
          subtitle: Text(airports[i].key),
          onTap: () {
            setState(() {
              if (isDep) _selectedDep = airports[i].key;
              else       _selectedArr = airports[i].key;
            });
            debugPrint('[SearchScreen] 공항 선택 → '
                '${isDep ? "출발" : "도착"}: ${airports[i].key}');
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBaseLayout(
      title: '항공',
      // 앱바 우측 예약내역 아이콘 → 추후 삭제 예정 (MyBookingScreen 에서 접근)
      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.receipt_long),
      //     onPressed: () => Navigator.push(context,
      //         MaterialPageRoute(builder: (_) => const MyReservationScreen())),
      //   ),
      // ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── 편도 / 왕복 탭 ────────────────────────────
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isRoundTrip = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: !_isRoundTrip ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        '편도',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !_isRoundTrip ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isRoundTrip = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _isRoundTrip ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        '왕복',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _isRoundTrip ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── 출발지 / 도착지 + 교차 버튼 ──────────────
            Stack(
              alignment: Alignment.centerRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.circle_outlined, color: AppColors.primary, size: 16),
                        title: Text(
                          _selectedDep != null ? FlightItem.getAirportName(_selectedDep) : '출발지',
                          style: TextStyle(
                            color: _selectedDep != null ? AppColors.textPrimary : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: _selectedDep != null ? Text(_selectedDep!) : null,
                        onTap: () => _showAirportPicker(isDep: true),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.location_on, color: AppColors.primary, size: 16),
                        title: Text(
                          _selectedArr != null ? FlightItem.getAirportName(_selectedArr) : '도착지',
                          style: TextStyle(
                            color: _selectedArr != null ? AppColors.textPrimary : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: _selectedArr != null ? Text(_selectedArr!) : null,
                        onTap: () => _showAirportPicker(isDep: false),
                      ),
                    ],
                  ),
                ),
                // 출발지/도착지 교차 버튼
                Positioned(
                  right: 16,
                  child: GestureDetector(
                    onTap: _swapAirports,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.swap_vert, color: AppColors.primary, size: 20),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── 날짜 선택 (왕복이면 귀환 날짜 추가 표시) ──
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDepDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('출발', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(FormatUtils.dateDisplay(_depDate),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isRoundTrip) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickRetDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('귀환', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(FormatUtils.dateDisplay(_retDate),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // ── 인원 선택 ─────────────────────────────────
            GestureDetector(
              onTap: _showPassengerDialog,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      FormatUtils.passenger(_adultCount, _childCount, _infantCount),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── 검색 버튼 ─────────────────────────────────
            CommonButton(text: '검색', onPressed: _onSearch),

            // ── 최근 검색 기록 (검색 이력이 있을 때만 표시) ──
            if (_recentSearches.isNotEmpty) ...[
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('최근 검색 기록',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  TextButton(
                    onPressed: () {
                      setState(() => _recentSearches.clear());
                      debugPrint('[SearchScreen] 최근 검색 기록 전체 삭제');
                    },
                    child: const Text('전체삭제',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              ),
              ...(_recentSearches.map((r) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history, color: AppColors.textSecondary),
                title: Text('${r['dep']} → ${r['arr']}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${r['date']} · ${r['isRoundTrip']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                  onPressed: () {
                    setState(() => _recentSearches.remove(r));
                    debugPrint('[SearchScreen] 최근 검색 기록 개별 삭제: $r');
                  },
                ),
                onTap: () {
                  // TODO: 최근 검색 기록 클릭 시 해당 조건으로 재검색 기능 추가 예정
                  debugPrint('[SearchScreen] 최근 검색 기록 클릭: $r');
                },
              ))),
            ],

          ],
        ),
      ),
    );
  }
}

// =============================================================================
// [파일 정보]
// 위치  : lib/airport/screen/search_screen.dart
// 역할  : 항공 검색 시작 화면 (출발지/도착지/날짜/인원 선택)
// 사용처 : 메인 라우팅 /airport 진입점
// -----------------------------------------------------------------------------
// [연관 파일]
// - flight_controller.dart  : fetchInitial() 호출 (검색 실행)
// - flight_item.dart        : airportCodes (공항 목록), getAirportName()
// - format_utils.dart       : dateApi(), dateDisplay(), passenger()
// - flight_list_screen.dart : 검색 후 이동하는 목록 화면
// -----------------------------------------------------------------------------
// [변경 이력]
// - 최초 작성 : Scaffold + AppBar 직접 사용, 직접 포맷 메서드 사용
// - 변경       : AppBaseLayout 공통 레이아웃 적용
//               Colors.blue → AppColors.primary 통일
//               ElevatedButton → CommonButton 적용
//               직접 포맷 메서드 → FormatUtils 공통 유틸로 통일
//               앱바 우측 예약내역 아이콘 주석 처리 (MyBookingScreen 에서 접근)
// -----------------------------------------------------------------------------
// [메서드 목록]
// - _pickDepDate()          : 출발 날짜 선택 (DatePicker)
// - _pickRetDate()          : 귀환 날짜 선택 (왕복일 때만 표시)
// - _swapAirports()         : 출발지/도착지 교차
// - _showPassengerDialog()  : 인원 선택 바텀시트
// - _passengerRow(...)      : 인원 행 위젯 (성인/소아/유아 공통)
// - _onSearch()             : 검색 유효성 검사 + FlightController 호출
// - _showAirportPicker(...) : 공항 선택 바텀시트
// - build()                 : 화면 구성
// -----------------------------------------------------------------------------
// [파일 흐름과 순서]
// 1. 앱 진입 → SearchScreen 표시 (편도 기본값)
// 2. 편도/왕복 탭 선택 → _isRoundTrip 변경 → 귀환 날짜 표시/숨김
// 3. 출발지/도착지 선택 → _showAirportPicker() → _selectedDep/Arr 저장
// 4. 날짜 선택 → _pickDepDate() / _pickRetDate()
// 5. 인원 선택 → _showPassengerDialog() → _adultCount 등 갱신
// 6. 검색 버튼 → _onSearch() → 유효성 검사 → fetchInitial() 호출
//    → FlightListScreen 으로 이동
// -----------------------------------------------------------------------------
// [주의사항 / 참고]
// - 최근 검색 기록은 앱 메모리에만 저장 (앱 재시작 시 초기화)
// - 왕복 선택 시 retDate 를 fetchInitial() 에 전달해야 오는편 조회 가능
// - 출발일 변경 시 귀환일이 이전이면 자동으로 +3일 조정됨
// - TODO: 최근 검색 기록 클릭 시 재검색 기능 미구현
// =============================================================================