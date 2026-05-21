import 'package:khatabook/core/enums/loan_status.dart';
import 'package:khatabook/core/enums/loan_type.dart';
import 'package:khatabook/features/loans/domain/entities/loan.dart' as domain;
import 'package:khatabook/features/loans/domain/entities/loan_payment.dart'
    as domain;
import 'package:khatabook/features/loans/domain/repositories/loan_repository.dart';
import 'package:khatabook/database/app_database.dart';
import 'package:drift/drift.dart';

/// Drift-backed implementation of [LoanRepository].
class LoanRepositoryImpl implements LoanRepository {
  final AppDatabase _db;

  LoanRepositoryImpl(this._db);

  domain.Loan _loanToDomain(Loan row) {
    return domain.Loan(
      id: row.id,
      personName: row.personName,
      type: LoanType.fromValue(row.type),
      originalAmount: row.originalAmount,
      remainingAmount: row.remainingAmount,
      status: LoanStatus.fromValue(row.status),
      linkedAccountId: row.linkedAccountId,
      notes: row.notes,
      loanDate: row.loanDate,
      createdAt: row.createdAt,
      modifiedAt: row.modifiedAt,
      syncVersion: row.syncVersion,
    );
  }

  LoansCompanion _loanToCompanion(domain.Loan entity) {
    return LoansCompanion(
      id: Value(entity.id),
      personName: Value(entity.personName),
      type: Value(entity.type.value),
      originalAmount: Value(entity.originalAmount),
      remainingAmount: Value(entity.remainingAmount),
      status: Value(entity.status.value),
      linkedAccountId: Value(entity.linkedAccountId),
      notes: Value(entity.notes),
      loanDate: Value(entity.loanDate),
      createdAt: Value(entity.createdAt),
      modifiedAt: Value(entity.modifiedAt),
      syncVersion: Value(entity.syncVersion),
    );
  }

  domain.LoanPayment _paymentToDomain(LoanPayment row) {
    return domain.LoanPayment(
      id: row.id,
      loanId: row.loanId,
      amount: row.amount,
      linkedTransactionId: row.linkedTransactionId,
      notes: row.notes,
      paymentDate: row.paymentDate,
      createdAt: row.createdAt,
      modifiedAt: row.modifiedAt,
      syncVersion: row.syncVersion,
    );
  }

  @override
  Future<List<domain.Loan>> getAllLoans() async {
    final rows = await _db.loanDao.getAllLoans();
    return rows.map(_loanToDomain).toList();
  }

  @override
  Future<domain.Loan?> getLoanById(String id) async {
    final row = await _db.loanDao.getLoanById(id);
    return row != null ? _loanToDomain(row) : null;
  }

  @override
  Future<List<domain.Loan>> getLoansByStatus(LoanStatus status) async {
    final rows = await _db.loanDao.getLoansByStatus(status.value);
    return rows.map(_loanToDomain).toList();
  }

  @override
  Future<domain.Loan> createLoan(domain.Loan loan) async {
    await _db.loanDao.insertLoan(_loanToCompanion(loan));
    return loan;
  }

  @override
  Future<void> updateLoan(domain.Loan loan) async {
    await _db.loanDao.updateLoan(_loanToCompanion(loan));
  }

  @override
  Future<void> addPayment(domain.LoanPayment payment) async {
    await _db.loanDao.insertPayment(LoanPaymentsCompanion(
      id: Value(payment.id),
      loanId: Value(payment.loanId),
      amount: Value(payment.amount),
      linkedTransactionId: Value(payment.linkedTransactionId),
      notes: Value(payment.notes),
      paymentDate: Value(payment.paymentDate),
      createdAt: Value(payment.createdAt),
      modifiedAt: Value(payment.modifiedAt),
      syncVersion: Value(payment.syncVersion),
    ));
  }

  @override
  Future<List<domain.LoanPayment>> getPaymentsForLoan(String loanId) async {
    final rows = await _db.loanDao.getPaymentsForLoan(loanId);
    return rows.map(_paymentToDomain).toList();
  }

  @override
  Future<int> getTotalOwed() async {
    return _db.loanDao.getTotalOwed();
  }

  @override
  Future<int> getTotalReceivable() async {
    return _db.loanDao.getTotalReceivable();
  }

  @override
  Stream<List<domain.Loan>> watchAllLoans() {
    return _db.loanDao.watchAllLoans().map(
          (rows) => rows.map(_loanToDomain).toList(),
        );
  }
}
