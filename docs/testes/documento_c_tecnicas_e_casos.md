# Documento C — Técnicas e Casos de Teste  
Projeto: App Mobile (Gestão de Entregas)  
Tecnologia: Flutter  
Norma aplicada: ISO/IEC/IEEE 29119-4  

## 1. Técnicas Utilizadas  
- Particionamento de Equivalência  
- Valor Limite  
- Teste baseado em cenário  
- Transição de estado  

---

## 2. Casos de Teste (12)

### TC01 — Login com e-mail inválido  
Técnica: Particionamento  
Entrada: email = "usuarioemail.com"  
Resultado esperado: SnackBar "e-mail válido"  

### TC02 — Login com senha vazia  
Técnica: Valor Limite  
Entrada: email válido, senha vazia  
Resultado esperado: SnackBar "senha não pode estar vazia"

### TC03 — Alternar visibilidade da senha  
Técnica: Transição de estado  
Entrada: clique no ícone olho  
Resultado esperado: ícone muda para visibilidade_off  

### TC04 — Permissão de localização negada  
Técnica: Particionamento  
Entrada: LocationPermission.denied  
Resultado esperado: obterLocalizacaoAtual() retorna null  

### TC05 — Permissão concedida retorna posição  
Técnica: Particionamento  
Entrada: LocationPermission.always  
Resultado esperado: obterLocalizacaoAtual() retorna Position  

### TC06 — Geocoding com retorno válido  
Técnica: Particionamento  
Entrada: placemark válido  
Resultado esperado: mapa com rua/bairro/cep/cidade  

### TC07 — Geocoding vazio  
Técnica: Valor Limite  
Entrada: lista vazia  
Resultado esperado: retornos com "-"  

### TC08 — Geocoding com erro  
Técnica: Exceção  
Entrada: exception no channel  
Resultado esperado: retornos com "-"  

### TC09 — UserModel.fromJson mapeia id/cargo  
Técnica: Particionamento  
Entrada: json válido  
Resultado esperado: id e cargo corretos  

### TC10 — UserModel.fromJson mapeia senha_hash  
Técnica: Particionamento  
Entrada: json válido  
Resultado esperado: senhaHash igual ao json  

### TC11 — ParadaModel (Criar) armazena dados  
Técnica: Particionamento  
Entrada: ordem, cidade, uf, valor  
Resultado esperado: campos com valores corretos  

### TC12 — ParadaModel (Editar) mantém status e campos  
Técnica: Particionamento  
Entrada: status = concluido, assinou_nome, cpf  
Resultado esperado: valores mantidos e status correto  
