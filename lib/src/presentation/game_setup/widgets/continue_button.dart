import 'package:flutter/material.dart';

/// used on game setUp page to
///
class ContinueButton extends StatelessWidget {
  const ContinueButton({
    super.key,
    required this.activeTab,
    required this.onContinue,
    required this.onBack,
  });

  final int activeTab;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedAlign(
          duration: Durations.short3,
          alignment: activeTab == 0 ? Alignment.center : Alignment.centerLeft,
          child: IconButton.outlined(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: onContinue,
            child: Text(activeTab == 0 ? "Continue" : 'Start Game'),
          ),
        ),
      ],
    );
  }
}
