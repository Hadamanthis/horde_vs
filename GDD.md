# GDD — “Horda Reversa”

## 1. Visão geral

**Título provisório:** Horda Reversa
**Gênero:** Survivor-like 2D / ação top-down
**Engine:** Godot 4.6
**Plataforma inicial:** PC / Web via itch.io
**Plataforma futura:** Mobile/celular, depois que o loop principal estiver validado
**Duração de uma partida:** 8 a 12 minutos
**Público-alvo:** jogadores de survivor-like, roguelite casual, jogos curtos de itch.io e game jams.

## 2. Frase de venda

Um survivor-like onde cada inimigo derrotado pode virar parte do seu exército.

## 3. Conceito central

O jogador controla um personagem fraco cercado por monstros. Ao derrotar inimigos, alguns deles são convertidos em aliados. Esses aliados seguem o jogador em formação, orbitam ao redor dele ou atacam automaticamente.

A graça do jogo está em transformar a ameaça em poder. Quanto mais inimigos o jogador derrota, maior e mais caótica fica sua horda.

## 4. Fantasia do jogador

O jogador deve sentir que começou vulnerável, fugindo de monstros, mas aos poucos virou o centro de uma horda crescente. O prazer principal é ver os inimigos que antes ameaçavam o jogador se juntando a ele e destruindo ondas cada vez maiores.

### 4.1 Identidade do protagonista

A direção recomendada para a versão itch.io é que o jogador seja um pequeno **Overlord Necromante**, ainda fraco, tentando reconstruir sua horda.

Visualmente, ele pode ser:

* uma cabeça de caveira flutuante com manto curto;
* olhos/energia verde ou ciano;
* corpo pequeno para parecer vulnerável no começo;
* silhueta simples e muito legível em top-down.

Essa opção conversa bem com a mecânica de converter monstros, com o tema de cemitério/ruínas e com a fantasia de virar o centro de um exército. Evitar por enquanto um humano detalhado, porque exigiria animações mais complexas e poderia disputar leitura com os aliados.

Nome de fantasia possível: **O Pequeno Overlord**.

## 5. Pilares de design

### 5.1 Transformar perigo em recurso

Inimigos não são apenas obstáculos. Eles são matéria-prima para o exército do jogador.

### 5.2 Crescimento visual claro

A evolução do jogador precisa ser visível na tela. No começo, ele anda sozinho. Depois, vários aliados cercam o personagem.

### 5.3 Mecânica simples, decisões rápidas

O jogador deve entender o básico em poucos segundos: andar, sobreviver, matar, converter, escolher upgrades.

### 5.4 Escopo pequeno e polido

O jogo deve ser curto, fechado e jogável do começo ao fim. Melhor ter pouco conteúdo bem ajustado do que vários sistemas incompletos.

## 6. Loop principal

1. O jogador se move pelo mapa.
2. Inimigos aparecem em ondas.
3. O jogador causa dano automaticamente.
4. Inimigos derrotados têm chance de virar aliados.
5. Aliados seguem o jogador e atacam inimigos.
6. O jogador coleta experiência.
7. Ao subir de nível, escolhe um upgrade.
8. A horda cresce.
9. A dificuldade aumenta.
10. Um chefe aparece no final.
11. O jogador vence se sobreviver até derrotar o chefe.

## 7. Controles

### PC

* WASD ou setas: mover personagem.
* Mouse: opcional, apenas para menus.
* Enter/Espaço: confirmar escolha.
* Esc: pausar.

### Observação

O jogo não deve exigir mira manual no MVP. O ataque deve ser automático para reduzir complexidade.

## 8. Câmera

Câmera top-down seguindo o jogador.
Zoom relativamente afastado para mostrar inimigos e aliados.
A câmera não precisa de efeitos complexos no MVP, mas pode ter leve shake ao derrotar inimigos fortes ou ao chefe aparecer.

## 9. Personagem principal

### 9.1 Nome provisório

“O Necromante Iniciante”

### 9.2 Função

Personagem controlável pelo jogador. Começa fraco e depende dos aliados para crescer.

### 9.3 Atributos

* Vida máxima
* Velocidade
* Dano base
* Taxa de ataque
* Alcance de conversão
* Limite de aliados
* Chance de conversão

