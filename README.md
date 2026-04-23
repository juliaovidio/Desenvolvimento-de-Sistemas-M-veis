# 🚚 Sistema de Gestão para Transportadora

Aplicação mobile desenvolvida para otimizar o controle operacional de rotas, motoristas, veículos e acompanhamento de entregas em tempo real.

## 📋 Visão Geral

O sistema oferece dois perfis de acesso principais:
- **Motorista**: Acompanhamento de rotas, atualização de localização e reporte de ocorrências
- **Gerente**: Gestão operacional, monitoramento em tempo real e relatórios

## 🎯 Objetivos Principais

- Centralizar o controle logístico de rotas e entregas
- Permitir acompanhamento em tempo real das operações
- Facilitar comunicação entre motorista e gerente
- Registrar e organizar informações operacionais

## ✨ Funcionalidades

| Gerente | Motorista |
|---------|-----------|
| Cadastro de motoristas e veículos | Login seguro |
| Criação e atribuição de rotas | Acompanhamento de rota ativa |
| Monitoramento em tempo real | Atualização de localização |
| Dashboard operacional | Reporte de problemas |
| Relatórios de atividades | Histórico de entregas |

## 🛠️ Tecnologias

- **Frontend**: React Native / Flutter
- **Backend**: Node.js / Python
- **Banco de Dados**: Supabase
- **Autenticação**: Sistema seguro com controle de acesso por perfil

## 🚀 Como Começar

### Requisitos
- Node.js v16+ (ou Python 3.8+)
- Supabase (configurado)
- Git

### Instalação

```bash
# Clone o repositório
git clone https://github.com/juliaovidio/Desenvolvimento-de-Sistemas-M-veis.git

# Instale as dependências
npm install
# ou
pip install -r requirements.txt

# Configure as variáveis de ambiente
cp .env.example .env

# Inicie a aplicação
npm start
# ou
python app.py
```

## 🔐 Segurança

- Autenticação por perfil de usuário
- Controle de acesso por funcionalidade
- Proteção de dados sensíveis
- Registro de atividades no sistema

## 📊 Fluxo Básico

1. Gerente cadastra motoristas, veículos e cria rotas
2. Motorista acessa o sistema e inicia a rota
3. Sistema rastreia localização em tempo real
4. Motorista pode atualizar status e reportar problemas
5. Gerente acompanha tudo pelo dashboard
6. Histórico fica registrado para análise

## 📁 Estrutura do Projeto

```
├── docs/                 # Documentação
├── src/                  # Código fonte
│   ├── components/       # Componentes reutilizáveis
│   ├── screens/          # Telas da aplicação
│   ├── services/         # Serviços e APIs
│   └── utils/            # Utilitários
├── package.json          # Dependências
└── README.md             # Este arquivo
```

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📝 Licença

Este projeto está sob licença MIT. Veja o arquivo LICENSE para mais detalhes.

## 📧 Contato

**Desenvolvedor**: Júlia Ovídio  
**Email**: [seu-email@example.com](mailto:seu-email@example.com)  
**GitHub**: [@juliaovidio](https://github.com/juliaovidio)

---

**Última atualização**: Abril de 2026
