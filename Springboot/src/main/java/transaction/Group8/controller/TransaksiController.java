package transaction.Group8.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import transaction.Group8.dto.TransaksiRequest;
import transaction.Group8.model.DetailTransaksi;
import transaction.Group8.model.Transaksi;
import transaction.Group8.security.JwtAuthenticationFilter;
import transaction.Group8.service.TransaksiService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Controller untuk mengelola Transaksi
 * Role access per method
 */
@RestController
@RequestMapping("/api/transaksi")
public class TransaksiController {

    @Autowired
    private TransaksiService transaksiService;

    /**
     * Get current user's ID from JWT token
     */
    private Integer getCurrentKaryawanId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getDetails() instanceof JwtAuthenticationFilter.JwtAuthenticationDetails) {
            JwtAuthenticationFilter.JwtAuthenticationDetails details = (JwtAuthenticationFilter.JwtAuthenticationDetails) auth
                    .getDetails();
            return details.getUserId();
        }
        return null;
    }

    /**
     * Get current user's role from JWT token
     */
    private String getCurrentRole() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getDetails() instanceof JwtAuthenticationFilter.JwtAuthenticationDetails) {
            JwtAuthenticationFilter.JwtAuthenticationDetails details = (JwtAuthenticationFilter.JwtAuthenticationDetails) auth
                    .getDetails();
            return details.getRole();
        }
        return null;
    }

    // GET - Get all transactions (ADMIN only)
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getAllTransaksi(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(defaultValue = "transaksiId") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {

        Sort sort = sortDir.equalsIgnoreCase("desc")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);
        Page<Transaksi> transaksiList = transaksiService.getAllTransaksi(pageable);
        return ResponseEntity.ok(transaksiList);
    }

    // GET - Get my transactions (ADMIN + KARYAWAN)
    @GetMapping("/my")
    @PreAuthorize("hasAnyRole('ADMIN','KARYAWAN')")
    public ResponseEntity<?> getMyTransaksi(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        Integer karyawanId = getCurrentKaryawanId();
        if (karyawanId == null) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Unauthorized");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }

        Pageable pageable = PageRequest.of(page, size, Sort.by("transaksiId").descending());
        Page<Transaksi> transaksiList = transaksiService.getTransaksiByKaryawanId(karyawanId, pageable);
        return ResponseEntity.ok(transaksiList);
    }

    // GET - Unified transaction history.
    // ADMIN receives all transactions; KARYAWAN receives only their own transactions.
    // This mirrors the CI4 web rule and prevents Flutter from deciding data scope on the client side.
    @GetMapping("/riwayat")
    @PreAuthorize("hasAnyRole('ADMIN','KARYAWAN')")
    public ResponseEntity<?> getRiwayatTransaksi(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "200") int size) {

        String role = getCurrentRole();
        Integer karyawanId = getCurrentKaryawanId();

        if (role == null || karyawanId == null) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Unauthorized");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }

        Pageable pageable = PageRequest.of(page, size, Sort.by("transaksiId").descending());
        Page<Transaksi> transaksiList = "ADMIN".equalsIgnoreCase(role)
                ? transaksiService.getAllTransaksi(pageable)
                : transaksiService.getTransaksiByKaryawanId(karyawanId, pageable);

        return ResponseEntity.ok(transaksiList);
    }

    // GET - Get transaction by ID (ADMIN: any, KARYAWAN: own only)
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','KARYAWAN')")
    public ResponseEntity<?> getTransaksiById(@PathVariable Integer id) {
        var transaksiOpt = transaksiService.getTransaksiById(id);
        if (transaksiOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Transaksi transaksi = transaksiOpt.get();

        // KARYAWAN can only see own transactions
        String role = getCurrentRole();
        if ("KARYAWAN".equals(role)) {
            Integer currentId = getCurrentKaryawanId();
            if (!transaksi.getKaryawanId().equals(currentId)) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Akses ditolak: bukan transaksi Anda");
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(error);
            }
        }

        return ResponseEntity.ok(transaksi);
    }

    // GET - Get transactions by karyawan ID (ADMIN only)
    @GetMapping("/karyawan/{karyawanId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getTransaksiByKaryawanId(
            @PathVariable Integer karyawanId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        Pageable pageable = PageRequest.of(page, size, Sort.by("transaksiId").descending());
        Page<Transaksi> transaksiList = transaksiService.getTransaksiByKaryawanId(karyawanId, pageable);
        return ResponseEntity.ok(transaksiList);
    }

    /**
     * POST - Create new transaction with details (ADMIN + KARYAWAN)
     * 
     * Request body:
     * {
     *   "items": [
     *     { "menuId": 1, "jumlah": 2 },
     *     { "menuId": 3, "jumlah": 1 }
     *   ],
     *   "metodePembayaran": "CASH",
     *   "bayar": 100000
     * }
     */
    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN','KARYAWAN')")
    public ResponseEntity<?> createTransaksi(@RequestBody TransaksiRequest request) {
        try {
            Integer karyawanId = getCurrentKaryawanId();
            if (karyawanId == null) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Unauthorized");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
            }

            List<TransaksiRequest.DetailRequest> items = request.getItems();
            if (items == null || items.isEmpty()) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Items tidak boleh kosong");
                return ResponseEntity.badRequest().body(error);
            }

            // Convert DTO to service request
            List<TransaksiService.DetailRequest> details = items.stream()
                    .map(d -> new TransaksiService.DetailRequest(d.getMenuId(), d.getJumlah()))
                    .collect(Collectors.toList());

            Transaksi created = transaksiService.createTransaksiWithDetails(
                    karyawanId, details, request.getMetodePembayaran(), request.getBayar());
            return ResponseEntity.status(HttpStatus.CREATED).body(created);
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

    // GET - Get detail items of a transaction (ADMIN: any, KARYAWAN: own only)
    @GetMapping("/{id}/detail")
    @PreAuthorize("hasAnyRole('ADMIN','KARYAWAN')")
    public ResponseEntity<?> getDetailTransaksi(@PathVariable Integer id) {
        var transaksiOpt = transaksiService.getTransaksiById(id);
        if (transaksiOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        // KARYAWAN can only see own transaction details
        String role = getCurrentRole();
        if ("KARYAWAN".equals(role)) {
            Integer currentId = getCurrentKaryawanId();
            if (!transaksiOpt.get().getKaryawanId().equals(currentId)) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Akses ditolak");
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(error);
            }
        }

        return ResponseEntity.ok(transaksiService.getDetailTransaksiView(id));
    }

    // POST - Add detail to existing transaction (ADMIN only)
    @PostMapping("/{id}/detail")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> addDetailTransaksi(@PathVariable Integer id, @RequestBody Map<String, Object> request) {
        try {
            if (!request.containsKey("menuId")) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "menuId is required");
                return ResponseEntity.badRequest().body(error);
            }
            if (!request.containsKey("jumlah")) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "jumlah is required");
                return ResponseEntity.badRequest().body(error);
            }

            Integer menuId = Integer.valueOf(request.get("menuId").toString());
            Integer jumlah = Integer.valueOf(request.get("jumlah").toString());

            DetailTransaksi created = transaksiService.addDetailTransaksi(id, menuId, jumlah);
            return ResponseEntity.status(HttpStatus.CREATED).body(created);
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

    // DELETE - Delete transaction (ADMIN only)
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> deleteTransaksi(@PathVariable Integer id) {
        try {
            transaksiService.deleteTransaksi(id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }
    }
}
