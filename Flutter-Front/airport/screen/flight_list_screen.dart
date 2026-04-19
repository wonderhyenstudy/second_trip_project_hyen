import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/flight_controller.dart';
import '../model/flight_item.dart';
import 'flight_detail_screen.dart';

/*여기어때 이미지랑 비교해서 구현한 것들:

정렬 필터 가로 스크롤 탭
항공사/편명 + 잔여석
출발→도착 시각 + 소요시간 + 직항
가격 표시
무한스크롤*/

class FlightListScreen extends StatefulWidget {
  const FlightListScreen({super.key});

  @override
  State<FlightListScreen> createState() => _FlightListScreenState();
}

class _FlightListScreenState extends State<FlightListScreen> {

  // ── 무한스크롤 ────────────────────────────────────────────
  final ScrollController _scrollController = ScrollController();

  // ── 정렬 상태 ─────────────────────────────────────────────
  String _sortType = '일정시간 빠른순';
  final List<String> _sortOptions = [
    '일정시간 빠른순',
    '가격 낮은순',
    '가격 높은순',
    '출발시간 빠른순',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final position = _scrollController.position;
    final isNearEnd = position.pixels >= position.maxScrollExtent - 200;
    if (isNearEnd) {
      context.read<FlightController>().fetchMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 날짜 요약 (20260420 → 4.20 월)
  String _formatDateSummary(String date) {
    if (date.length < 8) return '-';
    final dt = DateTime(
      int.parse(date.substring(0, 4)),
      int.parse(date.substring(4, 6)),
      int.parse(date.substring(6, 8)),
    );
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return '${dt.month}.${dt.day} ${days[dt.weekday - 1]}';
  }


  // ── 가격 포맷 ─────────────────────────────────────────────
  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    )}원';
  }

  // ── 시각 포맷 (20260421134000 → 13:40) ───────────────────
  String _formatTime(String? time) {
    if (time == null || time.length < 12) return '-';
    return '${time.substring(8, 10)}:${time.substring(10, 12)}';
  }

  // ── 소요시간 계산 ─────────────────────────────────────────
  String _duration(String? dep, String? arr) {
    if (dep == null || arr == null ||
        dep.length < 12 || arr.length < 12) return '-';
    final d = DateTime.parse(
        '${dep.substring(0, 4)}-${dep.substring(4, 6)}-${dep.substring(6, 8)} '
            '${dep.substring(8, 10)}:${dep.substring(10, 12)}:00');
    final a = DateTime.parse(
        '${arr.substring(0, 4)}-${arr.substring(4, 6)}-${arr.substring(6, 8)} '
            '${arr.substring(8, 10)}:${arr.substring(10, 12)}:00');
    final diff = a.difference(d);
    return '${diff.inHours}시간 ${diff.inMinutes % 60}분';
  }

  // ── 정렬 적용 ─────────────────────────────────────────────
  List<FlightItem> _sortedItems(List<FlightItem> items) {
    final sorted = List<FlightItem>.from(items);
    switch (_sortType) {
      case '가격 낮은순':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case '가격 높은순':
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case '출발시간 빠른순':
        sorted.sort((a, b) =>
            (a.depPlandTime ?? '').compareTo(b.depPlandTime ?? ''));
        break;
      default: // 일정시간 빠른순
        sorted.sort((a, b) =>
            (a.depPlandTime ?? '').compareTo(b.depPlandTime ?? ''));
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<FlightController>(
          builder: (_, c, __) => Text(
            '${FlightItem.getAirportName(c.depAirportId)} → '
                '${FlightItem.getAirportName(c.arrAirportId)}',
          ),
        ),
      ),
      body: Consumer<FlightController>(
        builder: (context, controller, _) {

          // 상태 1: 로딩 중
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 상태 2: 에러
          if (controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(controller.errorMessage!),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<FlightController>().fetchInitial(
                          depAirportId: controller.depAirportId,
                          arrAirportId: controller.arrAirportId,
                          depPlandTime: controller.depPlandTime,
                          isRoundTrip:  controller.isRoundTrip,
                          adultCount:   controller.adultCount,
                          childCount:   controller.childCount,
                          infantCount:  controller.infantCount,
                        ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          // 상태 3: 데이터 없음
          if (controller.items.isEmpty) {
            return const Center(child: Text('항공편이 없습니다'));
          }

          final sorted = _sortedItems(controller.items);


          return Column(
            children: [

              // ── 검색 조건 요약 바 ──────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                color: Colors.blue.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 날짜 + 요일
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateSummary(controller.depPlandTime),
                          style: const TextStyle(
                              fontSize: 13, color: Colors.blue),
                        ),
                      ],
                    ),

                    // 인원
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          '성인 ${controller.adultCount}'
                              '${controller.childCount > 0 ? ', 소아 ${controller.childCount}' : ''}'
                              '${controller.infantCount > 0 ? ', 유아 ${controller.infantCount}' : ''}',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.blue),
                        ),
                      ],
                    ),

                    // 재설정 버튼
                    GestureDetector(
                      onTap: () => _showResetModal(context, controller), // ✅ 수정
                      child: const Row(
                        children: [
                          Icon(Icons.tune, size: 14, color: Colors.blue),
                          SizedBox(width: 4),
                          Text(
                            '재설정',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),


              // ── 정렬 필터 ──────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                child: Row(
                  children: _sortOptions.map((option) {
                    final isSelected = _sortType == option;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _sortType = option),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ── 항공편 리스트 ──────────────────────────
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: sorted.length + 1,
                  itemBuilder: (context, index) {

                    // 마지막 인덱스
                    if (index == sorted.length) {
                      if (controller.isFetchingMore) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                              child: CircularProgressIndicator()),
                        );
                      }
                      if (!controller.hasMore) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              '모든 항공편을 불러왔습니다 ✅',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }

                    final item = sorted[index];
                    return _flightCard(context, item, controller);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── 재설정 모달 ───────────────────────────────────────────
  void _showResetModal(BuildContext context, FlightController controller) {
    // 현재 검색 조건 불러오기
    String? tempDep = controller.depAirportId;
    String? tempArr = controller.arrAirportId;
    DateTime tempDate = DateTime(
      int.parse(controller.depPlandTime.substring(0, 4)),
      int.parse(controller.depPlandTime.substring(4, 6)),
      int.parse(controller.depPlandTime.substring(6, 8)),
    );
    int tempAdult   = controller.adultCount;
    int tempChild   = controller.childCount;
    int tempInfant  = controller.infantCount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {

          String formatDisplay(DateTime date) {
            const days = ['월', '화', '수', '목', '금', '토', '일'];
            return '${date.month}.${date.day} ${days[date.weekday - 1]}';
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // 타이틀
                const Text(
                  '검색 조건 변경',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // ── 출발지 / 도착지 ────────────────────────
                const Text('출발지 / 도착지',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // 출발지
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final airports =
                          FlightItem.airportCodes.entries.toList();
                          await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('출발지 선택'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: airports.length,
                                  itemBuilder: (_, i) => ListTile(
                                    title: Text(airports[i].value),
                                    onTap: () {
                                      setModalState(
                                              () => tempDep = airports[i].key);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            FlightItem.getAirportName(tempDep),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),

                    // 교차 버튼
                    IconButton(
                      onPressed: () => setModalState(() {
                        final t = tempDep;
                        tempDep = tempArr;
                        tempArr = t;
                      }),
                      icon: const Icon(Icons.swap_horiz, color: Colors.blue),
                    ),

                    // 도착지
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final airports =
                          FlightItem.airportCodes.entries.toList();
                          await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('도착지 선택'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: airports.length,
                                  itemBuilder: (_, i) => ListTile(
                                    title: Text(airports[i].value),
                                    onTap: () {
                                      setModalState(
                                              () => tempArr = airports[i].key);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            FlightItem.getAirportName(tempArr),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── 날짜 ──────────────────────────────────
                const Text('출발 날짜',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: tempDate,
                      firstDate: now,
                      lastDate: DateTime(now.year + 1),
                    );
                    if (picked != null) {
                      setModalState(() => tempDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          formatDisplay(tempDate),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── 인원 ──────────────────────────────────
                const Text('인원',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 성인
                    _modalPassengerRow(
                      label: '성인',
                      count: tempAdult,
                      onMinus: () {
                        if (tempAdult > 1) {
                          setModalState(() => tempAdult--);
                        }
                      },
                      onPlus: () => setModalState(() => tempAdult++),
                    ),
                    // 소아
                    _modalPassengerRow(
                      label: '소아',
                      count: tempChild,
                      onMinus: () {
                        if (tempChild > 0) {
                          setModalState(() => tempChild--);
                        }
                      },
                      onPlus: () => setModalState(() => tempChild++),
                    ),
                    // 유아
                    _modalPassengerRow(
                      label: '유아',
                      count: tempInfant,
                      onMinus: () {
                        if (tempInfant > 0) {
                          setModalState(() => tempInfant--);
                        }
                      },
                      onPlus: () => setModalState(() => tempInfant++),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── 검색 버튼 ─────────────────────────────
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // 새 조건으로 검색
                    final dateStr =
                        '${tempDate.year}'
                        '${tempDate.month.toString().padLeft(2, '0')}'
                        '${tempDate.day.toString().padLeft(2, '0')}';

                    context.read<FlightController>().fetchInitial(
                      depAirportId: tempDep ?? controller.depAirportId,
                      arrAirportId: tempArr ?? controller.arrAirportId,
                      depPlandTime: dateStr,
                      isRoundTrip:  controller.isRoundTrip,
                      adultCount:   tempAdult,
                      childCount:   tempChild,
                      infantCount:  tempInfant,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    '검색',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

// ── 모달 인원 행 ──────────────────────────────────────────
  Widget _modalPassengerRow({
    required String label,
    required int count,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: Colors.grey)),
        Row(
          children: [
            IconButton(
              onPressed: onMinus,
              icon: const Icon(Icons.remove_circle_outline),
              color: count > 0 ? Colors.blue : Colors.grey,
              iconSize: 20,
            ),
            Text('$count',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: onPlus,
              icon: const Icon(Icons.add_circle_outline),
              color: Colors.blue,
              iconSize: 20,
            ),
          ],
        ),
      ],
    );
  }

  // ── 항공편 카드 ───────────────────────────────────────────
  Widget _flightCard(
      BuildContext context, FlightItem item, FlightController controller) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () {
          controller.selectDep(item);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const FlightDetailScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 항공사명 + 편명
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.airlineNm ?? '-'} ${item.flightNo ?? '-'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  // 잔여석
                  Text(
                    '잔여 ${item.seatsLeft}석',
                    style: TextStyle(
                      color: item.seatsLeft <= 10
                          ? Colors.red
                          : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 출발 → 도착 시각 + 소요시간
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 출발
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatTime(item.depPlandTime),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item.depAirportNm ?? '-',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),

                  // 소요시간
                  Column(
                    children: [
                      Text(
                        _duration(item.depPlandTime, item.arrPlandTime),
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12),
                      ),
                      const Icon(Icons.arrow_forward,
                          color: Colors.grey, size: 16),
                      const Text('직항',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),

                  // 도착
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTime(item.arrPlandTime),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item.arrAirportNm ?? '-',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 가격
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _formatPrice(item.price),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}