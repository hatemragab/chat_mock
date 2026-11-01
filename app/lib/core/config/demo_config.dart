import '../../features/business/models/business_room.dart';
import '../../features/publishing/models/publication.dart';
import '../../features/wallet/models/wallet_models.dart';

/// Commercial terms for this local demonstration session.
class DemoConfig {
  const DemoConfig({
    this.wallet = const WalletConfig(),
    this.publishing = const PublishingConfig(),
    this.business = const BusinessConfig(),
  });

  final WalletConfig wallet;
  final PublishingConfig publishing;
  final BusinessConfig business;
}
