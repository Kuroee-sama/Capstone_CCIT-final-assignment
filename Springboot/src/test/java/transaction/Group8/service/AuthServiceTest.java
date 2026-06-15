package transaction.Group8.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;
import transaction.Group8.dto.AuthResponse;
import transaction.Group8.dto.KaryawanRegisterRequest;
import transaction.Group8.dto.LoginRequest;
import transaction.Group8.model.Karyawan;
import transaction.Group8.repository.KaryawanRepository;
import transaction.Group8.security.JwtUtil;

import java.time.LocalDate;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

/**
 * Unit tests untuk AuthService (Karyawan only)
 */
@ExtendWith(MockitoExtension.class)
public class AuthServiceTest {

    @Mock
    private KaryawanRepository karyawanRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtUtil jwtUtil;

    @InjectMocks
    private AuthService authService;

    private Karyawan testKaryawan;
    private KaryawanRegisterRequest registerRequest;
    private LoginRequest loginRequest;

    @BeforeEach
    void setUp() {
        testKaryawan = new Karyawan();
        testKaryawan.setKaryawanId(1);
        testKaryawan.setUsername("testkaryawan");
        testKaryawan.setEmail("test@example.com");
        testKaryawan.setPassword("encodedPassword");
        testKaryawan.setUmur(25);
        testKaryawan.setAlamat("Jakarta");
        testKaryawan.setTglLahir(LocalDate.of(1999, 1, 15));
        testKaryawan.setNoTelp("081234567890");

        registerRequest = new KaryawanRegisterRequest();
        registerRequest.setUsername("newkaryawan");
        registerRequest.setEmail("newkaryawan@example.com");
        registerRequest.setPassword("password123");
        registerRequest.setUmur(25);
        registerRequest.setAlamat("Jakarta");
        registerRequest.setTglLahir(LocalDate.of(1999, 1, 15));
        registerRequest.setNoTelp("081234567890");

        loginRequest = new LoginRequest();
        loginRequest.setUsername("testkaryawan");
        loginRequest.setPassword("password123");
    }

    @Test
    void register_ValidRequest_ReturnsAuthResponse() {
        // Arrange
        when(karyawanRepository.findByEmail(anyString())).thenReturn(Optional.empty());
        when(karyawanRepository.findByUsername(anyString())).thenReturn(Optional.empty());
        when(passwordEncoder.encode(anyString())).thenReturn("encodedPassword");
        when(karyawanRepository.save(any(Karyawan.class))).thenAnswer(invocation -> {
            Karyawan savedKaryawan = invocation.getArgument(0);
            savedKaryawan.setKaryawanId(1);
            return savedKaryawan;
        });
        when(jwtUtil.generateToken(any(Karyawan.class))).thenReturn("jwt.token.here");

        // Act
        AuthResponse response = authService.register(registerRequest);

        // Assert
        assertNotNull(response);
        assertEquals("jwt.token.here", response.getToken());
        assertEquals("Registrasi berhasil", response.getMessage());
        assertNotNull(response.getKaryawan());
        assertEquals("newkaryawan", response.getKaryawan().getUsername());
        verify(karyawanRepository, times(1)).save(any(Karyawan.class));
    }

    @Test
    void register_EmailAlreadyExists_ThrowsException() {
        // Arrange
        when(karyawanRepository.findByEmail(registerRequest.getEmail())).thenReturn(Optional.of(testKaryawan));

        // Act & Assert
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> authService.register(registerRequest));
        assertTrue(exception.getMessage().contains("Email sudah digunakan"));
        verify(karyawanRepository, never()).save(any());
    }

    @Test
    void register_UsernameAlreadyExists_ThrowsException() {
        // Arrange
        when(karyawanRepository.findByEmail(anyString())).thenReturn(Optional.empty());
        when(karyawanRepository.findByUsername(registerRequest.getUsername())).thenReturn(Optional.of(testKaryawan));

        // Act & Assert
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> authService.register(registerRequest));
        assertTrue(exception.getMessage().contains("Username sudah digunakan"));
        verify(karyawanRepository, never()).save(any());
    }

    @Test
    void login_ValidCredentials_ReturnsAuthResponse() {
        // Arrange
        when(karyawanRepository.findByUsername("testkaryawan")).thenReturn(Optional.of(testKaryawan));
        when(passwordEncoder.matches("password123", "encodedPassword")).thenReturn(true);
        when(jwtUtil.generateToken(testKaryawan)).thenReturn("jwt.token.here");

        // Act
        AuthResponse response = authService.login(loginRequest);

        // Assert
        assertNotNull(response);
        assertEquals("jwt.token.here", response.getToken());
        assertEquals("Login berhasil", response.getMessage());
        assertNotNull(response.getKaryawan());
        assertEquals("testkaryawan", response.getKaryawan().getUsername());
    }

    @Test
    void login_InvalidPassword_ThrowsException() {
        // Arrange
        when(karyawanRepository.findByUsername("testkaryawan")).thenReturn(Optional.of(testKaryawan));
        when(passwordEncoder.matches("password123", "encodedPassword")).thenReturn(false);

        // Act & Assert
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> authService.login(loginRequest));
        assertTrue(exception.getMessage().contains("Username/email atau password salah"));
    }

    @Test
    void login_KaryawanNotFound_ThrowsException() {
        // Arrange
        when(karyawanRepository.findByUsername("nonexistent")).thenReturn(Optional.empty());
        when(karyawanRepository.findByEmail("nonexistent")).thenReturn(Optional.empty());

        loginRequest.setUsername("nonexistent");

        // Act & Assert
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> authService.login(loginRequest));
        assertTrue(exception.getMessage().contains("Karyawan tidak ditemukan"));
    }
}
