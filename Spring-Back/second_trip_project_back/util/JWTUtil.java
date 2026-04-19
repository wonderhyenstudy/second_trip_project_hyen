package com.busanit401.second_trip_project_back.util;

import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import lombok.extern.log4j.Log4j2;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.time.ZonedDateTime;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Log4j2
@Component
public class JWTUtil {

    @Value("busainit501234567890busainit501234567890busainit501234567890") // 비밀키를 외부 설정에서 가져옴
    private String key;


    public String generateToken(Map<String, Object> valueMap, int days) {
        log.info("Generating token with secret key: {}", key);
        // 헤더 설정
        Map<String, Object> headers = new HashMap<>();
        headers.put("typ", "JWT");
        headers.put("alg", "HS256");

        // 페이로드 설정
        Map<String, Object> payloads = new HashMap<>();
        payloads.putAll(valueMap);

        // 테스트 환경에서는 분 단위, 운영 환경에서는 일 단위로 설정
        int time = days * 60 * 24 ; // 테스트 시 분 단위 (나중에 60 * 24로 변경 가능)
//        int time = days  ; // 테스트 시 분 단위 (나중에 60 * 24로 변경 가능)

        // JWT 생성
        String jwtStr = Jwts.builder()
                .setHeader(headers) // 헤더 추가
                .setClaims(payloads) // 페이로드 추가
                .setIssuedAt(Date.from(ZonedDateTime.now().toInstant())) // 발급 시간
                .setExpiration(Date.from(ZonedDateTime.now().plusMinutes(time).toInstant())) // 만료 시간
                .signWith(SignatureAlgorithm.HS256, key.getBytes()) // 서명 알고리즘 및 비밀키 설정
                .compact();


        log.info("Generated JWT: {}", jwtStr);
        return jwtStr;
    }


    public Map<String, Object> validateToken(String token) throws JwtException {
        log.info("Validating token: {}", token);

       Map<String, Object> claims = null;
        // Claims 파싱 및 검증
        claims = Jwts.parser()
                .setSigningKey(key.getBytes()) // 비밀키 설정
                .parseClaimsJws(token) // 토큰 파싱 및 검증
                .getBody();

        // Claims 데이터를 Map으로 변환
        Map<String, Object> claimMap = new HashMap<>(claims);

        log.info("Token is valid. Extracted Claims: {}", claimMap);
        return claimMap;
    }
}