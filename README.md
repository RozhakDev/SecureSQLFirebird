# Proyek Keamanan Basis Data: Implementasi Hak Akses pada Firebird SQL

## 1. Ringkasan Proyek

Proyek ini merupakan demonstrasi praktis dari implementasi **Keamanan Basis Data** dan Kontrol Hak Akses menggunakan **Data Control Language** (DCL) pada Sistem Manajemen Basis Data (SMBD) **Firebird SQL**.

Tujuan utama dari proyek ini adalah untuk menyimulasikan skenario di mana beberapa pengguna dengan peran yang berbeda berinteraksi dengan basis data yang sama. Setiap pengguna diberikan hak akses yang spesifik sesuai dengan tanggung jawabnya, seperti melihat, menambah, mengubah, dan menghapus data. Proyek ini mencakup:

* **Pembuatan User:** Membuat akun pengguna yang terpisah.
* **Pemberian Hak Akses (GRANT):** Memberikan izin spesifik pada level tabel dan kolom.
* **Pencabutan Hak Akses (REVOKE):** Menarik kembali izin yang telah diberikan.
* **Simulasi Akses:** Menguji efektivitas aturan keamanan yang telah diterapkan dengan login sebagai setiap pengguna.

## 2. Prasyarat dan Instalasi

Sebelum memulai, pastikan perangkat lunak berikut telah terpasang di sistem operasi Windows Anda.

