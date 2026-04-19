package com.busanit401.second_trip_project_back.dto.loging;

import com.busanit401.second_trip_project_back.entity.Favorite;
import lombok.*;
import java.time.LocalDateTime;

// Flutter로 찜 정보 응답할 때 보내는 데이터
@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class FavoriteResponseDTO {

    private Long id;
    private String contentId;
    private String accommodationTitle;
    private String firstImage;
    private String addr1;
    private LocalDateTime regDate;

    // Favorite 엔티티 → DTO 변환
    public static FavoriteResponseDTO from(Favorite favorite) {
        return FavoriteResponseDTO.builder()
                .id(favorite.getId())
                .contentId(favorite.getContentId())
                .accommodationTitle(favorite.getAccommodationTitle())
                .firstImage(favorite.getFirstImage())
                .addr1(favorite.getAddr1())
                .regDate(favorite.getRegDate())
                .build();
    }
}
