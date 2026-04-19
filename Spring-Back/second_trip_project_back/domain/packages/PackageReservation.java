package com.busanit401.second_trip_project_back.domain.packages;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "trip_package_reservation")
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@ToString
public class PackageReservation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long memberId;

    @Column(nullable = false)
    private String packageId;

    @Column(nullable = false)
    private LocalDate reservationDate;

    @Column(nullable = false)
    private int peopleCount;

    @Column(nullable = false)
    private int totalPrice;

    // 필요시 생성자나 연관관계 설정 메소드를 여기에 추가합니다.
}