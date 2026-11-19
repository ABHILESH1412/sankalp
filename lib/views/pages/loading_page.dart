import 'package:flutter/material.dart';
import 'package:sankalp/views/widgets/logo.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: SankalpLogo(size: 72)),
    );
  }
}
