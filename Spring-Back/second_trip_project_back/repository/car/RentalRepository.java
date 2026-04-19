package com.busanit401.second_trip_project_back.repository.car;

import com.busanit401.second_trip_project_back.domain.car.Rental;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface RentalRepository extends JpaRepository<Rental, Long> {

    // 특정 유저의 예약 목록
    List<Rental> findByUserMid(String mid);

    // 날짜 겹치는 예약 존재 여부 (취소 제외)
    @Query("SELECT COUNT(r) > 0 FROM Rental r WHERE r.car.id = :carId " +
            "AND r.status != 'CANCELLED' " +
            "AND r.startDate < :endDate AND r.endDate >= :startDate")
    boolean existsOverlap(@Param("carId") Long carId,
                          @Param("startDate") LocalDate startDate,
                          @Param("endDate") LocalDate endDate);

    // 해당 기간에 예약된 차량 id 목록
    @Query("SELECT DISTINCT r.car.id FROM Rental r WHERE r.status != 'CANCELLED' " +
            "AND r.startDate < :endDate AND r.endDate >= :startDate")
    List<Long> findUnavailableCarIds(@Param("startDate") LocalDate startDate,
                                     @Param("endDate") LocalDate endDate);
}