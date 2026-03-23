# Yana OS — Enterprise EV Rider & Fleet Platform

> Unified platform for Rider + Fleet + Demand management  
> Stack: Django · PostgreSQL · Redis · Celery · Flutter · React · Docker

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Prerequisites](#prerequisites)
3. [Project Structure](#project-structure)
4. [Quick Start — Local (Docker)](#quick-start--local-docker)
5. [Backend — Django Setup](#backend--django-setup)
6. [Flutter Rider App Setup](#flutter-rider-app-setup)
7. [Frontend Admin Setup](#frontend-admin-setup)
8. [API Documentation](#api-documentation)
9. [Environment Variables Reference](#environment-variables-reference)
10. [Module Roadmap](#module-roadmap)
11. [Production Deployment](#production-deployment)
12. [Troubleshooting](#troubleshooting)

---

## Architecture Overview

```
Clients
  ├── Flutter Rider App (iOS + Android)
  ├── React Admin Dashboard (Ops / Sales / Admin)
  └── React Ops Lite App

         ↓ HTTPS / REST / WebSocket

    Nginx Reverse Proxy
         ↓
    API Gateway (Django REST Framework)
         ↓
┌────────────────────────────────────────────────────┐
│  Django Services (modular apps)                    │
│  onboarding · fleet · payments · marketplace       │
│  sales · maintenance · support · skilldev          │
└────────────────────────────────────────────────────┘
         ↓
    Celery + Redis (async tasks, scheduler)
         ↓
    Data Layer
      PostgreSQL · Redis Cache · MinIO (S3) · Elasticsearch
         ↓
    Integrations
      Razorpay · Digilocker/Karza · Google Maps · Firebase/WhatsApp
```

---

## Prerequisites

Install all of these before starting:

| Tool | Minimum Version | Download |
|------|----------------|---------|
| Docker Desktop | 24.x | https://www.docker.com/products/docker-desktop |
| Docker Compose | v2.x (bundled with Desktop) | — |
| Python | 3.12 | https://www.python.org/downloads/ |
| Flutter SDK | 3.19+ | https://docs.flutter.dev/get-started/install |
| Android Studio | 2023.x | https://developer.android.com/studio |
| Xcode (macOS only) | 15+ | Mac App Store |
| Node.js | 20 LTS | https://nodejs.org |
| Git | any | https://git-scm.com |

### Verify installations
```bash
docker --version          # Docker version 24.x
docker compose version    # Docker Compose version v2.x
python3 --version         # Python 3.12.x
flutter doctor            # Should show all green (or acceptable warnings)
node --version            # v20.x
```

---

## Project Structure

```
yana-os/
├── backend/                    # Django API
│   ├── apps/
│   │   ├── core/               # Custom User model, OTP auth
│   │   ├── onboarding/         # ★ Module 1: Rider onboarding & KYC
│   │   ├── fleet/              # ★ Module 2: Vehicles, hubs, allocations
│   │   ├── payments/           # Wallet, transactions, Razorpay
│   │   ├── marketplace/        # Job demand & rider matching
│   │   ├── sales/              # CRM, clients, demand creation
│   │   ├── maintenance/        # Vehicle service logs & alerts
│   │   ├── support/            # Tickets & WhatsApp fallback
│   │   └── skilldev/           # Training videos & gamification
│   ├── config/
│   │   ├── settings/
│   │   │   ├── base.py
│   │   │   ├── local.py
│   │   │   └── production.py
│   │   ├── urls.py
│   │   ├── celery.py
│   │   └── wsgi.py
│   ├── Dockerfile
│   ├── manage.py
│   └── requirements.txt
│
├── flutter-rider/              # Flutter Rider App
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/
│   │   │   ├── api_client.dart  # Dio + JWT interceptor
│   │   │   └── router.dart      # GoRouter navigation
│   │   ├── shared/
│   │   │   ├── theme/           # AppTheme
│   │   │   └── widgets/         # YanaButton, StatusBadge, MainShell
│   │   └── features/
│   │       ├── onboarding/      # Splash, OTP, Profile, KYC, Status
│   │       ├── vehicle/         # Vehicle list & booking
│   │       ├── payments/        # Wallet & transactions
│   │       ├── support/         # Tickets & WhatsApp
│   │       └── skilldev/        # Training videos & gamification
│   └── pubspec.yaml
│
├── frontend-admin/             # React Admin Dashboard (Phase 2)
│   └── Dockerfile
│
├── nginx/
│   └── nginx.conf              # Reverse proxy config
│
├── docker/
│   └── postgres/
│       └── init.sql            # DB extensions initialization
│
├── docker-compose.yml          # Full stack orchestration
├── .env.example                # Environment variables template
└── README.md                   # This file
```

---

## Quick Start — Local (Docker)

This spins up the entire backend stack (Django + PostgreSQL + Redis + MinIO + Celery + Nginx) with a single command.

### Step 1 — Clone and configure

```bash
git clone <your-repo-url> yana-os
cd yana-os

# Copy environment template
cp .env.example .env

# Open .env and set at minimum:
#   SECRET_KEY=<any long random string>
#   RAZORPAY_KEY_ID and RAZORPAY_SECRET (get from razorpay.com/dashboard)
nano .env    # or code .env, vim .env, etc.
```

### Step 2 — Build and start all services

```bash
docker compose up --build
```

This will:
- Pull Postgres 16, Redis 7, MinIO images
- Build the Django container and install all Python dependencies
- Run `python manage.py migrate` (creates all tables)
- Run `python manage.py collectstatic`
- Start Gunicorn (Django API) on port 8000
- Start Celery worker and Celery Beat scheduler
- Start Nginx reverse proxy on port 80
- Start MinIO object storage on port 9000

### Step 3 — Create superuser

```bash
# In a new terminal (while services are running):
docker compose exec backend python manage.py createsuperuser
```

### Step 4 — Access the services

| Service | URL | Credentials |
|---------|-----|-------------|
| Django Admin | http://localhost/admin/ | Superuser you just created |
| API (Swagger) | http://localhost/api/docs/ | — |
| API root | http://localhost/api/ | JWT Bearer token |
| MinIO Console | http://localhost:9001 | yana_minio / yana_minio_pass |
| PostgreSQL | localhost:5432 | yana_user / yana_secure_pass |
| Redis | localhost:6379 | — |

### Step 5 — Seed demo data (optional)

```bash
docker compose exec backend python manage.py loaddata fixtures/demo_data.json
```

### Stop services

```bash
docker compose down          # stop but keep data
docker compose down -v       # stop and DELETE all data volumes
```

---

## Backend — Django Setup

### Running without Docker (for development)

```bash
cd backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate        # macOS/Linux
# OR: venv\Scripts\activate     # Windows

# Install dependencies
pip install -r requirements.txt

# Set environment (point to local postgres/redis)
export DJANGO_SETTINGS_MODULE=config.settings.local
export DB_HOST=localhost
export REDIS_URL=redis://localhost:6379/0
export SECRET_KEY=dev-secret-key

# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Start development server
python manage.py runserver
```

### Run Celery worker (separate terminal)

```bash
cd backend
source venv/bin/activate
celery -A config worker --loglevel=info
```

### Run Celery Beat (separate terminal)

```bash
cd backend
source venv/bin/activate
celery -A config beat --loglevel=info --scheduler django_celery_beat.schedulers:DatabaseScheduler
```

### Key API endpoints

#### Authentication
```
POST /api/auth/otp/request/     → { phone_number }
POST /api/auth/otp/verify/      → { phone_number, otp } → { access, refresh, user }
POST /api/auth/token/refresh/   → { refresh } → { access }
GET  /api/auth/me/              → current user profile
```

#### Onboarding
```
POST   /api/onboarding/riders/                      Create rider profile
GET    /api/onboarding/riders/                      List riders (ops/admin)
GET    /api/onboarding/riders/{id}/                 Rider detail
POST   /api/onboarding/riders/{id}/upload_document/ Upload KYC doc
POST   /api/onboarding/riders/{id}/verify/          Approve/reject KYC
POST   /api/onboarding/riders/{id}/activate/        Activate rider
GET    /api/onboarding/riders/{id}/events/          Audit trail
GET    /api/onboarding/riders/stats/                Status counts
```

#### Fleet
```
GET    /api/fleet/hubs/                 List all hubs
GET    /api/fleet/vehicles/             List vehicles (filter: ?status=available&hub=<id>)
GET    /api/fleet/vehicles/available/   Available vehicles only
GET    /api/fleet/vehicles/stats/       Fleet health stats
POST   /api/fleet/allocations/allocate/ Allocate vehicle to rider
POST   /api/fleet/allocations/{id}/return_vehicle/  Return vehicle
```

#### Payments
```
GET    /api/payments/wallets/           Rider wallet info
```

---

## Flutter Rider App Setup

### Prerequisites check
```bash
flutter doctor -v
# Required: Flutter SDK, Android toolchain, Chrome (for web)
# Optional: Xcode (for iOS build on Mac)
```

### Step 1 — Install dependencies

```bash
cd flutter-rider
flutter pub get
```

### Step 2 — Configure API URL

The app talks to the backend. Configure the URL for your environment:

**Android Emulator** (default — already set):
- URL: `http://10.0.2.2:8000/api`
- `10.0.2.2` is the special Android emulator IP that maps to your laptop's `localhost`

**Physical Android Device** (on same WiFi):
```bash
# Find your laptop's local IP
ifconfig | grep "inet "   # macOS/Linux
ipconfig                  # Windows

# Edit lib/core/api_client.dart, change:
defaultValue: 'http://YOUR_LAPTOP_IP:8000/api'
```

**iOS Simulator** (Mac only):
```bash
# localhost works directly on iOS simulator
# Change defaultValue to: 'http://localhost:8000/api'
```

### Step 3 — Run on Android Emulator

```bash
# Start Android Emulator first (from Android Studio → Device Manager → Play button)

# Verify device detected
flutter devices

# Run the app
flutter run
```

### Step 4 — Run on Physical Device

```bash
# Enable Developer Options on your Android phone:
# Settings → About Phone → tap "Build Number" 7 times
# Settings → Developer Options → Enable "USB Debugging"

# Connect via USB cable
adb devices    # Should show your device

flutter run    # Automatically picks up connected device
```

### Step 5 — Build APK for distribution

```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK (for production)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# App Bundle for Play Store
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Step 6 — Run on iOS (Mac only)

```bash
# Open in Xcode to set signing
open ios/Runner.xcworkspace

# Set: Team → your Apple Developer account
# Bundle ID → com.yana.rider (must match your provisioning profile)

# Run on simulator
flutter run -d "iPhone 15"

# Run on physical iPhone (connected via USB)
flutter run -d <device-id>

# Build IPA
flutter build ipa
```

### Flutter app features (Phase 1)

| Screen | Description |
|--------|-------------|
| Splash | Auto-login check, animated logo |
| OTP Login | Phone + 6-digit OTP with real-time API |
| Profile Setup | Name + language selection |
| KYC (3-step) | Aadhaar/DL/bank details + document upload |
| Status Screen | Live onboarding progress tracker |
| Vehicle List | Browse available EVs by hub, battery, rent |
| Vehicle Detail | Book a vehicle with plan selection |
| Wallet | Balance, dues, incentives, transaction history |
| Support | Raise tickets by category, WhatsApp fallback |
| Skill Dev | Training videos + points/badge gamification |

---

## Frontend Admin Setup

> The React Admin dashboard is the Phase 1 wireframe built as an interactive widget.  
> The full React app will be built in Module 2.

```bash
cd frontend-admin
npm install
npm start
# Opens at http://localhost:3000
```

For now the interactive wireframe (Onboarding + Vehicle Allocation) has been delivered as an interactive prototype. Full React source will be scaffolded in the next sprint.

---

## API Documentation

Once the backend is running, visit:

- **Swagger UI**: http://localhost/api/docs/
- **OpenAPI Schema**: http://localhost/api/schema/

The schema auto-generates from Django REST Framework + drf-spectacular.

---

## Environment Variables Reference

Copy `.env.example` → `.env` and fill in:

```env
# === Django ===
SECRET_KEY=<50+ char random string — CHANGE THIS>
DEBUG=True                     # False in production
DJANGO_SETTINGS_MODULE=config.settings.local  # or .production
ALLOWED_HOSTS=localhost,127.0.0.1,your-domain.com
CORS_ORIGINS=http://localhost:3000

# === Database ===
DB_HOST=db                     # "db" in Docker, "localhost" for local dev
DB_PORT=5432
DB_NAME=yana_db
DB_USER=yana_user
DB_PASSWORD=<strong password>

# === Redis ===
REDIS_URL=redis://:redis_pass@redis:6379/0
REDIS_PASSWORD=redis_pass

# === MinIO / S3 storage ===
MINIO_ENDPOINT_URL=http://minio:9000   # in Docker
MINIO_ACCESS_KEY=yana_minio
MINIO_SECRET_KEY=<strong password>
MINIO_BUCKET=yana-docs

# === Razorpay (get from razorpay.com/dashboard) ===
RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxxxx
RAZORPAY_SECRET=<secret>

# === Firebase (for push notifications) ===
FIREBASE_CREDENTIALS=<base64 encoded service account JSON>

# === Google Maps ===
GOOGLE_MAPS_API_KEY=<key from console.cloud.google.com>

# === KYC Providers ===
DIGILOCKER_API_KEY=<from digilocker.gov.in>
KARZA_API_KEY=<from karza.in>
```

---

## Module Roadmap

### ✅ Phase 1 (Built — this package)
- [x] System architecture & DB design
- [x] Admin wireframe (Onboarding + Vehicle Allocation)
- [x] Backend: Custom User + OTP auth
- [x] Backend: Rider Onboarding module (full CRUD + KYC workflow)
- [x] Backend: Fleet module (Hubs + Vehicles + Allocations)
- [x] Backend: Payments wallet stub
- [x] Backend: Celery async tasks
- [x] Backend: Docker full-stack compose
- [x] Flutter: Splash, OTP, Profile, KYC (3-step), Status screens
- [x] Flutter: Vehicle list + booking screens
- [x] Flutter: Wallet, Support, Skill Dev screens

### 🔜 Phase 2 (Next sprint)
- [ ] React Admin full build (Vite + TypeScript)
- [ ] Payments module: Razorpay integration, UPI AutoPay
- [ ] Job Marketplace: Demand slots + rider applications
- [ ] Sales CRM: Client management + demand creation
- [ ] Maintenance module: Service logs + alerts
- [ ] Support: WhatsApp Business API + ticket system
- [ ] Push notifications: Firebase FCM
- [ ] KYC: Karza / Digilocker API integration

### 🔜 Phase 3 (AI Layer)
- [ ] Rider reliability scoring (ML model)
- [ ] Demand prediction per dark store
- [ ] Vehicle failure prediction
- [ ] Optimal rider allocation engine
- [ ] Admin analytics dashboard with Recharts

---

## Production Deployment

### AWS / GCP setup

```bash
# 1. Provision a VM (e.g. AWS EC2 t3.medium or GCP e2-standard-2)
# 2. SSH into the server

# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Clone repo
git clone <repo> yana-os && cd yana-os

# Set production env
cp .env.example .env
nano .env   # Set DEBUG=False, strong passwords, real domain

# Build and start
docker compose -f docker-compose.yml up -d --build

# Set up SSL with Certbot
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

### Scaling (Kubernetes — Phase 3)
The service boundaries are already drawn for Kubernetes deployment:
- Each Django app → separate Deployment
- Use AWS RDS (PostgreSQL) or Cloud SQL instead of container DB
- Use AWS ElastiCache instead of Redis container
- Use AWS S3 instead of MinIO
- Use Kubernetes HPA for autoscaling based on CPU/request rate

---

## Troubleshooting

### Docker issues

```bash
# If ports are already in use:
sudo lsof -i :5432   # find what's using postgres port
sudo lsof -i :6379   # find what's using redis port

# Reset everything (WARNING: deletes all data)
docker compose down -v
docker system prune -f

# View logs for a specific service
docker compose logs backend
docker compose logs celery-worker
docker compose logs db
```

### Django migration errors

```bash
docker compose exec backend python manage.py showmigrations
docker compose exec backend python manage.py migrate --run-syncdb
```

### Flutter build errors

```bash
# Clean build cache
flutter clean
flutter pub get
flutter run

# If gradle fails on Android
cd android && ./gradlew clean && cd ..
flutter run

# If pod install fails on iOS
cd ios && pod install && cd ..
flutter run
```

### API returns 401 Unauthorized

- Your JWT access token has expired (8 hour lifetime)
- Call `POST /api/auth/token/refresh/` with your refresh token
- In Flutter: the `api_client.dart` interceptor handles this automatically

### MinIO connection refused

```bash
# Check MinIO is running
docker compose ps minio

# Access MinIO console
open http://localhost:9001
# Login: yana_minio / yana_minio_pass

# Create the bucket manually if not auto-created
# Or run: docker compose exec backend python manage.py create_minio_bucket
```

---

## Support & Contributing

- Each module is in `backend/apps/<module>/`
- Add new features by creating model → serializer → view → url → task
- Run tests: `docker compose exec backend python manage.py test`
- Linting: `flake8 .` and `black .` in backend; `dart analyze` in Flutter

---

*Yana OS — Building the operating system for Tier 2/3 India's last-mile delivery workforce.*
