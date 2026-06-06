# SPRINTS.md

Roadmap de desenvolvimento de **Horda Reversa**.

Principio geral: cada sprint deve terminar com algo jogavel e validavel no Godot. Sistemas grandes devem ser quebrados em entregas menores.

## Estado atual

### Marco atual

MVP validado em jogo em 2026-06-06. O loop principal ja funciona: mover, sobreviver, derrotar inimigos, coletar XP, escolher upgrades, capturar aliados, montar composicao, fundir aliados e usar pickups de sustentacao.

O foco agora muda de provar mecanicas para melhorar apresentacao, legibilidade, balanceamento e preparar uma versao jogavel para itch.io.

### Ja validado em jogo

- Movimento top-down do jogador.
- Camera seguindo o jogador.
- Ataque automatico no inimigo mais proximo.
- Slimes e bats spawnando fora da tela.
- Inimigos tomam dano, morrem e dropam XP.
- XP e coletado por proximidade e magnetismo.
- Level up pausa o jogo e mostra 3 upgrades.
- O jogo pausa gameplay via `World` durante escolha de upgrade.
- Conversao cria aliado do mesmo tipo do inimigo derrotado.
- Aliados orbitam o jogador e atacam inimigos proximos.
- HUD de debug mostra valores reais usados pelo codigo.
- Dano de contato e aplicado por tick centralizado no `Game`.
- Partida tem meta temporaria de 5 minutos.
- Tela inicial permite comecar a partida de forma clara.
- HUD debug pode ser alternado com F3.
- Inimigos com papeis diferentes comecam a funcionar como pecas capturaveis.
- Conversao virou escolha do jogador por meio de essencias de captura opcionais.
- Upgrades genericos de horda comecaram a criar builds por composicao.
- Fusoes de aliados repetidos foram validadas em jogo.
- Pickups de vida e coleta global de XP foram adicionados para sustentar a run.

### Estrutura atual importante

- Cena principal: `scenes/Game.tscn`.
- Entidades reutilizaveis: `scenes/entities/`.
- Inimigos concretos: `scenes/entities/enemies/`.
- Aliados concretos: `scenes/entities/allies/`.
- Scripts de entidades: `scripts/entities/`.
- Script principal/orquestrador: `scripts/game/game.gd`.
- Guia de arte: `ART_GUIDE.md`.
- Gameplay pausavel fica sob o no `World`.
- HUD e controladores ficam fora do `World`.

### Proxima prioridade

Validar Sprint 17 em jogo e iniciar Sprint 18: objetos de mapa com colisao e quebraveis.

## Sprint 1 - Prototipo jogavel

Objetivo: provar o loop central em uma cena simples antes de criar conteudo maior.

Status: concluida em 2026-06-05.

### Entregue

- Jogador top-down com movimento por WASD e setas.
- Camera seguindo o jogador.
- Ataque automatico que mira no inimigo mais proximo.
- Projetil simples com dano.
- Slime inimigo perseguindo o jogador.
- Inimigo toma dano, morre e emite evento de morte.
- Chance de conversao ao derrotar slime.
- Slime convertido vira aliado.
- Aliados orbitam o jogador.
- Aliados atacam inimigos proximos automaticamente.
- Spawn inicial com 10 slimes.
- Spawn infinito simples com limite de inimigos na tela.
- HUD simples com vida, tempo, inimigos derrotados, aliados e conversoes.
- Derrota quando a vida chega a zero.
- Reinicio rapido com R.

### Decisoes

- Comecamos com visual simples para acelerar o loop jogavel.
- A primeira formacao de aliados usa orbita, como recomendado no GDD.
- Dano por contato e acerto de projetil usam distancia, nao colisao fisica complexa.

### Validacao

- Jogador se move.
- Ataque automatico mata slimes.
- Alguns slimes viram aliados.
- Aliados orbitam e causam dano.
- Jogador pode morrer e reiniciar com R.

## Sprint 2 - Loop completo

Objetivo: transformar o prototipo em uma partida com progressao basica.

Status: concluida em 2026-06-05.

### Entregue

- Cristais de XP dropam quando inimigos morrem.
- Cristais sao coletados por proximidade.
- Cristais sao atraidos quando o jogador chega perto.
- HUD mostra nivel e progresso de XP.
- Jogador sobe de nivel ao completar XP.
- Level up pausa a partida e oferece 3 upgrades.
- Implementados 8 upgrades basicos:
  - dano do orbe;
  - velocidade de ataque;
  - velocidade do jogador;
  - chance de conversao;
  - limite de aliados;
  - dano dos aliados;
  - vida maxima;
  - alcance de coleta.
