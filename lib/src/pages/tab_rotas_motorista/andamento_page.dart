import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'concluir_parada_page.dart';

class AndamentoTab extends StatefulWidget {
  final int autorId;
  final String cargo;
  final String nome;

  const AndamentoTab({
    required this.autorId,
    required this.cargo,
    required this.nome,
  });

  @override
  State<AndamentoTab> createState() => _AndamentoTabState();
}

class _AndamentoTabState extends State<AndamentoTab> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> rotas = [];

  // Cores baseadas no seu design
  final Color _darkBlue = const Color(0xFF0D2556);
  final Color _bgColor = const Color(0xFFF4F7FC);
  final Color _lightBlueCard = const Color(0xFFEDF2FA);
  final Color _yellowButton = const Color(0xFFFFC107);
  final Color _greyText = const Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _carregarRotasEmAndamento();
  }

  // ==========================================
  // CARREGAR ROTAS EM ANDAMENTO
  // ==========================================
  Future<void> _carregarRotasEmAndamento() async {
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
          .eq('status', 'em andamento')
          .not('iniciada_em', 'is', null)
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
  // CONCLUIR ROTA
  // ==========================================
  Future<void> _concluirRota(int rotaId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('Deseja concluir esta rota?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _executarConclusaoRota(rotaId);
            },
            child: const Text('Concluir', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Future<void> _executarConclusaoRota(int rotaId) async {
    try {
      final agora = DateTime.now().toIso8601String();

      await supabase
          .from('rotas')
          .update({
            'finalizada_em': agora,
            'status': 'finalizada',
          })
          .eq('id', rotaId);

      await _carregarRotasEmAndamento();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Rota concluída com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao concluir rota: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhuma rota pendente',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _darkBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Bom trabalho! Você não possui entregas aguardando no momento.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: _bgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: rotas.map((rota) {
            return _buildRotaCompleta(rota);
          }).toList(),
        ),
      ),
    );
  }

  // Constrói o visual completo da rota com os cards extras abaixo
  Widget _buildRotaCompleta(Map<String, dynamic> rota) {
    return Column(
      children: [
        _buildNovoRotaCard(rota),
        const SizedBox(height: 16),
        
        // Cards de Combustível e Pausa Legal
        Row(
          children: [
            Expanded(
              child: _buildInfoCardExtra(
                icon: Icons.local_gas_station_outlined,
                title: 'Combustível',
                value: '82%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCardExtra(
                icon: Icons.access_time,
                title: 'Pausa Legal',
                value: '02:15h',
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),

        // 📍 Paradas (Mantido funcional)
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _buscarParadas(rota['id']),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final paradas = snapshot.data ?? [];
            if (paradas.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, left: 4),
                  child: Text(
                    'Paradas da Rota',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _darkBlue,
                    ),
                  ),
                ),
                ...paradas.map((parada) => _buildParadaCard(parada, rota['id'])).toList(),
              ],
            );
          },
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // O Card Principal com Design Atualizado
  Widget _buildNovoRotaCard(Map<String, dynamic> rota) {
    return Container(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🗺️ MAPA SUPERIOR (Substitua o Container pela imagem real do mapa se tiver)
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  color: Colors.grey[300], // Cor de fundo temporária
                  child: Image.network(
                    'https://static.vecteezy.com/system/resources/previews/000/153/588/original/vector-road-map.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                      const Center(child: Icon(Icons.map, size: 50, color: Colors.white)),
                  ),
                ),
              ),
              // Badge "Em Rota"
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _darkBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Em Rota',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🎯 Título e Ícone Lateral
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rota['descricao'] ?? 'Sem descrição',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: _darkBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FutureBuilder<String>(
                            future: _buscarNomeVeiculo(rota['veiculo_id']),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? 'Carregando...',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _greyText,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _lightBlueCard,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.route, color: _darkBlue),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),

                // 📊 Informações da Rota (Tempo, Distância, Carga)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatColumn("TEMPO EST.", rota['tempo_estimado']?.toString() ?? '-'),
                    _buildStatColumn("DISTÂNCIA", "${rota['total_km']?.toString() ?? '-'} km"),
                    _buildStatColumn("CARGA", "${rota['carga_total']?.toString() ?? '-'} t"),
                  ],
                ),

                const SizedBox(height: 24),

                // 🟡 Botão Concluir Rota
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _yellowButton,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _concluirRota(rota['id']),
                    icon: const Icon(Icons.check_circle_outline, color: Colors.black),
                    label: const Text(
                      'Rota concluída',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget das informações extra (Combustível / Pausa Legal)
  Widget _buildInfoCardExtra({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _lightBlueCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _darkBlue, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(fontSize: 13, color: _greyText),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  // Coluna de status (Ex: TEMPO EST. / drf)
  Widget _buildStatColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _darkBlue,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // PARADA CARD (Lógica mantida, design levemente adaptado)
  // ==========================================
  Widget _buildParadaCard(Map<String, dynamic> parada, int rotaId) {
    bool isConcluida = parada['status'] == 'concluido';
    bool temFalha = parada['status'] == 'falha entrega';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: temFalha
            ? Colors.red[50]
            : isConcluida
                ? Colors.green[50]
                : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: temFalha
                      ? Colors.red[400]
                      : isConcluida
                          ? Colors.green[400]
                          : _darkBlue,
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
                                color: Colors.white,
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _darkBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${parada['rua'] ?? '-'}, ${parada['numero'] ?? '-'}',
                      style: TextStyle(color: _greyText),
                    ),
                    Text(
                      '${parada['bairro'] ?? '-'} - ${parada['cep'] ?? '-'}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    if (temFalha)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '❌ Falha na entrega',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _mostrarDetalhesParada(parada),
                child: const Text('Detalhes', style: TextStyle(color: Colors.blue)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConcluirParadaPage(
                      parada: parada,
                      rotaId: rotaId,
                      motoristaId: widget.autorId,
                      onSalvo: _carregarRotasEmAndamento,
                    ),
                  ),
                ),
                child: const Text('Editar Parada', style: TextStyle(color: Colors.orange)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BOTTOM SHEET COM DETALHES DA PARADA
  // ==========================================
  void _mostrarDetalhesParada(Map<String, dynamic> parada) {
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
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: parada['status'] == 'concluido'
                          ? Colors.green[400]
                          : _darkBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: parada['status'] == 'concluido'
                          ? const Icon(Icons.check, color: Colors.white)
                          : Text(
                              '${parada['ordem']}°',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${parada['cidade'] ?? '-'} - ${parada['uf'] ?? '-'}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _darkBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetalhesRow('Rua:', parada['rua'] ?? '-'),
              _buildDetalhesRow('Número:', parada['numero'] ?? '-'),
              _buildDetalhesRow('Bairro:', parada['bairro'] ?? '-'),
              _buildDetalhesRow('CEP:', parada['cep'] ?? '-'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Informações Adicionais',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _darkBlue),
              ),
              const SizedBox(height: 12),
              _buildDetalhesRow('Empresa:', parada['empresa_loja'] ?? '-'),
              _buildDetalhesRow('Responsável:', parada['responsavel'] ?? '-'),
              _buildDetalhesRow('CPF/CNPJ:', parada['cpf_cnpj'] ?? '-'),
              _buildDetalhesRow('Telefone:', parada['telefone_empresa'] ?? '-'),
              _buildDetalhesRow('Info Carga:', parada['info_carga'] ?? '-'),

              if (parada['status'] == 'concluido') ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Dados de Entrega',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _darkBlue),
                ),
                const SizedBox(height: 12),
                _buildDetalhesRow('Assinado por:', parada['assinou_nome'] ?? '-'),
                _buildDetalhesRow('CPF:', parada['assinou_cpf'] ?? '-'),
              ],
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar', style: TextStyle(color: Colors.white)),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: _greyText),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: TextStyle(color: _darkBlue, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}