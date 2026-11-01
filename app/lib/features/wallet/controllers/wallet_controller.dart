import 'package:flutter/foundation.dart';

import '../copy/wallet_copy.dart';
import '../models/wallet_models.dart';

/// Session-only wallet. Identifiers are idempotency keys for all mutations.
class WalletController extends ChangeNotifier {
  WalletController({
    this.config = const WalletConfig(),
    this.seedActivity = false,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       conversionRate = config.xafPerDiamond {
    if (seedActivity) _seedActivity();
  }
  final WalletConfig config;
  final bool seedActivity;
  final DateTime Function() _clock;
  int conversionRate;
  bool failNextConversion = false;
  int credits = 3000;
  int diamonds = 350;
  int pendingDiamonds = 40;
  int frozenDiamonds = 0;
  int cash = 1000;
  final List<WalletActivity> _activity = [];
  final Map<String, WalletPayment> _payments = {};
  final Map<String, WalletWithdrawal> _withdrawals = {};
  final Set<String> _conversions = {};
  final Set<String> _spends = {};
  final Set<String> _promotionRewards = {};
  // Keep IDs unique for this controller's lifetime, including across resets.
  int _sequence = 0;
  String newId(String prefix) => '$prefix-${++_sequence}';
  List<WalletActivity> get activity => List.unmodifiable(_activity.reversed);
  List<WalletPayment> get payments => List.unmodifiable(_payments.values);
  List<WalletWithdrawal> get withdrawals =>
      List.unmodifiable(_withdrawals.values.toList().reversed);

  /// Current mock-calendar limit, independent of validation copy and balances.
  bool get withdrawalFrequencyLimitReached {
    final now = _clock();
    final count = _withdrawals.values
        .where(
          (withdrawal) =>
              withdrawal.date.year == now.year &&
              withdrawal.date.month == now.month &&
              withdrawal.date.day == now.day,
        )
        .length;
    return count >= config.withdrawalsPerDay;
  }

  void reset() {
    credits = 3000;
    diamonds = 350;
    pendingDiamonds = 40;
    frozenDiamonds = 0;
    cash = 1000;
    _activity.clear();
    _payments.clear();
    _withdrawals.clear();
    _conversions.clear();
    _spends.clear();
    _promotionRewards.clear();
    conversionRate = config.xafPerDiamond;
    failNextConversion = false;
    if (seedActivity) _seedActivity();
    notifyListeners();
  }

  void _seedActivity() {
    final now = _clock();
    _activity.addAll([
      WalletActivity(
        id: 'seed-credit',
        kind: BalanceKind.credits,
        amount: -50,
        title: WalletCopy.storyBoost,
        reference: 'seed-publication',
        date: now.subtract(const Duration(days: 1)),
        status: WalletCopy.complete,
        description: WalletCopy.boostedStatus,
        purpose: WalletActivityPurpose.creditSpend,
      ),
      WalletActivity(
        id: 'seed-diamond',
        kind: BalanceKind.diamonds,
        amount: 40,
        title: WalletCopy.promotionReward,
        reference: 'seed-reward',
        date: now.subtract(const Duration(days: 2)),
        status: WalletCopy.pending,
        description: WalletCopy.rewardAwaitingConfirmation,
        purpose: WalletActivityPurpose.promotionReward,
      ),
      WalletActivity(
        id: 'seed-cash',
        kind: BalanceKind.cash,
        amount: 1000,
        title: WalletCopy.conversion,
        reference: 'seed-conversion',
        date: now.subtract(const Duration(days: 3)),
        status: WalletCopy.complete,
        description: WalletCopy.convertedDiamondsToCash,
        purpose: WalletActivityPurpose.conversionCredit,
      ),
    ]);
  }

  void setConversionRate(int rate) {
    if (rate <= 0) throw ArgumentError.value(rate, 'rate');
    if (rate == conversionRate) return;
    conversionRate = rate;
    notifyListeners();
  }

  /// Records a simulated reward as pending, never as convertible Diamonds.
  bool addPendingPromotionReward({required String id, required int amount}) {
    if (_promotionRewards.contains(id)) return true;
    if (id.isEmpty || amount <= 0) return false;
    _promotionRewards.add(id);
    pendingDiamonds += amount;
    _add(
      BalanceKind.diamonds,
      amount,
      WalletCopy.promotionReward,
      id,
      WalletCopy.pending,
      WalletCopy.mockRewardAwaitingConfirmation,
      purpose: WalletActivityPurpose.promotionReward,
    );
    notifyListeners();
    return true;
  }

  void setConversionFailure(bool fail) {
    failNextConversion = fail;
    notifyListeners();
  }

  static bool validPhone(String phone) =>
      RegExp(r'^\+?[0-9]{8,15}$')
          .hasMatch(phone.replaceAll(RegExp(r'[\s()-]'), ''));
  WalletPayment startPayment({
    required String id,
    required int credits,
    required PaymentMethod method,
    required String phone,
  }) {
    final previous = _payments[id];
    if (previous != null) return previous;
    if (credits <= 0 || !validPhone(phone)) {
      throw ArgumentError(WalletCopy.invalidAmountAndPhone);
    }
    final payment = WalletPayment(
      id: id,
      credits: credits,
      method: method,
      phone: phone,
      cost: credits * config.xafPerCredit,
      date: _clock(),
    );
    _payments[id] = payment;
    notifyListeners();
    return payment;
  }

  void setPaymentStatus(String id, PaymentStatus status) {
    final p = _payments[id];
    if (p == null) throw ArgumentError(WalletCopy.paymentNotFound);
    if (p.status == status ||
        p.status == PaymentStatus.confirmed ||
        p.status == PaymentStatus.cancelled) {
      return;
    }
    if (status == PaymentStatus.confirmed) {
      credits += p.credits;
      _add(
        BalanceKind.credits,
        p.credits,
        WalletCopy.creditPurchase,
        id,
        WalletCopy.confirmed,
        WalletCopy.purchasedVia(p.method.label),
        purpose: WalletActivityPurpose.creditPurchase,
      );
    }
    p.status = status;
    notifyListeners();
  }

  bool spendCredits({
    required String id,
    required int amount,
    required String description,
  }) {
    if (_spends.contains(id)) return true;
    if (amount <= 0 || amount > credits) return false;
    credits -= amount;
    _spends.add(id);
    _add(
      BalanceKind.credits,
      -amount,
      description,
      id,
      WalletCopy.complete,
      description,
      purpose: WalletActivityPurpose.creditSpend,
    );
    notifyListeners();
    return true;
  }

  bool convertDiamonds({
    required String id,
    required int amount,
    required int reviewedRate,
  }) {
    if (_conversions.contains(id)) return true;
    if (amount <= 0 || amount > diamonds || reviewedRate != conversionRate) {
      return false;
    }
    if (failNextConversion) {
      failNextConversion = false;
      notifyListeners();
      return false;
    }
    diamonds -= amount;
    cash += amount * reviewedRate;
    _conversions.add(id);
    _add(
      BalanceKind.diamonds,
      -amount,
      WalletCopy.convertedDiamonds,
      id,
      WalletCopy.complete,
      WalletCopy.convertedAt(reviewedRate),
      purpose: WalletActivityPurpose.conversionDebit,
    );
    _add(
      BalanceKind.cash,
      amount * reviewedRate,
      WalletCopy.diamondConversion,
      id,
      WalletCopy.complete,
      WalletCopy.convertedAmount(amount),
      purpose: WalletActivityPurpose.conversionCredit,
    );
    notifyListeners();
    return true;
  }

  String? withdrawalError({required int amount, required String destination}) {
    if (amount < config.withdrawalMinimum) {
      return WalletCopy.minimumWithdrawalError(config.withdrawalMinimum);
    }
    if (amount > cash) return WalletCopy.amountExceedsCash;
    if (amount <= config.withdrawalFee) {
      return WalletCopy.amountMustExceedFee;
    }
    if (!validPhone(destination)) return WalletCopy.invalidMobileMoneyNumber;
    if (withdrawalFrequencyLimitReached) {
      return WalletCopy.dailyWithdrawalLimitReached;
    }
    return null;
  }

  WalletWithdrawal requestWithdrawal({
    required String id,
    required int amount,
    required PaymentMethod method,
    required String destination,
  }) {
    final previous = _withdrawals[id];
    if (previous != null) return previous;
    final error = withdrawalError(amount: amount, destination: destination);
    if (error != null) throw ArgumentError(error);
    final withdrawal = WalletWithdrawal(
      id: id,
      amount: amount,
      fee: config.withdrawalFee,
      method: method,
      destination: destination,
      date: _clock(),
    );
    cash -= amount;
    _withdrawals[id] = withdrawal;
    _add(
      BalanceKind.cash,
      -amount,
      WalletCopy.withdrawalRequested,
      id,
      WalletCopy.pending,
      WalletCopy.payoutTo(method.label),
      purpose: WalletActivityPurpose.withdrawalReservation,
    );
    notifyListeners();
    return withdrawal;
  }

  void setWithdrawalStatus(
    String id,
    WithdrawalStatus status, {
    String? reason,
  }) {
    final w = _withdrawals[id];
    if (w == null) throw ArgumentError(WalletCopy.withdrawalNotFound);
    if (w.status == status ||
        {
          WithdrawalStatus.rejected,
          WithdrawalStatus.failed,
          WithdrawalStatus.paid,
        }.contains(w.status)) {
      return;
    }
    final allowed = switch (w.status) {
      WithdrawalStatus.pending => {
        WithdrawalStatus.inProgress,
        WithdrawalStatus.rejected,
        WithdrawalStatus.failed,
      },
      WithdrawalStatus.inProgress => {
        WithdrawalStatus.approved,
        WithdrawalStatus.rejected,
        WithdrawalStatus.failed,
      },
      WithdrawalStatus.approved => {
        WithdrawalStatus.paid,
        WithdrawalStatus.rejected,
        WithdrawalStatus.failed,
      },
      _ => <WithdrawalStatus>{},
    };
    if (!allowed.contains(status)) return;
    w.status = status;
    final explanation =
        reason ??
        switch (status) {
          WithdrawalStatus.rejected => WalletCopy.payoutRejectedExplanation,
          WithdrawalStatus.failed => WalletCopy.payoutFailedExplanation,
          _ => null,
        };
    w.events.add(
      WithdrawalEvent(status: status, date: _clock(), reason: explanation),
    );
    final index = _activity.indexWhere(
      (entry) =>
          entry.reference == id &&
          entry.purpose == WalletActivityPurpose.withdrawalReservation,
    );
    if (index >= 0) {
      final entry = _activity[index];
      _activity[index] = WalletActivity(
        id: entry.id,
        kind: entry.kind,
        amount: entry.amount,
        title: entry.title,
        reference: entry.reference,
        date: entry.date,
        status: status.label,
        description: entry.description,
        purpose: entry.purpose,
      );
    }
    if (status == WithdrawalStatus.rejected ||
        status == WithdrawalStatus.failed) {
      cash += w.amount;
      _add(
        BalanceKind.cash,
        w.amount,
        WalletCopy.withdrawalReturned,
        id,
        status.label,
        explanation ?? WalletCopy.payoutNotCompleted,
        purpose: WalletActivityPurpose.withdrawalReturn,
      );
    }
    notifyListeners();
  }

  void _add(
    BalanceKind kind,
    int amount,
    String title,
    String reference,
    String status,
    String description, {
    WalletActivityPurpose purpose = WalletActivityPurpose.other,
  }) {
    _activity.add(
      WalletActivity(
        id: newId('activity'),
        kind: kind,
        amount: amount,
        title: title,
        reference: reference,
        date: _clock(),
        status: status,
        description: description,
        purpose: purpose,
      ),
    );
  }
}
