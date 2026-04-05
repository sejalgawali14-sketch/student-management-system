# 🎓 Student Management System

A production-ready ASP.NET Core 8 Web API for managing students, built with clean layered architecture, JWT authentication, global exception handling, Serilog logging, Swagger documentation, Entity Framework Core, and a bonus vanilla-JS UI.

---

## 📁 Project Structure

```
StudentManagement/
├── StudentManagement.sln
│
├── StudentManagement.Core/              # Domain layer — zero dependencies
│   ├── Entities/
│   │   └── Student.cs                  # Student domain model
│   ├── DTOs/
│   │   └── StudentDtos.cs              # Request/Response DTOs + ApiResponse<T>
│   └── Interfaces/
│       └── IStudentInterfaces.cs       # IStudentRepository, IStudentService
│
├── StudentManagement.Infrastructure/   # Data access layer
│   ├── Data/
│   │   └── ApplicationDbContext.cs     # EF Core DbContext + seed data
│   ├── Repositories/
│   │   └── StudentRepository.cs        # Repository pattern implementation
│   └── Migrations/                     # EF Core migrations
│
├── StudentManagement.API/              # Presentation layer
│   ├── Controllers/
│   │   ├── StudentsController.cs       # CRUD endpoints (JWT-protected)
│   │   └── AuthController.cs          # Login → JWT token
│   ├── Services/
│   │   ├── StudentService.cs           # Business logic
│   │   └── TokenService.cs            # JWT generation
│   ├── Middleware/
│   │   └── ExceptionHandlingMiddleware.cs  # Global exception handler
│   ├── Extensions/
│   │   └── ServiceCollectionExtensions.cs  # DI registration helpers
│   ├── Program.cs                      # App bootstrap + Serilog
│   └── appsettings.json
│
├── StudentManagement.Tests/            # xUnit + Moq unit tests
│   └── StudentServiceTests.cs
│
├── StudentManagement.UI/               # Bonus: standalone HTML/JS UI
│   └── index.html
│
├── Dockerfile                          # Multi-stage Docker build
└── docker-compose.yml                  # API + SQL Server orchestration
```

---

## ⚙️ Tech Stack

| Layer          | Technology                              |
|----------------|-----------------------------------------|
| Framework      | ASP.NET Core 8 Web API                  |
| ORM            | Entity Framework Core 8 + SQL Server    |
| Authentication | JWT Bearer Tokens                       |
| Logging        | Serilog (Console + Rolling File)        |
| Documentation  | Swagger / Swashbuckle                   |
| Testing        | xUnit + Moq                             |
| Containerisation | Docker + Docker Compose               |
| Frontend (Bonus) | Vanilla JS / HTML (no build step)     |

---

## 🚀 Setup — Option A: Run Locally

### Prerequisites
- [.NET 8 SDK](https://dotnet.microsoft.com/download)
- SQL Server (local or Docker)

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/<your-username>/StudentManagement.git
cd StudentManagement

# 2. Update the connection string in appsettings.json
#    "DefaultConnection": "Server=localhost;Database=StudentManagementDB;
#                          Trusted_Connection=True;TrustServerCertificate=True;"

# 3. Apply EF Core migrations (creates DB + seed data automatically)
cd StudentManagement.API
dotnet ef database update

# 4. Run the API
dotnet run

# 5. Open Swagger UI
#    https://localhost:7001  (or http://localhost:5001)
```

---

## 🐳 Setup — Option B: Docker Compose (Recommended)

No SQL Server installation needed.

```bash
# 1. Build and start everything
docker-compose up --build

# 2. API is available at http://localhost:8080
# 3. Swagger UI:  http://localhost:8080/swagger
```

> SQL Server starts first (health-check), then the API migrates and seeds automatically.

---

## 🔐 Authentication

All `/api/students` endpoints require a JWT Bearer token.

### Step 1 — Login
```
POST /api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "Admin@123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful.",
  "data": { "token": "eyJhbGci..." }
}
```

### Step 2 — Use the token
Add to every request:
```
Authorization: Bearer eyJhbGci...
```

In Swagger UI: click **Authorize** → paste `Bearer <token>` → click Authorize.

---

## 📡 API Endpoints

| Method | Route                | Description           | Auth |
|--------|----------------------|-----------------------|------|
| POST   | `/api/auth/login`    | Get JWT token         | ❌   |
| GET    | `/api/students`      | Get all students      | ✅   |
| GET    | `/api/students/{id}` | Get student by ID     | ✅   |
| POST   | `/api/students`      | Create new student    | ✅   |
| PUT    | `/api/students/{id}` | Update student        | ✅   |
| DELETE | `/api/students/{id}` | Delete student        | ✅   |

### Sample Request — Create Student
```bash
curl -X POST https://localhost:7001/api/students \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Priya Sharma",
    "email": "priya@example.com",
    "age": 21,
    "course": "Data Science"
  }'
