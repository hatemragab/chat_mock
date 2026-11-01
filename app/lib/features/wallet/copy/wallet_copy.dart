/// English UI copy for the session-only wallet experience.
abstract final class WalletCopy {
  static const credits = 'Credits';
  static const diamonds = 'Diamonds';
  static const cash = 'Cash';
  static const xaf = 'XAF';
  static const mtnMobileMoney = 'MTN Mobile Money';
  static const orangeMobileMoney = 'Orange Mobile Money';
  static const pending = 'Pending';
  static const inProgress = 'In Progress';
  static const approved = 'Approved';
  static const rejected = 'Rejected';
  static const paid = 'Paid';
  static const failed = 'Failed';
  static const processing = 'Processing';
  static const cancelled = 'Cancelled';
  static const confirmed = 'Confirmed';
  static const complete = 'Complete';
  static const available = 'Available';
  static const storyBoost = 'Story Boost';
  static const boostedStatus = 'Boosted a Status.';
  static const promotionReward = 'Promotion reward';
  static const rewardAwaitingConfirmation = 'Reward awaiting confirmation.';
  static const conversion = 'Conversion';
  static const convertedDiamondsToCash = 'Converted Diamonds to Cash.';
  static const mockRewardAwaitingConfirmation =
      'Mock reward awaiting confirmation.';
  static const invalidAmountAndPhone =
      'Enter a valid amount and Mobile Money number.';
  static const paymentNotFound = 'Payment not found';
  static const creditPurchase = 'Credit purchase';
  static const convertedDiamonds = 'Converted Diamonds';
  static const diamondConversion = 'Diamond conversion';
  static const amountExceedsCash = 'Amount exceeds available Cash.';
  static const amountMustExceedFee = 'Amount must exceed the withdrawal fee.';
  static const invalidMobileMoneyNumber = 'Enter a valid Mobile Money number.';
  static const dailyWithdrawalLimitReached = 'Daily withdrawal limit reached.';
  static const withdrawalRequested = 'Withdrawal requested';
  static const withdrawalNotFound = 'Withdrawal not found';
  static const payoutRejectedExplanation = 'The payout request was rejected.';
  static const payoutFailedExplanation = 'The payout could not be completed.';
  static const withdrawalReturned = 'Withdrawal returned';
  static const payoutNotCompleted = 'Payout was not completed';
  static const wallet = 'Wallet';
  static const yourBalances = 'Your balances';
  static const manageBalances = 'Manage your Credits, Diamonds and Cash.';
  static const buyCredits = 'Buy Credits';
  static const convertDiamonds = 'Convert Diamonds';
  static const withdrawCash = 'Withdraw Cash';
  static const withdrawalHistory = 'Withdrawal history';
  static const received = 'Received';
  static const spent = 'Spent';
  static const noBalanceActivity = 'No activity for this balance yet.';
  static const loadMore = 'Load more';
  static const transactionDetails = 'Transaction details';
  static const type = 'Type';
  static const direction = 'Direction';
  static const status = 'Status';
  static const reference = 'Reference';
  static const date = 'Date';
  static const details = 'Details';
  static const viewWithdrawal = 'View withdrawal';
  static const viewPayment = 'View payment';
  static const relatedActivity = 'Related activity';
  static const chooseAmount = 'Choose an amount';
  static const invalidCreditAmountAndPhone =
      'Enter a valid credit amount and phone number.';
  static const mobileMoneyPhone = 'Mobile Money phone number';
  static const paymentMethod = 'Payment method';
  static const reviewPayment = 'Review payment';
  static const total = 'Total';
  static const method = 'Method';
  static const number = 'Number';
  static const provider = 'Provider';
  static const providerName = 'SmobilPay/Maviance';
  static const paymentSimulation =
      'This is a simulation. No payment will be made.';
  static const continueToProvider = 'Continue to provider';
  static const paymentStatus = 'Payment status';
  static const creditOnlyOnConfirmation =
      'No Credits are added until the payment is confirmed.';
  static const refreshStatus = 'Refresh status';
  static const cancelPayment = 'Cancel payment';
  static const cancelPaymentQuestion = 'Cancel payment?';
  static const keepPayment = 'Keep payment';
  static const amountWithinBalance =
      'Enter an amount within your available balance.';
  static const conversionSucceeded = 'Diamonds converted to Cash.';
  static const rateChanged =
      'The conversion rate changed. Please review the new rate.';
  static const conversionFailed =
      'Conversion failed or your balance changed. Your Diamonds are unchanged; please retry.';
  static const unavailableDiamondsExplanation =
      'Pending or frozen Diamonds cannot be converted.';
  static const diamondsToConvert = 'Diamonds to convert';
  static const submitting = 'Submitting…';
  static const reviewConversion = 'Review conversion';
  static const amountInXaf = 'Amount in XAF';
  static const mobileMoneyNumber = 'Mobile Money number';
  static const reviewWithdrawal = 'Review withdrawal';
  static const amount = 'Amount';
  static const fee = 'Fee';
  static const netPayout = 'Net payout';
  static const destination = 'Destination';
  static const confirmWithdrawal = 'Confirm withdrawal';
  static const withdrawalDetails = 'Withdrawal details';
  static const statusTimeline = 'Status timeline';
  static const reservedCashReturned =
      'The reserved Cash was returned to your balance.';
  static const noWithdrawals = 'No withdrawals found.';
  static const notEnoughCredits = 'Not enough Credits';
  static const secureSimulatedPayment =
      'Secure simulated payment via SmobilPay/Maviance.';
  static const payoutMethod = 'Payout method';
  static const confirmConversion = 'Confirm conversion';
  static String amountWithUnit(int amount, String unit) => '$amount $unit';
  static String signedAmount(int amount, String unit) =>
      '${amount > 0 ? '+' : ''}$amount $unit';
  static String pendingAndFrozen(int pending, int frozen) =>
      '$pending pending · $frozen frozen';
  static String activityTitle(String balance) => '$balance activity';
  static String statusDetail(String status, String detail) =>
      '$status · $detail';
  static String purchasedVia(String method) => '$method via SmobilPay/Maviance';
  static String convertedAt(int rate) => 'Converted at $rate XAF per Diamond';
  static String convertedAmount(int amount) => 'Converted $amount Diamonds';
  static String minimumWithdrawalError(int minimum) =>
      'Minimum withdrawal is $minimum XAF.';
  static String payoutTo(String method) => 'Payout to $method';
  static String paymentConfirmed(int credits) =>
      '$credits Credits were added to your wallet.';
  static String paymentProvider(String method) =>
      'SmobilPay/Maviance · $method';
  static String estimatedTotal(int amount) => 'Estimated total: $amount XAF';
  static String availableDiamonds(int amount) => '$amount available Diamonds';
  static String conversionRate(int rate) => 'Rate: 1 Diamond = $rate XAF';
  static String cashReceived(int amount) => 'You receive $amount XAF';
  static String cancelPurchase(int credits, String method) =>
      'Cancel the purchase of $credits Credits via $method? Your balance will not change.';
  static String payoutFee(int fee) => 'Mobile Money payout · $fee XAF fee';
  static String requiredCredits(int amount) => 'Required: $amount Credits';
  static String availableCredits(int amount) => 'Available: $amount Credits';
  static String missingCredits(int amount) => 'Missing: $amount Credits';
  static String availableCash(int amount) => '$amount XAF available';
  static String withdrawalTerms(int minimum, int fee) =>
      'Minimum $minimum XAF · Fee $fee XAF';
  static String withdrawalFrequency(int limit) =>
      'Up to $limit ${limit == 1 ? 'withdrawal' : 'withdrawals'} per day.';
  static String conversionCalculation(int diamonds, int rate) =>
      '$diamonds Diamonds × $rate XAF';
  static String withdrawalEvent(DateTime date, String? reason) =>
      '${date.toLocal().toString().substring(0, 16)}${reason == null ? '' : '\n$reason'}';
}
