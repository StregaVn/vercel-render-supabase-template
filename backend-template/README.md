# Backend Template

Spring Boot 3.2 backend template for deployment to Render with Supabase PostgreSQL.

## 📁 Structure

```
backend-template/
├── .mvn/                      # Maven wrapper configuration
├── src/
│   ├── main/
│   │   ├── java/com/template/app/
│   │   │   ├── TemplateApplication.java   # Main entry point
│   │   │   ├── api/                       # REST Controllers
│   │   │   ├── app/                       # Business logic (Services)
│   │   │   ├── config/                    # Spring configuration
│   │   │   │   ├── SecurityBeans.java     # Security beans (BCrypt, etc.)
│   │   │   │   └── SupabaseConfig.java    # Supabase configuration
│   │   │   ├── domain/                    # JPA Entities
│   │   │   │   ├── User.java              # User entity (authentication)
│   │   │   │   └── enums/
│   │   │   │       └── UserType.java      # User role enumeration
│   │   │   ├── dto/                       # Data Transfer Objects
│   │   │   ├── security/                  # JWT & Auth infrastructure
│   │   │   │   ├── SecurityConfig.java    # Spring Security config
│   │   │   │   ├── JwtTokenProvider.java  # JWT generation/validation
│   │   │   │   └── ...                    # Other security classes
│   │   │   ├── store/                     # JPA Repositories
│   │   │   └── util/                      # Utility classes
│   │   └── resources/
│   │       ├── application.yml            # Spring Boot configuration
│   │       └── db/migration/              # Flyway database migrations
│   │           └── V1__Initial_schema.sql
│   └── test/                              # Test classes
├── Dockerfile                             # Docker build configuration
├── mvnw                                   # Maven wrapper (Unix)
├── mvnw.cmd                               # Maven wrapper (Windows)
└── pom.xml                                # Maven dependencies
```

## 🚀 Quick Start

### 1. Customize the Template

**a) Update Package Names:**
```bash
# Replace 'com.template.app' with your package (e.g., com.acme.api)
# Use your IDE's refactoring tools or:
find src -type f -name "*.java" -exec sed -i '' 's/com.template.app/com.yourcompany.yourapp/g' {} +
```

**b) Update `pom.xml`:**
```xml
<groupId>com.yourcompany</groupId>
<artifactId>yourapp-backend</artifactId>
<name>Your App Backend</name>
<description>Your app description</description>
```

**c) Rename Main Application Class:**
```bash
mv src/main/java/com/template/app/TemplateApplication.java \
   src/main/java/com/yourcompany/yourapp/YourAppApplication.java
```

**d) Update Database Schema:**
- In `application.yml`: Change `default_schema` to your schema name
- In `User.java` and other entities: Update `@Table(schema = "...")`
- In `db/migration/*.sql`: Use your schema name

### 2. Set Up Local Development

**a) Create `.env` file:**
```bash
DB_URL=jdbc:postgresql://localhost:5433/your_app_db?currentSchema=your_schema
DB_USERNAME=your_app_user
DB_PASSWORD=your_app_pass
DB_POOL_SIZE=10
DB_MIN_IDLE=2

JWT_SECRET=generate-with-openssl-rand-base64-32
JWT_EXPIRATION_MS=86400000

CORS_ALLOWED_ORIGINS=http://localhost:*

SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-publishable-key
SUPABASE_SERVICE_KEY=your-secret-key

SPRING_PROFILES_ACTIVE=dev
```

**b) Start local PostgreSQL (optional for local dev):**
```bash
# Copy docker-compose.yml from templates/
cp ../templates/docker-compose.yml ./
docker-compose up -d
```

**c) Run the application:**
```bash
./mvnw spring-boot:run
```

### 3. Deploy to Render

**a) Ensure files are committed:**
```bash
git add .
git commit -m "Setup backend"
git push
```

**b) Create Render Web Service:**
- Go to [Render Dashboard](https://dashboard.render.com)
- New → Web Service
- Connect your repository
- Configure:
  - **Language:** Docker
  - **Root Directory:** `backend` (if backend is in a subdirectory)
  - **Environment Variables:** See `templates/RENDER_ENV_VARS_TEMPLATE.txt`

**c) Deploy:**
Render will automatically build and deploy using the Dockerfile.

## 📦 Core Features Included

