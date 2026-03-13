Caso de Uso: Confirmar entrega de produto
Ator: Motorista
Objetivo: Registrar que um produto foi entregue ao destinatário.

Pré-condições:

A rota deve estar em andamento.

O motorista deve estar autenticado no aplicativo.

O produto deve estar vinculado à rota.

Pós-condições:

A entrega do produto é registrada no sistema.

O gerente consegue visualizar que a entrega foi concluída.

Fluxo Principal:

O motorista acessa a lista de entregas da rota.

O motorista seleciona o produto entregue.

O motorista confirma a entrega no aplicativo.

O sistema registra a confirmação da entrega.

O sistema atualiza o histórico da rota.

Fluxos Alternativos:

A1) Problema na entrega

O motorista registra um problema no sistema.

O sistema registra automaticamente a data, horário e localização do ocorrido.

A2) Falha na atualização

O sistema salva temporariamente a informação e sincroniza quando houver conexão.

Regras de Negócio:

RN02 – Atualização de Status

RN03 – Registro de Problemas

Requisitos Relacionados:

RF03 – Histórico de Atividades

RNF01 – Segurança da Informação

RNF02 – Desempenho
