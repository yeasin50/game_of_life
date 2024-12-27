import 'package:flutter/material.dart';

import '../app/game_config.dart';
import 'infrastructure.dart';

extension GameProviderBuildContext on BuildContext {
  GameProvider get gameProvider => GameOfLifeInheritedWidget.of(this, listen: false);

  GameOfLifeEngine get gameEngine => gameProvider.engine;
  GameConfig get gameConfig => gameProvider.config;
  GameOfLifeDataBase get database => gameProvider.engine.cellDB;
  GOFState get gameState => gameEngine.gofState;

  CellPatternRepo get patternRepo => gameProvider.patternRepo;
}

extension GameStateExt<T extends StatefulWidget> on State<T> {
  GameProvider get gameProvider => context.gameProvider;
  GameOfLifeEngine get gameEngine => context.gameEngine;
  GameConfig get gameConfig => context.gameConfig;
  GameOfLifeDataBase get database => context.database;
  CellPatternRepo get patternRepo => context.patternRepo;
}

class GameProvider {
  const GameProvider._({
    required this.engine,
    required this.config,
    required this.patternRepo,
  });

  static Future<GameProvider> init() async {
    final GameConfig gameConfig = GameConfig(
      numberOfCol: 60,
      numberOfRows: 60,
      dimension: 75,
      generationGap: const Duration(milliseconds: 250),
      clipOnBorder: true,
    );

    final engine = GameOfLifeEngine(cellDB: GameOfLifeDataBase(), config: gameConfig);

    final patternRep = await CellPatternRepo.create();

    ///! something is not right, the assets doesNt load so I have used it,
    ///* A better approach  is using Stream
    await Future.delayed(const Duration(milliseconds: 200));

    return GameProvider._(
      engine: engine,
      config: gameConfig,
      patternRepo: patternRep,
    );
  }

  final GameOfLifeEngine engine;
  final GameConfig config;
  final CellPatternRepo patternRepo;

  void show(GameConfig newConfig) {
    throw UnimplementedError();
  }
}

@immutable
class GameOfLifeInheritedWidget extends InheritedWidget {
  const GameOfLifeInheritedWidget({
    super.key,
    required this.provider,
    required super.child,
  });

  final GameProvider provider;

  static GameProvider of(BuildContext context, {bool listen = true}) {
    if (listen) {
      return context.dependOnInheritedWidgetOfExactType<GameOfLifeInheritedWidget>()!.provider;
    }
    return context.findAncestorWidgetOfExactType<GameOfLifeInheritedWidget>()!.provider;
  }

  @override
  bool updateShouldNotify(GameOfLifeInheritedWidget oldWidget) {
    return oldWidget.provider != provider;
  }
}
