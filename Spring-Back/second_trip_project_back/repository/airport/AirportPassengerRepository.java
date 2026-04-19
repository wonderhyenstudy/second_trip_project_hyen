package com.busanit401.second_trip_project_back.repository.airport;

import com.busanit401.second_trip_project_back.entity.airport.AirportPassenger;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AirportPassengerRepository
        extends JpaRepository<AirportPassenger, Long> {
}