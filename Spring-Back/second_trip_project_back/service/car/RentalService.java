package com.busanit401.second_trip_project_back.service.car;

import com.busanit401.second_trip_project_back.dto.car.CarSearchResultDTO;
import com.busanit401.second_trip_project_back.dto.car.RentalDTO;
import com.busanit401.second_trip_project_back.dto.car.RentalRequestDTO;

import java.time.LocalDate;
import java.util.List;

public interface RentalService {
    RentalDTO createRental(String mid, RentalRequestDTO request);
    List<RentalDTO> getMyRentals(String mid);
    RentalDTO cancelRental(String mid, Long rentalId);
    List<Long> getUnavailableCarIds(LocalDate startDate, LocalDate endDate);
    List<CarSearchResultDTO> searchCars(String region, LocalDate startDate, LocalDate endDate);
}