### 9.4 Estado inicial sugerido

* Vida: 100
* Velocidade: 140
* Dano base: 8
* Taxa de ataque: 1 ataque por segundo
* Limite inicial de aliados: 5
* Chance inicial de conversão: 20%

## 10. Sistema de ataque do jogador

No MVP, o jogador possui um ataque automático simples.

### Ataque inicial: Orbe Sombrio

A cada intervalo, o personagem dispara automaticamente um projétil contra o inimigo mais próximo.

Características:

* mira automática;
* dano baixo;
* alcance médio;
* visual simples;
* fácil de implementar.

### Melhorias possíveis

* mais projéteis;
* maior dano;
* menor tempo entre ataques;
* projéteis atravessam inimigos;
* projéteis ricocheteiam.

## 11. Sistema de conversão

Esse é o sistema principal do jogo.

Quando um inimigo morre, existe uma chance de ele deixar uma essência de captura.

No protótipo atual, a conversão pode acontecer automaticamente ao derrotar o inimigo. Para a direção final do MVP, a recomendação é transformar a conversão em um drop opcional: o jogador precisa coletar a essência para adicionar aquele inimigo à horda.

Isso dá mais controle sobre a composição da run. O jogador pode ignorar uma captura que não combina com sua build atual, evitando a sensação de ficar à mercê de conversões indesejadas.

### Regras

* Apenas inimigos comuns podem ser convertidos no MVP.
* Chefes não podem ser convertidos.
* Ao morrer, um inimigo conversível pode deixar uma essência de captura daquele tipo.
* Se o jogador coletar a essência, ela vira um aliado equivalente ao inimigo de origem.
* Se o jogador ignorar a essência, ela desaparece depois de alguns segundos.
* Se o jogador atingiu o limite de aliados, a essência pode continuar no chão por um curto tempo, mas não pode ser coletada até haver espaço.
* A chance de uma essência aparecer pode aumentar com upgrades.
* Inimigos convertidos mantêm uma versão simplificada de sua habilidade original.
* O drop de captura deve ser visualmente diferente do XP para evitar coleta acidental.

### Exemplo

Um slime inimigo anda até o jogador e causa dano por contato.
Quando derrotado, pode deixar uma essência de slime. Se o jogador coletar essa essência, ela vira um slime aliado que segue o jogador e bate em inimigos próximos.

## 12. Sistema de aliados

Aliados são monstros convertidos que ajudam o jogador automaticamente.

### Comportamento base

Cada aliado deve:

1. seguir o jogador;
2. manter uma distância mínima dos outros aliados;
3. procurar inimigos próximos;
4. atacar automaticamente;
5. retornar para perto do jogador se ficar longe demais.

### Formações possíveis

Para o MVP, usar uma das opções:

### Opção A — Seguidores em bando

Aliados seguem o jogador com comportamento simples de steering.
Mais orgânico, mas pode ficar caótico.

### Opção B — Órbita ao redor do jogador

Aliados ficam girando em torno do personagem.
Mais fácil de controlar visualmente.

### Recomendação

Começar com órbita. É mais simples, mais legível e mais bonito em GIF.

## 13. Tipos de aliados

No MVP, usar poucos tipos.

### 13.1 Slime aliado

Origem: Slime inimigo
Função: corpo a corpo básico
Ataque: encosta em inimigos e causa dano
Personalidade: fraco, numeroso, descartável

### 13.2 Morcego aliado

Origem: Morcego inimigo
Função: atacante rápido
Ataque: avança rapidamente contra inimigos próximos
Personalidade: veloz, mas frágil

### 13.3 Caveira arqueira aliada

Origem: Caveira arqueira inimiga
Função: ataque à distância
Ataque: dispara projéteis lentos
Personalidade: frágil, mas útil contra hordas

### 13.4 Golem pequeno aliado

Origem: Golem inimigo
Função: tanque
Ataque: lento, mas forte
Personalidade: ocupa espaço e protege o jogador

## 14. Inimigos

### 14.1 Slime

Inimigo mais básico.

* Movimento: anda diretamente até o jogador.
* Vida: baixa.
* Dano: baixo.
* Velocidade: baixa.
* Conversível: sim.

