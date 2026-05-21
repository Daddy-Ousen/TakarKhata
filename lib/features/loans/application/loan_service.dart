import 'package:khatabook/core/enums/loan_status.dart';
import 'package:khatabook/core/enums/loan_type.dart';
import 'package:khatabook/core/enums/transaction_type.dart';
import 'package:khatabook/core/errors/failures.dart';
import 'package:khatabook/core/utils/uuid_generator.dart';
import 'package:khatabook/features/accounts/domain/repositories/account_repository.dart';
import 'package:khatabook/features/loans/domain/entities/loan.dart';
import 'package:khatabook/features/loans/domain/entities/loan_payment.dart';
import 'package:khatabook/features/loans/domain/repositories/loan_repository.dart';
import 'package:khatabook/features/transactions/application/transaction_service.dart';

/// Service for personal loan management.
///
/// Integrates loan operations with financial accounts so that
/// lending/borrowing money properly affects account balances.
class LoanService {
  final LoanRepository _loanRepository;
  final TransactionService _transactionService;
  final AccountRepository _accountRepository;

  LoanService({
    required LoanRepository loanRepository,
    required TransactionService transactionService,
    required AccountRepository accountRepository,
  })  : _loanRepository = loanRepository,
        _transactionService = transactionService,
        _accountRepository = accountRepository;

  /// Create a new loan and optionally create an associated transaction.
  ///
  /// For "Money Owed To Me" (lending): Creates an expense from the source account.
  /// For "Money I Owe" (borrowing): Creates an income to the destination account.
  Future<Loan> createLoan({
    required String personName,
    required LoanType type,
    required int amount,
    required DateTime loanDate,
    String? notes,
    String? linkedAccountId,
  }) async {
    if (amount <= 0) {
      throw const ValidationFailure('Loan amount must be greater than zero');
    }

    final now = DateTime.now();
    final loan = Loan(
      id: UuidGenerator.generate(),
      personName: personName,
      type: type,
      originalAmount: amount,
      remainingAmount: amount,
      status: LoanStatus.open,
      linkedAccountId: linkedAccountId,
      notes: notes,
      loanDate: loanDate,
      createdAt: now,
      modifiedAt: now,
    );

    final created = await _loanRepository.createLoan(loan);

    // Create linked transaction if an account is specified
    if (linkedAccountId != null) {
      final account =
          await _accountRepository.getAccountById(linkedAccountId);
      if (account != null) {
        if (type == LoanType.owedToMe) {
          // Lending money = expense from account
          await _transactionService.createTransaction(
            type: TransactionType.expense,
            amount: amount,
            accountId: linkedAccountId,
            notes: 'Loan to $personName',
            transactionDate: loanDate,
          );
        } else {
          // Borrowing money = income to account
          await _transactionService.createTransaction(
            type: TransactionType.income,
            amount: amount,
            accountId: linkedAccountId,
            notes: 'Loan from $personName',
            transactionDate: loanDate,
          );
        }
      }
    }

    return created;
  }

  /// Record a payment against a loan.
  Future<void> recordPayment({
    required String loanId,
    required int amount,
    required DateTime paymentDate,
    String? notes,
    String? accountId,
  }) async {
    final loan = await _loanRepository.getLoanById(loanId);
    if (loan == null) {
      throw NotFoundFailure(entityType: 'Loan', entityId: loanId);
    }

    if (amount <= 0) {
      throw const ValidationFailure('Payment amount must be greater than zero');
    }

    if (amount > loan.remainingAmount) {
      throw const ValidationFailure(
          'Payment amount exceeds remaining loan balance');
    }

    String? linkedTransactionId;

    // Create linked transaction if an account is specified
    if (accountId != null) {
      final txn = loan.type == LoanType.owedToMe
          ? await _transactionService.createTransaction(
              type: TransactionType.income,
              amount: amount,
              accountId: accountId,
              notes: 'Loan repayment from ${loan.personName}',
              transactionDate: paymentDate,
            )
          : await _transactionService.createTransaction(
              type: TransactionType.expense,
              amount: amount,
              accountId: accountId,
              notes: 'Loan repayment to ${loan.personName}',
              transactionDate: paymentDate,
            );
      linkedTransactionId = txn.id;
    }

    final now = DateTime.now();
    final payment = LoanPayment(
      id: UuidGenerator.generate(),
      loanId: loanId,
      amount: amount,
      linkedTransactionId: linkedTransactionId,
      notes: notes,
      paymentDate: paymentDate,
      createdAt: now,
      modifiedAt: now,
    );

    await _loanRepository.addPayment(payment);

    // Update remaining amount and status
    final newRemaining = loan.remainingAmount - amount;
    final newStatus =
        newRemaining <= 0 ? LoanStatus.settled : LoanStatus.partiallyPaid;

    await _loanRepository.updateLoan(
      loan.copyWith(
        remainingAmount: newRemaining,
        status: newStatus,
        modifiedAt: now,
      ),
    );
  }
}
