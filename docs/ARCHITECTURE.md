# 🏗️ Architecture Documentation

## 📊 System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                          CLIENT                              │
│                      (Web Browser)                           │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTPS
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                    FRONTEND (Vercel)                        │
│  ┌────────────────────────────────────────────────────┐    │
│  │  React 18 + TypeScript + Vite                      │    │
│  │  - Authentication Context                          │    │
│  │  - Protected Routes                                │    │
│  │  - API Client (Axios + withCredentials)           │    │
│  │  - TailwindCSS UI                                 │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  Deployment: Auto-deploy on git push                        │
│  CDN: Global edge network                                   │
│  SSL: Automatic HTTPS                                       │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTPS + Secure Cookies
                       │ (httpOnly, secure, sameSite=None)
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                   BACKEND (Render)                          │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Spring Boot 3.4 + Java 21 + WebFlux              │    │
│  │  ┌──────────────────────────────────────────────┐ │    │
│  │  │  Security Layer                              │ │    │
│  │  │  - JWT Token Provider                        │ │    │
│  │  │  - BCrypt Password Encoding                  │ │    │
│  │  │  - Secure Cookie Management                  │ │    │
│  │  │  - CORS Configuration                        │ │    │
│  │  └──────────────────────────────────────────────┘ │    │
│  │  ┌──────────────────────────────────────────────┐ │    │
│  │  │  API Layer                                   │ │    │
│  │  │  - REST Controllers                          │ │    │
│  │  │  - Request Validation                        │ │    │
│  │  │  - Exception Handling                        │ │    │
│  │  └──────────────────────────────────────────────┘ │    │
│  │  ┌──────────────────────────────────────────────┐ │    │
│  │  │  Business Layer                              │ │    │
│  │  │  - Services                                  │ │    │
│  │  │  - DTOs                                      │ │    │
│  │  └──────────────────────────────────────────────┘ │    │
│  │  ┌──────────────────────────────────────────────┐ │    │
│  │  │  Data Layer                                  │ │    │
│  │  │  - JPA Entities                              │ │    │
│  │  │  - Repositories                              │ │    │
│  │  │  - Flyway Migrations                         │ │    │
│  │  └──────────────────────────────────────────────┘ │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  Deployment: Docker container                                │
│  Health Check: /actuator/health                             │
│  Metrics: Micrometer + Spring Actuator                      │
└──────────────────────┬──────────────────────────────────────┘
                       │ Transaction Mode (port 6543)
                       │ Connection Pool (10 connections)
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                  DATABASE (Supabase)                        │
│  ┌────────────────────────────────────────────────────┐    │
│  │  PostgreSQL 17                                     │    │
│  │  - Custom Schema                                   │    │
│  │  - Row Level Security (optional)                   │    │
│  │  - Connection Pooler (PgBouncer)                   │    │
│  │  - Automatic Backups                               │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  Features: Auth, Storage, Realtime (optional)               │
│  Monitoring: Dashboard with query stats                     │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Request Flow

### 1. Authentication Flow

```
[Browser] → [Vercel] → POST /api/auth/login → [Render]
                                                   ↓
                                              Verify credentials
                                              (BCrypt compare)
                                                   ↓
                                              Generate JWT
                                                   ↓
                                              Set HttpOnly Cookie
                                                   ↓
[Browser] ← [Vercel] ← 200 + Set-Cookie ← [Render]
   ↓
Store cookie
(automatic)
   ↓
Redirect to dashboard
```

### 2. Protected Resource Access

```
[Browser] → GET /api/protected-resource
   ↓ (Cookie automatically attached)
[Vercel] → [Render]
             ↓
        Extract JWT from cookie
             ↓
        Validate JWT signature
             ↓
        Check expiration
             ↓
        Extract user info
             ↓
        Check permissions
             ↓
        Query database
             ↓
[Browser] ← [Vercel] ← 200 + Data ← [Render]
```

---

## 🔐 Security Architecture

### Authentication Chain

