# 🌿 EcoSim Desa

<div align="center">
  <img src="ecosim_flutter/assets/images/logo.png" alt="EcoSim Logo" width="120"/>
  
  <br/>
  
  <p><strong>Aplikasi Simulasi Ekosistem Desa Berbasis Kecerdasan Buatan</strong></p>
  <p>Platform perencanaan lingkungan cerdas yang membantu perangkat desa menganalisis kondisi lingkungan dan merancang program pembangunan berbasis data.</p>
  
  <br/>

  ![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
  ![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
  ![Node.js](https://img.shields.io/badge/Node.js-18.x-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
  ![TypeScript](https://img.shields.io/badge/TypeScript-5.x-3178C6?style=for-the-badge&logo=typescript&logoColor=white)
  ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15.x-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
  ![Gemini AI](https://img.shields.io/badge/Gemini_AI-Google-4285F4?style=for-the-badge&logo=google&logoColor=white)

  <br/>

  ![Android](https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white)
  ![iOS](https://img.shields.io/badge/Platform-iOS-000000?style=flat-square&logo=apple&logoColor=white)
  ![Build](https://img.shields.io/github/actions/workflow/status/nabil142/NIC-Software_Development/build.yml?style=flat-square&label=CI%2FCD%20Build)

</div>

---

## 📱 Tentang Aplikasi

**EcoSim Desa** adalah aplikasi mobile lintas platform (Android & iOS) yang dirancang untuk membantu perangkat desa dan pemangku kepentingan dalam:

- 🔍 **Menilai kondisi lingkungan** desa secara terstruktur melalui asesmen digital
- 🤖 **Mendapatkan rekomendasi solusi AI** berdasarkan data lingkungan yang diinput
- 📊 **Mensimulasikan skenario program** dan melihat proyeksi dampak lingkungannya
- 📜 **Membuat blueprint narasi** program desa secara otomatis siap cetak
- 📈 **Menganalisis kebijakan** dengan perspektif ahli berbasis AI

---

## ✨ Fitur Unggulan

| Fitur | Deskripsi |
|-------|-----------|
| 🏘️ **Profil Desa** | Input dan simpan data desa (nama, populasi, luas wilayah, potensi) |
| 📋 **Asesmen Lingkungan** | Penilaian 6 indikator: pengelolaan sampah, kualitas air, ruang hijau, risiko banjir, dan lainnya |
| 🤖 **Analisis AI Otomatis** | Deteksi masalah potensial & rekomendasi solusi dari Google Gemini AI |
| 🎯 **Simulator Skenario** | Pilih kombinasi program, lihat proyeksi skor kesehatan lingkungan sebelum & sesudah |
| 📊 **Policy Analyst** | Laporan analisis kebijakan mendalam dalam format ilmiah |
| 📝 **Blueprint Narasi** | Dokumen narasi program siap cetak untuk pengajuan proposal |
| 📈 **Laporan Ringkasan** | Visualisasi grafik perbandingan baseline vs proyeksi program |
| 🔐 **Multi-Auth** | Login dengan Email, Google, dan Apple (Sign in with Apple) |
| 🗑️ **Hapus Akun** | Fitur penghapusan akun permanen sesuai standar App Store |

---

## 🏗️ Arsitektur Sistem

```
┌─────────────────────────────────────────────────────────┐
│                    FLUTTER APP (Mobile)                 │
│         Android  ─────────────  iOS (TestFlight)        │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │  Auth    │  │ Village  │  │ Scenario │             │
│  │  Feature │  │ Feature  │  │ Feature  │  ...        │
│  └──────────┘  └──────────┘  └──────────┘             │
│         State Management: Riverpod                      │
│         Navigation: Go Router                           │
└──────────────────────┬──────────────────────────────────┘
                       │ REST API (Dio / HTTPS)
┌──────────────────────▼──────────────────────────────────┐
│              NODE.JS BACKEND (Express + TypeScript)     │
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │  Auth Routes │  │Village Routes│  │Scenario Routes│ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│              JWT Middleware (Authentication)             │
│              Prisma ORM                                 │
└──────────────────────┬──────────────────────────────────┘
           ┌───────────┴───────────┐
           ▼                       ▼
  ┌─────────────────┐    ┌──────────────────────┐
  │   PostgreSQL    │    │   Google Gemini AI   │
  │   (Database)    │    │   (AI Analysis API)  │
  └─────────────────┘    └──────────────────────┘
```

---

## 🗂️ Struktur Repositori

```
NIC-Software_Development/
│
├── ecosim_flutter/          # 📱 Aplikasi Flutter (Frontend)
│   ├── lib/
│   │   ├── core/            # Theme, network, shared widgets
│   │   └── features/        # Fitur-fitur aplikasi
│   │       ├── auth/        # Autentikasi (Login, Register, Apple, Google)
│   │       ├── village/     # Profil Desa
│   │       ├── assessment/  # Asesmen Lingkungan
│   │       └── scenario/    # Skenario, Analyst, Blueprint
│   ├── ios/                 # Konfigurasi iOS (Xcode)
│   └── android/             # Konfigurasi Android (Gradle)
│
├── ecosim_backend/          # 🖥️ Server Node.js (Backend)
│   ├── src/
│   │   ├── controllers/     # Logic bisnis (auth, village, assessment, scenario)
│   │   ├── middlewares/     # JWT auth middleware
│   │   └── app.ts           # Entry point Express server
│   └── prisma/
│       └── schema.prisma    # Skema basis data
│
└── .github/
    └── workflows/
        └── build.yml        # CI/CD Pipeline (Build APK + IPA + Deploy)
```

---

## 🛠️ Tech Stack

### Frontend
- **Flutter** — Framework mobile lintas platform
- **Riverpod** — State management
- **Go Router** — Navigasi
- **Dio** — HTTP client
- **FL Chart** — Visualisasi grafik
- **Google Sign In & Sign In with Apple** — Autentikasi SSO

### Backend
- **Node.js + Express.js** — Server & REST API
- **TypeScript** — Bahasa pemrograman bertipe statis
- **Prisma ORM + PostgreSQL** — Basis data
- **JWT + bcryptjs** — Autentikasi & enkripsi

### AI & Cloud
- **Google Gemini AI** — Analisis lingkungan, rekomendasi, & generasi narasi
- **GitHub Actions** — CI/CD otomatis (build APK + IPA)
- **Apple TestFlight** — Distribusi Beta iOS

---

## 🚀 Cara Menjalankan Proyek

### Prasyarat
- Flutter SDK 3.x (stable)
- Node.js 18.x LTS
- PostgreSQL 15.x
- API Key Google Gemini AI

### 1. Clone Repositori
```bash
git clone https://github.com/nabil142/NIC-Software_Development.git
cd NIC-Software_Development
```

### 2. Setup Backend
```bash
cd ecosim_backend

# Install dependencies
npm install

# Buat file environment
cp .env.example .env.development
# Isi DATABASE_URL dan GEMINI_API_KEY di file .env.development

# Jalankan migrasi database
npx prisma migrate dev

# Jalankan server
npm run dev
```

### 3. Setup Flutter
```bash
cd ../ecosim_flutter

# Install dependencies
flutter pub get

# Jalankan aplikasi (pastikan emulator/device terhubung)
flutter run
```

---

## 🔧 Variabel Lingkungan (Environment Variables)

Buat file `.env.development` di folder `ecosim_backend/` dengan isi berikut:

```env
DATABASE_URL="postgresql://USER:PASSWORD@HOST:PORT/DATABASE"
JWT_SECRET="your_super_secret_jwt_key"
GEMINI_API_KEY="your_gemini_api_key"
NODE_ENV="development"
PORT=5000
```

---

## ⚙️ CI/CD Pipeline

Proyek ini menggunakan **GitHub Actions** untuk otomasi proses *build* dan distribusi:

```
Push ke branch main
       │
       ├──► Build APK (Android Release)
       │         └── Upload artifact APK
       │
       └──► Build IPA (iOS Release)
                 └── Upload ke Apple TestFlight
```

Secrets yang diperlukan di GitHub Repository:
| Secret | Deskripsi |
|--------|-----------|
| `CERTIFICATE_BASE64` | Sertifikat distribusi iOS (.p12) dalam format Base64 |
| `CERTIFICATE_PASSWORD` | Password sertifikat .p12 |
| `PROVISIONING_PROFILE_BASE64` | Provisioning Profile (.mobileprovision) dalam format Base64 |
| `APP_STORE_CONNECT_API_KEY_BASE64` | API Key App Store Connect (.p8) dalam format Base64 |
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID dari App Store Connect |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID dari App Store Connect |

---


---

## 👥 Tim Pengembang

**NIC Team** — Kompetisi Nasional Informatika / Software Development

| Nama | Peran |
|------|-------|
| Andien Oktriarahmah | Project Lead |
| Nabil Athaya | Full-Stack Developer |
| Reza Pratama | UI/UX Design |

---

## 📄 Lisensi

Proyek ini dikembangkan untuk keperluan lomba.  
© 2026 New Dawn Team. All Rights Reserved.

---

<div align="center">
  <sub>Dibuat dengan ❤️ menggunakan Flutter & Node.js</sub>
  <br/>
  <sub>Powered by Google Gemini AI</sub>
</div>
