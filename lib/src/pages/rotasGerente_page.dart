import 'package:flutter/material.dart';
import '../layout/main_layout.dart';
import 'tabs_rotas_gerente/criar_rota_tab.dart';
import 'tabs_rotas_gerente/editar_rota_tab.dart';
import 'tabs_rotas_gerente/falhas_rota_tab.dart';
import 'tabs_rotas_gerente/visualizar_rotas_tab.dart';

class RotasGerentePage extends StatefulWidget {
  final String cargo;
  final String nome;
  final int autorId;

  const RotasGerentePage({
    Key? key,
    required this.cargo,
    required this.nome,
    required this.autorId, 
  }) : super(key: key);

  @override
  _RotasGerentePageState createState() => _RotasGerentePageState();
}

class _RotasGerentePageState extends State<RotasGerentePage> {
  // Controle de qual aba está selecionada (0 = Visualizar)
  int _abaSelecionada = 0;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      cargo: widget.cargo,
      nome: widget.nome,
      autorId: widget.autorId,
      titulo: "Rotas",
      paginaAtiva: 'rotas_gerente', 
      child: Column(
        children: [
          // 1. CONTEÚDO DA ABA (IndexedStack mantém o estado da tela ao trocar de aba)
          Expanded(
            child: IndexedStack(
              index: _abaSelecionada,
              children: [
                VisualizarRotasTab(),
                CriarRotaTab(),
                EditarRotaTab(),
                FalhasRotaTab(),
              ],
            ),
          ),
          
          // 2. MENU INFERIOR PERSONALIZADO (Rodapé)
          Container(
            padding: const EdgeInsets.only(top: 8, bottom: 16), // Espaçamento inferior
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1), // Linha sutil separando
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBotaoMenu(
                  index: 0,
                  icone: Icons.visibility_outlined,
                  titulo: "Visualizar",
                ),
                _buildBotaoMenu(
                  index: 1,
                  icone: Icons.add_box_outlined,
                  titulo: "Criar",
                ),
                _buildBotaoMenu(
                  index: 2,
                  icone: Icons.edit_outlined,
                  titulo: "Editar",
                ),
                _buildBotaoMenu(
                  index: 3,
                  icone: Icons.error_outline,
                  titulo: "Falhas",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // COMPONENTE: Criador de Botões do Menu
  Widget _buildBotaoMenu({required int index, required IconData icone, required String titulo}) {
    bool isSelecionado = _abaSelecionada == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _abaSelecionada = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          // Fundo azul clarinho se selecionado, transparente se não
          color: isSelecionado ? const Color(0xFFEDF2FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icone,
              // Azul escuro se selecionado, cinza se não
              color: isSelecionado ? const Color(0xFF0F265C) : Colors.grey.shade500,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              titulo,
              style: TextStyle(
                color: isSelecionado ? const Color(0xFF0F265C) : Colors.grey.shade500,
                fontWeight: isSelecionado ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}