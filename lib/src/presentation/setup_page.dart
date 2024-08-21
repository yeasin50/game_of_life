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
  Widget build(BuildContext context) {
    GameOfLifeInheritedWidget.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: InputFiledType.rows.filedSize.width + (2.5 * InputFiledType.cols.filedSize.width),
                  height: InputFiledType.cols.filedSize.height + (InputFiledType.cols.filedSize.width * 2),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: _InputField(
                          type: InputFiledType.animDelay,
                          initialValue: gameConfig.generationGap.inMilliseconds.toString(),
                          onValueChange: (value) {
                            final number = int.tryParse(value) ?? 0;
                            gameConfig.generationGap = Duration(milliseconds: number);
                            setState(() {});
                          },
                        ),
                      ),
                      Positioned(
                        left: 0,
                        bottom: InputFiledType.cols.filedSize.width + 10,
                        child: _InputField(
                          type: InputFiledType.cols,
                          initialValue: gameConfig.numberOfRows.toString(),
                          onValueChange: (value) {
                            final number = int.tryParse(value) ?? 0;
                            gameConfig.numberOfRows = number;
                            setState(() {});
                          },
                        ),
                      ),
                      Positioned(
                        left: InputFiledType.cols.filedSize.width + 10,
                        bottom: 0,
                        child: _InputField(
                          initialValue: gameConfig.numberOfCol.toString(),
                          type: InputFiledType.rows,
                          onValueChange: (value) {
                            final number = int.tryParse(value) ?? 0;
                            gameConfig.numberOfCol = number;
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: gameConfig.isValid ? navToOverViewPage : null,
                  child: const Text('Start Game'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GridOverViewBuilder extends StatelessWidget {
  const GridOverViewBuilder({
    super.key,
    required this.numberOFCol,
    required this.numberOfRow,
  });

  final int numberOFCol;
  final int numberOfRow;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [],
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
        InputFiledType.rows => 'Rows',
        InputFiledType.cols => 'Columns',
        InputFiledType.animDelay => 'anim delay (in ms)',
      };

  Size get filedSize => switch (this) {
        InputFiledType.rows => const Size(200, 84),
        InputFiledType.cols => const Size(84, 200),
        InputFiledType.animDelay => const Size(200, 100),
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
    return SizedBox(
      key: ValueKey(type.label),
      width: type.filedSize.width,
      height: type.filedSize.height,
      child: TextFormField(
        expands: true,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        maxLines: null,
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: type.label,
          floatingLabelAlignment: FloatingLabelAlignment.center,
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
      ),
    );
  }
}
