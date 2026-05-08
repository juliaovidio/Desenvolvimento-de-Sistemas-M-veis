import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class FalhasRotaTab extends StatefulWidget {
  const FalhasRotaTab({Key? key}) : super(key: key);

  @override
  State<FalhasRotaTab> createState() => _FalhasRotaTabState();
}

class _FalhasRotaTabState extends State<FalhasRotaTab> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> falhas = [];

  @override
  void initState() {
    super.initState();
    _carregarTodasAsFalhas();
  }

  // ==========================================
  // CARREGAR TODAS AS FALHAS (TODOS OS MOTORISTAS)
  // ==========================================
  Future<void> _carregarTodasAsFalhas() async {
    setState(() => _isLoading = true);
    try {
      // 1️⃣ Buscar todas as paradas com status 'falha entrega'
      final paradasComFalha = await supabase
          .from('paradas')
          .select('id, rota_id')
          .eq('status', 'falha entrega');

      List<int> paradasIds =
          (paradasComFalha as List).map((p) => p['id'] as int).toList();

      if (paradasIds.isEmpty) {
        setState(() {
          falhas = [];
          _isLoading = false;
        });
        return;
      }

      // 2️⃣ Buscar falhas relacionadas a essas paradas
      final falhasData = await supabase
          .from('falhas_entrega')
          .select(
              'id, parada_id, motorista_id, descricao, foto_url, criado_em')
          .inFilter('parada_id', paradasIds)
          .order('criado_em', ascending: false);

      // 3️⃣ Para cada falha, trazer dados da parada, rota e motorista
      List<Map<String, dynamic>> falhasComDados = [];

      for (var falha in falhasData) {
        try {
          // Buscar parada
          final parada = await supabase
              .from('paradas')
              .select(
                  'id, rota_id, ordem, cidade, uf, rua, numero, bairro, cep, empresa_loja, responsavel, cpf_cnpj, telefone_empresa, info_carga')
              .eq('id', falha['parada_id'])
              .single();

          // Buscar rota
          final rota = await supabase
              .from('rotas')
              .select('id, descricao, veiculo_id')
              .eq('id', parada['rota_id'])
              .single();

          // Buscar veículo
          final veiculo = await supabase
              .from('veiculos')
              .select('descricao, placa')
              .eq('id', rota['veiculo_id'])
              .single();

          // Buscar funcionário (motorista)
          final funcionario = await supabase
              .from('funcionarios')
              .select('nome')
              .eq('id', falha['motorista_id'])
              .single();

          falhasComDados.add({
            'id': falha['id'],
            'descricao_falha': falha['descricao'],
            'foto_url': falha['foto_url'],
            'criado_em': falha['criado_em'],
            'descricao_rota': rota['descricao'],
            'nome_motorista': funcionario['nome'],
            'veiculo_descricao': veiculo['descricao'],
            'veiculo_placa': veiculo['placa'],
            'ordem_parada': parada['ordem'],
            'cidade': parada['cidade'],
            'uf': parada['uf'],
            'rua': parada['rua'],
            'numero': parada['numero'],
            'bairro': parada['bairro'],
            'cep': parada['cep'],
            'empresa_loja': parada['empresa_loja'],
            'responsavel': parada['responsavel'],
            'cpf_cnpj': parada['cpf_cnpj'],
            'telefone_empresa': parada['telefone_empresa'],
            'info_carga': parada['info_carga'],
          });
        } catch (e) {
          print('Erro ao processar falha ${falha['id']}: $e');
          continue;
        }
      }

      setState(() {
        falhas = falhasComDados;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar falhas: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar falhas: $e')),
      );
    }
  }

  // ==========================================
  // FORMATAR DATA
  // ==========================================
  String _formatarData(String dataIso) {
    try {
      final data = DateTime.parse(dataIso);
      return DateFormat('dd/MM/yyyy HH:mm').format(data);
    } catch (e) {
      return dataIso;
    }
  }

  // ==========================================
  // EXPANDIR FOTO
  // ==========================================
  void _expandirFoto(String? fotoUrl) {
    if (fotoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sem foto disponível')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Image.network(
            fotoUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text('Erro ao carregar imagem'),
              );
            },
          ),
        ),
      ),
    );
  }

  // ==========================================
  // INTERFACE
  // ==========================================
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (falhas.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma falha registrada',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: falhas.map((falha) {
          return _buildFalhaCard(falha);
        }).toList(),
      ),
    );
  }

  Widget _buildFalhaCard(Map<String, dynamic> falha) {
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
          // 🎯 Cabeçalho com Rota
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
              children: [
                // 🔢 Número da parada em destaque
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${falha['ordem_parada']}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Descrição da rota
                Expanded(
                  child: Text(
                    falha['descricao_rota'] ?? '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // 👤 Dados do Motorista
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Motorista
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
                        text: falha['nome_motorista'] ?? '-',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // Veículo
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
                            '${falha['veiculo_descricao'] ?? '-'} = ${falha['veiculo_placa'] ?? '-'}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Descrição do problema
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Descrição do problema: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: falha['descricao_falha'] ?? '-',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 📍 Parada e Dados da Entrega
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
                // Número da parada
                Text(
                  'Parada ${falha['ordem_parada']}°:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),

                // Endereço
                _buildParadaRow(
                  'Empresa/loja:',
                  falha['empresa_loja'] ?? '-',
                ),
                _buildParadaRow(
                  'Responsável:',
                  falha['responsavel'] ?? '-',
                ),
                _buildParadaRow(
                  'CNPJ/CPF:',
                  falha['cpf_cnpj'] ?? '-',
                ),
                _buildParadaRow(
                  'Informações da carga:',
                  falha['info_carga'] ?? '-',
                ),
                _buildParadaRow(
                  'Bairro:',
                  falha['bairro'] ?? '-',
                ),
                _buildParadaRow(
                  'Rua:',
                  falha['rua'] ?? '-',
                ),
                _buildParadaRow(
                  'Número:',
                  falha['numero'] ?? '-',
                ),
                _buildParadaRow(
                  'Endereço:',
                  '${falha['cidade'] ?? '-'} - ${falha['cep'] ?? '-'}',
                ),
                _buildParadaRow(
                  'Cidade:',
                  '${falha['cidade'] ?? '-'}',
                ),
                _buildParadaRow(
                  'Telefone:',
                  falha['telefone_empresa'] ?? '-',
                ),
              ],
            ),
          ),

          // 📸 Foto e Data
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto
                if (falha['foto_url'] != null)
                  GestureDetector(
                    onTap: () => _expandirFoto(falha['foto_url']),
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          falha['foto_url'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[600],
                            );
                          },
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.image,
                      color: Colors.grey[600],
                    ),
                  ),

                const SizedBox(height: 12),

                // Data
                Text(
                  'Data: ${_formatarData(falha['criado_em'] ?? '')}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParadaRow(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}