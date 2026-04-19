package com.busanit401.second_trip_project_back.controller;

import com.busanit401.second_trip_project_back.dto.car.CarSearchResultDTO;
import com.busanit401.second_trip_project_back.dto.car.RentalDTO;
import com.busanit401.second_trip_project_back.dto.car.RentalRequestDTO;
import com.busanit401.second_trip_project_back.service.car.RentalService;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/rental")
@Log4j2
@RequiredArgsConstructor
public class RentalController {

    private final RentalService rentalService;

    // 예약 생성
    // POST /api/rental
    @PostMapping
    public ResponseEntity<RentalDTO> createRental(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody RentalRequestDTO request) {
        return ResponseEntity.ok(rentalService.createRental(userDetails.getUsername(), request));
    }

    // 내 예약 목록
    // GET /api/rental/my
    @GetMapping("/my")
    public ResponseEntity<List<RentalDTO>> getMyRentals(
            @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(rentalService.getMyRentals(userDetails.getUsername()));
    }

    // 예약 취소
    // DELETE /api/rental/{id}
    @DeleteMapping("/{id}")
    public ResponseEntity<RentalDTO> cancelRental(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long id) {
        return ResponseEntity.ok(rentalService.cancelRental(userDetails.getUsername(), id));
    }

    // 특정 기간에 예약 불가 차량 id 목록
    // GET /api/rental/unavailable?startDate=2025-05-01&endDate=2025-05-05
    @GetMapping("/unavailable")
    public ResponseEntity<List<Long>> getUnavailableCarIds(
            @RequestParam LocalDate startDate,
            @RequestParam LocalDate endDate) {
        return ResponseEntity.ok(rentalService.getUnavailableCarIds(startDate, endDate));
    }

    // 지역+기간으로 예약 가능한 차량 검색 (차량명으로 그룹핑)
    // GET /api/rental/search?region=부산&startDate=2025-05-01&endDate=2025-05-05
    @GetMapping("/search")
    public ResponseEntity<List<CarSearchResultDTO>> searchCars(
            @RequestParam String region,
            @RequestParam LocalDate startDate,
            @RequestParam LocalDate endDate) {
        return ResponseEntity.ok(rentalService.searchCars(region, startDate, endDate));
    }
}