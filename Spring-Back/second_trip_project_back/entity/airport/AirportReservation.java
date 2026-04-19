package com.busanit401.second_trip_project_back.entity.airport;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "trip_airport_reservation")
@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class AirportReservation {

    // ── 기본키 ──────────────────────────────────────────────
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // ── 회원 정보 (로그인 연동) ──────────────────────────────
    @Column(length = 50)
    private String mid;    // ✅ 로그인 회원 ID

    // ── 가는편 정보 ──────────────────────────────────────────
    @Column(nullable = false, length = 50)
    private String airlineNm;       // 항공사명

    @Column(nullable = false, length = 20)
    private String flightNo;        // 항공편명

    @Column(nullable = false, length = 50)
    private String depAirportNm;    // 출발 공항명

    @Column(nullable = false, length = 50)
    private String arrAirportNm;    // 도착 공항명

    @Column(nullable = false, length = 20)
    private String depAirportId;    // 출발 공항코드

    @Column(nullable = false, length = 20)
    private String arrAirportId;    // 도착 공항코드

    @Column(nullable = false)
    private String depPlandTime;    // 출발 예정시각

    @Column(nullable = false)
    private String arrPlandTime;    // 도착 예정시각

    @Column(nullable = false)
    private Integer depPrice;       // 가는편 가격

    // ── 오는편 정보 (왕복일 때) ──────────────────────────────
    @Column(length = 50)
    private String retAirlineNm;    // 오는편 항공사명

    @Column(length = 20)
    private String retFlightNo;     // 오는편 항공편명

    @Column
    private String retDepPlandTime; // 오는편 출발 예정시각

    @Column
    private String retArrPlandTime; // 오는편 도착 예정시각

    @Column
    private Integer retPrice;       // 오는편 가격

    // ── 탑승객 정보 ──────────────────────────────────────────
//    @Column(nullable = false, length = 50)
//    private String passengerName;   // 탑승객 이름
//
//    @Column(nullable = false, length = 8)
//    private String passengerBirth;  // 생년월일
//
//    @Column(nullable = false, length = 10)
//    private String passengerGender; // 성별

    // ── 탑승객 목록 (passenger 테이블로 분리) ────────────────
    @OneToMany(mappedBy = "reservation",
            cascade = CascadeType.ALL,
            orphanRemoval = true)
    @Builder.Default
    private List<AirportPassenger> passengers = new ArrayList<>();

    // ── 예약 정보 ────────────────────────────────────────────
    @Column(nullable = false)
    private Boolean isRoundTrip;    // 편도/왕복

    @Column(nullable = false)
    private String reservedAt;      // 예약 일시

    // ── 수정 메서드 ───────────────────────────────────────────
    public void changeReservationInfo(
            String passengerName,
            String passengerBirth,
            String passengerGender) {
//        this.passengerName   = passengerName;
//        this.passengerBirth  = passengerBirth;
//        this.passengerGender = passengerGender;
    }
}