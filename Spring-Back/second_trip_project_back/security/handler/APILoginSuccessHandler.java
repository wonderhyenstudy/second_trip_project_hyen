package com.busanit401.second_trip_project_back.security.handler;

import com.busanit401.second_trip_project_back.util.JWTUtil;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.http.MediaType;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;

import java.io.IOException;
import java.util.Map;

@Log4j2
@RequiredArgsConstructor
public class APILoginSuccessHandler implements AuthenticationSuccessHandler {
    private final JWTUtil jwtUtil;

    @Override
    public void onAuthenticationSuccess(
            HttpServletRequest request,
            HttpServletResponse response,
            Authentication authentication
    ) throws IOException, ServletException {
        // 로그인 성공 시 동작 로직
        log.info("Login Success Handler triggered");

        // 응답 Content-Type 설정
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);

        // 인증 정보 로그 출력
        log.info("Authentication: {}", authentication);
        log.info("Authenticated Username: {}", authentication.getName());

        // 클레임 설정 (사용자 이름 포함)
        Map<String, Object> claims = Map.of("mid", authentication.getName());

        // Access Token 유효기간: 1일
        String accessToken = jwtUtil.generateToken(claims, 1);

        // Refresh Token 유효기간: 30일
        String refreshToken = jwtUtil.generateToken(claims, 30);

        // JSON 형식 응답 생성
        Gson gson = new Gson();
        Map<String, String> keyMap = Map.of(
                "accessToken", accessToken,
                "refreshToken", refreshToken
        );
        String jsonStr = gson.toJson(keyMap);

        // 응답으로 JSON 전송
        response.getWriter().println(jsonStr);
    }
}