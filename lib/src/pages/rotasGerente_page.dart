import 'package:app_mobile/src/pages/tab_rotas_gerente/criar_rota_tab.dart';
import 'package:app_mobile/src/pages/tab_rotas_gerente/editar_rota_tab.dart';
import 'package:app_mobile/src/pages/tab_rotas_gerente/falhas_rota_tab.dart';
import 'package:app_mobile/src/pages/tab_rotas_gerente/visualizar_rota_tab.dart';
import 'package:flutter/material.dart';
import '../layout/main_layout.dart';

class RotasGerentePage extends StatelessWidget {
  final String cargo;
  final String nome;
  final int autorId;

  const RotasGerentePage({
    required this.cargo,
    required this.nome,
    required this.autorId, 
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: 0,  // (Visualizar)
      child: MainLayout(
        cargo: cargo,
        nome: nome,
        autorId: autorId,
        titulo: "Rotas",
        child: Column(
          children: [
            // 📦 CONTEÚDO DAS ABAS (FICA NA PARTE DE CIMA)
            Expanded(
              child: Container(
                color: const Color(0xFFF4F7FB), // Cor de fundo do app (cinza bem clarinho)
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(), // Evita deslizar para o lado sem querer
                  children: [
                    VisualizarRotasTab(),  
                    CriarRotaTab(),
                    EditarRotaTab(),
                    FalhasRotaTab(),
                  ],
                ),
              ),
            ),
            
            // 🔘 MENU INFERIOR DE ABAS (COMO NO DESIGN)
            Container(
              padding: const EdgeInsets.only(bottom: 12, top: 8, left: 8, right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ]
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: const Color(0xFFEEF2FF), // Fundo azul claro para a aba selecionada
                  borderRadius: BorderRadius.circular(16),
                ),
                indicatorPadding: const EdgeInsets.symmetric(horizontal: -4, vertical: 4),
                labelColor: const Color(0xFF3730A3), // Cor azul escura (Texto e Ícone selecionado)
                unselectedLabelColor: const Color(0xFF9CA3AF), // Cor cinza (Texto e Ícone não selecionado)
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.remove_red_eye_outlined, size: 22), 
                    text: "Visualizar",
                    iconMargin: EdgeInsets.only(bottom: 4),
                  ),
                  Tab(
                    icon: Icon(Icons.add_circle_outline, size: 22), 
                    text: "Criar",
                    iconMargin: EdgeInsets.only(bottom: 4),
                  ),
                  Tab(
                    icon: Icon(Icons.edit_document, size: 22), 
                    text: "Editar",
                    iconMargin: EdgeInsets.only(bottom: 4),
                  ),
                  Tab(
                    icon: Icon(Icons.report_problem_outlined, size: 22), 
                    text: "Falhas",
                    iconMargin: EdgeInsets.only(bottom: 4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}