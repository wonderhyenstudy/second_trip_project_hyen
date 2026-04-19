package com.busanit401.second_trip_project_back.repository.airport;

import com.busanit401.second_trip_project_back.entity.airport.AirportFlight;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AirportFlightRepository extends JpaRepository<AirportFlight, Long> {

    // ── 출발/도착 공항코드로 항공편 조회 ─────────────────────
    List<AirportFlight> findByDepAirportIdAndArrAirportId(
            String depAirportId,
            String arrAirportId

    );

    // ── 출발/도착 공항코드 + 출발날짜로 항공편 조회 ───────────
    List<AirportFlight> findByDepAirportIdAndArrAirportIdAndDepPlandTimeStartingWith(
            String depAirportId,
            String arrAirportId,
            String depPlandTime  // 앞 8자리 (20260501) 로 검색
    );
}