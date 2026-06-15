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
import transaction.Group8.model.DetailTransaksi;
import transaction.Group8.model.Karyawan;
import transaction.Group8.model.Menu;
import transaction.Group8.model.Transaksi;
import transaction.Group8.repository.DetailTransaksiRepository;
import transaction.Group8.repository.KaryawanRepository;
import transaction.Group8.repository.MenuRepository;
import transaction.Group8.repository.TransaksiRepository;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Unit tests untuk TransaksiService (Karyawan only)
 */
@ExtendWith(MockitoExtension.class)
public class TransaksiServiceTest {

    @Mock
    private TransaksiRepository transaksiRepository;

    @Mock
    private DetailTransaksiRepository detailTransaksiRepository;

    @Mock
    private KaryawanRepository karyawanRepository;

    @Mock
    private MenuRepository menuRepository;

    @InjectMocks
    private TransaksiService transaksiService;

    private Karyawan testKaryawan;
    private Menu testMenu;
    private Menu testMenu2;
    private Transaksi testTransaksi;

    @BeforeEach
    void setUp() {
        testKaryawan = new Karyawan();
        testKaryawan.setKaryawanId(1);
        testKaryawan.setUsername("testkaryawan");

        testMenu = new Menu();
        testMenu.setMenuId(1);
        testMenu.setNamaItem("Nasi Goreng");
        testMenu.setHarga(new BigDecimal("25000"));
        testMenu.setStok(50);

        testMenu2 = new Menu();
        testMenu2.setMenuId(2);
        testMenu2.setNamaItem("Mie Goreng");
        testMenu2.setHarga(new BigDecimal("20000"));
        testMenu2.setStok(30);

        testTransaksi = new Transaksi();
        testTransaksi.setTransaksiId(1);
        testTransaksi.setTotalAmount(new BigDecimal("100000"));
        testTransaksi.setKaryawan(testKaryawan);
    }

    @Test
    void getAllTransaksi_WithPagination_ReturnsPageOfTransaksi() {
        // Arrange
        Pageable pageable = PageRequest.of(0, 5);
        List<Transaksi> transaksiList = Arrays.asList(testTransaksi);
        Page<Transaksi> transaksiPage = new PageImpl<>(transaksiList, pageable, 1);
        when(transaksiRepository.findAll(pageable)).thenReturn(transaksiPage);

        // Act
        Page<Transaksi> result = transaksiService.getAllTransaksi(pageable);

        // Assert
        assertNotNull(result);
        assertEquals(1, result.getTotalElements());
        verify(transaksiRepository, times(1)).findAll(pageable);
    }

    @Test
    void getTransaksiById_ExistingId_ReturnsTransaksi() {
        // Arrange
        when(transaksiRepository.findById(1)).thenReturn(Optional.of(testTransaksi));

        // Act
        Optional<Transaksi> result = transaksiService.getTransaksiById(1);

        // Assert
        assertTrue(result.isPresent());
        assertEquals(new BigDecimal("100000"), result.get().getTotalAmount());
        verify(transaksiRepository, times(1)).findById(1);
    }

    @Test
    void getTransaksiById_NonExistingId_ReturnsEmpty() {
        // Arrange
        when(transaksiRepository.findById(999)).thenReturn(Optional.empty());

        // Act
        Optional<Transaksi> result = transaksiService.getTransaksiById(999);

        // Assert
        assertFalse(result.isPresent());
    }

    @Test
    void createTransaksiWithDetails_ValidData_ReturnsCreatedTransaksi() {
        // Arrange
        when(karyawanRepository.findById(1)).thenReturn(Optional.of(testKaryawan));
        when(menuRepository.findById(1)).thenReturn(Optional.of(testMenu));
        when(menuRepository.findById(2)).thenReturn(Optional.of(testMenu2));
        when(menuRepository.save(any(Menu.class))).thenAnswer(inv -> inv.getArgument(0));
        when(transaksiRepository.save(any(Transaksi.class))).thenAnswer(inv -> {
            Transaksi t = inv.getArgument(0);
            if (t.getTransaksiId() == null) {
                t.setTransaksiId(1);
            }
            return t;
        });
        when(detailTransaksiRepository.save(any(DetailTransaksi.class))).thenAnswer(inv -> {
            DetailTransaksi d = inv.getArgument(0);
            d.setDetailId(1);
            return d;
        });

        List<TransaksiService.DetailRequest> details = Arrays.asList(
                new TransaksiService.DetailRequest(1, 2), // 2x Nasi Goreng = 50000
                new TransaksiService.DetailRequest(2, 1) // 1x Mie Goreng = 20000
        );

        // Act
        Transaksi result = transaksiService.createTransaksiWithDetails(1, details);

        // Assert
        assertNotNull(result);
        assertEquals(new BigDecimal("70000"), result.getTotalAmount());
        assertEquals(48, testMenu.getStok()); // 50 - 2
        assertEquals(29, testMenu2.getStok()); // 30 - 1
        verify(transaksiRepository, times(2)).save(any(Transaksi.class));
        verify(detailTransaksiRepository, times(2)).save(any(DetailTransaksi.class));
    }

    @Test
    void createTransaksiWithDetails_KaryawanNotFound_ThrowsException() {
        // Arrange
        when(karyawanRepository.findById(999)).thenReturn(Optional.empty());

        List<TransaksiService.DetailRequest> details = Arrays.asList(
                new TransaksiService.DetailRequest(1, 2));

        // Act & Assert
        RuntimeException exception = assertThrows(
                RuntimeException.class,
                () -> transaksiService.createTransaksiWithDetails(999, details));
        assertTrue(exception.getMessage().contains("Karyawan not found"));
    }

    @Test
    void createTransaksiWithDetails_EmptyDetails_ThrowsException() {
        // Act & Assert
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> transaksiService.createTransaksiWithDetails(1, Arrays.asList()));
        assertTrue(exception.getMessage().contains("Details tidak boleh kosong"));
    }

    @Test
    void addDetailTransaksi_ValidData_ReducesStockAndCreatesDetail() {
        // Arrange
        when(transaksiRepository.findById(1)).thenReturn(Optional.of(testTransaksi));
        when(menuRepository.findById(1)).thenReturn(Optional.of(testMenu));
        when(menuRepository.save(any(Menu.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(detailTransaksiRepository.save(any(DetailTransaksi.class))).thenAnswer(invocation -> {
            DetailTransaksi detail = invocation.getArgument(0);
            detail.setDetailId(1);
            return detail;
        });
        when(transaksiRepository.save(any(Transaksi.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        DetailTransaksi result = transaksiService.addDetailTransaksi(1, 1, 5);

        // Assert
        assertNotNull(result);
        assertEquals(5, result.getJumlah());
        assertEquals(new BigDecimal("25000"), result.getHarga());
        assertEquals(45, testMenu.getStok()); // Stock reduced from 50 to 45
        verify(menuRepository, times(1)).save(any(Menu.class));
        verify(detailTransaksiRepository, times(1)).save(any(DetailTransaksi.class));
    }

    @Test
    void addDetailTransaksi_InsufficientStock_ThrowsException() {
        // Arrange
        testMenu.setStok(3); // Only 3 items in stock
        when(transaksiRepository.findById(1)).thenReturn(Optional.of(testTransaksi));
        when(menuRepository.findById(1)).thenReturn(Optional.of(testMenu));

        // Act & Assert
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> transaksiService.addDetailTransaksi(1, 1, 10)); // Requesting 10 items
        assertTrue(exception.getMessage().contains("Stok tidak mencukupi"));
    }
}
