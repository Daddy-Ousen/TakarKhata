# TakarKhata User Guide

Welcome to **TakarKhata**, your comprehensive, offline-first personal finance ledger. Whether you are using the Windows Desktop or Android version, this guide will help you navigate and master the application to take full control of your finances.

## Table of Contents
1. [Getting Started](#getting-started)
2. [Dashboard](#dashboard)
3. [Accounts Management](#accounts-management)
4. [Transaction Ledger](#transaction-ledger)
5. [Loans Tracking](#loans-tracking)
6. [Settings & Data Management](#settings--data-management)

---

## Getting Started

When you launch TakarKhata for the first time, you will be greeted by a fast, responsive, and completely offline interface. Your data never leaves your device unless you choose to export it.

### Initial Setup
1. Navigate to the **Accounts** tab.
2. Create your primary accounts (e.g., Cash, Bank Account, Credit Card).
3. If you already have existing balances, you can set them by navigating to **Settings > Set Initial Balances**. This will safely create an initial ledger entry for your account without requiring manual transaction math.

---

## Dashboard

The Dashboard is your financial command center, providing a bird's-eye view of your current standing.

- **Net Worth**: Automatically calculated by taking your total liquid assets (Cash, Debit) and subtracting your liabilities (Credit). **Note:** Savings are treated as assets and contribute positively to your Net Worth.
- **Current Balance**: A quick summary of just your available liquid funds (Debit + Cash).
- **Summary Cards**: At-a-glance view of your total Income, Expenses, and Transfers for the month.
- **Visual Analytics**: 
  - A dynamic pie chart breaks down your expenses by category.
  - Trend graphs show how your income and expenses have evolved over recent months.

---

## Accounts Management

The **Accounts** page groups your financial sources by type (Cash, Debit, Credit, Savings).

### Creating an Account
- Click the **+** button.
- Choose the account type (e.g., Savings, Credit).
- Give it a memorable name. 
- The system handles the rest. As you add transactions, the balance here will automatically update.

### Managing Balances
Balances are strictly derived from your transaction history. To adjust a balance, you must record a transaction (Income/Expense) or use the **Initial Balances** tool in Settings. This guarantees financial integrity.

---

## Transaction Ledger

The **Ledger** page is where you record your day-to-day financial activities. It groups your history by date for easy reading.

### Adding a Transaction
1. Tap the **+** button on the Ledger or Dashboard page.
2. **Select Type**: Income, Expense, or Transfer.
3. **Amount**: Enter the exact monetary value.
4. **Accounts**: Select the source (where the money is coming from) and the destination (where it is going). 
   - *Example for Expense: Source = Wallet (Cash), Destination = Groceries (Category).*
5. **Save**: The dashboard and account balances will instantly refresh.

### Modifying the Ledger
- **Delete**: If you made a mistake, you can delete a ledger entry. On mobile, swipe the transaction. On desktop, select the transaction to reveal the Delete option. The app will automatically reverse the transaction and recalculate all affected balances.

---

## Loans Tracking

Keep track of money you owe or money owed to you on the **Loans** page.

### Creating a Loan
- Select whether you are borrowing or lending.
- Link the loan to a specific account (e.g., the Bank Account where the borrowed money was deposited).
- The system will automatically create the corresponding ledger entry to update your cash flow.

### Repayments
- Open an active loan to record a payment.
- Progress bars visually indicate how much of the principal has been settled. 
- Once fully paid, the loan moves to the "Settled" group.

---

## Settings & Data Management

Because KhataBook is offline-first, you have absolute control over your data.

- **Data Export**: Export your entire financial history as a `.json` file for backup. We highly recommend doing this regularly. Keep the exported file in a secure location.
- **Data Import**: Restore your data from a `.json` backup file. The app includes duplicate-detection to prevent messing up your ledger if you accidentally import the same file twice.
- **Set Initial Balances**: A quick tool to establish your starting balances without manually creating individual transactions.
- **Repair Integrity**: In the highly unlikely event of a glitch or app crash during a transaction, this tool will perform a deep scan of your database and recalculate all account balances from scratch based on your ledger history, ensuring absolute accuracy.
