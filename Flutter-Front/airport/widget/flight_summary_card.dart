import 'package:flutter/material.dart';

import '../../common/constants/app_colors.dart';
import '../utils/format_utils.dart';

class FlightSummaryCard extends StatelessWidget {
  final String label;       // 가는편 / 오는편
  final String? depTime;    // 출발 시각
  final String? arrTime;    // 도착 시각
  final String depAirport;  // 출발 공항명
  final String arrAirport;  // 도착 공항명
  final String airline;     // 항공사명 + 편명
  final int price;          // 가격
  // ✅ 추가 - 변경 버튼 (상세화면에서 가는편 변경 시)
  final VoidCallback? onChangeTap;

  const FlightSummaryCard({
    super.key,
    required this.label,
    required this.depTime,
    required this.arrTime,
    required this.depAirport,
    required this.arrAirport,
    required this.airline,
    required this.price,
    this.onChangeTap,  // ✅ 추가
  });

  @override
  Widget build(BuildContext context) {
    // 날짜 포맷 (20260421... → 2026.04.21)
    String formattedDate = '-';
    if (depTime != null && depTime!.length >= 8) {
      formattedDate = FormatUtils.date(depTime);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 라벨 + 날짜 + ✅ 변경 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  // ✅ onChangeTap 있을 때만 변경 버튼 표시
                  if (onChangeTap != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onChangeTap,
                      child: const Text(
                        '변경',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 출발 → 도착
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FormatUtils.time(depTime),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    depAirport,
                    style: const TextStyle(
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward,
                  color: AppColors.textSecondary),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    FormatUtils.time(arrTime),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    arrAirport,
                    style: const TextStyle(
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 항공사 + 가격
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                airline,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                FormatUtils.price(price),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}