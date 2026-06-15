package transaction.Group8.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import transaction.Group8.model.Kategori;
import transaction.Group8.repository.KategoriRepository;

import java.util.List;
import java.util.Optional;

@Service
public class KategoriService {

    @Autowired
    private KategoriRepository kategoriRepository;

    public List<Kategori> getAllKategori() {
        return kategoriRepository.findAll();
    }

    public Optional<Kategori> getKategoriById(Integer id) {
        return kategoriRepository.findById(id);
    }

    @Transactional
    public Kategori createKategori(Kategori kategori) {
        if (kategori.getNamaKategori() == null || kategori.getNamaKategori().isEmpty()) {
            throw new IllegalArgumentException("Nama kategori wajib diisi");
        }
        if (kategoriRepository.findByNamaKategori(kategori.getNamaKategori()).isPresent()) {
            throw new IllegalArgumentException("Kategori sudah ada: " + kategori.getNamaKategori());
        }
        return kategoriRepository.save(kategori);
    }

    @Transactional
    public Kategori updateKategori(Integer id, Kategori kategoriDetails) {
        Kategori kategori = kategoriRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Kategori tidak ditemukan: " + id));

        if (kategoriDetails.getNamaKategori() != null) {
            if (!kategori.getNamaKategori().equals(kategoriDetails.getNamaKategori())
                    && kategoriRepository.findByNamaKategori(kategoriDetails.getNamaKategori()).isPresent()) {
                throw new IllegalArgumentException("Kategori sudah ada: " + kategoriDetails.getNamaKategori());
            }
            kategori.setNamaKategori(kategoriDetails.getNamaKategori());
        }
        if (kategoriDetails.getKDescription() != null) {
            kategori.setKDescription(kategoriDetails.getKDescription());
        }
        return kategoriRepository.save(kategori);
    }

    @Transactional
    public void deleteKategori(Integer id) {
        Kategori kategori = kategoriRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Kategori tidak ditemukan: " + id));
        kategoriRepository.delete(kategori);
    }
}
