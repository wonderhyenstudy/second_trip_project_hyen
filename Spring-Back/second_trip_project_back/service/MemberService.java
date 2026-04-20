package com.busanit401.second_trip_project_back.service;

import com.busanit401.second_trip_project_back.domain.member.Member;
import com.busanit401.second_trip_project_back.dto.MemberDTO;

import java.util.Optional;

public interface MemberService {

    // 1. 회원가입
    void register(MemberDTO memberDTO);

    // 2. 회원 정보 조회 (상세 보기)
    MemberDTO read(String mid);

    // 3. 회원 정보 수정 (이름, 전화번호, 프로필 사진 등)
    // 플러터 EditProfileScreen에서 보낸 데이터를 여기서 처리해!
    void modify(MemberDTO memberDTO);

    // 4. 회원 탈퇴 (삭제)
    void remove(String mid);

    // 5. 로그인 처리
    MemberDTO login(String mid, String mpw);

    // 6. 아이디(mid)로 엔티티 조회
    Optional<Member> findByMid(String mid);

    // 7. 아이디(이메일) 중복 확인
    boolean existsByMid(String mid);

    // 8. 실제 이메일 필드로 회원 조회
    Optional<Member> findByEmail(String email);
}