package com.busanit401.second_trip_project_back.service.car;

import com.busanit401.second_trip_project_back.domain.car.Car;
import com.busanit401.second_trip_project_back.domain.car.Rental;
import com.busanit401.second_trip_project_back.domain.member.Member;
import com.busanit401.second_trip_project_back.dto.car.CarSearchResultDTO;
import com.busanit401.second_trip_project_back.dto.car.RentalDTO;
import com.busanit401.second_trip_project_back.dto.car.RentalRequestDTO;
import com.busanit401.second_trip_project_back.repository.MemberRepository;
import com.busanit401.second_trip_project_back.repository.car.CarRepository;
import com.busanit401.second_trip_project_back.repository.car.RentalRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@Log4j2
@RequiredArgsConstructor
public class RentalServiceImpl implements RentalService {

    private final RentalRepository rentalRepository;
    private final CarRepository carRepository;
    private final MemberRepository userRepository;

    @Override
    @Transactional
    public RentalDTO createRental(String mid, RentalRequestDTO request) {
        if (!request.getEndDate().isAfter(request.getStartDate())) {
            throw new RuntimeException("반납일은 대여일 이후여야 합니다.");
        }

        Car car = carRepository.findById(request.getCarId())
                .orElseThrow(() -> new RuntimeException("차량을 찾을 수 없습니다."));

        if (rentalRepository.existsOverlap(car.getId(), request.getStartDate(), request.getEndDate())) {
            throw new RuntimeException("해당 기간에 이미 예약된 차량입니다.");
        }

        Member user = userRepository.findByMid(mid)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));

        Rental rental = Rental.builder()
                .car(car)
                .user(user)
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .status(Rental.RentalStatus.CONFIRMED)
                .build();

        return RentalDTO.from(rentalRepository.save(rental));
    }

    @Override
    public List<RentalDTO> getMyRentals(String mid) {
        return rentalRepository.findByUserMid(mid).stream()
                .map(RentalDTO::from).toList();
    }

    @Override
    @Transactional
    public RentalDTO cancelRental(String mid, Long rentalId) {
        Rental rental = rentalRepository.findById(rentalId)
                .orElseThrow(() -> new RuntimeException("예약을 찾을 수 없습니다."));

        if (!rental.getUser().getMid().equals(mid)) {
            throw new RuntimeException("본인 예약만 취소할 수 있습니다.");
        }

        if (rental.getStatus() == Rental.RentalStatus.CANCELLED) {
            throw new RuntimeException("이미 취소된 예약입니다.");
        }

        rental.cancel();
        return RentalDTO.from(rental);
    }

    @Override
    public List<Long> getUnavailableCarIds(LocalDate startDate, LocalDate endDate) {
        return rentalRepository.findUnavailableCarIds(startDate, endDate);
    }

    @Override
    public List<CarSearchResultDTO> searchCars(String region, LocalDate startDate, LocalDate endDate) {
        int days = (int) (endDate.toEpochDay() - startDate.toEpochDay());

        // 해당 기간 예약 불가 차량 id
        List<Long> unavailableIds = rentalRepository.findUnavailableCarIds(startDate, endDate);

        // 지역 내 예약 가능한 차량 조회
        List<Car> cars = unavailableIds.isEmpty()
                ? carRepository.findAllByRegion(region)
                : carRepository.findAvailableByRegion(region, unavailableIds);

        // 차량명으로 그룹핑
        Map<String, List<Car>> grouped = cars.stream()
                .collect(Collectors.groupingBy(Car::getName));

        return grouped.entrySet().stream()
                .map(entry -> {
                    List<Car> group = entry.getValue();
                    Car sample = group.get(0);

                    List<CarSearchResultDTO.CompanyOptionDTO> options = group.stream()
                            .map(car -> CarSearchResultDTO.CompanyOptionDTO.builder()
                                    .carId(car.getId())
                                    .companyId(car.getCompany().getId())
                                    .companyName(car.getCompany().getName())
                                    .roadAddress(car.getCompany().getRoadAddress())
                                    .dailyPrice(car.getDailyPrice())
                                    .totalPrice(car.getDailyPrice() * days)
                                    .build())
                            .sorted((a, b) -> a.getDailyPrice() - b.getDailyPrice()) // 가격 오름차순
                            .toList();

                    return CarSearchResultDTO.builder()
                            .carName(sample.getName())
                            .type(sample.getType())
                            .seats(sample.getSeats())
                            .fuel(sample.getFuel())
                            .lowestPrice(options.get(0).getDailyPrice())
                            .options(options)
                            .build();
                })
                .sorted((a, b) -> a.getLowestPrice() - b.getLowestPrice()) // 최저가 오름차순
                .toList();
    }
}