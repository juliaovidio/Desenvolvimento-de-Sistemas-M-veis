import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

// ---------------------------------------------------------
// Classe para gerenciar os controladores de cada parada
// ---------------------------------------------------------
class ParadaModel {
  int? id; 
  TextEditingController ordem = TextEditingController();
  TextEditingController cidade = TextEditingController();
  TextEditingController uf = TextEditingController();
  TextEditingController bairro = TextEditingController();
  TextEditingController cep = TextEditingController();
  TextEditingController rua = TextEditingController();
  TextEditingController numero = TextEditingController();
  TextEditingController empresa = TextEditingController();
  TextEditingController responsavel = TextEditingController();
  TextEditingController cpfCnpj = TextEditingController();
  TextEditingController telefone = TextEditingController();
  TextEditingController infoCarga = TextEditingController();
  TextEditingController valorPorParada = TextEditingController();
  
  // Novos campos de status e finalização
  String status = 'pendente'; 
  TextEditingController assinouNome = TextEditingController();
  TextEditingController assinouCpf = TextEditingController();
  TextEditingController concluidaEm = TextEditingController();
  String? fotoUrl;

  void dispose() {
    ordem.dispose();
    cidade.dispose();
    uf.dispose();
    bairro.dispose();
    cep.dispose();
    rua.dispose();
    numero.dispose();
    empresa.dispose();
    responsavel.dispose();
    cpfCnpj.dispose();
    telefone.dispose();
    infoCarga.dispose();
    valorPorParada.dispose();
    assinouNome.dispose();
    assinouCpf.dispose();
    concluidaEm.dispose();
  }
}

// ---------------------------------------------------------
// WIDGET PRINCIPAL
// ---------------------------------------------------------
class EditarRotaTab extends StatefulWidget {
  @override
  _EditarRotaTabState createState() => _EditarRotaTabState();
}

class _EditarRotaTabState extends State<EditarRotaTab> {
  final supabase = Supabase.instance.client;
  bool _isLoading = false;
  int? rotaIdSelecionada;

  // Controlador de Busca
  final buscaRotaController = TextEditingController();

  // Controladores da Rota
  final descricaoController = TextEditingController();
  final tempoController = TextEditingController();
  final totalKmController = TextEditingController();
  final valorMotoristaController = TextEditingController();
  final valorCaminhaoController = TextEditingController();
  final valorCobrarController = TextEditingController();
  final cargaTotalController = TextEditingController();
  
  // Campos de data/status da Rota
  final criadaEmController = TextEditingController();
  final iniciadaEmController = TextEditingController();
  final finalizadaEmController = TextEditingController();
  String statusRota = 'a realizar';

  // IDs e buscas de FK
  int? motoristaSelecionadoId;
  int? veiculoSelecionadoId;
  final motoristaSearchController = TextEditingController();
  final veiculoSearchController = TextEditingController();

  // Lista dinâmica de paradas
  List<ParadaModel> listaParadas = [];

  @override
  void dispose() {
    buscaRotaController.dispose();
    descricaoController.dispose();
    tempoController.dispose();
    totalKmController.dispose();
    valorMotoristaController.dispose();
    valorCaminhaoController.dispose();
    valorCobrarController.dispose();
    cargaTotalController.dispose();
    criadaEmController.dispose();
    iniciadaEmController.dispose();
    finalizadaEmController.dispose();
    motoristaSearchController.dispose();
    veiculoSearchController.dispose();
    for (var p in listaParadas) {
      p.dispose();
    }
    super.dispose();
  }

