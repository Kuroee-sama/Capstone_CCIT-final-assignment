package transaction.Group8.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "menu")
public class Menu {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "menu_id")
    private Integer menuId;

    @Column(name = "nama_item", nullable = false, length = 100)
    private String namaItem;

    @Column(name = "harga", nullable = false, precision = 10, scale = 2)
    private BigDecimal harga;

    @Column(name = "m_description", columnDefinition = "TEXT")
    private String mDescription;

    @Column(name = "gambar", length = 255)
    private String gambar;

    @Column(name = "stok", nullable = false)
    private Integer stok = 0;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "kategori_id")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Kategori kategori;

    @Column(name = "kategori_id", insertable = false, updatable = false)
    private Integer kategoriId;

    // Constructors
    public Menu() {
    }

    public Menu(String namaItem, BigDecimal harga, String mDescription, Integer stok) {
        this.namaItem = namaItem;
        this.harga = harga;
        this.mDescription = mDescription;
        this.stok = stok;
    }

    // Getters and Setters
    public Integer getMenuId() {
        return menuId;
    }

    public void setMenuId(Integer menuId) {
        this.menuId = menuId;
    }

    public String getNamaItem() {
        return namaItem;
    }

    public void setNamaItem(String namaItem) {
        this.namaItem = namaItem;
    }

    public BigDecimal getHarga() {
        return harga;
    }

    public void setHarga(BigDecimal harga) {
        this.harga = harga;
    }

    public String getMDescription() {
        return mDescription;
    }

    public void setMDescription(String mDescription) {
        this.mDescription = mDescription;
    }

    public String getGambar() {
        return gambar;
    }

    public void setGambar(String gambar) {
        this.gambar = gambar;
    }

    public Integer getStok() {
        return stok;
    }

    public void setStok(Integer stok) {
        this.stok = stok;
    }

    public Kategori getKategori() {
        return kategori;
    }

    public void setKategori(Kategori kategori) {
        this.kategori = kategori;
    }

    public Integer getKategoriId() {
        return kategoriId;
    }

    public void setKategoriId(Integer kategoriId) {
        this.kategoriId = kategoriId;
    }

    /**
     * Mengurangi stok dengan jumlah tertentu
     * 
     * @param jumlah jumlah yang akan dikurangi
     * @throws IllegalArgumentException jika stok tidak mencukupi
     */
    public void kurangiStok(Integer jumlah) {
        if (jumlah <= 0) {
            throw new IllegalArgumentException("Jumlah harus lebih dari 0");
        }
        if (this.stok < jumlah) {
            throw new IllegalArgumentException("Stok tidak mencukupi untuk item: " + this.namaItem +
                    ". Stok tersedia: " + this.stok + ", diminta: " + jumlah);
        }
        this.stok -= jumlah;
    }

    /**
     * Menambah stok dengan jumlah tertentu
     * 
     * @param jumlah jumlah yang akan ditambahkan
     */
    public void tambahStok(Integer jumlah) {
        if (jumlah <= 0) {
            throw new IllegalArgumentException("Jumlah harus lebih dari 0");
        }
        this.stok += jumlah;
    }
}
