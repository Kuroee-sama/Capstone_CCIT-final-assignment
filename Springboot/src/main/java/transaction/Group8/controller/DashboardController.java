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

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
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
     * GET /api/dashboard/monthly-income
     * ADMIN only. Mengembalikan rekap pendapatan bulanan seperti halaman
     * Pendapatan pada CodeIgniter4.
     */
    @GetMapping("/monthly-income")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getMonthlyIncome() {
        List<Map<String, Object>> response = new ArrayList<>();

        for (Object[] row : transaksiService.getMonthlyIncome()) {
            Map<String, Object> item = new HashMap<>();
            item.put("tahun", ((Number) row[0]).intValue());
            item.put("bulan", ((Number) row[1]).intValue());
            item.put("jumlahTransaksi", ((Number) row[2]).intValue());

            Object total = row[3];
            if (total instanceof BigDecimal) {
                item.put("totalPendapatan", total);
            } else if (total instanceof Number) {
                item.put("totalPendapatan", BigDecimal.valueOf(((Number) total).doubleValue()));
            } else {
                item.put("totalPendapatan", BigDecimal.ZERO);
            }

            response.add(item);
        }

        return ResponseEntity.ok(response);
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
