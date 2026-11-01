import '../../../../../shared/widgets/app_scaffold.dart';

import '../../../copy/onboarding_copy.dart';
import '../../../../../shared/copy/common_copy.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_header.dart';

import '../../../controllers/onboarding_controller.dart';

class ContactsAccessScreen extends StatefulWidget {
  const ContactsAccessScreen({
    super.key,
    required this.controller,
    required this.onComplete,
    this.initiallyStartMatching = false,
    this.matchingDelay = const Duration(milliseconds: 800),
  });

  final OnboardingController controller;
  final VoidCallback onComplete;
  final bool initiallyStartMatching;
  final Duration matchingDelay;

  @override
  State<ContactsAccessScreen> createState() => _ContactsAccessScreenState();
}

class _ContactsAccessScreenState extends State<ContactsAccessScreen> {
  Timer? _matchingTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initiallyStartMatching) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _allow();
      });
    }
  }

  @override
  void dispose() {
    _matchingTimer?.cancel();
    super.dispose();
  }

  void _allow() {
    if (widget.controller.hasContactsSession) {
      widget.controller.startSessionContactMatching(widget.matchingDelay);
      return;
    }
    widget.controller.setContactsState(ContactsState.matching);
    _matchingTimer?.cancel();
    _matchingTimer = Timer(widget.matchingDelay, () {
      if (mounted) widget.controller.setContactsState(ContactsState.empty);
    });
  }

  void _cancelMatching() {
    if (widget.controller.hasContactsSession) {
      widget.controller.cancelSessionContactMatching();
    } else {
      _matchingTimer?.cancel();
      widget.controller.setContactsState(ContactsState.idle);
    }
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppHeader(title: const Text(OnboardingCopy.findYourContacts)),
    body: SafeArea(
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final state = widget.controller.contactsState;
          return LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 40).clamp(
                    0.0,
                    double.infinity,
                  ),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(),
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        state == ContactsState.empty
                            ? OnboardingCopy.noMatchingContactsYet
                            : state == ContactsState.matched
                            ? OnboardingCopy.mutualContactsFound
                            : state == ContactsState.denied
                            ? OnboardingCopy.contactsAccessDeclined
                            : state == ContactsState.failed
                            ? OnboardingCopy.contactMatchingFailed
                            : OnboardingCopy.connectWithPeopleYouKnow,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state == ContactsState.empty
                            ? OnboardingCopy.noMatchesDescription
                            : state == ContactsState.matched
                            ? OnboardingCopy.matchedContactsDescription(
                                widget.controller.matchedContactNames,
                              )
                            : state == ContactsState.denied
                            ? OnboardingCopy.declinedContactsDescription
                            : state == ContactsState.failed
                            ? OnboardingCopy.failedMatchingDescription
                            : OnboardingCopy.contactsExplanation,
                        textAlign: TextAlign.center,
                      ),
                      if (state == ContactsState.matching) ...[
                        const SizedBox(height: 24),
                        const CircularProgressIndicator(),
                        const SizedBox(height: 12),
                        const Text(OnboardingCopy.findingMutualContacts),
                        TextButton(
                          onPressed: _cancelMatching,
                          child: const Text(OnboardingCopy.cancelMatching),
                        ),
                      ],
                      const Spacer(),
                      if (state == ContactsState.matched ||
                          state == ContactsState.empty ||
                          state == ContactsState.denied)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: widget.onComplete,
                            child: const Text(
                              OnboardingCopy.continueToDiscover,
                            ),
                          ),
                        )
                      else if (state != ContactsState.matching) ...[
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _allow,
                            child: Text(
                              state == ContactsState.failed
                                  ? OnboardingCopy.retryMatching
                                  : OnboardingCopy.allowContacts,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (state != ContactsState.failed) {
                              widget.controller.declineContacts();
                            }
                            widget.onComplete();
                          },
                          child: Text(
                            state == ContactsState.failed
                                ? OnboardingCopy.continueWithoutContacts
                                : CommonCopy.notNow,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
