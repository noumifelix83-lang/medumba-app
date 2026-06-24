import 'package:flutter/material.dart';
import '../theme/colors.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String emoji;
  const PlaceholderScreen({super.key, required this.title, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: kInk)),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kInk)),
            const SizedBox(height: 8),
            const Text('Bientôt disponible', style: TextStyle(color: kMuted, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
