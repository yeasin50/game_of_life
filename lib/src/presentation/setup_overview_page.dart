import 'package:flutter/material.dart';

import '../domain/domain.dart';
import '../infrastructure/game_provider.dart';
import 'gof_life_page.dart';
import 'widgets/export_dialog.dart';
import 'widgets/two_dimensional_custom_paint_gridview.dart';

/// select initial pattern to show
class SetUpOverviewPage extends StatefulWidget {
  const SetUpOverviewPage._();

  static MaterialPageRoute route() {
    return MaterialPageRoute(
      builder: (context) => const SetUpOverviewPage._(),
    );
  }

  @override
  State<SetUpOverviewPage> createState() => _SetUpOverviewPageState();
}

class _SetUpOverviewPageState extends State<SetUpOverviewPage> {
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    gameEngine.init(config: gameConfig).then((value) {
      isLoading = false;
      setState(() {});
    });
  }

  void navToGameBoard() async {
    if (context.mounted) {
      await Navigator.of(context).push(GOFPage.route());
      gameEngine.stopPeriodicGeneration();
      setState(() {});
    }
  }

  final patterns = [
    FiveCellPattern(),
    GliderPattern(),
    LightWeightSpaceShip(),
    MiddleWeightSpaceShip(),
    GosperGliderGun(),
  ];

  CellPattern? selectedPattern;

  void onPatternSelected(CellPattern? value) async {
    if (value == null) return;
    await gameEngine.killCells();
    gameEngine.addPattern(value);
    selectedPattern = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Initial life cell")),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ...patterns.map(
                    (e) => ActionChip(
                      backgroundColor: selectedPattern == e ? Colors.pink : null,
                      label: Text(e.name),
                      onPressed: () => onPatternSelected(e),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => navToGameBoard(),
                    child: const Text("Start"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.redAccent.withAlpha(100),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      gameEngine.killCells();
                      selectedPattern = null;
                      setState(() {});
                    },
                    child: const Text("Clear"),
                  ),
                  const SizedBox(width: 16),
                  const ExportGameData(),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? Container()
                  : const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TwoDimensionalCustomPaintGridView(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
