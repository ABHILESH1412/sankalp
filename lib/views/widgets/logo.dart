import 'package:flutter/material.dart';

/// The Sankalp "S" mark, tinted to match the current theme (white on dark,
/// black on light) unless [color] is given.
class SankalpLogo extends StatelessWidget {
  const SankalpLogo({super.key, this.size = 28, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      semanticLabel: 'Sankalp',
    );
  }
}
