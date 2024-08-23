import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game_of_life/src/infrastructure/game_config.dart';

import 'game_of_life_db.dart';

/// Default generation gap is 250 milliseconds
const _defaultGenerationDelay = Duration(milliseconds: 250);

class GameOfLifeEngine {
  GameOfLifeEngine({required this.cellDB});

  final GameOfLifeDataBase cellDB;

  late ValueNotifier<GOFState> _gofState;

  ValueNotifier<GOFState> get gofStateNotifier => _gofState;
  GOFState get gofState => _gofState.value;

  Duration? _generationGap;
  Duration get generationGap => _generationGap ?? _defaultGenerationDelay;
  Timer? _timer;

  Future<void> init({required GameConfig config}) async {
    _generationGap = config.generationGap;
    _gofState = ValueNotifier<GOFState>(const GOFState.empty());

    final grids = await cellDB.init(
      numberOfCol: config.numberOfCol,
      numberOfRows: config.numberOfRows,
    );
    _gofState.value = GOFState(grids, 0);
  }

  void updateState(GOFState newState) {
    _gofState.value = newState;
  }

  Future<void> kill() async {
    _gofState.value = const GOFState.empty();
    _timer?.cancel();
    _timer = null;
    _generationGap = null;
  }

  bool isOnPeriodicProgress = false;

  Future<void> nextGeneration() async {
    final result = await cellDB.nextGeneration(gofState.data);
    _gofState.value = GOFState([...result], gofState.generation + 1);
    isOnPeriodicProgress = false;
  }

  /// if [delay] is null, it will be default value of [generationGap]
  void startPeriodicGeneration({Duration? delay}) {
    _timer?.cancel();
    _timer = null;
    _timer = Timer.periodic(delay ?? generationGap, (t) async {
      if (isOnPeriodicProgress) return;

      isOnPeriodicProgress = true;
      await nextGeneration();

      //todo: check if pattern has been locked, like repeat the same pattern
      // if so cancel the timer
    });
  }

  void stopPeriodicGeneration() {
    _timer?.cancel();
    _timer = null;
    isOnPeriodicProgress = false;
  }
}
