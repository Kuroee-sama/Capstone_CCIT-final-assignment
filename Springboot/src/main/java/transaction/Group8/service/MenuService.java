package transaction.Group8.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import transaction.Group8.model.Kategori;
import transaction.Group8.model.Menu;
import transaction.Group8.repository.KategoriRepository;
import transaction.Group8.repository.MenuRepository;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class MenuService {

    private static final int MAX_BULK_SIZE = 5;

    @Autowired
    private MenuRepository menuRepository;

    @Autowired
    private KategoriRepository kategoriRepository;

    // Get all menu with pagination
    public Page<Menu> getAllMenu(Pageable pageable) {
        return menuRepository.findAll(pageable);
    }

    // Get all menu without pagination
    public List<Menu> getAllMenu() {
        return menuRepository.findAll();
    }

    // Get menu by ID
    public Optional<Menu> getMenuById(Integer id) {
        return menuRepository.findById(id);
    }

    // Get menu by kategori ID with pagination
    public Page<Menu> getMenuByKategoriId(Integer kategoriId, Pageable pageable) {
        return menuRepository.findByKategoriKategoriId(kategoriId, pageable);
    }

    // Get menu by nama item
    public Optional<Menu> getMenuByNamaItem(String namaItem) {
        return menuRepository.findByNamaItem(namaItem);
    }

    // Create new menu
    @Transactional
    public Menu createMenu(Menu menu) {
        if (menu.getNamaItem() == null || menu.getNamaItem().isEmpty()) {
            throw new IllegalArgumentException("Nama item wajib diisi");
        }
        if (menu.getHarga() == null) {
            throw new IllegalArgumentException("Harga wajib diisi");
        }
        if (menuRepository.findByNamaItem(menu.getNamaItem()).isPresent()) {
            throw new IllegalArgumentException("Menu item sudah ada: " + menu.getNamaItem());
        }
        if (menu.getStok() == null) {
            menu.setStok(0);
        }
        // Set kategori relation if kategoriId provided
        if (menu.getKategoriId() != null) {
            Kategori kategori = kategoriRepository.findById(menu.getKategoriId())
                    .orElseThrow(() -> new IllegalArgumentException("Kategori tidak ditemukan: " + menu.getKategoriId()));
            menu.setKategori(kategori);
        }
        return menuRepository.save(menu);
    }

    // Bulk create menu - All or nothing (Transactional)
    @Transactional(rollbackFor = Exception.class)
    public List<Menu> bulkCreateMenu(List<Menu> menuList) {
        if (menuList.size() > MAX_BULK_SIZE) {
            throw new IllegalArgumentException("Bulk create limit exceeded. Maximum allowed: " + MAX_BULK_SIZE);
        }
        if (menuList.isEmpty()) {
            throw new IllegalArgumentException("Menu list cannot be empty");
        }

        List<Menu> createdMenu = new ArrayList<>();
        for (Menu menu : menuList) {
            createdMenu.add(createMenu(menu));
        }
        return createdMenu;
    }

    // Bulk delete menu - All or nothing (Transactional)
    @Transactional(rollbackFor = Exception.class)
    public void bulkDeleteMenu(List<Integer> ids) {
        if (ids.size() > MAX_BULK_SIZE) {
            throw new IllegalArgumentException("Bulk delete limit exceeded. Maximum allowed: " + MAX_BULK_SIZE);
        }
        if (ids.isEmpty()) {
            throw new IllegalArgumentException("ID list cannot be empty");
        }

        List<Integer> notFoundIds = new ArrayList<>();
        for (Integer id : ids) {
            if (!menuRepository.existsById(id)) {
                notFoundIds.add(id);
            }
        }
        if (!notFoundIds.isEmpty()) {
            throw new RuntimeException("Menu not found with ids: " + notFoundIds);
        }

        for (Integer id : ids) {
            menuRepository.deleteById(id);
        }
    }

    // Update menu
    @Transactional
    public Menu updateMenu(Integer id, Menu menuDetails) {
        Menu menu = menuRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Menu not found with id: " + id));

        if (menuDetails.getNamaItem() != null) {
            if (!menu.getNamaItem().equals(menuDetails.getNamaItem())
                    && menuRepository.findByNamaItem(menuDetails.getNamaItem()).isPresent()) {
                throw new IllegalArgumentException("Menu item already exists: " + menuDetails.getNamaItem());
            }
            menu.setNamaItem(menuDetails.getNamaItem());
        }
        if (menuDetails.getHarga() != null) {
            menu.setHarga(menuDetails.getHarga());
        }
        if (menuDetails.getMDescription() != null) {
            menu.setMDescription(menuDetails.getMDescription());
        }
        if (menuDetails.getGambar() != null) {
            menu.setGambar(menuDetails.getGambar());
        }
        if (menuDetails.getStok() != null) {
            menu.setStok(menuDetails.getStok());
        }
        // Update kategori relation
        if (menuDetails.getKategoriId() != null) {
            Kategori kategori = kategoriRepository.findById(menuDetails.getKategoriId())
                    .orElseThrow(() -> new IllegalArgumentException("Kategori tidak ditemukan: " + menuDetails.getKategoriId()));
            menu.setKategori(kategori);
        }
        return menuRepository.save(menu);
    }

    // Update stok only
    @Transactional
    public Menu updateStok(Integer id, Integer stok) {
        Menu menu = menuRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Menu not found with id: " + id));

        if (stok < 0) {
            throw new IllegalArgumentException("Stok cannot be negative");
        }
        menu.setStok(stok);
        return menuRepository.save(menu);
    }

    // Kurangi stok (untuk transaksi)
    @Transactional
    public Menu kurangiStok(Integer id, Integer jumlah) {
        Menu menu = menuRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Menu not found with id: " + id));

        menu.kurangiStok(jumlah); // Will throw exception if stock insufficient
        return menuRepository.save(menu);
    }

    // Tambah stok (untuk restock atau cancel transaksi)
    @Transactional
    public Menu tambahStok(Integer id, Integer jumlah) {
        Menu menu = menuRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Menu not found with id: " + id));

        menu.tambahStok(jumlah);
        return menuRepository.save(menu);
    }

    // Delete menu
    @Transactional
    public void deleteMenu(Integer id) {
        Menu menu = menuRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Menu not found with id: " + id));
        menuRepository.delete(menu);
    }
}
