import 'package:flutter/material.dart';
import '../layout/main_layout.dart';

class RotasMotoristaPage extends StatelessWidget {
  final String cargo;
  final String nome;
  final int autorId; // 🔥 1. Adicionamos a variável aqui

  const RotasMotoristaPage({
    required this.cargo,
    required this.nome,
    required this.autorId, // 🔥 2. Pedimos ela no construtor
  });

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      cargo: cargo,
      nome: nome,
      autorId: autorId, // 🔥 3. Passamos para o MainLayout
      titulo: "Minhas Rotas",
      child: Center(child: Text("Tela de Rotas")),
    );
  }
}