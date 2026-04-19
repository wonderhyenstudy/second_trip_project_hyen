package com.busanit401.second_trip_project_back.repository.car;

import com.busanit401.second_trip_project_back.domain.car.RentCompany;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RentCompanyRepository extends JpaRepository<RentCompany, Long> {
    boolean existsByNameAndRoadAddress(String name, String roadAddress);
    List<RentCompany> findByRegion(String region);
}