import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class VisualizarFalhasPage extends StatefulWidget {
  final int autorId;
  final String cargo;
  final String nome;

  const VisualizarFalhasPage({
    super.key,
    required this.autorId,
    required this.cargo,
    required this.nome,
  });

  @override
  State<VisualizarFalhasPage> createState() => _VisualizarFalhasPageState();
}

class _VisualizarFalhasPageState extends State<VisualizarFalhasPage> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  
  List<Map<String, dynamic>> falhas = [];

  @override
  void initState() {
    super.initState();
    _carregarFalhas();
  }

  // ==========================================
  // CARREGAR FALHAS DO MOTORISTA
  // ==========================================
  Future<void> _carregarFalhas() async {
    setState(() => _isLoading = true);
    try {
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

      final falhasData = await supabase
          .from('falhas_entrega')
          .select('id, parada_id, descricao, foto_url, criado_em')
          .inFilter('parada_id', paradasIds)
          .order('criado_em', ascending: false);

      List<Map<String, dynamic>> falhasComDados = [];

      for (var falha in falhasData) {
        final parada = await supabase
            .from('paradas')
            .select('id, rota_id, cidade, uf, rua, numero, bairro, cep')
            .eq('id', falha['parada_id'])
            .single();

        final rota = await supabase
            .from('rotas')
            .select('descricao, motorista_id')
            .eq('id', parada['rota_id'])
            .single();

        if (rota['motorista_id'] == widget.autorId) {
          falhasComDados.add({
            'id': falha['id'],
            'descricao_falha': falha['descricao'],
            'foto_url': falha['foto_url'],
            'criado_em': falha['criado_em'],
            'descricao_rota': rota['descricao'],
            'cidade': parada['cidade'],
            'uf': parada['uf'],
            'rua': parada['rua'],
            'numero': parada['numero'],
            'bairro': parada['bairro'],
            'cep': parada['cep'],
          });
        }
      }

      setState(() {
        falhas = falhasComDados;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar falhas: $e');
      setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // FORMATAR DATAS
  // ==========================================
  String _formatarDataApenas(String dataIso) {
    try {
      final data = DateTime.parse(dataIso);
      return DateFormat('dd/MM/yyyy').format(data);
    } catch (e) {
      return '-';
    }
  }

  String _formatarHoraApenas(String dataIso) {
    try {
      final data = DateTime.parse(dataIso);
      return DateFormat('HH:mm').format(data);
    } catch (e) {
      return '-';
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
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              fotoUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
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
    return Container(
      color: const Color(0xFFF5F6FA),
      child: Column(
        children: [
          // LISTA DE FALHAS
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : falhas.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhuma rota com falha',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: falhas.length,
                        itemBuilder: (context, index) {
                          return _buildFalhaCard(falhas[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CARD DE FALHA
  // ==========================================
  Widget _buildFalhaCard(Map<String, dynamic> falha) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CABEÇALHO: Título e Data/Hora
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    falha['descricao_rota'] ?? 'Rota sem descrição',
                    style: const TextStyle(
                      color: Color(0xFF00214B), // Azul escuro do título
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatarDataApenas(falha['criado_em'] ?? ''),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    Text(
                      _formatarHoraApenas(falha['criado_em'] ?? ''),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 8),

            // BADGE "FALHAS"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE), // Fundo vermelho claro
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 16),
                  const SizedBox(width: 4),
                  const Text(
                    'FALHAS',
                    style: TextStyle(
                      color: Color(0xFFD32F2F),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // CORPO: Imagem e Dados
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagem
                GestureDetector(
                  onTap: () => _expandirFoto(falha['foto_url']),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: falha['foto_url'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              falha['foto_url'],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey),
                            ),
                          )
                        : const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
                
                const SizedBox(width: 16),

                // Lista de Informações com Ícones
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.location_on_outlined, '${falha['cidade'] ?? '-'}, ${falha['uf'] ?? '-'}'),
                      const SizedBox(height: 6),
                      _buildInfoRow(Icons.local_shipping_outlined, '${falha['rua'] ?? '-'}, ${falha['numero'] ?? '-'}'),
                      const SizedBox(height: 6),
                      _buildInfoRow(Icons.inventory_2_outlined, '${falha['bairro'] ?? '-'} - ${falha['cep'] ?? '-'}'),
                      const SizedBox(height: 6),
                      
                      // NOVO COMPONENTE EXPANSÍVEL PARA A DESCRIÇÃO
                      _ExpandableDescription(text: falha['descricao_falha'] ?? 'Sem descrição'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para as linhas de ícone + texto normal (não expansíveis)
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.black87),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ==========================================
// WIDGET PARA DESCRIÇÃO EXPANSÍVEL
// ==========================================
class _ExpandableDescription extends StatefulWidget {
  final String text;

  const _ExpandableDescription({required this.text});

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      // Deixa o clique mais fácil de pegar em toda a área da linha
      behavior: HitTestBehavior.opaque, 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: Colors.black87),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.text,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: _isExpanded ? null : 1, // Se expandido tira o limite de linhas
                  overflow: _isExpanded ? null : TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _isExpanded ? 'Ver menos' : 'Ver mais',
                  style: const TextStyle(
                    color: Color(0xFF00214B), // Mesma cor azul do título
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}