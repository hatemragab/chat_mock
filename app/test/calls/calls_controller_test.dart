import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/calls/models/call_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'an unaffordable answer has a start cause rather than a paid boundary',
    () {
      final controller = CallsController(spendCredits: (_, _, _) => false);
      addTearDown(controller.dispose);
      final call = controller.start(
        name: 'Maison Studio',
        kind: CallKind.audio,
        business: true,
        storyId: 'maison',
      );
      expect(controller.answer(), isFalse);
      expect(call.endCause, CallEndCause.insufficientStartCredits);
      expect(call.seconds, 0);
      expect(call.totalCost, 0);
      expect(controller.history.single, same(call));
    },
  );

  test(
    'unanswered business calls do not charge and repeated end is harmless',
    () {
      var spends = 0;
      final controller = CallsController(
        spendCredits: (_, _, _) {
          spends++;
          return true;
        },
      );
      controller.start(
        name: 'Maison Studio',
        kind: CallKind.video,
        business: true,
        storyId: 'maison',
      );
      controller.finishRinging(CallPhase.missed);
      controller.end();
      expect(spends, 0);
      expect(controller.history.single.totalCost, 0);
      controller.dispose();
    },
  );

  test('answered business calls charge once per started block and stop at balance boundary', () {
    var balance = 30;
    final ids = <String>{};
    final controller = CallsController(
      spendCredits: (id, amount, _) {
        if (ids.contains(id)) return true;
        if (balance < amount) return false;
        balance -= amount;
        ids.add(id);
        return true;
      },
    );
    final call = controller.start(
      name: 'Maison Studio',
      kind: CallKind.audio,
      business: true,
      storyId: 'maison',
    );
    expect(controller.answer(), isTrue);
    expect(balance, 15);
    controller.setMinimized(true);
    controller.advance(60);
    expect(balance, 15);
    controller.advance(1);
    expect(balance, 0);
    controller.advance(59);
    controller.advance(1);
    expect(controller.active, isNull);
    expect(call.seconds, 120);
    expect(call.totalCost, 30);
    expect(call.endCause, CallEndCause.insufficientNextBlock);
    controller.end();
    expect(controller.history.length, 1);
    controller.dispose();
  });

  test('incoming business recipient is not charged', () {
    var spends = 0;
    final controller = CallsController(
      spendCredits: (_, _, _) {
        spends++;
        return true;
      },
    );
    controller.start(
      name: 'Maison Studio',
      kind: CallKind.video,
      business: true,
      incoming: true,
      storyId: 'maison',
    );
    controller.answer();
    controller.advance(121);
    expect(spends, 0);
    controller.dispose();
  });
  test(
    'warns about an uncovered next block while preserving reconnecting session',
    () {
      var balance = 15;
      final controller = CallsController(
        spendCredits: (_, amount, _) {
          if (balance < amount) return false;
          balance -= amount;
          return true;
        },
        availableCredits: () => balance,
      );
      final call = controller.start(
        name: 'Daily Brew',
        kind: CallKind.audio,
        business: true,
        storyId: 'brew',
      );
      expect(controller.answer(), isTrue);
      expect(controller.lowBalance, isTrue);
      controller.setReconnecting(true);
      controller.advance(60);
      expect(call.phase, CallPhase.ended);
      expect(call.seconds, 60);
      controller.advance(1);
      expect(call.phase, CallPhase.ended);
      expect(call.totalCost, 15);
      expect(controller.history.where((item) => item.id == call.id).length, 1);
      controller.dispose();
    },
  );

  test('unaffordable calls stop at the exact boundary without precharging', () {
    var balance = 15;
    final charges = <int>[];
    final controller = CallsController(
      availableCredits: () => balance,
      spendCredits: (_, amount, _) {
        if (balance < amount) return false;
        balance -= amount;
        charges.add(amount);
        return true;
      },
    );
    final call = controller.start(
      name: 'Maison Studio',
      kind: CallKind.audio,
      business: true,
      storyId: 'maison',
    );
    expect(controller.answer(), isTrue);
    controller.setMinimized(true);
    controller.advance(59);
    expect(controller.active, same(call));
    controller.advance(1);
    expect(controller.active, isNull);
    expect(call.seconds, 60);
    expect(call.totalCost, 15);
    expect(charges, [15]);
    expect(call.endCause, CallEndCause.insufficientNextBlock);
    controller.end();
    controller.advance(1);
    expect(call.endCause, CallEndCause.insufficientNextBlock);
    expect(
      controller.history.where((item) => item.id == call.id),
      hasLength(1),
    );
    controller.dispose();
  });

  test('an affordable next block is charged only when it starts', () {
    var balance = 30;
    final controller = CallsController(
      availableCredits: () => balance,
      spendCredits: (_, amount, _) {
        if (balance < amount) return false;
        balance -= amount;
        return true;
      },
    );
    final call = controller.start(
      name: 'Maison Studio',
      kind: CallKind.audio,
      business: true,
      storyId: 'maison',
    );
    expect(controller.answer(), isTrue);
    controller.advance(60);
    expect(controller.active, same(call));
    expect(call.totalCost, 15);
    expect(balance, 15);
    controller.advance(1);
    expect(call.totalCost, 30);
    expect(balance, 0);
    controller.advance(59);
    expect(controller.active, isNull);
    expect(call.seconds, 120);
    expect(controller.history, hasLength(1));
    controller.dispose();
  });

  test('permission denial cannot start an active session or charge', () {
    var spends = 0;
    final controller = CallsController(
      spendCredits: (_, _, _) {
        spends++;
        return true;
      },
    );
    controller.setPermissionGranted(false);
    final blocked = controller.start(name: 'Sarah', kind: CallKind.video);
    expect(blocked.phase, CallPhase.permissionBlocked);
    expect(controller.active, isNull);
    expect(controller.answer(), isFalse);
    expect(spends, 0);
    controller.dispose();
  });

  test(
    'fixtures can be deleted and reset without changing an active balance',
    () {
      final controller = CallsController(
        spendCredits: (_, _, _) => true,
        seedHistory: true,
      );
      expect(controller.history.length, 3);
      final first = controller.history.first;
      controller.deleteHistory(first);
      expect(controller.history, isNot(contains(first)));
      controller.reset();
      expect(controller.history.length, 3);
      expect(
        controller.history.any((call) => call.phase == CallPhase.missed),
        isTrue,
      );
      controller.dispose();
    },
  );
}
