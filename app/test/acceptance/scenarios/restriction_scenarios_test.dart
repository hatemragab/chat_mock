import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/publishing/controllers/publishing_controller.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/settings/controllers/settings_controller.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('V128 warning allows messaging and publishing', () {
    final chats = ChatsController();
    final settings = SettingsController(chats: chats);
    final wallet = WalletController();
    chats.canMessage = () => settings.canMessage;
    final publishing = PublishingController(
      wallet: wallet,
      canPublish: () => settings.canPublish,
    );
    addTearDown(() {
      publishing.dispose();
      wallet.dispose();
      settings.dispose();
      chats.dispose();
    });

    settings.setRestriction(RestrictionLevel.warning);
    final chat = chats.byId('sarah');
    final count = chat.messages.length;
    expect(chats.send(chat, 'Warning still permits a message'), isNotNull);
    expect(chat.messages, hasLength(count + 1));
    final draft = publishing.createDraft(PublicationType.status);
    expect(
      publishing.publish(draft, publishing.review(draft)),
      PublishResult.success,
    );
    expect(publishing.publications.any((item) => item.id == draft.id), isTrue);
  });

  for (final level in [
    RestrictionLevel.suspension,
    RestrictionLevel.permanentBan,
  ]) {
    test(
      '${level == RestrictionLevel.suspension ? 'V129' : 'V130'} prevents messaging and publishing without charging',
      () {
        final chats = ChatsController();
        final settings = SettingsController(chats: chats);
        final wallet = WalletController();
        chats.canMessage = () => settings.canMessage;
        final publishing = PublishingController(
          wallet: wallet,
          canPublish: () => settings.canPublish,
        );
        addTearDown(() {
          publishing.dispose();
          wallet.dispose();
          settings.dispose();
          chats.dispose();
        });

        final chat = chats.byId('sarah');
        final messageCount = chat.messages.length;
        final balance = wallet.credits;
        final draft = publishing.createDraft(PublicationType.advertisement);
        final review = publishing.review(draft);
        settings.setRestriction(level);
        expect(chats.send(chat, 'Restricted message'), isNull);
        expect(chat.messages, hasLength(messageCount));
        expect(publishing.publish(draft, review), PublishResult.restricted);
        expect(
          publishing.publications.any((item) => item.id == draft.id),
          isFalse,
        );
        expect(wallet.credits, balance);

        settings.setRestriction(null);
        expect(chats.send(chat, 'Messaging restored'), isNotNull);
        expect(publishing.publish(draft, review), PublishResult.success);
      },
    );
  }
}
