package com.busanit401.second_trip_project_back.domain.member;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "trip_member") // 테이블 이름은 우리 프로젝트에 맞게!
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class Member {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 플러터 앱에서 이메일로 로그인하니까 mid를 이메일 값으로 넣으면 돼!
    @Column(unique = true, nullable = false, length = 50)
    private String mid;

    @Column(nullable = false)
    private String mpw; // 비밀번호

    @Column(nullable = false, length = 50)
    private String mname; // 이름

    @Column(unique = true, nullable = false, length = 100)
    private String email; // 이메일

    // ⭐ 우리 플러터 앱에 전화번호 입력칸이 있었지? 추가해주자!
    @Column(length = 20)
    private String phone;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    @Builder.Default
    private MemberRole role = MemberRole.USER;

    @Column(length = 255)
    private String profileImg;

    @Column(nullable = false)
    @Builder.Default
    private LocalDateTime regDate = LocalDateTime.now();

    // ──────────────────────────────────────────────
    // 비즈니스 메서드
    // ──────────────────────────────────────────────

    public void changePassword(String mpw) { this.mpw = mpw; }
    public void changeMname(String mname) { this.mname = mname; }
    public void changeEmail(String email) { this.email = email; }
    public void changeProfileImg(String profileImg) { this.profileImg = profileImg; }

    // ⭐ 전화번호 변경 메서드도 추가!
    public void changePhone(String phone) { this.phone = phone; }
}
