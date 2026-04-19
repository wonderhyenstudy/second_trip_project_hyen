package com.busanit401.second_trip_project_back.dto.loging;

import lombok.*;
import java.time.LocalDate;

// Flutter에서 예약 요청할 때 보내는 데이터
@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class ReservationRequestDTO {

    // TourAPI 숙소 ID
    private String contentId;

    // TourAPI 객실 코드
    private String roomCode;

    // 숙소 이름 (TourAPI에서 받아온 값)
    private String accommodationTitle;

    // 객실 이름 (TourAPI에서 받아온 값)
    private String roomTitle;

    // 체크인 날짜 (예: 2024-04-20)
    private LocalDate checkInDate;

    // 체크아웃 날짜 (예: 2024-04-21)
    private LocalDate checkOutDate;

    // 예약 인원
    private int guestCount;

    // 총 가격
    private Integer totalPrice;
}
