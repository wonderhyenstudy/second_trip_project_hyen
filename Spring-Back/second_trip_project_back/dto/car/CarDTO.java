package com.busanit401.second_trip_project_back.dto.car;

import com.busanit401.second_trip_project_back.domain.car.Car;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class CarDTO {
    private Long id;
    private Long companyId;
    private String companyName;
    private String name;
    private String type;
    private int seats;
    private String fuel;
    private int dailyPrice;
    private int year;
    public static CarDTO from(Car car) {
        return CarDTO.builder()
                .id(car.getId())
                .companyId(car.getCompany().getId())
                .companyName(car.getCompany().getName())
                .name(car.getName())
                .type(car.getType())
                .seats(car.getSeats())
                .fuel(car.getFuel())
                .dailyPrice(car.getDailyPrice())
                .year(car.getYear())
                .build();
    }
}