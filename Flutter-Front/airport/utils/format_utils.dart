class FormatUtils {
  FormatUtils._();  // 인스턴스 생성 방지

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
  static String dateDisplay(DateTime date) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return '${date.month}.${date.day} ${days[date.weekday - 1]}';
  }

  // ── API용 날짜 포맷 (DateTime → 20260421) ─────────────
  static String dateApi(DateTime date) {
    return '${date.year}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ── 소요시간 계산 ─────────────────────────────────────
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

  // ✅ 추가 - 인원 표시 포맷
  // (성인 1, 소아 0, 유아 0 → '성인 1, 전체')
  // (성인 2, 소아 1, 유아 0 → '성인 2, 소아 1, 전체')
  static String passenger(int adult, int child, int infant) {
    String result = '성인 $adult';
    if (child > 0)  result += ', 소아 $child';
    if (infant > 0) result += ', 유아 $infant';
    result += ', 전체';
    return result;
  }
}