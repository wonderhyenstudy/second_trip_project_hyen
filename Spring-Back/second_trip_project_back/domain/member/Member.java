package com.busanit401.second_trip_project_back.domain.member;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "trip_member")
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class Member {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 아이디 (플러터에서 로그인 시 사용하는 이메일)
    @Column(unique = true, nullable = false, length = 50)
    private String mid;

    @Column(nullable = false)
    private String mpw; // 비밀번호

    @Column(nullable = false, length = 50)
    private String mname; // 이름

    @Column(unique = true, nullable = false, length = 100)
    private String email; // 이메일

    @Column(length = 20)
    private String phone;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    @Builder.Default
    private MemberRole role = MemberRole.USER;

    @Column(length = 255)
    private String profileImg;

    @Column(nullable = false, updatable = false) // 등록일은 수정되지 않도록 설정
    @Builder.Default
    private LocalDateTime regDate = LocalDateTime.now();

    // ──────────────────────────────────────────────
    // 비즈니스 메서드 (Setter 대신 사용!)
    // ──────────────────────────────────────────────

    // 비밀번호 변경
    public void changePassword(String mpw) {
        this.mpw = mpw;
    }

    // 이름 변경
    public void changeMname(String mname) {
        this.mname = mname;
    }

    // 이메일 변경
    public void changeEmail(String email) {
        this.email = email;
    }

    // 프로필 이미지 변경
    public void changeProfileImg(String profileImg) {
        this.profileImg = profileImg;
    }

    // 전화번호 변경
    public void changePhone(String phone) {
        this.phone = phone;
    }
}