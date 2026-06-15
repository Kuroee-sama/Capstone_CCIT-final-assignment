package transaction.Group8.controller;

import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import transaction.Group8.dto.AuthResponse;
import transaction.Group8.dto.KaryawanRegisterRequest;
import transaction.Group8.dto.LoginRequest;
import transaction.Group8.service.AuthService;

import java.util.HashMap;
import java.util.Map;

/**
 * Controller untuk endpoint autentikasi (login dan register)
 * Endpoint ini public dan tidak memerlukan token
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    /**
     * POST /api/auth/register - Registrasi karyawan baru
     * 
     * Request body:
     * {
     * "username": "kasir_baru",
     * "email": "kasir@cafe.com",
     * "password": "password123",
     * "umur": 25,
     * "alamat": "Jakarta",
     * "tglLahir": "1999-01-15",
     * "noTelp": "081234567890"
     * }
     */
    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody KaryawanRegisterRequest request) {
        try {
            AuthResponse response = authService.register(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }

    /**
     * POST /api/auth/login - Login karyawan
     * 
     * Request body:
     * {
     * "username": "kasir_andi",
     * "password": "password123"
     * }
     */
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        try {
            AuthResponse response = authService.login(request);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }
    }

    /**
     * GET /api/auth/health - Health check endpoint
     */
    @GetMapping("/health")
    public ResponseEntity<?> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("message", "Auth service is running");
        return ResponseEntity.ok(response);
    }
}
