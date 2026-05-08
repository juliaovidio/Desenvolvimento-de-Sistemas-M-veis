import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import './inserir_falha_page.dart';

class ConcluirParadaPage extends StatefulWidget {
  final Map<String, dynamic> parada;
  final int rotaId;
  final int motoristaId;
  final VoidCallback onSalvo;

  const ConcluirParadaPage({
    required this.parada,
    required this.rotaId,
    required this.motoristaId,
    required this.onSalvo,
  });

  @override
  State<ConcluirParadaPage> createState() => _ConcluirParadaPageState();
}

class _ConcluirParadaPageState extends State<ConcluirParadaPage> {
  final supabase = Supabase.instance.client;
  late TextEditingController nomeController;
  late TextEditingController cpfController;
  XFile? imagemSelecionada;
  bool _isLoading = false;
  bool _uploadingImage = false;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(
      text: widget.parada['assinou_nome'] ?? '',
    );
    cpfController = TextEditingController(
      text: widget.parada['assinou_cpf'] ?? '',
    );
  }

  @override
  void dispose() {
    nomeController.dispose();
    cpfController.dispose();
    super.dispose();
  }

  // ==========================================
  // SELECIONAR IMAGEM (CÂMERA OU GALERIA)
  // ==========================================
  Future<void> _selecionarImagem(ImageSource source) async {
    final picker = ImagePicker();
    final imagem = await picker.pickImage(source: source);

    if (imagem != null) {
      setState(() {
        imagemSelecionada = imagem;
      });
    }
  }

  // ==========================================
  // MOSTRAR OPÇÕES DE CÂMERA/GALERIA
  // ==========================================
  void _mostrarOpcoesFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.blue),
              ),
              title: const Text('Tirar foto da câmera', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _selecionarImagem(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.image, color: Colors.purple),
              ),
              title: const Text('Escolher da galeria', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _selecionarImagem(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // UPLOAD DE IMAGEM PARA SUPABASE STORAGE
  // ==========================================
  Future<String?> _uploadImagemParaStorage() async {
    if (imagemSelecionada == null) return null;

    setState(() => _uploadingImage = true);

    try {
      final bytes = await imagemSelecionada!.readAsBytes();
      final fileName =
          'parada_${widget.parada['id']}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage
          .from('fotos-paradas')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      final urlPublica = supabase.storage
          .from('fotos-paradas')
          .getPublicUrl(fileName);

      setState(() => _uploadingImage = false);
      return urlPublica;
    } catch (e) {
      print('Erro no upload: $e');
      setState(() => _uploadingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer upload: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  // ==========================================
  // CONCLUIR PARADA
  // ==========================================
  Future<void> _concluirParada() async {
    if (nomeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha o nome!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (cpfController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha o CPF!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? fotoUrl;
      if (imagemSelecionada != null) {
        fotoUrl = await _uploadImagemParaStorage();
      }

      final updateData = {
        'assinou_nome': nomeController.text,
        'assinou_cpf': cpfController.text,
        'status': 'concluido',
      };

      if (fotoUrl != null) {
        updateData['foto_entrega_url'] = fotoUrl;
      }

      await supabase
          .from('paradas')
          .update(updateData)
          .eq('id', widget.parada['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Parada concluída com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onSalvo();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao concluir parada: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // FALHA NA ENTREGA
  // ==========================================
  void _falhaEntrega() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InserirFalhaPage(
          parada: widget.parada,
          motoristaId: widget.motoristaId,
          onSalvo: widget.onSalvo,
        ),
      ),
    ).then((_) {
      Navigator.pop(context);
    });
  }

  // ==========================================
  // DECORAÇÃO PADRÃO DE INPUT
  // ==========================================
  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade300, width: 1.5),
      ),
    );
  }

  // ==========================================
  // INTERFACE
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Fundo mais claro e limpo
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 21, 87),
        foregroundColor: const Color.fromARGB(255, 210, 227, 245),
        elevation: 0,
        title: Text(
          '${widget.parada['ordem']}° Parada - ${widget.parada['cidade']} ${widget.parada['uf']}',
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📍 Endereço
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red[400], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Endereço de Entrega',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.parada['rua'] ?? '-'}, ${widget.parada['numero'] ?? '-'}',
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.parada['bairro'] ?? '-'} - CEP: ${widget.parada['cep'] ?? '-'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 📸 Evidência Visual (Baseado no novo design)
            const Text(
              'Evidência Visual',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: _mostrarOpcoesFoto,
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA), // Cinza bem clarinho
                  borderRadius: BorderRadius.circular(16),
                  // Borda simulando o tracejado da imagem (usando uma cor suave)
                  border: Border.all(color: Colors.grey.shade400, width: 1.5),
                ),
                child: imagemSelecionada == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 32,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tirar Foto',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(imagemSelecionada!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 32),

            // 👤 Quem assinou (Inputs atualizados)
            const Text(
              'Recebedor',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: nomeController,
              decoration: _buildInputDecoration('Ex: João da Silva...'),
            ),

            const SizedBox(height: 16),

            const Text(
              'Documento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: cpfController,
              keyboardType: TextInputType.number,
              decoration: _buildInputDecoration('Ex: 123.456.789-00'),
            ),

            const SizedBox(height: 40),

            // ✅ Botão Concluir Parada
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 1, 21, 87),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading || _uploadingImage ? null : _concluirParada,
                child: _isLoading || _uploadingImage
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.black),
                      )
                    : const Text(
                        'Concluir Parada',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // ❌ Botão Falha na Entrega
            SizedBox(
              width: double.infinity,
              height: 55,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red.shade300, width: 1.5),
                  ),
                ),
                onPressed: _falhaEntrega,
                child: const Text(
                  'Falha na entrega',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}