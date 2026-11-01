import 'package:flutter/material.dart';

import '../../../controllers/calls_controller.dart';
import '../../../copy/calls_copy.dart';
import '../../../models/call_session.dart';

class LowCallBalanceDialog extends StatelessWidget {
  const LowCallBalanceDialog({
    super.key,
    required this.controller,
    required this.call,
  });
  final CallsController controller;
  final CallSession call;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(CallsCopy.lowCallBalance),
    content: Text(
      CallsCopy.nextBlock(
        call.kind.label,
        call.name,
        controller.rateFor(call.kind),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(CallsCopy.ok),
      ),
    ],
  );
}
