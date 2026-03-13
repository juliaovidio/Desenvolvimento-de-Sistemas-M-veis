Caso de Uso: Atualizar localização da rota
Ator: Motorista
Objetivo: Informar ao gerente a localização atual durante a entrega.

Pré-condições:

O motorista deve estar logado no aplicativo.

O motorista deve ter permitido o acesso à localização no dispositivo.

A rota deve estar atribuída ao motorista.

Pós-condições:

A localização atual do motorista é enviada ao sistema.

O gerente consegue visualizar a atualização da rota.

Fluxo Principal:

O motorista acessa o aplicativo.

O sistema verifica se a permissão de localização está ativa.

O motorista pressiona o botão de atualizar localização.

O sistema coleta a localização atual do motorista.

O sistema envia a localização para o gerente.

O sistema registra a atualização no histórico de atividades.

Fluxos Alternativos:

A1) Permissão de localização negada

O sistema solicita novamente a permissão de localização ao motorista.

Caso o motorista não autorize, a atualização não poderá ser realizada.

A2) Falha na conexão

O sistema tenta reenviar a localização automaticamente quando a conexão for restabelecida.

Regras de Negócio:

RN02 – Atualização de Status

Requisitos Relacionados:

RF01 – Permissão de localidade

RF02 – Compartilhamento de Conteúdo

RNF02 – Desempenho
