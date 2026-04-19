package com.busanit401.second_trip_project_back.dto.loging;

import com.busanit401.second_trip_project_back.entity.Reservation;
import com.busanit401.second_trip_project_back.enums.ReservationStatus;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

// Flutter로 예약 정보 응답할 때 보내는 데이터
@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class ReservationResponseDTO {

    private Long id;
    private String contentId;
    private String roomCode;
    private String accommodationTitle;
    private String roomTitle;
    private LocalDate checkInDate;
    private LocalDate checkOutDate;
    private int guestCount;
    private Integer totalPrice;
    private ReservationStatus status;
    private LocalDateTime regDate;

    // Reservation 엔티티 → DTO 변환
    public static ReservationResponseDTO from(Reservation reservation) {
        return ReservationResponseDTO.builder()
                .id(reservation.getId())
                .contentId(reservation.getContentId())
                .roomCode(reservation.getRoomCode())
                .accommodationTitle(reservation.getAccommodationTitle())
                .roomTitle(reservation.getRoomTitle())
                .checkInDate(reservation.getCheckInDate())
                .checkOutDate(reservation.getCheckOutDate())
                .guestCount(reservation.getGuestCount())
                .totalPrice(reservation.getTotalPrice())
                .status(reservation.getStatus())
                .regDate(reservation.getRegDate())
                .build();
    }
}