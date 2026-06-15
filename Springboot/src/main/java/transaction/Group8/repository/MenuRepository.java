package transaction.Group8.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import transaction.Group8.model.Menu;

import java.util.List;
import java.util.Optional;

@Repository
public interface MenuRepository extends JpaRepository<Menu, Integer> {
    Optional<Menu> findByNamaItem(String namaItem);

    List<Menu> findByKategoriKategoriId(Integer kategoriId);

    Page<Menu> findByKategoriKategoriId(Integer kategoriId, Pageable pageable);
}
