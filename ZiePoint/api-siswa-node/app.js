const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");
const bodyParser = require("body-parser");

const app = express();
app.use(cors());
app.use(bodyParser.json());

// --- KONEKSI KE MYSQL ---
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "db_sekolah",
});

db.connect((err) => {
  if (err) {
    console.error("Database Tidak Terhubung!", err);
    return;
  }
  console.log("Terhubung ke MySQL!");
});

// --- ROUTES ---

// 1. GET All Siswa
app.get("/siswa", (req, res) => {
  db.query("SELECT * FROM siswa", (err, results) => {
    if (err) return res.status(500).send(err);
    res.json(results);
  });
});

// 2. GET Siswa by ID
app.get("/siswa/:id", (req, res) => {
  const { id } = req.params;
  db.query("SELECT * FROM siswa WHERE id = ?", [id], (err, results) => {
    if (err) return res.status(500).send(err);
    if (results.length === 0) return res.status(404).json({ message: "Siswa tidak ditemukan!" });
    res.json(results[0]);
  });
});

// 3. POST Siswa (Tambah Data)
app.post("/siswa", (req, res) => {
  const { nama, kelas, nis } = req.body;
  const sql = "INSERT INTO siswa (nama, kelas, nis) VALUES (?, ?, ?)";
  db.query(sql, [nama, kelas, nis], (err, result) => {
    if (err) return res.status(500).send(err);
    res.json({ message: "Data masuk!", id: result.insertId });
  });
});

// 4. PUT Siswa (Update Data)
app.put("/siswa/:id", (req, res) => {
  const { id } = req.params;
  const { nama, kelas, nis } = req.body;
  const sql = "UPDATE siswa SET nama = ?, kelas = ?, nis = ? WHERE id = ?";
  db.query(sql, [nama, kelas, nis, id], (err, result) => {
    if (err) return res.status(500).send(err);
    res.json({ message: "Data diperbarui!" });
  });
});

// 5. DELETE Siswa
app.delete("/siswa/:id", (req, res) => {
  const { id } = req.params;
  db.query("DELETE FROM siswa WHERE id = ?", [id], (err) => {
    if (err) return res.status(500).send(err);
    res.json({ message: "Data dihapus!" });
  });
});

// Get Jenis Catatan Berdasarkan Tipe
app.get("/jenis_catatan/:tipe", (req, res) => {
  const { tipe } = req.params;

  const sql = "SELECT * FROM jenis_catatan WHERE tipe = ?";
  db.query(sql, [tipe], (err, results) => {
    if (err) return res.status(500).send(err);
    res.json(results);
  });
});

// --- TRANSAKSI CATATAN SISWA ---

// 1. GET Riwayat Pelanggaran Siswa Tertentu
app.get("/catatan_siswa/siswa/:id", (req, res) => {
  const { id } = req.params;
  const sql = `
    SELECT c.*, j.nama AS nama_pelanggaran, j.poin
    FROM catatan_siswa c
    JOIN jenis_catatan j ON c.id_jenis = j.id_jenis
    WHERE c.id_siswa = ?
    ORDER BY c.tanggal DESC
  `;
  db.query(sql, [id], (err, results) => {
    if (err) return res.status(500).send(err);
    res.json(results);
  });
});

// 2. POST Catatan Siswa (Merekam Pelanggaran Baru)
app.post("/catatan_siswa", (req, res) => {
  const { id_siswa, id_jenis, keterangan } = req.body;
  const sql = "INSERT INTO catatan_siswa (id_siswa, id_jenis, tanggal, keterangan) VALUES (?, ?, CURDATE(), ?)";
  db.query(sql, [id_siswa, id_jenis, keterangan || null], (err, result) => {
    if (err) return res.status(500).send(err);
    res.json({ message: "Transaksi pelanggaran berhasil dicatat!", id: result.insertId });
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server jalan di port ${PORT}`);
});