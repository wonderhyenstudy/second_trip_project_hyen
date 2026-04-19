package com.busanit401.second_trip_project_back.security.filter;

import com.busanit401.second_trip_project_back.security.APIUserDetailsService;
import com.busanit401.second_trip_project_back.security.exception.AccessTokenException;
import com.busanit401.second_trip_project_back.util.JWTUtil;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.SignatureException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Map;

@Log4j2
@RequiredArgsConstructor
public class TokenCheckFilter extends OncePerRequestFilter {

    private final APIUserDetailsService apiUserDetailsService;
    private final JWTUtil jwtUtil;


    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        // 로그 출력
        log.info("Token Check Filter triggered...");
        log.info("JWTUtil instance: {}", jwtUtil);


        try {
//            // JWT 유효성 검증
//            validateAccessToken(request);
//
//            // 검증 성공 시 다음 필터로 전달
//            filterChain.doFilter(request, response);
            Map<String, Object> payload = validateAccessToken(request);
            // mid 추출
            String mid = (String) payload.get("mid");
            log.info("mid: " + mid);

            UserDetails userDetails = apiUserDetailsService.loadUserByUsername(mid);
            UsernamePasswordAuthenticationToken authentication =
                    new UsernamePasswordAuthenticationToken(
                            userDetails,
                            null,
                            userDetails.getAuthorities()
                    );

            SecurityContextHolder.getContext().setAuthentication(authentication);
            // 인증 후 다음 필터로 요청 전달
            filterChain.doFilter(request, response);
        } catch (AccessTokenException accessTokenException) {
            // 검증 실패 시 에러 응답 반환
            accessTokenException.sendResponseError(response);
        }
    }


    public Map<String, Object> validateAccessToken(HttpServletRequest request) throws AccessTokenException {
        String headerStr = request.getHeader("Authorization");

        // 1. Authorization 헤더가 없는 경우
        if (headerStr == null || headerStr.length() < 8) {
            throw new AccessTokenException(AccessTokenException.TOKEN_ERROR.UNACCEPT);
        }

        // 2. 토큰 타입 확인
        String tokenType = headerStr.substring(0, 6);
        String tokenStr = headerStr.substring(7);

        if (!tokenType.equalsIgnoreCase("Bearer")) {
            throw new AccessTokenException(AccessTokenException.TOKEN_ERROR.BADTYPE);
        }

        try {
            // 3. JWT 검증
            Map<String, Object> values = jwtUtil.validateToken(tokenStr);
            return values;

        } catch (MalformedJwtException malformedJwtException) {
            log.error("MalformedJwtException: Invalid token format.");
            throw new AccessTokenException(AccessTokenException.TOKEN_ERROR.MALFORM);

        } catch (SignatureException signatureException) {
            log.error("SignatureException: Invalid token signature.");
            throw new AccessTokenException(AccessTokenException.TOKEN_ERROR.BADSIGN);

        } catch (ExpiredJwtException expiredJwtException) {
            log.error("ExpiredJwtException: Token has expired.");
            throw new AccessTokenException(AccessTokenException.TOKEN_ERROR.EXPIRED);
        }
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) throws ServletException {
        String path = request.getRequestURI();

        // 아래 경로들로 들어오는 요청은 필터 로직(토큰 검사)을 건너뜁니다.
        if (!path.startsWith("/api/") ||
                path.startsWith("/api/member/exists/") ||
                path.startsWith("/api/member/check-mid") ||
                path.startsWith("/api/member/register") ||
                path.startsWith("/api/member/login") ||
                path.startsWith("/api/member/check-email") ||
                path.startsWith("/api/member/signup") ||
                path.startsWith("/api/airport/flights") ||
                path.startsWith("/rent/") ||
                path.startsWith("/api/rental/search") ||
                path.startsWith("/api/rental/unavailable")) {
            return true;
        }

        return false;
    }
}

