import 'package:app_mobile/src/pages/tab_rotas_motorista/finalizado_page.dart';
import 'package:app_mobile/src/pages/tab_rotas_motorista/pendente_page.dart';
import 'package:app_mobile/src/pages/tab_rotas_motorista/vizualizar_falhas_page.dart';
import 'package:flutter/material.dart';
import '../layout/main_layout.dart';
import 'package:app_mobile/src/pages/tab_rotas_motorista/andamento_page.dart';

class RotasMotoristaPage extends StatefulWidget {
  final String cargo;
  final String nome;
  final int autorId;

  const RotasMotoristaPage({
    required this.cargo,
    required this.nome,
    required this.autorId,
  });

  @override
  State<RotasMotoristaPage> createState() => _RotasMotoristaPageState();
}

class _RotasMotoristaPageState extends State<RotasMotoristaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var pendingTab = PendingTab;
    return MainLayout(
      cargo: widget.cargo,
      nome: widget.nome,
      autorId: widget.autorId,
      titulo: "Minhas Rotas",
      child: Column(
        children: [
          // 🟡 TabBar com as 4 abas
          Container(
            color: Colors.grey[200],
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.yellow[700],
              indicatorWeight: 3,
              tabs: const [
                Tab(text: "Pendente"),
                Tab(text: "Andamento"),
                Tab(text: "Finalizado"),
                Tab(text: "Falhas"),
              ],
            ),
          ),
          // 📄 TabBarView com o conteúdo de cada aba
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1️⃣ Aba Pendente
                PendingTab(
                  autorId: widget.autorId,
                  cargo: widget.cargo,
                  nome: widget.nome,
                ),
                // 2️⃣ Aba Andamento (vazio por enquanto)
                AndamentoTab(
                  autorId: widget.autorId,
                  cargo: widget.cargo,
                  nome: widget.nome,
                ),
                // 3️⃣ Aba Finalizado (vazio por enquanto)
                FinalizadoTab(
                  autorId: widget.autorId,
                  cargo: widget.cargo,
                  nome: widget.nome,
                ),
                // 4️⃣ Aba Falhas (vazio por enquanto)
                VisualizarFalhasPage(
                  autorId: widget.autorId,
                  cargo: widget.cargo,
                  nome: widget.nome,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}