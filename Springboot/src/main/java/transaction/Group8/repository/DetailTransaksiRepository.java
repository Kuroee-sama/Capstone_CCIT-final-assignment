package transaction.Group8.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import transaction.Group8.model.DetailTransaksi;

import java.util.List;

@Repository
public interface DetailTransaksiRepository extends JpaRepository<DetailTransaksi, Integer> {
    List<DetailTransaksi> findByTransaksiId(Integer transaksiId);
}