```

### Sample Response
```json
{
  "success": true,
  "message": "Student created successfully.",
  "data": {
    "id": 3,
    "name": "Priya Sharma",
    "email": "priya@example.com",
    "age": 21,
    "course": "Data Science",
    "createdDate": "2024-04-01T10:30:00Z"
  }
}
```

---

## 🗄️ Database Schema

```sql
CREATE TABLE Students (
    Id          INT IDENTITY(1,1) PRIMARY KEY,
    Name        NVARCHAR(100)  NOT NULL,
    Email       NVARCHAR(200)  NOT NULL UNIQUE,
    Age         INT            NOT NULL,
    Course      NVARCHAR(100)  NOT NULL,
    CreatedDate DATETIME2      NOT NULL DEFAULT GETUTCDATE()
);
```

---

## 🧪 Running Unit Tests

```bash
cd StudentManagement.Tests
dotnet test --verbosity normal
```

Tests cover:
- `GetAllStudentsAsync` — returns all records
- `GetStudentByIdAsync` — found / not found
- `CreateStudentAsync` — success + duplicate email conflict
- `DeleteStudentAsync` — success + not found

---

## 🎨 Bonus UI

Open `StudentManagement.UI/index.html` directly in any browser — no build step needed.

- Login with `admin` / `Admin@123`
- Set your API base URL (defaults to `https://localhost:7001`)
- Falls back to built-in mock data if the API is unreachable
- Full CRUD: view, add, edit, delete students
- JWT token display in sidebar

---

## 🔑 Configuration Reference (`appsettings.json`)

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=...;Database=StudentManagementDB;..."
  },
  "JwtSettings": {
    "SecretKey": "ZestIndiaIT_SuperSecret_JWT_Key_2024!@#$",
    "Issuer": "StudentManagementAPI",
    "Audience": "StudentManagementClient",
    "ExpiryHours": "8"
  },
  "DemoCredentials": {
    "Username": "admin",
    "Password": "Admin@123"
  }
}
```

> ⚠️ In production, store `SecretKey` and credentials in environment variables or Azure Key Vault — never in source control.

---

## ✅ Assignment Checklist

| Requirement                           | Status |
|---------------------------------------|--------|
| GET / POST / PUT / DELETE students    | ✅     |
| JWT Authentication                    | ✅     |
| Global Exception Handling (Middleware)| ✅     |
| Serilog Logging (Console + File)      | ✅     |
| Swagger API Documentation             | ✅     |
| Layered Architecture (C / S / R)      | ✅     |
| SQL Server + EF Core                  | ✅     |
| Clean structured code                 | ✅     |
| GitHub-ready with README              | ✅     |
| **Bonus:** Unit Tests (xUnit + Moq)   | ✅     |
| **Bonus:** Docker + Docker Compose    | ✅     |
| **Bonus:** Frontend UI                | ✅     |

---

## 👤 Author **Sejal Gawali**
