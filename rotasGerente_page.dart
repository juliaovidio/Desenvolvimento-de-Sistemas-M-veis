import 'package:flutter/material.dart';
import '../layout/main_layout.dart';
import 'tabs_rotas_gerente/criar_rota_tab.dart'; // Importe a aba que criamos
import 'tabs_rotas_gerente/editar_rota_tab.dart'; // 🔥 ADICIONADO O IMPORT DA EDIÇÃO

// Importe as outras abas conforme for criando. Exemplo:
// import 'tabs_rotas_gerente/visualizar_rotas_tab.dart';
// import 'tabs_rotas_gerente/falhas_rota_tab.dart';

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
      length: 4, // Quantidade de abas
      initialIndex: 1, // Já começa na aba "Criar" (índice 1)
      child: MainLayout(
        cargo: cargo,
        nome: nome,
        autorId: autorId,
        titulo: "Rotas",
        child: Column(
          children: [
            // MENU SUPERIOR (TABS)
            Container(
              color: Colors.grey[300], // Cor de fundo da barra inteira
              child: TabBar(
                indicator: BoxDecoration(
                  color: Colors.grey[500], // Cor da aba selecionada (igual ao Figma)
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 2), // Detalhe abaixo da selecionada
                  )
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black54,
                tabs: [
                  Tab(text: "Visualizar"),
                  Tab(text: "Criar"),
                  Tab(text: "Editar"),
                  Tab(text: "Falhas"),
                ],
              ),
            ),
            // CONTEÚDO DAS ABAS
            Expanded(
              child: TabBarView(
                children: [
                  Center(child: Text("Página Visualizar (Em breve)")), // Substitua pelo seu VisualizarRotasTab()
                  CriarRotaTab(), // Aqui chamamos o arquivo do passo anterior!
                  EditarRotaTab(), // 🔥 ABA DE EDIÇÃO CHAMADA AQUI!
                  Center(child: Text("Página Falhas (Em breve)")),    // Substitua pelo seu FalhasRotaTab()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}