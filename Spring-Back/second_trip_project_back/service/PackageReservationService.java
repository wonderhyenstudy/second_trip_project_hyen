package com.busanit401.second_trip_project_back.service;

import com.busanit401.second_trip_project_back.dto.PackageReservationDto;

public interface PackageReservationService {
    Long register(PackageReservationDto packageReservationDto);
}
