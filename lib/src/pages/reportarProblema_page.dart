// ignore: file_names
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../layout/main_layout.dart';


class ReportarProblemaPage extends StatefulWidget {
  final String cargo;
  final String nome;
  final int autorId;


  const ReportarProblemaPage({
    super.key,
    required this.cargo,
    required this.nome,
    required this.autorId,
  });


  @override
  State<ReportarProblemaPage> createState() => _ReportarProblemaPageState();
}


class _ReportarProblemaPageState extends State<ReportarProblemaPage> {
  final supabase = Supabase.instance.client;


  // Aba inicial baseada no design
  String abaSelecionada = "adicionar";


  List relatos = [];
  XFile? imagemSelecionada;
  bool isLoading = false;


  // Controllers dos campos
  final tituloCtrl = TextEditingController();
  final descricaoCtrl = TextEditingController();


  // 🔥 CORES DO DESIGN FIEL
  final Color primaryDarkBlue = const Color(0xFF00214B);
  final Color bgColor = const Color(0xFFF5F6FA);
  final Color primaryBlueTitle = const Color(0xFF00214B);
  final Color placeholderColor = const Color(0xFFE9EDF2);
  final Color lightBluePill = const Color(0xFFF0F4FC);


  @override
  void initState() {
    super.initState();
    carregarRelatos();
  }


  // =============================
  // 🔥 BANCO DE DADOS
  // =============================


  Future<void> carregarRelatos() async {
    final response = await supabase
        .from('relatos_problema')
        .select()
        .order('criado_em', ascending: false);


    setState(() {
      relatos = response;
    });
  }


  // =============================
  // 📷 CÂMERA
  // =============================


