import 'package:flutter/material.dart';

enum InputFiledType {
  rows,
  cols,
  animDelay;
}

extension InputFiledTypeExt on InputFiledType {
  String get label => switch (this) {
        InputFiledType.rows => 'Nb of Rows',
        InputFiledType.cols => 'Nb of Columns',
        InputFiledType.animDelay => 'anim delay (in ms)',
      };
}

class InputField extends StatelessWidget {
  const InputField({
    required this.type,
    required this.controller,
    required this.minValue,
  });

  final InputFiledType type;
  final TextEditingController controller;
  final int minValue;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlign: TextAlign.center,
      textAlignVertical: TextAlignVertical.center,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: type.label,
        border: const OutlineInputBorder(),
      ),
      autovalidateMode: AutovalidateMode.always,
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required field';
        int number = int.tryParse(value) ?? 0;

        if (number <= minValue) return 'Value must be greater than  $minValue';
        return null;
      },
    );
  }
}
