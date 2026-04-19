package com.busanit401.second_trip_project_back.repository.airport;

import com.busanit401.second_trip_project_back.entity.airport.AirportReservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AirportReservationRepository
        extends JpaRepository<AirportReservation, Long> {

    // ── 회원 ID로 예약 조회 ───────────────────────────────────
//    List<AirportReservation> findByMemberIdOrderByReservedAtDesc(String mid);
    List<AirportReservation> findByMidOrderByReservedAtDesc(String mid);


    // ── 탑승객 이름으로 예약 조회 ─────────────────────────────
//    List<AirportReservation> findByPassengerName(String passengerName);

    // ── 예약 일시 내림차순 전체 조회 ─────────────────────────
    List<AirportReservation> findAllByOrderByReservedAtDesc();

    // ✅ [추가] 중복 예약 체크
    // 같은 항공편 + 같은 탑승객 이름 + 같은 생년월일
//    boolean existsByFlightNoAndPassengers_PassengerNameAndPassengers_PassengerBirth(
//            String flightNo,
//            String passengerName,
//            String passengerBirth
//    );
    // ✅ [변경 후] JPQL 직접 작성
    @Query("SELECT COUNT(r) > 0 FROM AirportReservation r " +
            "JOIN r.passengers p " +
            "WHERE r.flightNo = :flightNo " +
            "AND p.passengerName = :passengerName " +
            "AND p.passengerBirth = :passengerBirth")
    boolean existsDuplicateReservation(
            @Param("flightNo") String flightNo,
            @Param("passengerName") String passengerName,
            @Param("passengerBirth") String passengerBirth
    );

    // ── 탑승객 이름 + 내림차순 조회 ──────────────────────────
//    List<AirportReservation> findByPassengerNameOrderByReservedAtDesc(
//            String passengerName);
}