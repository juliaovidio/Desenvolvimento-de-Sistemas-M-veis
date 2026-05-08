import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiService {
  static const String apiKey = 'AIzaSyCQ77Yq-jgj1tMlloYDcZMQwNrhP9cp3W4';
  static const String apiUrl =
       'https://generativelanguage.googleapis.com/v1beta/models/gemini-latest:generateContent?key=$apiKey';

  // ==========================================
  // ENVIAR PERGUNTA PARA GEMINI
  // ==========================================
  static Future<String> enviarPergunta(String pergunta) async {
    try {
      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': pergunta}
            ]
          }
        ]
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Timeout ao conectar com Gemini'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Verificar se foi bloqueado por segurança
        if (jsonResponse['candidates'] != null &&
            jsonResponse['candidates'].isNotEmpty) {
          final candidate = jsonResponse['candidates'][0];

          if (candidate['finishReason'] == 'SAFETY') {
            String motivo = 'Resposta bloqueada por segurança:\n';

            if (candidate['safetyRatings'] != null) {
              for (var safety in candidate['safetyRatings']) {
                if (safety['probability'] != 'NEGLIGIBLE') {
                  motivo +=
                      '- ${safety['category']}: ${safety['probability']}\n';
                }
              }
            }

            return motivo;
          }

          // Extrair resposta
          if (candidate['content'] != null &&
              candidate['content']['parts'] != null &&
              candidate['content']['parts'].isNotEmpty) {
            return candidate['content']['parts'][0]['text'] ?? 'Sem resposta';
          }
        }

        return 'Nenhuma resposta foi gerada. Verifique se não há conteúdo abusivo ou censurado e tente novamente.';
      } else if (response.statusCode == 429) {
        return 'Limite de requisições atingido. Tente novamente em alguns momentos.';
      } else {
        return 'Erro ao conectar com Gemini: ${response.statusCode}';
      }
    } catch (e) {
      return 'Erro ao processar: $e';
    }
  }
}