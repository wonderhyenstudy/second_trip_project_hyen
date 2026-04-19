package com.busanit401.second_trip_project_back.service;

import com.busanit401.second_trip_project_back.domain.member.Member;
import com.busanit401.second_trip_project_back.dto.loging.FavoriteRequestDTO;
import com.busanit401.second_trip_project_back.dto.loging.FavoriteResponseDTO;
import com.busanit401.second_trip_project_back.entity.Favorite;
import com.busanit401.second_trip_project_back.repository.FavoriteRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class FavoriteService {

    private final FavoriteRepository favoriteRepository;

    // ─── 찜 추가 ──────────────────────────────────────
    public FavoriteResponseDTO addFavorite(
            Member member,
            FavoriteRequestDTO requestDTO) {

        // 이미 찜했는지 확인
        if (favoriteRepository.existsByMemberAndContentId(
                member, requestDTO.getContentId())) {
            throw new IllegalStateException("이미 찜한 숙소입니다.");
        }

        Favorite favorite = Favorite.builder()
                .member(member)
                .contentId(requestDTO.getContentId())
                .accommodationTitle(requestDTO.getAccommodationTitle())
                .firstImage(requestDTO.getFirstImage())
                .addr1(requestDTO.getAddr1())
                .build();

        Favorite saved = favoriteRepository.save(favorite);
        log.info("찜 추가 완료: {}", saved.getId());

        return FavoriteResponseDTO.from(saved);
    }

    // ─── 찜 삭제 ──────────────────────────────────────
    public void removeFavorite(Member member, String contentId) {
        // 찜했는지 확인
        if (!favoriteRepository.existsByMemberAndContentId(
                member, contentId)) {
            throw new IllegalArgumentException("찜한 숙소를 찾을 수 없습니다.");
        }

        favoriteRepository.deleteByMemberAndContentId(member, contentId);
        log.info("찜 삭제 완료: contentId={}", contentId);
    }

    // ─── 내 찜 목록 조회 ──────────────────────────────
    @Transactional(readOnly = true)
    public List<FavoriteResponseDTO> getMyFavorites(Member member) {
        return favoriteRepository
                .findByMemberOrderByRegDateDesc(member)
                .stream()
                .map(FavoriteResponseDTO::from)
                .collect(Collectors.toList());
    }

    // ─── 찜 여부 확인 ─────────────────────────────────
    @Transactional(readOnly = true)
    public boolean isFavorite(Member member, String contentId) {
        return favoriteRepository.existsByMemberAndContentId(
                member, contentId);
    }
}