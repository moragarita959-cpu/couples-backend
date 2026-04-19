import 'package:flutter/material.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('\u65e5\u8bb0'),
      ),
      body: const Center(
        child: Text('\u65e5\u8bb0\u529f\u80fd\u5efa\u8bbe\u4e2d'),
      ),
    );
  }
}
