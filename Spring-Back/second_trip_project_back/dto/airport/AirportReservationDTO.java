package com.busanit401.second_trip_project_back.dto.airport;

import com.busanit401.second_trip_project_back.entity.airport.AirportReservation;
import lombok.*;

import java.util.List;
import java.util.stream.Collectors;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AirportReservationDTO {

    // ── 기본키 ──────────────────────────────────────────────
    private Long id;

    // ── 회원 정보 ────────────────────────────────────────────
    private String mid;             // 로그인 회원 ID

    // ── 가는편 정보 ──────────────────────────────────────────
    private String airlineNm;       // 항공사명
    private String flightNo;        // 항공편명
    private String depAirportNm;    // 출발 공항명
    private String arrAirportNm;    // 도착 공항명
    private String depAirportId;    // 출발 공항코드
    private String arrAirportId;    // 도착 공항코드
    private String depPlandTime;    // 출발 예정시각
    private String arrPlandTime;    // 도착 예정시각
    private Integer depPrice;       // 가는편 가격

    // ── 오는편 정보 (왕복일 때) ──────────────────────────────
    private String retAirlineNm;    // 오는편 항공사명
    private String retFlightNo;     // 오는편 항공편명
    private String retDepPlandTime; // 오는편 출발 예정시각
    private String retArrPlandTime; // 오는편 도착 예정시각
    private Integer retPrice;       // 오는편 가격

    // ── 탑승객 목록 (passenger 테이블로 분리) ────────────────
    private List<AirportPassengerDTO> passengers;

    // ── 예약 정보 ────────────────────────────────────────────
    private Boolean isRoundTrip;    // 편도/왕복
    private String reservedAt;      // 예약 일시

    // ── 총 금액 계산 ─────────────────────────────────────────
    public int getTotalPrice() {
        final int fee = 1000;
        if (Boolean.TRUE.equals(isRoundTrip) && retPrice != null) {
            return depPrice + retPrice + fee;
        }
        return depPrice + fee;
    }

    // ── Entity → DTO 변환 ────────────────────────────────────
    public static AirportReservationDTO fromEntity(AirportReservation entity) {
        return AirportReservationDTO.builder()
                .id(entity.getId())                             // 기본키
                .mid(entity.getMid())                           // 회원 ID
                .airlineNm(entity.getAirlineNm())               // 항공사명
                .flightNo(entity.getFlightNo())                 // 항공편명
                .depAirportNm(entity.getDepAirportNm())         // 출발 공항명
                .arrAirportNm(entity.getArrAirportNm())         // 도착 공항명
                .depAirportId(entity.getDepAirportId())         // 출발 공항코드
                .arrAirportId(entity.getArrAirportId())         // 도착 공항코드
                .depPlandTime(entity.getDepPlandTime())         // 출발 예정시각
                .arrPlandTime(entity.getArrPlandTime())         // 도착 예정시각
                .depPrice(entity.getDepPrice())                 // 가는편 가격
                .retAirlineNm(entity.getRetAirlineNm())         // 오는편 항공사명
                .retFlightNo(entity.getRetFlightNo())           // 오는편 항공편명
                .retDepPlandTime(entity.getRetDepPlandTime())   // 오는편 출발 예정시각
                .retArrPlandTime(entity.getRetArrPlandTime())   // 오는편 도착 예정시각
                .retPrice(entity.getRetPrice())                 // 오는편 가격
                .passengers(entity.getPassengers().stream()     // 탑승객 목록
                        .map(AirportPassengerDTO::fromEntity)
                        .collect(Collectors.toList()))
                .isRoundTrip(entity.getIsRoundTrip())           // 편도/왕복
                .reservedAt(entity.getReservedAt())             // 예약 일시
                .build();
    }

    // ── DTO → Entity 변환 ────────────────────────────────────
    public AirportReservation toEntity() {
        return AirportReservation.builder()
                .mid(mid)                                       // 회원 ID
                .airlineNm(airlineNm)                           // 항공사명
                .flightNo(flightNo)                             // 항공편명
                .depAirportNm(depAirportNm)                     // 출발 공항명
                .arrAirportNm(arrAirportNm)                     // 도착 공항명
                .depAirportId(depAirportId)                     // 출발 공항코드
                .arrAirportId(arrAirportId)                     // 도착 공항코드
                .depPlandTime(depPlandTime)                     // 출발 예정시각
                .arrPlandTime(arrPlandTime)                     // 도착 예정시각
                .depPrice(depPrice)                             // 가는편 가격
                .retAirlineNm(retAirlineNm)                     // 오는편 항공사명
                .retFlightNo(retFlightNo)                       // 오는편 항공편명
                .retDepPlandTime(retDepPlandTime)               // 오는편 출발 예정시각
                .retArrPlandTime(retArrPlandTime)               // 오는편 도착 예정시각
                .retPrice(retPrice)                             // 오는편 가격
                .isRoundTrip(isRoundTrip)                       // 편도/왕복
                .reservedAt(reservedAt)                         // 예약 일시
                .build();
    }
}