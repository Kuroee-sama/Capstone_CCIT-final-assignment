package transaction.Group8.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Menyajikan file gambar menu melalui Spring Boot.
 *
 * Database hanya menyimpan nama file pada kolom `menu.gambar`, sedangkan file fisik
 * berada di CodeIgniter4/public/uploads/menu. Resource handler ini membuat file
 * tersebut bisa diakses dari Flutter melalui:
 * http://localhost:8080/uploads/menu/{nama_file}
 */
@Configuration
public class StaticResourceConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        Path springDir = Paths.get(System.getProperty("user.dir")).toAbsolutePath();
        Path localUploads = springDir.resolve("uploads");
        Path ci4Uploads = springDir.getParent() == null
                ? springDir.resolve("CodeIgniter4").resolve("public").resolve("uploads")
                : springDir.getParent().resolve("CodeIgniter4").resolve("public").resolve("uploads");

        registry.addResourceHandler("/uploads/**")
                .addResourceLocations(
                        localUploads.toUri().toString(),
                        ci4Uploads.toUri().toString(),
                        "classpath:/static/uploads/"
                );
    }
}