- Gameplay foi agrupado em `World`, permitindo pausar inimigos, aliados, projetis e XP juntos durante a escolha de upgrade.
- Spawn de inimigos acontece fora da area visivel da camera com margem segura.
- HUD de debug mostra valores usados pelo codigo.
- Dano por contato foi centralizado no `Game` e aplicado por tick.
- Inimigos ganharam separacao simples para evitar pilhas visualmente perfeitas.

### Decisoes

- Pausa global de gameplay deve ser feita pausando o `World`, nao travando entidade por entidade.
- O HUD de debug fica temporariamente visivel para facilitar validacao enquanto o jogo ainda esta em prototipo.
- `Player.tscn` e `XPOrb.tscn` passaram a ter nos `Visual` editaveis no editor.

### Validacao

- XP sobe corretamente.
- Level up mostra upgrades.
- Escolher upgrade despausa o jogo.
- Inimigos e projetis param durante a escolha.
- Dano de contato respeita o intervalo configurado.
- Debug atualiza com os valores reais do codigo.

## Sprint 3 - Conteudo e organizacao de inimigos

Objetivo: adicionar segundo inimigo e organizar inimigos por cenas concretas.

Status: concluida em 2026-06-05.

### Entregue

- Criada uma cena concreta para cada inimigo:
  - `scenes/entities/enemies/Slime.tscn`;
  - `scenes/entities/enemies/Bat.tscn`.
- Criado script base compartilhado:
  - `scripts/entities/enemies/enemy.gd`.
- Cada cena de inimigo guarda seus proprios valores:
  - vida;
  - velocidade;
  - dano de contato;
  - XP;
  - tipo;
  - cores;
  - separacao.
- Slime teve separacao reduzida para evitar espalhamento exagerado.
- Morcego implementado como segundo inimigo simples: mais rapido, menos vida e cor roxa.
- Spawn escolhe slimes no comeco e mistura morcegos depois de alguns segundos.
- Debug mostra quantidade de slimes, quantidade de morcegos e ultimo tipo spawnado.

### Decisoes

- Inimigos devem usar um script base com comportamento comum e uma cena concreta por tipo.
- Stats e visual do inimigo ficam na cena concreta para facilitar ajuste no Inspector.

### Validacao

- Slimes continuam funcionando.
- Bats aparecem depois do tempo configurado.
- Debug mostra contagem de slimes e bats.
- Dano de contato usa o valor do inimigo encostando.

## Sprint 4 - Aliados por tipo

Objetivo: garantir que a conversao preserve a identidade visual do inimigo convertido.

Status: concluida em 2026-06-05.

### Entregue

- Criadas cenas concretas de aliados:
  - `scenes/entities/allies/SlimeAlly.tscn`;
  - `scenes/entities/allies/BatAlly.tscn`.
- Criado script base compartilhado:
  - `scripts/entities/allies/ally.gd`.
- Conversao escolhe a cena aliada pelo `enemy_type`.
- Slime convertido vira slime aliado.
- Bat convertido vira bat aliado.
- Debug mostra quantidade de aliados slime, aliados bat e ultima conversao.
- Aliados ganharam feedback simples de ataque por escala do `Visual`.

### Decisoes

- Aliados convertidos seguem o mesmo padrao dos inimigos: base compartilhada + cena concreta por tipo.
- O aliado deve manter uma silhueta ligada ao inimigo de origem, mas com cor de aliado.

### Validacao

- Bat convertido vira visualmente um bat aliado.
- Slime convertido continua virando slime aliado.
- Debug incrementa `Aliados slime` e `Aliados bat` corretamente.
- `Ultima conversao` mostra o tipo convertido.

## Sprint 5 - Derrota e reinicio claro

Objetivo: fechar melhor o ciclo de partida quando o jogador perde.

Status: concluida em 2026-06-05.

### Entregue

- Tela de derrota com estatisticas.
- Mostrar tempo sobrevivido.
- Mostrar nivel alcancado.
- Mostrar inimigos derrotados.
- Mostrar aliados convertidos.
- Botao para tentar novamente.
- Tecla R continua reiniciando a partida.
- Gameplay pausa quando o jogador morre.
- Inimigos, projeteis e XP ativos sao removidos na derrota.
- HUD debug e HUD normal saem de foco durante a tela de derrota.

### Decisoes

- A derrota usa pausa global de gameplay, mantendo o `Game` e o HUD em `PROCESS_MODE_ALWAYS`.
- As estatisticas da tela de derrota usam os mesmos contadores reais do HUD/debug.

### Validacao

- Ao morrer, gameplay para.
- Tela de derrota aparece.
- Estatisticas batem com o HUD/debug.
- R ou botao reinicia a partida.

## Sprint 6 - Feedback visual de combate

Objetivo: deixar ataques, dano e conversao mais legiveis.

Status: concluida em 2026-06-05.

### Entregue

