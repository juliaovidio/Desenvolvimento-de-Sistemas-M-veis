# App Mobile - Flutter

Aplicação móvel multiplataforma desenvolvida com **Flutter** e **Dart**.

## 🎯 Características

- 🔐 Autenticação com Supabase
- 📸 Processamento de imagens (câmera e galeria)
- 🗺️ Geolocalização e Google Maps
- 🤖 Integração com IA Generativa
- ✅ Validação avançada de formulários
- 🔍 Busca inteligente com sugestões

## 🚀 Instalação

### Pré-requisitos
- Flutter SDK 3.11.0+
- Dart 3.11.0+
- Git
- Android Studio / Xcode (para emuladores)

### Passo a Passo

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
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d web
```

## 📁 Estrutura

```
lib/
├── main.dart
├── screens/
├── models/
├── services/
├── widgets/
└── utils/
```

## 📦 Build

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 🤝 Contribuir

1. Faça um Fork
2. Crie sua branch (`git checkout -b feature/nova-feature`)
3. Commit (`git commit -m 'Add nova-feature'`)
4. Push (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 👨‍💻 Autores

- **Júlia Ovídio** - [@juliaovidio](https://github.com/juliaovidio)
- **Júlia Docema**
