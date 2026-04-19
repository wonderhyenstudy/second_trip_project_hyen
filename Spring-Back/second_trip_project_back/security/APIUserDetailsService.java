package com.busanit401.second_trip_project_back.security;

import com.busanit401.second_trip_project_back.domain.member.Member;
import com.busanit401.second_trip_project_back.dto.APIUserDTO;
import com.busanit401.second_trip_project_back.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@Log4j2
@RequiredArgsConstructor
public class APIUserDetailsService implements UserDetailsService {

    private final MemberRepository memberRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        Member member = memberRepository.findByMid(username)
                .orElseThrow(() ->
                        new UsernameNotFoundException("Cannot find user with username: " + username)
                );

        log.info("APIUserDetailsService - Found Member: {}", member.getMid());

        String roleStr = "ROLE_" + member.getRole().name();
        APIUserDTO dto = new APIUserDTO(
                member.getMid(),
                member.getMpw(),
                List.of(new SimpleGrantedAuthority(roleStr))
        );

        log.info("APIUserDetailsService - Created APIUserDTO: {}", dto);
        return dto;
    }
}
