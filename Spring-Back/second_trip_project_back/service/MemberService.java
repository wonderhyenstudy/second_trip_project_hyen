package com.busanit401.second_trip_project_back.service;

import com.busanit401.second_trip_project_back.domain.member.Member;
import com.busanit401.second_trip_project_back.dto.MemberDTO;

import java.util.Optional;

public interface MemberService {
    // 회원가입
    void register(MemberDTO memberDTO);

    // 회원 정보 조회
    MemberDTO read(String mid);

    // 회원 수정
    void modify(MemberDTO memberDTO);

    // 회원 삭제
    void remove(String mid);

    MemberDTO login(String mid, String mpw);

    Optional<Member> findByMid(String mid);

    // 이메일 중복 확인
    boolean existsByMid(String mid);

    // 이메일로 회원 조회
    Optional<Member> findByEmail(String email);
}