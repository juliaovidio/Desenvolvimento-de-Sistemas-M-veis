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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

    try {
      final resposta = await GeminiService.enviarPergunta(pergunta);

      setState(() {
        _messages.add({
          'tipo': 'ia',
          'texto': resposta,
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'tipo': 'ia',
          'texto': 'Erro: $e',
        });
        _isLoading = false;
      });
    }
  }

  // ==========================================
  // INTERFACE
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _mostrarChat(context),
      backgroundColor: Colors.blue[600],
      child: const Icon(Icons.chat_bubble_outline),
    );
  }

  // ==========================================
  // MODAL DO CHAT
  // ==========================================
  void _mostrarChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // 🎯 Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: const BorderRadius.only(
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
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // 💬 Mensagens
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
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isUser = msg['tipo'] == 'usuario';

                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Colors.blue[600]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.8,
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

              // ⏳ Carregando
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(Colors.blue[600]),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Digitando...'),
                    ],
                  ),
                ),

              // 📝 Input
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Digite sua pergunta...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        maxLines: null,
                        onSubmitted: (_) => _enviarMensagem(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      mini: true,
                      onPressed: _isLoading ? null : _enviarMensagem,
                      backgroundColor:
                          _isLoading ? Colors.grey : Colors.blue[600],
                      child: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}