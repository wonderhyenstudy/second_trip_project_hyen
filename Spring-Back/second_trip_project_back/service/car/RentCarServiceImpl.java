package com.busanit401.second_trip_project_back.service.car;

import com.busanit401.second_trip_project_back.dto.car.CarDTO;
import com.busanit401.second_trip_project_back.dto.car.RentCompanyDTO;
import com.busanit401.second_trip_project_back.repository.car.CarRepository;
import com.busanit401.second_trip_project_back.repository.car.RentCompanyRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@Log4j2
@RequiredArgsConstructor
public class RentCarServiceImpl implements RentCarService {

    private final RentCompanyRepository rentCompanyRepository;
    private final CarRepository carRepository;

    @Override
    public List<RentCompanyDTO> getCompanies(String region) {
        if (region != null && !region.isBlank()) {
            return rentCompanyRepository.findByRegion(region).stream()
                    .map(RentCompanyDTO::from).toList();
        }
        return rentCompanyRepository.findAll().stream()
                .map(RentCompanyDTO::from).toList();
    }

    @Override
    public RentCompanyDTO getCompany(Long companyId) {
        return rentCompanyRepository.findById(companyId)
                .map(RentCompanyDTO::from)
                .orElseThrow(() -> new RuntimeException("회사를 찾을 수 없습니다. id=" + companyId));
    }

    @Override
    public List<CarDTO> getCarsByCompany(Long companyId) {
        return carRepository.findByCompanyId(companyId).stream()
                .map(CarDTO::from).toList();
    }

    @Override
    public List<CarDTO> getCars(String type, String fuel, Integer seats) {
        return carRepository.findByFilter(type, fuel, seats).stream()
                .map(CarDTO::from).toList();
    }

    @Override
    public CarDTO getCar(Long carId) {
        return carRepository.findById(carId)
                .map(CarDTO::from)
                .orElseThrow(() -> new RuntimeException("차량을 찾을 수 없습니다. id=" + carId));
    }
}