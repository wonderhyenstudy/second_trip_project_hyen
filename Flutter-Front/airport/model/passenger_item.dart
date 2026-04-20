class PassengerItem {

  // ── 데이터 구조 ───────────────────────────────────────────
  final int?   id;              // DB PK (조회 시에만 존재, 등록 시 null)
  final String passengerType;   // 탑승객 유형 (성인/소아/유아)
  final String passengerName;   // 이름 (예: 홍 길동)
  final String passengerBirth;  // 생년월일 YYYYMMDD (예: 19990101)
  final String passengerGender; // 성별 (남성/여성)

  PassengerItem({
    this.id,
    required this.passengerType,
    required this.passengerName,
    required this.passengerBirth,
    required this.passengerGender,
  });

  // ── JSON → PassengerItem 변환 (서버 응답 파싱) ────────────
  factory PassengerItem.fromJson(Map<String, dynamic> json) {
    return PassengerItem(
      id:              json['id'],
      passengerType:   json['passengerType']   ?? '성인',
      passengerName:   json['passengerName']   ?? '',
      passengerBirth:  json['passengerBirth']  ?? '',
      passengerGender: json['passengerGender'] ?? '남성',
    );
  }

  // ── PassengerItem → JSON 변환 (서버 전송용) ───────────────
  // id 는 전송하지 않음 (서버에서 자동 생성)
  Map<String, dynamic> toJson() {
    return {
      'passengerType':   passengerType,
      'passengerName':   passengerName,
      'passengerBirth':  passengerBirth,
      'passengerGender': passengerGender,
    };
  }
}

// =============================================================================
// [파일 정보]
// 위치  : lib/airport/model/passenger_item.dart
// 역할  : 탑승객 데이터 모델
// 사용처 : ReservationItem, ReservationScreen, ReservationConfirmScreen
// -----------------------------------------------------------------------------
// [변경 이력]
// - 최초 작성 : 단일 탑승객 구조
// - 변경       : id 필드 추가 (DB 조회 시 사용)
// =============================================================================