```
Request → CookieTokenAuthenticationConverter
           ↓
       Extract JWT from cookie
           ↓
       JwtTokenProvider.validateToken()
           ↓
       Parse claims
           ↓
       Create Authentication object
           ↓
       SecurityContext
           ↓
       Controller (authenticated)
```

### Cookie Security

```java
ResponseCookie.from("token", jwt)
    .httpOnly(true)      // JavaScript cannot access
    .secure(true)        // HTTPS only
    .sameSite("None")    // Cross-origin allowed
    .path("/")           // All paths
    .maxAge(24h)         // 24 hour expiration
```

**Protection Against:**
- ✅ XSS (httpOnly prevents JavaScript access)
- ✅ CSRF (sameSite + custom headers)
- ✅ Man-in-the-middle (secure = HTTPS only)

### Password Security

```
User Password (plaintext)
   ↓
BCryptPasswordEncoder.encode()
   ↓
Hash with salt (10 rounds)
   ↓
Store in database
   ↓
On login: BCrypt.matches(input, stored)
```

**BCrypt Benefits:**
- Automatic salting
- Configurable work factor
- Resistant to rainbow tables
- Slow by design (prevents brute force)

---

## 💾 Data Architecture

### Database Schema Pattern

```sql
-- Custom schema (not public)
CREATE SCHEMA IF NOT EXISTS your_app;
SET search_path TO your_app;

-- Base audit fields pattern
CREATE TABLE base_entity (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);

-- Soft delete pattern
ALTER TABLE entity ADD COLUMN deleted_at TIMESTAMP;
CREATE INDEX idx_entity_not_deleted ON entity(id) WHERE deleted_at IS NULL;
```

### Connection Pooling

```
Application Instances (1-3)
   ↓
HikariCP Pool (10 connections each)
   ↓
Supabase Transaction Pooler (PgBouncer)
   ↓
PostgreSQL (Max 200 connections)
```

**Pool Configuration:**
```yaml
hikari:
  maximum-pool-size: 10      # Max connections per instance
  minimum-idle: 2            # Keep warm connections
  connection-timeout: 30000  # 30 seconds
  max-lifetime: 1800000      # 30 minutes
  idle-timeout: 600000       # 10 minutes
```

---

## 🚀 Deployment Architecture

### CI/CD Pipeline

```
Developer
   ↓
git push origin main
   ↓
GitHub Repository
   ├→ Vercel (Frontend)
   │    ↓
   │  Detect changes in frontend-template/
   │    ↓
   │  npm install
   │    ↓
   │  npm run build
   │    ↓
   │  Deploy to Edge Network
   │    ↓
   │  Update DNS
   │    ↓
   │  Live at https://app.vercel.app
   │
   └→ Render (Backend)
        ↓
      Detect changes in backend-template/
        ↓
      Build Docker image
        ↓
      docker build -f Dockerfile
        ↓
      Run health check
        ↓
      Blue-green deployment
        ↓
      Live at https://app.onrender.com
```

### Docker Build

```dockerfile
# Multi-stage build for optimization

# Stage 1: Build
FROM maven:3.8.7-openjdk-21 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests
# Result: target/app.jar (~50MB)

# Stage 2: Runtime
FROM openjdk:21-jdk-slim
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
# Final image: ~250MB (vs 800MB without multi-stage)
```

---

## 📈 Scalability

### Horizontal Scaling

**Frontend (Vercel):**
- ✅ Automatic CDN distribution
- ✅ Edge caching
- ✅ Infinite scalability
- ✅ Auto-scaling

**Backend (Render):**
- Manual scaling (upgrade plan)
- Load balancer included
- Health checks
- Zero-downtime deployments

**Database (Supabase):**
- Connection pooler handles concurrency
- Read replicas available (Pro plan)
- Automatic backups
- Point-in-time recovery

### Vertical Scaling

**Render Plans:**
- Free: 512MB RAM, 0.1 CPU
- Starter: 512MB RAM, 0.5 CPU ($7/month)
- Standard: 2GB RAM, 1 CPU ($25/month)
- Pro: 4GB RAM, 2 CPU ($85/month)

**Supabase Plans:**
- Free: 500MB DB, 2GB bandwidth
- Pro: 8GB DB, 50GB bandwidth ($25/month)
- Team: 100GB DB, custom ($599/month)

