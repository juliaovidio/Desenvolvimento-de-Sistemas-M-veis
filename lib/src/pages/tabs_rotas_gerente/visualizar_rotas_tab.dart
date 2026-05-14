import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class VisualizarRotasTab extends StatefulWidget {
  const VisualizarRotasTab({Key? key}) : super(key: key);

  @override
  State<VisualizarRotasTab> createState() => _VisualizarRotasTabState();
}

class _VisualizarRotasTabState extends State<VisualizarRotasTab> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> rotas = [];
  String _filtroStatus = 'em andamento'; // Filtro padrão

  @override
  void initState() {
    super.initState();
    _carregarTodasAsRotas();
  }

  // ==========================================
  // CARREGAR TODAS AS ROTAS (COM FILTRO)
  // ==========================================
  Future<void> _carregarTodasAsRotas() async {
    setState(() => _isLoading = true);
    try {
      // Buscar rotas com o status filtrado
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
            valor_pagar_motorista,
            valor_gasto_caminhao,
            valor_cobrar_entrega,
            criada_em,
            iniciada_em,
            finalizada_em,
            status
          ''')
          .eq('status', _filtroStatus)
          .order('criada_em', ascending: false);
          
      // Para cada rota, buscar dados do motorista, veículo e paradas
      List<Map<String, dynamic>> rotasComDados = [];

      for (var rota in response) {
        try {
          // Buscar motorista
          final motorista = await supabase
              .from('funcionarios')
              .select('nome')
              .eq('id', rota['motorista_id'])
              .single();

          // Buscar veículo
          final veiculo = await supabase
              .from('veiculos')
              .select('descricao, placa')
              .eq('id', rota['veiculo_id'])
              .single();

          // Buscar paradas (A query vazia no select traz todas as colunas, incluindo foto_entrega_url)
          final paradas = await supabase
              .from('paradas')
              .select()
              .eq('rota_id', rota['id'])
              .order('ordem', ascending: true);

          rotasComDados.add({
            'id': rota['id'],
            'descricao': rota['descricao'],
            'nome_motorista': motorista['nome'],
            'veiculo_descricao': veiculo['descricao'],
            'veiculo_placa': veiculo['placa'],
            'tempo_estimado': rota['tempo_estimado'],
            'total_km': rota['total_km'],
            'carga_total': rota['carga_total'],
            'valor_pagar_motorista': rota['valor_pagar_motorista'],
            'valor_gasto_caminhao': rota['valor_gasto_caminhao'],
            'valor_cobrar_entrega': rota['valor_cobrar_entrega'],
            'criada_em': rota['criada_em'],
            'iniciada_em': rota['iniciada_em'],
            'finalizada_em': rota['finalizada_em'],
            'status': rota['status'],
            'info_carga': rota['info_carga'],
            'paradas': paradas,
          });
        } catch (e) {
          print('Erro ao processar rota ${rota['id']}: $e');
          continue;
        }
      }

      setState(() {
        rotas = rotasComDados;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar rotas: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar rotas: $e')),
      );
    }
  }

  // ==========================================
  // DELETAR ROTA
  // ==========================================
  Future<void> _deletarRota(int rotaId) async {
    setState(() => _isLoading = true);
    try {
      await supabase.from('paradas').delete().eq('rota_id', rotaId);
      await supabase.from('rotas').delete().eq('id', rotaId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rota deletada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      _carregarTodasAsRotas();
    } catch (e) {
      print('Erro ao deletar rota: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao deletar rota: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmarExclusao(BuildContext context, int rotaId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Deletar Rota'),
          ],
        ),
        content: const Text('Deseja realmente deletar esta rota? Esta ação não pode ser desfeita.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _deletarRota(rotaId);
            },
            child: const Text('Deletar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FORMATAR MOEDA E DATA
  // ==========================================
  String _formatarMoeda(dynamic valor) {
    if (valor == null) return '-';
    try {
      final num = double.parse(valor.toString());
      return 'R\$${num.toStringAsFixed(2)}';
    } catch (e) {
      return '-';
    }
  }

  String _formatarDataHora(String? dataIso) {
    if (dataIso == null) return '-';
    try {
      final data = DateTime.parse(dataIso);
      return DateFormat('dd/MM/yyyy - HH:mm').format(data);
    } catch (e) {
      return dataIso;
    }
  }

  // ==========================================
  // EXPANDIR FOTO (NOVA FUNÇÃO)
  // ==========================================
  void _expandirFoto(String? fotoUrl) {
    if (fotoUrl == null || fotoUrl.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              fotoUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: const Text('Erro ao carregar imagem', style: TextStyle(color: Colors.black)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // INTERFACE PRINCIPAL
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔽 Filtro por Status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.filter_list, color: Colors.grey),
              const SizedBox(width: 8),
              const Text(
                'Status da Rota:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filtroStatus,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00214B)),
                      items: const [
                        DropdownMenuItem(value: 'pendente', child: Text('Pendente')),
                        DropdownMenuItem(value: 'em andamento', child: Text('Em andamento')),
                        DropdownMenuItem(value: 'finalizada', child: Text('Finalizado')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _filtroStatus = value;
                          });
                          _carregarTodasAsRotas();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 📄 Conteúdo
        if (_isLoading)
          const Expanded(
            child: Center(child: CircularProgressIndicator(color: Color(0xFF00214B))),
          )
        else if (rotas.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.route_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma rota $_filtroStatus',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: _carregarTodasAsRotas,
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
  // CARD DE ROTA
  // ==========================================
  Widget _buildRotaCard(Map<String, dynamic> rota) {
    Color statusColor = _getStatusColor(rota['status']);
    String statusLabel = _getStatusLabel(rota['status']).toUpperCase();

    bool podeDeletar = rota['status'] == 'pendente' || rota['status'] == 'finalizada';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎯 Cabeçalho da Rota com Status e Botão Deletar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                border: Border(
                  left: BorderSide(color: statusColor, width: 4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rota['descricao'] ?? 'Rota sem descrição',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Criada em: ${_formatarDataHora(rota['criada_em'])}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  
                  if (podeDeletar) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _confirmarExclusao(context, rota['id']),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      ),
                    ),
                  ]
                ],
              ),
            ),

            // 👤 Info Motorista e Veículo
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue[50],
                          radius: 18,
                          child: const Icon(Icons.person, size: 20, color: Colors.blue),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Motorista', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              Text(
                                rota['nome_motorista'] ?? '-',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 30, color: Colors.grey[300]),
                  Expanded(
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        CircleAvatar(
                          backgroundColor: Colors.orange[50],
                          radius: 18,
                          child: const Icon(Icons.local_shipping, size: 20, color: Colors.orange),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Veículo', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              Text(
                                '${rota['veiculo_placa'] ?? '-'}',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1),

            // 💰 Resumo Logístico e Financeiro
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniInfo(Icons.map, 'Distância', '${rota['total_km'] ?? '-'} km'),
                      _buildMiniInfo(Icons.timer, 'Tempo Est.', rota['tempo_estimado'] ?? '-'),
                      _buildMiniInfo(Icons.scale, 'Carga', '${rota['carga_total'] ?? '-'} kg'),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 12),

                  _buildCampoFinanceiro('Pagamento do Motorista:', _formatarMoeda(rota['valor_pagar_motorista'])),
                  _buildCampoFinanceiro('Gastos do Caminhão:', _formatarMoeda(rota['valor_gasto_caminhao'])),
                  _buildCampoFinanceiro('Cobrar na Entrega:', _formatarMoeda(rota['valor_cobrar_entrega'])),
                ],
              ),
            ),

            // 📍 Seção de Paradas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 18, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(
                        'Roteiro de Paradas (${(rota['paradas'] as List).length})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...(rota['paradas'] as List).map((parada) => _buildParadaCard(parada)).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // COMPONENTES AUXILIARES DO CARD
  // ==========================================
  Widget _buildMiniInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCampoFinanceiro(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.monetization_on_outlined, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
          const SizedBox(width: 6),
          Text(
            valor,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildParadaCard(Map<String, dynamic> parada) {
    bool isConcluida = parada['status'] == 'concluido';
    bool temFalha = parada['status'] == 'falha entrega';

    Color statusColor = temFalha
        ? Colors.red
        : isConcluida
            ? Colors.green
            : Colors.orange;

    IconData statusIcon = temFalha
        ? Icons.close
        : isConcluida
            ? Icons.check
            : Icons.access_time_filled;

    return GestureDetector(
      onTap: () => _mostrarDetalhesParada(parada),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: temFalha
              ? Colors.red[50]
              : isConcluida
                  ? Colors.green[50]
                  : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: temFalha
                ? Colors.red[200]!
                : isConcluida
                    ? Colors.green[200]!
                    : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: statusColor.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
                ],
              ),
              child: Center(
                child: Icon(statusIcon, color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${parada['ordem']}º - ${parada['rua'] ?? ''}, ${parada['numero'] ?? ''}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${parada['bairro'] ?? ''} • ${parada['cidade'] ?? ''}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // BOTTOM SHEET COM DETALHES DA PARADA
  // ==========================================
  void _mostrarDetalhesParada(Map<String, dynamic> parada) {
    bool isConcluida = parada['status'] == 'concluido';
    bool temFalha = parada['status'] == 'falha entrega';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: temFalha
                          ? Colors.red
                          : isConcluida
                              ? Colors.green
                              : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: temFalha
                          ? const Icon(Icons.close, color: Colors.white)
                          : isConcluida
                              ? const Icon(Icons.check, color: Colors.white)
                              : Text(
                                  '${parada['ordem']}º',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                                ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${parada['cidade'] ?? '-'} - ${parada['uf'] ?? '-'}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (temFalha)
                          Text('Falha na entrega', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold))
                        else if (isConcluida)
                          Text('Entrega Concluída', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold))
                        else
                          Text('Pendente', style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              _buildSectionTitle('Endereço'),
              _buildDetalhesRow('Rua:', parada['rua'] ?? '-'),
              _buildDetalhesRow('Número:', parada['numero'] ?? '-'),
              _buildDetalhesRow('Bairro:', parada['bairro'] ?? '-'),
              _buildDetalhesRow('CEP:', parada['cep'] ?? '-'),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              _buildSectionTitle('Informações Adicionais'),
              _buildDetalhesRow('Empresa/Loja:', parada['empresa_loja'] ?? '-'),
              _buildDetalhesRow('Responsável:', parada['responsavel'] ?? '-'),
              _buildDetalhesRow('CPF/CNPJ:', parada['cpf_cnpj'] ?? '-'),
              _buildDetalhesRow('Telefone:', parada['telefone_empresa'] ?? '-'),
              _buildDetalhesRow('Info Carga:', parada['info_carga'] ?? '-'),

              // 📷 DADOS DA CONCLUSAO E FOTO
              if (isConcluida) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildSectionTitle('Dados de Recebimento'),
                _buildDetalhesRow('Assinado por:', parada['assinou_nome'] ?? '-'),
                _buildDetalhesRow('CPF:', parada['assinou_cpf'] ?? '-'),
                
                const SizedBox(height: 16),
                const Text(
                  'Evidência Visual',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),

                // Lógica que exibe a foto do BD (foto_entrega_url) e permite expandir
                if (parada['foto_entrega_url'] != null && parada['foto_entrega_url'].toString().isNotEmpty)
                  GestureDetector(
                    onTap: () => _expandirFoto(parada['foto_entrega_url']),
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          parada['foto_entrega_url'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.image_not_supported, color: Colors.grey[400], size: 40),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined, color: Colors.grey[400], size: 30),
                        const SizedBox(height: 8),
                        Text('Sem foto registrada', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('FECHAR', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
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
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700], fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(valor, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CORES E LABELS DE STATUS
  // ==========================================
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return Colors.orange;
      case 'em andamento':
        return Colors.blue;
      case 'finalizada':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return 'Pendente';
      case 'em andamento':
        return 'Em Andamento';
      case 'finalizada':
        return 'Finalizado';
      default:
        return status;
    }
  }
}