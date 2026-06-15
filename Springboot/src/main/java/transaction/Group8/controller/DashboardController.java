package transaction.Group8.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import transaction.Group8.repository.KaryawanRepository;
import transaction.Group8.repository.MenuRepository;
import transaction.Group8.security.JwtAuthenticationFilter;
import transaction.Group8.service.TransaksiService;

import java.util.HashMap;
import java.util.Map;

/**
 * Controller untuk dashboard summary
 */
@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    @Autowired
    private TransaksiService transaksiService;

    @Autowired
    private MenuRepository menuRepository;

    @Autowired
    private KaryawanRepository karyawanRepository;

    private Integer getCurrentKaryawanId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getDetails() instanceof JwtAuthenticationFilter.JwtAuthenticationDetails) {
            return ((JwtAuthenticationFilter.JwtAuthenticationDetails) auth.getDetails()).getUserId();
        }
        return null;
    }

    private String getCurrentRole() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getDetails() instanceof JwtAuthenticationFilter.JwtAuthenticationDetails) {
            return ((JwtAuthenticationFilter.JwtAuthenticationDetails) auth.getDetails()).getRole();
        }
        return null;
    }

    /**
     * GET /api/dashboard/summary
     * ADMIN: full summary
     * KARYAWAN: limited summary
     */
    @GetMapping("/summary")
    @PreAuthorize("hasAnyRole('ADMIN','KARYAWAN')")
    public ResponseEntity<?> getDashboardSummary() {
        Map<String, Object> summary = new HashMap<>();
        String role = getCurrentRole();

        summary.put("totalMenu", menuRepository.count());
        summary.put("totalTransaksi", transaksiService.countAll());

        if ("ADMIN".equals(role)) {
            summary.put("totalPendapatan", transaksiService.sumTotalAmount());
            summary.put("totalKaryawan", karyawanRepository.count());
        } else {
            // KARYAWAN
            Integer karyawanId = getCurrentKaryawanId();
            if (karyawanId != null) {
                summary.put("totalTransaksiSaya", transaksiService.countByKaryawanId(karyawanId));
            }
        }

        return ResponseEntity.ok(summary);
    }
}
