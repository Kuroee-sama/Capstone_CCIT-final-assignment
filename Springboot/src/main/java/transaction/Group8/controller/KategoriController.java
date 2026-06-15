package transaction.Group8.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import transaction.Group8.model.Kategori;
import transaction.Group8.service.KategoriService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Controller untuk mengelola Kategori
 * GET: ADMIN + KARYAWAN
 * CUD: ADMIN only
 */
@RestController
@RequestMapping("/api/kategori")
public class KategoriController {

    @Autowired
    private KategoriService kategoriService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN','KARYAWAN')")
    public ResponseEntity<List<Kategori>> getAllKategori() {
        return ResponseEntity.ok(kategoriService.getAllKategori());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','KARYAWAN')")
    public ResponseEntity<?> getKategoriById(@PathVariable Integer id) {
        return kategoriService.getKategoriById(id)
                .map(k -> ResponseEntity.ok((Object) k))
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> createKategori(@RequestBody Kategori kategori) {
        try {
            Kategori created = kategoriService.createKategori(kategori);
            return ResponseEntity.status(HttpStatus.CREATED).body(created);
        } catch (IllegalArgumentException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> updateKategori(@PathVariable Integer id, @RequestBody Kategori kategori) {
        try {
            Kategori updated = kategoriService.updateKategori(id, kategori);
            return ResponseEntity.ok(updated);
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

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> deleteKategori(@PathVariable Integer id) {
        try {
            kategoriService.deleteKategori(id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }
    }
}
