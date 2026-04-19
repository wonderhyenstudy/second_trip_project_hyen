package com.busanit401.second_trip_project_back.service.airport;

import com.busanit401.second_trip_project_back.dto.airport.AirportPassengerDTO;
import com.busanit401.second_trip_project_back.dto.airport.AirportReservationDTO;
import com.busanit401.second_trip_project_back.entity.airport.AirportPassenger;
import com.busanit401.second_trip_project_back.entity.airport.AirportReservation;
import com.busanit401.second_trip_project_back.repository.airport.AirportReservationRepository;
import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Log4j2
public class AirportReservationServiceImpl implements AirportReservationService {

    private final AirportReservationRepository airportReservationRepository;

    // ── 예약 등록 ─────────────────────────────────────────────
    @Override
    @Transactional
    public Long register(AirportReservationDTO dto) {

        log.info("✅ [AirportReservationService] 예약 등록 → mid: {}",
                dto.getMid());

        // ✅ [추가] 중복 예약 체크
        if (dto.getPassengers() != null) {
            for (AirportPassengerDTO passenger : dto.getPassengers()) {
                boolean isDuplicate =
//                        airportReservationRepository
//                        .existsByFlightNoAndPassengers_PassengerNameAndPassengers_PassengerBirth(
//                                dto.getFlightNo(),
//                                passenger.getPassengerName(),
//                                passenger.getPassengerBirth()
//                        );
                // ✅ [변경 후]
                airportReservationRepository
                    .existsDuplicateReservation(
                            dto.getFlightNo(),
                            passenger.getPassengerName(),
                            passenger.getPassengerBirth()
                    );
                if (isDuplicate) {
                    log.warn("❌ [AirportReservationService] 중복 예약 → "
                                    + "항공편: {} / 탑승객: {}",
                            dto.getFlightNo(),
                            passenger.getPassengerName());
                    throw new RuntimeException(
                            "이미 예약된 항공편입니다. 탑승객: "
                                    + passenger.getPassengerName());
                }
            }
        }

        // ✅ 1단계: 예약 먼저 저장
        AirportReservation reservation = dto.toEntity();
        AirportReservation saved = airportReservationRepository.save(reservation);

        // ✅ 2단계: 탑승객 목록 저장
        if (dto.getPassengers() != null && !dto.getPassengers().isEmpty()) {
            for (AirportPassengerDTO passengerDTO : dto.getPassengers()) {
                AirportPassenger passenger = passengerDTO.toEntity(saved);
                saved.getPassengers().add(passenger);
            }
            airportReservationRepository.save(saved);
            log.info("✅ [AirportReservationService] 탑승객 {}명 저장 완료",
                    dto.getPassengers().size());
        }

        log.info("✅ [AirportReservationService] 예약 등록 완료 → id: {}",
                saved.getId());

        return saved.getId();
    }

    // ── 예약 단건 조회 ────────────────────────────────────────
    @Override
    public AirportReservationDTO getReservation(Long id) {

        log.info("✅ [AirportReservationService] 예약 단건 조회 → id: {}", id);

        AirportReservation reservation = airportReservationRepository.findById(id)
                .orElseThrow(() -> {
                    log.error("❌ [AirportReservationService] 예약 없음 → id: {}", id);
                    return new RuntimeException("예약을 찾을 수 없습니다. id: " + id);
                });

        return AirportReservationDTO.fromEntity(reservation);
    }

    // ── 전체 예약 목록 조회 ───────────────────────────────────
    @Override
    public List<AirportReservationDTO> getReservationList() {

        log.info("✅ [AirportReservationService] 전체 예약 목록 조회");

        List<AirportReservation> list =
                airportReservationRepository.findAllByOrderByReservedAtDesc();

        log.info("✅ [AirportReservationService] 조회 완료 → {}건", list.size());

        return list.stream()
                .map(AirportReservationDTO::fromEntity)
                .collect(Collectors.toList());
    }

    // ── 회원 ID로 예약 조회 ───────────────────────────────────
    @Override
    public List<AirportReservationDTO> getReservationListByMid(String mid) {

        log.info("✅ [AirportReservationService] mid로 조회 → {}", mid);

        List<AirportReservation> list =
                airportReservationRepository
                        .findByMidOrderByReservedAtDesc(mid);

        log.info("✅ [AirportReservationService] 조회 완료 → {}건", list.size());

        return list.stream()
                .map(AirportReservationDTO::fromEntity)
                .collect(Collectors.toList());
    }

    // ── 탑승객 이름으로 예약 조회 ─────────────────────────────
//    @Override
//    public List<AirportReservationDTO> getReservationListByName(
//            String passengerName) {
//
//        log.info("✅ [AirportReservationService] 탑승객 이름으로 조회 → {}",
//                passengerName);
//
//        List<AirportReservation> list =
//                airportReservationRepository
//                        .findByPassengerNameOrderByReservedAtDesc(passengerName);
//
//        log.info("✅ [AirportReservationService] 조회 완료 → {}건", list.size());
//
//        return list.stream()
//                .map(AirportReservationDTO::fromEntity)
//                .collect(Collectors.toList());
//    }

    // ── 예약 취소 (삭제) ──────────────────────────────────────
    @Override
    public void remove(Long id) {

        log.info("✅ [AirportReservationService] 예약 취소 → id: {}", id);

        if (!airportReservationRepository.existsById(id)) {
            log.error("❌ [AirportReservationService] 예약 없음 → id: {}", id);
            throw new RuntimeException("예약을 찾을 수 없습니다. id: " + id);
        }

        airportReservationRepository.deleteById(id);
        log.info("✅ [AirportReservationService] 예약 취소 완료 → id: {}", id);
    }
}