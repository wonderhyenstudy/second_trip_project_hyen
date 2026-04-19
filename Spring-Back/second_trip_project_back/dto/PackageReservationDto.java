package com.busanit401.second_trip_project_back.dto;

import lombok.*;
import java.time.LocalDate;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class PackageReservationDto {

    private Long memberId;
    private String packageId;
    private LocalDate reservationDate;
    private int peopleCount;
    private int totalPrice;


}