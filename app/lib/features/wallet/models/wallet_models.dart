import '../copy/wallet_copy.dart';

enum BalanceKind { credits, diamonds, cash }

enum PaymentMethod { mtn, orange }

enum PaymentStatus { processing, pending, failed, cancelled, confirmed }

enum WithdrawalStatus { pending, inProgress, approved, rejected, paid, failed }

enum WalletActivityPurpose {
  other,
  creditPurchase,
  creditSpend,
  promotionReward,
  conversionDebit,
  conversionCredit,
  withdrawalReservation,
  withdrawalReturn,
}

class WithdrawalEvent {
  const WithdrawalEvent({
    required this.status,
    required this.date,
    this.reason,
  });
  final WithdrawalStatus status;
  final DateTime date;
  final String? reason;
}

extension BalanceKindLabel on BalanceKind {
  String get label => switch (this) {
    BalanceKind.credits => WalletCopy.credits,
    BalanceKind.diamonds => WalletCopy.diamonds,
    BalanceKind.cash => WalletCopy.cash,
  };
  String get unit => this == BalanceKind.cash ? WalletCopy.xaf : label;
}

extension PaymentMethodLabel on PaymentMethod {
  String get label => switch (this) {
    PaymentMethod.mtn => WalletCopy.mtnMobileMoney,
    PaymentMethod.orange => WalletCopy.orangeMobileMoney,
  };
}

extension WithdrawalStatusLabel on WithdrawalStatus {
  String get label => switch (this) {
    WithdrawalStatus.pending => WalletCopy.pending,
    WithdrawalStatus.inProgress => WalletCopy.inProgress,
    WithdrawalStatus.approved => WalletCopy.approved,
    WithdrawalStatus.rejected => WalletCopy.rejected,
    WithdrawalStatus.paid => WalletCopy.paid,
    WithdrawalStatus.failed => WalletCopy.failed,
  };
}

class WalletConfig {
  const WalletConfig({
    this.xafPerCredit = 10,
    this.xafPerDiamond = 5,
    this.withdrawalMinimum = 1000,
    this.withdrawalFee = 100,
    this.withdrawalsPerDay = 2,
  });
  final int xafPerCredit;
  final int xafPerDiamond;
  final int withdrawalMinimum;
  final int withdrawalFee;
  final int withdrawalsPerDay;
}

class WalletActivity {
  const WalletActivity({
    required this.id,
    required this.kind,
    required this.amount,
    required this.title,
    required this.reference,
    required this.date,
    required this.status,
    required this.description,
    this.purpose = WalletActivityPurpose.other,
  });
  final String id;
  final BalanceKind kind;

  /// Signed amount: a debit is negative.
  final int amount;
  final String title;
  final String reference;
  final DateTime date;
  final String status;
  final String description;
  final WalletActivityPurpose purpose;
}

class WalletPayment {
  WalletPayment({
    required this.id,
    required this.credits,
    required this.method,
    required this.phone,
    required this.cost,
    required this.date,
    this.status = PaymentStatus.processing,
  });
  final String id;
  final int credits;
  final PaymentMethod method;
  final String phone;
  final int cost;
  final DateTime date;
  PaymentStatus status;
}

class WalletWithdrawal {
  WalletWithdrawal({
    required this.id,
    required this.amount,
    required this.fee,
    required this.method,
    required this.destination,
    required this.date,
    this.status = WithdrawalStatus.pending,
  }) : events = [WithdrawalEvent(status: status, date: date)];
  final String id;
  final int amount;
  final int fee;
  int get net => amount - fee;
  final PaymentMethod method;
  final String destination;
  final DateTime date;
  WithdrawalStatus status;
  final List<WithdrawalEvent> events;
}
