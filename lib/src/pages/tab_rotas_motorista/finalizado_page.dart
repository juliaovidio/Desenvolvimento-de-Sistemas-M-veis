import 'package:app_mobile/src/pages/tab_rotas_motorista/detalhes_parada_finalizada_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FinalizadoTab extends StatefulWidget {
  final int autorId;
  final String cargo;
  final String nome;

  const FinalizadoTab({
    required this.autorId,
    required this.cargo,
    required this.nome,
  });

  @override
  State<FinalizadoTab> createState() => _FinalizadoTabState();
}

class _FinalizadoTabState extends State<FinalizadoTab> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> rotas = [];

  @override
  void initState() {
    super.initState();
    _carregarRotasFinalizadas();
  }

  // ==========================================
  // FORMATAR DATA (Ex: 24 OUT 2023)
  // ==========================================
  String _formatarData(String? dataString) {
    if (dataString == null || dataString.isEmpty) return '';
    try {
      DateTime data = DateTime.parse(dataString);
      List<String> meses = [
        'JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN',
        'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'
      ];
      return '${data.day.toString().padLeft(2, '0')} ${meses[data.month - 1]} ${data.year}';
    } catch (e) {
      return dataString.substring(0, 10);
    }
  }

  // ==========================================
  // CARREGAR ROTAS FINALIZADAS
  // ==========================================
  Future<void> _carregarRotasFinalizadas() async {
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
          .eq('status', 'finalizada')
          .not('finalizada_em', 'is', null)
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
  // INTERFACE PRINCIPAL
  // ==========================================
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: const Color(0xFFF4F6F8), // Fundo cinza bem claro do app
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildSearchBar(),
            ),
          ),
          if (rotas.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'Nenhuma rota finalizada',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildRotaCard(rotas[index]),
                  childCount: rotas.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // BARRA DE PESQUISA (TOPO)
  // ==========================================
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por placa ou rota...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black87),
            onPressed: () {
              // Ação do filtro
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // CARD PRINCIPAL DA ROTA
  // ==========================================
  Widget _buildRotaCard(Map<String, dynamic> rota) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎯 Título da Rota e Badge Finalizado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    rota['descricao'] ?? 'Sem descrição',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Finalizado',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 📅 Data finalizada
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  _formatarData(rota['finalizada_em']),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 📊 Informações da Rota (3 Colunas)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(color: Colors.grey.shade100, width: 1.5),
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildEstatisticaColuna(
                      Icons.access_time_outlined,
                      "Tempo",
                      rota['tempo_estimado']?.toString() ?? '-',
                    ),
                    VerticalDivider(color: Colors.grey.shade200, thickness: 1),
                    _buildEstatisticaColuna(
                      Icons.route_outlined,
                      "Distância",
                      rota['total_km']?.toString() ?? '-',
                    ),
                    VerticalDivider(color: Colors.grey.shade200, thickness: 1),
                    _buildEstatisticaColuna(
                      Icons.shopping_bag_outlined,
                      "Carga",
                      rota['carga_total']?.toString() ?? '-',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 📍 Lista de Paradas
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _buscarParadas(rota['id']),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ));
                }

                final paradas = snapshot.data ?? [];

                return Column(
                  children: paradas.map((parada) {
                    return _buildParadaItem(parada);
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 8),

            // 🔽 Botão Ver Mais
            Center(
              child: TextButton(
                onPressed: () => _mostrarDetalhesRota(rota),
                child: Text(
                  'Ver mais +',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Auxiliar para as 3 colunas de info
  Widget _buildEstatisticaColuna(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 24),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }

  // ==========================================
  // ITEM DA PARADA (SUCESSO / FALHA)
  // ==========================================
  Widget _buildParadaItem(Map<String, dynamic> parada) {
    bool temFalha = parada['status'] == 'falha entrega';
    bool isConcluida = parada['status'] == 'concluido' || !temFalha; // Assume sucesso se não for falha para o visual da foto

    // Cores baseadas no status
    Color bgColor = temFalha ? const Color(0xFFFFF4F4) : const Color(0xFFF2FDF5);
    Color borderColor = temFalha ? const Color(0xFFFFEAEA) : const Color(0xFFE8F8EE);
    Color iconBgColor = temFalha ? const Color(0xFFFFE0E0) : const Color(0xFFDDF5E6);
    Color iconColor = temFalha ? const Color(0xFFE53935) : const Color(0xFF43A047);
    IconData iconData = temFalha ? Icons.close : Icons.check;
    String statusTexto = temFalha ? 'Falha na entrega' : 'Concluída';

    // Montar um titulo provisorio baseado na cidade/rua pra ficar parecido com o "ghy - jj" da foto
    String titulo = '${parada['cidade'] ?? 'Parada'} - ${parada['uf'] ?? parada['ordem']}';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetalheParadaFinalizadoPage(parada: parada),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Ícone circular (X vermelho ou Check verde)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 18),
            ),
            const SizedBox(width: 16),
            
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusTexto,
                    style: TextStyle(
                      fontSize: 13,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
            ),

            // Seta para direita
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // BOTTOM SHEET COM DETALHES DA ROTA
  // ==========================================
  void _mostrarDetalhesRota(Map<String, dynamic> rota) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                rota['descricao'] ?? '-',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              _buildDetalhesRow('Tempo estimado:', rota['tempo_estimado']?.toString() ?? '-'),
              _buildDetalhesRow('Total km:', rota['total_km']?.toString() ?? '-'),
              _buildDetalhesRow('Carga total:', rota['carga_total']?.toString() ?? '-'),
              _buildDetalhesRow('Status:', rota['status'] ?? '-'),
              const SizedBox(height: 16),
              const Divider(thickness: 1),
              const SizedBox(height: 16),
              _buildDetalhesRow('Criada em:', _formatarData(rota['criada_em'])),
              _buildDetalhesRow('Iniciada em:', _formatarData(rota['iniciada_em'])),
              _buildDetalhesRow('Finalizada em:', _formatarData(rota['finalizada_em'])),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetalhesRow(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}