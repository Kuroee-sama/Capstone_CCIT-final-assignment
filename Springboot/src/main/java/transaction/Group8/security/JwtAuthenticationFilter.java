package transaction.Group8.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;

/**
 * Filter untuk mengextract dan memvalidasi JWT token dari setiap request
 * Supports role-based authentication for Customer and Karyawan
 */
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private CustomUserDetailsService userDetailsService;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        final String authorizationHeader = request.getHeader("Authorization");

        String username = null;
        String jwt = null;
        String role = null;

        // Check apakah header Authorization ada dan dimulai dengan "Bearer "
        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            jwt = authorizationHeader.substring(7);
            try {
                username = jwtUtil.extractUsername(jwt);
                role = jwtUtil.extractRole(jwt);
            } catch (Exception e) {
                // Token tidak valid, lanjutkan tanpa authentication
                logger.warn("JWT Token tidak valid: " + e.getMessage());
            }
        }

        // Jika username ditemukan dan belum ada authentication di context
        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            // Validate token
            if (jwtUtil.validateToken(jwt, username)) {
                // Create authentication with role from token
                String authority = "ROLE_" + (role != null ? role : "KARYAWAN");

                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                        username,
                        null,
                        Collections.singletonList(new SimpleGrantedAuthority(authority)));

                // Store additional info in details
                authToken.setDetails(new JwtAuthenticationDetails(
                        new WebAuthenticationDetailsSource().buildDetails(request),
                        jwt,
                        jwtUtil.extractId(jwt),
                        role));

                SecurityContextHolder.getContext().setAuthentication(authToken);
            }
        }

        filterChain.doFilter(request, response);
    }

    /**
     * Custom authentication details to store JWT info
     */
    public static class JwtAuthenticationDetails {
        private final Object webDetails;
        private final String token;
        private final Integer userId;
        private final String role;

        public JwtAuthenticationDetails(Object webDetails, String token, Integer userId, String role) {
            this.webDetails = webDetails;
            this.token = token;
            this.userId = userId;
            this.role = role;
        }

        public Object getWebDetails() {
            return webDetails;
        }

        public String getToken() {
            return token;
        }

        public Integer getUserId() {
            return userId;
        }

        public String getRole() {
            return role;
        }
    }
}
