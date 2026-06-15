package transaction.Group8.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import transaction.Group8.model.Kategori;

import java.util.Optional;

@Repository
public interface KategoriRepository extends JpaRepository<Kategori, Integer> {
    Optional<Kategori> findByNamaKategori(String namaKategori);
}
