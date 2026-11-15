-- =====================================================================
-- TUGAS BESAR REKAYASA SISTEM INFORMASI
-- KELOMPOK E - SIMT KURNIA FURNITURE BOGOR
-- FILE: dbDesign_kelE.sql
-- =====================================================================
-- CATATAN PENTING:
-- Seluruh data yang di-insert ke dalam tabel di bawah ini (seperti data
-- pelanggan, proyek, dan transaksi keuangan) adalah DATA DUMMY (fiktif).
-- Data ini dibuat hanya untuk keperluan simulasi query dan pengujian.
-- Apabila di kemudian hari sistem ini diimplementasikan secara nyata
-- dan mendapatkan izin (otorisasi) dari pihak manajemen Kurnia Furniture,
-- maka data dummy ini akan dihapus (TRUNCATE) dan digantikan dengan
-- dataset resmi (data riil dari perusahaan).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. CREATE DATABASE
-- ---------------------------------------------------------------------
CREATE DATABASE simt_kurnia_furniture;
-- (Catatan: Jika menjalankan file ini di pgAdmin, 
-- pastikan untuk pindah ke database simt_kurnia_furniture sebelum mengeksekusi tabel di bawahnya)

-- ---------------------------------------------------------------------
-- 2. CREATE TABLES (DDL)
-- ---------------------------------------------------------------------
CREATE TABLE roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role_id INT REFERENCES roles(role_id),
    deleted_at TIMESTAMP NULL
);

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    address TEXT
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_code VARCHAR(20) UNIQUE NOT NULL,
    project_name VARCHAR(100) NOT NULL,
    customer_id INT REFERENCES customers(customer_id),
    start_date DATE NOT NULL,
    status VARCHAR(30) DEFAULT 'Planning' -- Planning, In Production, Completed
);

CREATE TABLE budget_plans (
    budget_id SERIAL PRIMARY KEY,
    project_id INT REFERENCES projects(project_id),
    material_cost NUMERIC(15,2) NOT NULL,
    labor_cost NUMERIC(15,2) NOT NULL,
    total_cost NUMERIC(15,2) GENERATED ALWAYS AS (material_cost + labor_cost) STORED,
    status VARCHAR(30) DEFAULT 'Draft' -- Draft, Approved, Rejected
);

CREATE TABLE materials (
    material_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    price NUMERIC(15,2) NOT NULL,
    stock INT NOT NULL
);

CREATE TABLE financial_transactions (
    transaction_id SERIAL PRIMARY KEY,
    project_id INT REFERENCES projects(project_id),
    date DATE NOT NULL,
    type VARCHAR(10) CHECK (type IN ('Income', 'Expense')),
    amount NUMERIC(15,2) NOT NULL,
    description TEXT,
    status VARCHAR(30) DEFAULT 'Approved'
);

CREATE TABLE attendances (
    attendance_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    date DATE NOT NULL,
    status VARCHAR(20) -- Present, Late, Absent
);

CREATE TABLE payrolls (
    payroll_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    period VARCHAR(7) NOT NULL, -- Format: YYYY-MM
    basic_salary NUMERIC(15,2) NOT NULL,
    allowance NUMERIC(15,2) DEFAULT 0,
    total_salary NUMERIC(15,2) NOT NULL,
    status VARCHAR(30) DEFAULT 'Pending'
);

-- ---------------------------------------------------------------------
-- 3. INSERT DATA DUMMY (DML)
-- ---------------------------------------------------------------------
-- Data Master
INSERT INTO roles (role_name) VALUES ('Sales'), ('Admin RAB'), ('Manager'), ('Finance'), ('Owner');

-- Data Customers & Projects
INSERT INTO customers (name, phone, address) VALUES 
('Budi Santoso', '081234567890', 'Jl. Sudirman No. 10, Jakarta'),
('Siti Aminah', '085712345678', 'Perumahan Indah Blok C, Bogor');

INSERT INTO projects (project_code, project_name, customer_id, start_date, status) VALUES 
('PRJ-202608-0001', 'Meja Makan Jati Custom', 1, '2026-08-01', 'Completed'),
('PRJ-202609-0002', 'Kitchen Set Minimalis', 2, '2026-09-15', 'In Production');

-- Data RAB & Lainnya
INSERT INTO budget_plans (project_id, material_cost, labor_cost, status) VALUES 
(1, 15000000.00, 5000000.00, 'Approved'),
(2, 30000000.00, 10000000.00, 'Approved');

