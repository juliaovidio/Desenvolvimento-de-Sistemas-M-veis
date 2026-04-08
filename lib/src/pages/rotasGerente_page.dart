import 'package:flutter/material.dart';
import '../layout/main_layout.dart';

class RotasGerentePage extends StatelessWidget {
  final String cargo;
  final String nome;
   final int autorId; // 🔥 1. Adicionamos a variável aqui

  const RotasGerentePage({
    required this.cargo,
    required this.nome,
     required this.autorId, 
  });

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      cargo: cargo,
      nome: nome,
       autorId: autorId,
      titulo: "Rotas", // 🔥 MUDA AQUI
      child: Center(child: Text("Tela de Rotas")),
    );
  }
}