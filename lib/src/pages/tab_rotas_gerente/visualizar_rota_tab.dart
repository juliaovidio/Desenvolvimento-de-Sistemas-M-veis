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
          ''')  // ← REMOVER info_carga daqui
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

          // Buscar paradas
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
  // FORMATAR MOEDA
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

  // ==========================================
  // FORMATAR DATA E HORA
  // ==========================================
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
  // INTERFACE
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔽 Filtro por Status
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey[200],
          child: Row(
            children: [
              const Text(
                'Filtrar por:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: _filtroStatus,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'pendente', child: Text('Pendente')),
                    DropdownMenuItem(
                        value: 'em andamento', child: Text('Em andamento')),
                    DropdownMenuItem(
                        value: 'finalizada', child: Text('Finalizado')),
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
            ],
          ),
        ),

        // 📄 Conteúdo
        if (_isLoading)
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (rotas.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'Nenhuma rota ${_filtroStatus}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: rotas.map((rota) {
                  return _buildRotaCard(rota);
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRotaCard(Map<String, dynamic> rota) {
    Color statusColor = _getStatusColor(rota['status']);
    String statusLabel = _getStatusLabel(rota['status']);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🎯 Cabeçalho com Status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    rota['descricao'] ?? '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 👤 Motorista e Veículo
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Motorista: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: rota['nome_motorista'] ?? '-',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Veículo: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text:
                            '${rota['veiculo_descricao'] ?? '-'} = ${rota['veiculo_placa'] ?? '-'}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 💰 Valores e Dados
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Total km:', rota['total_km']?.toString() ?? '-'),
                _buildInfoRow('Carga total:', rota['carga_total']?.toString() ?? '-'),
                _buildInfoRow(
                  'Tempo estimado:',
                  rota['tempo_estimado']?.toString() ?? '-',
                ),
                _buildInfoRow(
                  'Valor a pagar motorista:',
                  _formatarMoeda(rota['valor_pagar_motorista']),
                ),
                _buildInfoRow(
                  'Valor dos gastos:',
                  _formatarMoeda(rota['valor_gasto_caminhao']),
                ),
                _buildInfoRow(
                  'Valor a cobrar entrega:',
                  _formatarMoeda(rota['valor_cobrar_entrega']),
                ),
               
              ],
            ),
          ),

          // 📍 Paradas
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (rota['paradas'] as List).map((parada) {
                return _buildParadaCard(parada);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParadaCard(Map<String, dynamic> parada) {
    bool isConcluida = parada['status'] == 'concluido';
    bool temFalha = parada['status'] == 'falha entrega';

    Color statusColor = temFalha
        ? Colors.red[400]!
        : isConcluida
            ? Colors.green[400]!
            : Colors.yellow[400]!;

    IconData statusIcon = temFalha
        ? Icons.close
        : isConcluida
            ? Icons.check
            : Icons.circle;

    return GestureDetector(
      onTap: () => _mostrarDetalhesParada(parada),
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
            // Número + Informações resumidas
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: temFalha || isConcluida
                        ? Icon(statusIcon, color: Colors.white, size: 18)
                        : Text(
                            '${parada['ordem']}°',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black,
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
                        '${parada['rua'] ?? '-'}, ${parada['numero'] ?? '-'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${parada['bairro'] ?? '-'} - ${parada['cep'] ?? '-'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '${parada['cidade'] ?? '-'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Botão Ver mais
                TextButton(
                  onPressed: () => _mostrarDetalhesParada(parada),
                  child: const Text(
                    'Ver mais +',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📍 Cabeçalho
              Row(
                children: [
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
                                    color: Colors.black,
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
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (temFalha)
                          Text(
                            '❌ Falha na entrega',
                            style: TextStyle(
                              color: Colors.red[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          )
                        else if (isConcluida)
                          Text(
                            '✅ Concluída',
                            style: TextStyle(
                              color: Colors.green[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 📋 Informações da Parada
              _buildDetalhesRow('Rua:', parada['rua'] ?? '-'),
              _buildDetalhesRow('Número:', parada['numero'] ?? '-'),
              _buildDetalhesRow('Bairro:', parada['bairro'] ?? '-'),
              _buildDetalhesRow('CEP:', parada['cep'] ?? '-'),

              const SizedBox(height: 16),
              const Divider(thickness: 2),
              const SizedBox(height: 16),

              const Text(
                'Informações Adicionais',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),

              const SizedBox(height: 10),

              _buildDetalhesRow('Empresa/Loja:', parada['empresa_loja'] ?? '-'),
              _buildDetalhesRow('Responsável:', parada['responsavel'] ?? '-'),
              _buildDetalhesRow('CPF/CNPJ:', parada['cpf_cnpj'] ?? '-'),
              _buildDetalhesRow(
                'Telefone:',
                parada['telefone_empresa'] ?? '-',
              ),
              _buildDetalhesRow(
                'Informação da Carga:',
                parada['info_carga'] ?? '-',
              ),

              // 🖊️ Dados de Entrega (se concluída)
              if (isConcluida) ...[
                const SizedBox(height: 16),
                const Divider(thickness: 2),
                const SizedBox(height: 16),
                const Text(
                  'Dados de Entrega',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 10),
                _buildDetalhesRow(
                  'Assinado por:',
                  parada['assinou_nome'] ?? '-',
                ),
                _buildDetalhesRow(
                  'CPF:',
                  parada['assinou_cpf'] ?? '-',
                ),
              ],

              const SizedBox(height: 20),

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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
          Text(
            valor,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pendente':
        return Colors.orange[300]!;
      case 'em andamento':
        return Colors.blue[300]!;
      case 'finalizada':
        return Colors.green[300]!;
      default:
        return Colors.grey[300]!;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pendente':
        return 'pendente';
      case 'em andamento':
        return 'em andamento';
      case 'finalizada':
        return 'finalizado';
      default:
        return status;
    }
  }
}