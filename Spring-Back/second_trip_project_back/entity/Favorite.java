package com.busanit401.second_trip_project_back.entity;

import com.busanit401.second_trip_project_back.domain.member.Member;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(
        name = "favorite",
        // 같은 회원이 같은 숙소를 중복 찜하지 못하게
        uniqueConstraints = @UniqueConstraint(
                columnNames = {"member_id", "contentId"}
        )
)
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class Favorite {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 찜한 회원
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    // TourAPI 숙소 ID
    @Column(nullable = false, length = 20)
    private String contentId;

    // 숙소 이름 (TourAPI에서 받아온 값 저장)
    @Column(length = 200)
    private String accommodationTitle;

    // 숙소 이미지 URL (TourAPI에서 받아온 값 저장)
    @Column(length = 500)
    private String firstImage;

    // 숙소 주소 (TourAPI에서 받아온 값 저장)
    @Column(length = 300)
    private String addr1;

    // 찜한 시간
    @Column(nullable = false)
    @Builder.Default
    private LocalDateTime regDate = LocalDateTime.now();
}
