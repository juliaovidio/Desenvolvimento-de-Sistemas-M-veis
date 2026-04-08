import 'package:flutter/material.dart';
import '../layout/main_layout.dart';

class LocalizacaoPage extends StatelessWidget {
  final String cargo;
  final String nome;
  final int autorId; // 🔥 1. Adicionamos a variável aqui

  const LocalizacaoPage({
    required this.cargo,
    required this.nome,
    required this.autorId, // 🔥 2. Pedimos ela no construtor
  });

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      cargo: cargo,
      nome: nome,
      titulo: "Localização", // Ajustei o título para fazer sentido com a página
      autorId: autorId, // 🔥 3. Passamos a variável para o MainLayout
      child: Center(child: Text("Tela de Localização")),
    );
  }
}