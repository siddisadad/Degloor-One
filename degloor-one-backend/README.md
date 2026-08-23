# DEGLOOR ONE Backend

Spring Boot 3 / Java 21 API that owns authentication, pricing, inventory, order state, delivery OTP, and the rest of the Degloor marketplace rules.

Flutter remains the presentation layer. Point it at this API with:

```text
--dart-define=JAVA_API_BASE_URL=http://10.0.2.2:8080
```

Until that flag is set, the app keeps showcase/Supabase fallbacks.

## Run locally

Needs Java 21, Maven, and PostgreSQL 16.

```bash
# terminal 1
docker compose up postgres redis

# terminal 2
cp env.example .env   # optional
mvn spring-boot:run
```

API: `http://localhost:8080`  
Swagger: `http://localhost:8080/swagger-ui.html`  
Health: `http://localhost:8080/actuator/health`

Seed login (password for every demo user is `password`):

| Email | Role |
|---|---|
| `guest@local` | customer |
| `suresh@degloor.local` | business_owner |
| `rider@degloor.local` | delivery_partner |
| `admin@degloor.local` | admin |

Controllers call services. Services call Spring Data repositories. Search, counts, and unassigned-order lookups live on the repository layer (`*Specifications`, `@Query`), not `findAll()` plus in-memory filters.

## Tests

This environment has no Docker daemon for Testcontainers. Tests use H2 (`MODE=PostgreSQL`).

```bash
mvn test
```

## Docker

```bash
mvn -DskipTests package
docker compose up --build
```

Production secrets come from the environment: `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`, `JWT_SECRET`. Never commit real values.
