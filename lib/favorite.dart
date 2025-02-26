import 'package:flutter/material.dart';

class FavoriteSurah extends StatelessWidget {
  const FavoriteSurah({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Surah Favorit'),
      ),
      body: const Center(
        child: Text('Daftar Surah Favorit'),
      ),
    );
  }
}