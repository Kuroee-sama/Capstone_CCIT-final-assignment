package transaction.Group8.service;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import transaction.Group8.model.DetailTransaksi;
import transaction.Group8.model.Karyawan;
import transaction.Group8.model.Menu;
import transaction.Group8.model.Transaksi;
import transaction.Group8.repository.DetailTransaksiRepository;
import transaction.Group8.repository.KaryawanRepository;
import transaction.Group8.repository.MenuRepository;
import transaction.Group8.repository.TransaksiRepository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class TransaksiService {

    @PersistenceContext
    private EntityManager entityManager;

    @Autowired
    private TransaksiRepository transaksiRepository;

    @Autowired
    private DetailTransaksiRepository detailTransaksiRepository;

    @Autowired
    private KaryawanRepository karyawanRepository;

    @Autowired
    private MenuRepository menuRepository;

    // Get all transactions with pagination
    public Page<Transaksi> getAllTransaksi(Pageable pageable) {
        return transaksiRepository.findAll(pageable);
    }

    // Get all transactions without pagination
    public List<Transaksi> getAllTransaksi() {
        return transaksiRepository.findAll();
    }

    // Get transaction by ID
    public Optional<Transaksi> getTransaksiById(Integer id) {
        return transaksiRepository.findById(id);
    }

    // Get transactions by karyawan ID with pagination
    public Page<Transaksi> getTransaksiByKaryawanId(Integer karyawanId, Pageable pageable) {
        return transaksiRepository.findByKaryawanId(karyawanId, pageable);
    }

    // Count all transactions
    public long countAll() {
        return transaksiRepository.count();
    }

    // Count transactions by karyawan
    public long countByKaryawanId(Integer karyawanId) {
        return transaksiRepository.countByKaryawanId(karyawanId);
    }

    // Sum all transaction amounts
    public BigDecimal sumTotalAmount() {
        return transaksiRepository.sumTotalAmount();
    }

    /**
     * Create new transaction with details in one request
     * Backend calculates total from DB prices (never trust frontend total)
     * Stock is validated and reduced atomically
     */
    @Transactional
    public Transaksi createTransaksiWithDetails(Integer karyawanId, List<DetailRequest> details,
                                                 String metodePembayaran, BigDecimal bayar) {
        if (details == null || details.isEmpty()) {
            throw new IllegalArgumentException("Details tidak boleh kosong");
        }

        Karyawan karyawan = karyawanRepository.findById(karyawanId)
                .orElseThrow(() -> new RuntimeException("Karyawan not found with id: " + karyawanId));

        // Create transaksi
        Transaksi transaksi = new Transaksi();
        transaksi.setKaryawan(karyawan);
        transaksi.setTglTransaksi(LocalDateTime.now());
        transaksi.setTotalAmount(BigDecimal.ZERO);
        transaksi.setMetodePembayaran(metodePembayaran != null ? metodePembayaran : "CASH");

        Transaksi savedTransaksi = transaksiRepository.save(transaksi);

        BigDecimal totalAmount = BigDecimal.ZERO;

        // Process each detail - calculate total from DB prices
        for (DetailRequest detailReq : details) {
            if (detailReq.getMenuId() == null) {
                throw new IllegalArgumentException("menuId is required for each detail");
            }
            if (detailReq.getJumlah() == null || detailReq.getJumlah() <= 0) {
                throw new IllegalArgumentException("jumlah must be greater than 0");
            }

            Menu menu = menuRepository.findById(detailReq.getMenuId())
                    .orElseThrow(() -> new RuntimeException("Menu not found with id: " + detailReq.getMenuId()));

            // Check and reduce stock
            menu.kurangiStok(detailReq.getJumlah());
            menuRepository.save(menu);

            // Create detail - price from DB, NOT from request
            DetailTransaksi detail = new DetailTransaksi();
            detail.setTransaksi(savedTransaksi);
            detail.setMenu(menu);
            detail.setJumlah(detailReq.getJumlah());
            detail.setHarga(menu.getHarga());
            detail.setTotalHarga(menu.getHarga().multiply(BigDecimal.valueOf(detailReq.getJumlah())));

            detailTransaksiRepository.save(detail);

            totalAmount = totalAmount.add(detail.getTotalHarga());
        }

        // Update total amount (server-calculated)
        savedTransaksi.setTotalAmount(totalAmount);

        // Set payment info
        if (bayar != null) {
            savedTransaksi.setBayar(bayar);
            savedTransaksi.setKembalian(bayar.subtract(totalAmount));
        }

        Transaksi finalTransaksi = transaksiRepository.save(savedTransaksi);

        // Flush all pending changes to database and refresh entity to load all relationships
        entityManager.flush();
        entityManager.refresh(finalTransaksi);

        return finalTransaksi;
    }

    // Get detail items by transaction ID
    public List<DetailTransaksi> getDetailTransaksi(Integer transaksiId) {
        return detailTransaksiRepository.findByTransaksiId(transaksiId);
    }

    /**
     * Add detail to existing transaction with automatic stock reduction
     */
    @Transactional
    public DetailTransaksi addDetailTransaksi(Integer transaksiId, Integer menuId, Integer jumlah) {
        Transaksi transaksi = transaksiRepository.findById(transaksiId)
                .orElseThrow(() -> new RuntimeException("Transaction not found with id: " + transaksiId));

        Menu menu = menuRepository.findById(menuId)
                .orElseThrow(() -> new RuntimeException("Menu not found with id: " + menuId));

        // Check and reduce stock
        menu.kurangiStok(jumlah);
        menuRepository.save(menu);

        // Create detail transaksi
        DetailTransaksi detail = new DetailTransaksi();
        detail.setTransaksi(transaksi);
        detail.setMenu(menu);
        detail.setJumlah(jumlah);
        detail.setHarga(menu.getHarga());
        detail.setTotalHarga(menu.getHarga().multiply(BigDecimal.valueOf(jumlah)));

        DetailTransaksi savedDetail = detailTransaksiRepository.save(detail);

        // Update total amount in transaksi
        BigDecimal currentTotal = transaksi.getTotalAmount() != null ? transaksi.getTotalAmount() : BigDecimal.ZERO;
        transaksi.setTotalAmount(currentTotal.add(savedDetail.getTotalHarga()));
        transaksiRepository.save(transaksi);

        return savedDetail;
    }

    /**
     * Delete transaction and restore stock
     */
    @Transactional
    public void deleteTransaksi(Integer id) {
        Transaksi transaksi = transaksiRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Transaction not found with id: " + id));

        // Restore stock for each detail
        List<DetailTransaksi> details = detailTransaksiRepository.findByTransaksiId(id);
        for (DetailTransaksi detail : details) {
            if (detail.getMenu() != null && detail.getJumlah() != null) {
                Menu menu = detail.getMenu();
                menu.tambahStok(detail.getJumlah());
                menuRepository.save(menu);
            }
        }

        transaksiRepository.delete(transaksi);
    }

    /**
     * Inner class for detail request
     */
    public static class DetailRequest {
        private Integer menuId;
        private Integer jumlah;

        public DetailRequest() {
        }

        public DetailRequest(Integer menuId, Integer jumlah) {
            this.menuId = menuId;
            this.jumlah = jumlah;
        }

        public Integer getMenuId() {
            return menuId;
        }

        public void setMenuId(Integer menuId) {
            this.menuId = menuId;
        }

        public Integer getJumlah() {
            return jumlah;
        }

        public void setJumlah(Integer jumlah) {
            this.jumlah = jumlah;
        }
    }
}
