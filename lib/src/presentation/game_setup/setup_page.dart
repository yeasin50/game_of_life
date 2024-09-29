import 'package:flutter/material.dart';
import '../widgets/pattern_selection_view.dart';

import '../../domain/cell_pattern.dart';
import '../../domain/domain.dart';
import '../../infrastructure/game_provider.dart';
import '../setup_overview_page.dart';
import 'widgets/game_config_tile.dart';

/// - decide number of Rows and Columns
/// - decide generation delay
/// -
class GameBoardSetupPage extends StatefulWidget {
  const GameBoardSetupPage({super.key});

  @override
  State<GameBoardSetupPage> createState() => _GameBoardSetupPageState();
}

class _GameBoardSetupPageState extends State<GameBoardSetupPage> with SingleTickerProviderStateMixin {
  late AnimationController controller = AnimationController(vsync: this, duration: Durations.medium1);

  late final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  CellPattern? selectedPattern;

  void onPatternSelected(CellPattern? value) async {
    selectedPattern = value;
    gameConfig.clipOnBorder = value?.clip ?? false;
    setState(() {});
    if (value != null) {
      if (gameConfig.numberOfCol < value.minSpace.$2) {
        gameConfig.numberOfCol = value.minSpace.$2 + 2;
      }
      if (gameConfig.numberOfRows < value.minSpace.$1) {
        gameConfig.numberOfRows = value.minSpace.$1 + 2;
      }
    }
  }

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Conway's Game of Life",
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      "https://github.com/yeasin50/game_of_life",
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      height: 450,
                      child: AnimatedSwitcher(
                        duration: Durations.medium3,
                        child: currentIndex == 1
                            ? Form(
                                key: formKey,
                                child: GameTileConfigView(selectedPattern: selectedPattern),
                              )
                            : PatternSelectionView(
                                onChanged: onPatternSelected,
                                selectedPattern: selectedPattern,
                              ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 48),
                        Stack(
                          children: [
                            AnimatedAlign(
                              duration: Durations.short3,
                              alignment: currentIndex == 0 ? Alignment.center : Alignment.centerLeft,
                              child: IconButton.outlined(
                                onPressed: () {
                                  controller.reverse();
                                  currentIndex = 0;
                                  setState(() {});
                                },
                                icon: const Icon(Icons.arrow_back_ios_new),
                              ),
                            ),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (currentIndex == 0) {
                                    currentIndex = 1;
                                    controller.forward();
                                    setState(() {});
                                  } else if (currentIndex == 1) {
                                    if (formKey.currentState?.validate() == false) {
                                      return;
                                    }
                                    Navigator.of(context).push(
                                      SetUpOverviewPage.route(
                                        selectedPattern: selectedPattern,
                                        config: gameConfig, //!ignore for now
                                      ),
                                    );
                                  } else {
                                    throw UnimplementedError();
                                  }
                                },
                                child: Text(currentIndex == 0 ? "Continue" : 'Start Game'),
                              ),
                            ),
                            const SizedBox(),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