- Feedback visual quando aliado ataca.
- Feedback visual quando inimigo recebe dano.
- Feedback visual especifico de conversao.
- Pequeno efeito no XP coletado.
- Texto flutuante para dano do jogador.
- Texto flutuante para dano dos aliados.
- Texto flutuante para XP coletado.
- Nova cena reutilizavel `scenes/effects/FloatingText.tscn`.
- Melhorar diferenca visual entre inimigo e aliado.

### Decisoes

- O feedback de texto fica em uma cena propria para ser reutilizado sem poluir `game.gd`.
- `game.gd` instancia o efeito como `Node2D` e chama `setup`, evitando depender do `class_name` novo imediatamente.
- O inimigo continua responsavel pelo flash de dano do proprio visual.
- O aliado continua responsavel pelo flash/escala do proprio ataque.

### Validacao

- Jogador percebe quando aliado causa dano.
- Conversao fica visualmente clara.
- Tela continua legivel com varios personagens.
- Coletar XP mostra `+XP`.

## Sprint 7 - Progressao de partida curta

Objetivo: caminhar para uma partida MVP de 5 minutos.

Status: concluida em 2026-06-05.

### Entregue

- Controlar progressao por tempo.
- Ajustar spawn rate ao longo da partida.
- Ajustar limite de inimigos vivos ao longo da partida.
- Definir meta inicial de duracao: 5 minutos.
- Preparar condicao simples de vitoria temporaria aos 5 minutos.
- HUD mostra tempo decorrido, tempo ate a meta e pressao da partida.
- Debug mostra pressao, intervalo de spawn atual e limite atual de inimigos.

### Decisoes

- A progressao inicial e linear para ser facil de entender e ajustar.
- `spawn_interval` e `max_enemies` representam o comeco da partida.
- `spawn_interval_at_end` e `max_enemies_at_end` representam a pressao aos 5 minutos.
- A vitoria de 5 minutos e temporaria para validar duracao antes de criar objetivos finais maiores.

### Validacao

- Partida dura alguns minutos sem quebrar.
- Pressao aumenta com o tempo.
- Debug permite acompanhar spawn e contagens.
- Ao chegar em 5 minutos, gameplay para e aparece tela de vitoria.

## Sprint 8 - Terceiro inimigo ou tela inicial

Objetivo: escolher o proximo ganho de produto depois do loop estar mais estavel.

Status: concluida em 2026-06-05.

### Escolha

Foi escolhida uma mistura pequena das opcoes B e C, porque ajuda mais outra pessoa a testar sem explicacao direta.

### Entregue

- Tela inicial com nome do jogo.
- Botao para comecar partida.
- Partida nao spawna inimigos antes do jogador iniciar.
- Jogador nao se move antes do inicio.
- HUD normal ficou focado em vida, nivel, XP, tempo, meta, pressao e contagens principais.
- HUD debug pode ser alternado com F3.
- Hint mostra comandos principais durante a partida.

### Decisoes

- Ainda nao adicionamos terceiro inimigo porque o proximo gargalo e validar fluxo de partida completo.
- A tela inicial foi feita dentro de `Game.tscn` para manter o MVP simples.
- O debug continua no prototipo, mas deixa de competir tanto com a experiencia normal.

### Validacao

- Abrir a cena mostra tela inicial.
- Clicar em `Comecar partida` inicia spawn e libera movimento.
- F3 mostra/oculta debug.
- R reinicia a cena.

## Sprint 9 - Inimigos com papeis capturaveis

Objetivo: adicionar gameplay novo tratando inimigos como pecas capturaveis, nao apenas obstaculos.

Status: concluida em 2026-06-05.

### Entregue

- Novo inimigo `Boar`: avanca com investida depois de uma preparacao curta.
- Novo aliado `BoarAlly`: atacante de investida, bom para dano explosivo em alvo unico.
- Novo inimigo `Totem`: lento, resistente e tenta manter distancia do jogador.
- Novo aliado `TotemAlly`: suporte ofensivo com ataque em area ao redor dele.
- Script base de inimigos ganhou modos de movimento:
  - `chase`;
  - `skirmisher`;
  - `charger`.
- Script base de aliados ganhou modos de ataque:
  - `melee`;
  - `dash`;
  - `aura`.
- Spawn por peso passa a misturar tipos novos ao longo do tempo.
- Conversao preserva os novos tipos e cria aliados equivalentes.
- Debug mostra contagem de boars/totens e seus aliados.

### Decisoes

- Cada inimigo novo deve responder qual papel ele traz para o exercito quando convertido.
- Continuamos usando cena concreta por tipo e script base compartilhado.
- O comportamento e configurado por exports no Inspector para facilitar ajuste sem criar muitos scripts.
- Polimento user friendly fica em pausa; o foco volta para variedade jogavel.

### Validacao

