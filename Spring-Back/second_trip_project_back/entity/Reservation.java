package com.busanit401.second_trip_project_back.entity;

import com.busanit401.second_trip_project_back.domain.member.Member;
import com.busanit401.second_trip_project_back.enums.ReservationStatus;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "reservation")
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class Reservation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 예약한 회원
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    // TourAPI 숙소 ID
    @Column(nullable = false, length = 20)
    private String contentId;

    // TourAPI 객실 코드
    @Column(nullable = false, length = 20)
    private String roomCode;

    // 객실 이름 (TourAPI에서 받아온 값 저장)
    @Column(length = 100)
    private String roomTitle;

    // 숙소 이름 (TourAPI에서 받아온 값 저장)
    @Column(length = 200)
    private String accommodationTitle;

    // 체크인 날짜
    @Column(nullable = false)
    private LocalDate checkInDate;

    // 체크아웃 날짜
    @Column(nullable = false)
    private LocalDate checkOutDate;

    // 예약 인원
    @Column(nullable = false)
    @Builder.Default
    private int guestCount = 1;

    // 총 가격
    private Integer totalPrice;

    // 예약 상태
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private ReservationStatus status = ReservationStatus.PENDING;

    // 예약 생성 시간
    @Column(nullable = false)
    @Builder.Default
    private LocalDateTime regDate = LocalDateTime.now();

    // ─── 비즈니스 메서드 ─────────────────────────────
    // 예약 취소
    public void cancel() {
        this.status = ReservationStatus.CANCELLED;
    }

    // 예약 확정
    public void confirm() {
        this.status = ReservationStatus.CONFIRMED;
    }
}
