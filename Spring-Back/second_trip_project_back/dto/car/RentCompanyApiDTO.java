package com.busanit401.second_trip_project_back.dto.car;

import lombok.Data;

// 공공데이터 API 응답 매핑용 DTO
@Data
public class RentCompanyApiDTO {

    private String entrpsNm;   // 업체명
    private String rdnmadr;    // 도로명주소
    private String lnmadr;     // 지번주소
    private String latitude;   // 위도
    private String longitude;  // 경도
    private String phoneNumber; // 전화번호
    private String ctprvnNm;   // 시도명 (지역)
}