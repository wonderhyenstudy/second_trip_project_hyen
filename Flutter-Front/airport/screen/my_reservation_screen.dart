import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/constants/app_colors.dart';
import '../../common/widget/app_base_layout.dart';
import '../../common/widget/common_button.dart';
import '../controller/reservation_controller.dart';
import '../model/reservation_item.dart';
import '../utils/format_utils.dart';

class MyReservationScreen extends StatefulWidget {
  const MyReservationScreen({super.key});

  @override
  State<MyReservationScreen> createState() => _MyReservationScreenState();
}

class _MyReservationScreenState extends State<MyReservationScreen> {

  // ✅ [변경 전] _tempMemberId
  // static const String _tempMemberId = 'user1';
  // ✅ [변경 후] _tempMid
  // ✅ [추후 로그인 연동] null → loginController.mid 로 교체
  // ✅ [변경 전] static const String _tempMid = 'user1';
  // ✅ [변경 후] SharedPreferences 에서 가져오기
  String _mid = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ✅ [변경 전] _tempMid 하드코딩
      // ✅ [변경 후] SharedPreferences 에서 가져오기
      final prefs = await SharedPreferences.getInstance();
      _mid = prefs.getString('userMid') ?? '';
      debugPrint('[MyReservationScreen] 예약 목록 조회 시작 → mid: $_mid');
      context.read<ReservationController>()
          .fetchReservations(_mid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBaseLayout(
      title: '항공권 예약 내역',
      body: Column(
        children: [

          // 20260415 국내항공만 사용하므로 탭 주석처리 유지
          // Container(...)

          // ── 예약 목록 ─────────────────────────────────
          Expanded(
            child: Consumer<ReservationController>(
              builder: (context, controller, _) {

                // ✅ 로딩 중
                if (controller.isLoading) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                // ✅ 에러 발생
                // if (controller.errorMessage != null) {
                //   debugPrint('[MyReservationScreen] 에러: ${controller.errorMessage}');
                //   return Center(
                //     child: Text(controller.errorMessage!),
                //   );
                // }

                // 상태 1: 예약 없음
                if (controller.items.isEmpty) {
                  debugPrint('[MyReservationScreen] 예약 내역 없음');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '해당되는 예약 내역이 없습니다.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '지금 새로운 예약을 진행해보세요.',
                          style: TextStyle(
                              color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            debugPrint('[MyReservationScreen] 항공 홈 바로가기');
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                          child: const Text(
                            '항공 홈 바로가기',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                debugPrint('[MyReservationScreen] '
                    '예약 ${controller.items.length}건 표시');

                // 상태 2: 예약 목록 표시
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.items.length,
                  itemBuilder: (context, index) {
                    final item = controller.items[index];
                    return _reservationCard(
                        context, item, index, controller);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── 예약 카드 ─────────────────────────────────────────────
  Widget _reservationCard(
      BuildContext context,
      ReservationItem item,
      int index,
      ReservationController controller,
      ) {
    final isCancelled = item.status == '취소';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── 상단: 상태 배지 ──────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isCancelled
                  ? AppColors.backgroundGrey
                  : AppColors.primaryLight,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.status,
                  style: TextStyle(
                    color: isCancelled
                        ? AppColors.textSecondary
                        : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '예약일: ${item.reservedAt.substring(0, 10)}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── 가는편 ───────────────────────────────
                _flightRow(
                  label: '가는편',
                  date: FormatUtils.date(item.depPlandTime),
                  depTime: FormatUtils.time(item.depPlandTime),
                  arrTime: FormatUtils.time(item.arrPlandTime),
                  depAirport: item.depAirportNm ?? '-',
                  arrAirport: item.arrAirportNm ?? '-',
                  airline:
                  '${item.airlineNm ?? '-'} ${item.flightNo ?? '-'}',
                ),

                // ── 오는편 (왕복일 때) ────────────────────
                if (item.isRoundTrip &&
                    item.retDepPlandTime != null) ...[
                  const Divider(height: 20),
                  _flightRow(
                    label: '오는편',
                    date: FormatUtils.date(item.retDepPlandTime),
                    depTime: FormatUtils.time(item.retDepPlandTime),
                    arrTime: FormatUtils.time(item.retArrPlandTime),
                    depAirport: item.arrAirportNm ?? '-',
                    arrAirport: item.depAirportNm ?? '-',
                    airline: '${item.retAirlineNm ?? '-'} '
                        '${item.retFlightNo ?? '-'}',
                  ),
                ],

                const Divider(height: 20),

                // ── 탑승객 + 총 금액 ──────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text(
                    //   // ✅ [변경 전] item.passengerName
                    //   // ✅ [변경 후] passengers 첫 번째 탑승객
                    //   '탑승객: ${item.passengers.isNotEmpty ? item.passengers[0].passengerName : '-'}',
                    //   style: const TextStyle(
                    //       color: AppColors.textSecondary),
                    // ),
                    // ✅ [변경 전] 단일 탑승객
                    // ✅ [변경 후] 탑승객 목록
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: item.passengers.isEmpty
                          ? [const Text('탑승객: -',
                          style: TextStyle(color: AppColors.textSecondary))]
                          : item.passengers.map((p) => Text(
                        '${p.passengerType} · ${p.passengerName}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      )).toList(),
                    ),
                    Text(
                      FormatUtils.price(item.totalPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                // ── 취소 버튼 (예약완료 상태만) ───────────
                if (!isCancelled) ...[
                  const SizedBox(height: 12),
                  CommonButton(
                    text: '예약 취소',
                    isOutlined: true,
                    color: AppColors.danger,
                    onPressed: () {
                      debugPrint('[MyReservationScreen] 취소 버튼 클릭 → '
                          'index: $index / '
                      // '탑승객: ${item.passengerName}');
                          '탑승객: ${item.passengers.isNotEmpty ? item.passengers[0].passengerName : '-'}');
                      _showCancelDialog(context, index, controller);
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 항공편 행 ─────────────────────────────────────────────
  Widget _flightRow({
    required String label,
    required String date,
    required String depTime,
    required String arrTime,
    required String depAirport,
    required String arrAirport,
    required String airline,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                )),
            Text(date,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(depTime,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                Text(depAirport,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const Icon(Icons.airplanemode_active,
                color: AppColors.primary, size: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(arrTime,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                Text(arrAirport,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(airline,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  // ── 취소 확인 다이얼로그 ──────────────────────────────────
  void _showCancelDialog(
      BuildContext context,
      int index,
      ReservationController controller,
      ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('예약 취소'),
        content: const Text('정말 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('[MyReservationScreen] 예약 취소 → 아니오 선택');
              Navigator.pop(context);
            },
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () async {
              debugPrint('[MyReservationScreen] 예약 취소 확정 → index: $index');
              Navigator.pop(context);
              await controller.cancelReservation(index);
            },
            child: const Text(
              '예',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}