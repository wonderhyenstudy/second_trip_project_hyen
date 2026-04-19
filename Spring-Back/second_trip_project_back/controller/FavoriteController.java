package com.busanit401.second_trip_project_back.controller;

import com.busanit401.second_trip_project_back.domain.member.Member;
import com.busanit401.second_trip_project_back.dto.loging.FavoriteRequestDTO;
import com.busanit401.second_trip_project_back.dto.loging.FavoriteResponseDTO;
import com.busanit401.second_trip_project_back.repository.MemberRepository;
import com.busanit401.second_trip_project_back.service.FavoriteService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/favorites")
@RequiredArgsConstructor
@Slf4j
public class FavoriteController {

    private final FavoriteService favoriteService;
    private final MemberRepository memberRepository;

    // ─── 찜 추가 ──────────────────────────────────────
    // POST /api/favorites
    @PostMapping
    public ResponseEntity<FavoriteResponseDTO> addFavorite(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody FavoriteRequestDTO requestDTO) {

        Member member = getMember(userDetails);
        FavoriteResponseDTO response =
                favoriteService.addFavorite(member, requestDTO);
        return ResponseEntity.ok(response);
    }

    // ─── 찜 삭제 ──────────────────────────────────────
    // DELETE /api/favorites/{contentId}
    @DeleteMapping("/{contentId}")
    public ResponseEntity<Void> removeFavorite(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable String contentId) {

        Member member = getMember(userDetails);
        favoriteService.removeFavorite(member, contentId);
        return ResponseEntity.ok().build();
    }

    // ─── 내 찜 목록 조회 ──────────────────────────────
    // GET /api/favorites
    @GetMapping
    public ResponseEntity<List<FavoriteResponseDTO>> getMyFavorites(
            @AuthenticationPrincipal UserDetails userDetails) {

        Member member = getMember(userDetails);
        List<FavoriteResponseDTO> response =
                favoriteService.getMyFavorites(member);
        return ResponseEntity.ok(response);
    }

    // ─── 찜 여부 확인 ─────────────────────────────────
    // GET /api/favorites/check/{contentId}
    @GetMapping("/check/{contentId}")
    public ResponseEntity<Boolean> checkFavorite(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable String contentId) {

        Member member = getMember(userDetails);
        boolean isFavorite =
                favoriteService.isFavorite(member, contentId);
        return ResponseEntity.ok(isFavorite);
    }

    // ─── 회원 조회 헬퍼 ──────────────────────────────
    private Member getMember(UserDetails userDetails) {
        return memberRepository.findByMid(userDetails.getUsername())
                .orElseThrow(() ->
                        new IllegalArgumentException("회원을 찾을 수 없습니다."));
    }
}
