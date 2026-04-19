package com.busanit401.second_trip_project_back.repository;

import com.busanit401.second_trip_project_back.domain.member.Member;
import com.busanit401.second_trip_project_back.entity.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface FavoriteRepository extends JpaRepository<Favorite, Long> {

    // 특정 회원의 찜 목록 전체 조회
    List<Favorite> findByMemberOrderByRegDateDesc(Member member);

    // 특정 회원이 특정 숙소를 찜했는지 확인
    Optional<Favorite> findByMemberAndContentId(Member member, String contentId);

    // 특정 회원이 특정 숙소를 찜했는지 여부
    boolean existsByMemberAndContentId(Member member, String contentId);

    // 특정 회원의 특정 숙소 찜 삭제
    void deleteByMemberAndContentId(Member member, String contentId);
}