Função no jogo: ensinar o loop.

### 14.2 Morcego

Inimigo rápido.

* Movimento: persegue o jogador em linha reta.
* Vida: baixa.
* Dano: baixo.
* Velocidade: alta.
* Conversível: sim.

Função no jogo: pressionar movimento.

### 14.3 Caveira arqueira

Inimigo à distância.

* Movimento: mantém distância.
* Ataque: projétil.
* Vida: média.
* Dano: médio.
* Conversível: sim.

Função no jogo: forçar o jogador a se mover.

### 14.4 Golem pequeno

Inimigo resistente.

* Movimento: lento.
* Vida: alta.
* Dano: alto.
* Conversível: sim.

Função no jogo: criar obstáculos vivos.

### 14.5 Chefe final: Paladino da Luz

Inimigo especial que aparece no final.

* Movimento: persegue lentamente.
* Ataque 1: investida.
* Ataque 2: onda circular.
* Ataque 3: invoca inimigos comuns.
* Conversível: não.

Função no jogo: testar a horda criada pelo jogador.

## 15. Progressão da partida

A partida deve ser curta e escalável.

### Estrutura sugerida de 10 minutos

#### 0:00 – 1:00

Apenas slimes.
Objetivo: ensinar movimento, ataque automático e conversão.

#### 1:00 – 3:00

Slimes e morcegos.
Objetivo: aumentar pressão.

#### 3:00 – 5:00

Entrada das caveiras arqueiras.
Objetivo: forçar desvio de projéteis.

#### 5:00 – 7:00

Entrada dos golems.
Objetivo: criar inimigos resistentes.

#### 7:00 – 9:00

Mistura intensa de todos os inimigos.
Objetivo: testar build do jogador.

#### 9:00 – 10:00

Chefe final aparece.
Objetivo: sobreviver e derrotar o chefe.

## 16. Sistema de experiência e nível

Inimigos derrotados deixam cristais de experiência.

O jogador coleta cristais ao se aproximar.

## 16.1 Pickups de partida

Além de XP e essências de captura, inimigos podem deixar pickups raros que ajudam a run sem virar um sistema grande.

### Pickup de vida

Recupera uma quantidade fixa de vida do jogador.

Regras iniciais:

* Deve ser visualmente diferente de XP e essência de captura.
* Deve curar sem ultrapassar a vida máxima.
* Pode dropar mesmo se o jogador estiver com vida cheia, mas nesse caso tem pouco valor.

### Ímã de almas

Coleta todos os cristais de XP espalhados pelo mapa.

Regras iniciais:

* Deve afetar XP, não essências de captura. Essências continuam sendo uma escolha de composição.
* Pode ser instantâneo no protótipo.
* No futuro, pode puxar os cristais visualmente até o jogador para dar mais satisfação.

Ao subir de nível, aparecem 3 opções de upgrade.

### Regras

* O jogo pausa durante a escolha.
* O jogador escolhe 1 upgrade.
* Upgrades podem ser comuns, raros ou lendários.
* No MVP, não precisa mostrar raridade visual complexa.

## 17. Upgrades e builds de run

Os upgrades devem ajudar o jogador a montar uma identidade para a run sem depender de cartas específicas demais para cada criatura.

A preferência é usar upgrades genéricos que interagem com sistemas amplos: ataque, cooldown, quantidade de aliados, tipos repetidos, nível dos aliados, coleta e captura.

### 17.1 Upgrades do jogador

* +10% velocidade
* +15% dano do orbe
* +10% velocidade de ataque
* +1 projétil
* +20 vida máxima
* +10% alcance de coleta

### 17.2 Upgrades de horda

Esses upgrades devem afetar muitos aliados ao mesmo tempo e formar a base das builds.

* aliados causam +10% dano
* aliados reduzem todos os cooldowns de ataque em 10%
* aliados recebem +20% vida
* +3 limite de aliados
* +10% chance de essência de captura aparecer
* +10% duração de efeitos criados por aliados, como aura, rastro e bloqueio
* +10% alcance de ataque dos aliados
* aliados causam +5% dano para cada cópia adicional do mesmo tipo na horda. Um aliado sozinho não conta; 2 slimes geram +5% para slimes, 3 slimes geram +10%, e assim por diante
* aliados de nível 2 ou maior causam +15% dano
* aliados de nível 3 reduzem seus cooldowns em 15%

