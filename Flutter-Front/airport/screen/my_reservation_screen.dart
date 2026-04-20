import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../common/constants/app_colors.dart';
import '../../common/widget/app_base_layout.dart';
import '../../common/widget/common_button.dart';
import '../../car/controller/car_reservation_controller.dart';
import '../../car/model/car_rental_reservation_dto.dart';
import '../../car/util/format_util.dart';
import '../controller/reservation_controller.dart';
import '../model/reservation_item.dart';
import '../utils/format_utils.dart';

// ✅ package 추가
enum BookingType { flight, rental, hotel, package }

class MyReservationScreen extends StatefulWidget {
  final BookingType type;
  final bool isModal;

  const MyReservationScreen({super.key, this.type = BookingType.flight,this.isModal = false,});

  @override
  State<MyReservationScreen> createState() => _MyReservationScreenState();
}

class _MyReservationScreenState extends State<MyReservationScreen> {
  final _scrollController = ScrollController();

  String _mid = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      _mid = prefs.getString('userMid') ?? '';
      debugPrint('[MyReservationScreen] 예약 목록 조회 시작 → mid: $_mid');

      switch (widget.type) {
        case BookingType.flight:
          context.read<ReservationController>().fetchReservations(_mid);
          break;
        case BookingType.rental:
          context.read<CarReservationController>().fetchMyRentals();
          _scrollController.addListener(() {
            if (_scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 200) {
              context.read<CarReservationController>().loadMoreRentals();
            }
          });
          break;
        case BookingType.hotel:
        // TODO: 숙소 담당자 - 숙소 예약 목록 API 연결
          break;
        case BookingType.package:
        // TODO: 패키지 담당자 - 패키지 예약 목록 API 연결
          break;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.type) {
      case BookingType.flight:  return '항공권 예약 내역';
      case BookingType.rental:  return '렌터카 예약 내역';
      case BookingType.hotel:   return '숙소 예약 내역';
      case BookingType.package: return '패키지 예약 내역';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBaseLayout(
      title: _title,
      showBackButton: !widget.isModal,  // ✅ leading 대신 이걸로
      actions: widget.isModal
          ? [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ]
          : null,
      body: switch (widget.type) {
        BookingType.flight  => _flightBody(),
        BookingType.rental  => _rentalBody(),
        BookingType.hotel   => _hotelBody(),
        BookingType.package => _packageBody(),
      },
    );
  }

