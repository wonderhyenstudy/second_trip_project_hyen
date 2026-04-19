class FlightItem {
  // ── 1. 데이터 구조 정의 ──────────────────────────────────
  final String? airlineNm;      // 항공사명
  final String? flightNo;      // 항공편명 (예: KE1234) vihicleId
  final String? depAirportNm;   // 출발 공항명
  final String? arrAirportNm;   // 도착 공항명
  final String? depAirportId;   // 출발 공항코드
  final String? arrAirportId;   // 도착 공항코드
  final String? depPlandTime;   // 출발 예정시각
  final String? arrPlandTime;   // 도착 예정시각
  final int price;              // 가격
  final int seatsLeft;          // 잔여석

  FlightItem({
    this.airlineNm,
    this.flightNo,
    this.depAirportNm,
    this.arrAirportNm,
    this.depAirportId,
    this.arrAirportId,
    this.depPlandTime,
    this.arrPlandTime,
    required this.price,
    required this.seatsLeft,
  });

  // ── 2. API JSON → FlightItem 변환 ───────────────────────
  // ✅ [변경 전] TAGO API 필드명
  // factory FlightItem.fromJson(Map<String, dynamic> json) {
  //   return FlightItem(
  //     airlineNm:    json['airlineNm'],
  //     vihicleId:    json['vihicleId'],    // TAGO 필드명
  //     depAirportNm: json['depAirportNm'],
  //     arrAirportNm: json['arrAirportNm'],
  //     depAirportId: json['depAirportId'],
  //     arrAirportId: json['arrAirportId'],
  //     depPlandTime: json['depPlandTime']?.toString(),
  //     arrPlandTime: json['arrPlandTime']?.toString(),
  //     price:        _mockPrice(),          // Mock 가격
  //     seatsLeft:    _mockSeats(),          // Mock 잔여석
  //   );
  // }
  // ✅ [변경 후] 스프링부트 API 필드명
  factory FlightItem.fromJson(Map<String, dynamic> json) {
    return FlightItem(
      airlineNm:    json['airlineNm'],
      flightNo:    json['flightNo'],           // ✅ flightNo 로 변경
      depAirportNm: json['depAirportNm'],
      arrAirportNm: json['arrAirportNm'],
      depAirportId: json['depAirportId'],
      arrAirportId: json['arrAirportId'],
      depPlandTime: json['depPlandTime']?.toString(),
      arrPlandTime: json['arrPlandTime']?.toString(),
      price:        json['economyCharge'] ?? 0, // ✅ 실제 DB 가격
      seatsLeft:    json['seatsLeft'] ?? 0,     // ✅ 실제 DB 잔여석
    );
  }

  // ── 3. Mock 데이터 (주석처리 - 스프링부트 연결 후 불필요) ──
  // ✅ [변경 전] Mock 가격/잔여석
  // static int _mockPrice() {
  //   final prices = [59000, 79000, 89000, 109000, 139000, 189000];
  //   prices.shuffle();
  //   return prices.first;
  // }
  // static int _mockSeats() => (5 + DateTime.now().millisecond % 45);

  // ── 4. 공항코드 상수 ─────────────────────────────────────
  // ✅ [변경 전] TAGO API 공항코드
  // static const Map<String, String> airportCodes = {
  //   'NAARKNW' : '김포',
  //   'NAARKPK' : '김해(부산)',
  //   'NAARKPC' : '제주',
  //   'NAARKDG' : '대구',
  //   'NAARKTU' : '청주',
  //   'NAARKJJ' : '광주',
  //   'NAARKRW' : '여수',
  //   'NAARKPH' : '포항',
  //   'NAARKUL' : '울산',
  //   'NAARKSB' : '사천',
  // };
  // ✅ [변경 후] 스프링부트 DB 공항코드
  static const Map<String, String> airportCodes = {
    'GIMPO'   : '김포',
    'GIMHAE'  : '김해(부산)',
    'JEJU'    : '제주',
    'DAEGU'   : '대구',
    'CHEONGJU': '청주',
    'GWANGJU' : '광주',
    'YEOSU'   : '여수',
    'POHANG'  : '포항',
    'ULSAN'   : '울산',
    'SACHEON' : '사천',
  };

  // ── 5. 공항코드 → 공항명 변환 ───────────────────────────
  static String getAirportName(String? code) {
    return airportCodes[code] ?? code ?? '-';
  }
}