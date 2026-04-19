package com.busanit401.second_trip_project_back.repository;

import com.busanit401.second_trip_project_back.domain.member.Member;
import com.busanit401.second_trip_project_back.domain.member.MemberRole;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MemberRepository extends JpaRepository<Member, Long> {

    // 1. 아이디(이메일값)로 회원 조회 (로그인용)
    Optional<Member> findByMid(String mid);

    // 2. 아이디 중복 확인
    // 기존 2번(existsByMid) 코드를 이걸로 덮어씌워!
    @Query("SELECT COUNT(m) > 0 FROM Member m WHERE m.mid = :mid OR m.email = :mid")
    boolean existsByMid(@Param("mid") String mid);

    // 3. 이메일 중복 확인
    boolean existsByEmail(String email);

    // 4. 이메일로 회원 조회 (비밀번호 찾기용)
    Optional<Member> findByEmail(String email);

    // 5. 역할(USER, ADMIN)별 회원 목록 조회 (관리자 기능)
    List<Member> findByRole(MemberRole role);

    // 6. 이름으로 회원 검색 (부분 일치)
    List<Member> findByMnameContaining(String mname);

    // 7. 역할별 회원 수 집계 (관리자 대시보드용)
    long countByRole(MemberRole role);

    // 8. 아이디와 이메일로 회원 조회 (비밀번호 찾기 본인 인증용)
    Optional<Member> findByMidAndEmail(String mid, String email);

    // 9. 통합 검색 (아이디, 이름, 이메일 중 하나라도 포함되면 검색)
    @Query("SELECT m FROM Member m WHERE " +
            "m.mid LIKE %:keyword% OR " +
            "m.mname LIKE %:keyword% OR " +
            "m.email LIKE %:keyword%")
    List<Member> searchByKeyword(@Param("keyword") String keyword);
}
