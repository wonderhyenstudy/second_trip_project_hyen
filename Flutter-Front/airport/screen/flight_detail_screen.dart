import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/constants/app_colors.dart';
import '../../common/widget/app_base_layout.dart';
import '../../common/widget/common_button.dart';
import '../constants/airport_constants.dart';
import '../controller/flight_controller.dart';
import '../model/flight_item.dart';
import '../utils/format_utils.dart';
import 'reservation_screen.dart';

class FlightDetailScreen extends StatefulWidget {
  const FlightDetailScreen({super.key});

  @override
  State<FlightDetailScreen> createState() => _FlightDetailScreenState();
}

class _FlightDetailScreenState extends State<FlightDetailScreen> {

  // ── API용 날짜 포맷 (DateTime → 20260421) ────────────────
  // fetchReturnFlights() 파라미터로 전달 시 사용
  String _formatDateApi(DateTime date) {
    return '${date.year}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ── 표시용 날짜 포맷 (DateTime → 4.21 화) ────────────────
  // 오는편 섹션 타이틀에 날짜 표시 시 사용
  String _formatDateDisplay(DateTime? date) {
    if (date == null) return '-';
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return '${date.month}.${date.day} ${days[date.weekday - 1]}';
  }

  @override
  void initState() {
    super.initState();
    // 화면 빌드 완료 후 왕복 오는편 자동 조회
    // 편도일 때는 호출하지 않음
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<FlightController>();
      if (controller.isRoundTrip && controller.retDate != null) {
        debugPrint('[FlightDetailScreen] 왕복 오는편 자동 조회 시작');
        controller.fetchReturnFlights(
          retPlandTime: _formatDateApi(controller.retDate!),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FlightController>();
    final dep = controller.selectedDep;

    // 선택된 가는편 없으면 에러 화면 표시 (비정상 진입 방지)
    if (dep == null) {
      debugPrint('[FlightDetailScreen] 선택된 가는편 없음 → 에러 표시');
      return const Scaffold(
        body: Center(child: Text('항공편 정보가 없습니다')),
      );
    }

    // 총 인원 (성인 + 소아 + 유아) → 결제 예상금액 계산에 사용
    final totalPassengers =
        controller.adultCount + controller.childCount + controller.infantCount;

    return AppBaseLayout(
      title: '${controller.depAirportNm} - ${controller.arrAirportNm}',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── 선택한 가는편 ─────────────────────────────
            // [변경] 버튼 클릭 시 FlightListScreen 으로 복귀
            _sectionTitleWithAction(
              title: '선택한 가는편',
              onTap: () {
                debugPrint('[FlightDetailScreen] 가는편 변경 → FlightListScreen 복귀');
                Navigator.pop(context);
              },
            ),
            _flightCard(dep),

            const SizedBox(height: 24),

            // ── 왕복: 오는편 선택 ─────────────────────────
            // 왕복일 때만 표시, retDate 있으면 타이틀에 날짜 표시
            // fetchReturnFlights() 로 조회한 _retItems 목록 표시
            if (controller.isRoundTrip) ...[
              _sectionTitleWithAction(
                title: '오는편 선택'
                    '${controller.retDate != null
                    ? ' · ${_formatDateDisplay(controller.retDate)}' : ''}',
                onTap: null,
              ),

              const SizedBox(height: 12),

              if (controller.retItems.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('오는편 항공편이 없습니다'),
                  ),
                )
              else
                ...controller.retItems.map((retItem) {
                  final isSelected =
                      controller.selectedRet?.flightNo == retItem.flightNo;
                  return GestureDetector(
                    onTap: () {
                      debugPrint('[FlightDetailScreen] 오는편 선택: '
                          '${retItem.airlineNm} ${retItem.flightNo}');
                      controller.selectRet(retItem);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        // 선택된 항공편: primary 테두리 2px / 미선택: 기본 테두리 1px
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _flightCard(retItem),
                    ),
                  );
                }),

              const SizedBox(height: 24),
            ],

            // ── 선택한 항공권 요약 ────────────────────────
            // 편도: 가는편 선택 시 바로 표시
            // 왕복: 오는편까지 선택 완료 후 표시
            if (!controller.isRoundTrip || controller.selectedRet != null) ...[
              _sectionTitleWithAction(title: '선택한 항공권', onTap: null),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [

                    // 가는편 요약
                    _summaryRow(
                      label: '가는편',
                      time: '${FormatUtils.time(dep.depPlandTime)} - '
                          '${FormatUtils.time(dep.arrPlandTime)}',
                      info: '${dep.depAirportNm ?? '-'}, '
                          '${dep.airlineNm ?? '-'} ${dep.flightNo ?? '-'}',
                      price: dep.price,
                    ),

                    // 오는편 요약 (왕복일 때)
                    if (controller.isRoundTrip && controller.selectedRet != null) ...[
                      const Divider(height: 20),
                      _summaryRow(
                        label: '오는편',
                        time: '${FormatUtils.time(controller.selectedRet!.depPlandTime)} - '
                            '${FormatUtils.time(controller.selectedRet!.arrPlandTime)}',
                        info: '${controller.selectedRet!.depAirportNm ?? '-'}, '
                            '${controller.selectedRet!.airlineNm ?? '-'} '
                            '${controller.selectedRet!.flightNo ?? '-'}',
                        price: controller.selectedRet!.price,
                      ),
                    ],

                    const Divider(height: 20),

                    // 발급 수수료 (AirportConstants.issueFee = 1,000원)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('발급 수수료',
                            style: TextStyle(color: AppColors.textSecondary)),
                        Text(FormatUtils.price(AirportConstants.issueFee),
                            style: const TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // 결제 예상금액: (가는편 + 오는편) × 총인원 + 발급수수료
                    // 소아/유아 차등 적용은 ReservationScreen 에서 처리
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '결제 예상금액 ($totalPassengers명)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          FormatUtils.price(
                            (dep.price + (controller.selectedRet?.price ?? 0)) *
                                totalPassengers + AirportConstants.issueFee,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── 항공권 예약 버튼 ──────────────────────
              // 비로그인: 스낵바 → 로그인 화면 → 로그인 성공 시 ReservationScreen
              // 로그인: 바로 ReservationScreen 이동
              CommonButton(
                text: '항공권 예약',
                onPressed: () async {
                  debugPrint('[FlightDetailScreen] 항공권 예약 버튼 클릭');
                  final prefs = await SharedPreferences.getInstance();
                  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
                  debugPrint('[FlightDetailScreen] 로그인 상태: $isLoggedIn');

                  if (!mounted) return;

                  if (!isLoggedIn) {
                    // 비로그인 → 로그인 화면으로 이동
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('로그인이 필요한 서비스입니다.')),
                    );
                    await Navigator.pushNamed(context, '/login');

                    if (!mounted) return;
                    final prefsAfter = await SharedPreferences.getInstance();
                    final isLoggedInAfter = prefsAfter.getBool('isLoggedIn') ?? false;
                    debugPrint('[FlightDetailScreen] 로그인 후 상태: $isLoggedInAfter');

                    if (isLoggedInAfter) {
                      // 로그인 성공 → ReservationScreen 이동
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ReservationScreen()));
                    }
                    return;
                  }

                  // 로그인 상태 → 바로 ReservationScreen 이동
                  debugPrint('[FlightDetailScreen] ReservationScreen 으로 이동');
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ReservationScreen()));
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── 섹션 타이틀 + [변경] 버튼 ────────────────────────────
  // onTap 이 null 이면 [변경] 버튼 숨김
  // onTap 이 있으면 오른쪽에 [변경] 텍스트 버튼 표시
  Widget _sectionTitleWithAction({
    required String title,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          if (onTap != null)
            GestureDetector(
              onTap: onTap,
              child: const Text('변경',
                  style: TextStyle(color: AppColors.primary, fontSize: 14)),
            ),
        ],
      ),
    );
  }

  // ── 항공편 카드 ───────────────────────────────────────────
  // 가는편(선택 확인) / 오는편(선택 목록) 공통으로 사용
  // 항공사명 + 편명 / 출발~도착 시각 / 소요시간 / 가격 표시
  Widget _flightCard(FlightItem item) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.airlineNm ?? '-'} ${item.flightNo ?? '-'}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  '${FormatUtils.time(item.depPlandTime)} - ${FormatUtils.time(item.arrPlandTime)}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  FormatUtils.duration(item.depPlandTime, item.arrPlandTime),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(FormatUtils.price(item.price),
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('성인 1인 기준',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── 항공권 요약 행 ────────────────────────────────────────
  // 선택한 항공권 섹션에서 가는편/오는편 각각 표시
  // label: 가는편/오는편, time: 출발-도착 시각, info: 공항+항공사, price: 가격
  Widget _summaryRow({
    required String label,
    required String time,
    required String info,
    required int price,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(info, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        Text(FormatUtils.price(price), style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// =============================================================================
// [파일 정보]
// 위치  : lib/airport/screen/flight_detail_screen.dart
// 역할  : 선택한 가는편 확인 / 왕복 오는편 선택 / 항공권 요약 / 예약 진행
// 사용처 : FlightListScreen 에서 항공편 카드 탭 시 이동
// -----------------------------------------------------------------------------
// [연관 파일]
// - flight_controller.dart   : selectedDep, retItems, selectRet(), fetchReturnFlights()
// - flight_item.dart         : 항공편 데이터 모델
// - airport_constants.dart   : issueFee (발급 수수료)
// - format_utils.dart        : time(), duration(), price()
// - reservation_screen.dart  : 예약 버튼 클릭 시 이동
// - app_base_layout.dart     : 공통 앱바 레이아웃
// -----------------------------------------------------------------------------
// [변경 이력]
// - 최초 작성 : Scaffold + AppBar 직접 사용
// - 변경       : AppBaseLayout 적용
//               Colors.blue → AppColors 통일
//               ElevatedButton → CommonButton 적용
//               로그인 체크 후 ReservationScreen 이동 로직 추가
// -----------------------------------------------------------------------------
// [메서드 목록]
// - _formatDateApi(date)          : DateTime → API용 날짜 문자열 (20260421)
// - _formatDateDisplay(date)      : DateTime → 표시용 날짜 문자열 (4.21 화)
// - initState()                   : 왕복 시 오는편 자동 조회
// - build()                       : 가는편 확인 / 오는편 선택 / 요약 / 예약 버튼
// - _sectionTitleWithAction(...)  : 섹션 타이틀 + [변경] 버튼 위젯
// - _flightCard(item)             : 항공편 카드 위젯 (가는편/오는편 공통)
// - _summaryRow(...)              : 항공권 요약 행 위젯
// -----------------------------------------------------------------------------
// [파일 흐름과 순서]
// 1. FlightListScreen 에서 selectDep() 호출 후 이동
// 2. initState() → 왕복이면 fetchReturnFlights() 자동 호출
//    → 출발/도착 반전 후 오는편 목록 조회
// 3. 가는편 카드 표시 / 왕복이면 오는편 목록 표시
// 4. 오는편 선택 → selectRet() → 항공권 요약 + 예약 버튼 표시
// 5. 예약 버튼 클릭 → 로그인 체크
//    → 비로그인: 로그인 화면 이동 → 로그인 성공 시 ReservationScreen
//    → 로그인: 바로 ReservationScreen 이동
// -----------------------------------------------------------------------------
// [주의사항 / 참고]
// - 결제 예상금액은 성인 기준 단순 계산 (소아/유아 차등은 ReservationScreen 에서 처리)
// - 오는편 선택 전까지 항공권 요약 / 예약 버튼 미표시
// - 가는편 [변경] 클릭 시 FlightListScreen 으로 복귀 (pop)
// - 로그인 체크는 SharedPreferences isLoggedIn 기준
// =============================================================================