package transaction.Group8.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import transaction.Group8.model.Karyawan;
import transaction.Group8.repository.KaryawanRepository;

import java.util.Collections;

/**
 * Custom UserDetailsService untuk load karyawan dari database
 * Supports both ADMIN and KARYAWAN roles
 */
@Service
public class CustomUserDetailsService implements UserDetailsService {

        @Autowired
        private KaryawanRepository karyawanRepository;

        @Override
        public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
                Karyawan karyawan = karyawanRepository.findByUsername(username)
                                .orElseGet(() -> karyawanRepository.findByEmail(username).orElse(null));

                if (karyawan == null) {
                        throw new UsernameNotFoundException("Karyawan tidak ditemukan: " + username);
                }

                // Use actual role from database instead of hardcoding KARYAWAN
                String role = karyawan.getRole() != null ? karyawan.getRole().name() : "KARYAWAN";

                return new org.springframework.security.core.userdetails.User(
                                karyawan.getUsername(),
                                karyawan.getPassword(),
                                Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + role)));
        }
}
