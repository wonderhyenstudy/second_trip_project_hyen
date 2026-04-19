package com.busanit401.second_trip_project_back.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class MemberDTO {
    private String mid;
    private String mpw;
    private String mname;
    private String email;
    private String phone;
    private String role;
    private LocalDateTime regDate;

    // ⭐ 토큰 담는 칸
    private String accessToken;
    private String refreshToken;
}