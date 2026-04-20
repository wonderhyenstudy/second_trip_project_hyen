package com.busanit401.second_trip_project_back.service;

import com.busanit401.second_trip_project_back.domain.member.Member;
import com.busanit401.second_trip_project_back.domain.member.MemberRole;
import com.busanit401.second_trip_project_back.dto.MemberDTO;
import com.busanit401.second_trip_project_back.repository.MemberRepository;
import com.busanit401.second_trip_project_back.util.JWTUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.Optional;

@Service
@Log4j2
@RequiredArgsConstructor
@Transactional
public class MemberServiceImpl implements MemberService {

    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;
    private final JWTUtil jwtUtil;

    @Override
    public void register(MemberDTO memberDTO) {
        log.info("회원가입 로직 실행: " + memberDTO);

        Member member = Member.builder()
                .mid(memberDTO.getMid())
                .mpw(passwordEncoder.encode(memberDTO.getMpw()))
                .mname(memberDTO.getMname())
                .email(memberDTO.getEmail())
                .phone(memberDTO.getPhone())
                .role(MemberRole.USER)
                .build();

        memberRepository.save(member);
    }

    @Override
    public MemberDTO read(String mid) {
        Optional<Member> result = memberRepository.findByMid(mid);
        Member member = result.orElseThrow();
        return entityToDTO(member);
    }

    // ⭐ 회원 정보 수정 로직 구현 완료!
    @Override
    public void modify(MemberDTO memberDTO) {
        log.info("회원 정보 수정 로직 실행: " + memberDTO);

        // 1. DB에서 기존 회원 데이터를 찾아옴
        Optional<Member> result = memberRepository.findByMid(memberDTO.getMid());
        Member member = result.orElseThrow(() -> new RuntimeException("해당 회원을 찾을 수 없습니다."));

        // 2. 엔티티의 비즈니스 메서드를 호출해서 값 변경
        // 플러터에서 보내온 이름과 전화번호로 업데이트!
        member.changeMname(memberDTO.getMname());
        member.changePhone(memberDTO.getPhone());

        // 3. @Transactional 덕분에 따로 save를 안 해도 메서드가 끝날 때 DB에 반영돼!
        // 하지만 명시적으로 확인하고 싶다면 아래를 써도 무방해.
        memberRepository.save(member);
    }

    @Override
    public void remove(String mid) {
        Optional<Member> member = memberRepository.findByMid(mid);
        member.ifPresent(memberRepository::delete);
    }

    @Override
    public MemberDTO login(String mid, String mpw) {
        Member member = memberRepository.findByMid(mid)
                .orElseThrow(() -> new RuntimeException("아이디가 존재하지 않습니다."));

        if (!passwordEncoder.matches(mpw, member.getMpw())) {
            throw new RuntimeException("비밀번호가 일치하지 않습니다.");
        }

        MemberDTO memberDTO = entityToDTO(member);

        String token = jwtUtil.generateToken(Map.of("mid", mid), 1);
        memberDTO.setAccessToken(token);

        return memberDTO;
    }

    @Override
    public Optional<Member> findByMid(String mid) {
        return memberRepository.findByMid(mid);
    }

    @Override
    public boolean existsByMid(String mid) {
        if (mid == null || mid.isBlank()) return false;
        log.info("DB에서 중복 체크 중 (공백제거): " + mid.trim());
        return memberRepository.existsByMid(mid.trim());
    }

    @Override
    public Optional<Member> findByEmail(String email) {
        return memberRepository.findByMid(email);
    }

    private MemberDTO entityToDTO(Member member) {
        return MemberDTO.builder()
                .mid(member.getMid())
                .mname(member.getMname())
                .email(member.getEmail())
                .phone(member.getPhone())
                .role(member.getRole().name())
                .regDate(member.getRegDate())
                .build();
    }
}