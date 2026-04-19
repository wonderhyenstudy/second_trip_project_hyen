package com.busanit401.second_trip_project_back.dto.airport;

import com.busanit401.second_trip_project_back.entity.airport.AirportPassenger;
import com.busanit401.second_trip_project_back.entity.airport.AirportReservation;
import lombok.*;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AirportPassengerDTO {

    // ── 기본키 ──────────────────────────────────────────────
    private Long id;

    // ── 탑승객 정보 ──────────────────────────────────────────
    private String passengerType;   // 탑승객 유형 (성인/소아/유아)
    private String passengerName;   // 탑승객 이름
    private String passengerBirth;  // 생년월일 (YYYYMMDD)
    private String passengerGender; // 성별 (남성/여성)

    // ── Entity → DTO 변환 ────────────────────────────────────
    public static AirportPassengerDTO fromEntity(AirportPassenger entity) {
        return AirportPassengerDTO.builder()
                .id(entity.getId())                             // 기본키
                .passengerType(entity.getPassengerType())       // 탑승객 유형
                .passengerName(entity.getPassengerName())       // 탑승객 이름
                .passengerBirth(entity.getPassengerBirth())     // 생년월일
                .passengerGender(entity.getPassengerGender())   // 성별
                .build();
    }

    // ── DTO → Entity 변환 ────────────────────────────────────
    public AirportPassenger toEntity(AirportReservation reservation) {
        return AirportPassenger.builder()
                .reservation(reservation)                       // 예약 연관관계
                .passengerType(passengerType)                   // 탑승객 유형
                .passengerName(passengerName)                   // 탑승객 이름
                .passengerBirth(passengerBirth)                 // 생년월일
                .passengerGender(passengerGender)               // 성별
                .build();
    }
}