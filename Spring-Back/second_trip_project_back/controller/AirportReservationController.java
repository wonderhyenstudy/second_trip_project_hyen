package com.busanit401.second_trip_project_back.controller;

import com.busanit401.second_trip_project_back.dto.airport.AirportReservationDTO;
import com.busanit401.second_trip_project_back.service.airport.AirportReservationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/airport")
@RequiredArgsConstructor
@Log4j2
@Tag(name = "AirportReservation", description = "항공 예약 API")
public class AirportReservationController {

    private final AirportReservationService airportReservationService;

    // ── 예약 등록 (중복 체크 포함) ───────────────────────────
    @PostMapping("/reservations")
    @Operation(summary = "예약 등록",
            description = "항공권 예약 등록 (중복 예약 시 400 반환)")
    public ResponseEntity<?> register(
            @RequestBody AirportReservationDTO dto) {

        log.info("✅ [AirportReservationController] 예약 등록 → mid: {}",
                dto.getMid());
        log.info("✅ [AirportReservationController] depAirportId: {} / arrAirportId: {} / depPlandTime: {}",
                dto.getDepAirportId(), dto.getArrAirportId(), dto.getDepPlandTime());

        try {
            Long id = airportReservationService.register(dto);
            log.info("✅ [AirportReservationController] 예약 등록 완료 → id: {}", id);
            return ResponseEntity.ok(id);
        } catch (RuntimeException e) {
            // ✅ 중복 예약 시 400 + message 반환
            log.warn("❌ [AirportReservationController] 예약 실패 → {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(Map.of("message", e.getMessage()));
        }
    }

    // ── 예약 단건 조회 ────────────────────────────────────────
    @GetMapping("/reservations/{id}")
    @Operation(summary = "예약 단건 조회",
            description = "예약 ID로 단건 조회")
    public ResponseEntity<AirportReservationDTO> getReservation(
            @PathVariable Long id) {

        log.info("✅ [AirportReservationController] 예약 단건 조회 → id: {}", id);

        AirportReservationDTO dto = airportReservationService.getReservation(id);

        return ResponseEntity.ok(dto);
    }

    // ── 전체 예약 목록 조회 ───────────────────────────────────
    @GetMapping("/reservations")
    @Operation(summary = "전체 예약 목록 조회",
            description = "전체 예약 목록 조회 (관리자)")
    public ResponseEntity<List<AirportReservationDTO>> getReservationList() {

        log.info("✅ [AirportReservationController] 전체 예약 목록 조회");

        List<AirportReservationDTO> list =
                airportReservationService.getReservationList();

        log.info("✅ [AirportReservationController] 조회 완료 → {}건", list.size());

        return ResponseEntity.ok(list);
    }

    // ── 회원 ID(mid)로 예약 조회 ─────────────────────────────
    @GetMapping("/reservations/my")
    @Operation(summary = "회원 ID(mid)로 예약 조회",
            description = "로그인 회원 mid로 내 예약 목록 조회")
    public ResponseEntity<List<AirportReservationDTO>> getReservationListByMid(
            @RequestParam String mid) {

        log.info("✅ [AirportReservationController] mid로 조회 → {}", mid);

        List<AirportReservationDTO> list =
                airportReservationService.getReservationListByMid(mid);

        log.info("✅ [AirportReservationController] 조회 완료 → {}건", list.size());

        return ResponseEntity.ok(list);
    }

    // ── 탑승객 이름으로 예약 조회 ─────────────────────────────
//    @GetMapping("/reservations/my")
//    @Operation(summary = "탑승객 이름으로 예약 조회",
//            description = "탑승객 이름으로 내 예약 목록 조회")
//    public ResponseEntity<List<AirportReservationDTO>> getReservationListByName(
//            @RequestParam String passengerName) {
//
//        log.info("✅ [AirportReservationController] 탑승객 이름으로 조회 → {}",
//                passengerName);
//
//        List<AirportReservationDTO> list =
//                airportReservationService.getReservationListByName(passengerName);
//
//        log.info("✅ [AirportReservationController] 조회 완료 → {}건", list.size());
//
//        return ResponseEntity.ok(list);
//    }

    // ── 예약 취소 (삭제) ──────────────────────────────────────
    @DeleteMapping("/reservations/{id}")
    @Operation(summary = "예약 취소",
            description = "예약 취소 (삭제)")
    public ResponseEntity<Void> remove(
            @PathVariable Long id) {

        log.info("✅ [AirportReservationController] 예약 취소 → id: {}", id);

        airportReservationService.remove(id);

        log.info("✅ [AirportReservationController] 예약 취소 완료 → id: {}", id);

        return ResponseEntity.ok().build();
    }

}