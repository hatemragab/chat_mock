import 'package:app/features/business/controllers/business_controller.dart';
import 'package:app/features/chats/controllers/chats_controller.dart';
import 'package:app/features/groups/controllers/group_controller.dart';
import 'package:app/features/prototype_tools/ui/widgets/group_business_controls.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:app/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'review controls change group identity and Business source on the retained controllers',
    (tester) async {
      final chats = ChatsController();
      final group = GroupController(chats: chats);
      final wallet = WalletController();
      final business = BusinessController(wallet: wallet);
      addTearDown(() {
        group.dispose();
        business.dispose();
        chats.dispose();
        wallet.dispose();
      });
      final story = StoriesController.stories.firstWhere(
        (s) => s.id == 'maison',
      );
      final before = business.now;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListenableBuilder(
              listenable: Listenable.merge([group, business]),
              builder: (_, _) => ListView(
                children: [
                  GroupBusinessControls(
                    group: group,
                    business: business,
                    onAdvanceClock: business.advance,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Amira Hassan · member').last);
      await tester.pumpAndSettle();
      expect(group.perspectiveId, 'amira');
      expect(group.canManage, isFalse);
      await tester.ensureVisible(find.byType(SwitchListTile));
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(business.sourceEligible(story), isFalse);
      await tester.ensureVisible(
        find.text('Advance Business room clock by 24 hours'),
      );
      await tester.tap(find.text('Advance Business room clock by 24 hours'));
      await tester.pump();
      expect(business.now.difference(before).inHours, 24);
    },
  );
}