### 17.3 Upgrades de composição

Upgrades de composição podem existir, mas devem continuar genéricos. Eles não devem parecer uma carta feita para apenas um monstro.

Exemplos:

* aliados corpo a corpo ganham +15% velocidade de ataque
* aliados à distância ganham +1 perfuração ou +15% alcance
* aliados defensivos aumentam a resistência do jogador quando estão perto dele
* efeitos de área duram +20%
* criaturas rápidas ganham +20% velocidade durante ataques especiais

### 17.4 Upgrades especiais

#### Horda Faminta

Aliados causam mais dano quanto maior for a quantidade de aliados ativos.

#### Pacto Instável

Aumenta muito a chance de essência de captura aparecer, mas reduz a vida máxima do jogador.

#### Ritual de Condensação

Melhora fusões: aliados fundidos recebem um bônus extra de dano ou cooldown.

### 17.5 Direção de design

O jogador deve sentir que está montando uma build durante a partida, mas sem precisar entender uma árvore complexa.

As melhores decisões devem nascer de perguntas simples:

* Quero muitos aliados fracos ou poucos aliados fortes?
* Quero repetir tipos para ganhar bônus de cópia?
* Quero aceitar essa essência agora ou ignorar porque ela atrapalha minha composição?
* Quero gastar espaço da horda com criaturas defensivas, dano à distância ou dano agressivo?

## 18. Sistema de níveis e fusão de aliados

### Status

Não obrigatório para o primeiro loop jogável, mas recomendado como uma das próximas grandes adições depois que captura opcional e upgrades de horda estiverem funcionando.

### Conceito

Aliados e inimigos podem ter nível de 1 a 3.

* Nível 1: criatura comum.
* Nível 2: versão melhorada.
* Nível 3: versão rara e forte.

Para aliados, níveis são obtidos por fusão. A regra inicial recomendada é:

* 3 aliados iguais de nível 1 podem virar 1 aliado igual de nível 2.
* 3 aliados iguais de nível 2 podem virar 1 aliado igual de nível 3.
* Nível 3 é o limite inicial.

Exemplo:

3 slimes nível 1 viram 1 slime nível 2.
3 slimes nível 2 viram 1 slime nível 3.

### Por que 3 cópias?

Começar com 3 é uma boa regra porque é fácil de entender, cria objetivo de curto prazo e já é comum em jogos de fusão.

Se parecer difícil demais montar fusões durante uma run curta, testar 2 cópias para o nível 2 e 3 cópias para o nível 3. Se parecer fácil demais, manter 3 e reduzir um pouco a chance de captura.

### Como a fusão deve acontecer

A fusão não deve acontecer automaticamente no momento em que o jogador tiver 3 cópias. O jogador precisa manter controle sobre a composição.

Recomendação inicial:

* Quando o jogador tiver fusão disponível, mostrar isso na tela de level up como uma opção especial.
* A opção deve explicar claramente o resultado, por exemplo: "Fundir 3 Slimes Nv.1 em 1 Slime Nv.2".
* Ao escolher a fusão, os aliados usados somem da composição original e são substituídos pelo aliado criado.
* Se houver mais de 3 cópias, fundir as 3 mais fracas ou mais antigas.
* Fusões não devem consumir essência de captura; elas consomem aliados já ativos.

Essa abordagem evita interromper a ação com uma janela extra no meio do combate e encaixa a fusão no mesmo ritmo de decisão dos upgrades.

### Alternativa futura

Depois do MVP, pode existir uma pequena tela de gerenciamento da horda durante pausas, mas isso não deve ser necessário agora.

### Benefícios

* menos poluição visual;
* sensação de evolução;
* cria objetivo secundário.
* faz capturas repetidas continuarem interessantes;
* permite escolher entre quantidade e qualidade.

### Riscos

Pode complicar o balanceamento.

Pode reduzir demais a quantidade visual da horda se os aliados fundidos ficarem fortes demais.

Pode deixar o jogador confuso se a UI não mostrar quantas cópias existem e quais fusões estão disponíveis.

### Direção visual para aliados aprimorados

