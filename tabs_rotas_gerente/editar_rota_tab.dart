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
        SnackBar(content: Text('✅ Rota atualizada com sucesso!'), backgroundColor: Colors.green),
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🔍 Pesquisar Rota para Editar:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            TypeAheadField<Map<String, dynamic>>(
              builder: (context, controller, focusNode) => TextField(
                controller: buscaRotaController,
                focusNode: focusNode,
                decoration: _inputDeco("Digite a descrição, motorista ou veículo..."),
              ),
              suggestionsCallback: (pattern) async => await buscarRotasParaEdicao(pattern),
              itemBuilder: (context, suggestion) => ListTile(
                title: Text(suggestion['descricao'] ?? 'Sem descrição'),
                subtitle: Text("Motorista: ${suggestion['funcionarios']?['nome'] ?? 'N/A'} | Veículo: ${suggestion['veiculos']?['placa'] ?? 'N/A'}"),
                trailing: Text(suggestion['status'] ?? '', style: TextStyle(color: Colors.blue)),
              ),
              onSelected: (suggestion) {
                buscaRotaController.text = suggestion['descricao'];
                carregarRota(suggestion);
              },
            ),
            
            if (rotaIdSelecionada != null) ...[
              SizedBox(height: 20),
              Divider(thickness: 2, color: Colors.blue),
              SizedBox(height: 10),

              _buildTextField("Descrição da Rota:", descricaoController),
              SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: _buildTextField("Criada em:", criadaEmController)),
                  SizedBox(width: 10),
                  Expanded(child: _buildTextField("Iniciada em:", iniciadaEmController)),
                  SizedBox(width: 10),
                  Expanded(child: _buildTextField("Finalizada em:", finalizadaEmController)),
                ],
              ),
              SizedBox(height: 15),

              Text("Motorista:", style: TextStyle(fontWeight: FontWeight.bold)),
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
              SizedBox(height: 10),

              Text("Veículo:", style: TextStyle(fontWeight: FontWeight.bold)),
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
              SizedBox(height: 20),
              Divider(thickness: 2),

              Text("Paradas:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: listaParadas.length,
                itemBuilder: (context, index) {
                  final parada = listaParadas[index];
                  return Card(
                    color: Colors.grey[100],
                    margin: EdgeInsets.only(bottom: 15),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Parada ${index + 1}", style: TextStyle(fontWeight: FontWeight.bold)),
                              
                              DropdownButton<String>(
                                value: parada.status,
                                items: ['pendente', 'em andamento', 'finalizado', 'cancelado']
                                    .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                onChanged: (val) => setState(() => parada.status = val!),
                              ),
                            ],
                          ),

                          _buildTextField("Ordem", parada.ordem, isNumber: true),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                            child: Text(
                              "pergunte para a IA a melhor ordem",
                              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                            ),
                          ),
                          _buildTextField("Valor por parada:", parada.valorPorParada, isNumber: true),
                          SizedBox(height: 8),

                          Row(
                            children: [
                              Expanded(flex: 3, child: _buildTextField("Cidade", parada.cidade)),
                              SizedBox(width: 10),
                              Expanded(flex: 1, child: _buildTextField("UF", parada.uf)),
                            ],
                          ),
                          _buildTextField("Bairro", parada.bairro),
                          _buildTextField("CEP", parada.cep),
                          Row(
                            children: [
                              Expanded(flex: 3, child: _buildTextField("Rua", parada.rua)),
                              SizedBox(width: 10),
                              Expanded(flex: 1, child: _buildTextField("Nº", parada.numero)),
                            ],
                          ),
                          _buildTextField("Empresa/Loja", parada.empresa),
                          _buildTextField("Responsável", parada.responsavel),
                          _buildTextField("CPF/CNPJ", parada.cpfCnpj),
                          _buildTextField("Telefone", parada.telefone),
                          _buildTextField("Informação da Carga", parada.infoCarga),

                          // ==========================================
                          // SEÇÃO DE FINALIZAÇÃO DA PARADA
                          // ==========================================
                          if (parada.status == 'finalizado') ...[
                            SizedBox(height: 15),
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                border: Border.all(color: Colors.green),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Dados de Conclusão", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800])),
                                  _buildTextField("Nome de quem assinou", parada.assinouNome),
                                  _buildTextField("CPF de quem assinou", parada.assinouCpf),
                                  _buildTextField("Concluída em", parada.concluidaEm),
                                  SizedBox(height: 10),
                                  Text("Foto da entrega:", style: TextStyle(fontSize: 14)),
                                  SizedBox(height: 5),
                                  
                                  // LÓGICA DA FOTO AQUI:
                                  // Se tiver URL preenchida, mostra a foto da internet. Se for null/vazio, mostra o quadro cinza.
                                  if (parada.fotoUrl != null && parada.fotoUrl!.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        parada.fotoUrl!,
                                        height: 120,
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
                    ),
                  );
                },
              ),
              
              Divider(thickness: 2),
              SizedBox(height: 10),

              _buildTextField("Quant total da carga:", cargaTotalController),
              _buildTextField("Tempo estimado:", tempoController),
              _buildTextField("Total km:", totalKmController, isNumber: true),
              _buildTextField("Valor a pagar motorista:", valorMotoristaController, isNumber: true),
              _buildTextField("Valor gasto caminhão:", valorCaminhaoController, isNumber: true),
              _buildTextField("Valor a cobrar da entrega:", valorCobrarController, isNumber: true),

              SizedBox(height: 30),

              Center(
                child: _isLoading 
                  ? CircularProgressIndicator() 
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                      ),
                      onPressed: atualizarRota,
                      child: Text("Salvar Alterações da Rota", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
              ),
              SizedBox(height: 40),
            ]
          ],
        ),
      ),
    );
  }

  // WIDGET EXTRA PARA EVITAR CÓDIGO REPETIDO DO QUADRO CINZA
  Widget _quadroCinzaSemFoto() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(10)
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, color: Colors.white, size: 40),
            Text("Sem foto registrada", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14)),
          TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: _inputDeco(""),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[300],
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    );
  }
}