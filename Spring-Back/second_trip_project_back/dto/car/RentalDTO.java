package com.busanit401.second_trip_project_back.dto.car;

import com.busanit401.second_trip_project_back.domain.car.Rental;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
public class RentalDTO {
    private Long id;
    private Long carId;
    private String carName;
    private String companyName;
    private String userId;
    private LocalDate startDate;
    private LocalDate endDate;
    private String status;
    private int totalPrice;
    private LocalDateTime createdAt;

    public static RentalDTO from(Rental rental) {
        int days = (int) (rental.getEndDate().toEpochDay() - rental.getStartDate().toEpochDay());
        return RentalDTO.builder()
                .id(rental.getId())
                .carId(rental.getCar().getId())
                .carName(rental.getCar().getName())
                .companyName(rental.getCar().getCompany().getName())
                .userId(rental.getUser().getMid())
                .startDate(rental.getStartDate())
                .endDate(rental.getEndDate())
                .status(rental.getStatus().name())
                .totalPrice(rental.getCar().getDailyPrice() * days)
                .createdAt(rental.getCreatedAt())
                .build();
    }
}