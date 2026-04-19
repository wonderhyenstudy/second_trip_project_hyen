package com.busanit401.second_trip_project_back.controller;

import com.busanit401.second_trip_project_back.dto.car.CarDTO;
import com.busanit401.second_trip_project_back.dto.car.RentCompanyDTO;
import com.busanit401.second_trip_project_back.service.car.RentCarService;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/rent")
@Log4j2
@RequiredArgsConstructor
public class RentCarController {

    private final RentCarService rentCarService;

    // 렌트 회사 목록 (region 파라미터로 지역 필터링 가능)
    // GET /rent/companies
    // GET /rent/companies?region=부산
    @GetMapping("/companies")
    public ResponseEntity<List<RentCompanyDTO>> getCompanies(
            @RequestParam(required = false) String region) {
        return ResponseEntity.ok(rentCarService.getCompanies(region));
    }

    // 렌트 회사 단건 조회
    // GET /rent/companies/{id}
    @GetMapping("/companies/{id}")
    public ResponseEntity<RentCompanyDTO> getCompany(@PathVariable Long id) {
        return ResponseEntity.ok(rentCarService.getCompany(id));
    }

    // 특정 회사의 차량 목록
    // GET /rent/companies/{id}/cars
    @GetMapping("/companies/{id}/cars")
    public ResponseEntity<List<CarDTO>> getCarsByCompany(@PathVariable Long id) {
        return ResponseEntity.ok(rentCarService.getCarsByCompany(id));
    }

    // 전체 차량 목록 (필터링 가능)
    // GET /rent/cars
    // GET /rent/cars?type=SUV&fuel=디젤&seats=7&available=true
    @GetMapping("/cars")
    public ResponseEntity<List<CarDTO>> getCars(
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String fuel,
            @RequestParam(required = false) Integer seats) {
        return ResponseEntity.ok(rentCarService.getCars(type, fuel, seats));
    }

    // 차량 단건 조회
    // GET /rent/cars/{id}
    @GetMapping("/cars/{id}")
    public ResponseEntity<CarDTO> getCar(@PathVariable Long id) {
        return ResponseEntity.ok(rentCarService.getCar(id));
    }
}
