# 💡 Knowledge Base - Lessons Learned

This document contains real-world solutions from actual production deployments. These lessons saved hours of debugging.

---

## 🔧 Critical Configuration Issues

### Issue #1: MaxClientsInSessionMode Error

**Problem:**
```
FATAL: MaxClientsInSessionMode: max clients reached
```

**Cause:** Supabase Session mode (port 5432) has strict connection limits (~15-20 connections max)

**Solution:** Use **Transaction mode** (port 6543) instead

```bash
# ❌ Session mode - TOO RESTRICTIVE
DB_URL=jdbc:postgresql://host:5432/postgres

# ✅ Transaction mode - RECOMMENDED  
DB_URL=jdbc:postgresql://host:6543/postgres
```

**Why it works:** Transaction mode pools connections more efficiently, supporting 200+ concurrent connections.

**Configuration:**
```yaml
# application-render.yml
spring:
  datasource:
    url: ${DB_URL}  # Must use port 6543
    hikari:
      maximum-pool-size: 10
      minimum-idle: 2
```

---

### Issue #2: Cookies Not Being Set (Login Success but No Authentication)

**Problem:** Login returns 200 with `{success: true}` but user remains unauthenticated. Browser doesn't store the cookie.

**Cause:** Cross-origin HTTPS requires specific cookie settings.

**Solution:** Configure cookies for cross-origin HTTPS

```java
// ❌ WRONG - Works locally but fails in production
ResponseCookie cookie = ResponseCookie.from(TOKEN_COOKIE_NAME, token)
    .httpOnly(true)
    .secure(false)      // ❌ Must be true for HTTPS
    .sameSite("Lax")    // ❌ Doesn't work cross-origin
    .build();

// ✅ CORRECT - Works with Vercel + Render
ResponseCookie cookie = ResponseCookie.from(TOKEN_COOKIE_NAME, token)
    .httpOnly(true)
    .secure(true)       // ✅ Required for HTTPS
    .sameSite("None")   // ✅ Required for cross-origin with secure=true
    .path("/")
    .maxAge(Duration.ofHours(24))
    .build();
```

**Key Points:**
- `secure(true)` - Required when frontend uses HTTPS (Vercel always uses HTTPS)
- `sameSite("None")` - Required for cookies to work across different domains
- Must be applied to ALL cookie operations (login, refresh, logout)

---

### Issue #3: 404 on Frontend Routes (e.g., `/login`)

**Problem:** Direct navigation to `/login` returns 404. Clicking links works, but refresh breaks.

**Cause:** Vercel doesn't know it's a Single Page Application (SPA). It tries to find `/login` as a physical file.

**Solution:** Add `vercel.json` to the **frontend directory** (not root!)