- Depois de cerca de 55 segundos, javalis podem aparecer.
- Javalis devem preparar e avancar em linha reta.
- Depois de cerca de 105 segundos, totens podem aparecer.
- Totens devem ser lentos, resistentes e render mais XP.
- Converter javali cria aliado de investida.
- Converter totem cria aliado de area.
- F3 mostra contagens dos novos tipos.

## Sprint 10 - Sinergias e composicao do exercito

Objetivo: fazer o jogador se importar com quais criaturas converteu.

Status: pronta para validacao em 2026-06-05.

### Entregue ate agora

- Investida do `Boar` inimigo ficou mais longa e mais facil de perceber.
- `BoarAlly` deixou de ser um teleporte curto e passou a preparar e investir como criatura propria.
- Modo `dash` dos aliados agora tem windup, duracao, velocidade e raio de acerto configuraveis.
- `BoarAlly` so investe quando esta perto o suficiente do jogador e depois precisa voltar para a formacao.
- `BoarAlly` ganhou cooldown minimo maior depois da investida.
- `BatAlly` ganhou comportamento de cacador rapido: sai da orbita para morder alvos proximos e retorna.
- `Game` ganhou `enabled_enemy_types` para testar tipos especificos de inimigos pela cena.
- `BatAlly` agora mantem a cacada por uma janela curta mesmo se sair da area do jogador.
- `TotemAlly` ganhou feedback visual de pulso para deixar a area de ataque legivel.
- Novo inimigo `Spitter`: mantem distancia e atira projeteis simples no jogador.
- Novo aliado `SpitterAlly`: fica na formacao e dispara projeteis contra inimigos.
- Projetil foi generalizado para acertar inimigos ou jogador conforme o tipo de alvo.
- `TotemAlly` virou uma invocacao temporaria: aparece parado ao redor do jogador, pulsa por duracao configuravel, some e entra em cooldown.
- `Totem` inimigo agora usa ataque em area com pulso visual, preservando o comportamento quando capturado.
- `SlimeAlly` ganhou comportamento de cacador de curto alcance, parecido com o bat mas com raio menor.
- `BatAlly` ganhou raio maior e cooldown mais alto para agir como criatura voadora mais independente.
- Novo inimigo `Crawler`: persegue deixando um rastro temporario que causa dano por contato.
- Novo aliado `CrawlerAlly`: orbita deixando rastro temporario que causa dano em inimigos.
- Novo inimigo `Shield`: imune a dano de projeteis.
- Novo aliado `ShieldAlly`: orbita o jogador, bloqueia projeteis inimigos e empurra inimigos para longe quando estao fora do raio de patrulha.

### Decisao de direcao

O exercito deve preservar a personalidade do inimigo convertido. Em vez de todo aliado ser uma bolinha orbitando com dano parecido, cada tipo deve manter um comportamento reconhecivel:

- slime: cacador de curto alcance;
- bat: cacador rapido que sai e volta da formacao;
- boar: investida em linha;
- totem: invocacao estacionaria temporaria com area/pulso.
- spitter: atirador de retaguarda.
- crawler: controle de chao por rastro.
- shield: defesa contra dano a distancia e empurrao defensivo.

### Ideias propostas

- Bônus por composicao, por exemplo:
  - 3 slimes aumentam chance de conversao;
  - 2 bats aumentam velocidade da horda;
  - 2 boars aumentam dano de investida;
  - 1 totem melhora alcance de coleta ou dano em area.
- Limite por tipo ou custo de slots para criaturas fortes.
- Indicador simples de composicao atual no debug antes de virar HUD definitivo.
- Pequenas escolhas de upgrade que interagem com tipos de aliados.
- Repensar o slime para ser mais do que melee basico, possivelmente com empurrao, lentidao, grude ou bonus por quantidade.
- Evoluir tipos de ataque/resistencia alem de `ranged`, por exemplo fisico, area e elemental.

### Validacao

- Ter aliados diferentes muda a forma como a horda luta.
- O jogador consegue perceber valor em converter tipos especificos.
- A composicao do exercito vira uma decisao, nao apenas uma contagem.
- `Crawler` inimigo deixa rastro que machuca o jogador por tick.
- `CrawlerAlly` convertido deixa rastro que machuca inimigos.
- `Shield` inimigo nao toma dano de projetil do jogador, mas ainda toma dano melee/area.
- `ShieldAlly` bloqueia projeteis inimigos proximos e empurra inimigos para fora do player.
- `Totem` inimigo escolhe uma regiao proxima ao player, pisca a area 3 vezes, cai ali e so depois liga a aura ao redor do proprio corpo.
- `TotemAlly` tambem tem aviso/queda antes da aura ativa para preservar a identidade do inimigo convertido.
- Aviso e aura do `Totem` agora usam visuais separados: amarelo para area de aviso, verde/ciano para aura ativa.
- `Boar` e `BoarAlly` mostram uma faixa de aviso no caminho da investida durante o windup.
- `warning_visuals.gd` concentra configuracao visual de areas/faixas de aviso para reduzir duplicacao nos scripts base.
- `Bat` inimigo voltou a causar dano fisico por contato; o Bat aliado usa raio maior como leash de caca.
- Rastros de `Crawler` ficaram mais finos/longos e usam cooldown por alvo para evitar dano sobreposto quebrado.
- Projeteis bloqueados por shield mostram feedback de `Bloqueio` para deixar imunidade/defesa legivel.
- Em `Game.tscn`, todos os tipos estao habilitados e os tipos especiais comecam cedo para facilitar teste.

