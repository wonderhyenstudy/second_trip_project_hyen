class AirportConstants {
  AirportConstants._(); // 인스턴스 생성 방지

  // ── 항공 관련 상수 ───────────────────────────────────────
  static const int issueFee = 1000; // 발급 수수료 (예약 1건당 1회 부과)
  static const int pageSize = 10;   // 무한스크롤 페이지 단위
}

// =============================================================================
// [파일 정보]
// 위치  : lib/airport/constants/airport_constants.dart
// 역할  : 항공 기능 공통 상수 모음
// 사용처 : flight_detail_screen, reservation_screen, reservation_confirm_screen
// -----------------------------------------------------------------------------
// [변경 이력]
// - 최초 작성 : issueFee, pageSize 상수 정의
// =============================================================================