import 'package:flutter/material.dart';

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
  int numberOfCol = 100;
  int numberOfRows = 100;
  int generationGap = 100;

  void navToOverViewPage() {
    Navigator.of(context).push(SetUpOverviewPage.route(
      generationGap: Duration(milliseconds: generationGap),
      numberOfCol: numberOfCol,
      numberOfRows: numberOfRows,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  _InputField(
                    label: 'Number of Rows',
                    onValueChange: (value) {
                      numberOfRows = int.tryParse(value) ?? 50;
                      setState(() {});
                    },
                  ),
                  _InputField(
                    label: 'Number of Columns',
                    onValueChange: (value) {
                      numberOfCol = int.tryParse(value) ?? 50;
                      setState(() {});
                    },
                  ),
                  _InputField(
                    label: 'anim delay (in ms)',
                    onValueChange: (value) {
                      generationGap = int.tryParse(value) ?? 250;
                      setState(() {});
                    },
                  ),
                ],
              ),
              Expanded(
                child: GridOverViewBuilder(
                  numberOFCol: numberOfCol,
                  numberOfRow: numberOfRows,
                ),
              ),
            ],
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
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: numberOFCol,
      ),
      itemCount: numberOFCol * numberOfRow,
      itemBuilder: (context, index) {
        return Placeholder(
          child: Text("$index"),
        );
      },
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.onValueChange,
  });

  final String label;
  final ValueChanged<String> onValueChange;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: TextFormField(
        initialValue: '100',
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (v) {
          if (int.tryParse(v) == null) return;
          onValueChange(v);
        },
      ),
    );
  }
}
