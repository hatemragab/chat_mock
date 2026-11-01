import 'package:app/app/app.dart';
import 'package:app/app/ui/screens/home_shell/home_shell.dart';
import 'package:app/features/profile/ui/screens/profile_screen/profile_screen.dart';
import 'package:app/features/publishing/models/publication.dart';
import 'package:app/features/settings/models/settings_models.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/wallet/models/wallet_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Reset demo restores coherent shared session fixtures', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(386, 802);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const WhizpeeApp());
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    final shell = tester.widget<HomeShell>(find.byType(HomeShell));
    final payment = shell.wallet.startPayment(
      id: shell.wallet.newId('payment'),
      credits: 20,
      method: PaymentMethod.mtn,
      phone: '670000000',
    );
    shell.wallet.setPaymentStatus(payment.id, PaymentStatus.confirmed);
    final draft = shell.publishing.createDraft(PublicationType.status);
    shell.publishing.publish(draft, shell.publishing.review(draft));
    shell.group.updateIdentity('Changed team', 'Changed details');
    final story = StoriesController.stories.firstWhere(
      (item) => item.id == 'maison',
    );
    shell.business.openRoom(story, confirmed: true);
    shell.chats.setOnline(false);
    shell.settings.setPermission('Contacts', MockPermission.denied);
    await tester.pump();
    expect(shell.wallet.credits, isNot(3000));
    expect(shell.publishing.usedPhotoSlots, 3);
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Prototype tools'),
      250,
      scrollable: find
          .descendant(
            of: find.byType(ProfileScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Prototype tools'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Reset demo'),
      350,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Reset demo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset').last);
    await tester.pumpAndSettle();
    expect(shell.wallet.credits, 3000);
    expect(shell.wallet.diamonds, 350);
    expect(shell.wallet.pendingDiamonds, 40);
    expect(shell.wallet.cash, 1000);
    expect(shell.publishing.usedPhotoSlots, 2);
    expect(shell.publishing.publications.map((item) => item.id).toSet(), {
      'seed-status-1',
      'seed-status-2',
    });
    expect(shell.group.name, 'Design Team');
    expect(shell.chats.online, isTrue);
    expect(shell.settings.permissions['Contacts'], MockPermission.allowed);
    expect(shell.business.roomFor('maison')?.openingCount, 1);
    expect(shell.business.isActive(shell.business.roomFor('maison')!), isFalse);
  });
}