Mesmo sem sprites finais, versões aprimoradas precisam ser fáceis de reconhecer.

Para o protótipo:

* Nível 1 usa o visual normal.
* Nível 2 usa escala um pouco maior, contorno mais forte e um pequeno brilho.
* Nível 3 usa escala maior que nível 2, contorno duplo ou cor de destaque, e um efeito simples de pulso.
* Evitar aumentar demais o tamanho, para não atrapalhar leitura e colisões.
* Usar marcador pequeno de nível acima do aliado apenas se a tela continuar legível.

O ideal é que o jogador reconheça o nível pelo corpo da criatura antes de precisar ler texto.

### Habilidades finais de aliados nível 3

Todo aliado que chega ao nível 3 deve ganhar uma melhoria especial reconhecível. A habilidade final deve ser uma evolução da identidade original do monstro, não um poder aleatório.

Regras:

* deve ser fácil de explicar em uma frase;
* deve reaproveitar o modo de ataque do aliado quando possível;
* deve ter feedback visual próprio;
* não deve exigir controle manual do jogador.

#### Slime Nv.3 — Golpe em Arco

O slime bate em um arco à frente do movimento/ataque, acertando vários inimigos próximos.

Função: transformar o slime de corpo a corpo simples em limpador de multidão curta.

#### Bat Nv.3 — Caçada em Cadeia

Depois de morder um inimigo, o bat pode saltar para outro alvo próximo uma ou duas vezes.

Função: preservar a fantasia de caçador rápido.

#### Boar Nv.3 — Investida Sísmica

A investida deixa uma onda curta no fim do caminho, causando dano em área.

Função: manter o javali como dano explosivo e abrir espaço.

#### Totem Nv.3 — Aura Dupla

O totem cria uma aura maior ou dois pulsos antes de sumir.

Função: reforçar controle de área.

#### Spitter Nv.3 — Tiro Dividido

O disparo se divide em projéteis menores ao acertar ou após certa distância.

Função: melhorar dano à distância contra grupos.

#### Crawler Nv.3 — Rastro Venenoso Maior

O rastro dura mais e pulsa com dano em intervalos claros.

Função: controle de chão e negação de área.

#### Shield Nv.3 — Barreira Circular

Periodicamente cria uma barreira curta ao redor do jogador ou empurra inimigos em volta.

Função: defesa e proteção da formação.

## 19. Mapa

### MVP validado

Um único mapa aberto.

Tema sugerido: cemitério/campo sombrio.

Elementos visuais:

* chão escuro;
* pedras;
* ossos;
* árvores secas;
* pequenas ruínas.

### Colisão

Poucos obstáculos sólidos.
Evitar labirintos no MVP.

### Objetivo do mapa

O mapa deve permitir movimento livre, fuga e circulação em volta da horda.

### Versão itch.io

Para a versão itch.io, o jogo deve ter pelo menos 3 fases/arenas. Elas não precisam ter regras totalmente diferentes, mas devem mudar leitura, ritmo e composição visual.

#### Arena 1 — Cemitério dos Fracos

Função: arena inicial e mais legível.

Características:

* tamanho médio;
* poucos obstáculos sólidos;
* muitas lápides quebráveis;
* árvores secas nas bordas;
* boa para aprender captura, XP e fusão.

#### Arena 2 — Bosque das Ossadas

Função: arena com mais navegação e bloqueios.

Características:

* tamanho maior;
* árvores com colisão;
* troncos e pedras criando rotas;
* clareiras abertas conectadas por corredores largos;
* cuidado para não virar labirinto injusto.

#### Arena 3 — Ruínas do Overlord

Função: arena final mais intensa.

Características:

* tamanho menor ou médio, com pressão mais alta;
* colunas quebradas com colisão;
* altares quebráveis;
* mais objetos que geram pickups;
* visual mais mágico, com símbolos no chão e energia necromântica.

### Objetos de mapa

O mapa deve ter dois tipos principais de objetos.

#### Objetos com colisão

Servem para dar forma à arena e mudar rotas.

Exemplos:

* árvores;
* pedras grandes;
* colunas;
* mausoléus pequenos;
* ruínas.

Regras:

