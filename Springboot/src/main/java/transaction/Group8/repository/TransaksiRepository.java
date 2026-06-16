package transaction.Group8.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import transaction.Group8.model.Transaksi;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface TransaksiRepository extends JpaRepository<Transaksi, Integer> {
    Page<Transaksi> findByKaryawanId(Integer karyawanId, Pageable pageable);

    long countByKaryawanId(Integer karyawanId);

    @Query("SELECT COALESCE(SUM(t.totalAmount), 0) FROM Transaksi t")
    BigDecimal sumTotalAmount();

    @Query(value = """
            SELECT
                YEAR(tgl_transaksi) AS tahun,
                MONTH(tgl_transaksi) AS bulan,
                COUNT(*) AS jumlah_transaksi,
                COALESCE(SUM(total_amount), 0) AS total_pendapatan
            FROM transaksi
            GROUP BY YEAR(tgl_transaksi), MONTH(tgl_transaksi)
            ORDER BY tahun DESC, bulan DESC
            """, nativeQuery = true)
    List<Object[]> getMonthlyIncome();
}
