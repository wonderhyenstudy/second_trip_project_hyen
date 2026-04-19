class PassengerItem {

  // ── 데이터 구조 ───────────────────────────────────────────
  final int? id;                  // DB id
  final String passengerType;     // 탑승객 유형 (성인/소아/유아)
  final String passengerName;     // 이름
  final String passengerBirth;    // 생년월일 (YYYYMMDD)
  final String passengerGender;   // 성별 (남성/여성)

  PassengerItem({
    this.id,
    required this.passengerType,
    required this.passengerName,
    required this.passengerBirth,
    required this.passengerGender,
  });

  // ── JSON → PassengerItem 변환 ─────────────────────────────
  factory PassengerItem.fromJson(Map<String, dynamic> json) {
    return PassengerItem(
      id:             json['id'],
      passengerType:  json['passengerType']  ?? '성인',
      passengerName:  json['passengerName']  ?? '',
      passengerBirth: json['passengerBirth'] ?? '',
      passengerGender: json['passengerGender'] ?? '남성',
    );
  }

  // ── PassengerItem → JSON 변환 ─────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'passengerType':  passengerType,  // 탑승객 유형
      'passengerName':  passengerName,  // 이름
      'passengerBirth': passengerBirth, // 생년월일
      'passengerGender': passengerGender, // 성별
    };
  }
}