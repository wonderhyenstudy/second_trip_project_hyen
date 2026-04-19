import 'package:flutter/material.dart';

class AppColors {
  AppColors._();  // 인스턴스 생성 방지

  // ── 메인 색상 (여기어때 공식 Red) ───────────────────────
  static const Color primary      = Color(0xFFF7323F); // Yeogi Red
  static const Color primaryLight = Color(0xFFFFEBEC); // 연한 핑크톤 배경

  // ── 텍스트 색상 ───────────────────────────────────────
  static const Color textPrimary   = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textRed       = Color(0xFFF7323F);
  static const Color textWhite     = Color(0xFFFFFFFF);

  // ── 배경 색상 ─────────────────────────────────────────
  static const Color backgroundGrey  = Color(0xFFF5F5F5);
  static const Color backgroundWhite = Colors.white;

  // ── 보더 색상 ─────────────────────────────────────────
  static const Color border      = Color(0xFFE0E0E0);
  static const Color borderRed   = Color(0xFFF7323F);

  // ── 상태 색상 ─────────────────────────────────────────
  static const Color success  = Color(0xFF4CAF50);
  static const Color warning  = Color(0xFFFF9800);
  static const Color danger   = Color(0xFFF7323F);
  static const Color info     = Color(0xFF2196F3);

  // ✅ 추가 - 항공 전용 (좌석 상태 표시용)
  static const Color seatAvailable = Color(0xFF4CAF50); // 여유 (초록)
  static const Color seatLow       = Color(0xFFF7323F); // 마감임박 (빨강)

}