```json
// frontend-template/vercel.json
{
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

**Important:** 
- File must be in `frontend-template/` directory
- Vercel Root Directory must be set to `frontend-template`
- This tells Vercel to serve `index.html` for all routes

---

### Issue #4: CORS Errors in Browser Console

**Problem:**
```
Access to fetch at 'https://backend.onrender.com/api/auth/login' 
from origin 'https://frontend.vercel.app' has been blocked by CORS policy
```

**Cause:** Backend doesn't allow requests from the frontend domain.

**Solution:** Configure CORS to allow your frontend

```java
// SecurityConfig.java or CorsConfig.java
@Bean
public CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration configuration = new CorsConfiguration();
    
    // Use patterns to support localhost (any port) and Vercel
    String allowedOrigins = System.getenv().getOrDefault(
        "CORS_ALLOWED_ORIGINS",
        "http://localhost:*,https://*.vercel.app"
    );
    
    configuration.setAllowedOriginPatterns(
        Arrays.asList(allowedOrigins.split(","))
    );
    configuration.setAllowedMethods(
        Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS")
    );
    configuration.setAllowedHeaders(
        Arrays.asList("Authorization", "Content-Type", "X-Requested-With")
    );
    configuration.setAllowCredentials(true);  // Required for cookies
    
    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", configuration);
    return source;
}
```

**Environment Variable:**
```bash
CORS_ALLOWED_ORIGINS=http://localhost:*,https://your-app.vercel.app,https://*.vercel.app
```

---

### Issue #5: Vercel Deployment Not Triggering

**Problem:** Git push to `main` doesn't trigger Vercel deployment.

**Cause:** Git commit author doesn't match Vercel account or manual deployment required.

**Solution:** 

1. **Check git author:**
```bash
git config user.name
git config user.email
```

2. **Update if needed:**
```bash
git config user.name "your-vercel-username"
git config user.email "your-vercel-email"
```

3. **Or manually trigger:**
- Go to Vercel Dashboard → Deployments
- Click three-dot menu → "Redeploy"

---

### Issue #6: Password Hash Doesn't Match

**Problem:** Login fails with "Invalid password" even though password is correct.

**Cause:** Password hash was generated with a different BCrypt implementation or has wrong rounds.

**Solution:** Generate hash using the application's `PasswordEncoder`

```bash
cd backend-template
./mvnw exec:java -Dexec.mainClass="com.template.app.util.PasswordHashGenerator"
```

**Or create a test class:**
```java
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class TestHash {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String password = "YourPassword123!";
        String hash = encoder.encode(password);
        
        System.out.println("Password: " + password);
        System.out.println("Hash: " + hash);
        System.out.println("Matches: " + encoder.matches(password, hash));
    }
}
```

**Important:** Always use the same `BCryptPasswordEncoder` configuration as your application.

---

### Issue #7: Render Build Fails - "mvnw: No such file"

**Problem:** Render build fails with `./mvnw: No such file or directory`

**Cause:** `mvnw` and `mvnw.cmd` are in `.gitignore`

**Solution:** 

1. **Remove from `.gitignore`:**
```bash
# .gitignore
# Remove these lines:
# mvnw
# mvnw.cmd
```

2. **Add to git:**
```bash
git add backend-template/mvnw backend-template/mvnw.cmd
git commit -m "Add Maven wrapper for Render deployment"
git push
```

3. **Alternative - Use Docker:**
Better approach is to use Docker (already in template):
```dockerfile
FROM maven:3.8.7-openjdk-21 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM openjdk:21-jdk-slim
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

---

### Issue #8: Render Build Fails - "JAVA_HOME is not set"

**Problem:** Render build fails because Java is not available.

**Cause:** Render doesn't have Java in the default environment.

**Solution:** Use Docker (already configured in template)

**Render Settings:**
- **Environment**: Docker
- **Dockerfile Path**: `./backend-template/Dockerfile`
- **Docker Build Context**: `.` (root)

Docker handles Java installation automatically.

---

## 🎯 Best Practices

### 1. Environment-Specific Configuration

Use Spring profiles:
- `application.yml` - defaults
- `application-local.yml` - local development
- `application-render.yml` - Render production

```yaml
# application.yml
spring:
  profiles:
    active: ${SPRING_PROFILES_ACTIVE:local}
```

### 2. Connection Pool Sizing

```yaml
spring:
  datasource:
    hikari:
      # Supabase Free tier: 60 total connections
      # Reserve some for direct connections, backups, etc.
      maximum-pool-size: 10  # Conservative
      minimum-idle: 2        # Keep some warm
      connection-timeout: 30000
      max-lifetime: 1800000  # 30 minutes
      idle-timeout: 600000   # 10 minutes
```

### 3. Secure Password Requirements

Enforce strong passwords in code:
```java
public class PasswordValidator {
    public static void validatePassword(String password) {
        if (password.length() < 12) {
            throw new IllegalArgumentException("Password must be at least 12 characters");
        }
        if (!password.matches(".*[A-Z].*")) {
            throw new IllegalArgumentException("Password must contain uppercase letter");
        }
        if (!password.matches(".*[a-z].*")) {
            throw new IllegalArgumentException("Password must contain lowercase letter");
        }
        if (!password.matches(".*\\d.*")) {
            throw new IllegalArgumentException("Password must contain a number");
        }
        if (!password.matches(".*[!@#$%^&*].*")) {
            throw new IllegalArgumentException("Password must contain special character");
        }
    }
}
```

