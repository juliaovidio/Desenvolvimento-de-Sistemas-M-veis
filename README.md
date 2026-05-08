# App Mobile - Sistema de Desenvolvimento Móvel

[![Flutter](https://img.shields.io/badge/Flutter-3.11+-blue?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.11+-1f425f?logo=dart)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Active-success)](https://github.com/juliaovidio/Desenvolvimento-de-Sistemas-M-veis)

Aplicação móvel multiplataforma desenvolvida com **Flutter** e **Dart**, offering robust features for mobile systems development with real-time capabilities, geolocation, and AI integration.

## 📋 Visão Geral

Este projeto é uma aplicação mobile completa que demonstra as melhores práticas de desenvolvimento Flutter, incluindo autenticação, validação de dados, processamento de imagens, geolocalização e integração com APIs modernas.

### ✨ Características Principais

- 🔐 **Autenticação Segura** - Integração com Supabase para gerenciamento de usuários
- 📸 **Processamento de Imagens** - Captura e seleção de fotos com tratamento de permissões
- ✅ **Validação Avançada** - Validação de formulários com feedback em tempo real
- 📍 **Geolocalização** - Localização GPS com mapas interativos
- 🗺️ **Mapas** - Integração com Google Maps e Flutter Map
- 🤖 **IA Generativa** - Suporte a Google Generative AI
- 🔍 **Busca Inteligente** - Typeahead com sugestões automáticas
- 🌐 **Requisições HTTP** - Comunicação eficiente com APIs REST

## 🛠️ Stack Tecnológico

### Dependências Principais

| Tecnologia | Versão | Propósito |
|-----------|--------|----------|
| **Flutter** | 3.11+ | Framework principal |
| **Dart** | 3.11+ | Linguagem de programação |
| **Supabase Flutter** | 2.12.2 | Backend e autenticação |
| **Google Maps Flutter** | 2.4.0 | Mapas interativos |
| **Image Picker** | 1.0.7 | Seleção de imagens |
| **Permission Handler** | 11.3.0 | Gerenciamento de permissões |
| **Geolocator** | 9.0.2 | Serviços de localização |
| **BCrypt** | 1.1.3 | Criptografia de senhas |
| **Google Generative AI** | 0.4.7 | Integração com IA |
| **Flutter TypeAhead** | 6.0.0 | Busca com sugestões |

### Linguagens Utilizadas

- **Dart**: 92.6% - Lógica principal da aplicação
- **C++**: 4.3% - Código nativo para performance crítica
- **CMake**: 2.5% - Build configuration
- **Outros**: 0.6%

## 🚀 Começando

### Pré-requisitos

- Flutter SDK 3.11.0 ou superior
- Dart 3.11.0 ou superior
- Git
- Android Studio / Xcode (para emuladores)
- Chaves de API (Google Maps, Supabase)

### Instalação

1. **Clone o repositório**
```bash
git clone https://github.com/juliaovidio/Desenvolvimento-de-Sistemas-M-veis.git
cd Desenvolvimento-de-Sistemas-M-veis
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Configure as variáveis de ambiente**
   - Configure as credenciais do Supabase
   - Configure a chave da API do Google Maps
   - Configure as credenciais do Google Generative AI

4. **Execute a aplicação**
```bash
# Para Android
flutter run -d android

# Para iOS
flutter run -d ios

# Para Web
flutter run -d web
```

## 📁 Estrutura do Projeto

```
lib/
├── main.dart              # Ponto de entrada da aplicação
├── screens/               # Telas da aplicação
├── models/                # Modelos de dados
├── services/              # Serviços (API, autenticação, etc)
├── widgets/               # Componentes reutilizáveis
└── utils/                 # Utilitários e funções auxiliares

assets/
└── images/                # Recursos de imagens

android/                   # Código específico para Android
ios/                       # Código específico para iOS
windows/                   # Código específico para Windows
```

## 🔧 Funcionalidades Implementadas

### 🔐 Autenticação e Segurança
- Login e registro com validação
- Hash de senhas com BCrypt
- Gerenciamento de sessão com Supabase

### 📸 Mídia
- Seleção de fotos da galeria
- Captura de fotos com câmera
- Requisição de permissões dinâmicas

### 🗺️ Localização e Mapas
- Obtenção de coordenadas GPS em tempo real
- Integração com Google Maps
- Mapa alternativo com Flutter Map
- Geocodificação e reversa geocodificação

### 🤖 Inteligência Artificial
- Integração com Google Generative AI
- Processamento de requisições com IA

### 📝 Validação e Formulários
- Validação avançada de entrada
- Feedback em tempo real para usuários
- Sugestões automáticas com TypeAhead

## 🧪 Testes e Qualidade

Para executar os testes:

```bash
# Testes de unidade
flutter test

# Testes com cobertura
flutter test --coverage

# Análise de código
flutter analyze
```

## 📦 Build e Distribuição

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Faça um Fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### Diretrizes de Contribuição

- Siga o estilo de código Flutter oficial
- Adicione testes para novas funcionalidades
- Atualize a documentação conforme necessário
- Mantenha a compatibilidade com versões anteriores

## 📚 Documentação Útil

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [Supabase Flutter](https://supabase.com/docs/reference/dart)
- [Google Maps Flutter](https://developers.google.com/maps/documentation/flutter)
- [Google Generative AI](https://ai.google.dev/)

## 🐛 Conhecidos Problemas e Soluções

### Problema: Erro ao compilar para iOS
**Solução**: Execute `flutter clean` e `flutter pub get` novamente

### Problema: Permissões não funcionam
**Solução**: Verifique as configurações de permissão no `AndroidManifest.xml` e `Info.plist`

### Problema: Google Maps não carrega
**Solução**: Verifique se a chave de API está configurada corretamente no projeto Android e iOS

## 📊 Estatísticas do Projeto

- **Criado**: 26 de Fevereiro de 2026
- **Últimas atualizações**: 8 de Maio de 2026
- **Issues abertos**: 6
- **Forks**: 2
- **Tamanho**: 451 KB

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👨‍💻 Autor

**Júlia Ovídio**
- GitHub: [@juliaovidio](https://github.com/juliaovidio)
- Repositório: [Desenvolvimento-de-Sistemas-M-veis](https://github.com/juliaovidio/Desenvolvimento-de-Sistemas-M-veis)

## 🙏 Agradecimentos

- Flutter community por ferramentas excelentes
- Supabase pelo backend-as-a-service
- Google Cloud por mapas e IA
- Comunidade open-source

## ✉️ Suporte e Contato

Para questões, sugestões ou problemas:

1. Abra uma [Issue](https://github.com/juliaovidio/Desenvolvimento-de-Sistemas-M-veis/issues)
2. Envie um Pull Request
3. Consulte a documentação do projeto

---

<div align="center">

⭐️ Se este projeto foi útil, considere deixar uma estrela!

Made with ❤️ by [@juliaovidio](https://github.com/juliaovidio)

</div>
