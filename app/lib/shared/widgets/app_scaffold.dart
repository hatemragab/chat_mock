import 'package:flutter/material.dart';

/// Page chrome with consistent safe-area and keyboard behavior.
/// Full-screen media/call layouts and the tab host may manage their own insets.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.backgroundColor,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
    this.safeArea = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;
  final bool safeArea;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: appBar,
    backgroundColor: backgroundColor,
    resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    floatingActionButton: floatingActionButton,
    bottomNavigationBar: bottomNavigationBar,
    body: safeArea ? SafeArea(top: appBar == null, child: body) : body,
  );
}
