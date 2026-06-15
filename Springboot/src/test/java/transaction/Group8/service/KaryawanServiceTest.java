package transaction.Group8.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import transaction.Group8.model.Karyawan;
import transaction.Group8.repository.KaryawanRepository;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Unit tests untuk KaryawanService
 */
@ExtendWith(MockitoExtension.class)
public class KaryawanServiceTest {

    @Mock
    private KaryawanRepository karyawanRepository;

    @InjectMocks
    private KaryawanService karyawanService;

    private Karyawan testKaryawan;

    @BeforeEach
    void setUp() {
        testKaryawan = new Karyawan();
        testKaryawan.setKaryawanId(1);
        testKaryawan.setUsername("testkaryawan");
        testKaryawan.setEmail("karyawan@example.com");
        testKaryawan.setPassword("password123");
        testKaryawan.setUmur(28);
        testKaryawan.setAlamat("Bandung");
        testKaryawan.setTglLahir(LocalDate.of(1996, 5, 20));
        testKaryawan.setNoTelp("081987654321");
    }

    @Test
    void getAllKaryawan_WithPagination_ReturnsPageOfKaryawan() {
        // Arrange
        Pageable pageable = PageRequest.of(0, 5);
        List<Karyawan> karyawanList = Arrays.asList(testKaryawan);
        Page<Karyawan> karyawanPage = new PageImpl<>(karyawanList, pageable, 1);
        when(karyawanRepository.findAll(pageable)).thenReturn(karyawanPage);

        // Act
        Page<Karyawan> result = karyawanService.getAllKaryawan(pageable);

        // Assert
        assertNotNull(result);
        assertEquals(1, result.getTotalElements());
        assertEquals("testkaryawan", result.getContent().get(0).getUsername());
        verify(karyawanRepository, times(1)).findAll(pageable);
    }

    @Test
    void getKaryawanById_ExistingId_ReturnsKaryawan() {
        // Arrange
        when(karyawanRepository.findById(1)).thenReturn(Optional.of(testKaryawan));

        // Act
        Optional<Karyawan> result = karyawanService.getKaryawanById(1);

        // Assert
        assertTrue(result.isPresent());
        assertEquals("testkaryawan", result.get().getUsername());
        verify(karyawanRepository, times(1)).findById(1);
    }

    @Test
    void getKaryawanById_NonExistingId_ReturnsEmpty() {
        // Arrange
        when(karyawanRepository.findById(999)).thenReturn(Optional.empty());

        // Act
        Optional<Karyawan> result = karyawanService.getKaryawanById(999);

        // Assert
        assertFalse(result.isPresent());
        verify(karyawanRepository, times(1)).findById(999);
    }

    @Test
    void createKaryawan_ValidKaryawan_ReturnsCreatedKaryawan() {
        // Arrange
        when(karyawanRepository.findByEmail(testKaryawan.getEmail())).thenReturn(Optional.empty());
        when(karyawanRepository.findByUsername(testKaryawan.getUsername())).thenReturn(Optional.empty());
        when(karyawanRepository.save(any(Karyawan.class))).thenReturn(testKaryawan);

        // Act
        Karyawan result = karyawanService.createKaryawan(testKaryawan);

        // Assert
        assertNotNull(result);
        assertEquals("testkaryawan", result.getUsername());
        verify(karyawanRepository, times(1)).save(testKaryawan);
    }

    @Test
    void createKaryawan_DuplicateEmail_ThrowsException() {
        // Arrange
        when(karyawanRepository.findByEmail(testKaryawan.getEmail())).thenReturn(Optional.of(testKaryawan));

        // Act & Assert
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> karyawanService.createKaryawan(testKaryawan));
        assertTrue(exception.getMessage().contains("Email already exists"));
        verify(karyawanRepository, never()).save(any());
    }

    @Test
    void createKaryawan_DuplicateUsername_ThrowsException() {
        // Arrange
        when(karyawanRepository.findByEmail(testKaryawan.getEmail())).thenReturn(Optional.empty());
        when(karyawanRepository.findByUsername(testKaryawan.getUsername())).thenReturn(Optional.of(testKaryawan));

        // Act & Assert
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> karyawanService.createKaryawan(testKaryawan));
        assertTrue(exception.getMessage().contains("Username already exists"));
        verify(karyawanRepository, never()).save(any());
    }

    @Test
    void updateKaryawan_ExistingKaryawan_ReturnsUpdatedKaryawan() {
        // Arrange
        Karyawan updatedDetails = new Karyawan();
        updatedDetails.setUsername("updatedkaryawan");
        updatedDetails.setAlamat("Jakarta");

        when(karyawanRepository.findById(1)).thenReturn(Optional.of(testKaryawan));
        when(karyawanRepository.findByUsername("updatedkaryawan")).thenReturn(Optional.empty());
        when(karyawanRepository.save(any(Karyawan.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        Karyawan result = karyawanService.updateKaryawan(1, updatedDetails);

        // Assert
        assertEquals("updatedkaryawan", result.getUsername());
        assertEquals("Jakarta", result.getAlamat());
        verify(karyawanRepository, times(1)).save(any(Karyawan.class));
    }

    @Test
    void updateKaryawan_NonExistingKaryawan_ThrowsException() {
        // Arrange
        when(karyawanRepository.findById(999)).thenReturn(Optional.empty());

        // Act & Assert
        RuntimeException exception = assertThrows(
                RuntimeException.class,
                () -> karyawanService.updateKaryawan(999, testKaryawan));
        assertTrue(exception.getMessage().contains("Karyawan not found"));
    }

    @Test
    void deleteKaryawan_ExistingKaryawan_DeletesSuccessfully() {
        // Arrange
        when(karyawanRepository.findById(1)).thenReturn(Optional.of(testKaryawan));
        doNothing().when(karyawanRepository).delete(testKaryawan);

        // Act
        karyawanService.deleteKaryawan(1);

        // Assert
        verify(karyawanRepository, times(1)).delete(testKaryawan);
    }

    @Test
    void deleteKaryawan_NonExistingKaryawan_ThrowsException() {
        // Arrange
        when(karyawanRepository.findById(999)).thenReturn(Optional.empty());

        // Act & Assert
        RuntimeException exception = assertThrows(
                RuntimeException.class,
                () -> karyawanService.deleteKaryawan(999));
        assertTrue(exception.getMessage().contains("Karyawan not found"));
    }

    @Test
    void bulkCreateKaryawan_ExceedsLimit_ThrowsException() {
        // Arrange - Create 6 karyawan to exceed limit
        List<Karyawan> karyawanList = new ArrayList<>();
        for (int i = 1; i <= 6; i++) {
            Karyawan k = new Karyawan("k" + i, "k" + i + "@test.com", "password");
            karyawanList.add(k);
        }

        // Act & Assert
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> karyawanService.bulkCreateKaryawan(karyawanList));
        assertTrue(exception.getMessage().contains("Bulk create limit exceeded"));
    }
}
