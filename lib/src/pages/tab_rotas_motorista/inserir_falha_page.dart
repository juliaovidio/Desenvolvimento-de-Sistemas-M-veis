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
  // MOSTRAR OPÇÕES DE CÂMERA/GALERIA
  // ==========================================
  void _mostrarOpcoesFoto() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar foto'),
              onTap: () {
                Navigator.pop(context);
                _selecionarImagem(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                _selecionarImagem(ImageSource.gallery);
              },
            ),
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
  // INTERFACE
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 21, 87),
        foregroundColor: const Color.fromARGB(255, 210, 227, 245),
        title: const Text('Falha na entrega'),
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
                    '${widget.parada['ordem']}° Parada - ${widget.parada['cidade']} ${widget.parada['uf']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.parada['rua'] ?? '-'}, ${widget.parada['numero'] ?? '-'}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    '${widget.parada['bairro'] ?? '-'} - ${widget.parada['cep'] ?? '-'}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 📝 Descrição do problema
            Text(
              'Descreva o problema:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: descricaoController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Descrição',
                filled: true,
                fillColor: Colors.grey[300],
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 📸 Foto (opcional)
            Text(
              'Foto (se quiser):',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: _mostrarOpcoesFoto,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: imagemSelecionada == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 40, color: Colors.grey[600]),
                          const SizedBox(height: 8),
                          Text(
                            'Anexar imagem',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      )
                    : Image.file(
                        File(imagemSelecionada!.path),
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            const SizedBox(height: 30),

            // ✅ Botão Concluir Falha
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[400],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _isLoading || _uploadingImage
                    ? null
                    : _concluirFalha,
                child: _isLoading || _uploadingImage
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text(
                        'Concluir relatório de falha',
                        style: TextStyle(
                          color: Colors.black,
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