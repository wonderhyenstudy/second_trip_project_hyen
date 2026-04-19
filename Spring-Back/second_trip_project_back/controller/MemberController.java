package com.busanit401.second_trip_project_back.controller;

import com.busanit401.second_trip_project_back.dto.MemberDTO;
import com.busanit401.second_trip_project_back.service.MemberService;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@Log4j2
@RequiredArgsConstructor
@RequestMapping("/api/member")
public class MemberController {

    private final MemberService memberService;

    // 1. 회원가입
    @PostMapping("/register")
    public String register(@RequestBody MemberDTO memberDTO) {
        log.info("회원가입 요청 들어옴! 데이터: " + memberDTO);
        memberService.register(memberDTO);
        return "success";
    }

    // ⭐ 2. 중복 확인 창구 추가! (플러터가 여기로 물어볼 거야)
    // ⭐ 2. 중복 확인 창구 (경로 부분만 살짝 수정!)
    @GetMapping("/exists/{email:.+}") // 👈 뒤에 :.+ 를 꼭 붙여줘!
    public ResponseEntity<Boolean> checkDuplicate(@PathVariable("email") String email) {
        log.info("중복 확인 요청 들어옴! 이메일: " + email);
        boolean exists = memberService.existsByMid(email);
        return ResponseEntity.ok(exists);
    }

    // 3. 회원정보 조회
    @GetMapping("/{mid}")
    public MemberDTO read(@PathVariable("mid") String mid) {
        log.info("회원조회 요청 들어옴! 아이디: " + mid);
        return memberService.read(mid);
    }

    // 4. 로그인
    @PostMapping("/login")
    public MemberDTO login(@RequestBody MemberDTO memberDTO) {
        log.info("로그인 시도 아이디: " + memberDTO.getMid());
        return memberService.login(memberDTO.getMid(), memberDTO.getMpw());
    }
}