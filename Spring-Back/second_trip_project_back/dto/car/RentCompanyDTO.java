package com.busanit401.second_trip_project_back.dto.car;

import com.busanit401.second_trip_project_back.domain.car.RentCompany;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class RentCompanyDTO {
    private Long id;
    private String name;
    private String region;
    private String roadAddress;
    private String address;
    private String latitude;
    private String longitude;
    private String phone;

    public static RentCompanyDTO from(RentCompany company) {
        return RentCompanyDTO.builder()
                .id(company.getId())
                .name(company.getName())
                .region(company.getRegion())
                .roadAddress(company.getRoadAddress())
                .address(company.getAddress())
                .latitude(company.getLatitude())
                .longitude(company.getLongitude())
                .phone(company.getPhone())
                .build();
    }
}