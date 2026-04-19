package com.busanit401.second_trip_project_back.service.airport;

import com.busanit401.second_trip_project_back.dto.airport.AirportFlightDTO;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Transactional
public interface AirportFlightService {

    // ── 항공편 목록 조회 ─────────────────────────────────────
    List<AirportFlightDTO> getFlightList(
            String depAirportId,
            String arrAirportId,
            String depPlandTime
    );

    // ── 항공편 단건 조회 ─────────────────────────────────────
    AirportFlightDTO getFlight(Long id);

    // ── 항공편 등록 (관리자) ──────────────────────────────────
    Long register(AirportFlightDTO dto);

    // ── 항공편 수정 (관리자) ──────────────────────────────────
    void modify(AirportFlightDTO dto);

    // ── 항공편 삭제 (관리자) ──────────────────────────────────
    void remove(Long id);
}