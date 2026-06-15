package transaction.Group8.model;

import jakarta.persistence.*;

@Entity
@Table(name = "kategori")
public class Kategori {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "kategori_id")
    private Integer kategoriId;

    @Column(name = "nama_kategori", nullable = false, length = 100, unique = true)
    private String namaKategori;

    @Column(name = "k_description", columnDefinition = "TEXT")
    private String kDescription;

    // Constructors
    public Kategori() {
    }

    public Kategori(String namaKategori, String kDescription) {
        this.namaKategori = namaKategori;
        this.kDescription = kDescription;
    }

    // Getters and Setters
    public Integer getKategoriId() {
        return kategoriId;
    }

    public void setKategoriId(Integer kategoriId) {
        this.kategoriId = kategoriId;
    }

    public String getNamaKategori() {
        return namaKategori;
    }

    public void setNamaKategori(String namaKategori) {
        this.namaKategori = namaKategori;
    }

    public String getKDescription() {
        return kDescription;
    }

    public void setKDescription(String kDescription) {
        this.kDescription = kDescription;
    }
}
