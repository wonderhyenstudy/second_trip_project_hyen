import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ [추가]
import '../constants/airport_constants.dart';
import '../../common/constants/app_colors.dart';
import '../../common/widget/app_base_layout.dart';
import '../../common/widget/common_button.dart';
import '../controller/reservation_controller.dart';
import '../model/reservation_item.dart';
import '../utils/format_utils.dart';

// ✅ [변경 전] StatelessWidget → [변경 후] StatefulWidget
class ReservationConfirmScreen extends StatefulWidget {
  final ReservationItem reservation;

  const ReservationConfirmScreen({
    super.key,
    required this.reservation,
  });

  @override
  State<ReservationConfirmScreen> createState() =>
      _ReservationConfirmScreenState();
}

class _ReservationConfirmScreenState extends State<ReservationConfirmScreen> {

  // ✅ [추가] 이메일/전화번호
  String _email = '-';
  String _phone = '-';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // ✅ [추가] SharedPreferences 에서 가져오기
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('userEmail') ?? '-';
      _phone = prefs.getString('userPhone') ?? '-';
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[ReservationConfirmScreen] 예약 확인 → '
        '탑승객: ${widget.reservation.passengers.isNotEmpty
        ? widget.reservation.passengers[0].passengerName : '-'} / '
        '총금액: ${widget.reservation.totalPrice}');

    return AppBaseLayout(
      title: '예약내역 최종확인',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── 안내 문구 ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '이제 최종예약만 남았어요.\n'
                    '내용 확인하신 후 최종예약를 진행해주세요.',
                style: TextStyle(
                    color: AppColors.primary, fontSize: 13),
              ),
            ),

            const SizedBox(height: 20),

            // ── 예약 정보 ─────────────────────────────────
            _sectionCard(
              title: '예약 정보',
              child: Column(
                children: [
                  // _infoRow('예약자 이름', widget.reservation.passengerName),
                  _infoRow('예약자 이름',
                      widget.reservation.passengers.isNotEmpty
                          ? widget.reservation.passengers[0].passengerName
                          : '-'),
                  const SizedBox(height: 8),
                  // ✅ [변경 전] '-' → [변경 후] SharedPreferences 에서 가져오기
                  _infoRow('이메일', _email),
                  const SizedBox(height: 8),
                  _infoRow('휴대폰 번호', _phone),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── 여행 정보 ─────────────────────────────────
            _sectionCard(
              title: '여행 정보',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _travelRow(
                    label: '가는편',
                    date: FormatUtils.date(widget.reservation.depPlandTime),
                    depTime: FormatUtils.time(widget.reservation.depPlandTime),
                    arrTime: FormatUtils.time(widget.reservation.arrPlandTime),
                    depAirport: widget.reservation.depAirportNm ?? '-',
                    arrAirport: widget.reservation.arrAirportNm ?? '-',
                    airline: '${widget.reservation.airlineNm ?? '-'} '
                        '${widget.reservation.flightNo ?? '-'}',
                  ),

                  if (widget.reservation.isRoundTrip &&
                      widget.reservation.retDepPlandTime != null) ...[
                    const Divider(height: 20),
                    _travelRow(
                      label: '오는편',
                      date: FormatUtils.date(widget.reservation.retDepPlandTime),
                      depTime: FormatUtils.time(widget.reservation.retDepPlandTime),
                      arrTime: FormatUtils.time(widget.reservation.retArrPlandTime),
                      depAirport: widget.reservation.arrAirportNm ?? '-',
                      arrAirport: widget.reservation.depAirportNm ?? '-',
                      airline: '${widget.reservation.retAirlineNm ?? '-'} '
                          '${widget.reservation.retFlightNo ?? '-'}',
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── 탑승객 정보 ───────────────────────────────
            _sectionCard(
              title: '탑승객 정보',
              child: Column(
                children: [
                  // _infoRow('성명', widget.reservation.passengerName),
                  // const SizedBox(height: 8),
                  // _infoRow('생년월일',
                  //     FormatUtils.birth(widget.reservation.passengerBirth)),
                  // const SizedBox(height: 8),
                  // _infoRow('성별', widget.reservation.passengerGender),
                  // ✅ [변경 전] 단일 탑승객
                  // ✅ [변경 후] 탑승객 목록으로 변경
                  ...widget.reservation.passengers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final p = entry.value;
                    return Column(
                      children: [
                        if (index > 0) const Divider(height: 16),
                        _infoRow('탑승객 ${index + 1} (${p.passengerType})', ''),
                        const SizedBox(height: 8),
                        _infoRow('성명', p.passengerName),
                        const SizedBox(height: 8),
                        _infoRow('생년월일', FormatUtils.birth(p.passengerBirth)),
                        const SizedBox(height: 8),
                        _infoRow('성별', p.passengerGender),
                      ],
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── 최종 결제금액 ─────────────────────────────
            _sectionCard(
              title: '최종 결제금액',
              child: Column(
                children: [
                  _priceRow('가는편', widget.reservation.depPrice),
                  if (widget.reservation.isRoundTrip &&
                      widget.reservation.retPrice != null) ...[
                    const SizedBox(height: 8),
                    _priceRow('오는편', widget.reservation.retPrice!),
                  ],
                  const SizedBox(height: 8),
                  _priceRow('발급 수수료', AirportConstants.issueFee,
                      isGrey: true),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '최종 결제금액',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        FormatUtils.price(widget.reservation.totalPrice),
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

            // ── 버튼 행 ───────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: CommonButton(
                    text: '다시 입력',
                    isOutlined: true,
                    onPressed: () {
                      debugPrint('[ReservationConfirmScreen] 다시 입력 → 이전 화면으로');
                      Navigator.pop(context);
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  flex: 2,
                  child: CommonButton(
                    text: '최종예약',
                    onPressed: () {
                      debugPrint('[ReservationConfirmScreen] 최종예약 클릭 → '
                          '총금액: ${widget.reservation.totalPrice}원');
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => AlertDialog(
                          title: const Text('예약 완료'),
                          content: const Text(
                            '예약 및 결제가 완료되었습니다!',
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                debugPrint('[ReservationConfirmScreen] '
                                    '검색화면으로 이동');
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              },
                              child: const Text('확인'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── 섹션 카드 ─────────────────────────────────────────────
  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              )),
          const Divider(height: 16),
          child,
        ],
      ),
    );
  }

  // ── 정보 행 ───────────────────────────────────────────────
  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textSecondary)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ── 여행 정보 행 ──────────────────────────────────────────
  Widget _travelRow({
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
                style: const TextStyle(color: AppColors.textSecondary)),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                Text(depAirport,
                    style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
            const Icon(Icons.arrow_forward,
                color: AppColors.textSecondary),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(arrTime,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                Text(arrAirport,
                    style: const TextStyle(color: AppColors.textSecondary)),
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

  // ── 금액 행 ───────────────────────────────────────────────
  Widget _priceRow(String label, int price, {bool isGrey = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: isGrey
                    ? AppColors.textSecondary
                    : AppColors.textPrimary)),
        Text(
          FormatUtils.price(price),
          style: TextStyle(
              color: isGrey
                  ? AppColors.textSecondary
                  : AppColors.textPrimary),
        ),
      ],
    );
  }
}