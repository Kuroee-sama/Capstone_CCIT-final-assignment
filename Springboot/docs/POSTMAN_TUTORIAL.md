# 📮 POSTMAN TUTORIAL - Group-8 Transaction API
# Tutorial Postman - API Transaksi Group-8

> **Bilingual Documentation | Dokumentasi Dwibahasa**
> 
> Complete guide to test all API endpoints using Postman.
> Panduan lengkap untuk testing semua endpoint API menggunakan Postman.

---

## 📖 Table of Contents | Daftar Isi

1. [Prerequisites | Prasyarat](#1-prerequisites--prasyarat)
2. [Environment Setup | Pengaturan Environment](#2-environment-setup--pengaturan-environment)
3. [Authentication Endpoints | Endpoint Autentikasi](#3-authentication-endpoints--endpoint-autentikasi)
4. [Karyawan Endpoints | Endpoint Karyawan](#4-karyawan-endpoints--endpoint-karyawan)
5. [Menu Endpoints | Endpoint Menu](#5-menu-endpoints--endpoint-menu)
6. [Transaksi Endpoints | Endpoint Transaksi](#6-transaksi-endpoints--endpoint-transaksi)
7. [Error Handling | Penanganan Error](#7-error-handling--penanganan-error)

---

## 1. Prerequisites | Prasyarat

### English
Before starting, ensure you have:
1. **Postman** installed ([Download here](https://www.postman.com/downloads/))
2. **MySQL** running with database `transaksi` created
3. **Application** running on `http://localhost:8080`

### Bahasa Indonesia
Sebelum memulai, pastikan Anda memiliki:
1. **Postman** terinstall ([Download di sini](https://www.postman.com/downloads/))
2. **MySQL** berjalan dengan database `transaksi` sudah dibuat
3. **Aplikasi** berjalan di `http://localhost:8080`

### Start the Application | Jalankan Aplikasi
```bash
cd "d:\Data\Tugas Kuliah\ccit\Phase 6 (MAR)\Pakhir\Group-8_R2Bfinal"
./mvnw spring-boot:run
```

---

## 2. Environment Setup | Pengaturan Environment

### Import Collection | Import Koleksi
1. Open Postman | Buka Postman
2. Click **Import** button | Klik tombol **Import**
3. Select file: `docs/Group8_API.postman_collection.json`
4. Collection will appear in sidebar | Koleksi akan muncul di sidebar

### Setup Environment Variables | Atur Variabel Environment
Create a new environment with these variables:

| Variable | Initial Value | Description |
|----------|---------------|-------------|
| `base_url` | `http://localhost:8080` | Base URL of API |
| `jwt_token` | (empty) | Will be set after login |
| `admin_token` | (empty) | Token for ADMIN role |

---

## 3. Authentication Endpoints | Endpoint Autentikasi

### 3.1 Health Check

**Purpose | Tujuan:** Check if the authentication service is running.

```
GET {{base_url}}/api/auth/health
```

**Response:**
```json
{
    "status": "UP",
    "message": "Auth service is running"
}
```

---

### 3.2 Register New Employee | Registrasi Karyawan Baru

**Purpose | Tujuan:** Create a new employee account and get JWT token.

```
POST {{base_url}}/api/auth/register
Content-Type: application/json
```

**Request Body (KARYAWAN role):**
```json
{
    "username": "kasir_andi",
    "email": "andi@cafe.com",
    "password": "password123",
    "umur": 25,
    "alamat": "Jl. Sudirman No. 123, Jakarta",
    "tglLahir": "1999-05-15",
    "noTelp": "081234567890"
}
```

**Request Body (ADMIN role):**
```json
{
    "username": "admin_budi",
    "email": "budi@cafe.com",
    "password": "admin123",
    "umur": 30,
    "alamat": "Jl. Gatot Subroto No. 456, Jakarta",
    "tglLahir": "1994-08-20",
    "noTelp": "081234567891",
    "role": "ADMIN"
}
```

**Response (201 Created):**
```json
{
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "message": "Registrasi berhasil",
    "karyawan": {
        "karyawanId": 1,
        "username": "kasir_andi",
        "email": "andi@cafe.com",
        "umur": 25,
        "alamat": "Jl. Sudirman No. 123, Jakarta",
        "noTelp": "081234567890",
        "role": "KARYAWAN"
    }
}
```

> **💡 Tip:** Copy the `token` value and save it to `jwt_token` or `admin_token` environment variable.

---

### 3.3 Login | Masuk

**Purpose | Tujuan:** Login with existing credentials and get JWT token.

```
POST {{base_url}}/api/auth/login
Content-Type: application/json
```

**Request Body:**
```json
{
    "username": "kasir_andi",
    "password": "password123"
}
```

> **Note | Catatan:** You can also use email instead of username for login.

**Response (200 OK):**
```json
{
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "message": "Login berhasil",
    "karyawan": {
        "karyawanId": 1,
        "username": "kasir_andi",
        "email": "andi@cafe.com",
        "role": "KARYAWAN"
    }
}
```

---

## 4. Karyawan Endpoints | Endpoint Karyawan

> ⚠️ **Authorization Required | Otorisasi Diperlukan:** All endpoints require ADMIN role.
> Semua endpoint membutuhkan role ADMIN.

**Header for all requests:**
```
Authorization: Bearer {{admin_token}}
```

---

### 4.1 Get All Karyawan (Paginated) | Ambil Semua Karyawan (Paginasi)

```
GET {{base_url}}/api/karyawan?page=0&size=5&sortBy=karyawanId&sortDir=asc
```

**Query Parameters:**
| Parameter | Default | Description |
|-----------|---------|-------------|
| `page` | 0 | Page number (0-indexed) |
| `size` | 5 | Items per page |
| `sortBy` | karyawanId | Sort field |
| `sortDir` | asc | Sort direction (asc/desc) |

**Response (200 OK):**
```json
{
    "content": [
        {
            "karyawanId": 1,
            "username": "kasir_andi",
            "email": "andi@cafe.com",
            "umur": 25,
            "alamat": "Jakarta",
            "role": "KARYAWAN"
        }
    ],
    "pageable": {
        "pageNumber": 0,
        "pageSize": 5
    },
    "totalElements": 1,
    "totalPages": 1
}
```

---

### 4.2 Get Karyawan by ID | Ambil Karyawan berdasarkan ID

```
GET {{base_url}}/api/karyawan/1
```

**Response (200 OK):**
```json
{
    "karyawanId": 1,
    "username": "kasir_andi",
    "email": "andi@cafe.com",
    "umur": 25,
    "alamat": "Jakarta",
    "tglLahir": "1999-05-15",
    "noTelp": "081234567890",
    "role": "KARYAWAN"
}
```

---

### 4.3 Create Karyawan | Buat Karyawan Baru

```
POST {{base_url}}/api/karyawan
Content-Type: application/json
```

**Request Body:**
```json
{
    "username": "kasir_citra",
    "email": "citra@cafe.com",
    "password": "password123",
    "umur": 22,
    "alamat": "Bandung",
    "tglLahir": "2002-03-10",
    "noTelp": "081234567892",
    "role": "KARYAWAN"
}
```

**Response (201 Created):**
```json
{
    "karyawanId": 2,
    "username": "kasir_citra",
    "email": "citra@cafe.com",
    "role": "KARYAWAN"
}
```

---

### 4.4 Bulk Create Karyawan | Buat Banyak Karyawan Sekaligus

```
POST {{base_url}}/api/karyawan/bulk
Content-Type: application/json
```

**Request Body (max 5 items):**
```json
[
    {
        "username": "kasir_deni",
        "email": "deni@cafe.com",
        "password": "password123",
        "umur": 24,
        "role": "KARYAWAN"
    },
    {
        "username": "kasir_eka",
        "email": "eka@cafe.com",
        "password": "password123",
        "umur": 26,
        "role": "KARYAWAN"
    }
]
```

**Response (201 Created):**
```json
{
    "message": "2 karyawan created successfully",
    "data": [...]
}
```

---

### 4.5 Update Karyawan | Update Karyawan

```
PUT {{base_url}}/api/karyawan/1
Content-Type: application/json
```

**Request Body:**
```json
{
    "username": "kasir_andi_updated",
    "email": "andi.updated@cafe.com",
    "umur": 26,
    "alamat": "Surabaya"
}
```

**Response (200 OK):** Updated karyawan object

---

### 4.6 Delete Karyawan | Hapus Karyawan

```
DELETE {{base_url}}/api/karyawan/2
```

**Response (204 No Content):** Empty body

---

### 4.7 Bulk Delete Karyawan | Hapus Banyak Karyawan Sekaligus

```
DELETE {{base_url}}/api/karyawan/bulk
Content-Type: application/json
```

**Request Body:**
```json
{
    "ids": [3, 4, 5]
}
```

**Response (204 No Content):** Empty body

---

## 5. Menu Endpoints | Endpoint Menu

> ⚠️ **Authorization Required | Otorisasi Diperlukan:** Requires KARYAWAN or ADMIN role.
> Membutuhkan role KARYAWAN atau ADMIN.

**Header for all requests:**
```
Authorization: Bearer {{jwt_token}}
```

---

### 5.1 Get All Menu (Paginated) | Ambil Semua Menu

```
GET {{base_url}}/api/menu?page=0&size=5&sortBy=menuId&sortDir=asc
```

**Response (200 OK):**
```json
{
    "content": [
        {
            "menuId": 1,
            "namaItem": "Nasi Goreng",
            "kategori": "makanan",
            "harga": 25000.00,
            "deskripsi": "Nasi goreng spesial dengan ayam",
            "stok": 50
        }
    ],
    "totalElements": 1,
    "totalPages": 1
}
```

---

### 5.2 Get Menu by ID | Ambil Menu berdasarkan ID

```
GET {{base_url}}/api/menu/1
```

---

### 5.3 Get Menu by Kategori | Ambil Menu berdasarkan Kategori

```
GET {{base_url}}/api/menu/kategori/makanan?page=0&size=5
```

**Valid kategori values:** `makanan`, `minuman`

---

### 5.4 Create Menu | Buat Menu Baru

```
POST {{base_url}}/api/menu
Content-Type: application/json
```

**Request Body:**
```json
{
    "namaItem": "Nasi Goreng Spesial",
    "kategori": "makanan",
    "harga": 28000.00,
    "deskripsi": "Nasi goreng dengan telur, ayam, dan kerupuk",
    "stok": 100
}
```

**Response (201 Created):** Created menu object

---

### 5.5 Bulk Create Menu | Buat Banyak Menu Sekaligus

```
POST {{base_url}}/api/menu/bulk
Content-Type: application/json
```

**Request Body (max 5 items):**
```json
[
    {
        "namaItem": "Es Teh Manis",
        "kategori": "minuman",
        "harga": 5000.00,
        "deskripsi": "Teh manis dingin",
        "stok": 200
    },
    {
        "namaItem": "Kopi Susu",
        "kategori": "minuman",
        "harga": 15000.00,
        "deskripsi": "Kopi dengan susu segar",
        "stok": 150
    }
]
```

---

### 5.6 Update Menu (Full) | Update Menu (Lengkap)

```
PUT {{base_url}}/api/menu/1
Content-Type: application/json
```

**Request Body:**
```json
{
    "namaItem": "Nasi Goreng Premium",
    "kategori": "makanan",
    "harga": 35000.00,
    "deskripsi": "Nasi goreng premium dengan seafood",
    "stok": 75
}
```

---

### 5.7 Update Stock Only (PATCH) | Update Stok Saja

```
PATCH {{base_url}}/api/menu/1/stok
Content-Type: application/json
```

**Request Body:**
```json
{
    "stok": 120
}
```

> **💡 Use PATCH when:** You only need to update stock without changing other fields.
> **Gunakan PATCH ketika:** Anda hanya perlu update stok tanpa mengubah field lain.

---

### 5.8 Delete Menu | Hapus Menu

```
DELETE {{base_url}}/api/menu/1
```

---

### 5.9 Bulk Delete Menu | Hapus Banyak Menu Sekaligus

```
DELETE {{base_url}}/api/menu/bulk
Content-Type: application/json
```

**Request Body:**
```json
{
    "ids": [2, 3]
}
```

---

## 6. Transaksi Endpoints | Endpoint Transaksi

> ⚠️ **Authorization Required | Otorisasi Diperlukan:** Requires KARYAWAN or ADMIN role.
> Membutuhkan role KARYAWAN atau ADMIN.

---

### 6.1 Get All Transactions | Ambil Semua Transaksi

```
GET {{base_url}}/api/transaksi?page=0&size=5&sortBy=transaksiId&sortDir=desc
```

**Response (200 OK):**
```json
{
    "content": [
        {
            "transaksiId": 1,
            "karyawanId": 1,
            "tglTransaksi": "2024-12-24T10:30:00",
            "totalAmount": 78000.00
        }
    ],
    "totalElements": 1
}
```

---

### 6.2 Get Transaction by ID | Ambil Transaksi berdasarkan ID

```
GET {{base_url}}/api/transaksi/1
```

---

### 6.3 Get Transactions by Karyawan | Ambil Transaksi berdasarkan Karyawan

```
GET {{base_url}}/api/transaksi/karyawan/1?page=0&size=5
```

---

### 6.4 Get My Transactions | Ambil Transaksi Saya

```
GET {{base_url}}/api/transaksi/my?page=0&size=5
```

> **Note | Catatan:** This uses the karyawanId from your JWT token automatically.
> Ini menggunakan karyawanId dari token JWT Anda secara otomatis.

---

### 6.5 Create Transaction with Details | Buat Transaksi dengan Detail

**This is the main endpoint for creating transactions!**
**Ini adalah endpoint utama untuk membuat transaksi!**

```
POST {{base_url}}/api/transaksi
Content-Type: application/json
```

**Request Body:**
```json
{
    "details": [
        {
            "menuId": 1,
            "jumlah": 2
        },
        {
            "menuId": 2,
            "jumlah": 3
        }
    ]
}
```

> **Important | Penting:**
> - `karyawanId` is automatically taken from JWT token
> - Stock will be reduced automatically
> - If stock is insufficient, the transaction will fail
> 
> - `karyawanId` diambil otomatis dari token JWT
> - Stok akan berkurang secara otomatis
> - Jika stok tidak mencukupi, transaksi akan gagal

**Response (201 Created):**
```json
{
    "transaksiId": 1,
    "karyawanId": 1,
    "tglTransaksi": "2024-12-24T10:30:00",
    "totalAmount": 78000.00,
    "detailList": [
        {
            "detailId": 1,
            "menuId": 1,
            "jumlah": 2,
            "harga": 28000.00,
            "totalHarga": 56000.00,
            "menu": {
                "menuId": 1,
                "namaItem": "Nasi Goreng Spesial"
            }
        },
        {
            "detailId": 2,
            "menuId": 2,
            "jumlah": 3,
            "harga": 5000.00,
            "totalHarga": 15000.00
        }
    ]
}
```

---

### 6.6 Get Transaction Details | Ambil Detail Transaksi

```
GET {{base_url}}/api/transaksi/1/detail
```

**Response (200 OK):**
```json
[
    {
        "detailId": 1,
        "transaksiId": 1,
        "menuId": 1,
        "jumlah": 2,
        "harga": 28000.00,
        "totalHarga": 56000.00,
        "menu": {
            "menuId": 1,
            "namaItem": "Nasi Goreng Spesial",
            "kategori": "makanan"
        }
    }
]
```

---

### 6.7 Add Detail to Existing Transaction | Tambah Detail ke Transaksi

```
POST {{base_url}}/api/transaksi/1/detail
Content-Type: application/json
```

**Request Body:**
```json
{
    "menuId": 3,
    "jumlah": 2
}
```

> **Note | Catatan:** This will also reduce stock and update the total amount.
> Ini juga akan mengurangi stok dan memperbarui total amount.

---

## 7. Error Handling | Penanganan Error

### Common HTTP Status Codes | Kode Status HTTP Umum

| Code | Meaning (EN) | Arti (ID) | When | Kapan |
|------|--------------|-----------|------|-------|
| 200 | OK | Sukses | Successful GET/PUT/PATCH | GET/PUT/PATCH berhasil |
| 201 | Created | Dibuat | Successful POST | POST berhasil |
| 204 | No Content | Tanpa Konten | Successful DELETE | DELETE berhasil |
| 400 | Bad Request | Permintaan Salah | Validation error | Error validasi |
| 401 | Unauthorized | Tidak Terotorisasi | Missing/invalid token | Token hilang/tidak valid |
| 403 | Forbidden | Dilarang | Wrong role | Role tidak sesuai |
| 404 | Not Found | Tidak Ditemukan | Resource not found | Resource tidak ditemukan |

### Error Response Examples | Contoh Response Error

**401 Unauthorized (No Token):**
```json
{
    "error": "Full authentication is required"
}
```

**403 Forbidden (Wrong Role):**
```json
{
    "error": "Access Denied"
}
```

**400 Bad Request (Validation Error):**
```json
{
    "error": "Username sudah digunakan: kasir_andi"
}
```

**400 Bad Request (Insufficient Stock):**
```json
{
    "error": "Stok tidak mencukupi untuk item: Nasi Goreng. Stok tersedia: 5, diminta: 10"
}
```

**404 Not Found:**
```json
{
    "error": "Karyawan not found with id: 999"
}
```

---

## 🚀 Quick Test Sequence | Urutan Testing Cepat

Follow this sequence to test the complete flow:

### Step 1: Register Admin
```
POST /api/auth/register
Body: { "username": "admin", "email": "admin@cafe.com", "password": "admin123", "role": "ADMIN" }
→ Save token as admin_token
```

### Step 2: Register Karyawan
```
POST /api/auth/register
Body: { "username": "kasir1", "email": "kasir1@cafe.com", "password": "pass123" }
→ Save token as jwt_token
```

### Step 3: Create Menu (as KARYAWAN)
```
POST /api/menu
Header: Authorization: Bearer {{jwt_token}}
Body: { "namaItem": "Nasi Goreng", "kategori": "makanan", "harga": 25000, "stok": 100 }
```

### Step 4: Create Transaction
```
POST /api/transaksi
Header: Authorization: Bearer {{jwt_token}}
Body: { "details": [{ "menuId": 1, "jumlah": 2 }] }
```

### Step 5: Check Transaction
```
GET /api/transaksi/my
Header: Authorization: Bearer {{jwt_token}}
```

### Step 6: Check Stock Reduced
```
GET /api/menu/1
→ Stock should be 98 (100 - 2)
```

---

> **📁 Postman Collection:** Import `Group8_API.postman_collection.json` for pre-configured requests.
> **📁 Koleksi Postman:** Import `Group8_API.postman_collection.json` untuk request yang sudah dikonfigurasi.
