# 🦷 SmileCraft Dental Care & Live Serialization System
### Advanced Dental Surgeon Portfolio, Multi-Chamber Management & Real-Time Queue Platform for Bangladesh

[![Live on GitHub Pages](https://img.shields.io/badge/Live%20Demo-GitHub%20Pages-teal?style=for-the-badge&logo=github)](https://smh1s1n.github.io/dental-profile/)
[![Flutter](https://img.shields.io/badge/Flutter-3.47.7-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod%203-blue?style=for-the-badge)](https://riverpod.dev)

🌐 **Live URL:** [https://smh1s1n.github.io/dental-profile/](https://smh1s1n.github.io/dental-profile/)

A comprehensive, production-grade Flutter application built with **Riverpod**, **Clean Architecture (Feature-First)**, and the **Singleton Design Principle**, engineered specifically for dental surgeons in Bangladesh managing multiple private chambers.

---

## 🇧🇩 Deep Research & Clinical Context (Bangladesh Dental Landscape)

1. **BMDC Credentials & Legal Identification**:
   - Every practicing dental doctor in Bangladesh is accredited by the **Bangladesh Medical & Dental Council (BMDC)**.
   - Prominently showcases **BMDC Reg. No: D-12845**, academic credentials from **Dhaka Dental College (DDC)** and **Bangabandhu Sheikh Mujib Medical University (BSMMU)**, and specialized fellowships.

2. **The Bangladeshi Multi-Chamber Reality**:
   - Prominent dentists in Dhaka and other divisional cities practice across 2 to 3 distinct locations on alternating days.
   - **Chamber 1 (Dhanmondi)**: *SmileCraft Dental Care* (Sat, Mon, Wed 5:30 PM - 10:00 PM)
   - **Chamber 2 (Uttara)**: *Apex Dental & Implant Center* (Sun, Tue, Thu 6:00 PM - 10:30 PM)
   - **Chamber 3 (Banani)**: *Banani Aesthetic & Surgery Studio* (Fri & Sat morning 10:00 AM - 2:00 PM)
   - Each chamber has its own consultation fees (Regular ৳1,000 / Follow-up ৳500), compounder contact, address, and facility badges.

3. **Pain-Free Live Serial System (লাইভ সিরিয়াল ম্যানেজমেন্ট)**:
   - Waiting room congestion is the single biggest pain point for private medical chambers in Bangladesh.
   - **Patient Mobile Tracker**: Patients search by Token ID (`DENT-8904`) or mobile number (`017XXXXXXXX`) to view real-time doctor presence, active serving serial (`Now Serving #3`), and estimated wait time without sitting in crowded waiting rooms.
   - **Chamber TV Display Mode**: Fullscreen high-visibility LED display board designed for chamber waiting room monitors, featuring real-time serial calling, upcoming patient ticker, and bilingual patient advice.
   - **Compounder & Doctor Controller**: One-click serial advancing (`Call Next`), recall chime, `In-Chamber`, `Completed`, `Mark Absent/Delayed`, and `Emergency Walk-in Priority`.
   - **Doctor Traffic & Delay Broadcast**: Real-time announcements (e.g. *"Doctor delayed 20 mins due to emergency hospital surgery"*).

4. **Clinical Dental Charting & Electronic Prescriptions (e-Rx)**:
   - **Interactive 32-Tooth Mouth Map (FDI 11 to 48 notation)**: Doctors click teeth to log conditions (Caries, Composite Filling, Zirconia Crown, RCT, Missing, Impacted Wisdom).
   - **Official Dental Prescription (e-Rx)**: Standard dental medications in Bangladesh (Moxaclav 625mg, Ketorolac, Esomeprazole, Chlorhexidine 0.2% mouthwash) with Bengali dosage directions and post-op care.

5. **Local Payments & Verification**:
   - bKash Instant Merchant Pay (`01711-234567`) with TrxID recording.
   - Nagad Pay & Cash at Reception counter.

---

## 🏛️ Architectural Standards

### 1. Clean Architecture (Feature-First)
```text
lib/
├── core/
│   ├── constants/            # Colors, strings, mock seed data
│   ├── services/             # Thread-safe Singletons (Storage, Queue Broadcast, Auth)
│   ├── theme/                # Medical teal palette, card & button styles
│   └── utils/                # Bengali digit converter, BD phone validator
├── features/
│   ├── doctor_portfolio/     # Profile, bio, credentials, 8 specialized services, reviews
│   ├── chamber_management/   # Multi-chamber repository, schedules, fees
│   ├── appointment_booking/  # 4-step wizard, serial slip, QR generation, bKash pay
│   ├── live_serial_queue/    # Real-time stream, Mobile Tracker, Waiting Room TV Display
│   ├── clinical_records/     # 32-tooth FDI dental chart, e-Prescription generator
│   └── staff_portal/         # Role-based PIN auth, Live Queue Controller, Walk-in registry
└── main.dart                 # ProviderScope entrypoint
```

### 2. Singleton Design Principle
Thread-safe singletons ensure a single source of truth across all features and platforms:
- **`StorageService.instance`**: Unified persistent cache for appointments, chambers, serial state, and dental charts.
- **`LiveQueueBroadcaster.instance`**: Reactive publish/subscribe broadcast stream emitting real-time serial calls and audio/visual chimes.
- **`AuthSecurityService.instance`**: SHA-256 hashed PIN authentication and role validation (`Doctor: 1234`, `Staff: 5678`).
- **`AppointmentRepositoryImpl.instance` & `ChamberRepositoryImpl.instance`**: Repository singletons exposed cleanly via Riverpod providers.

### 3. Riverpod 3 State Management
- `Notifier` / `NotifierProvider` for stateful mutators (`SelectedChamberNotifier`, `AuthStateNotifier`).
- `FutureProvider.family` for parameterized chamber queries.
- `StreamProvider` for real-time live serial broadcaster listening.

---

## 🚀 Running the Application

### Web
```bash
flutter run -d chrome
# or to build production web bundle:
flutter build web
```

### macOS Desktop
```bash
flutter run -d macos
```

### Running Test Suite
```bash
flutter test
```
All 13 unit, widget, and singleton repository tests pass with 0 errors.

---

## 🔐 Credentials for Testing

- **Public Patient Mode**: Open without login. Book appointments, track serials, view chamber schedules, and inspect digital tickets.
- **Doctor Console PIN**: `1234` (Dr. Syed Tanvir Rahman - Full clinical access, e-Rx, dental chart, queue control)
- **Chamber Compounder PIN**: `5678` (Md. Rafiqul Islam - Queue calling, walk-in patient registration, cash/bKash payment collection)
