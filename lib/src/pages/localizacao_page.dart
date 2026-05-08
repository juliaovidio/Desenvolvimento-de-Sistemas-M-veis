import 'package:flutter/material.dart';
import '../layout/main_layout.dart';

class LocalizacaoPage extends StatelessWidget {
  final String cargo;
  final String nome;
  final int autorId; // Adicionamos a variável aqui

  const LocalizacaoPage({
    required this.cargo,
    required this.nome,
    required this.autorId, //  Pedimos ela no construtor
  });

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      cargo: cargo,
      nome: nome,
      titulo: "Localização", // Ajustei o título para fazer sentido com a página
      autorId: autorId, //  Passamos a variável para o MainLayout
      child: Center(child: Text("Tela de Localização")),
    );
  }
}