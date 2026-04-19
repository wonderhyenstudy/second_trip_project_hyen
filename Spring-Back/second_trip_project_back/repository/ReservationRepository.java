package com.busanit401.second_trip_project_back.repository;

import com.busanit401.second_trip_project_back.domain.member.Member;
import com.busanit401.second_trip_project_back.entity.Reservation;
import com.busanit401.second_trip_project_back.enums.ReservationStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ReservationRepository extends JpaRepository<Reservation, Long> {

    // 특정 회원의 예약 목록 전체 조회
    List<Reservation> findByMemberOrderByRegDateDesc(Member member);

    // 특정 회원의 특정 상태 예약 조회
    List<Reservation> findByMemberAndStatusOrderByRegDateDesc(
            Member member, ReservationStatus status);

    // 특정 숙소의 예약 목록 조회 (객실 재고 확인용)
    @Query("SELECT r FROM Reservation r WHERE r.contentId = :contentId " +
            "AND r.roomCode = :roomCode " +
            "AND r.status != 'CANCELLED' " +
            "AND r.checkInDate < :checkOut " +
            "AND r.checkOutDate > :checkIn")
    List<Reservation> findOverlappingReservations(
            @Param("contentId") String contentId,
            @Param("roomCode") String roomCode,
            @Param("checkIn") java.time.LocalDate checkIn,
            @Param("checkOut") java.time.LocalDate checkOut);
}
