import 'package:flutter/material.dart';

import '../../domain/grid_data.dart';
import '../utils/grid_data_extension.dart';

class GridItemView extends StatelessWidget {
  const GridItemView({
    super.key,
    required this.data,
  });
  final GridData data;

  @override
  Widget build(BuildContext context) {
    Theme.of(context).colorScheme.surface;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: data.color,
      ),
      child: FittedBox(child: Text("${data}")),
    );
  }
}