### Authentication & Security
- **JWT-based authentication** with secure cookie handling
- **BCrypt password hashing**
- **Spring Security** with WebFlux (reactive)
- **CORS configuration** for cross-origin requests
- **Supabase JWT validation** (optional)

### Database
- **PostgreSQL** with JPA/Hibernate
- **Flyway migrations** for schema management
- **HikariCP connection pooling** optimized for Supabase
- **UUID primary keys** for better distribution

### API
- **Reactive WebFlux** for non-blocking I/O
- **Validation** with Jakarta Bean Validation
- **Actuator** for health checks (`/actuator/health`)
- **Exception handling** with global error handlers

### Developer Experience
- **Lombok** for reducing boilerplate
- **MapStruct** for DTO/Entity mapping
- **Hot reload** with Spring Boot DevTools
- **Testcontainers** for integration testing

## 🔧 Common Customizations

### Add a New Entity

**1. Create Entity:**
```java
@Entity
@Table(name = "items", schema = "your_schema")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Item {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    private String name;
    private String description;
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
```

**2. Create Repository:**
```java
public interface ItemRepository extends JpaRepository<Item, UUID> {
    List<Item> findByNameContaining(String name);
}
```

**3. Create Service:**
```java
@Service
@RequiredArgsConstructor
public class ItemService {
    private final ItemRepository itemRepository;
    
    public Mono<List<Item>> getAllItems() {
        return Mono.fromCallable(itemRepository::findAll)
            .subscribeOn(Schedulers.boundedElastic());
    }
}
```

**4. Create Controller:**
```java
@RestController
@RequestMapping("/api/items")
@RequiredArgsConstructor
public class ItemController {
    private final ItemService itemService;
    
    @GetMapping
    public Mono<ResponseEntity<List<Item>>> getAllItems() {
        return itemService.getAllItems()
            .map(ResponseEntity::ok);
    }
}
```

**5. Create Migration:**
```sql
-- db/migration/V2__Create_items_table.sql
CREATE TABLE IF NOT EXISTS your_schema.items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Configure Additional Database

To use a different database (e.g., MySQL, MongoDB):

**1. Update dependencies in `pom.xml`:**
```xml
<!-- For MySQL -->
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
</dependency>

<!-- For MongoDB -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-mongodb</artifactId>
</dependency>
```

**2. Update `application.yml`:**
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/mydb
    driver-class-name: com.mysql.cj.jdbc.Driver
```

### Add Email Service

**1. Add dependency:**
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-mail</artifactId>
</dependency>
```

**2. Configure in `application.yml`:**
```yaml
spring:
  mail:
    host: smtp.gmail.com
    port: 587
    username: ${EMAIL_USERNAME}
    password: ${EMAIL_PASSWORD}
    properties:
      mail:
        smtp:
          auth: true
          starttls:
            enable: true
```

**3. Create EmailService:**
```java
@Service
@RequiredArgsConstructor
public class EmailService {
    private final JavaMailSender mailSender;
    
    public void sendEmail(String to, String subject, String body) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(to);
        message.setSubject(subject);
        message.setText(body);
        mailSender.send(message);
    }
}
```

## 📚 Additional Documentation

- **API Documentation:** Add Springdoc OpenAPI for auto-generated API docs
- **Monitoring:** Configure Prometheus metrics export
- **Logging:** Customize logging in `application.yml`
- **Testing:** Use Testcontainers for integration tests

## 🔍 Troubleshooting

### Build Fails
```bash
# Clean and rebuild
./mvnw clean install -DskipTests

# Check Java version
java -version  # Should be 21+
```

### Database Connection Fails
- Check `DB_URL` format matches Supabase connection string
- Verify credentials are correct
- Ensure Supabase allows connections from your IP (or Render IPs)
- Use Transaction mode (port 6543) for Render deployment

### Authentication Issues
- Verify `JWT_SECRET` is set and consistent
- Check BCrypt hash generation
- Review CORS configuration

## 📖 Further Reading

- [Spring Boot Reference](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/)
- [Spring Security Reference](https://docs.spring.io/spring-security/reference/)
- [Flyway Documentation](https://flywaydb.org/documentation/)
- [Render Deployment Guide](../docs/DEPLOYMENT_PLAN.md)
- [Supabase PostgreSQL](https://supabase.com/docs/guides/database)

## 🆘 Support

See `../docs/TROUBLESHOOTING.md` for common issues and solutions.

