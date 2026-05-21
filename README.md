# TakarKhata

**TakarKhata** is a production-quality, offline-first personal finance ledger application built with Flutter. It targets Android, Windows, and Linux, giving you full control of your financial data without relying on cloud servers.

## Key Features

- **Offline-First**: All data is securely stored locally on your device via SQLite (Drift ORM).
- **Double-Entry Ledger**: Ensures absolute mathematical accuracy. Balances are rigorously derived from your transaction history.
- **Zero Floating-Point Errors**: All monetary values are handled as integers (cents) under the hood.
- **Cross-Platform Adaptive UI**: Fluid, responsive design that works perfectly on both mobile screens and wide desktop displays.
- **Comprehensive Analytics**: Track your Net Worth dynamically and visualize your monthly cash flow with interactive charts.
- **Loan Tracking**: Seamlessly record borrowed and lent funds and track repayment progress against the principal.
- **Data Portability**: Full JSON export and import capabilities. Your data is always yours.

## Architecture

TakarKhata utilizes a Clean Architecture structure:
- **Presentation**: Flutter UI driven by Riverpod.
- **Application**: Domain services and a core `FinancialEngine` that strictly guards ledger integrity.
- **Data**: Drift (SQLite) DAOs executing high-performance aggregate SQL queries.

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
- Android SDK (for Android build)
- Visual Studio (for Windows build)

### Running the App

1. Clone the repository:
   ```bash
   git clone https://github.com/Daddy-Ousen/TakarKhata.git
   cd TakarKhata
   ```
2. Get dependencies:
   ```bash
   flutter pub get
   ```
3. Run the code generation for the database:
   ```bash
   dart run build_runner build -d
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Documentation
For a deep dive into the application's design and how to use it, please see the provided `user_guide.pdf` and `technical_documentation.pdf` generated during the build process.

## License
Copyright 2026. All rights reserved.
