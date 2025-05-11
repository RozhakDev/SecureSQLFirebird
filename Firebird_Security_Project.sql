
-- SISTEM BASIS DATA — Keamanan & Hak Akses (Firebird SQL)

-- 1. Buat Database
CREATE DATABASE 'C:\FirebirdDB\SECURITY_PROJECT.FDB' 
USER 'SYSDBA' PASSWORD 'masterkey';

-- 2. Buat Tabel
CREATE TABLE employees (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    role VARCHAR(30)
);

CREATE TABLE attendance (
    id INT PRIMARY KEY,
    employee_id INT,
    attend_date DATE,
    status VARCHAR(20)
);

COMMIT;

-- 3. Masukkan Data Awal
INSERT INTO employees VALUES (1, 'MAULANA', 'Admin');
INSERT INTO employees VALUES (2, 'ZAHRA', 'Staff');

INSERT INTO attendance VALUES (1, 1, CURRENT_DATE, 'Present');
COMMIT;

-- 4. Pembuatan User
CREATE USER maulana PASSWORD 'pwd_maulana';
CREATE USER didik PASSWORD 'pwd_didik';
CREATE USER zahra PASSWORD 'pwd_zahra';
CREATE USER arsya PASSWORD 'pwd_arsya';
CREATE USER rozhak PASSWORD 'pwd_rozhak';
COMMIT;

-- 5. Pemberian Hak Akses
GRANT SELECT, INSERT ON employees TO maulana;

GRANT SELECT, INSERT ON attendance TO zahra;

GRANT UPDATE (name) ON employees TO didik;
GRANT SELECT ON employees TO didik;

GRANT DELETE, SELECT ON attendance TO arsya;

GRANT SELECT ON employees TO rozhak;
GRANT SELECT ON attendance TO rozhak;

COMMIT;

-- 6. REVOKE Hak Akses
REVOKE SELECT ON employees FROM rozhak;
COMMIT;