* devem bloquear jogador e inimigos;
* não devem formar becos apertados demais;
* precisam ser visualmente óbvios como sólidos;
* devem existir em pouca quantidade no começo.

#### Objetos quebráveis

Servem como micro-recompensas no mapa.

Exemplos:

* lápides rachadas;
* vasos;
* caixotes;
* ossários;
* altares frágeis.

Regras:

* podem receber dano de ataques do jogador e aliados;
* podem dropar vida, ímã de almas ou XP;
* devem quebrar com feedback visual claro;
* não devem competir com essências de captura.

## 20. Arte

### Direção visual

Direção recomendada: **dark fantasy fofo e legível**, com pixel art simples ou sprites 2D de baixa resolução.

O jogo deve parecer sombrio, mas não realista. A leitura vem antes do detalhe.

Paleta inicial:

* chão escuro dessaturado;
* inimigos com tons quentes/vermelhos/roxos;
* aliados com contorno ou energia verde/ciano;
* pickups com cores altamente distintas;
* efeitos de captura/fusão com verde, ciano e roxo.

Evitar que tudo fique marrom, cinza ou roxo demais. Cada arena deve ter uma cor dominante secundária própria, mas os personagens precisam continuar legíveis em todas elas.

### Estilo dos sprites

Recomendação inicial:

* player, inimigos e aliados em canvas 64x64, com personagem ativo perto de 40-56 px;
* bosses em 96x96 ou 128x128;
* pickups em 16x16 ou 24x24;
* objetos de mapa em 16x16, 32x32 ou 48x48;
* silhuetas grandes e simples;
* poucos frames de animação;
* contraste alto entre corpo e contorno;
* versões aliadas reaproveitam a silhueta do inimigo, mas com energia/contorno aliado.

O player, monstros e mapa precisam conversar visualmente. Se o protagonista for o Pequeno Overlord, o mundo deve parecer um território necromântico: cemitérios, ossos, ruínas, árvores secas, altares e magia verde/ciano.

### Produção de sprites

Para a versão itch.io, usar sprites reais em vez de formas vetoriais de protótipo.

Cada monstro deve ter 3 níveis visuais:

* Nv.1: forma base;
* Nv.2: mesma silhueta com detalhe novo, escala ou energia maior;
* Nv.3: forma final memorável, ainda reconhecível como o mesmo monstro.

O Overlord já existe com várias direções, mas isso não deve virar exigência para todos os sprites. Para controlar escopo, inimigos e aliados podem começar com sprite estático em uma direção principal. Direções extras entram apenas se melhorarem muito a leitura do comportamento.

Começar com sprites estáticos por nível. Animações podem entrar depois, quando a direção visual estiver aprovada.

### Revisão do roster de monstros

Os comportamentos do protótipo podem continuar, mas os monstros precisam ser memoráveis e coerentes com o tema.

Recomendações:

* Slime: manter.
* Bat: manter ou transformar em Morcego de Osso.
* Boar: trocar por Carneiro Caveira, mantendo comportamento de investida.
* Totem: manter como Totem Profano.
* Spitter: trocar por Crânio Cuspidor ou Cuspideira Ossária.
* Crawler: trocar por Verme de Ossos.
* Shield: trocar por Guardião Escudo.

### Prioridades de efeitos visuais

Antes de adicionar mais conteúdo, melhorar efeitos de ações principais:

* XP vindo visualmente em direção ao jogador quando coletado por magnetismo ou ímã de almas;
* absorção do XP no jogador com pequeno brilho;
* cura com pulso verde/vermelho claro no jogador;
* fusão com explosão curta ou anel de energia;
* essência de captura com silhueta do tipo capturável;
* objeto quebrável com estilhaços simples.

### Recomendação para iniciante

Usar sprites pequenos e simples:

* personagem e inimigos em canvas 64x64;
* projéteis simples;
* efeitos com partículas.

### Prioridade visual

1. Legibilidade.
2. Feedback de dano.
3. Diferenciação entre inimigo e aliado.
4. Efeitos satisfatórios de conversão.

### Diferenciar inimigos e aliados

Inimigos podem ter contorno vermelho ou tom quente.
Aliados podem ter contorno azul, roxo ou verde.

O importante é o jogador bater o olho e entender quem está do lado dele.

