import 'package:flutter/material.dart';
import '../../common/constants/app_colors.dart';
import '../model/flight_item.dart';
import '../utils/format_utils.dart';

class FlightCard extends StatelessWidget {
  final FlightItem item;
  final VoidCallback? onTap;
  final bool isSelected;    // 선택된 카드 표시 (오는편 선택 시)
  // ✅ 추가 - 마진 제거 옵션 (상세화면에서 카드 안에 넣을 때)
  final bool removePadding;

  const FlightCard({
    super.key,
    required this.item,
    this.onTap,
    this.isSelected = false,
    this.removePadding = false,  // ✅ 추가
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        // ✅ removePadding이 true면 마진 없애기
        margin: removePadding
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.borderRed : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 항공사명 + 편명 + 잔여석
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
                  Text(
                    '잔여 ${item.seatsLeft}석',
                    style: TextStyle(
                      color: item.seatsLeft <= 10
                          ? AppColors.danger
                          : AppColors.textSecondary,
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
                        FormatUtils.time(item.depPlandTime),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item.depAirportNm ?? '-',
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12),
                      ),
                    ],
                  ),

                  // 소요시간
                  Column(
                    children: [
                      Text(
                        FormatUtils.duration(
                            item.depPlandTime, item.arrPlandTime),
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12),
                      ),
                      const Icon(Icons.arrow_forward,
                          color: AppColors.textSecondary, size: 16),
                      const Text('직항',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12)),
                    ],
                  ),

                  // 도착
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        FormatUtils.time(item.arrPlandTime),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item.arrAirportNm ?? '-',
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12),
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
                  FormatUtils.price(item.price),
                  style: const TextStyle(
                    color: AppColors.primary,
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