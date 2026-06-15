package transaction.Group8.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import transaction.Group8.dto.AuthResponse;
import transaction.Group8.dto.KaryawanRegisterRequest;
import transaction.Group8.dto.LoginRequest;
import transaction.Group8.model.Karyawan;
import transaction.Group8.model.Role;
import transaction.Group8.repository.KaryawanRepository;
import transaction.Group8.security.JwtUtil;

/**
 * Service untuk handle autentikasi (login dan register) untuk Karyawan
 */
@Service
public class AuthService {

    @Autowired
    private KaryawanRepository karyawanRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    /**
     * Register karyawan baru
     */
    @Transactional
    public AuthResponse register(KaryawanRegisterRequest request) {
        // Check apakah email sudah digunakan
        if (karyawanRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new IllegalArgumentException("Email sudah digunakan: " + request.getEmail());
        }

        // Check apakah username sudah digunakan
        if (karyawanRepository.findByUsername(request.getUsername()).isPresent()) {
            throw new IllegalArgumentException("Username sudah digunakan: " + request.getUsername());
        }

        // Buat karyawan baru
        Karyawan karyawan = new Karyawan();
        karyawan.setUsername(request.getUsername());
        karyawan.setEmail(request.getEmail());
        karyawan.setPassword(passwordEncoder.encode(request.getPassword()));
        karyawan.setUmur(request.getUmur());
        karyawan.setAlamat(request.getAlamat());
        karyawan.setTglLahir(request.getTglLahir());
        karyawan.setNoTelp(request.getNoTelp());
        // Public registration always creates KARYAWAN role
        // ADMIN accounts must be created by existing ADMINs only
        karyawan.setRole(Role.KARYAWAN);

        Karyawan savedKaryawan = karyawanRepository.save(karyawan);

        // Generate token
        String token = jwtUtil.generateToken(savedKaryawan);

        // Build response
        AuthResponse.KaryawanInfo karyawanInfo = buildKaryawanInfo(savedKaryawan);
        return new AuthResponse(token, "Registrasi berhasil", karyawanInfo);
    }

    /**
     * Login karyawan
     */
    public AuthResponse login(LoginRequest request) {
        // Cari karyawan
        Karyawan karyawan = karyawanRepository.findByUsername(request.getUsername())
                .orElseGet(() -> karyawanRepository.findByEmail(request.getUsername()).orElse(null));

        if (karyawan == null) {
            throw new IllegalArgumentException("Karyawan tidak ditemukan");
        }

        // Verify password
        if (!passwordEncoder.matches(request.getPassword(), karyawan.getPassword())) {
            throw new IllegalArgumentException("Username/email atau password salah");
        }

        // Generate token
        String token = jwtUtil.generateToken(karyawan);

        // Build response
        AuthResponse.KaryawanInfo karyawanInfo = buildKaryawanInfo(karyawan);
        return new AuthResponse(token, "Login berhasil", karyawanInfo);
    }

    private AuthResponse.KaryawanInfo buildKaryawanInfo(Karyawan karyawan) {
        AuthResponse.KaryawanInfo info = new AuthResponse.KaryawanInfo();
        info.setKaryawanId(karyawan.getKaryawanId());
        info.setUsername(karyawan.getUsername());
        info.setEmail(karyawan.getEmail());
        info.setUmur(karyawan.getUmur());
        info.setAlamat(karyawan.getAlamat());
        info.setNoTelp(karyawan.getNoTelp());
        info.setRole(karyawan.getRole() != null ? karyawan.getRole().name() : "KARYAWAN");
        return info;
    }
}
