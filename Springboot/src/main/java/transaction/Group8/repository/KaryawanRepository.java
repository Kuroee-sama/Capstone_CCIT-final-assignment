package transaction.Group8.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import transaction.Group8.model.Karyawan;
import transaction.Group8.model.Role;

import java.util.List;
import java.util.Optional;

@Repository
public interface KaryawanRepository extends JpaRepository<Karyawan, Integer> {
    Optional<Karyawan> findByEmail(String email);

    Optional<Karyawan> findByUsername(String username);

    List<Karyawan> findByRole(Role role);
}
