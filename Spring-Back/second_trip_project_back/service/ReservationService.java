package com.busanit401.second_trip_project_back.service;

import com.busanit401.second_trip_project_back.domain.member.Member;
import com.busanit401.second_trip_project_back.dto.loging.ReservationRequestDTO;
import com.busanit401.second_trip_project_back.dto.loging.ReservationResponseDTO;
import com.busanit401.second_trip_project_back.entity.Reservation;
import com.busanit401.second_trip_project_back.enums.ReservationStatus;
import com.busanit401.second_trip_project_back.repository.ReservationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class ReservationService {

    private final ReservationRepository reservationRepository;

    // ─── 예약 생성 ────────────────────────────────────
    public ReservationResponseDTO createReservation(
            Member member,
            ReservationRequestDTO requestDTO) {

        // 날짜 중복 체크
        List<Reservation> overlapping = reservationRepository
                .findOverlappingReservations(
                        requestDTO.getContentId(),
                        requestDTO.getRoomCode(),
                        requestDTO.getCheckInDate(),
                        requestDTO.getCheckOutDate());

        if (!overlapping.isEmpty()) {
            throw new IllegalStateException("해당 날짜에 이미 예약이 있습니다.");
        }

        // 예약 생성
        Reservation reservation = Reservation.builder()
                .member(member)
                .contentId(requestDTO.getContentId())
                .roomCode(requestDTO.getRoomCode())
                .accommodationTitle(requestDTO.getAccommodationTitle())
                .roomTitle(requestDTO.getRoomTitle())
                .checkInDate(requestDTO.getCheckInDate())
                .checkOutDate(requestDTO.getCheckOutDate())
                .guestCount(requestDTO.getGuestCount())
                .totalPrice(requestDTO.getTotalPrice())
                .build();

        Reservation saved = reservationRepository.save(reservation);
        log.info("예약 생성 완료: {}", saved.getId());

        return ReservationResponseDTO.from(saved);
    }

    // ─── 내 예약 목록 조회 ────────────────────────────
    @Transactional(readOnly = true)
    public List<ReservationResponseDTO> getMyReservations(Member member) {
        return reservationRepository
                .findByMemberOrderByRegDateDesc(member)
                .stream()
                .map(ReservationResponseDTO::from)
                .collect(Collectors.toList());
    }

    // ─── 예약 상태별 조회 ─────────────────────────────
    @Transactional(readOnly = true)
    public List<ReservationResponseDTO> getMyReservationsByStatus(
            Member member, ReservationStatus status) {
        return reservationRepository
                .findByMemberAndStatusOrderByRegDateDesc(member, status)
                .stream()
                .map(ReservationResponseDTO::from)
                .collect(Collectors.toList());
    }

    // ─── 예약 취소 ────────────────────────────────────
    public ReservationResponseDTO cancelReservation(
            Member member, Long reservationId) {

        Reservation reservation = reservationRepository
                .findById(reservationId)
                .orElseThrow(() ->
                        new IllegalArgumentException("예약을 찾을 수 없습니다."));

        // 본인 예약인지 확인
        if (!reservation.getMember().getId().equals(member.getId())) {
            throw new IllegalStateException("본인의 예약만 취소할 수 있습니다.");
        }

        // 이미 취소된 예약인지 확인
        if (reservation.getStatus() == ReservationStatus.CANCELLED) {
            throw new IllegalStateException("이미 취소된 예약입니다.");
        }

        reservation.cancel();
        log.info("예약 취소 완료: {}", reservationId);

        return ReservationResponseDTO.from(reservation);
    }
}
