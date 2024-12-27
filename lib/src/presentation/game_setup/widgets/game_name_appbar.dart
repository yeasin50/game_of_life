import 'package:flutter/material.dart';

/// just to show the game name &  github repo in setUp page,
/// can be used
class GameNameAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GameNameAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Conway's Game of Life",
            textAlign: TextAlign.center,
            style: textTheme.titleLarge,
          ),
          SelectableText(
            "https://github.com/yeasin50/game_of_life",
            textAlign: TextAlign.center,
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(120);
}
