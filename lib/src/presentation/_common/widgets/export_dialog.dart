import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/cell_pattern.dart';
import '../../../infrastructure/game_provider.dart';

class ExportGameData extends StatelessWidget {
  const ExportGameData({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        bool isClassFormat = false;
        showDialog(
          context: context,
          builder: (context) {
            final textData = CellPattern.printData(context.gameState.data, true);

            //todo: create micro
            final classFormat = '''
class MyCellPattern implements CellPattern {
  @override
  List<GridData> get data => CellPattern.fromDigit(${textData.trim()}).expand((e) => e).toList();

  @override
  String get name => "MyCellPattern";

  
  @override
  bool? get clip => ${context.gameConfig.clipOnBorder};

  @override
  (int, int) get minSpace => (${context.gameConfig.numberOfRows},${context.gameConfig.numberOfCol});
}
''';

            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  content: SelectableText(isClassFormat ? classFormat : textData),
                  actions: [
                    TextButton.icon(
                      onPressed: Navigator.of(context).pop,
                      icon: const Icon(Icons.close),
                      label: const Text("Close"),
                    ),
                    TextButton.icon(
                      icon: isClassFormat ? const Icon(Icons.class_) : const Icon(Icons.print),
                      onPressed: () {
                        isClassFormat = !isClassFormat;
                        setState(() {});
                      },
                      label: Text(isClassFormat ? "Data only" : "Class format"),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: isClassFormat ? classFormat : textData));
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text("Copy"),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
      child: const Text("Export"),
    );
  }
}
