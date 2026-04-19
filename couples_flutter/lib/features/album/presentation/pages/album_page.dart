import 'package:flutter/material.dart';

class AlbumPage extends StatelessWidget {
  const AlbumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('\u76f8\u518c'),
      ),
      body: const Center(
        child: Text('\u76f8\u518c\u529f\u80fd\u5efa\u8bbe\u4e2d'),
      ),
    );
  }
}
