package transaction.Group8.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "transaksi")
public class Transaksi {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "transaksi_id")
    private Integer transaksiId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "karyawan_id")
    @JsonIgnore
    private Karyawan karyawan;

    @Column(name = "karyawan_id", insertable = false, updatable = false)
    private Integer karyawanId;

    @Column(name = "tgl_transaksi", updatable = false)
    private LocalDateTime tglTransaksi;

    @Column(name = "total_amount", precision = 10, scale = 2)
    private BigDecimal totalAmount;

    @Column(name = "metode_pembayaran", length = 20)
    private String metodePembayaran = "CASH";

    @Column(name = "bayar", precision = 10, scale = 2)
    private BigDecimal bayar;

    @Column(name = "kembalian", precision = 10, scale = 2)
    private BigDecimal kembalian;

    @OneToMany(mappedBy = "transaksi", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnore
    private List<DetailTransaksi> detailList;

    // Transient field for karyawan username in response
    @Transient
    private String karyawanUsername;

    // Constructors
    public Transaksi() {
    }

    public Transaksi(BigDecimal totalAmount, Karyawan karyawan) {
        this.totalAmount = totalAmount;
        this.karyawan = karyawan;
    }

    // Getters and Setters
    public Integer getTransaksiId() {
        return transaksiId;
    }

    public void setTransaksiId(Integer transaksiId) {
        this.transaksiId = transaksiId;
    }

    public Karyawan getKaryawan() {
        return karyawan;
    }

    public void setKaryawan(Karyawan karyawan) {
        this.karyawan = karyawan;
    }

    public Integer getKaryawanId() {
        return karyawanId;
    }

    public void setKaryawanId(Integer karyawanId) {
        this.karyawanId = karyawanId;
    }

    public LocalDateTime getTglTransaksi() {
        return tglTransaksi;
    }

    public void setTglTransaksi(LocalDateTime tglTransaksi) {
        this.tglTransaksi = tglTransaksi;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getMetodePembayaran() {
        return metodePembayaran;
    }

    public void setMetodePembayaran(String metodePembayaran) {
        this.metodePembayaran = metodePembayaran;
    }

    public BigDecimal getBayar() {
        return bayar;
    }

    public void setBayar(BigDecimal bayar) {
        this.bayar = bayar;
    }

    public BigDecimal getKembalian() {
        return kembalian;
    }

    public void setKembalian(BigDecimal kembalian) {
        this.kembalian = kembalian;
    }

    public List<DetailTransaksi> getDetailList() {
        return detailList;
    }

    public void setDetailList(List<DetailTransaksi> detailList) {
        this.detailList = detailList;
    }

    public String getKaryawanUsername() {
        if (karyawan != null) {
            return karyawan.getUsername();
        }
        return karyawanUsername;
    }

    public void setKaryawanUsername(String karyawanUsername) {
        this.karyawanUsername = karyawanUsername;
    }

    @PrePersist
    protected void onCreate() {
        this.tglTransaksi = LocalDateTime.now();
    }
}
