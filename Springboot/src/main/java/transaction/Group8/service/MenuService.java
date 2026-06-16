package transaction.Group8.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import transaction.Group8.model.Kategori;
import transaction.Group8.model.Menu;
import transaction.Group8.repository.KategoriRepository;
import transaction.Group8.repository.MenuRepository;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

@Service
public class MenuService {

    private static final int MAX_BULK_SIZE = 5;
    private static final long MAX_IMAGE_SIZE = 5L * 1024L * 1024L;
    private static final Set<String> ALLOWED_EXTENSIONS = Set.of("jpg", "jpeg", "png", "webp", "gif");

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
        validateCreateMenu(menu);
        attachKategori(menu, menu.getKategoriId());
        return menuRepository.save(menu);
    }

    // Create new menu with uploaded image file
    @Transactional
    public Menu createMenu(Menu menu, MultipartFile gambar) {
        String uploadedFile = null;
        if (gambar != null && !gambar.isEmpty()) {
            uploadedFile = storeMenuImage(gambar);
            menu.setGambar(uploadedFile);
        }

        try {
            return createMenu(menu);
        } catch (RuntimeException e) {
            if (uploadedFile != null) {
                deleteMenuImage(uploadedFile);
            }
            throw e;
        }
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
            deleteMenu(id);
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
            attachKategori(menu, menuDetails.getKategoriId());
        }
        return menuRepository.save(menu);
    }

    // Update menu with optional uploaded image
    @Transactional
    public Menu updateMenu(Integer id, Menu menuDetails, MultipartFile gambar) {
        String oldImage = menuRepository.findById(id)
                .map(Menu::getGambar)
                .orElseThrow(() -> new RuntimeException("Menu not found with id: " + id));

        String uploadedFile = null;
        if (gambar != null && !gambar.isEmpty()) {
            uploadedFile = storeMenuImage(gambar);
            menuDetails.setGambar(uploadedFile);
        }

        try {
            Menu updated = updateMenu(id, menuDetails);
            if (uploadedFile != null && oldImage != null && !oldImage.equals(uploadedFile)) {
                deleteMenuImage(oldImage);
            }
            return updated;
        } catch (RuntimeException e) {
            if (uploadedFile != null) {
                deleteMenuImage(uploadedFile);
            }
            throw e;
        }
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
        String oldImage = menu.getGambar();
        menuRepository.delete(menu);
        if (oldImage != null && !oldImage.isBlank()) {
            deleteMenuImage(oldImage);
        }
    }

    private void validateCreateMenu(Menu menu) {
        if (menu.getNamaItem() == null || menu.getNamaItem().isBlank()) {
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
    }

    private void attachKategori(Menu menu, Integer kategoriId) {
        if (kategoriId == null) {
            return;
        }
        Kategori kategori = kategoriRepository.findById(kategoriId)
                .orElseThrow(() -> new IllegalArgumentException("Kategori tidak ditemukan: " + kategoriId));
        menu.setKategori(kategori);
    }

    private String storeMenuImage(MultipartFile file) {
        if (file.getSize() > MAX_IMAGE_SIZE) {
            throw new IllegalArgumentException("Ukuran gambar maksimal 5 MB");
        }

        String original = file.getOriginalFilename() == null ? "menu-image" : file.getOriginalFilename();
        String extension = extensionOf(original);
        if (!ALLOWED_EXTENSIONS.contains(extension)) {
            throw new IllegalArgumentException("Format gambar harus JPG, JPEG, PNG, WEBP, atau GIF");
        }

        String fileName = Instant.now().toEpochMilli() + "_" + UUID.randomUUID().toString().replace("-", "").substring(0, 16) + "." + extension;
        byte[] bytes;
        try {
            bytes = file.getBytes();
        } catch (IOException e) {
            throw new RuntimeException("Gagal membaca file gambar");
        }

        for (Path dir : uploadDirectories()) {
            try {
                Files.createDirectories(dir);
                Files.write(dir.resolve(fileName), bytes);
            } catch (IOException e) {
                throw new RuntimeException("Gagal menyimpan gambar ke " + dir + ": " + e.getMessage());
            }
        }

        return fileName;
    }

    private void deleteMenuImage(String fileName) {
        String safeName = Paths.get(fileName).getFileName().toString();
        for (Path dir : uploadDirectories()) {
            try {
                Files.deleteIfExists(dir.resolve(safeName));
            } catch (IOException ignored) {
                // Tidak menggagalkan operasi database hanya karena file lama tidak bisa dihapus.
            }
        }
    }

    private List<Path> uploadDirectories() {
        Path springDir = Paths.get(System.getProperty("user.dir")).toAbsolutePath();
        Path localUploads = springDir.resolve("uploads").resolve("menu");
        Path ci4Uploads = springDir.getParent() == null
                ? springDir.resolve("CodeIgniter4").resolve("public").resolve("uploads").resolve("menu")
                : springDir.getParent().resolve("CodeIgniter4").resolve("public").resolve("uploads").resolve("menu");

        List<Path> dirs = new ArrayList<>();
        dirs.add(localUploads);
        if (!ci4Uploads.equals(localUploads)) {
            dirs.add(ci4Uploads);
        }
        return dirs;
    }

    private String extensionOf(String fileName) {
        String safeName = Paths.get(fileName).getFileName().toString();
        int dot = safeName.lastIndexOf('.');
        if (dot < 0 || dot == safeName.length() - 1) {
            throw new IllegalArgumentException("File gambar harus memiliki ekstensi");
        }
        return safeName.substring(dot + 1).toLowerCase(Locale.ROOT);
    }
}
