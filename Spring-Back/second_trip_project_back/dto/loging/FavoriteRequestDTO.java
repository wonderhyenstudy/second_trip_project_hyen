package com.busanit401.second_trip_project_back.dto.loging;

import lombok.*;

// Flutter에서 찜 요청할 때 보내는 데이터
@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class FavoriteRequestDTO {

    // TourAPI 숙소 ID
    private String contentId;

    // 숙소 이름 (TourAPI에서 받아온 값)
    private String accommodationTitle;

    // 숙소 이미지 URL (TourAPI에서 받아온 값)
    private String firstImage;

    // 숙소 주소 (TourAPI에서 받아온 값)
    private String addr1;
}