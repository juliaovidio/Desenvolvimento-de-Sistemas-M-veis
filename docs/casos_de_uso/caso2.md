Caso de Uso: Iniciar rota de entrega
Ator: Motorista
Objetivo: Iniciar uma rota previamente atribuída para realizar entregas.

Pré-condições:

O motorista deve estar autenticado no sistema.

A rota deve estar vinculada ao motorista e ao veículo.

A rota deve estar disponível para início.

Pós-condições:

A rota passa para o status "Em andamento".

O gerente consegue acompanhar o progresso da rota.

Fluxo Principal:

O motorista acessa o aplicativo.

O motorista visualiza a rota atribuída.

O motorista seleciona a opção "Iniciar rota".

O sistema altera o status da rota para "Em andamento".

O sistema registra o início da rota no histórico de atividades.

Fluxos Alternativos:

A1) Rota não atribuída ao motorista

O sistema impede o início da rota.

O sistema exibe uma mensagem informando que a rota não está vinculada ao motorista.

A2) Veículo não ativo

O sistema bloqueia o início da rota e informa o problema ao motorista.

Regras de Negócio:

RN01 – Vinculação de Rotas

RN02 – Atualização de Status

Requisitos Relacionados:

RF03 – Histórico de Atividades

RNF01 – Segurança da Informação

RNF03 – Disponibilidade
