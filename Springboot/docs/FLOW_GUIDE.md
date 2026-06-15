# 📚 FLOW GUIDE - Group-8 Transaction System
# Panduan Alur Sistem - Sistem Transaksi Group-8

> **Bilingual Documentation | Dokumentasi Dwibahasa**
> 
> This guide explains the system architecture and flow of the Group-8 Transaction API.
> Panduan ini menjelaskan arsitektur dan alur sistem API Transaksi Group-8.

---

## 📖 Table of Contents | Daftar Isi

1. [System Overview | Gambaran Sistem](#1-system-overview--gambaran-sistem)
2. [Architecture Diagram | Diagram Arsitektur](#2-architecture-diagram--diagram-arsitektur)
3. [Database Schema | Skema Database](#3-database-schema--skema-database)
4. [Security & Authentication | Keamanan & Autentikasi](#4-security--authentication--keamanan--autentikasi)
5. [Controller Layer | Lapisan Controller](#5-controller-layer--lapisan-controller)
6. [Service Layer | Lapisan Service](#6-service-layer--lapisan-service)
7. [Business Flow Examples | Contoh Alur Bisnis](#7-business-flow-examples--contoh-alur-bisnis)

---

## 1. System Overview | Gambaran Sistem

### English
This is a **REST API** for a cafe/restaurant transaction management system built with:
- **Spring Boot 3.x** - Java framework for building web applications
- **Spring Security** - For authentication and authorization
- **JWT (JSON Web Token)** - For stateless authentication
- **JPA/Hibernate** - For database operations
- **MySQL** - Database storage

### Bahasa Indonesia
Ini adalah **REST API** untuk sistem manajemen transaksi kafe/restoran yang dibangun dengan:
- **Spring Boot 3.x** - Framework Java untuk membangun aplikasi web
- **Spring Security** - Untuk autentikasi dan otorisasi
- **JWT (JSON Web Token)** - Untuk autentikasi stateless
- **JPA/Hibernate** - Untuk operasi database
- **MySQL** - Penyimpanan database

---

## 2. Architecture Diagram | Diagram Arsitektur

### Layered Architecture | Arsitektur Berlapis

```mermaid
graph TB
    subgraph "Client Layer"
        A[Postman / Frontend App]
    end
    
    subgraph "Security Layer"
        B[JwtAuthenticationFilter]
        C[SecurityConfig]
    end
    
    subgraph "Controller Layer - REST Endpoints"
        D[AuthController<br>/api/auth/*]
        E[KaryawanController<br>/api/karyawan/*]
        F[MenuController<br>/api/menu/*]
        G[TransaksiController<br>/api/transaksi/*]
    end
    
    subgraph "Service Layer - Business Logic"
        H[AuthService]
        I[KaryawanService]
        J[MenuService]
        K[TransaksiService]
    end
    
    subgraph "Repository Layer - Data Access"
        L[KaryawanRepository]
        M[MenuRepository]
        N[TransaksiRepository]
        O[DetailTransaksiRepository]
    end
    
    subgraph "Database"
        P[(MySQL Database)]
    end
    
    A -->|HTTP Request| B
    B -->|Validate JWT| C
    C --> D & E & F & G
    D --> H
    E --> I
    F --> J
    G --> K
    H & I --> L
    J --> M
    K --> N & O & M & L
    L & M & N & O --> P
```

### Request Flow | Alur Permintaan

```mermaid
sequenceDiagram
    participant C as Client
    participant F as JwtFilter
    participant S as SecurityConfig
    participant CT as Controller
    participant SV as Service
    participant R as Repository
    participant DB as Database
    
    C->>F: HTTP Request + JWT Token
    F->>F: Extract & Validate Token
    alt Token Valid
        F->>S: Set Authentication
        S->>CT: Forward Request
        CT->>SV: Call Business Logic
        SV->>R: Data Operation
        R->>DB: SQL Query
        DB-->>R: Result
        R-->>SV: Entity/Data
        SV-->>CT: Processed Result
        CT-->>C: HTTP Response (200/201)
    else Token Invalid/Missing
        F-->>C: HTTP 401 Unauthorized
    end
```

---

## 3. Database Schema | Skema Database

### Entity Relationship Diagram | Diagram Relasi Entitas

```mermaid
erDiagram
    KARYAWAN ||--o{ TRANSAKSI : creates
    TRANSAKSI ||--|{ DETAIL_TRANSAKSI : contains
    MENU ||--o{ DETAIL_TRANSAKSI : ordered_in
    
    KARYAWAN {
        int karyawan_id PK
        string username UK
        string email UK
        string password
        int umur
        text alamat
        date tgl_lahir
        string no_telp
        enum role "ADMIN, KARYAWAN"
    }
    
    MENU {
        int menu_id PK
        string nama_item
        enum kategori "makanan, minuman"
        decimal harga
        text deskripsi
        int stok
    }
    
    TRANSAKSI {
        int transaksi_id PK
        int karyawan_id FK
        datetime tgl_transaksi
        decimal total_amount
    }
    
    DETAIL_TRANSAKSI {
        int detail_id PK
        int transaksi_id FK
        int menu_id FK
        int jumlah
        decimal harga
        decimal total_harga
    }
```

### Table Descriptions | Deskripsi Tabel

| Table | Description (EN) | Deskripsi (ID) |
|-------|------------------|----------------|
| `karyawan` | Stores employee data who can access the system | Menyimpan data karyawan yang dapat mengakses sistem |
| `menu` | Stores food and drink items with stock | Menyimpan item makanan dan minuman beserta stok |
| `transaksi` | Stores transaction headers (date, total, who created) | Menyimpan header transaksi (tanggal, total, pembuat) |
| `detail_transaksi` | Stores individual items in each transaction | Menyimpan item-item dalam setiap transaksi |

---

## 4. Security & Authentication | Keamanan & Autentikasi

### JWT Authentication Flow | Alur Autentikasi JWT

```mermaid
sequenceDiagram
    participant U as User
    participant A as AuthController
    participant AS as AuthService
    participant J as JwtUtil
    participant DB as Database
    
    Note over U,DB: Registration Flow | Alur Registrasi
    U->>A: POST /api/auth/register
    A->>AS: register(request)
    AS->>AS: Validate unique email/username
    AS->>AS: Encode password (BCrypt)
    AS->>DB: Save Karyawan
    AS->>J: generateToken(karyawan)
    J-->>AS: JWT Token
    AS-->>A: AuthResponse
    A-->>U: {token, message, karyawanInfo}
    
    Note over U,DB: Login Flow | Alur Login
    U->>A: POST /api/auth/login
    A->>AS: login(request)
    AS->>DB: Find by username/email
    AS->>AS: Verify password
    AS->>J: generateToken(karyawan)
    J-->>AS: JWT Token
    AS-->>A: AuthResponse
    A-->>U: {token, message, karyawanInfo}
```

### Role-Based Access Control | Kontrol Akses Berbasis Role

| Role | Accessible Endpoints | Endpoint yang Dapat Diakses |
|------|---------------------|----------------------------|
| **PUBLIC** | `/api/auth/*` | Registrasi, Login, Health Check |
| **ADMIN** | `/api/karyawan/*` | CRUD Karyawan (semua karyawan) |
| **KARYAWAN** | `/api/menu/*`, `/api/transaksi/*` | CRUD Menu, CRUD Transaksi |

> **Note | Catatan:** ADMIN role inherits KARYAWAN permissions in most cases.
> Role ADMIN mewarisi izin KARYAWAN dalam sebagian besar kasus.

### JWT Token Structure | Struktur Token JWT

```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "sub": "kasir_andi",      // username
    "id": 1,                   // karyawanId
    "email": "andi@cafe.com",
    "role": "KARYAWAN",
    "iat": 1703404800,         // issued at
    "exp": 1703491200          // expires (24h)
  }
}
```

---

## 5. Controller Layer | Lapisan Controller

### Controller Responsibilities | Tanggung Jawab Controller

```mermaid
mindmap
  root((Controllers))
    AuthController
      Register new user
      Login existing user
      Health check
    KaryawanController
      CRUD operations
      Bulk create/delete
      Pagination & sorting
      ADMIN only access
    MenuController
      CRUD operations
      Filter by kategori
      Update stock PATCH
      Bulk operations
      KARYAWAN access
    TransaksiController
      Create with details
      View transactions
      Filter by karyawan
      View my transactions
      Add detail to existing
      KARYAWAN access
```

### Endpoint Summary | Ringkasan Endpoint

#### AuthController (`/api/auth`)
| Method | Endpoint | Description (EN) | Deskripsi (ID) |
|--------|----------|------------------|----------------|
| POST | `/register` | Register new employee | Registrasi karyawan baru |
| POST | `/login` | Login and get JWT token | Login dan dapatkan token JWT |
| GET | `/health` | Check if service is running | Cek apakah service berjalan |

#### KaryawanController (`/api/karyawan`) - **ADMIN Only**
| Method | Endpoint | Description (EN) | Deskripsi (ID) |
|--------|----------|------------------|----------------|
| GET | `/` | Get all with pagination | Ambil semua dengan paginasi |
| GET | `/{id}` | Get by ID | Ambil berdasarkan ID |
| POST | `/` | Create new | Buat baru |
| POST | `/bulk` | Create max 5 at once | Buat maksimal 5 sekaligus |
| PUT | `/{id}` | Update by ID | Update berdasarkan ID |
| DELETE | `/{id}` | Delete by ID | Hapus berdasarkan ID |
| DELETE | `/bulk` | Delete max 5 at once | Hapus maksimal 5 sekaligus |

#### MenuController (`/api/menu`) - **KARYAWAN Access**
| Method | Endpoint | Description (EN) | Deskripsi (ID) |
|--------|----------|------------------|----------------|
| GET | `/` | Get all with pagination | Ambil semua dengan paginasi |
| GET | `/{id}` | Get by ID | Ambil berdasarkan ID |
| GET | `/kategori/{kategori}` | Filter by category | Filter berdasarkan kategori |
| POST | `/` | Create new menu | Buat menu baru |
| POST | `/bulk` | Create max 5 at once | Buat maksimal 5 sekaligus |
| PUT | `/{id}` | Full update | Update lengkap |
| PATCH | `/{id}/stok` | Update stock only | Update stok saja |
| DELETE | `/{id}` | Delete by ID | Hapus berdasarkan ID |
| DELETE | `/bulk` | Delete max 5 at once | Hapus maksimal 5 sekaligus |

#### TransaksiController (`/api/transaksi`) - **KARYAWAN Access**
| Method | Endpoint | Description (EN) | Deskripsi (ID) |
|--------|----------|------------------|----------------|
| GET | `/` | Get all with pagination | Ambil semua dengan paginasi |
| GET | `/{id}` | Get by ID | Ambil berdasarkan ID |
| GET | `/karyawan/{id}` | Get by karyawan ID | Ambil berdasarkan ID karyawan |
| GET | `/my` | Get my transactions | Ambil transaksi saya |
| POST | `/` | Create with details | Buat dengan detail |
| GET | `/{id}/detail` | Get transaction details | Ambil detail transaksi |
| POST | `/{id}/detail` | Add detail to transaction | Tambah detail ke transaksi |

---

## 6. Service Layer | Lapisan Service

### Service Responsibilities | Tanggung Jawab Service

| Service | Responsibilities (EN) | Tanggung Jawab (ID) |
|---------|----------------------|---------------------|
| **AuthService** | Handle registration, login, password encoding, JWT generation | Menangani registrasi, login, encoding password, pembuatan JWT |
| **KaryawanService** | CRUD operations, validation, bulk operations | Operasi CRUD, validasi, operasi bulk |
| **MenuService** | CRUD operations, stock management, category filtering | Operasi CRUD, manajemen stok, filter kategori |
| **TransaksiService** | Create transactions, auto-calculate totals, stock reduction | Buat transaksi, hitung total otomatis, pengurangan stok |

### Transaction Service Flow | Alur Service Transaksi

```mermaid
flowchart TD
    A[Receive Request] --> B{Validate Details}
    B -->|Empty| C[Throw Error: Details required]
    B -->|Valid| D[Find Karyawan by ID]
    D -->|Not Found| E[Throw Error: Karyawan not found]
    D -->|Found| F[Create Transaksi Header]
    F --> G[Loop: For each detail]
    G --> H[Find Menu by ID]
    H -->|Not Found| I[Throw Error: Menu not found]
    H -->|Found| J{Check Stock}
    J -->|Insufficient| K[Throw Error: Stock insufficient]
    J -->|Sufficient| L[Reduce Stock]
    L --> M[Create DetailTransaksi]
    M --> N[Add to Total Amount]
    N --> O{More Details?}
    O -->|Yes| G
    O -->|No| P[Save Transaksi with Total]
    P --> Q[Return Complete Transaksi]
```

---

## 7. Business Flow Examples | Contoh Alur Bisnis

### Example 1: Complete Transaction Flow | Alur Transaksi Lengkap

```mermaid
sequenceDiagram
    participant K as Kasir (KARYAWAN)
    participant TC as TransaksiController
    participant TS as TransaksiService
    participant MR as MenuRepository
    participant TR as TransaksiRepository
    
    Note over K,TR: Kasir creates new transaction | Kasir membuat transaksi baru
    
    K->>TC: POST /api/transaksi<br>{details: [{menuId:1, jumlah:2}, {menuId:3, jumlah:1}]}
    TC->>TC: Extract karyawanId from JWT
    TC->>TS: createTransaksiWithDetails(karyawanId, details)
    
    TS->>TR: Save empty transaksi
    TR-->>TS: transaksiId = 1
    
    loop For each detail
        TS->>MR: findById(menuId)
        MR-->>TS: Menu (stok=10, harga=25000)
        TS->>TS: menu.kurangiStok(jumlah)
        TS->>MR: save(menu) // stok = 8
        TS->>TS: Create DetailTransaksi
        TS->>TS: totalAmount += (harga × jumlah)
    end
    
    TS->>TR: Update transaksi with totalAmount
    TS-->>TC: Complete Transaksi object
    TC-->>K: 201 Created {transaksiId, totalAmount, ...}
```

### Example 2: Admin Managing Employees | Admin Mengelola Karyawan

```mermaid
sequenceDiagram
    participant A as Admin
    participant KC as KaryawanController
    participant KS as KaryawanService
    participant KR as KaryawanRepository
    
    Note over A,KR: Admin creates new cashier | Admin membuat kasir baru
    
    A->>KC: POST /api/karyawan<br>Authorization: Bearer {admin_token}
    KC->>KC: @PreAuthorize("hasRole('ADMIN')")
    KC->>KS: createKaryawan(karyawan)
    KS->>KS: Validate unique username/email
    KS->>KS: Encode password
    KS->>KR: save(karyawan)
    KR-->>KS: Saved Karyawan
    KS-->>KC: Karyawan object
    KC-->>A: 201 Created
```

---

## 🎯 Quick Start | Mulai Cepat

### Prerequisites | Prasyarat
1. Java 17+ installed | Java 17+ terinstall
2. MySQL running on port 3306 | MySQL berjalan di port 3306
3. Database `transaksi` created | Database `transaksi` sudah dibuat

### Run Application | Jalankan Aplikasi
```bash
# Navigate to project root | Navigasi ke root proyek
cd "d:\Data\Tugas Kuliah\ccit\Phase 6 (MAR)\Pakhir\Group-8_R2Bfinal"

# Run with Maven Wrapper | Jalankan dengan Maven Wrapper
./mvnw spring-boot:run
```

### Test Endpoints | Tes Endpoint
1. Open Postman | Buka Postman
2. Import collection from `docs/Group8_API.postman_collection.json`
3. Start with `/api/auth/register` or `/api/auth/login`
4. Copy the JWT token and use it in other requests

---

> **Next Step | Langkah Selanjutnya:** See [POSTMAN_TUTORIAL.md](./POSTMAN_TUTORIAL.md) for detailed API testing guide.
> Lihat [POSTMAN_TUTORIAL.md](./POSTMAN_TUTORIAL.md) untuk panduan testing API yang detail.
