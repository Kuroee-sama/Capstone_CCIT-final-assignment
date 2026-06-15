package transaction.Group8.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import transaction.Group8.model.Transaksi;

import java.math.BigDecimal;

@Repository
public interface TransaksiRepository extends JpaRepository<Transaksi, Integer> {
    Page<Transaksi> findByKaryawanId(Integer karyawanId, Pageable pageable);

    long countByKaryawanId(Integer karyawanId);

    @Query("SELECT COALESCE(SUM(t.totalAmount), 0) FROM Transaksi t")
    BigDecimal sumTotalAmount();
}
