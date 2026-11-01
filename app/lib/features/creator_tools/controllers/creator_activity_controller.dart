import 'package:flutter/foundation.dart';

import '../../business/controllers/business_controller.dart';
import '../../business/models/business_room.dart';
import '../../calls/controllers/calls_controller.dart';
import '../../calls/models/call_session.dart';
import '../../publishing/models/publication.dart';

/// Projects real in-memory interactions for one originating publication.
class CreatorActivityController {
  CreatorActivityController({required this.business, required this.calls});

  final BusinessController business;
  final CallsController calls;

  Listenable get changes => Listenable.merge([business, calls]);

  BusinessRoom? roomFor(Publication publication) =>
      business.roomFor(publication.id);

  List<CallSession> callsFor(Publication publication) {
    final active = calls.active;
    final matching = <CallSession>[
      if (active != null && active.business && active.storyId == publication.id)
        active,
      ...calls.history.where(
        (call) => call.business && call.storyId == publication.id,
      ),
    ];
    matching.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return List.unmodifiable(matching);
  }
}
