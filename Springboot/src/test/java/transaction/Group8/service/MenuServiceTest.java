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
import transaction.Group8.model.Menu;
import transaction.Group8.repository.MenuRepository;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Unit tests untuk MenuService
 */
@ExtendWith(MockitoExtension.class)
public class MenuServiceTest {

    @Mock
    private MenuRepository menuRepository;

    @InjectMocks
    private MenuService menuService;

    private Menu testMenu;

    @BeforeEach
    void setUp() {
        testMenu = new Menu();
        testMenu.setMenuId(1);
        testMenu.setNamaItem("Nasi Goreng");
        testMenu.setKategori(Menu.Kategori.makanan);
        testMenu.setHarga(new BigDecimal("25000.00"));
        testMenu.setDeskripsi("Nasi goreng spesial dengan telur");
        testMenu.setStok(50);
    }

    @Test
    void getAllMenu_WithPagination_ReturnsPageOfMenu() {
        // Arrange
        Pageable pageable = PageRequest.of(0, 5);
        List<Menu> menuList = Arrays.asList(testMenu);
        Page<Menu> menuPage = new PageImpl<>(menuList, pageable, 1);
        when(menuRepository.findAll(pageable)).thenReturn(menuPage);

        // Act
        Page<Menu> result = menuService.getAllMenu(pageable);

        // Assert
        assertNotNull(result);
        assertEquals(1, result.getTotalElements());
        assertEquals("Nasi Goreng", result.getContent().get(0).getNamaItem());
        verify(menuRepository, times(1)).findAll(pageable);
    }

    @Test
    void getMenuById_ExistingId_ReturnsMenu() {
        // Arrange
        when(menuRepository.findById(1)).thenReturn(Optional.of(testMenu));

        // Act
        Optional<Menu> result = menuService.getMenuById(1);

        // Assert
        assertTrue(result.isPresent());
        assertEquals("Nasi Goreng", result.get().getNamaItem());
        assertEquals(Menu.Kategori.makanan, result.get().getKategori());
        verify(menuRepository, times(1)).findById(1);
    }

    @Test
    void getMenuById_NonExistingId_ReturnsEmpty() {
        // Arrange
        when(menuRepository.findById(999)).thenReturn(Optional.empty());

        // Act
        Optional<Menu> result = menuService.getMenuById(999);

        // Assert
        assertFalse(result.isPresent());
        verify(menuRepository, times(1)).findById(999);
    }

    @Test
    void createMenu_ValidMenu_ReturnsCreatedMenu() {
        // Arrange
        when(menuRepository.findByNamaItem(testMenu.getNamaItem())).thenReturn(Optional.empty());
        when(menuRepository.save(any(Menu.class))).thenReturn(testMenu);

        // Act
        Menu result = menuService.createMenu(testMenu);

        // Assert
        assertNotNull(result);
        assertEquals("Nasi Goreng", result.getNamaItem());
        verify(menuRepository, times(1)).save(testMenu);
    }

