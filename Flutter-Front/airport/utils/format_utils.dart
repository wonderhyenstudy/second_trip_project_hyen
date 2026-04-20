class FormatUtils {
  FormatUtils._(); // 인스턴스 생성 방지

  // ── 가격 포맷 (89000 → 89,000원) ─────────────────────
  static String price(int price) {
    return '${price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    )}원';
  }

  // ── 시각 포맷 (20260421134000 → 13:40) ───────────────
  static String time(String? time) {
    if (time == null || time.length < 12) return '-';
    return '${time.substring(8, 10)}:${time.substring(10, 12)}';
  }

  // ── 날짜 포맷 (20260421 → 2026.04.21) ────────────────
  static String date(String? time) {
    if (time == null || time.length < 8) return '-';
    return '${time.substring(0, 4)}.${time.substring(4, 6)}.${time.substring(6, 8)}';
  }

  // ── 날짜 표시 포맷 (DateTime → 4.21 화) ──────────────
  // 검색화면/목록화면 날짜 표시에 사용
  static String dateDisplay(DateTime date) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return '${date.month}.${date.day} ${days[date.weekday - 1]}';
  }

  // ── API용 날짜 포맷 (DateTime → 20260421) ─────────────
  // 서버 API 호출 시 파라미터로 사용
  static String dateApi(DateTime date) {
    return '${date.year}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ── 소요시간 계산 (출발~도착 시각 차이) ──────────────
  // 예) 06:00 → 07:10 = 1시간 10분
  static String duration(String? dep, String? arr) {
    if (dep == null || arr == null ||
        dep.length < 12 || arr.length < 12) return '-';
    final d = DateTime.parse(
        '${dep.substring(0, 4)}-${dep.substring(4, 6)}-'
            '${dep.substring(6, 8)} '
            '${dep.substring(8, 10)}:${dep.substring(10, 12)}:00');
    final a = DateTime.parse(
        '${arr.substring(0, 4)}-${arr.substring(4, 6)}-'
            '${arr.substring(6, 8)} '
            '${arr.substring(8, 10)}:${arr.substring(10, 12)}:00');
    final diff = a.difference(d);
    return '${diff.inHours}시간 ${diff.inMinutes % 60}분';
  }

  // ── 생년월일 포맷 (19990101 → 1999.01.01) ────────────
  static String birth(String birth) {
    if (birth.length != 8) return birth;
    return '${birth.substring(0, 4)}.'
        '${birth.substring(4, 6)}.'
        '${birth.substring(6, 8)}';
  }

  // ── 인원 표시 포맷 ────────────────────────────────────
  // 성인 1, 소아 0, 유아 0 → '성인 1, 전체'
  // 성인 2, 소아 1, 유아 0 → '성인 2, 소아 1, 전체'
  static String passenger(int adult, int child, int infant) {
    String result = '성인 $adult';
    if (child > 0)  result += ', 소아 $child';
    if (infant > 0) result += ', 유아 $infant';
    result += ', 전체';
    return result;
  }

  // ── 탑승객 유형별 단가 계산 ──────────────────────────
  // 성인 100% / 소아 75% / 유아 10%
  static int passengerPrice(int basePrice, String passengerType) {
    if (passengerType == '소아') return (basePrice * 0.75).round();
    if (passengerType == '유아') return (basePrice * 0.1).round();
    return basePrice; // 성인
  }

  // ── 전체 탑승객 총 금액 계산 ─────────────────────────
  // 발급수수료 + (가는편 + 오는편) × 탑승객별 단가 합산
  // 예) 성인1 + 소아1, 가는편 89,000원 → (89000 + 66750) + 1000 = 156,750원
  static int totalPassengerPrice({
    required int depPrice,
    int? retPrice,
    required List<String> passengerTypes,
    int issueFee = 1000,
  }) {
    int total = issueFee;
    for (final type in passengerTypes) {
      total += passengerPrice(depPrice, type);
      if (retPrice != null) total += passengerPrice(retPrice, type);
    }
    return total;
  }
}

// =============================================================================
// [파일 정보]
// 위치  : lib/airport/utils/format_utils.dart
// 역할  : 항공 기능 전체에서 사용하는 포맷/계산 공통 유틸
// 사용처 : 항공 관련 모든 screen, controller
// -----------------------------------------------------------------------------
// [변경 이력]
// - 최초 작성 : price, time, date, duration, birth, passenger
// - 추가       : passengerPrice, totalPassengerPrice (소아/유아 가격 차등 적용)
// - 추가       : dateDisplay, dateApi (검색화면 날짜 포맷 통일)
// =============================================================================