import 'package:flutter/material.dart';

import '../constants/design_tokens.dart';

class Separator extends StatelessWidget {
  const Separator._({
    super.key,
    this.width = 0,
    this.height = 0,
  });

  final double width;
  final double height;

  factory Separator.w12({Key? key}) => Separator._(
        key: key,
        width: AppSpacing.md,
      );

  factory Separator.h12({Key? key}) => Separator._(
        key: key,
        height: AppSpacing.md,
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height);
  }
}
