package transaction.Group8.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import transaction.Group8.model.Karyawan;
import transaction.Group8.service.KaryawanService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Controller untuk mengelola data Karyawan
 * Hanya dapat diakses oleh role ADMIN
 */
@RestController
@RequestMapping("/api/karyawan")
@PreAuthorize("hasRole('ADMIN')")
public class KaryawanController {

    @Autowired
    private KaryawanService karyawanService;

    // GET - Get all karyawan with pagination
    @GetMapping
    public ResponseEntity<Page<Karyawan>> getAllKaryawan(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "5") int size,
            @RequestParam(defaultValue = "karyawanId") String sortBy,
            @RequestParam(defaultValue = "asc") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("desc")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<Karyawan> karyawanList = karyawanService.getAllKaryawan(pageable);
        return ResponseEntity.ok(karyawanList); // 200 OK
    }

    // GET - Get karyawan by ID
    @GetMapping("/{id}")
    public ResponseEntity<?> getKaryawanById(@PathVariable Integer id) {
        return karyawanService.getKaryawanById(id)
                .map(karyawan -> ResponseEntity.ok(karyawan)) // 200 OK
                .orElseGet(() -> ResponseEntity.notFound().build()); // 404 Not Found
    }

    // POST - Create new karyawan
    @PostMapping
    public ResponseEntity<?> createKaryawan(@RequestBody Karyawan karyawan) {
        try {
            Karyawan createdKaryawan = karyawanService.createKaryawan(karyawan);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdKaryawan); // 201 Created
        } catch (IllegalArgumentException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error); // 400 Bad Request
        }
    }

    // POST - Bulk create karyawan (max 5, transactional)
    @PostMapping("/bulk")
    public ResponseEntity<?> bulkCreateKaryawan(@RequestBody List<Karyawan> karyawanList) {
        try {
            List<Karyawan> createdKaryawan = karyawanService.bulkCreateKaryawan(karyawanList);
            Map<String, Object> response = new HashMap<>();
            response.put("message", createdKaryawan.size() + " karyawan created successfully");
            response.put("data", createdKaryawan);
            return ResponseEntity.status(HttpStatus.CREATED).body(response); // 201 Created
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error); // 400 Bad Request
        }
    }

    // PUT - Update karyawan
    @PutMapping("/{id}")
    public ResponseEntity<?> updateKaryawan(@PathVariable Integer id, @RequestBody Karyawan karyawan) {
        try {
            Karyawan updatedKaryawan = karyawanService.updateKaryawan(id, karyawan);
            return ResponseEntity.ok(updatedKaryawan); // 200 OK
        } catch (IllegalArgumentException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error); // 400 Bad Request
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error); // 404 Not Found
        }
    }

    // DELETE - Delete karyawan
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteKaryawan(@PathVariable Integer id) {
        try {
            karyawanService.deleteKaryawan(id);
            return ResponseEntity.noContent().build(); // 204 No Content
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error); // 404 Not Found
        }
    }

    // DELETE - Bulk delete karyawan (max 5, transactional, validate IDs)
    @DeleteMapping("/bulk")
    public ResponseEntity<?> bulkDeleteKaryawan(@RequestBody Map<String, List<Integer>> request) {
        try {
            List<Integer> ids = request.get("ids");
            if (ids == null || ids.isEmpty()) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "IDs are required");
                return ResponseEntity.badRequest().body(error); // 400 Bad Request
            }
            karyawanService.bulkDeleteKaryawan(ids);
            return ResponseEntity.noContent().build(); // 204 No Content
        } catch (IllegalArgumentException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error); // 400 Bad Request
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error); // 404 Not Found
        }
    }
}
