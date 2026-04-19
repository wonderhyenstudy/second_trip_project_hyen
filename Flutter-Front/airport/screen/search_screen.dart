import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/constants/app_colors.dart';       // ✅ [추가] AppColors
import '../../common/widget/app_base_layout.dart';
import '../../common/widget/common_button.dart';       // ✅ [추가] CommonButton
import '../controller/flight_controller.dart';
import '../model/flight_item.dart';
import '../utils/format_utils.dart';
import 'flight_list_screen.dart';
import 'my_reservation_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  // ── 상태 변수 ─────────────────────────────────────────────
  bool _isRoundTrip  = false;
  String? _selectedDep;
  String? _selectedArr;
  DateTime _depDate  = DateTime.now();
  DateTime _retDate  = DateTime.now().add(const Duration(days: 3));
  int _adultCount    = 1;
  int _childCount    = 0;
  int _infantCount   = 0;
  final List<Map<String, String>> _recentSearches = [];

  // ── 날짜 포맷 ─────────────────────────────────────────────
  // ✅ [변경 전] 직접 포맷 메서드 사용
  // String _formatDateApi(DateTime date) {
  //   return '${date.year}'
  //       '${date.month.toString().padLeft(2, '0')}'
  //       '${date.day.toString().padLeft(2, '0')}';
  // }
  // String _formatDateDisplay(DateTime date) {
  //   const days = ['월', '화', '수', '목', '금', '토', '일'];
  //   return '${date.month}.${date.day} ${days[date.weekday - 1]}';
  // }
  // ✅ [변경 후] FormatUtils 공통 메서드 사용

  // ── 날짜 선택 ─────────────────────────────────────────────
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
      // ✅ [디버그] 출발 날짜 선택 확인
      debugPrint('[SearchScreen] 출발 날짜 선택: ${FormatUtils.dateApi(picked)}');
    }
  }

  Future<void> _pickRetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _retDate,
      firstDate: _depDate,
      lastDate: DateTime(_depDate.year + 1),
    );
    if (picked != null) {
      setState(() => _retDate = picked);
      // ✅ [디버그] 귀환 날짜 선택 확인
      debugPrint('[SearchScreen] 귀환 날짜 선택: ${FormatUtils.dateApi(picked)}');
    }
  }

  // ── 출발지/도착지 교차 ────────────────────────────────────
  void _swapAirports() {
    setState(() {
      final temp   = _selectedDep;
      _selectedDep = _selectedArr;
      _selectedArr = temp;
    });
    // ✅ [디버그] 교차 결과 확인
    debugPrint('[SearchScreen] 교차 후 → 출발: $_selectedDep / 도착: $_selectedArr');
  }

  // ── 인원 선택 바텀시트 ────────────────────────────────────
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                _passengerRow(
                  label: '성인',
                  sub: '만 12세 이상',
                  count: _adultCount,
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
                  label: '소아',
                  sub: '만 2세 ~ 12세 미만',
                  count: _childCount,
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
                  label: '유아',
                  sub: '만 24개월 미만',
                  count: _infantCount,
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

                // ✅ [변경 전] ElevatedButton 직접 사용
                // ElevatedButton(
                //   onPressed: () => Navigator.pop(context),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.blue,
                //     foregroundColor: Colors.white,
                //     padding: const EdgeInsets.symmetric(vertical: 14),
                //   ),
                //   child: const Text('적용'),
                // ),
                // ✅ [변경 후] CommonButton 공통 위젯 사용
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
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(sub,
                // ✅ [변경 전] Colors.grey 하드코딩
                // style: const TextStyle(color: Colors.grey, fontSize: 12)),
                // ✅ [변경 후] AppColors 사용
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: onMinus,
              icon: const Icon(Icons.remove_circle_outline),
              // ✅ [변경 전] Colors.blue / Colors.grey 하드코딩
              // color: count > 0 ? Colors.blue : Colors.grey,
              // ✅ [변경 후] AppColors 사용
              color: count > 0 ? AppColors.primary : AppColors.textSecondary,
            ),
            Text('$count',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: onPlus,
              icon: const Icon(Icons.add_circle_outline),
              // ✅ [변경 전] Colors.blue 하드코딩
              // color: Colors.blue,
              // ✅ [변경 후] AppColors 사용
              color: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  // ── 검색 버튼 ─────────────────────────────────────────────
  void _onSearch() {
    // ✅ [디버그] 검색 시작
    debugPrint('[SearchScreen] 검색 버튼 눌림');
    debugPrint('[SearchScreen] 출발: $_selectedDep / 도착: $_selectedArr');
    debugPrint('[SearchScreen] 날짜: ${FormatUtils.dateApi(_depDate)}');
    debugPrint('[SearchScreen] 왕복: $_isRoundTrip / 인원: $_adultCount명');

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

    // ✅ [변경 전] 인원 표시 직접 문자열 조합
    // '성인 $_adultCount'
    // '${_childCount > 0 ? ', 소아 $_childCount' : ''}'
    // '${_infantCount > 0 ? ', 유아 $_infantCount' : ''}'
    // ', 전체'
    // ✅ [변경 후] FormatUtils.passenger() 사용

    // ✅ 최근 검색 기록 저장
    setState(() {
      _recentSearches.insert(0, {
        'dep'        : FlightItem.getAirportName(_selectedDep),
        'arr'        : FlightItem.getAirportName(_selectedArr),
        // ✅ [변경 전] _formatDateDisplay(_depDate)
        // ✅ [변경 후] FormatUtils.dateDisplay() 사용
        'date'       : FormatUtils.dateDisplay(_depDate),
        'isRoundTrip': _isRoundTrip ? '왕복' : '편도',
      });
      if (_recentSearches.length > 5) _recentSearches.removeLast();
    });

    context.read<FlightController>().fetchInitial(
      depAirportId: _selectedDep!,
      arrAirportId: _selectedArr!,
      // ✅ [변경 전] _formatDateApi(_depDate)
      // ✅ [변경 후] FormatUtils.dateApi() 사용
      depPlandTime: FormatUtils.dateApi(_depDate),
      isRoundTrip:  _isRoundTrip,
      adultCount:   _adultCount,
      childCount:   _childCount,
      infantCount:  _infantCount,
      retDate:      _isRoundTrip ? _retDate : null,
    );

    // ✅ [디버그] 리스트 화면 이동 확인
    debugPrint('[SearchScreen] FlightListScreen 으로 이동');

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FlightListScreen()),
    );
  }

  // ── 공항 선택 바텀시트 ────────────────────────────────────
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
              if (isDep) {
                _selectedDep = airports[i].key;
              } else {
                _selectedArr = airports[i].key;
              }
            });
            // ✅ [디버그] 공항 선택 확인
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
    // ✅ [변경 전] Scaffold + AppBar 직접 사용
    // return Scaffold(
    //   appBar: AppBar(title: const Text('항공')),
    // ✅ [변경 후] AppBaseLayout 공통 레이아웃 사용
    return AppBaseLayout(
      title: '항공',

      // ✅ 앱바 우측에 예약내역 아이콘
      // 추후 삭제예정
      actions: [
        IconButton(
          icon: const Icon(Icons.receipt_long),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const MyReservationScreen()),
          ),
        ),
      ],


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
                            // ✅ [변경 전] Colors.blue / Colors.transparent
                            // ✅ [변경 후] AppColors 사용
                            color: !_isRoundTrip
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        '편도',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // ✅ [변경 전] Colors.blue / Colors.grey
                          // ✅ [변경 후] AppColors 사용
                          color: !_isRoundTrip
                              ? AppColors.primary
                              : AppColors.textSecondary,
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
                            color: _isRoundTrip
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        '왕복',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _isRoundTrip
                              ? AppColors.primary
                              : AppColors.textSecondary,
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
                    // ✅ [변경 전] Colors.grey.shade300
                    // ✅ [변경 후] AppColors 사용
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.circle_outlined,
                            // ✅ [변경 전] Colors.blue
                            // ✅ [변경 후] AppColors 사용
                            color: AppColors.primary, size: 16),
                        title: Text(
                          _selectedDep != null
                              ? FlightItem.getAirportName(_selectedDep)
                              : '출발지',
                          style: TextStyle(
                            // ✅ [변경 전] Colors.black / Colors.grey
                            // ✅ [변경 후] AppColors 사용
                            color: _selectedDep != null
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: _selectedDep != null
                            ? Text(_selectedDep!)
                            : null,
                        onTap: () => _showAirportPicker(isDep: true),
                      ),

                      const Divider(height: 1),

                      ListTile(
                        leading: const Icon(Icons.location_on,
                            color: AppColors.primary, size: 16),
                        title: Text(
                          _selectedArr != null
                              ? FlightItem.getAirportName(_selectedArr)
                              : '도착지',
                          style: TextStyle(
                            color: _selectedArr != null
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: _selectedArr != null
                            ? Text(_selectedArr!)
                            : null,
                        onTap: () => _showAirportPicker(isDep: false),
                      ),
                    ],
                  ),
                ),

                // 교차 버튼
                Positioned(
                  right: 16,
                  child: GestureDetector(
                    onTap: _swapAirports,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        // ✅ [변경 전] Colors.white
                        // ✅ [변경 후] AppColors 사용
                        color: AppColors.backgroundWhite,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.swap_vert,
                        // ✅ [변경 전] Colors.blue
                        // ✅ [변경 후] AppColors 사용
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── 날짜 선택 ─────────────────────────────────
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
                          const Text('출발',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            // ✅ [변경 전] _formatDateDisplay(_depDate)
                            // ✅ [변경 후] FormatUtils.dateDisplay() 사용
                            FormatUtils.dateDisplay(_depDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
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
                            const Text('귀환',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              FormatUtils.dateDisplay(_retDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
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
                    const Icon(Icons.person_outline,
                        color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      // ✅ [변경 전] 직접 문자열 조합
                      // '성인 $_adultCount'
                      // '${_childCount > 0 ? ', 소아 $_childCount' : ''}'
                      // '${_infantCount > 0 ? ', 유아 $_infantCount' : ''}'
                      // ', 전체'
                      // ✅ [변경 후] FormatUtils.passenger() 사용
                      FormatUtils.passenger(
                          _adultCount, _childCount, _infantCount),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── 검색 버튼 ─────────────────────────────────
            // ✅ [변경 전] ElevatedButton 직접 사용
            // ElevatedButton(
            //   onPressed: _onSearch,
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.blue,
            //     foregroundColor: Colors.white,
            //     padding: const EdgeInsets.symmetric(vertical: 16),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //   ),
            //   child: const Text('검색',
            //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            // ),
            // ✅ [변경 후] CommonButton 공통 위젯 사용
            CommonButton(
              text: '검색',
              onPressed: _onSearch,
            ),

            // ── 최근 검색 기록 ────────────────────────────
            if (_recentSearches.isNotEmpty) ...[
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '최근 검색 기록',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _recentSearches.clear());
                      // ✅ [디버그] 전체 삭제 확인
                      debugPrint('[SearchScreen] 최근 검색 기록 전체 삭제');
                    },
                    child: const Text('전체삭제',
                        style: TextStyle(
                            color: AppColors.textSecondary)),
                  ),
                ],
              ),
              ...(_recentSearches.map((r) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history,
                    color: AppColors.textSecondary),
                title: Text(
                  '${r['dep']} → ${r['arr']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${r['date']} · ${r['isRoundTrip']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.close,
                      size: 16, color: AppColors.textSecondary),
                  onPressed: () {
                    setState(() => _recentSearches.remove(r));
                    // ✅ [디버그] 개별 삭제 확인
                    debugPrint('[SearchScreen] 최근 검색 기록 삭제: $r');
                  },
                ),
                onTap: () {
                  // ✅ [추후 구현] 최근 검색 기록 클릭 시 재검색
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