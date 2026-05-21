# TakarKhata Technical Documentation

This document serves as a technical overview and architectural guide for **TakarKhata**, a production-grade, offline-first personal finance application. It is designed to assist stakeholders, clients, and new developers in understanding the technical foundations, design patterns, and core capabilities of the system.

## 1. Executive Summary

TakarKhata is a high-performance cross-platform application (targeting Android, Windows, and Linux) built to manage personal finances with absolute data integrity. By enforcing a strict double-entry ledger system and utilizing offline-first localized storage, the application guarantees privacy, speed, and mathematical accuracy without relying on cloud infrastructure.

## 2. Technology Stack

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod (with Code Generation)
- **Database**: Drift (SQLite ORM)
- **Routing**: GoRouter (Declarative, URL-based navigation)
- **UI/UX**: Material 3 Design System, Custom Adaptive Scaffold, `fl_chart` for Analytics

## 3. Architectural Design

TakarKhata employs **Clean Architecture** combined with a **Feature-First modular structure**. This ensures strong separation of concerns, high testability, and scalable maintenance.

### 3.1 Layered Architecture

1. **Presentation Layer**: 
   - Contains Flutter UI components (Pages, Widgets).
   - Driven entirely by reactive Riverpod providers.
   - Strictly handles UI logic; delegates business rules downward.
2. **Application Layer**: 
   - Contains Services (e.g., `TransactionService`, `AccountService`) and the `FinancialEngine`.
   - Orchestrates use cases and enforces business rules.
3. **Domain Layer**: 
   - Core entities (`Account`, `TransactionEntry`, `Loan`).
   - Repository interfaces defining data contracts.
4. **Infrastructure/Data Layer**: 
   - Repository implementations.
   - Drift DAOs and SQLite table definitions.

### 3.2 The Financial Engine & Data Integrity

The cornerstone of TakarKhata is its strict adherence to financial data integrity.

> [!IMPORTANT]
> **Zero Floating-Point Errors:** All monetary values within the application and database are stored as strict `Integers` representing cents (e.g., $12.50 is stored as 1250). This eliminates the rounding errors common in floating-point financial software.

- **Ledger as Source of Truth**: Account balances are not freely editable. They are derived directly from the sum of all transaction entries. 
- **Atomic Operations**: Transfers between accounts are handled as a single atomic database transaction (Debit Source -> Credit Destination).
- **Auto-Repair & Validation**: On startup, the `FinancialEngine` can validate cached account balances against a raw sum of the ledger. If a discrepancy is found (e.g., due to an OS-level crash mid-write), the system can instantly repair itself by recalculating balances from the ledger.

## 4. Key Features & Capabilities

### 4.1 Cross-Platform Adaptive UI
The application utilizes an `AdaptiveScaffold` that seamlessly transitions between mobile and desktop form factors.
- **Mobile**: Utilizes a standard bottom navigation bar.
- **Desktop/Tablet**: Automatically scales to a side navigation rail or a persistent drawer, maximizing screen real estate.

### 4.2 Comprehensive Analytics
The Dashboard leverages `fl_chart` to render highly responsive, animated charts.
- **Net Worth Calculation**: Dynamically computed by summing liquid assets (Cash, Debit, Savings) and subtracting liabilities (Credit).
- **Trend Analysis**: Monthly aggregation of income and expenses visualized over time.

### 4.3 Loan Management System
TakarKhata includes a robust loan tracker capable of handling both borrowed and lent funds.
- Loans are heavily integrated into the core ledger. Creating a loan instantly logs a transaction to reflect the cash flow.
- Repayment progress is tracked mathematically against the principal amount.

### 4.4 Data Portability
Despite being offline-first, users are never locked in.
- **Export**: The entire database state can be serialized to a JSON payload and saved to the device's file system via the native File Picker.
- **Import**: The application features a robust JSON ingestion engine that safely deserializes backups, utilizing UUID-based duplicate detection to prevent data corruption during restoration.

## 5. Build & Deployment

The project is configured for multi-platform compilation.
- **Android**: Fully configured with `compileSdk 36` to support the latest Android lifecycles and permissions. Generates optimized, tree-shaken APKs.
- **Windows**: Compiles to a standalone `.exe` using native Win32 bindings.
- **Dependencies**: All third-party plugins (e.g., `file_picker`, `share_plus`) are carefully version-locked to ensure stable, reproducible builds across CI/CD environments.