### 4. JWT Secret Generation

Always use a cryptographically secure random secret:
```bash
# Generate 32-byte base64 secret
openssl rand -base64 32

# Or 64-byte for extra security
openssl rand -base64 64
```

**Never use:**
- Predictable strings
- Dictionary words
- Short secrets (< 32 bytes)

### 5. Error Handling

Don't expose sensitive information:
```java
// ❌ BAD - Exposes internal details
return ResponseEntity.status(500).body("Database error: " + ex.getMessage());

// ✅ GOOD - Generic message, log details
log.error("Database error", ex);
return ResponseEntity.status(500).body("An error occurred. Please try again.");
```

### 6. Database Migrations

Follow Flyway naming conventions:
```
V1__Initial_schema.sql
V2__Add_users_table.sql
V3__Add_indexes.sql
```

Rules:
- Version numbers must be unique and sequential
- Never modify existing migrations
- Test migrations locally first
- Include rollback plan

### 7. Frontend API Configuration

Use environment variables:
```typescript
// config.ts
export const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080';

// api.ts
import { API_BASE_URL } from './config';

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  withCredentials: true,  // Important for cookies
  headers: {
    'Content-Type': 'application/json',
  },
});
```

---

## 📊 Performance Tips

### 1. Database Query Optimization

```java
// ❌ N+1 query problem
List<User> users = userRepository.findAll();
users.forEach(user -> {
    List<Orders> orders = orderRepository.findByUserId(user.getId());
});

// ✅ Use JOIN FETCH
@Query("SELECT u FROM User u LEFT JOIN FETCH u.orders")
List<User> findAllWithOrders();
```

### 2. Connection Pooling

Monitor connection usage:
```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  metrics:
    export:
      enabled: true
```

### 3. Frontend Code Splitting

```typescript
// Lazy load routes
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Reports = lazy(() => import('./pages/Reports'));

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <Routes>
        <Route path="/" element={<Dashboard />} />
        <Route path="/reports" element={<Reports />} />
      </Routes>
    </Suspense>
  );
}
```

---

## 🔒 Security Checklist

- [ ] HTTPS enabled (automatic on Vercel/Render)
- [ ] Secure cookies (httpOnly, secure, sameSite)
- [ ] Strong JWT secret (32+ bytes)
- [ ] Password hashing with BCrypt (cost factor 10+)
- [ ] CORS limited to specific origins
- [ ] Environment variables for secrets
- [ ] SQL injection prevention (JPA/prepared statements)
- [ ] XSS protection headers
- [ ] Rate limiting (optional but recommended)
- [ ] Regular dependency updates

---

## 💰 Cost Optimization

### Free Tier Limits

**Vercel:**
- ✅ Unlimited deployments
- ✅ 100GB bandwidth/month
- ❌ No custom domains on hobby

**Render:**
- ✅ 750 hours/month free (1 always-on service)
- ❌ Sleeps after 15 min inactivity on free tier
- 💡 Use cron job to keep alive: `curl https://your-app.onrender.com/actuator/health`

**Supabase:**
- ✅ 500MB database
- ✅ 2GB bandwidth
- ✅ 50,000 monthly active users
- ❌ Pauses after 1 week inactivity on free tier

### Cost-Effective Scaling

1. Start with free tiers
2. Upgrade Render to $7/month when you need always-on
3. Upgrade Supabase to $25/month when you hit limits
4. Add Vercel Pro ($20/month) for custom domains and more

---

## 🎓 Additional Resources

- [Spring Boot Documentation](https://docs.spring.io/spring-boot/)
- [React Documentation](https://react.dev)
- [Supabase Documentation](https://supabase.com/docs)
- [Render Documentation](https://render.com/docs)
- [Vercel Documentation](https://vercel.com/docs)

---

**This knowledge base is continuously updated with new lessons learned. Contributions welcome!**

