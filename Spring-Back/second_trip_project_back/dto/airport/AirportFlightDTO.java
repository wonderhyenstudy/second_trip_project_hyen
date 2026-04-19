package com.busanit401.second_trip_project_back.dto.airport;

import com.busanit401.second_trip_project_back.entity.airport.AirportFlight;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AirportFlightDTO {

    // ── 항공편 정보 ──────────────────────────────────────────
    private Long id;
    private String airlineNm;       // 항공사명
    private String flightNo;        // 항공편명
    private String depAirportId;    // 출발 공항코드
    private String arrAirportId;    // 도착 공항코드
    private String depAirportNm;    // 출발 공항명
    private String arrAirportNm;    // 도착 공항명
    private String depPlandTime;    // 출발 예정시각
    private String arrPlandTime;    // 도착 예정시각
    private Integer economyCharge;  // 일반석 가격
    private Integer seatsLeft;      // 잔여석

    // ── Entity → DTO 변환 ────────────────────────────────────
    public static AirportFlightDTO fromEntity(AirportFlight entity) {
        return AirportFlightDTO.builder()
                .id(entity.getId())
                .airlineNm(entity.getAirlineNm())
                .flightNo(entity.getFlightNo())
                .depAirportId(entity.getDepAirportId())
                .arrAirportId(entity.getArrAirportId())
                .depAirportNm(entity.getDepAirportNm())
                .arrAirportNm(entity.getArrAirportNm())
                .depPlandTime(entity.getDepPlandTime())
                .arrPlandTime(entity.getArrPlandTime())
                .economyCharge(entity.getPrice())
                .seatsLeft(entity.getSeatsLeft())
                .build();
    }

    // ── DTO → Entity 변환 ────────────────────────────────────
    public AirportFlight toEntity() {
        return AirportFlight.builder()
                .airlineNm(airlineNm)
                .flightNo(flightNo)
                .depAirportId(depAirportId)
                .arrAirportId(arrAirportId)
                .depAirportNm(depAirportNm)
                .arrAirportNm(arrAirportNm)
                .depPlandTime(depPlandTime)
                .arrPlandTime(arrPlandTime)
                .price(economyCharge)
                .seatsLeft(seatsLeft)
                .build();
    }
}