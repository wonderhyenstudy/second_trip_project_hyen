class FlightItem {

  // ── 1. 데이터 구조 ──────────────────────────────────────
  final String? airlineNm;     // 항공사명
  final String? flightNo;      // 항공편명 (예: KE1234)
  final String? depAirportNm;  // 출발 공항명
  final String? arrAirportNm;  // 도착 공항명
  final String? depAirportId;  // 출발 공항코드
  final String? arrAirportId;  // 도착 공항코드
  final String? depPlandTime;  // 출발 예정시각 (예: 20260421060000)
  final String? arrPlandTime;  // 도착 예정시각
  final int price;             // 가격 (economyCharge)
  final int seatsLeft;         // 잔여석

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

  // ── 2. JSON → FlightItem 변환 ───────────────────────────
  // 스프링부트 API 응답 기준 (TAGO API → DB 저장 후 제공)
  factory FlightItem.fromJson(Map<String, dynamic> json) {
    return FlightItem(
      airlineNm:    json['airlineNm'],
      flightNo:     json['flightNo'],
      depAirportNm: json['depAirportNm'],
      arrAirportNm: json['arrAirportNm'],
      depAirportId: json['depAirportId'],
      arrAirportId: json['arrAirportId'],
      depPlandTime: json['depPlandTime']?.toString(),
      arrPlandTime: json['arrPlandTime']?.toString(),
      price:        json['economyCharge'] ?? 0,
      seatsLeft:    json['seatsLeft'] ?? 0,
    );
  }

  // ── 3. 공항코드 상수 (스프링부트 DB 기준) ────────────────
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

  // ── 4. 공항코드 → 공항명 변환 ───────────────────────────
  static String getAirportName(String? code) {
    return airportCodes[code] ?? code ?? '-';
  }
}

// =============================================================================
// [파일 정보]
// 위치  : lib/airport/model/flight_item.dart
// 역할  : 항공편 데이터 모델 (API 응답 → Flutter 객체 변환)
// 사용처 : FlightController, FlightListScreen, FlightDetailScreen
// -----------------------------------------------------------------------------
// [변경 이력]
// - 최초 작성 : TAGO API 기준 fromJson, Mock 가격/잔여석
// - 변경       : 스프링부트 DB API 기준으로 전환
//               vihicleId → flightNo, Mock → 실제 DB 데이터 사용
//               TAGO 공항코드 → 영문 공항코드 (GIMHAE, JEJU 등)
// =============================================================================