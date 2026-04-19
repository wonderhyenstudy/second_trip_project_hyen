package com.busanit401.second_trip_project_back.service.car;

import com.busanit401.second_trip_project_back.dto.car.CarDTO;
import com.busanit401.second_trip_project_back.dto.car.RentCompanyDTO;

import java.util.List;

public interface RentCarService {

    // 회사 목록 전체 or 지역별
    List<RentCompanyDTO> getCompanies(String region);

    // 회사 단건 조회
    RentCompanyDTO getCompany(Long companyId);

    // 특정 회사의 차량 목록
    List<CarDTO> getCarsByCompany(Long companyId);

    // 전체 차량 필터 조회
    List<CarDTO> getCars(String type, String fuel, Integer seats);

    // 차량 단건 조회
    CarDTO getCar(Long carId);
}