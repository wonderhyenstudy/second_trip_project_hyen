package com.busanit401.second_trip_project_back.entity.airport;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "trip_airport_flight")
@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class AirportFlight {

    // ── 기본키 ──────────────────────────────────────────────
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // ── 항공편 정보 ──────────────────────────────────────────
    @Column(nullable = false, length = 50)
    private String airlineNm;       // 항공사명 (대한항공, 제주항공 등)

    @Column(nullable = false, length = 20)
    private String flightNo;        // 항공편명 (KE1234)

    @Column(nullable = false, length = 20)
    private String depAirportId;    // 출발 공항코드 (GIMPO)

    @Column(nullable = false, length = 20)
    private String arrAirportId;    // 도착 공항코드 (JEJU)

    @Column(nullable = false, length = 50)
    private String depAirportNm;    // 출발 공항명 (김포)

    @Column(nullable = false, length = 50)
    private String arrAirportNm;    // 도착 공항명 (제주)

    @Column(nullable = false)
    private String depPlandTime;    // 출발 예정시각 (20260501134000)

    @Column(nullable = false)
    private String arrPlandTime;    // 도착 예정시각 (20260501144500)

    // ── 가격 / 잔여석 ────────────────────────────────────────
    @Column(nullable = false)
    private Integer price;  // 일반석 가격 economyCharge

    @Column(nullable = false)
    private Integer seatsLeft;      // 잔여석

    // ── 수정 메서드 ───────────────────────────────────────────
    public void changeFlightInfo(
            String airlineNm,
            String flightNo,
            String depPlandTime,
            String arrPlandTime,
            Integer price, //economyCharg
            Integer seatsLeft) {
        this.airlineNm     = airlineNm;
        this.flightNo      = flightNo;
        this.depPlandTime  = depPlandTime;
        this.arrPlandTime  = arrPlandTime;
//        this.economyCharge = economyCharge;
        this.price = price;
        this.seatsLeft     = seatsLeft;
    }
}