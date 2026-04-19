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

        // 비밀번호 암호화해서 저장해야 해!
        Member member = Member.builder()
                .mid(memberDTO.getMid())
                .mpw(passwordEncoder.encode(memberDTO.getMpw())) // 암호화 슥삭
                .mname(memberDTO.getMname())
                .email(memberDTO.getEmail())
                .phone(memberDTO.getPhone())
                .role(MemberRole.USER) // 기본 권한은 USER로!
                .build();

        memberRepository.save(member);
    }

    @Override
    public MemberDTO read(String mid) {
        Optional<Member> result = memberRepository.findByMid(mid);
        Member member = result.orElseThrow();
        return entityToDTO(member);
    }

    @Override
    public void modify(MemberDTO memberDTO) {
        // 수정 로직 필요시 구현
    }

    @Override
    public void remove(String mid) {
        // mid가 String이니까 deleteById 대신 직접 찾아서 지우거나,
        // 리포지토리에 만든 mid용 삭제 메소드를 써야 해!
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

        // 토큰 발행 (팀원분 코드 방식에 맞춰서 조절해!)
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

        // 리포지토리에 새로 만든 통합 쿼리를 호출!
        return memberRepository.existsByMid(mid.trim());
    }

    @Override
    public Optional<Member> findByEmail(String email) {
        return memberRepository.findByMid(email); // mid가 이메일이니까!
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