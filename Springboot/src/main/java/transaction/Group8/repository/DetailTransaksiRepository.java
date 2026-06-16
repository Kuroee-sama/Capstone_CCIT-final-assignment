package transaction.Group8.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import transaction.Group8.model.DetailTransaksi;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface DetailTransaksiRepository extends JpaRepository<DetailTransaksi, Integer> {
    List<DetailTransaksi> findByTransaksiId(Integer transaksiId);

    @Query(value = """
            SELECT
                dt.detail_id AS detailId,
                dt.transaksi_id AS transaksiId,
                dt.menu_id AS menuId,
                dt.jumlah AS jumlah,
                dt.harga AS harga,
                dt.total_harga AS totalHarga,
                COALESCE(m.nama_item, CONCAT('Item #', dt.menu_id)) AS namaItem,
                COALESCE(k.nama_kategori, '-') AS namaKategori
            FROM detail_transaksi dt
            LEFT JOIN menu m ON m.menu_id = dt.menu_id
            LEFT JOIN kategori k ON k.kategori_id = m.kategori_id
            WHERE dt.transaksi_id = :transaksiId
            ORDER BY dt.detail_id ASC
            """, nativeQuery = true)
    List<DetailTransaksiView> findDetailViewByTransaksiId(@Param("transaksiId") Integer transaksiId);

    interface DetailTransaksiView {
        Integer getDetailId();
        Integer getTransaksiId();
        Integer getMenuId();
        Integer getJumlah();
        BigDecimal getHarga();
        BigDecimal getTotalHarga();
        String getNamaItem();
        String getNamaKategori();
    }
}
