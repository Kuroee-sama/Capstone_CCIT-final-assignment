package transaction.Group8.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "detail_transaksi")
public class DetailTransaksi {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "detail_id")
    private Integer detailId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "transaksi_id")
    @JsonIgnore
    private Transaksi transaksi;

    @Column(name = "transaksi_id", insertable = false, updatable = false)
    private Integer transaksiId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "menu_id")
    private Menu menu;

    @Column(name = "menu_id", insertable = false, updatable = false)
    private Integer menuId;

    @Column(name = "jumlah")
    private Integer jumlah;

    @Column(name = "harga", precision = 10, scale = 2)
    private BigDecimal harga;

    @Column(name = "total_harga", precision = 10, scale = 2)
    private BigDecimal totalHarga;

    // Constructors
    public DetailTransaksi() {
    }

    public DetailTransaksi(Menu menu, Integer jumlah, Transaksi transaksi) {
        this.menu = menu;
        this.jumlah = jumlah;
        this.harga = menu.getHarga();
        this.transaksi = transaksi;
        this.totalHarga = this.harga.multiply(BigDecimal.valueOf(jumlah));
    }

    // Getters and Setters
    public Integer getDetailId() {
        return detailId;
    }

    public void setDetailId(Integer detailId) {
        this.detailId = detailId;
    }

    public Transaksi getTransaksi() {
        return transaksi;
    }

    public void setTransaksi(Transaksi transaksi) {
        this.transaksi = transaksi;
    }

    public Integer getTransaksiId() {
        return transaksiId;
    }

    public void setTransaksiId(Integer transaksiId) {
        this.transaksiId = transaksiId;
    }

    public Menu getMenu() {
        return menu;
    }

    public void setMenu(Menu menu) {
        this.menu = menu;
        if (menu != null) {
            this.harga = menu.getHarga();
        }
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
        calculateTotalHarga();
    }

    public BigDecimal getHarga() {
        return harga;
    }

    public void setHarga(BigDecimal harga) {
        this.harga = harga;
        calculateTotalHarga();
    }

    public BigDecimal getTotalHarga() {
        return totalHarga;
    }

    public void setTotalHarga(BigDecimal totalHarga) {
        this.totalHarga = totalHarga;
    }

    /**
     * Calculate total_harga based on harga and jumlah
     */
    private void calculateTotalHarga() {
        if (this.harga != null && this.jumlah != null) {
            this.totalHarga = this.harga.multiply(BigDecimal.valueOf(this.jumlah));
        }
    }
}