  // ==========================================
  // BUSCAS E SELECTS
  // ==========================================
  Future<List<Map<String, dynamic>>> buscarRotasParaEdicao(String query) async {
    final response = await supabase
        .from('rotas')
        .select('*, funcionarios(nome), veiculos(descricao, placa)')
        .or('descricao.ilike.%$query%, status.ilike.%$query%'); 
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> buscarMotoristas(String query) async {
    final response = await supabase
        .from('funcionarios')
        .select('id, nome')
        .ilike('cargo', '%motorista%')
        .ilike('nome', '%$query%');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> buscarVeiculos(String query) async {
    final response = await supabase
        .from('veiculos')
        .select('id, descricao, placa')
        .ilike('descricao', '%$query%');
    return List<Map<String, dynamic>>.from(response);
  }

  // ==========================================
  // CARREGAR DADOS DA ROTA E PARADAS SELECIONADAS
  // ==========================================
  void carregarRota(Map<String, dynamic> rota) async {
    setState(() {
      _isLoading = true;
      rotaIdSelecionada = rota['id'];
      
      descricaoController.text = rota['descricao'] ?? '';
      tempoController.text = rota['tempo_estimado'] ?? '';
      totalKmController.text = rota['total_km']?.toString() ?? '';
      valorMotoristaController.text = rota['valor_pagar_motorista']?.toString() ?? '';
      valorCaminhaoController.text = rota['valor_gasto_caminhao']?.toString() ?? '';
      valorCobrarController.text = rota['valor_cobrar_entrega']?.toString() ?? '';
      cargaTotalController.text = rota['carga_total'] ?? '';
      
      criadaEmController.text = rota['criada_em'] ?? '';
      iniciadaEmController.text = rota['iniciada_em'] ?? '';
      finalizadaEmController.text = rota['finalizada_em'] ?? '';
      statusRota = rota['status'] ?? 'a realizar';

      motoristaSelecionadoId = rota['motorista_id'];
      veiculoSelecionadoId = rota['veiculo_id'];
      motoristaSearchController.text = rota['funcionarios']?['nome'] ?? '';
      veiculoSearchController.text = "${rota['veiculos']?['descricao']} - ${rota['veiculos']?['placa']}";
    });

    final paradasRes = await supabase
        .from('paradas')
        .select()
        .eq('rota_id', rotaIdSelecionada!)
        .order('ordem', ascending: true);

    setState(() {
      for (var p in listaParadas) { p.dispose(); }
      
      listaParadas = paradasRes.map<ParadaModel>((p) {
        var model = ParadaModel();
        model.id = p['id'];
        model.ordem.text = p['ordem']?.toString() ?? '';
        model.cidade.text = p['cidade'] ?? '';
        model.uf.text = p['uf'] ?? '';
        model.bairro.text = p['bairro'] ?? '';
        model.cep.text = p['cep'] ?? '';
        model.rua.text = p['rua'] ?? '';
        model.numero.text = p['numero'] ?? '';
        model.empresa.text = p['empresa_loja'] ?? '';
        model.responsavel.text = p['responsavel'] ?? '';
        model.cpfCnpj.text = p['cpf_cnpj'] ?? '';
        model.telefone.text = p['telefone_empresa'] ?? '';
        model.infoCarga.text = p['info_carga'] ?? '';
        model.valorPorParada.text = p['valor_por_parada']?.toString() ?? '';
        model.status = p['status'] ?? 'pendente';
        model.assinouNome.text = p['assinou_nome'] ?? '';
        model.assinouCpf.text = p['assinou_cpf'] ?? '';
        model.concluidaEm.text = p['concluida_em'] ?? '';
        model.fotoUrl = p['foto_url'];
        return model;
      }).toList();
      _isLoading = false;
    });
  }

  // ==========================================
  // ATUALIZAR TUDO NO SUPABASE
  // ==========================================
  Future<void> atualizarRota() async {
    if (rotaIdSelecionada == null) return;
    setState(() => _isLoading = true);

    try {
      await supabase.from('rotas').update({
        'descricao': descricaoController.text,
        'motorista_id': motoristaSelecionadoId,
        'veiculo_id': veiculoSelecionadoId,
        'tempo_estimado': tempoController.text,
        'total_km': double.tryParse(totalKmController.text) ?? 0.0,
        'valor_pagar_motorista': double.tryParse(valorMotoristaController.text) ?? 0.0,
        'valor_gasto_caminhao': double.tryParse(valorCaminhaoController.text) ?? 0.0,
        'valor_cobrar_entrega': double.tryParse(valorCobrarController.text) ?? 0.0,
        'carga_total': cargaTotalController.text,
        'iniciada_em': iniciadaEmController.text.isEmpty ? null : iniciadaEmController.text,
        'finalizada_em': finalizadaEmController.text.isEmpty ? null : finalizadaEmController.text,
        'status': statusRota,
      }).eq('id', rotaIdSelecionada!);

      await supabase.from('paradas').delete().eq('rota_id', rotaIdSelecionada!);

      List<Map<String, dynamic>> paradasParaInserir = [];
      for (int i = 0; i < listaParadas.length; i++) {
        final p = listaParadas[i];
        paradasParaInserir.add({
          'rota_id': rotaIdSelecionada,
          'ordem': int.tryParse(p.ordem.text) ?? (i + 1),
          'cidade': p.cidade.text,
          'uf': p.uf.text,
          'bairro': p.bairro.text,
          'cep': p.cep.text,
          'rua': p.rua.text,
          'numero': p.numero.text,
          'empresa_loja': p.empresa.text,
          'responsavel': p.responsavel.text,
          'cpf_cnpj': p.cpfCnpj.text,
          'telefone_empresa': p.telefone.text,
          'info_carga': p.infoCarga.text,
          'valor_por_parada': double.tryParse(p.valorPorParada.text) ?? 0.0,
          'status': p.status,
          'assinou_nome': p.assinouNome.text.isEmpty ? null : p.assinouNome.text,
          'assinou_cpf': p.assinouCpf.text.isEmpty ? null : p.assinouCpf.text,
          'concluida_em': p.concluidaEm.text.isEmpty ? null : p.concluidaEm.text,
          'foto_url': p.fotoUrl, // Mantém a URL se existir
        });
      }
      await supabase.from('paradas').insert(paradasParaInserir);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Rota atualizada com sucesso!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // INTERFACE DE USUÁRIO (UI)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Fundo moderno
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 BARRA DE PESQUISA AJEITADA
            const Text(
              "Pesquisar Rota para Editar",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F265C)),
            ),
            const SizedBox(height: 8),
            TypeAheadField<Map<String, dynamic>>(
              builder: (context, controller, focusNode) => TextField(
                controller: buscaRotaController,
                focusNode: focusNode,
                decoration: _inputDeco("Digite a descrição, status, motorista...").copyWith(
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                ),
              ),
              suggestionsCallback: (pattern) async => await buscarRotasParaEdicao(pattern),
              itemBuilder: (context, suggestion) => Container(
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: const Icon(Icons.route, color: Color(0xFF00214B)),
                  ),
                  title: Text(suggestion['descricao'] ?? 'Sem descrição', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Motorista: ${suggestion['funcionarios']?['nome'] ?? 'N/A'}\nVeículo: ${suggestion['veiculos']?['placa'] ?? 'N/A'}"),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      suggestion['status'] ?? '',
                      style: const TextStyle(color: Color(0xFF00214B), fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ),
              ),
              onSelected: (suggestion) {
                buscaRotaController.text = suggestion['descricao'];
                carregarRota(suggestion);
              },
            ),
            
            if (rotaIdSelecionada != null) ...[
              const SizedBox(height: 32),
              const Divider(thickness: 1, color: Colors.black12),
              const SizedBox(height: 24),
              
              const Text("Dados Principais da Rota", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F265C))),
              const SizedBox(height: 16),

              _buildTextField("Descrição da Rota", descricaoController),
              
              Row(
                children: [
                  Expanded(child: _buildTextField("Criada em", criadaEmController)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField("Iniciada em", iniciadaEmController)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField("Finalizada em", finalizadaEmController)),
                ],
              ),

              const Text("Motorista", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              TypeAheadField<Map<String, dynamic>>(
                builder: (context, controller, focusNode) => TextField(
                  controller: motoristaSearchController,
                  focusNode: focusNode,
                  decoration: _inputDeco("Alterar motorista"),
                ),
                suggestionsCallback: (pattern) async => await buscarMotoristas(pattern),
                itemBuilder: (context, suggestion) => ListTile(title: Text(suggestion['nome'])),
                onSelected: (suggestion) {
                  motoristaSearchController.text = suggestion['nome'];
                  motoristaSelecionadoId = suggestion['id'];
                },
              ),
              const SizedBox(height: 16),

              const Text("Veículo", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              TypeAheadField<Map<String, dynamic>>(
                builder: (context, controller, focusNode) => TextField(
                  controller: veiculoSearchController,
                  focusNode: focusNode,
                  decoration: _inputDeco("Alterar veículo"),
                ),
                suggestionsCallback: (pattern) async => await buscarVeiculos(pattern),
                itemBuilder: (context, suggestion) => ListTile(title: Text("${suggestion['descricao']} - ${suggestion['placa']}")),
                onSelected: (suggestion) {
                  veiculoSearchController.text = "${suggestion['descricao']} - ${suggestion['placa']}";
                  veiculoSelecionadoId = suggestion['id'];
                },
              ),
              
              const SizedBox(height: 32),
              const Divider(thickness: 1, color: Colors.black12),
              const SizedBox(height: 16),

              const Text("Roteiro de Paradas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F265C))),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: listaParadas.length,
                itemBuilder: (context, index) {
                  final parada = listaParadas[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)),
                              child: Text("Parada ${index + 1}", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00214B))),
                            ),
                            
                            // NOVO SELECT DE STATUS DA PARADA
                           // NOVO SELECT DE STATUS DA PARADA
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: parada.status,
                                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00214B)),
                                  style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600),
                                  // SOLUÇÃO: Trocamos 'finalizado' por 'concluido' para bater com o banco de dados!
                                  items: ['pendente', 'em andamento', 'concluido', 'cancelado', 'falha entrega']
                                      .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
                                  onChanged: (val) => setState(() => parada.status = val!),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        _buildTextField("Ordem", parada.ordem, isNumber: true),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
                          child: Row(
                            children: [
                              Icon(Icons.auto_awesome, size: 14, color: Color(0xFF00214B)),
                              const SizedBox(width: 4),
                              Text(
                                "Pergunte para a IA a melhor ordem",
                                style: TextStyle(fontSize: 12, color: Color(0xFF00214B), fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        _buildTextField("Valor por parada", parada.valorPorParada, isNumber: true),

                        Row(
                          children: [
                            Expanded(flex: 3, child: _buildTextField("Cidade", parada.cidade)),
                            const SizedBox(width: 12),
                            Expanded(flex: 1, child: _buildTextField("UF", parada.uf)),
                          ],
                        ),
                        _buildTextField("Bairro", parada.bairro),
                        _buildTextField("CEP", parada.cep),
                        Row(
                          children: [
                            Expanded(flex: 3, child: _buildTextField("Rua", parada.rua)),
                            const SizedBox(width: 12),
                            Expanded(flex: 1, child: _buildTextField("Nº", parada.numero)),
                          ],
                        ),
                        _buildTextField("Empresa/Loja", parada.empresa),
                        _buildTextField("Responsável", parada.responsavel),
                        _buildTextField("CPF/CNPJ", parada.cpfCnpj),
                        _buildTextField("Telefone", parada.telefone),
                        _buildTextField("Informação da Carga", parada.infoCarga, maxLines: 2),

                        // ==========================================
                        // SEÇÃO DE FINALIZAÇÃO DA PARADA (VISUAL MELHORADO)
                        // ==========================================
                        if (parada.status == 'finalizado' || parada.status == 'concluido') ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              border: Border.all(color: Colors.green.shade200),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                                    const SizedBox(width: 8),
                                    Text("Dados de Conclusão", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green.shade800)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                _buildTextField("Nome de quem assinou", parada.assinouNome),
                                _buildTextField("CPF de quem assinou", parada.assinouCpf),
                                _buildTextField("Data de conclusão", parada.concluidaEm),
                                
                                const Text("Evidência Visual da Entrega", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                                const SizedBox(height: 8),
                                
                                if (parada.fotoUrl != null && parada.fotoUrl!.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      parada.fotoUrl!,
                                      height: 140,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => _quadroCinzaSemFoto(),
                                    ),
                                  )
                                else
                                  _quadroCinzaSemFoto(),
                              ],
                            ),
                          )
                        ],
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 10),
              const Divider(thickness: 1, color: Colors.black12),
              const SizedBox(height: 20),

              const Text("Valores e Resumo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F265C))),
              const SizedBox(height: 16),

              _buildTextField("Quantidade total da carga", cargaTotalController),
              _buildTextField("Tempo estimado", tempoController),
              _buildTextField("Total (km)", totalKmController, isNumber: true),
              _buildTextField("Valor a pagar ao motorista", valorMotoristaController, isNumber: true),
              _buildTextField("Valor gasto com caminhão", valorCaminhaoController, isNumber: true),
              _buildTextField("Valor a cobrar da entrega", valorCobrarController, isNumber: true),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF00214B))) 
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00214B),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                      ),
                      onPressed: atualizarRota,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text("Salvar Alterações da Rota", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
              ),
              const SizedBox(height: 60),
            ]
          ],
        ),
      ),
    );
  }

  // WIDGET DO QUADRO CINZA
  Widget _quadroCinzaSemFoto() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400, size: 40),
            const SizedBox(height: 8),
            Text("Sem foto registrada", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // WIDGET DE INPUT PADRÃO
  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, String hint = "", int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
            decoration: _inputDeco(hint),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF0F265C), width: 1.5),
      ),
    );
  }
}