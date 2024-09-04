import 'package:flutter/material.dart';

import '../infrastructure/game_provider.dart';
import 'setup_overview_page.dart';

/// - decide number of Rows and Columns
/// - decide generation delay
/// -
class GameBoardSetupPage extends StatefulWidget {
  const GameBoardSetupPage({super.key});

  @override
  State<GameBoardSetupPage> createState() => _GameBoardSetupPageState();
}

class _GameBoardSetupPageState extends State<GameBoardSetupPage> {
  void navToOverViewPage() {
    Navigator.of(context).push(SetUpOverviewPage.route());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _InputField(
                    type: InputFiledType.cols,
                    initialValue: gameConfig.numberOfRows.toString(),
                    onValueChange: (value) {
                      final number = int.tryParse(value) ?? 0;
                      gameConfig.numberOfRows = number;
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 24),
                  _InputField(
                    initialValue: gameConfig.numberOfCol.toString(),
                    type: InputFiledType.rows,
                    onValueChange: (value) {
                      final number = int.tryParse(value) ?? 0;
                      gameConfig.numberOfCol = number;
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 24),
                  _InputField(
                    type: InputFiledType.animDelay,
                    initialValue: gameConfig.generationGap.inMilliseconds.toString(),
                    onValueChange: (value) {
                      final number = int.tryParse(value) ?? 0;
                      gameConfig.generationGap = Duration(milliseconds: number);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: gameConfig.clipOnBorder,
                    title: const Text("Clip on border"),
                    onChanged: (value) async {
                      gameConfig.clipOnBorder = value;
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 64),
                  ElevatedButton(
                    onPressed: gameConfig.isValid ? navToOverViewPage : null,
                    child: const Text('Start Game'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum InputFiledType {
  rows,
  cols,
  animDelay;
}

extension InputFiledTypeExt on InputFiledType {
  String get label => switch (this) {
        InputFiledType.rows => 'Nb of Rows',
        InputFiledType.cols => 'Nb of Columns',
        InputFiledType.animDelay => 'anim delay (in ms)',
      };
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.type,
    required this.onValueChange,
    required this.initialValue,
  });

  final InputFiledType type;
  final ValueChanged<String> onValueChange;
  final String initialValue;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlign: TextAlign.center,
      textAlignVertical: TextAlignVertical.center,
      initialValue: initialValue,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: type.label,
        border: const OutlineInputBorder(),
      ),
      autovalidateMode: AutovalidateMode.always,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required field';
        int number = int.tryParse(value) ?? 0;
        if (number <= 0) return 'Value must be greater than 0';
        return null;
      },
      onChanged: (v) {
        onValueChange(v);
      },
    );
  }
}