-- Data Transaksi 3 Bulan (30 Data)
-- Campuran Income (DP/Pelunasan) dan Expense (Beli Material/Gaji)
INSERT INTO financial_transactions (project_id, date, type, amount, description) VALUES 
(1, '2026-08-02', 'Income', 10000000.00, 'DP Proyek 1 (50%)'),
(1, '2026-08-05', 'Expense', 7500000.00, 'Beli Kayu Jati'),
(1, '2026-08-10', 'Expense', 2500000.00, 'Beli Finishing Cat'),
(1, '2026-08-15', 'Expense', 2000000.00, 'Upah Tukang Minggu 1'),
(1, '2026-08-20', 'Expense', 3000000.00, 'Upah Tukang Minggu 2'),
(1, '2026-08-25', 'Income', 10000000.00, 'Pelunasan Proyek 1'),
(1, '2026-09-01', 'Expense', 1500000.00, 'Pengiriman & Instalasi'),
(2, '2026-09-15', 'Income', 20000000.00, 'DP Proyek 2 (50%)'),
(2, '2026-09-16', 'Expense', 12000000.00, 'Beli Multiplek & HPL'),
(2, '2026-09-20', 'Expense', 4000000.00, 'Beli Hardware (Engsel, Rel)'),
(1, '2026-09-22', 'Expense', 1000000.00, 'Maintenance tools'),
(2, '2026-09-25', 'Expense', 3000000.00, 'Upah Tukang Minggu 1'),
(2, '2026-09-30', 'Expense', 500000.00, 'Konsumsi Tukang'),
(2, '2026-10-01', 'Expense', 3500000.00, 'Upah Tukang Minggu 2'),
(2, '2026-10-05', 'Expense', 1500000.00, 'Beli Aksesoris Kabinet'),
(2, '2026-10-10', 'Expense', 2000000.00, 'Sewa Mesin Profil'),
(2, '2026-10-15', 'Income', 5000000.00, 'Termin 2 Proyek 2'),
(2, '2026-10-18', 'Expense', 1500000.00, 'Beli Lem & Sealant'),
(2, '2026-10-20', 'Expense', 2000000.00, 'Upah Tukang Minggu 3'),
(2, '2026-10-22', 'Expense', 500000.00, 'Bensin Kendaraan Operasional'),
(2, '2026-10-25', 'Expense', 1000000.00, 'Servis Gergaji Mesin'),
(2, '2026-10-28', 'Expense', 2500000.00, 'Upah Tukang Minggu 4'),
(1, '2026-10-29', 'Expense', 300000.00, 'Biaya Tak Terduga Proyek 1'),
(2, '2026-10-30', 'Income', 5000000.00, 'Termin 3 Proyek 2'),
(1, '2026-10-30', 'Expense', 400000.00, 'Pengecatan Ulang'),
(2, '2026-10-31', 'Expense', 1000000.00, 'Pembersihan Gudang'),
(1, '2026-09-10', 'Expense', 500000.00, 'Beli Sekrup & Paku'),
(2, '2026-09-18', 'Expense', 800000.00, 'Sewa Scaffolding'),
(2, '2026-10-12', 'Expense', 600000.00, 'Beli Lampu LED Kabinet'),
(2, '2026-10-20', 'Expense', 700000.00, 'Beli Glass Kaca');

-- ---------------------------------------------------------------------
-- 4. QUERY SQL DASAR (SELECT, FROM, WHERE)
-- ---------------------------------------------------------------------
-- Query 4.1: Mencari semua transaksi pengeluaran (Expense) di bulan Oktober 2026
SELECT transaction_id, date, amount, description
FROM financial_transactions
WHERE type = 'Expense' 
  AND date >= '2026-10-01' 
  AND date <= '2026-10-31';

-- Query 4.2: Mencari proyek yang sedang berjalan beserta nama customernya
SELECT p.project_code, p.project_name, c.name AS customer_name, p.start_date
FROM projects p
JOIN customers c ON p.customer_id = c.customer_id
WHERE p.status = 'In Production';

-- ---------------------------------------------------------------------
-- 5. QUERY SQL ANALITIK (GROUP BY & HAVING)
-- ---------------------------------------------------------------------
-- Query 5.1: Menghitung Total Pemasukan dan Pengeluaran per Bulan
SELECT 
    TO_CHAR(date, 'YYYY-MM') AS periode_bulan,
    SUM(CASE WHEN type = 'Income' THEN amount ELSE 0 END) AS total_pemasukan,
    SUM(CASE WHEN type = 'Expense' THEN amount ELSE 0 END) AS total_pengeluaran,
    (SUM(CASE WHEN type = 'Income' THEN amount ELSE 0 END) - SUM(CASE WHEN type = 'Expense' THEN amount ELSE 0 END)) AS laba_bersih
FROM financial_transactions
GROUP BY TO_CHAR(date, 'YYYY-MM')
ORDER BY periode_bulan;

-- Query 5.2: Mencari Proyek yang Total Pengeluarannya Melebihi Rp 5.000.000
SELECT 
    p.project_code,
    p.project_name,
    SUM(t.amount) AS total_pengeluaran
FROM financial_transactions t
JOIN projects p ON t.project_id = p.project_id
WHERE t.type = 'Expense'
GROUP BY p.project_code, p.project_name
HAVING SUM(t.amount) > 5000000
ORDER BY total_pengeluaran DESC;

-- Query 5.3: Analitik Kinerja Proyek (Margin Keuntungan)
SELECT 
    p.project_code,
    p.project_name,
    SUM(CASE WHEN t.type = 'Income' THEN t.amount ELSE 0 END) AS pendapatan,
    SUM(CASE WHEN t.type = 'Expense' THEN t.amount ELSE 0 END) AS biaya,
    (SUM(CASE WHEN t.type = 'Income' THEN t.amount ELSE 0 END) - SUM(CASE WHEN t.type = 'Expense' THEN t.amount ELSE 0 END)) AS profit
FROM projects p
JOIN financial_transactions t ON p.project_id = t.project_id
GROUP BY p.project_code, p.project_name
HAVING (SUM(CASE WHEN t.type = 'Income' THEN t.amount ELSE 0 END) - SUM(CASE WHEN t.type = 'Expense' THEN t.amount ELSE 0 END)) > 0;

-- =====================================================================
-- END OF FILE
-- =====================================================================