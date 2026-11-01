import 'package:app/features/calls/controllers/calls_controller.dart';
import 'package:app/features/calls/models/call_session.dart';
import 'package:app/features/stories/controllers/stories_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('business calls retain the selected public Story across sessions', () {
    final controller = CallsController(spendCredits: (_, _, _) => true);
    final first = StoriesController.stories.firstWhere(
      (story) => story.id == 'maison',
    );
    final second = StoriesController.stories.firstWhere(
      (story) => story.id == 'brew',
    );
    final call = controller.start(
      name: 'Private name',
      kind: CallKind.audio,
      business: true,
      story: first,
    );
    expect(call.name, first.author);
    expect(call.storyId, first.id);
    controller.finishRinging(CallPhase.cancelled);
    final incoming = controller.start(
      name: 'Other private name',
      kind: CallKind.video,
      business: true,
      incoming: true,
      story: second,
    );
    expect(incoming.name, second.author);
    expect(incoming.storyId, second.id);
    expect(controller.history.single.story, same(first));
    expect(incoming.story, same(second));
    controller.dispose();
  });
}