    @Test
    void createMenu_DuplicateNamaItem_ThrowsException() {
        // Arrange
        when(menuRepository.findByNamaItem(testMenu.getNamaItem())).thenReturn(Optional.of(testMenu));

        // Act & Assert
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> menuService.createMenu(testMenu));
        assertTrue(exception.getMessage().contains("Menu item already exists"));
        verify(menuRepository, never()).save(any());
    }

    @Test
    void createMenu_MissingNamaItem_ThrowsException() {
        // Arrange
        Menu invalidMenu = new Menu();
        invalidMenu.setKategori(Menu.Kategori.makanan);
        invalidMenu.setHarga(new BigDecimal("10000"));

        // Act & Assert
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> menuService.createMenu(invalidMenu));
        assertTrue(exception.getMessage().contains("Nama item is required"));
    }

    @Test
    void createMenu_MissingKategori_ThrowsException() {
        // Arrange
        Menu invalidMenu = new Menu();
        invalidMenu.setNamaItem("Test Item");
        invalidMenu.setHarga(new BigDecimal("10000"));

        // Act & Assert
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> menuService.createMenu(invalidMenu));
        assertTrue(exception.getMessage().contains("Kategori is required"));
    }

    @Test
    void updateMenu_ExistingMenu_ReturnsUpdatedMenu() {
        // Arrange
        Menu updatedDetails = new Menu();
        updatedDetails.setNamaItem("Nasi Goreng Special");
        updatedDetails.setHarga(new BigDecimal("30000.00"));

        when(menuRepository.findById(1)).thenReturn(Optional.of(testMenu));
        when(menuRepository.findByNamaItem("Nasi Goreng Special")).thenReturn(Optional.empty());
        when(menuRepository.save(any(Menu.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        Menu result = menuService.updateMenu(1, updatedDetails);

        // Assert
        assertEquals("Nasi Goreng Special", result.getNamaItem());
        assertEquals(new BigDecimal("30000.00"), result.getHarga());
        verify(menuRepository, times(1)).save(any(Menu.class));
    }

    @Test
    void updateMenu_NonExistingMenu_ThrowsException() {
        // Arrange
        when(menuRepository.findById(999)).thenReturn(Optional.empty());

        // Act & Assert
        RuntimeException exception = assertThrows(
                RuntimeException.class,
                () -> menuService.updateMenu(999, testMenu));
        assertTrue(exception.getMessage().contains("Menu not found"));
    }

    @Test
    void updateStok_ValidStok_ReturnsUpdatedMenu() {
        // Arrange
        when(menuRepository.findById(1)).thenReturn(Optional.of(testMenu));
        when(menuRepository.save(any(Menu.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        Menu result = menuService.updateStok(1, 100);

        // Assert
        assertEquals(100, result.getStok());
        verify(menuRepository, times(1)).save(any(Menu.class));
    }

    @Test
    void updateStok_NegativeStok_ThrowsException() {
        // Arrange
        when(menuRepository.findById(1)).thenReturn(Optional.of(testMenu));

        // Act & Assert
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> menuService.updateStok(1, -5));
        assertTrue(exception.getMessage().contains("Stok cannot be negative"));
    }

    @Test
    void kurangiStok_SufficientStock_ReducesStock() {
        // Arrange
        testMenu.setStok(50);
        when(menuRepository.findById(1)).thenReturn(Optional.of(testMenu));
        when(menuRepository.save(any(Menu.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        Menu result = menuService.kurangiStok(1, 10);

        // Assert
        assertEquals(40, result.getStok());
        verify(menuRepository, times(1)).save(any(Menu.class));
    }

    @Test
    void kurangiStok_InsufficientStock_ThrowsException() {
        // Arrange
        testMenu.setStok(5);
        when(menuRepository.findById(1)).thenReturn(Optional.of(testMenu));

        // Act & Assert
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> menuService.kurangiStok(1, 10));
        assertTrue(exception.getMessage().contains("Stok tidak mencukupi"));
    }

    @Test
    void tambahStok_ValidJumlah_IncreasesStock() {
        // Arrange
        testMenu.setStok(50);
        when(menuRepository.findById(1)).thenReturn(Optional.of(testMenu));
        when(menuRepository.save(any(Menu.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        Menu result = menuService.tambahStok(1, 20);

        // Assert
        assertEquals(70, result.getStok());
        verify(menuRepository, times(1)).save(any(Menu.class));
    }

    @Test
    void deleteMenu_ExistingMenu_DeletesSuccessfully() {
        // Arrange
        when(menuRepository.findById(1)).thenReturn(Optional.of(testMenu));
        doNothing().when(menuRepository).delete(testMenu);

        // Act
        menuService.deleteMenu(1);

        // Assert
        verify(menuRepository, times(1)).delete(testMenu);
    }

    @Test
    void deleteMenu_NonExistingMenu_ThrowsException() {
        // Arrange
        when(menuRepository.findById(999)).thenReturn(Optional.empty());

        // Act & Assert
        RuntimeException exception = assertThrows(
                RuntimeException.class,
                () -> menuService.deleteMenu(999));
        assertTrue(exception.getMessage().contains("Menu not found"));
    }

    @Test
    void bulkCreateMenu_ExceedsLimit_ThrowsException() {
        // Arrange
        List<Menu> menuList = Arrays.asList(
                new Menu("Item1", Menu.Kategori.makanan, new BigDecimal("10000"), "Desc", 10),
                new Menu("Item2", Menu.Kategori.makanan, new BigDecimal("10000"), "Desc", 10),
                new Menu("Item3", Menu.Kategori.minuman, new BigDecimal("10000"), "Desc", 10),
                new Menu("Item4", Menu.Kategori.minuman, new BigDecimal("10000"), "Desc", 10),
                new Menu("Item5", Menu.Kategori.makanan, new BigDecimal("10000"), "Desc", 10),
                new Menu("Item6", Menu.Kategori.makanan, new BigDecimal("10000"), "Desc", 10) // 6th item exceeds limit
        );

        // Act & Assert
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> menuService.bulkCreateMenu(menuList));
        assertTrue(exception.getMessage().contains("Bulk create limit exceeded"));
    }
}
