package com.busanit401.second_trip_project_back.controller;

import com.busanit401.second_trip_project_back.dto.PackageReservationDto;
import com.busanit401.second_trip_project_back.service.PackageReservationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/reservations")
@RequiredArgsConstructor
@Log4j2
public class PackageReservationController {

    private final PackageReservationService packageReservationService;

    @PostMapping("/")
    public ResponseEntity<Long> register(@RequestBody PackageReservationDto packageReservationDto) {
        log.info("예약 요청 데이터: " + packageReservationDto);

        Long reservationId = packageReservationService.register(packageReservationDto);

        return ResponseEntity.ok(reservationId);
    }
}