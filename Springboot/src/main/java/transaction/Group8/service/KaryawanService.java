package transaction.Group8.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import transaction.Group8.model.Karyawan;
import transaction.Group8.repository.KaryawanRepository;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class KaryawanService {

    private static final int MAX_BULK_SIZE = 5;

    @Autowired
    private KaryawanRepository karyawanRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    // Get all karyawan with pagination
    public Page<Karyawan> getAllKaryawan(Pageable pageable) {
        return karyawanRepository.findAll(pageable);
    }

    // Get all karyawan without pagination
    public List<Karyawan> getAllKaryawan() {
        return karyawanRepository.findAll();
    }

    // Get karyawan by ID
    public Optional<Karyawan> getKaryawanById(Integer id) {
        return karyawanRepository.findById(id);
    }

    // Get karyawan by email
    public Optional<Karyawan> getKaryawanByEmail(String email) {
        return karyawanRepository.findByEmail(email);
    }

    // Get karyawan by username
    public Optional<Karyawan> getKaryawanByUsername(String username) {
        return karyawanRepository.findByUsername(username);
    }

    // Create new karyawan
    @Transactional
    public Karyawan createKaryawan(Karyawan karyawan) {
        if (karyawanRepository.findByEmail(karyawan.getEmail()).isPresent()) {
            throw new IllegalArgumentException("Email already exists: " + karyawan.getEmail());
        }
        if (karyawanRepository.findByUsername(karyawan.getUsername()).isPresent()) {
            throw new IllegalArgumentException("Username already exists: " + karyawan.getUsername());
        }
        if (karyawan.getPassword() != null && !isBcryptHash(karyawan.getPassword())) {
            karyawan.setPassword(passwordEncoder.encode(karyawan.getPassword()));
        }
        return karyawanRepository.save(karyawan);
    }

    // Bulk create karyawan - All or nothing (Transactional)
    @Transactional(rollbackFor = Exception.class)
    public List<Karyawan> bulkCreateKaryawan(List<Karyawan> karyawanList) {
        if (karyawanList.size() > MAX_BULK_SIZE) {
            throw new IllegalArgumentException("Bulk create limit exceeded. Maximum allowed: " + MAX_BULK_SIZE);
        }
        if (karyawanList.isEmpty()) {
            throw new IllegalArgumentException("Karyawan list cannot be empty");
        }

        List<Karyawan> createdKaryawan = new ArrayList<>();
        for (Karyawan karyawan : karyawanList) {
            if (karyawan.getUsername() == null || karyawan.getUsername().isEmpty()) {
                throw new IllegalArgumentException("Username is required for all karyawan");
            }
            if (karyawan.getEmail() == null || karyawan.getEmail().isEmpty()) {
                throw new IllegalArgumentException("Email is required for all karyawan");
            }
            if (karyawan.getPassword() == null || karyawan.getPassword().isEmpty()) {
                throw new IllegalArgumentException("Password is required for all karyawan");
            }

            if (karyawanRepository.findByEmail(karyawan.getEmail()).isPresent()) {
                throw new IllegalArgumentException("Email already exists: " + karyawan.getEmail());
            }
            if (karyawanRepository.findByUsername(karyawan.getUsername()).isPresent()) {
                throw new IllegalArgumentException("Username already exists: " + karyawan.getUsername());
            }
            if (!isBcryptHash(karyawan.getPassword())) {
                karyawan.setPassword(passwordEncoder.encode(karyawan.getPassword()));
            }
            createdKaryawan.add(karyawanRepository.save(karyawan));
        }
        return createdKaryawan;
    }

    // Bulk delete karyawan - All or nothing (Transactional)
    @Transactional(rollbackFor = Exception.class)
    public void bulkDeleteKaryawan(List<Integer> ids) {
        if (ids.size() > MAX_BULK_SIZE) {
            throw new IllegalArgumentException("Bulk delete limit exceeded. Maximum allowed: " + MAX_BULK_SIZE);
        }
        if (ids.isEmpty()) {
            throw new IllegalArgumentException("ID list cannot be empty");
        }

        List<Integer> notFoundIds = new ArrayList<>();
        for (Integer id : ids) {
            if (!karyawanRepository.existsById(id)) {
                notFoundIds.add(id);
            }
        }
        if (!notFoundIds.isEmpty()) {
            throw new RuntimeException("Karyawan not found with ids: " + notFoundIds);
        }

        for (Integer id : ids) {
            karyawanRepository.deleteById(id);
        }
    }

    // Update karyawan
    @Transactional
    public Karyawan updateKaryawan(Integer id, Karyawan karyawanDetails) {
        Karyawan karyawan = karyawanRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Karyawan not found with id: " + id));

        if (karyawanDetails.getUsername() != null) {
            if (!karyawan.getUsername().equals(karyawanDetails.getUsername())
                    && karyawanRepository.findByUsername(karyawanDetails.getUsername()).isPresent()) {
                throw new IllegalArgumentException("Username already exists: " + karyawanDetails.getUsername());
            }
            karyawan.setUsername(karyawanDetails.getUsername());
        }
        if (karyawanDetails.getEmail() != null) {
            if (!karyawan.getEmail().equals(karyawanDetails.getEmail())
                    && karyawanRepository.findByEmail(karyawanDetails.getEmail()).isPresent()) {
                throw new IllegalArgumentException("Email already exists: " + karyawanDetails.getEmail());
            }
            karyawan.setEmail(karyawanDetails.getEmail());
        }
        if (karyawanDetails.getPassword() != null) {
            karyawan.setPassword(isBcryptHash(karyawanDetails.getPassword())
                    ? karyawanDetails.getPassword()
                    : passwordEncoder.encode(karyawanDetails.getPassword()));
        }
        if (karyawanDetails.getUmur() != null) {
            karyawan.setUmur(karyawanDetails.getUmur());
        }
        if (karyawanDetails.getAlamat() != null) {
            karyawan.setAlamat(karyawanDetails.getAlamat());
        }
        if (karyawanDetails.getTglLahir() != null) {
            karyawan.setTglLahir(karyawanDetails.getTglLahir());
        }
        if (karyawanDetails.getNoTelp() != null) {
            karyawan.setNoTelp(karyawanDetails.getNoTelp());
        }
        if (karyawanDetails.getRole() != null) {
            karyawan.setRole(karyawanDetails.getRole());
        }

        return karyawanRepository.save(karyawan);
    }

    private boolean isBcryptHash(String value) {
        return value != null && value.matches("^\\$2[aby]\\$\\d{2}\\$.{53}$");
    }

    // Delete karyawan
    @Transactional
    public void deleteKaryawan(Integer id) {
        Karyawan karyawan = karyawanRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Karyawan not found with id: " + id));
        karyawanRepository.delete(karyawan);
    }
}
