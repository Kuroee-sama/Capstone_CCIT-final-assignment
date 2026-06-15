package transaction.Group8.security;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;
import transaction.Group8.model.Karyawan;

import java.util.Base64;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests untuk JwtUtil (Karyawan only)
 */
@ExtendWith(MockitoExtension.class)
public class JwtUtilTest {

    private JwtUtil jwtUtil;
    private Karyawan testKaryawan;
    private String validToken;

    @BeforeEach
    void setUp() {
        jwtUtil = new JwtUtil();

        // Set properties via reflection
        String secretKey = Base64.getEncoder().encodeToString(
                "thisisaverysecuresecretkeyforsigning12345678901234567890".getBytes());
        ReflectionTestUtils.setField(jwtUtil, "jwtSecret", secretKey);
        ReflectionTestUtils.setField(jwtUtil, "jwtExpiration", 86400000L); // 24 hours

        testKaryawan = new Karyawan();
        testKaryawan.setKaryawanId(1);
        testKaryawan.setUsername("testkaryawan");
        testKaryawan.setEmail("test@example.com");

        // Generate valid token for tests
        validToken = jwtUtil.generateToken(testKaryawan);
    }

    @Test
    void generateToken_ValidKaryawan_ReturnsToken() {
        // Act
        String token = jwtUtil.generateToken(testKaryawan);

        // Assert
        assertNotNull(token);
        assertFalse(token.isEmpty());
        assertTrue(token.split("\\.").length == 3); // JWT has 3 parts
    }

    @Test
    void extractUsername_ValidToken_ReturnsUsername() {
        // Act
        String username = jwtUtil.extractUsername(validToken);

        // Assert
        assertEquals("testkaryawan", username);
    }

    @Test
    void extractId_ValidToken_ReturnsKaryawanId() {
        // Act
        Integer karyawanId = jwtUtil.extractId(validToken);

        // Assert
        assertEquals(1, karyawanId);
    }

    @Test
    void extractEmail_ValidToken_ReturnsEmail() {
        // Act
        String email = jwtUtil.extractEmail(validToken);

        // Assert
        assertEquals("test@example.com", email);
    }

    @Test
    void extractRole_ValidToken_ReturnsKaryawanRole() {
        // Act
        String role = jwtUtil.extractRole(validToken);

        // Assert
        assertEquals("KARYAWAN", role);
    }

    @Test
    void isKaryawan_ValidToken_ReturnsTrue() {
        // Act
        boolean isKaryawan = jwtUtil.isKaryawan(validToken);

        // Assert
        assertTrue(isKaryawan);
    }

    @Test
    void validateToken_ValidToken_ReturnsTrue() {
        // Act
        Boolean isValid = jwtUtil.validateToken(validToken, "testkaryawan");

        // Assert
        assertTrue(isValid);
    }

    @Test
    void validateToken_WrongUsername_ReturnsFalse() {
        // Act
        Boolean isValid = jwtUtil.validateToken(validToken, "wrongkaryawan");

        // Assert
        assertFalse(isValid);
    }

    @Test
    void validateToken_InvalidToken_ReturnsFalse() {
        // Act
        Boolean isValid = jwtUtil.validateToken("invalid.token.here");

        // Assert
        assertFalse(isValid);
    }

    @Test
    void validateToken_ExpiredToken_ReturnsFalse() {
        // Arrange - Create JWT util with 1ms expiration
        JwtUtil shortExpJwtUtil = new JwtUtil();
        String secretKey = Base64.getEncoder().encodeToString(
                "thisisaverysecuresecretkeyforsigning12345678901234567890".getBytes());
        ReflectionTestUtils.setField(shortExpJwtUtil, "jwtSecret", secretKey);
        ReflectionTestUtils.setField(shortExpJwtUtil, "jwtExpiration", 1L); // 1ms

        String token = shortExpJwtUtil.generateToken(testKaryawan);

        // Wait for expiration
        try {
            Thread.sleep(10);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        // Act
        Boolean isValid = shortExpJwtUtil.validateToken(token);

        // Assert
        assertFalse(isValid);
    }

    @Test
    void extractExpiration_ValidToken_ReturnsDate() {
        // Act
        var expiration = jwtUtil.extractExpiration(validToken);

        // Assert
        assertNotNull(expiration);
        assertTrue(expiration.getTime() > System.currentTimeMillis());
    }
}
