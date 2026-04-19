package com.busanit401.second_trip_project_back.dto.car;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class CarSearchResultDTO {

    private String carName;     // 모닝
    private String type;        // 경형
    private int seats;          // 4
    private String fuel;        // 가솔린
    private int lowestPrice;    // 가장 저렴한 옵션 가격 (정렬용)

    private List<CompanyOptionDTO> options; // 이 차를 보유한 회사 목록

    @Data
    @Builder
    public static class CompanyOptionDTO {
        private Long carId;
        private Long companyId;
        private String companyName;
        private String roadAddress;
        private int dailyPrice;
        private int totalPrice;  // dailyPrice * 대여일수
    }
}