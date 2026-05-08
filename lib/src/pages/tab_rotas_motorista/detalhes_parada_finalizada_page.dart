import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetalheParadaFinalizadoPage extends StatefulWidget {
  final Map<String, dynamic> parada;

  const DetalheParadaFinalizadoPage({
    required this.parada,
  });

  @override
  State<DetalheParadaFinalizadoPage> createState() =>
      _DetalheParadaFinalizadoPageState();
}

class _DetalheParadaFinalizadoPageState
    extends State<DetalheParadaFinalizadoPage> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  Map<String, dynamic>? falhaData;

  @override
  void initState() {
    super.initState();
    _buscarFalha();
  }

  // ==========================================
  // BUSCAR FALHA (SE HOUVER)
  // ==========================================
  Future<void> _buscarFalha() async {
    try {
      final response = await supabase
          .from('falhas_entrega')
          .select()
          .eq('parada_id', widget.parada['id'])
          .single();

      setState(() {
        falhaData = response;
        _isLoading = false;
      });
    } catch (e) {
      // Sem falha
      setState(() => _isLoading = false);
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
    bool isConcluida = widget.parada['status'] == 'concluido';
    bool temFalha = widget.parada['status'] == 'falha entrega';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 21, 87),
        foregroundColor: const Color.fromARGB(255, 210, 227, 245),
        title: Text(
          '${widget.parada['ordem']}° Parada - ${widget.parada['cidade']}',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📍 Endereço
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.parada['rua'] ?? '-'}, ${widget.parada['numero'] ?? '-'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${widget.parada['bairro'] ?? '-'} - ${widget.parada['cep'] ?? '-'}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                  Text(
                    '${widget.parada['cidade'] ?? '-'}, ${widget.parada['uf'] ?? '-'}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🏢 Informações da Empresa
            const Text(
              'Informações da Parada',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),

            _buildDetalhesRow('Empresa/Loja:', widget.parada['empresa_loja'] ?? '-'),
            _buildDetalhesRow('Responsável:', widget.parada['responsavel'] ?? '-'),
            _buildDetalhesRow('CPF/CNPJ:', widget.parada['cpf_cnpj'] ?? '-'),
            _buildDetalhesRow('Telefone:', widget.parada['telefone_empresa'] ?? '-'),
            _buildDetalhesRow(
              'Informação da Carga:',
              widget.parada['info_carga'] ?? '-',
            ),

            const SizedBox(height: 16),
            const Divider(thickness: 2),
            const SizedBox(height: 16),

            // ✅ Dados de Entrega (Se concluída)
            if (isConcluida) ...[
              const Text(
                'Dados de Entrega',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 10),

              _buildDetalhesRow(
                'Assinado por:',
                widget.parada['assinou_nome'] ?? '-',
              ),
              _buildDetalhesRow(
                'CPF:',
                widget.parada['assinou_cpf'] ?? '-',
              ),

              // Foto de entrega
              if (widget.parada['foto_entrega_url'] != null) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () =>
                      _expandirFoto(widget.parada['foto_entrega_url']),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.parada['foto_entrega_url'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),
              const Divider(thickness: 2),
              const SizedBox(height: 16),
            ],

            // ❌ Dados de Falha (Se houver falha)
            if (temFalha) ...[
              const Text(
                'Falha Registrada',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (falhaData != null) ...[
                _buildDetalhesRow(
                  'Descrição:',
                  falhaData!['descricao'] ?? '-',
                ),

                // Foto de falha
                if (falhaData!['foto_url'] != null) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _expandirFoto(falhaData!['foto_url']),
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          falhaData!['foto_url'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(thickness: 2),
                const SizedBox(height: 16),
              ],
            ],

            // 📌 Status da Parada
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isConcluida
                    ? Colors.green[50]
                    : temFalha
                        ? Colors.red[50]
                        : Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isConcluida
                      ? Colors.green[300]!
                      : temFalha
                          ? Colors.red[300]!
                          : Colors.blue[300]!,
                ),
              ),
              child: Row(
                children: [
                  if (isConcluida)
                    Icon(Icons.check_circle, color: Colors.green[600])
                  else if (temFalha)
                    Icon(Icons.cancel, color: Colors.red[600])
                  else
                    Icon(Icons.info, color: Colors.blue[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isConcluida
                          ? 'Parada Concluída'
                          : temFalha
                              ? 'Falha na Entrega'
                              : 'Parada Pendente',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isConcluida
                            ? Colors.green[700]
                            : temFalha
                                ? Colors.red[700]
                                : Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
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
}