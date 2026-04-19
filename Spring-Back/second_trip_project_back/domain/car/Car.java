package com.busanit401.second_trip_project_back.domain.car;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "trip_car")
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class Car {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "company_id")
    private RentCompany company;

    private String name;

    private String type;

    private int seats;

    private String fuel;

    @Column(name = "daily_price")
    private int dailyPrice;

    private int year;
}