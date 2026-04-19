package com.busanit401.second_trip_project_back.dto.car;

import lombok.Data;

import java.time.LocalDate;

@Data
public class RentalRequestDTO {
    private Long carId;
    private LocalDate startDate;
    private LocalDate endDate;
}