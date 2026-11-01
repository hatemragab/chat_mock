import 'package:flutter/material.dart';

import '../../../controllers/calls_controller.dart';
import '../../../copy/calls_copy.dart';
import '../../../models/call_session.dart';

class AudioOutputSheet extends StatelessWidget {
  const AudioOutputSheet({
    super.key,
    required this.controller,
    required this.call,
  });
  final CallsController controller;
  final CallSession call;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              CallsCopy.audioOutput,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          for (final choice in [
            (CallOutput.earpiece, CallsCopy.earpiece, Icons.hearing),
            (CallOutput.speaker, CallsCopy.speaker, Icons.volume_up_outlined),
            (CallOutput.bluetooth, CallsCopy.bluetoothDevice, Icons.bluetooth),
          ])
            ListTile(
              leading: Icon(choice.$3),
              title: Text(choice.$2),
              trailing: call.output == choice.$1
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                controller.setOutput(choice.$1);
                Navigator.pop(context);
              },
            ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}
