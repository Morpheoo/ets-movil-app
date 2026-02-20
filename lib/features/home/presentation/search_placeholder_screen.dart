import 'package:flutter/material.dart';

class SearchPlaceholderScreen extends StatelessWidget {
  const SearchPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: const Center(
        child: Text('Pantalla de busqueda (marcador)'),
      ),
    );
  }
}