  // ─────────────────────────────────────────────
  // 항공
  // ─────────────────────────────────────────────
  Widget _flightBody() {
    return Column(
      children: [
        Expanded(
          child: Consumer<ReservationController>(
            builder: (context, controller, _) {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.errorMessage != null) {
                return Center(child: Text(controller.errorMessage!));
              }
              if (controller.items.isEmpty) {
                return _emptyView('해당되는 예약 내역이 없습니다.', '지금 새로운 예약을 진행해보세요.');
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.items.length,
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return _flightCard(context, item, index, controller);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isPastFlight(String? depPlandTime) {
    if (depPlandTime == null || depPlandTime.length < 12) return false;
    try {
      final year   = int.parse(depPlandTime.substring(0, 4));
      final month  = int.parse(depPlandTime.substring(4, 6));
      final day    = int.parse(depPlandTime.substring(6, 8));
      final hour   = int.parse(depPlandTime.substring(8, 10));
      final minute = int.parse(depPlandTime.substring(10, 12));
      return DateTime(year, month, day, hour, minute).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  Widget _flightCard(BuildContext context, ReservationItem item, int index, ReservationController controller) {
    final isCancelled = item.status == '취소';
    final isPast      = _isPastFlight(item.depPlandTime);
    final isGrey      = isCancelled || isPast;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isGrey ? Colors.grey.shade100 : null,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isGrey ? Colors.grey.shade300 : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isGrey ? AppColors.backgroundGrey : AppColors.primaryLight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isCancelled ? '취소' : isPast ? '지난예약' : item.status,
                  style: TextStyle(
                    color: isGrey ? AppColors.textSecondary : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '예약일: ${item.reservedAt.substring(0, 10)}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _flightRow(
                  label: '가는편',
                  date: FormatUtils.date(item.depPlandTime),
                  depTime: FormatUtils.time(item.depPlandTime),
                  arrTime: FormatUtils.time(item.arrPlandTime),
                  depAirport: item.depAirportNm ?? '-',
                  arrAirport: item.arrAirportNm ?? '-',
                  airline: '${item.airlineNm ?? '-'} ${item.flightNo ?? '-'}',
                  isGrey: isGrey,
                ),
                if (item.isRoundTrip && item.retDepPlandTime != null) ...[
                  const Divider(height: 20),
                  _flightRow(
                    label: '오는편',
                    date: FormatUtils.date(item.retDepPlandTime),
                    depTime: FormatUtils.time(item.retDepPlandTime),
                    arrTime: FormatUtils.time(item.retArrPlandTime),
                    depAirport: item.arrAirportNm ?? '-',
                    arrAirport: item.depAirportNm ?? '-',
                    airline: '${item.retAirlineNm ?? '-'} ${item.retFlightNo ?? '-'}',
                    isGrey: isGrey,
                  ),
                ],
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '탑승객: ${item.passengerSummary}',
                      style: TextStyle(
                        color: isGrey ? AppColors.textSecondary : AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      FormatUtils.price(item.totalPrice),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isGrey ? AppColors.textSecondary : AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (!isCancelled && !isPast) ...[
                  const SizedBox(height: 12),
                  CommonButton(
                    text: '예약 취소',
                    isOutlined: true,
                    color: AppColors.danger,
                    onPressed: () =>
                        _showFlightCancelDialog(context, index, controller),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _flightRow({
    required String label,
    required String date,
    required String depTime,
    required String arrTime,
    required String depAirport,
    required String arrAirport,
    required String airline,
    bool isGrey = false,
  }) {
    final labelColor = isGrey ? AppColors.textSecondary : AppColors.primary;
    final timeStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: isGrey ? AppColors.textSecondary : AppColors.textPrimary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: labelColor, fontWeight: FontWeight.bold)),
            Text(date, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(depTime, style: timeStyle),
              Text(depAirport, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
            Icon(Icons.airplanemode_active,
                color: isGrey ? AppColors.textSecondary : AppColors.primary,
                size: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(arrTime, style: timeStyle),
              Text(arrAirport, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
          ],
        ),
        const SizedBox(height: 4),
        Text(airline, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  void _showFlightCancelDialog(BuildContext context, int index, ReservationController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('예약 취소'),
        content: const Text('정말 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await controller.cancelReservation(index);
            },
            child: const Text('예', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 렌터카
  // ─────────────────────────────────────────────
  Widget _rentalBody() {
    return Consumer<CarReservationController>(
      builder: (context, controller, _) {
        if (controller.isLoading && controller.myRentals.isEmpty) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 10,
            itemBuilder: (_, __) => const _ShimmerRentalCard(),
          );
        }
        if (controller.errorMessage != null) {
          return Center(child: Text(controller.errorMessage!));
        }
        if (controller.myRentals.isEmpty) {
          return _emptyView('예약 내역이 없습니다.', '렌터카를 예약해보세요.');
        }
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: controller.myRentals.length + (controller.hasNext ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.myRentals.length) {
              return const _ShimmerRentalCard();
            }
            return _rentalCard(context, controller.myRentals[index], controller);
          },
        );
      },
    );
  }

  bool _isPastRental(String endDate) {
    try {
      return DateTime.parse(formatDateString(endDate, '.', '-'))
          .isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  String _rentalStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED': return '예약확정';
      case 'CANCELLED': return '취소';
      default: return status;
    }
  }

  Widget _rentalCard(BuildContext context, CarRentalReservationDTO item, CarReservationController controller) {
    final isPast = _isPastRental(item.endDate);
    final statusLabel = isPast ? '지난예약' : _rentalStatusLabel(item.status);
    final color = isPast ? Colors.grey : Colors.orange[700]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isPast ? Colors.grey.shade100 : null,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isPast ? Colors.grey.shade300 : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(statusLabel, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                Text('예약번호 #${item.id}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.carName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      '${formatDateString(item.startDate, '-', '.')} ~ ${formatDateString(item.endDate, '-', '.')}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('총 금액', style: TextStyle(color: AppColors.textSecondary)),
                    Text(formatPrice(item.totalPrice),
                        style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                  ],
                ),
                if (!isPast) ...[
                  const SizedBox(height: 12),
                  CommonButton(
                    text: '예약 취소',
                    isOutlined: true,
                    color: color,
                    onPressed: () => _showRentalCancelDialog(context, item, controller),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRentalCancelDialog(BuildContext context, CarRentalReservationDTO item, CarReservationController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('예약 취소'),
        content: const Text('정말 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await controller.cancelRental(item.id);
            },
            child: const Text('예', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 숙소 (임시)
  // TODO: 숙소 담당자 - 실제 숙소 예약 내역으로 교체
  // ─────────────────────────────────────────────
  Widget _hotelBody() {
    return _emptyView('숙소 예약 내역', '준비 중입니다.');
  }

  // ─────────────────────────────────────────────
  // 패키지 (임시)
  // TODO: 패키지 담당자 - 실제 패키지 예약 내역으로 교체
  // ─────────────────────────────────────────────
  Widget _packageBody() {
    return _emptyView('패키지 예약 내역', '준비 중입니다.');
  }

  // ─────────────────────────────────────────────
  // 공통
  // ─────────────────────────────────────────────
  Widget _emptyView(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ShimmerRentalCard extends StatelessWidget {
  const _ShimmerRentalCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 140, height: 16, color: Colors.white),
                  const SizedBox(height: 10),
                  Container(width: 180, height: 13, color: Colors.white),
                  const SizedBox(height: 16),
                  Container(width: double.infinity, height: 1, color: Colors.white),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 60, height: 13, color: Colors.white),
                      Container(width: 80, height: 13, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}