---

## 🎯 Design Patterns

### Frontend Patterns

**1. Context Pattern (Authentication)**
```typescript
// Provides auth state to entire app
<AuthProvider>
  <App />
</AuthProvider>
```

**2. Protected Route Pattern**
```typescript
// Redirects unauthorized users
<Route path="/dashboard" element={
  <ProtectedRoute>
    <Dashboard />
  </ProtectedRoute>
} />
```

**3. API Client Pattern**
```typescript
// Centralized API configuration
export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  withCredentials: true,
});
```

### Backend Patterns

**1. Controller-Service-Repository Pattern**
```
Controller → Service → Repository → Database
  (API)     (Logic)   (Data Access)
```

**2. DTO Pattern**
```java
// Separate internal models from API models
Entity → Service → DTO → Controller → JSON
```

**3. Exception Handling Pattern**
```java
@ControllerAdvice
public class GlobalExceptionHandler {
  @ExceptionHandler(UserNotFoundException.class)
  public ResponseEntity<Error> handleUserNotFound() {
    // Centralized error handling
  }
}
```

---

## 🔧 Configuration Management

### Environment-Based Config

```
application.yml          # Defaults
   ├── application-local.yml    # Local dev
   ├── application-render.yml   # Production
   └── application-test.yml     # Testing
```

**Profile Activation:**
```yaml
spring:
  profiles:
    active: ${SPRING_PROFILES_ACTIVE:local}
```

**Environment Variables:**
```bash
# Development
SPRING_PROFILES_ACTIVE=local

# Production
SPRING_PROFILES_ACTIVE=render
```

---

## 📊 Monitoring & Observability

### Health Checks

**Backend:**
```
GET /actuator/health
{
  "status": "UP",
  "components": {
    "db": {"status": "UP"},
    "diskSpace": {"status": "UP"}
  }
}
```

**Frontend:**
- Vercel Analytics (optional)
- Custom error tracking

### Logging

**Backend (Spring Boot):**
```yaml
logging:
  level:
    root: INFO
    com.yourapp: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} - %msg%n"
```

**Render Logs:**
- Real-time log streaming
- 7-day retention (free)
- Persistent logs (paid plans)

---

## 🔒 Security Best Practices

### Defense in Depth

```
1. Network Layer
   - HTTPS only (Vercel/Render default)
   - Firewall rules (Supabase)

2. Application Layer
   - Input validation
   - SQL injection prevention (JPA)
   - XSS prevention (React escaping)

3. Data Layer
   - Encrypted at rest (Supabase)
   - Encrypted in transit (TLS)
   - Regular backups

4. Authentication Layer
   - Strong password requirements
   - JWT with expiration
   - HttpOnly cookies
```

---

## 📚 Technology Choices

### Why These Technologies?

**React + Vite:**
- Fast development experience
- Modern build tooling
- Great ecosystem
- TypeScript support

**Spring Boot:**
- Mature, production-ready
- Excellent security
- Large community
- Easy to maintain

**PostgreSQL:**
- Reliable and battle-tested
- ACID compliance
- Rich feature set
- JSON support

**Vercel:**
- Zero-config deployments
- Global CDN
- Automatic HTTPS
- Great DX

**Render:**
- Docker support
- Affordable
- Auto-scaling
- Good for Java apps

**Supabase:**
- PostgreSQL-based
- Built-in auth
- Generous free tier
- Developer-friendly

---

## 🎯 Future Enhancements

### Potential Additions

1. **Caching Layer**
   - Redis for session storage
   - CDN caching strategies

2. **Message Queue**
   - Background job processing
   - Event-driven architecture

3. **Microservices**
   - Split into smaller services
   - Service mesh

4. **Advanced Monitoring**
   - APM (Datadog, New Relic)
   - Error tracking (Sentry)
   - Custom metrics

5. **CI/CD Enhancements**
   - Automated testing
   - Staging environments
   - Canary deployments

---

**This architecture is designed to be simple, scalable, and maintainable for small to medium applications.**

