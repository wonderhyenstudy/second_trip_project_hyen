package com.busanit401.second_trip_project_back.service;

import com.busanit401.second_trip_project_back.domain.packages.PackageReservation;
import com.busanit401.second_trip_project_back.dto.PackageReservationDto;
import com.busanit401.second_trip_project_back.repository.PackageReservationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class PackageReservationServiceImpl implements PackageReservationService {
    private final PackageReservationRepository packageReservationRepository;

    @Override
    public Long register(PackageReservationDto packageReservationDto) {
        PackageReservation reservation = PackageReservation.builder()
                .memberId(packageReservationDto.getMemberId())
                .packageId(packageReservationDto.getPackageId())
                .reservationDate(packageReservationDto.getReservationDate())
                .peopleCount(packageReservationDto.getPeopleCount())
                .totalPrice(packageReservationDto.getTotalPrice())
                .build();

        PackageReservation savedReservation = packageReservationRepository.save(reservation);
        return savedReservation.getId();
    }
}