  Future<void> tirarFoto() async {
    final status = await Permission.camera.request();


    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permissão de câmera negada")),
        );
      }
      return;
    }


    final picker = ImagePicker();
    final foto = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );


    if (foto != null) {
      setState(() => imagemSelecionada = foto);
    }
  }


  // =============================
  // 🔐 SALVAR RELATO
  // =============================


  Future<void> salvarRelato() async {
    if (tituloCtrl.text.isEmpty || descricaoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha título e descrição")),
      );
      return;
    }


    setState(() => isLoading = true);


    try {
      String? urlImagem;


      if (imagemSelecionada != null) {
        final bytes = await imagemSelecionada!.readAsBytes();
        final fileName = 'relato_${DateTime.now().millisecondsSinceEpoch}.jpg';


        await supabase.storage.from('relatos').uploadBinary(fileName, bytes);
        urlImagem = supabase.storage.from('relatos').getPublicUrl(fileName);
      }


      await supabase.from('relatos_problema').insert({
        'titulo': tituloCtrl.text,
        'descricao': descricaoCtrl.text,
        'foto_url': urlImagem,
        'autor_id': widget.autorId,
        'criado_em': DateTime.now().toIso8601String(),
      });


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Relato salvo com sucesso!")),
        );
      }


      limparCampos();
      await carregarRelatos();
      setState(() => abaSelecionada = "visualizar");
    } catch (e) {
      print("Erro ao salvar relato: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao salvar o relato")),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }


  void limparCampos() {
    tituloCtrl.clear();
    descricaoCtrl.clear();
    setState(() => imagemSelecionada = null);
  }


  // =============================
  // UI WIDGETS (VISUAL FIEL)
  // =============================


  Widget abaPersonalizada(String titulo, IconData icone, String valor) {
    final ativo = abaSelecionada == valor;


    return GestureDetector(
      onTap: () {
        setState(() => abaSelecionada = valor);
        if (valor == "adicionar") limparCampos();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          color: ativo ? lightBluePill : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, color: ativo ? primaryDarkBlue : Colors.grey.shade500, size: 24),
            const SizedBox(height: 4),
            Text(
              titulo,
              style: TextStyle(
                color: ativo ? primaryDarkBlue : Colors.grey.shade500,
                fontWeight: ativo ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget campoPersonalizado(String titulo, String hint, TextEditingController ctrl, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: ctrl,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }


  Widget cardRelato(Map f) {
    String dataFormatada = "";
    if (f['criado_em'] != null) {
      DateTime data = DateTime.parse(f['criado_em']);
      dataFormatada = "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}";
    }


    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📷 FOTO OU PLACEHOLDER
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: placeholderColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: f['foto_url'] != null && f['foto_url'].toString().isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(f['foto_url'], fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hide_image_outlined, color: Colors.grey.shade400, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        "SEM IMAGEM",
                        style: TextStyle(fontSize: 8, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 16),
          // 📄 DADOS DO RELATO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f['titulo'] ?? 'Sem título',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryBlueTitle),
                ),
                const SizedBox(height: 6),
                Text(
                  f['descricao'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.3),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      "Data: $dataFormatada",
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return MainLayout(
      cargo: widget.cargo,
      nome: widget.nome,
      titulo: "Reportar Problema",
      autorId: widget.autorId,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Stack(
            children: [
              // ================= CONTEÚDO DAS ABAS =================
              Positioned.fill(
                bottom: 80, // Espaço para a aba inferior customizada
                child: abaSelecionada == "adicionar"
                    // ABA ADICIONAR
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Evidência Visual",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            // Botão Tirar Foto com Borda Tracejada
                            GestureDetector(
                              onTap: tirarFoto,
                              child: CustomPaint(
                                painter: DashedRectPainter(color: Colors.grey.shade400, strokeWidth: 1.5, gap: 5.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
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
                                              ),
                                              child: const Icon(Icons.camera_alt_outlined, size: 32, color: Colors.black87),
                                            ),
                                            const SizedBox(height: 12),
                                            const Text("Tirar Foto", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                          ],
                                        )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Image.file(
                                            File(imagemSelecionada!.path),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),


                            // Formulário
                            campoPersonalizado("Título do Problema", "Ex: Pneu furado, Atraso na carga...", tituloCtrl),
                            campoPersonalizado("Descrição do Problema", "Descreva detalhadamente o ocorrido...", descricaoCtrl, maxLines: 4),


                            const SizedBox(height: 8),


                          SizedBox(
                              width: double.infinity,
                              height: 56,
                              // SOLUÇÃO: Aqui o ElevatedButton não estava dentro de um Row pelo que vi, o problema deveria estar no _cardRelato (onde a lista é exibida)
                              child: ElevatedButton.icon(
                                onPressed: isLoading ? null : salvarRelato,
                                icon: isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.save_outlined, color: Colors.white),
                                label: Text(
                                  isLoading ? "Salvando..." : "Salvar Relato",
                                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                                  // SOLUÇÃO: Limitar o overflow no botão também, por segurança
                                  overflow: TextOverflow.ellipsis, 
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryDarkBlue,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 60), // Espaço pro FAB não cobrir o botão
                          ],
                        ),
                      )
                    // ABA VISUALIZAR
                    : relatos.isEmpty
                        ? Center(child: Text("Nenhum relato encontrado.", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24).copyWith(bottom: 100),
                            itemCount: relatos.length,
                            itemBuilder: (_, i) => cardRelato(relatos[i]),
                          ),
              ),


              // ================= FAB (ROBÔ/BRILHO) =================
             


              // ================= BARRA INFERIOR (TABS) =================
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 85,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      abaPersonalizada("Adicionar", Icons.add_circle_outline, "adicionar"),
                      abaPersonalizada("Visualizar", Icons.history, "visualizar"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ==========================================
// PAINTER PARA CRIAR A BORDA TRACEJADA FIEL
// ==========================================
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;


  DashedRectPainter({required this.color, required this.strokeWidth, required this.gap});


  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;


    final Path path = Path();
    final double radius = 16.0;


    // Retângulo base arredondado
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(radius)));


    // Efeito Tracejado
    Path dashPath = Path();
    double distance = 0.0;
    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(pathMetric.extractPath(distance, distance + gap), Offset.zero);
        distance += gap * 2;
      }
      distance = 0.0;
    }


    canvas.drawPath(dashPath, paint);
  }


  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