| **Perangkat Lunak** | **Tautan Unduhan**                                                         | **Catatan**                                                     |
| ------------------- | -------------------------------------------------------------------------- | --------------------------------------------------------------- |
| Firebird 5.0        | [firebirdsql.org](https://firebirdsql.org/en/firebird-5-0)                 | Mesin basis data utama.                                         |
| FlameRobin (GUI)    | [GitHub Releases](https://github.com/mariuz/flamerobin/releases/tag/0.9.7) | Opsional, sebagai alat bantu visual untuk manajemen basis data. |

### Konfigurasi Awal

* Selama instalasi Firebird, atur kata sandi default untuk user `SYSDBA` menjadi `masterkey`.
* Proyek ini sepenuhnya dapat dijalankan melalui **Firebird SQL Shell (isql)** yang tersedia secara default.

## 3. Inisialisasi Basis Data

Langkah-langkah berikut akan memandu Anda untuk membuat basis data, mendefinisikan struktur tabel, dan mengisi data awal melalui `isql`.

### 1. Buka `isql` sebagai Administrator:

* Buka Command Prompt (CMD) dengan hak akses Administrator.
* Arahkan ke direktori `bin` instalasi Firebird Anda.
  
  ```bash
  # Untuk instalasi 64-bit (default)
  cd "C:\Program Files\Firebird\Firebird_5_0\bin"
  ```
* Jalankan shell interaktif.

### 2. Buat dan Hubungkan ke Database:

Jalankan perintah berikut untuk membuat file database baru (`.FDB`) di lokasi yang Anda tentukan (misal: `C:\FirebirdDB\`)

```bash
CREATE DATABASE 'C:\FirebirdDB\SECURITY_PROJECT.FDB'
USER 'SYSDBA' PASSWORD 'masterkey';
```

### 3. Buat Struktur Tabel:

Dua tabel utama digunakan dalam proyek ini: `employees` untuk data pegawai dan `attendance` untuk data absensi.

```sql
-- Tabel untuk menyimpan data pegawai
CREATE TABLE employees (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    role VARCHAR(30)
);

-- Tabel untuk mencatat kehadiran pegawai
CREATE TABLE attendance (
    id INT PRIMARY KEY,
    employee_id INT,
    attend_date DATE,
    status VARCHAR(20)
);

COMMIT;
```

### 4. Masukkan Data Awal (Seed Data):

Tambahkan beberapa data awal untuk keperluan pengujian.

```sql
INSERT INTO employees VALUES (1, 'MAULANA', 'Admin');
INSERT INTO employees VALUES (2, 'ZAHRA', 'Staff');

INSERT INTO attendance VALUES (1, 1, CURRENT_DATE, 'Present');

COMMIT;
```

## 4. Implementasi Keamanan: Pengguna dan Hak Akses

Bagian ini adalah inti dari proyek, di mana kita mendefinisikan pengguna dan menetapkan hak akses mereka sesuai dengan skenario yang ditentukan.

### 👥 Skenario Pengguna dan Peran

Berikut adalah pemetaan pengguna, peran, dan hak akses yang akan diimplementasikan:

| **Nama User** | **Nama Lengkap**      | **Peran / Skenario**   | **Hak Akses yang Diberikan**                             |
| ------------- | --------------------- | ---------------------- | -------------------------------------------------------- |
| maulana       | MAULANA GHANI ROLANDA | Admin Tabel Pegawai    | SELECT dan INSERT pada tabel `employees`.                |
| zahra         | ZAHRA TSUROYYA POETRI | Staf Absensi           | SELECT dan INSERT pada tabel `attendance`.               |
| didik         | DIDIK SETIAWAN        | Staf HR (Update Nama)  | SELECT pada `employees`, UPDATE hanya pada kolom `name`. |
| arsya         | ARSYA FATHIHA RAHMAN  | Staf Audit Absensi     | SELECT dan DELETE pada tabel `attendance`.               |
| rozhak        | ROZHAK                | Supervisor (Read-Only) | SELECT pada `employees` dan `attendance`.                |

### 🧑‍💻 Pembuatan User

Buat setiap pengguna dengan kata sandi masing-masing.

```sql
CREATE USER maulana PASSWORD 'pwd_maulana';
CREATE USER didik PASSWORD 'pwd_didik';
CREATE USER zahra PASSWORD 'pwd_zahra';
CREATE USER arsya PASSWORD 'pwd_arsya';
CREATE USER rozhak PASSWORD 'pwd_rozhak';
COMMIT;
```

### 🔐 Pemberian Hak Akses (GRANT)

Terapkan hak akses sesuai dengan skenario yang telah didefinisikan.

```sql
-- Maulana hanya bisa mengelola tabel employees
GRANT SELECT, INSERT ON employees TO maulana;

-- Zahra hanya bisa mengelola tabel attendance
GRANT SELECT, INSERT ON attendance TO zahra;

-- Didik bisa melihat data pegawai dan hanya boleh mengubah kolom 'name'
GRANT SELECT ON employees TO didik;
GRANT UPDATE (name) ON employees TO didik;

-- Arsya bisa melihat dan menghapus data absensi
GRANT DELETE, SELECT ON attendance TO arsya;

-- Rozhak bisa melihat semua data dari kedua tabel
GRANT SELECT ON employees TO rozhak;
GRANT SELECT ON attendance TO rozhak;

COMMIT;
```

## 5. Simulasi dan Verifikasi Akses

Untuk memverifikasi bahwa aturan keamanan berfungsi, keluar dari sesi `SYSDBA` dan login sebagai setiap pengguna untuk menguji hak akses mereka.

Keluar dari `isql`:

```sql
EXIT;
```

### 🧑‍💻 Sesi sebagai maulana (Admin Pegawai)

Login kembali ke isql dan hubungkan sebagai maulana.

```bash
isql
CONNECT "C:\FirebirdDB\SECURITY_PROJECT.FDB" USER 'maulana' PASSWORD 'pwd_maulana';
```

#### Pengujian:

```sql
-- SUKSES: Maulana dapat melihat data pegawai
SELECT * FROM employees;

-- SUKSES: Maulana dapat menambah data pegawai baru
INSERT INTO employees VALUES (3, 'MAULANA TEST', 'Admin');
COMMIT;

-- GAGAL: Maulana tidak memiliki hak akses ke tabel attendance
-- Perintah ini akan menghasilkan error "no permission for read/select access to table ATTENDANCE"
SELECT * FROM attendance;
```

### 🧑‍💻 Sesi sebagai didik (Staf HR)

Login kembali sebagai didik.

```bash
isql
CONNECT "C:\FirebirdDB\SECURITY_PROJECT.FDB" USER 'didik' PASSWORD 'pwd_didik';
```

#### Pengujian:

```sql
-- SUKSES: Didik dapat melihat data pegawai
SELECT * FROM employees;

-- SUKSES: Didik dapat mengubah kolom 'name'
UPDATE employees SET name = 'DIDIK EDIT' WHERE id = 2;
COMMIT;

-- GAGAL: Didik tidak dapat mengubah kolom 'role'
-- Perintah ini akan menghasilkan error "no permission for update access to column ROLE"
UPDATE employees SET role = 'Manager' WHERE id = 2;
```

### 🧑‍💻 Sesi sebagai zahra (Staf Absensi)

Login kembali sebagai zahra.

```sh
isql
CONNECT "C:\FirebirdDB\SECURITY_PROJECT.FDB" USER 'zahra' PASSWORD 'pwd_zahra';
```

#### Pengujian:

```sql
-- SUKSES: Zahra dapat melihat data absensi
SELECT * FROM attendance;

-- SUKSES: Zahra dapat menambah data absensi baru
INSERT INTO attendance VALUES (2, 2, CURRENT_DATE, 'Present');
COMMIT;

-- GAGAL: Zahra tidak dapat mengakses tabel pegawai
-- Perintah ini akan menghasilkan error "no permission for read/select access to table EMPLOYEES"
SELECT * FROM employees;
```

### 🧑‍💻 Sesi sebagai arsya (Staf Audit Absensi)

Login kembali sebagai arsya.

```bash
isql
CONNECT "C:\FirebirdDB\SECURITY_PROJECT.FDB" USER 'arsya' PASSWORD 'pwd_arsya';
```

#### Pengujian:

```sql
-- SUKSES: Arsya dapat melihat data absensi
SELECT * FROM attendance;

-- SUKSES: Arsya dapat menghapus data absensi
DELETE FROM attendance WHERE id = 1;
COMMIT;

-- GAGAL: Arsya tidak dapat menambah data absensi
-- Perintah ini akan menghasilkan error "no permission for insert access to table ATTENDANCE"
INSERT INTO attendance VALUES (3, 1, CURRENT_DATE, 'Late');
```

### 🧑‍💻 Sesi sebagai rozhak (Supervisor)

Login kembali sebagai rozhak.

```bash
isql
CONNECT "C:\FirebirdDB\SECURITY_PROJECT.FDB" USER 'rozhak' PASSWORD 'pwd_rozhak';
```

#### Pengujian:

```sql
-- SUKSES: Rozhak dapat melihat data pegawai
SELECT * FROM employees;

-- SUKSES: Rozhak dapat melihat data absensi
SELECT * FROM attendance;

-- GAGAL: Rozhak tidak dapat menghapus data
-- Perintah ini akan menghasilkan error "no permission for delete access to table EMPLOYEES"
DELETE FROM employees WHERE id = 1;
```

### 6. Pencabutan Hak Akses (REVOKE)

`REVOKE` digunakan untuk menghapus hak akses yang sebelumnya telah diberikan.

**Skenario:** Hak akses `SELECT` untuk user `rozhak` pada tabel `employees` akan dicabut.

### 1. Jalankan Perintah `REVOKE` (sebagai `SYSDBA`):

```bash
-- Login sebagai SYSDBA terlebih dahulu
isql -user 'SYSDBA' -password 'masterkey' "C:\FirebirdDB\SECURITY_PROJECT.FDB"
```

```sql
-- Cabut hak akses
REVOKE SELECT ON employees FROM rozhak;
COMMIT;
EXIT;
```

### 2. Uji Akses Setelah `REVOKE`:

Login kembali sebagai `rozhak`.

```bash
isql
CONNECT "C:\FirebirdDB\SECURITY_PROJECT.FDB" USER 'rozhak' PASSWORD 'pwd_rozhak';
```

#### Pengujian:

```sql
-- GAGAL: Rozhak tidak lagi bisa melihat data employees
-- Perintah ini akan menghasilkan error "no permission for read/select access to table EMPLOYEES"
SELECT * FROM employees;

-- SUKSES: Hak akses untuk tabel attendance masih ada
SELECT * FROM attendance;
```

## 7. Skrip SQL Lengkap

Seluruh perintah yang digunakan dalam proyek ini telah dirangkum dalam file `Firebird_Security_Project.sql` untuk kemudahan eksekusi.

## 8. Lisensi

Proyek ini dilisensikan di bawah MIT License. Lihat file `LICENSE` untuk detail lebih lanjut.