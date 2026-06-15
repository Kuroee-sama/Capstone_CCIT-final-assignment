package transaction.Group8.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * DTO untuk request login
 */
public class LoginRequest {

    @NotBlank(message = "Username atau email tidak boleh kosong")
    private String username; // Bisa username atau email

    @NotBlank(message = "Password tidak boleh kosong")
    private String password;

    // Constructors
    public LoginRequest() {
    }

    public LoginRequest(String username, String password) {
        this.username = username;
        this.password = password;
    }

    // Getters and Setters
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
