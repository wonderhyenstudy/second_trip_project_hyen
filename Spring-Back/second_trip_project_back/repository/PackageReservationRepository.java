package com.busanit401.second_trip_project_back.repository;

import com.busanit401.second_trip_project_back.domain.packages.PackageReservation;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PackageReservationRepository extends JpaRepository<PackageReservation, Long> {
}