## Sprint 11 - Sinergias e composicao do exercito

Objetivo: transformar a lista de aliados em escolhas de composicao com efeitos claros.

Status: concluida em 2026-06-06.

### Entregue ate agora

- Conversao deixou de ser automatica: inimigos conversiveis agora podem gerar uma essencia de captura.
- Essencia de captura e um drop opcional no chao; o jogador precisa pegar para adicionar o aliado.
- Se a horda estiver cheia, a essencia nao e consumida e mostra feedback de `Horda cheia`.
- HUD mostra quantas essencias estao no chao.
- Debug mostra essencias ativas, chance de essencia, cooldown global dos aliados e bonus por copia.
- Novo upgrade `Ritmo da horda`: reduz todos os cooldowns dos aliados em 10%.
- Novo upgrade `Instinto de matilha`: tipos repetidos ganham +5% dano por copia extra.
- Bonus de horda passaram a ser recalculados de forma centralizada nos aliados.

### Decisoes

- Captura opcional entrou antes de fusao porque resolve primeiro a agencia do jogador sobre a composicao.
- Upgrades novos devem ser amplos e sistemicos, nao cartas especificas para um unico monstro.
- Bonus por copia repetida fica como primeiro teste de build por composicao.
- Fusao e niveis ficam para a proxima sprint, para nao misturar escolha de captura com gerenciamento de aliados na mesma entrega.

### Validacao

- Testado em jogo em 2026-06-06.
- Essencias aparecem no chao e podem ser coletadas para converter inimigos.
- O jogador consegue ignorar capturas que nao quer para a composicao atual.
- HUD/debug mostram os dados novos da sprint.
- Upgrades de cooldown global e bonus por copia aparecem no fluxo normal de level up.

## Sprint 12 - Niveis e fusao de aliados

Objetivo: fazer capturas repetidas virarem progresso claro sem lotar a tela de aliados iguais.

Status: concluida em 2026-06-06.

### Entregue ate agora

- Aliados ganharam nivel de 1 a 3.
- Aliados de nivel maior recebem bonus simples de dano e cooldown.
- Visual provisorio de nivel usa escala e cor no no `Visual`.
- Quando existem 3 aliados iguais do mesmo nivel, o level up pode oferecer uma carta de fusao.
- A carta de fusao troca 3 aliados iguais por 1 aliado do proximo nivel.
- HUD mostra quantidade de fusoes feitas.
- Debug mostra fusoes disponiveis usando dados reais da composicao.
- Essencias de captura ganharam cor, silhueta e letra por tipo para mostrar o que sera coletado.

### Validacao

- O jogador entende quando uma fusao esta disponivel. Validado em 2026-06-06.
- O jogador consegue escolher entre manter quantidade ou trocar por um aliado mais forte. Validado em 2026-06-06.
- O aliado fundido fica visualmente reconhecivel. Validado em 2026-06-06.
- A fusao reduz aliados repetidos sem fazer a horda parecer vazia. Validado em 2026-06-06.
- O jogador consegue identificar o tipo de uma essencia antes de coletar.

## Sprint 13 - Pickups de sustentacao e coleta

Objetivo: adicionar recompensas raras de mapa que ajudem a run sem competir com a composicao da horda.

Status: concluida em 2026-06-06.

### Entregue ate agora

- Nova cena generica `scenes/entities/Pickup.tscn`.
- Novo script `scripts/entities/pickup.gd`.
- Pickup de vida cura o jogador sem ultrapassar a vida maxima.
- Pickup de coleta global recolhe todos os cristais de XP ativos no mapa.
- Coleta global nao recolhe essencias de captura.
- Pickups têm visual distinto de XP e essencias.
- Pickups e essencias ganharam area de coleta maior para combinar melhor com o tamanho visual.
- `XPOrb`, `CaptureEssence` e `Pickup` agora mostram `CollectArea/CollisionShape2D` no editor.
- `XPOrb` tambem mostra `MagnetArea/CollisionShape2D` para visualizar o alcance de magnetismo.
- HUD mostra quantidade de pickups ativos.
- Debug mostra contagem de pickups ativos e ultimo pickup coletado.

