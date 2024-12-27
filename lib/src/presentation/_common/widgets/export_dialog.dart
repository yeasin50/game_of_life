import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../infrastructure/game_provider.dart';

class ExportGameData extends StatelessWidget {
  const ExportGameData({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final textData = await context.patternRepo.toRLE(context.gameState.data);
        if (context.mounted == false) return;

        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: SelectableText(textData),
              actions: [
                TextButton.icon(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(Icons.close),
                  label: const Text("Close"),
                ),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: textData));
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text("Copy"),
                ),
              ],
            );
          },
        );
      },
      child: const Text("Export"),
    );
  }
}
