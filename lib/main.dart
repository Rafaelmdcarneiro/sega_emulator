import 'package:flutter/material.dart';
import 'emulator_screen.dart';

void main() {
  runApp(const SegaEmulatorApp());
}

class SegaEmulatorApp extends StatelessWidget {
  const SegaEmulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sega Master System Emulator',
      theme: ThemeData.dark(),
      home: const EmulatorScreen(),
    );
  }
}