## 21. Áudio

### Música

Uma música de ação em loop.

### Efeitos sonoros necessários

* ataque do jogador;
* inimigo recebendo dano;
* inimigo morrendo;
* conversão;
* coleta de XP;
* level up;
* escolha de upgrade;
* dano no jogador;
* boss aparecendo;
* vitória;
* derrota.

O som de conversão deve ser especialmente satisfatório, porque é o diferencial do jogo.

## 22. Interface

### HUD

Mostrar:

* vida do jogador;
* barra de experiência;
* nível atual;
* tempo de partida;
* quantidade de aliados atual / limite de aliados.

Exemplo:

Vida: 80/100
Nível: 4
Tempo: 03:25
Aliados: 12/20

### Tela de level up

Mostrar 3 cartas de upgrade.

Cada carta deve ter:

* nome;
* descrição curta;
* ícone simples.

Exemplo:

**Chamado Sombrio**
+10% chance de conversão.

### Tela inicial

Botões:

* Jogar
* Como jogar
* Créditos
* Sair

### Tela de derrota

Mostrar:

* tempo sobrevivido;
* nível alcançado;
* inimigos derrotados;
* aliados convertidos;
* botão tentar novamente.

### Tela de vitória

Mostrar:

* tempo total;
* chefe derrotado;
* aliados convertidos;
* inimigos derrotados;
* botão jogar novamente.

## 23. Estrutura técnica em Godot

### Cenas principais

```text
Main.tscn
Game.tscn
Player.tscn
Enemy.tscn
Ally.tscn
Projectile.tscn
XPOrb.tscn
Pickup.tscn
UpgradeCard.tscn
HUD.tscn
MainMenu.tscn
PauseMenu.tscn
GameOverScreen.tscn
VictoryScreen.tscn
```

### Scripts principais

```text
player.gd
enemy.gd
ally.gd
projectile.gd
xp_orb.gd
spawn_manager.gd
upgrade_manager.gd
ally_manager.gd
game_manager.gd
hud.gd
```

## 24. Sistemas técnicos

### 24.1 PlayerController

Responsável por:

* movimento;
* vida;
* receber dano;
* disparar ataque automático;
* coletar XP;
* emitir sinais de morte e level up.

### 24.2 SpawnManager

Responsável por:

* controlar o tempo da partida;
* escolher quais inimigos aparecem;
* aumentar dificuldade;
* spawnar boss no final.

### 24.3 AllyManager

Responsável por:

* guardar lista de aliados ativos;
* verificar limite de aliados;
* posicionar aliados em órbita;
* remover aliados mortos;
* aplicar upgrades globais.

### 24.4 UpgradeManager

Responsável por:

* guardar lista de upgrades possíveis;
* sortear 3 upgrades;
* aplicar upgrade escolhido;
* pausar e despausar jogo.

### 24.5 GameManager

Responsável por:

* estado da partida;
* vitória;
* derrota;
* reiniciar jogo;
* trocar telas.

## 25. Sinais importantes

```gdscript
player_died
enemy_died(enemy_type, position)
enemy_converted(enemy_type, position)
xp_collected(amount)
level_up(new_level)
upgrade_selected(upgrade_id)
boss_spawned
boss_defeated
game_won
game_lost
```

## 26. MVP obrigatório

O jogo só é considerado MVP quando tiver:

* personagem andando;
* ataque automático;
* pelo menos 2 inimigos;
* inimigos tomando dano e morrendo;
* chance de conversão;
* aliados seguindo ou orbitando o jogador;
* aliados atacando inimigos;
* XP;
* level up;
* pelo menos 8 upgrades;
* HUD funcional;
* começo, derrota e reinício;
* partida de pelo menos 5 minutos.

## 27. Versão itch.io mínima

Para publicar na itch.io com dignidade, precisa ter:

* partida de 8 a 12 minutos;
* pelo menos 3 arenas/fases diferentes;
* objetos de mapa com colisão;
* objetos quebráveis que podem gerar pickups;
* 4 inimigos;
* 3 tipos de aliados;
* habilidades finais para aliados nível 3;
* 1 boss;
* 12 a 15 upgrades;
* tela inicial;
* tela de vitória;
* tela de derrota;
* música;
* efeitos sonoros;
* estilo de arte definido e coerente entre player, monstros, mapas e pickups;
* efeitos visuais melhores para XP, cura, fusão, captura e quebra de objetos;
* página da itch.io com descrição, controles e GIF curto.

