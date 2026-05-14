import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PendingTab extends StatefulWidget {
  final int autorId;
  final String cargo;
  final String nome;

  const PendingTab({
    super.key,
    required this.autorId,
    required this.cargo,
    required this.nome,
  });

  @override
  State<PendingTab> createState() => _PendingTabState();
}

class _PendingTabState extends State<PendingTab> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> rotas = [];

  @override
  void initState() {
    super.initState();
    _carregarRotasPendentes();
  }

  // ==========================================
  // CARREGAR ROTAS PENDENTES DO MOTORISTA
  // ==========================================
  Future<void> _carregarRotasPendentes() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('rotas')
          .select('''
            id,
            descricao,
            motorista_id,
            veiculo_id,
            tempo_estimado,
            total_km,
            carga_total,
            criada_em,
            iniciada_em,
            finalizada_em,
            status
          ''')
          .eq('motorista_id', widget.autorId)
          .eq('status', 'a realizar')
          .isFilter('iniciada_em', null)
          .isFilter('finalizada_em', null)
          .order('criada_em', ascending: false);

      setState(() {
        rotas = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar rotas: $e');
      setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // BUSCAR NOME DO VEÍCULO
  // ==========================================
  Future<String> _buscarNomeVeiculo(int veiculoId) async {
    try {
      final response = await supabase
          .from('veiculos')
          .select('descricao')
          .eq('id', veiculoId)
          .single();
      return response['descricao'] ?? 'Veículo desconhecido';
    } catch (e) {
      return 'Veículo desconhecido';
    }
  }

  // ==========================================
  // BUSCAR PARADAS DE UMA ROTA
  // ==========================================
  Future<List<Map<String, dynamic>>> _buscarParadas(int rotaId) async {
    try {
      final response = await supabase
          .from('paradas')
          .select()
          .eq('rota_id', rotaId)
          .order('ordem', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao carregar paradas: $e');
      return [];
    }
  }

  // ==========================================
  // INICIAR ROTA
  // ==========================================
  Future<void> _iniciarRota(int rotaId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar Início', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0))),
        content: const Text('Deseja realmente iniciar esta rota de entregas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00214B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _executarInicioRota(rotaId);
            },
            child: const Text('Iniciar Rota', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _executarInicioRota(int rotaId) async {
    try {
      final agora = DateTime.now().toIso8601String();

      await supabase
          .from('rotas')
          .update({
            'iniciada_em': agora,
            'status': 'em andamento',
          })
          .eq('id', rotaId);

      await supabase
          .from('paradas')
          .update({'status': 'em andamento'})
          .eq('rota_id', rotaId);

      await _carregarRotasPendentes();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Rota iniciada com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao iniciar rota: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==========================================
  // INTERFACE PRINCIPAL
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: _buildAbaPendente(),
      ),
    );
  }

  // ==========================================
  // ABA PENDENTE (CONTEÚDO PRINCIPAL)
  // ==========================================
  Widget _buildAbaPendente() {
    return Column(
      children: [
        // 🔍 BARRA DE FILTRO
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          color: Colors.white,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Filtrar rotas...',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
              prefixIcon: const Icon(Icons.filter_list, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF3F6F8),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF00214B)),
              ),
            ),
          ),
        ),
        
        const Divider(height: 1, color: Color(0xFFE5E7EB)),

        // 📦 ÁREA DE LISTAGEM COM PULL-TO-REFRESH
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00214B)))
              : rotas.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _carregarRotasPendentes,
                      color: const Color(0xFF00214B),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: rotas.length,
                        itemBuilder: (context, index) {
                          return _buildRotaCard(rotas[index]);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  // ==========================================
  // ESTADO VAZIO LIMPO (SIMPLIFICADO)
  // ==========================================
  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _carregarRotasPendentes,
      color: const Color(0xFF00214B),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Permite puxar para baixo mesmo vazio
        child: Container(
          height: MediaQuery.of(context).size.height * 0.5,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Nenhuma rota pendente',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0B132B)),
              ),
              const SizedBox(height: 8),
              Text(
                'Deslize para baixo para atualizar',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // CARD DE ROTA PRINCIPAL
  // ==========================================
  Widget _buildRotaCard(Map<String, dynamic> rota) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SOLUÇÃO: O Expanded garante que a descrição só cresça até onde a tela permite.
                  Expanded(
                    child: Text(
                      rota['descricao'] ?? 'Sem descrição',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00214B),
                      ),
                      // SOLUÇÃO EXTRA: Adicionamos um maxLines para o texto não ficar infinito se for grande.
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8), // Pequeno respiro entre o texto e a tag "A realizar"
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'A realizar',
                      style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FutureBuilder<String>(
                future: _buscarNomeVeiculo(rota['veiculo_id']),
                builder: (context, snapshot) {
                  return Row(
                    children: [
                      Icon(Icons.local_shipping_outlined, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      // SOLUÇÃO: Envolver o nome do veículo num Expanded também, caso seja um nome comprido
                      Expanded(
                        child: Text(
                          snapshot.data ?? 'Carregando veículo...',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7FB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // SOLUÇÃO: Para esses 3 blocos não estourarem no celular menor, colocamos eles como 'Flexible' dentro do método '_buildInfoColumn' ou garantimos que tenham espaço de manobra. 
                    Expanded(child: _buildInfoColumn(Icons.timer_outlined, "Tempo", rota['tempo_estimado']?.toString() ?? '-')),
                    Container(width: 1, height: 30, color: Colors.grey[300]),
                    Expanded(child: _buildInfoColumn(Icons.route_outlined, "Dist.", "${rota['total_km']?.toString() ?? '-'} km")), // "Distância" abreviado para caber melhor
                    Container(width: 1, height: 30, color: Colors.grey[300]),
                    Expanded(child: _buildInfoColumn(Icons.inventory_2_outlined, "Carga", rota['carga_total']?.toString() ?? '-')),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              "Lista de Paradas",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00214B)),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _buscarParadas(rota['id']),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                final paradas = snapshot.data ?? [];
                if (paradas.isEmpty) {
                  return const Text("Nenhuma parada cadastrada.", style: TextStyle(color: Colors.grey));
                }
                return Column(
                  children: paradas.map((parada) => _buildParadaCard(parada)).toList(),
                );
              },
            ),
      const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00214B),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _iniciarRota(rota['id']),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: Color.fromARGB(255, 255, 255, 255), size: 24),
                    SizedBox(width: 8),
                    // SOLUÇÃO: Colocamos o Flexible e o overflow aqui no texto do botão!
                    Flexible(
                      child: Text(
                        'Iniciar Rota de Entregas',
                        style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF3730A3), size: 20),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildParadaCard(Map<String, dynamic> parada) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 232, 232, 232),
              border: Border.all(color: const Color(0xFF00214B)),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${parada['ordem']}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF00214B)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${parada['cidade'] ?? '-'} - ${parada['uf'] ?? '-'}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${parada['rua'] ?? '-'}, ${parada['numero'] ?? '-'}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${parada['bairro'] ?? '-'}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF3730A3)),
            onPressed: () => _mostrarDetalhesParada(parada),
            tooltip: "Ver detalhes",
          ),
        ],
      ),
    );
  }

  void _mostrarDetalhesParada(Map<String, dynamic> parada) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Parada ${parada['ordem']}°",
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00214B)),
                              ),
                              const Text(
                                "Detalhes da Entrega",
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.pending_actions, color: Color(0xFFD97706), size: 16),
                              SizedBox(width: 4),
                              Text(
                                "Pendente",
                                style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
              
                    const SizedBox(height: 24),
                    const Text(
                      "Informações do Destino",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00214B)),
                    ),
                    const SizedBox(height: 16),
                    _buildDesignRow(Icons.business, "Empresa/Loja", parada['empresa_loja'] ?? 'Não informado'),
                    _buildDesignRow(Icons.person_outline, "Responsável", parada['responsavel'] ?? 'Não informado'),
                    _buildDesignRow(Icons.location_on_outlined, "Endereço Completo",
                        "${parada['rua'] ?? '-'}, ${parada['numero'] ?? '-'}\n${parada['bairro'] ?? '-'} - ${parada['cidade'] ?? '-'}/${parada['uf'] ?? '-'}\nCEP: ${parada['cep'] ?? '-'}"),
                    _buildDesignRow(Icons.phone_outlined, "Telefone", parada['telefone_empresa'] ?? 'Não informado'),
                    _buildDesignRow(Icons.badge_outlined, "CPF/CNPJ", parada['cpf_cnpj'] ?? 'Não informado'),
                    _buildDesignRow(Icons.inventory_2_outlined, "Informação da Carga", parada['info_carga'] ?? 'Sem informações adicionais'),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00214B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Fechar Detalhes",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesignRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF3730A3), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}