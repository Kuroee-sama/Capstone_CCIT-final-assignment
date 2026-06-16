package transaction.Group8.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import transaction.Group8.model.Menu;
import transaction.Group8.service.MenuService;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Controller untuk mengelola Menu
 * GET endpoints: ADMIN + KARYAWAN
 * CUD endpoints: ADMIN only
 */
@RestController
@RequestMapping("/api/menu")
public class MenuController {

    @Autowired
    private MenuService menuService;

    // GET - Get all menu with pagination (ADMIN + KARYAWAN)
    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN','KARYAWAN')")
    public ResponseEntity<Page<Menu>> getAllMenu(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "100") int size,
            @RequestParam(defaultValue = "menuId") String sortBy,
            @RequestParam(defaultValue = "asc") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("desc")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<Menu> menuList = menuService.getAllMenu(pageable);
        return ResponseEntity.ok(menuList);
    }

    // GET - Get menu by ID (ADMIN + KARYAWAN)
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','KARYAWAN')")
    public ResponseEntity<?> getMenuById(@PathVariable Integer id) {
        return menuService.getMenuById(id)
                .map(menu -> ResponseEntity.ok(menu))
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    // GET - Get menu by kategori ID with pagination (ADMIN + KARYAWAN)
    @GetMapping("/kategori/{kategoriId}")
    @PreAuthorize("hasAnyRole('ADMIN','KARYAWAN')")
    public ResponseEntity<?> getMenuByKategori(
            @PathVariable Integer kategoriId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "100") int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("menuId").ascending());
        Page<Menu> menuList = menuService.getMenuByKategoriId(kategoriId, pageable);
        return ResponseEntity.ok(menuList);
    }

    // POST JSON - Create new menu (ADMIN only)
    @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE)
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> createMenu(@RequestBody Menu menu) {
        try {
            Menu createdMenu = menuService.createMenu(menu);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdMenu);
        } catch (IllegalArgumentException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    // POST multipart - Create new menu with image upload (ADMIN only)
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> createMenuMultipart(
            @RequestParam String namaItem,
            @RequestParam BigDecimal harga,
            @RequestParam(defaultValue = "0") Integer stok,
            @RequestParam Integer kategoriId,
            @RequestParam(required = false) String mDescription,
            @RequestParam(required = false) MultipartFile gambar) {
        try {
            Menu menu = buildMenu(namaItem, harga, stok, kategoriId, mDescription);
            Menu createdMenu = menuService.createMenu(menu, gambar);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdMenu);
        } catch (IllegalArgumentException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    // POST - Bulk create menu (ADMIN only)
    @PostMapping("/bulk")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> bulkCreateMenu(@RequestBody List<Menu> menuList) {
        try {
            List<Menu> createdMenu = menuService.bulkCreateMenu(menuList);
            Map<String, Object> response = new HashMap<>();
            response.put("message", createdMenu.size() + " menu items created successfully");
            response.put("data", createdMenu);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    // PUT JSON - Update menu (ADMIN only)
    @PutMapping(value = "/{id}", consumes = MediaType.APPLICATION_JSON_VALUE)
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> updateMenu(@PathVariable Integer id, @RequestBody Menu menu) {
        try {
            Menu updatedMenu = menuService.updateMenu(id, menu);
            return ResponseEntity.ok(updatedMenu);
        } catch (IllegalArgumentException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }
    }

    // POST multipart - Update menu with image upload (ADMIN only)
    @PostMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> updateMenuMultipart(
            @PathVariable Integer id,
            @RequestParam String namaItem,
            @RequestParam BigDecimal harga,
            @RequestParam(defaultValue = "0") Integer stok,
            @RequestParam Integer kategoriId,
            @RequestParam(required = false) String mDescription,
            @RequestParam(required = false) MultipartFile gambar) {
        try {
            Menu menu = buildMenu(namaItem, harga, stok, kategoriId, mDescription);
            Menu updatedMenu = menuService.updateMenu(id, menu, gambar);
            return ResponseEntity.ok(updatedMenu);
        } catch (IllegalArgumentException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }
    }

    // PATCH - Update stok only (ADMIN only)
    @PatchMapping("/{id}/stok")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> updateStok(@PathVariable Integer id, @RequestBody Map<String, Integer> request) {
        try {
            Integer stok = request.get("stok");
            if (stok == null) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "stok is required");
                return ResponseEntity.badRequest().body(error);
            }
            Menu updatedMenu = menuService.updateStok(id, stok);
            return ResponseEntity.ok(updatedMenu);
        } catch (IllegalArgumentException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }
    }

    // DELETE - Delete menu (ADMIN only)
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> deleteMenu(@PathVariable Integer id) {
        try {
            menuService.deleteMenu(id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }
    }

    // DELETE - Bulk delete menu (ADMIN only)
    @DeleteMapping("/bulk")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> bulkDeleteMenu(@RequestBody Map<String, List<Integer>> request) {
        try {
            List<Integer> ids = request.get("ids");
            if (ids == null || ids.isEmpty()) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "IDs are required");
                return ResponseEntity.badRequest().body(error);
            }
            menuService.bulkDeleteMenu(ids);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }
    }

    private Menu buildMenu(String namaItem, BigDecimal harga, Integer stok, Integer kategoriId, String mDescription) {
        Menu menu = new Menu();
        menu.setNamaItem(namaItem);
        menu.setHarga(harga);
        menu.setStok(stok);
        menu.setKategoriId(kategoriId);
        menu.setMDescription(mDescription);
        return menu;
    }
}
