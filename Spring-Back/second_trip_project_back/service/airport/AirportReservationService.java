package com.busanit401.second_trip_project_back.service.airport;

import com.busanit401.second_trip_project_back.dto.airport.AirportReservationDTO;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Transactional
public interface AirportReservationService {

    // ── 예약 등록 ─────────────────────────────────────────────
    Long register(AirportReservationDTO dto);

    // ── 예약 단건 조회 ────────────────────────────────────────
    AirportReservationDTO getReservation(Long id);

    // ── 전체 예약 목록 조회 ───────────────────────────────────
    List<AirportReservationDTO> getReservationList();

    // ── 회원 ID로 예약 조회 ───────────────────────────────────
//    List<AirportReservationDTO> getReservationListByMemberId(String mid);
    List<AirportReservationDTO> getReservationListByMid(String mid);

    // ── 탑승객 이름으로 예약 조회 ─────────────────────────────
//    List<AirportReservationDTO> getReservationListByName(String passengerName);

    // ── 예약 취소 (삭제) ──────────────────────────────────────
    void remove(Long id);
}