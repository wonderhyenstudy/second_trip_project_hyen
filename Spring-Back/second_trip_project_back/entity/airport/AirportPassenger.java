package com.busanit401.second_trip_project_back.entity.airport;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "trip_airport_passenger")
@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class AirportPassenger {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // ── 예약과 연관관계 ──────────────────────────────────────
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reservation_id", nullable = false)
    private AirportReservation reservation;

    // ── 탑승객 정보 ──────────────────────────────────────────
    @Column(nullable = false, length = 10)
    private String passengerType;   // 성인/소아/유아

    @Column(nullable = false, length = 50)
    private String passengerName;   // 이름

    @Column(nullable = false, length = 8)
    private String passengerBirth;  // 생년월일

    @Column(nullable = false, length = 10)
    private String passengerGender; // 성별
}