import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'detalhes_parada_finalizado_page.dart';

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
  // INTERFACE
  // ==========================================
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (rotas.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma rota finalizada',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: rotas.map((rota) {
          return _buildRotaCard(rota);
        }).toList(),
      ),
    );
  }

  Widget _buildRotaCard(Map<String, dynamic> rota) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎯 Título da Rota
            Text(
              rota['descricao'] ?? 'Sem descrição',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // 🚗 Nome do Veículo
            FutureBuilder<String>(
              future: _buscarNomeVeiculo(rota['veiculo_id']),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? 'Carregando...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // 📊 Informações da Rota
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    "Tempo estimado:",
                    rota['tempo_estimado']?.toString() ?? '-',
                  ),
                  _buildInfoRow(
                    "Total km:",
                    rota['total_km']?.toString() ?? '-',
                  ),
                  _buildInfoRow(
                    "Carga total:",
                    rota['carga_total']?.toString() ?? '-',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🛑 Separador
            const Divider(thickness: 1),
            const SizedBox(height: 12),

            // 📍 Paradas
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _buscarParadas(rota['id']),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final paradas = snapshot.data ?? [];

                return Column(
                  children: paradas.map((parada) {
                    return _buildParadaCard(parada);
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 12),

            // 🔽 Botão Ver Mais
            Center(
              child: TextButton(
                onPressed: () => _mostrarDetalhesRota(rota),
                child: const Text(
                  'Ver mais +',
                  style: TextStyle(color: Color(0xFF00214B)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParadaCard(Map<String, dynamic> parada) {
    bool isConcluida = parada['status'] == 'concluido';
    bool temFalha = parada['status'] == 'falha entrega';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetalheParadaFinalizadoPage(
            parada: parada,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: temFalha
                ? Colors.red[300]!
                : isConcluida
                    ? Colors.green[300]!
                    : Colors.grey[300]!,
            width: temFalha || isConcluida ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: temFalha
              ? Colors.red[50]
              : isConcluida
                  ? Colors.green[50]
                  : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📍 Número da Parada + Cidade + Rua
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Número em destaque
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: temFalha
                        ? Colors.red[400]
                        : isConcluida
                            ? Colors.green[400]
                            : Colors.yellow[400],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: temFalha
                        ? const Icon(Icons.close, color: Colors.white)
                        : isConcluida
                            ? const Icon(Icons.check, color: Colors.white)
                            : Text(
                                '${parada['ordem']}°',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${parada['rua'] ?? '-'}, ${parada['numero'] ?? '-'}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Text(
                        '${parada['bairro'] ?? '-'} - ${parada['cep'] ?? '-'}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                      // Status
                      if (temFalha)
                        Text(
                          '❌ Falha na entrega',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      if (isConcluida)
                        Text(
                          '✅ Concluída',
                          style: TextStyle(
                            color: Colors.green[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Separador
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                height: 1,
                color: Colors.grey[300],
              ),
            ),
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📍 Título
              Text(
                rota['descricao'] ?? '-',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // 📋 Informações
              _buildDetalhesRow('Tempo estimado:', rota['tempo_estimado']?.toString() ?? '-'),
              _buildDetalhesRow('Total km:', rota['total_km']?.toString() ?? '-'),
              _buildDetalhesRow('Carga total:', rota['carga_total']?.toString() ?? '-'),
              _buildDetalhesRow('Status:', rota['status'] ?? '-'),

              const SizedBox(height: 16),
              const Divider(thickness: 2),
              const SizedBox(height: 16),

              // 📅 Datas
              _buildDetalhesRow(
                'Criada em:',
                rota['criada_em']?.substring(0, 10) ?? '-',
              ),
              _buildDetalhesRow(
                'Iniciada em:',
                rota['iniciada_em']?.substring(0, 10) ?? '-',
              ),
              _buildDetalhesRow(
                'Finalizada em:',
                rota['finalizada_em']?.substring(0, 10) ?? '-',
              ),

              const SizedBox(height: 20),

              // ✅ Botão Fechar
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(valor),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(valor),
        ],
      ),
    );
  }
}