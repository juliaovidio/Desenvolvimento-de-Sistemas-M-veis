import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class InserirFalhaPage extends StatefulWidget {
  final Map<String, dynamic> parada;
  final int motoristaId;
  final VoidCallback onSalvo;

  const InserirFalhaPage({
    required this.parada,
    required this.motoristaId,
    required this.onSalvo,
  });

  @override
  State<InserirFalhaPage> createState() => _InserirFalhaPageState();
}

class _InserirFalhaPageState extends State<InserirFalhaPage> {
  final supabase = Supabase.instance.client;
  late TextEditingController descricaoController;
  XFile? imagemSelecionada;
  bool _isLoading = false;
  bool _uploadingImage = false;

  @override
  void initState() {
    super.initState();
    descricaoController = TextEditingController();
  }

  @override
  void dispose() {
    descricaoController.dispose();
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
  // MOSTRAR OPÇÕES DE CÂMERA/GALERIA (Novo Design)
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
          'falha_${widget.parada['id']}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage
          .from('foto-falha')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      final urlPublica = supabase.storage
          .from('foto-falha')
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
  // CONCLUIR FALHA
  // ==========================================
  Future<void> _concluirFalha() async {
    if (descricaoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Descreva o problema!'),
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

      final falhaData = {
        'parada_id': widget.parada['id'],
        'motorista_id': widget.motoristaId,
        'descricao': descricaoController.text,
        'criado_em': DateTime.now().toIso8601String(),
      };

      if (fotoUrl != null) {
        falhaData['foto_url'] = fotoUrl;
      }

      await supabase.from('falhas_entrega').insert(falhaData);

      await supabase
          .from('paradas')
          .update({'status': 'falha entrega'})
          .eq('id', widget.parada['id']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Falha registrada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onSalvo();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao registrar falha: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
      backgroundColor: const Color(0xFFF4F6F8), // Novo Fundo mais claro e limpo
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 21, 87),
        foregroundColor: const Color.fromARGB(255, 210, 227, 245),
        elevation: 0,
        title: const Text('Falha na entrega', style: TextStyle(fontSize: 18)),
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
                      Text(
                        '${widget.parada['ordem']}° Parada de Entrega',
                        style: const TextStyle(
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
                    '${widget.parada['bairro'] ?? '-'} - ${widget.parada['cidade']} ${widget.parada['uf']}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 📝 Descrição do problema
            const Text(
              'Descreva o problema',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: descricaoController,
              maxLines: 5,
              decoration: _buildInputDecoration('Explique o motivo da falha na entrega...'),
            ),

            const SizedBox(height: 32),

            // 📸 Foto (opcional) - Novo Design
            const Text(
              'Evidência Visual (Opcional)',
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
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
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
                            'Anexar imagem',
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

            const SizedBox(height: 40),

            // ✅ Botão Concluir Falha
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
                onPressed: _isLoading || _uploadingImage ? null : _concluirFalha,
                child: _isLoading || _uploadingImage
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.black),
                      )
                    : const Text(
                        'Concluir falha',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
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