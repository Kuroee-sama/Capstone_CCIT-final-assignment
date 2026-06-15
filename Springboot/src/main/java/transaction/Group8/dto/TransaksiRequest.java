package transaction.Group8.dto;

import java.math.BigDecimal;
import java.util.List;

/**
 * DTO untuk request pembuatan transaksi dengan detail
 * Supports both "items" and "details" field names for compatibility
 */
public class TransaksiRequest {

    private List<DetailRequest> items;
    private String metodePembayaran;
    private BigDecimal bayar;

    // Inner class untuk detail request
    public static class DetailRequest {
        private Integer menuId;
        private Integer jumlah;

        public DetailRequest() {
        }

        public DetailRequest(Integer menuId, Integer jumlah) {
            this.menuId = menuId;
            this.jumlah = jumlah;
        }

        public Integer getMenuId() {
            return menuId;
        }

        public void setMenuId(Integer menuId) {
            this.menuId = menuId;
        }

        public Integer getJumlah() {
            return jumlah;
        }

        public void setJumlah(Integer jumlah) {
            this.jumlah = jumlah;
        }
    }

    // Constructors
    public TransaksiRequest() {
    }

    public TransaksiRequest(List<DetailRequest> items) {
        this.items = items;
    }

    // Getters and Setters
    public List<DetailRequest> getItems() {
        return items;
    }

    public void setItems(List<DetailRequest> items) {
        this.items = items;
    }

    // Backward compatibility: "details" maps to "items"
    public List<DetailRequest> getDetails() {
        return items;
    }

    public void setDetails(List<DetailRequest> details) {
        this.items = details;
    }

    public String getMetodePembayaran() {
        return metodePembayaran;
    }

    public void setMetodePembayaran(String metodePembayaran) {
        this.metodePembayaran = metodePembayaran;
    }

    public BigDecimal getBayar() {
        return bayar;
    }

    public void setBayar(BigDecimal bayar) {
        this.bayar = bayar;
    }
}