### Validacao

- Pickup de vida aparece, pode ser coletado e cura o jogador.
- Pickup de coleta global recolhe todos os XP ativos.
- Coleta global nao coleta essencias de captura.
- Pickups somem corretamente na derrota/vitoria/reinicio.

## Sprint 14 - UI pos-MVP

Objetivo: transformar a UI de prototipo em uma UI mais legivel para testes externos.

Status: pronta para validacao em 2026-06-06.

### Entregue ate agora

- HUD normal reorganizado em blocos: run, progresso e horda.
- Texto inicial atualizado para explicar essencias e composicao de horda.
- Painel de upgrades ficou maior para reduzir aperto de texto.
- Cartas de upgrade ganharam mais altura.
- Hint inferior ficou mais curto e alinhado com o loop atual.

### Validacao planejada

- HUD normal deve ser entendido sem ligar o debug.
- Tela de upgrade deve ser confortavel de ler.
- Tela inicial deve explicar a fantasia atual sem texto longo demais.
- UI nao deve cobrir gameplay importante durante a partida.

## Sprint 15 - Identidade visual e protagonista

Objetivo: definir a direcao de sprites reais para player, monstros, aliados, mapas, pickups e efeitos.

Status: em andamento.

### Entregue ate agora

- Player definido como `Pequeno Overlord`.
- Criado guia simples de arte em `ART_GUIDE.md`.
- Sprite temporario do player trocado de losango azul para caveira com manto, coroa, olhos de energia e aura.
- Definido tamanho base recomendado: canvas 64x64 para player, inimigos e aliados.
- Definido que cada monstro deve ter 3 niveis visuais.
- Definida revisao de roster: comportamentos podem ficar, mas monstros pouco memoraveis podem mudar de nome/visual.
- Gerada primeira folha conceitual de inimigos em `sprites/enemies/concepts/`.
- Criados recortes 64x64 para Slime, Morcego de Osso, Carneiro Caveira, Totem Profano, Cranio Cuspidor, Verme de Ossos e Guardiao Escudo.
- Corrigida integracao inicial com sprites reais: o script base de inimigos agora usa `Sprite2D` como visual principal quando existir, preservando os icones vetoriais antigos como fallback.
- Corrigido `Totem`: avisos de queda e aura voltaram a aparecer mesmo com o corpo antigo escondido.
- Definida convencao de frente: sprites que precisam apontar/rotacionar devem nascer olhando para a direita/leste.
- Aplicadas sprites reais iniciais nas cenas de aliados, reaproveitando a silhueta do inimigo com tintura ciano e marca de conversao.
- Aliados ganharam borda/halo ciano gerado pelo script base para melhorar identificacao no meio da horda.
- Criada nova sprite frontal 64x64 para o player Overlord em `sprites/overlord/generated/` e aplicada na cena do player.
- Player, inimigos e aliados agora espelham a sprite horizontalmente conforme direcao de movimento/alvo.
- Corrigido bug do `Shield`: feedback de resistencia a projetil nao aumenta mais a sprite para escala gigante.
- Reposicionada a direcao visual dos monstros: os sprites atuais com caveira/ossos passam a servir como referencia de Nv.2; a proxima leva deve criar Nv.1 mais simples/naturais.
- Gerada primeira folha real de monstros Nv.1 em `sprites/enemies/level_1/`.
- Inimigos comuns agora usam sprites Nv.1 nas cenas concretas.
- Aliados Nv.1 agora usam sprites Nv.1; aliados fundidos Nv.2 passam a nascer em cenas proprias com sprites caveira/ossos.
- Refatorada a evolucao de aliados para cenas concretas por nivel: criadas cenas `*AllyLevel2.tscn` para todos os tipos.
- A fusao agora instancia a cena do nivel correspondente, permitindo stats e comportamento diferentes por nivel em vez de apenas trocar sprite.
- Removida do script base de aliados a tabela rigida que trocava sprite por nivel.
- Gerada primeira folha real de monstros Nv.3 em `sprites/enemies/level_3/`.
- Criadas cenas `*AllyLevel3.tscn` para todos os tipos, com sprites mais ameacadoras e stats mais fortes.
- A factory de aliados agora escolhe cenas concretas para Nv.1, Nv.2 e Nv.3.
- Implementada primeira versao das habilidades finais Nv.3:
  - Slime: golpe em arco/area curta.
  - Bat: cacada em cadeia.
  - Boar: investida com rastro sismico.
  - Totem: aura maior e mais duradoura.
  - Spitter: tiro dividido.
  - Crawler: rastro venenoso maior.
  - Shield: barreira circular com feedback ao empurrar.

### Entregas candidatas