## 28. Stretch goals

Adicionar apenas se o jogo base já estiver divertido.

* mais um personagem jogável;
* upgrades raros;
* conquistas internas;
* salvamento de recorde;
* modo infinito;
* efeitos de partículas melhores;
* tela de estatísticas pós-jogo.

## 29. O que não fazer na primeira versão

Evitar antes da versão itch.io mínima:

* história longa;
* loja permanente;
* árvore de habilidades;
* muitos personagens;
* multiplayer;
* inventário;
* diálogos complexos;
* crafting;
* inimigos com IA elaborada;
* procedural map;
* 30 tipos de upgrade.

Essas coisas parecem legais, mas podem impedir o jogo de ser terminado.

## 30. Cronograma sugerido

### Semana 1 — Protótipo jogável

Objetivo: provar que o loop é divertido.

Entregas:

* movimento do jogador;
* ataque automático;
* inimigo básico;
* morte de inimigo;
* conversão;
* aliado seguindo jogador;
* spawn infinito simples.

### Semana 2 — Loop completo

Objetivo: transformar o protótipo em jogo.

Entregas:

* XP;
* level up;
* upgrades;
* HUD;
* 2 ou 3 inimigos;
* limite de aliados;
* tela de derrota.

### Semana 3 — Conteúdo e balanceamento

Objetivo: dar corpo à partida.

Entregas:

* 4 inimigos;
* 3 aliados;
* 10+ upgrades;
* progressão por tempo;
* chefe final;
* tela de vitória.

### Semana 4 — Polimento e itch.io

Objetivo: deixar apresentável.

Entregas:

* menu inicial;
* áudio;
* partículas;
* feedback visual;
* correção de bugs;
* export HTML5 ou Windows;
* página da itch.io;
* GIFs e screenshots.

## 31. Critério de sucesso

O jogo será considerado bem-sucedido se:

* uma partida completa durar menos de 12 minutos;
* o jogador entender a mecânica em menos de 30 segundos;
* a tela ficar visualmente mais interessante conforme a horda cresce;
* converter inimigos for satisfatório;
* o jogo puder ser reiniciado rapidamente;
* pelo menos uma pessoa de fora conseguir jogar sem explicação direta.

## 32. Riscos principais

### Risco 1: tela caótica demais

Solução: limitar aliados, usar órbita, reduzir partículas e diferenciar bem cores.

### Risco 2: aliados fazem tudo e jogador só anda

Solução: inimigos à distância, boss com ataques em área e upgrades com trade-offs.

### Risco 3: escopo crescer

Solução: fechar a primeira versão itch.io com 3 arenas pequenas, 1 personagem, poucos objetos de mapa reutilizáveis e habilidades finais simples para aliados nível 3.

### Risco 4: performance ruim com muitos inimigos

Solução: limitar quantidade de entidades, usar colisões simples e evitar pathfinding complexo.

## 33. Primeira meta real

Antes de pensar em arte, menu ou boss, fazer uma cena com:

* jogador;
* 10 slimes;
* ataque automático;
* slimes morrendo;
* alguns virando aliados;
* aliados orbitando o jogador;
* aliados dando dano nos inimigos.

Se essa cena for divertida por 2 minutos, o jogo tem futuro.

## Nota de direcao visual - niveis dos monstros

A direcao atual para sprites de monstros e aliados e tratar cada nivel como uma transformacao causada pelo Overlord:

* Nv.1: criatura base, mais natural/selvagem, com poucos sinais necromanticos.
* Nv.2: versao tocada pelo Overlord, mantendo a silhueta mas ganhando caveira, osso, rachaduras ou energia verde/ciano.
* Nv.3: forma final necromantica memoravel, ainda reconhecivel como o mesmo monstro.

Os sprites atuais com aparencia de caveira/ossos devem ser usados como referencia de Nv.2. A proxima leva de arte deve criar versoes Nv.1 mais simples, para que fusoes e melhorias parecam uma corrupcao/evolucao visual clara.
