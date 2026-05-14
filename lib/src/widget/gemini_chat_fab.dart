import 'package:app_mobile/core/service/gemini_service.dart';
import 'package:flutter/material.dart';

class GeminiChatFAB extends StatefulWidget {
  const GeminiChatFAB({Key? key}) : super(key: key);

  @override
  State<GeminiChatFAB> createState() => _GeminiChatFABState();
}

class _GeminiChatFABState extends State<GeminiChatFAB> {
  late TextEditingController _controller;
  List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool _chatAberto = false;
  
  // 🎯 Posição do FAB arrastável - CANTO INFERIOR DIREITO
  late Offset _fabPosition;
  
  // 🎯 ScrollController para auto-scroll
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController();
    
    // Define a posição inicial no canto inferior direito após a primeira build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        _fabPosition = Offset(
          screenSize.width - 70, // 70 = tamanho do FAB + margem
          screenSize.height - 100, // 100 = margem do bottom
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ==========================================
  // SCROLL AUTOMÁTICO PARA ÚLTIMA MENSAGEM
  // ==========================================
  void _scrollParaUltima() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ==========================================
  // ENVIAR MENSAGEM
  // ==========================================
  Future<void> _enviarMensagem() async {
    if (_controller.text.isEmpty) return;

    String pergunta = _controller.text;
    _controller.clear();

    setState(() {
      _messages.add({
        'tipo': 'usuario',
        'texto': pergunta,
      });
      _isLoading = true;
    });

    _scrollParaUltima();

    try {
      final resposta = await GeminiService.enviarPergunta(pergunta);

      setState(() {
        _messages.add({
          'tipo': 'ia',
          'texto': resposta,
        });
        _isLoading = false;
      });

      _scrollParaUltima();
    } catch (e) {
      setState(() {
        _messages.add({
          'tipo': 'ia',
          'texto': 'Erro: $e',
        });
        _isLoading = false;
      });

      _scrollParaUltima();
    }
  }

  // ==========================================
  // INTERFACE
  // ==========================================
@override
Widget build(BuildContext context) {
  return Stack(
    children: [
      Positioned(
        left: _fabPosition.dx,
        top: _fabPosition.dy,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _fabPosition = Offset(
                _fabPosition.dx + details.delta.dx,
                _fabPosition.dy + details.delta.dy,
              );
            });
          },
          onTap: () => _mostrarChat(context), // 👈 junta tudo aqui
          child: Material(
            elevation: 0,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: 60,
              height: 60,
              child: Image.asset(
                'assets/images/gemini.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

  // ==========================================
  // MODAL DO CHAT
  // ==========================================
  void _mostrarChat(BuildContext context) {
    _chatAberto = true;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          _chatAberto = false;
          return true;
        },
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // 🎯 HEADER
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Assistente IA',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () {
                          _chatAberto = false;
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),

                // 💬 MENSAGENS
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Text(
                            'Olá! 👋\nComo posso ajudá-lo?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length + (_isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Indicador de carregamento
                            if (index == _messages.length) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F0F0),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: const AlwaysStoppedAnimation(
                                            Color(0xFF4A90E2),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Digitando...',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final msg = _messages[index];
                            final isUser = msg['tipo'] == 'usuario';

                            return Align(
                              alignment: isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? const Color(0xFF4A90E2)
                                      : const Color(0xFFF0F0F0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75,
                                ),
                                child: Text(
                                  msg['texto']!,
                                  style: TextStyle(
                                    color: isUser ? Colors.white : Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // 📝 INPUT - FIXO NO BOTTOM COM KEYBOARD AWARE
                AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Digite sua pergunta...',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(
                                  color: Color(0xFFCCCCCC),
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(
                                  color: Color(0xFFCCCCCC),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(
                                  color: Color(0xFF4A90E2),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFFAFAFA),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                            minLines: 1,
                            onSubmitted: (_) => _enviarMensagem(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FloatingActionButton(
                          mini: true,
                          onPressed: _isLoading ? null : _enviarMensagem,
                          backgroundColor: _isLoading
                              ? Colors.grey[400]
                              : const Color(0xFF4A90E2),
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      _chatAberto = false;
    });
  }
}