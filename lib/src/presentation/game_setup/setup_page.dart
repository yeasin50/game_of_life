import 'package:flutter/material.dart';
import '../_common/widgets/pattern_selection_view.dart';

import '../../domain/cell_pattern.dart';
import '../../domain/domain.dart';
import '../../infrastructure/game_provider.dart';
import 'setup_overview_page.dart';
import 'widgets/continue_button.dart';
import 'widgets/game_config_tile.dart';
import 'widgets/game_name_appbar.dart';

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

  void onContinue() {
    if (currentIndex == 0) {
      currentIndex = 1;
      controller.forward();
      setState(() {});
    } else if (currentIndex == 1) {
      if (formKey.currentState?.validate() == false) {
        return;
      }
      final route = SetUpOverviewPage.route(
        selectedPattern: selectedPattern,
        config: gameConfig, //!ignore for now
      );
      Navigator.of(context).push(route);
    } else {
      throw UnimplementedError();
    }
  }

  void onBack() {
    controller.reverse();
    currentIndex = 0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // to have scrollBar at end
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    const GameNameAppBar(),
                    const SizedBox(height: 48),
                    AnimatedContainer(
                      duration: const Duration(seconds: 3),
                      child: currentIndex == 0
                          ? PatternSelectionView(
                              onChanged: onPatternSelected,
                              selectedPattern: selectedPattern,
                            )
                          : Form(
                              key: formKey,
                              child: GameTileConfigView(selectedPattern: selectedPattern),
                            ),
                    ),
                    const SizedBox(height: 24),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450, maxHeight: 75),
                      child: ContinueButton(
                        activeTab: currentIndex,
                        onBack: onBack,
                        onContinue: onContinue,
                      ),
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