- Definir roster final de monstros antes de gerar sprites.
- Definir como inimigo e aliado se diferenciam visualmente.
- Revisar visual dos aliados em jogo e decidir se a tintura/marca basta ou se precisa de sprites dedicadas.
- Validar em jogo se as sprites Nv.1 estao legiveis na camera atual.
- Validar em jogo as habilidades finais Nv.3 e ajustar exagero/legibilidade.
- Balancear cada cena Nv.2 no Inspector depois da validacao em jogo.
- Balancear cada cena Nv.3 no Inspector depois da validacao em jogo.
- Criar lista completa de sprites necessarios para a versao itch.io.
- Escolher ferramenta principal: Aseprite, Pixelorama, Pix2D ou Piskel.
- Testar um fluxo com IA: gerar base, limpar no editor, importar no Godot.
- Validar no Godot se o halo dos aliados esta forte o bastante sem poluir a tela.
- Validar se o novo Overlord fica bom no tamanho real da camera.

### Validacao planejada

- Player, inimigos, aliados, pickups e mapa devem parecer do mesmo jogo.
- O jogador deve reconhecer rapidamente quem e aliado, inimigo e pickup.
- Um sprite em canvas 64x64 deve continuar legivel no zoom atual do jogo.

## Sprint 16 - Arenas e mapa

Objetivo: sair de um unico campo vazio para arenas com identidade e leitura.

Status: primeira versao implementada em 2026-06-06; precisa validacao e polimento.

### Entregue ate agora

- Criar sistema simples de selecao/carregamento de arena.
- Implementar 3 arenas: Cemiterio dos Fracos, Bosque das Ossadas e Ruinas do Overlord.
- Dar tamanhos e densidades diferentes para cada arena.
- Adicionar decoracao sem colisao para identidade visual.
- Garantir que a camera e spawn funcionem bem em cada arena.
- Nova cena raiz `World/ArenaRoot` em `scenes/Game.tscn`.
- Novo script `scripts/game/arena.gd` com tamanho, bounds globais e area segura de spawn.
- `Game` agora tem `arena_id` exportado para trocar a arena no Inspector.
- Spawns comuns e spawn do Totem sao presos aos limites seguros da arena.
- Camera do jogador usa os limites da arena carregada.
- Jogador fica preso dentro dos limites da arena enquanto ainda nao temos paredes/colisoes de mapa.

### Validacao planejada

- As 3 arenas parecem diferentes.
- Cada arena muda um pouco o ritmo da run.
- Nenhuma arena cria travamentos ou becos injustos.

## Sprint 17 - Legibilidade da horda e selecao de fase

Objetivo: deixar claro quem pertence a horda aliada e permitir escolher uma arena sem mexer no Inspector.

Status: primeira versao implementada em 2026-06-06; precisa validacao em jogo.

### Entregue ate agora

- Aliados ganharam identificacao visual redundante:
  - contorno ciano baseado na sprite;
  - ring ciano no chao;
  - marcador amarelo acima da criatura.
- O ring e o marcador acompanham o nivel visual do aliado.
- Tela inicial ganhou seletor de fase com as 3 arenas existentes.
- Selecionar uma fase antes de iniciar recarrega a arena no `World/ArenaRoot`.
- O seletor fica desabilitado quando a run comeca.

### Validacao planejada

- O jogador deve reconhecer aliados rapidamente mesmo quando o inimigo tem sprite parecida.
- O ring nao pode poluir demais a tela quando a horda crescer.
- O jogador deve conseguir testar as 3 arenas pela tela inicial.

## Sprint 18 - Objetos de mapa

Objetivo: adicionar coisas no mapa que mudam movimento e geram recompensas.

Status: planejada.

### Entregas candidatas

- Objetos com colisao: arvores, pedras, colunas ou ruinas.
- Objetos quebraveis: lapides, vasos, ossarios ou altares frageis.
- Quebraveis podem dropar vida, XP ou ima de almas.
- Inimigos e player devem respeitar colisao.
- Aliados devem continuar legiveis perto dos obstaculos.

### Validacao planejada

- Obstaculos mudam rotas sem frustrar.
- Quebraveis sao entendidos como objetos atacaveis.
- Pickups gerados por quebraveis funcionam corretamente.

## Sprint 19 - Habilidades finais Nv.3

Objetivo: fazer cada criatura nivel 3 parecer uma conquista forte e visualmente especial.

Status: planejada.

### Entregas candidatas

- Slime Nv.3: golpe em arco. Primeira versao implementada.
- Bat Nv.3: caçada em cadeia. Primeira versao implementada.
- Boar Nv.3: investida sismica. Primeira versao implementada como rastro durante a investida.
- Totem Nv.3: aura dupla. Primeira versao implementada como aura maior/mais duradoura; ainda falta visual de aura dupla real.
- Spitter Nv.3: tiro dividido. Primeira versao implementada.
- Crawler Nv.3: rastro venenoso maior. Primeira versao implementada.
- Shield Nv.3: barreira circular. Primeira versao implementada como push maior com pulso visual.

