import 'package:second_trip_project/airport/model/passenger_item.dart';

import '../constants/airport_constants.dart';

class ReservationItem {

  // ── 1. 데이터 구조 정의 ──────────────────────────────────
  final int? id;                  // 스프링부트 DB id
  // ✅ [추가] mid 필드
  final String? mid;              // 회원 ID
  final String? airlineNm;        // 항공사명
  final String? flightNo;        // 항공편명
  final String? depAirportNm;     // 출발 공항명
  final String? arrAirportNm;     // 도착 공항명
  final String? depAirportId;     // 출발 공항코드
  final String? arrAirportId;     // 도착 공항코드
  final String? depPlandTime;     // 출발 시각
  final String? arrPlandTime;     // 도착 시각
  final int depPrice;             // 가는편 가격

  // ── 왕복일 때 ─────────────────────────────────────────────
  final String? retAirlineNm;     // 오는편 항공사명
  final String? retFlightNo;     // 오는편 항공편명 retVihicleId
  final String? retDepPlandTime;  // 오는편 출발 시각
  final String? retArrPlandTime;  // 오는편 도착 시각
  final int? retPrice;            // 오는편 가격

  // ── 탑승객 정보 ───────────────────────────────────────────
  // final String passengerName;     // 이름
  // final String passengerBirth;    // 생년월일
  // final String passengerGender;   // 성별

  // ── 탑승객 목록 (passenger 테이블로 분리) ─────────────────
  final List<PassengerItem> passengers;  // ✅ [변경] 단일 → 목록

  // ── 예약 정보 ─────────────────────────────────────────────
  final bool isRoundTrip;         // 편도/왕복
  final String reservedAt;        // 예약 일시
  String status;                  // 예약완료 / 취소

  ReservationItem({
    this.id,
    // ✅ [추가] mid
    this.mid,
    this.airlineNm,
    this.flightNo,
    this.depAirportNm,
    this.arrAirportNm,
    this.depAirportId,
    this.arrAirportId,
    this.depPlandTime,
    this.arrPlandTime,
    required this.depPrice,
    this.retAirlineNm,
    this.retFlightNo,
    this.retDepPlandTime,
    this.retArrPlandTime,
    this.retPrice,
    // required this.passengerName,
    // required this.passengerBirth,
    // required this.passengerGender,
    required this.passengers,     // ✅ [변경] 탑승객 목록
    required this.isRoundTrip,
    required this.reservedAt,
    required this.status,
  });

  // ── 2. 총 금액 계산 ──────────────────────────────────────
  // int get totalPrice {
  //   if (isRoundTrip && retPrice != null) {
  //     return depPrice + retPrice! + AirportConstants.issueFee;
  //   }
  //   return depPrice + AirportConstants.issueFee;
  // }
  // ✅ [변경 후] 탑승객 수만큼 곱하기
  int get totalPrice {
    final count = passengers.isNotEmpty ? passengers.length : 1;
    if (isRoundTrip && retPrice != null) {
      return (depPrice + retPrice!) * count + AirportConstants.issueFee;
    }
    return depPrice * count + AirportConstants.issueFee;
  }

  // ── 3. 스프링부트 JSON → ReservationItem 변환 ────────────
  factory ReservationItem.fromJson(Map<String, dynamic> json) {
    return ReservationItem(
      id:              json['id'],                // 스프링부트 DB id
      // ✅ [추가] mid
      mid:             json['mid'],               // 회원 ID
      airlineNm:       json['airlineNm'],         // 항공사명
      flightNo:       json['flightNo'],          // 항공편명 flightNo → vihicleId
      depAirportNm:    json['depAirportNm'],      // 출발 공항명
      arrAirportNm:    json['arrAirportNm'],      // 도착 공항명
      depAirportId:    json['depAirportId'],      // 출발 공항코드
      arrAirportId:    json['arrAirportId'],      // 도착 공항코드
      depPlandTime:    json['depPlandTime'],      // 출발 시각
      arrPlandTime:    json['arrPlandTime'],      // 도착 시각
      depPrice:        json['depPrice'] ?? 0,    // 가는편 가격
      retAirlineNm:    json['retAirlineNm'],      // 오는편 항공사명
      retFlightNo:    json['retFlightNo'],       // 오는편 출발 시각 retFlightNo → retVihicleId
      retDepPlandTime: json['retDepPlandTime'],   // 오는편 출발 시각
      retArrPlandTime: json['retArrPlandTime'],   // 오는편 도착 시각
      retPrice:        json['retPrice'],          // 오는편 가격
      // passengerName:   json['passengerName'],     // 이름
      // passengerBirth:  json['passengerBirth'],    // 생년월일
      // passengerGender: json['passengerGender'],   // 성별
      // ✅ [변경] 탑승객 목록 변환
      passengers: (json['passengers'] as List<dynamic>? ?? [])
          .map((e) => PassengerItem.fromJson(e))
          .toList(),
      isRoundTrip:     json['isRoundTrip'] ?? false, // 편도/왕복
      reservedAt:      json['reservedAt'] ?? '', // 예약 일시
      status:          '예약완료',               // 상태
    );
  }

  // ── 4. ReservationItem → 스프링부트 JSON 변환 ────────────
  Map<String, dynamic> toJson() {
    return {
      // ✅ [추가] mid
      'mid':             mid,               // 회원 ID
      'airlineNm':       airlineNm,         // 항공사명
      'flightNo':        flightNo,         // 항편명공 vihicleId → flightNo
      'depAirportNm':    depAirportNm,      // 출발 공항명
      'arrAirportNm':    arrAirportNm,      // 도착 공항명
      'depAirportId':    depAirportId,      // 출발 공항코드
      'arrAirportId':    arrAirportId,      // 도착 공항코드
      'depPlandTime':    depPlandTime,      // 출발 시각
      'arrPlandTime':    arrPlandTime,      // 도착 시각
      'depPrice':        depPrice,          // 가는편 가격
      'retAirlineNm':    retAirlineNm,      // 오는편 항공사명
      'retFlightNo':     retFlightNo,      // retVihicleId → retFlightNo
      'retDepPlandTime': retDepPlandTime,   // 오는편 출발 시각
      'retArrPlandTime': retArrPlandTime,   // 오는편 도착 시각
      'retPrice':        retPrice,          // 오는편 가격
      // 'passengerName':   passengerName,     // 이름
      // 'passengerBirth':  passengerBirth,    // 생년월일
      // 'passengerGender': passengerGender,   // 성별
      // ✅ [변경] 탑승객 목록 변환
      'passengers':      passengers.map((e) => e.toJson()).toList(),
      'isRoundTrip':     isRoundTrip,       // 편도/왕복
      'reservedAt':      reservedAt,        // 예약 일시
    };
  }
}