package com.busanit401.second_trip_project_back.controller;

import com.busanit401.second_trip_project_back.dto.airport.AirportFlightDTO;
import com.busanit401.second_trip_project_back.service.airport.AirportFlightService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/airport")
@RequiredArgsConstructor
@Log4j2
@Tag(name = "Airport", description = "항공편 API")
public class AirportFlightController {

    private final AirportFlightService airportFlightService;

    // ── 항공편 목록 조회 ─────────────────────────────────────
    @GetMapping("/flights")
    @Operation(summary = "항공편 목록 조회",
            description = "출발지/도착지/날짜로 항공편 목록 조회")
    public ResponseEntity<List<AirportFlightDTO>> getFlightList(
            @RequestParam String depAirportId,
            @RequestParam String arrAirportId,
            @RequestParam String depPlandTime) {

        log.info("✅ [AirportFlightController] 항공편 목록 조회 → " +
                        "출발: {} / 도착: {} / 날짜: {}",
                depAirportId, arrAirportId, depPlandTime);

        List<AirportFlightDTO> list = airportFlightService.getFlightList(
                depAirportId,
                arrAirportId,
                depPlandTime
        );

        log.info("✅ [AirportFlightController] 조회 결과: {}건", list.size());

        return ResponseEntity.ok(list);
    }

    // ── 항공편 단건 조회 ─────────────────────────────────────
    @GetMapping("/flights/{id}")
    @Operation(summary = "항공편 단건 조회",
            description = "항공편 ID로 단건 조회")
    public ResponseEntity<AirportFlightDTO> getFlight(
            @PathVariable Long id) {

        log.info("✅ [AirportFlightController] 항공편 단건 조회 → id: {}", id);

        AirportFlightDTO dto = airportFlightService.getFlight(id);

        return ResponseEntity.ok(dto);
    }

    // ── 항공편 등록 (관리자) ──────────────────────────────────
    @PostMapping("/flights")
    @Operation(summary = "항공편 등록 (관리자)",
            description = "새로운 항공편 등록")
    public ResponseEntity<Long> register(
            @RequestBody AirportFlightDTO dto) {

        log.info("✅ [AirportFlightController] 항공편 등록 → {}", dto);

        Long id = airportFlightService.register(dto);

        log.info("✅ [AirportFlightController] 등록 완료 → id: {}", id);

        return ResponseEntity.ok(id);
    }

    // ── 항공편 수정 (관리자) ──────────────────────────────────
    @PutMapping("/flights/{id}")
    @Operation(summary = "항공편 수정 (관리자)",
            description = "항공편 정보 수정")
    public ResponseEntity<Void> modify(
            @PathVariable Long id,
            @RequestBody AirportFlightDTO dto) {

        log.info("✅ [AirportFlightController] 항공편 수정 → id: {}", id);

        dto = AirportFlightDTO.builder()
                .id(id)
                .airlineNm(dto.getAirlineNm())
                .flightNo(dto.getFlightNo())
                .depAirportId(dto.getDepAirportId())
                .arrAirportId(dto.getArrAirportId())
                .depAirportNm(dto.getDepAirportNm())
                .arrAirportNm(dto.getArrAirportNm())
                .depPlandTime(dto.getDepPlandTime())
                .arrPlandTime(dto.getArrPlandTime())
                .economyCharge(dto.getEconomyCharge())
                .seatsLeft(dto.getSeatsLeft())
                .build();

        airportFlightService.modify(dto);

        log.info("✅ [AirportFlightController] 수정 완료 → id: {}", id);

        return ResponseEntity.ok().build();
    }

    // ── 항공편 삭제 (관리자) ──────────────────────────────────
    @DeleteMapping("/flights/{id}")
    @Operation(summary = "항공편 삭제 (관리자)",
            description = "항공편 삭제")
    public ResponseEntity<Void> remove(
            @PathVariable Long id) {

        log.info("✅ [AirportFlightController] 항공편 삭제 → id: {}", id);

        airportFlightService.remove(id);

        log.info("✅ [AirportFlightController] 삭제 완료 → id: {}", id);

        return ResponseEntity.ok().build();
    }

}