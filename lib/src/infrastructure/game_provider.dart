import 'package:flutter/material.dart';

import 'game_config.dart';
import 'game_of_life_db.dart';
import 'game_of_life_engine.dart';

extension GameProviderBuildContext on BuildContext {
  GameProvider get gameProvider => GameOfLifeInheritedWidget.of(this, listen: false);

  GameOfLifeEngine get gameEngine => gameProvider.engine;
  GameConfig get gameConfig => gameProvider.config;
  GameOfLifeDataBase get database => gameProvider.engine.cellDB;
}

extension GameStateExt<T extends StatefulWidget> on State<T> {
  GameProvider get gameProvider => context.gameProvider;
  GameOfLifeEngine get gameEngine => context.gameEngine;
  GameConfig get gameConfig => context.gameConfig;
  GameOfLifeDataBase get database => context.database;
}

class GameProvider {
  const GameProvider._({
    required this.engine,
    required this.config,
  });

  static Future<GameProvider> init() async {
    final GameConfig gameConfig = GameConfig(
      numberOfCol: 4,
      numberOfRows: 4,
      generationGap: const Duration(milliseconds: 250),
    );

    final engine = GameOfLifeEngine(cellDB: GameOfLifeDataBase());

    return GameProvider._(
      engine: engine,
      config: gameConfig,
    );
  }

  final GameOfLifeEngine engine;
  final GameConfig config;

  void updateConfig(GameConfig newConfig) {
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
