package com.busanit401.second_trip_project_back.service.airport;

import com.busanit401.second_trip_project_back.dto.airport.AirportFlightDTO;
import com.busanit401.second_trip_project_back.entity.airport.AirportFlight;
import com.busanit401.second_trip_project_back.repository.airport.AirportFlightRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Log4j2
public class AirportFlightServiceImpl implements AirportFlightService {

    private final AirportFlightRepository airportFlightRepository;

    // ── 항공편 목록 조회 ─────────────────────────────────────
    @Override
    public List<AirportFlightDTO> getFlightList(
            String depAirportId,
            String arrAirportId,
            String depPlandTime) {

        log.info("✅ [AirportFlightService] 항공편 목록 조회 → " +
                        "출발: {} / 도착: {} / 날짜: {}",
                depAirportId, arrAirportId, depPlandTime);

        List<AirportFlight> flights =
                airportFlightRepository
                        .findByDepAirportIdAndArrAirportIdAndDepPlandTimeStartingWith(
                                depAirportId,
                                arrAirportId,
                                depPlandTime
                        );

        log.info("✅ [AirportFlightService] 조회 결과: {}건", flights.size());

        return flights.stream()
                .map(AirportFlightDTO::fromEntity)
                .collect(Collectors.toList());
    }

    // ── 항공편 단건 조회 ─────────────────────────────────────
    @Override
    public AirportFlightDTO getFlight(Long id) {

        log.info("✅ [AirportFlightService] 항공편 단건 조회 → id: {}", id);

        AirportFlight flight = airportFlightRepository.findById(id)
                .orElseThrow(() -> {
                    log.error("❌ [AirportFlightService] 항공편 없음 → id: {}", id);
                    return new RuntimeException("항공편을 찾을 수 없습니다. id: " + id);
                });

        return AirportFlightDTO.fromEntity(flight);
    }

    // ── 항공편 등록 (관리자) ──────────────────────────────────
    @Override
    public Long register(AirportFlightDTO dto) {

        log.info("✅ [AirportFlightService] 항공편 등록 → {}", dto);

        AirportFlight flight = dto.toEntity();
        AirportFlight saved  = airportFlightRepository.save(flight);

        log.info("✅ [AirportFlightService] 등록 완료 → id: {}", saved.getId());

        return saved.getId();
    }

    // ── 항공편 수정 (관리자) ──────────────────────────────────
    @Override
    public void modify(AirportFlightDTO dto) {

        log.info("✅ [AirportFlightService] 항공편 수정 → id: {}", dto.getId());

        AirportFlight flight = airportFlightRepository.findById(dto.getId())
                .orElseThrow(() -> {
                    log.error("❌ [AirportFlightService] 항공편 없음 → id: {}", dto.getId());
                    return new RuntimeException("항공편을 찾을 수 없습니다. id: " + dto.getId());
                });

        flight.changeFlightInfo(
                dto.getAirlineNm(),
                dto.getFlightNo(),
                dto.getDepPlandTime(),
                dto.getArrPlandTime(),
                dto.getEconomyCharge(),
                dto.getSeatsLeft()
        );

        airportFlightRepository.save(flight);
        log.info("✅ [AirportFlightService] 수정 완료 → id: {}", dto.getId());
    }

    // ── 항공편 삭제 (관리자) ──────────────────────────────────
    @Override
    public void remove(Long id) {

        log.info("✅ [AirportFlightService] 항공편 삭제 → id: {}", id);

        if (!airportFlightRepository.existsById(id)) {
            log.error("❌ [AirportFlightService] 항공편 없음 → id: {}", id);
            throw new RuntimeException("항공편을 찾을 수 없습니다. id: " + id);
        }

        airportFlightRepository.deleteById(id);
        log.info("✅ [AirportFlightService] 삭제 완료 → id: {}", id);
    }
}