package com.busanit401.second_trip_project_back.repository.car;

import com.busanit401.second_trip_project_back.domain.car.Car;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface CarRepository extends JpaRepository<Car, Long> {

    List<Car> findByCompanyId(Long companyId);

    @Query("SELECT c FROM Car c WHERE c.company.region = :region AND c.id NOT IN :unavailableIds")
    List<Car> findAvailableByRegion(@Param("region") String region,
                                    @Param("unavailableIds") List<Long> unavailableIds);

    @Query("SELECT c FROM Car c WHERE c.company.region = :region")
    List<Car> findAllByRegion(@Param("region") String region);

    @Query("SELECT c FROM Car c WHERE " +
            "(:type IS NULL OR c.type = :type) AND " +
            "(:fuel IS NULL OR c.fuel = :fuel) AND " +
            "(:seats IS NULL OR c.seats = :seats)")
    List<Car> findByFilter(@Param("type") String type,
                           @Param("fuel") String fuel,
                           @Param("seats") Integer seats);
}