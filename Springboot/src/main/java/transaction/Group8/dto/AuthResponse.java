package transaction.Group8.dto;

/**
 * DTO untuk response autentikasi (login/register)
 */
public class AuthResponse {

    private String token;
    private String tokenType = "Bearer";
    private String message;
    private KaryawanInfo karyawan;

    // Inner class untuk karyawan info
    public static class KaryawanInfo {
        private Integer karyawanId;
        private String username;
        private String email;
        private Integer umur;
        private String alamat;
        private String noTelp;
        private String role;

        public KaryawanInfo() {
        }

        public KaryawanInfo(Integer karyawanId, String username, String email) {
            this.karyawanId = karyawanId;
            this.username = username;
            this.email = email;
        }

        // Getters and Setters
        public Integer getKaryawanId() {
            return karyawanId;
        }

        public void setKaryawanId(Integer karyawanId) {
            this.karyawanId = karyawanId;
        }

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getEmail() {
            return email;
        }

        public void setEmail(String email) {
            this.email = email;
        }

        public Integer getUmur() {
            return umur;
        }

        public void setUmur(Integer umur) {
            this.umur = umur;
        }

        public String getAlamat() {
            return alamat;
        }

        public void setAlamat(String alamat) {
            this.alamat = alamat;
        }

        public String getNoTelp() {
            return noTelp;
        }

        public void setNoTelp(String noTelp) {
            this.noTelp = noTelp;
        }

        public String getRole() {
            return role;
        }

        public void setRole(String role) {
            this.role = role;
        }
    }

    // Constructors
    public AuthResponse() {
    }

    public AuthResponse(String token, String message) {
        this.token = token;
        this.message = message;
    }

    public AuthResponse(String token, String message, KaryawanInfo karyawan) {
        this.token = token;
        this.message = message;
        this.karyawan = karyawan;
    }

    // Getters and Setters
    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getTokenType() {
        return tokenType;
    }

    public void setTokenType(String tokenType) {
        this.tokenType = tokenType;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public KaryawanInfo getKaryawan() {
        return karyawan;
    }

    public void setKaryawan(KaryawanInfo karyawan) {
        this.karyawan = karyawan;
    }
}