### Validacao planejada

- Chegar ao nivel 3 muda a forma como aquele aliado luta.
- O efeito final deve ser percebido sem ler debug.
- Habilidades finais nao quebram performance nem legibilidade.

## Sprint 20 - Feedback visual de coleta e cura

Objetivo: melhorar a satisfacao visual das recompensas principais.

Status: planejada.

### Entregas candidatas

- XP voa visualmente ate o jogador quando magnetizado ou coletado por ima.
- Efeito de absorcao no jogador ao receber XP.
- Efeito de cura no jogador ao coletar vida.
- Efeito melhor para pickup de ima de almas.
- Efeito de quebra para objetos quebraveis.

### Validacao planejada

- Coletar XP e pickups deve parecer gostoso.
- Efeitos nao podem esconder essencias ou inimigos.

## Sprint 21 - Balanceamento de run de 5 minutos

Objetivo: ajustar pressao, drops, XP, upgrades, capturas, fusoes, mapas e objetos para uma partida curta mais consistente.

Status: planejada.

### Entregas candidatas

- Ajustar chances de essencia, vida e coleta global.
- Ajustar curva de XP e frequencia de level up.
- Ajustar spawn e limite de inimigos por minuto por arena.
- Revisar dano/vida dos tipos de inimigos e aliados.
- Definir metas simples de balanceamento: facil, medio e dificil.

### Validacao planejada

- Uma run de 5 minutos deve ter pelo menos algumas escolhas de build.
- O jogador deve conseguir sobreviver se jogar bem.
- A tela nao deve ficar ilegivel por excesso de aliados/inimigos.

## Sprint 22 - Objetivo final da run

Objetivo: substituir ou complementar a vitoria temporaria por um encerramento mais jogavel.

Status: planejada.

### Entregas candidatas

- Chefe simples ou onda final aos 5 minutos.
- Condicao de vitoria mais clara.
- Recompensa visual ao vencer.

### Validacao planejada

- A partida deve ter um climax reconhecivel.
- A horda montada deve importar no final.

## Sprint 23 - Tela de composicao e resultados

Objetivo: mostrar melhor o que o jogador montou durante a run.

Status: planejada.

### Entregas candidatas

- HUD ou painel simples de composicao por tipo e nivel.
- Tela final mostrando aliados por tipo, fusoes, capturas recusadas/coletadas e upgrades escolhidos.
- Melhorar nomenclatura dos tipos para ficar consistente.

### Validacao planejada

- O jogador consegue explicar qual build montou depois da run.
- A tela final da vontade de tentar outra composicao.

## Sprint 24 - Feedback audiovisual minimo

Objetivo: adicionar feedback sensorial suficiente para o jogo parecer menos seco.

Status: planejada.

### Entregas candidatas

- Sons simples para XP, captura, level up, upgrade, dano e derrota.
- Pequenos efeitos visuais para pickup de vida e coleta global.
- Feedback especial para fusao de aliados.
- Shake leve ou flash controlado para eventos importantes.

### Validacao planejada

- Coletar, converter, fundir e subir de nivel devem parecer satisfatorios.
- Feedback nao pode atrapalhar leitura com muitos personagens.

## Sprint 25 - Build itch.io

Objetivo: preparar uma primeira versao compartilhavel.

Status: planejada.

### Entregas candidatas

- Revisar controles PC/Web.
- Criar tela de creditos simples.
- Preparar export Web.
- Testar tamanho de tela e leitura no navegador.
- Escrever pagina curta de itch.io com controles e proposta.

### Validacao planejada

- Outra pessoa consegue abrir, entender e jogar sem explicacao direta.

## Backlog pos-MVP

Considerar apenas depois das sprints de UI, balanceamento e export jogavel:

- Multiplos mapas.
- Loja permanente.
- Arvore de habilidades.
- Multiplayer.
- Crafting.
- Historia longa.
- Boss final completo.
- Audio completo.
- Export itch.io.

## Checklist do MVP obrigatorio

- [x] Personagem andando.
- [x] Ataque automatico.
- [x] Pelo menos 2 inimigos.
- [x] Pelo menos 4 inimigos.
- [x] Inimigos tomando dano e morrendo.
- [x] Chance de conversao.
- [x] Aliados orbitando o jogador.
- [x] Aliados atacando inimigos.
- [x] XP.
- [x] Level up.
- [x] Pelo menos 8 upgrades.
- [x] HUD funcional.
- [x] Tela de derrota completa.
- [x] Reinicio rapido.
- [x] Partida de pelo menos 5 minutos validada como MVP.
