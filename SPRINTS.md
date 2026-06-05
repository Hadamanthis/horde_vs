# SPRINTS.md

Roadmap de desenvolvimento de **Horda Reversa**.

Principio geral: cada sprint deve terminar com algo jogavel e validavel no Godot. Sistemas grandes devem ser quebrados em entregas menores.

## Estado atual

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

### Estrutura atual importante

- Cena principal: `scenes/Game.tscn`.
- Entidades reutilizaveis: `scenes/entities/`.
- Inimigos concretos: `scenes/entities/enemies/`.
- Aliados concretos: `scenes/entities/allies/`.
- Scripts de entidades: `scripts/entities/`.
- Script principal/orquestrador: `scripts/game/game.gd`.
- Gameplay pausavel fica sob o no `World`.
- HUD e controladores ficam fora do `World`.

### Proxima prioridade

Sprint 7: progressao de partida curta rumo ao MVP de 5 minutos.

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

Status: planejada.

### Entregas propostas

- Controlar progressao por tempo.
- Ajustar spawn rate ao longo da partida.
- Ajustar limite de inimigos vivos.
- Definir meta inicial de duracao: 5 minutos.
- Preparar condicao simples de vitoria temporaria, se necessario.

### Validacao

- Partida dura alguns minutos sem quebrar.
- Pressao aumenta com o tempo.
- Debug permite acompanhar spawn e contagens.

## Sprint 8 - Terceiro inimigo ou tela inicial

Objetivo: escolher o proximo ganho de produto depois do loop estar mais estavel.

Status: planejada.

### Opcoes

- Opcao A: terceiro inimigo simples.
- Opcao B: tela inicial com jogar e sair.
- Opcao C: melhorar HUD normal e separar HUD debug.

### Criterio de escolha

Escolher a opcao que mais ajudar a validar o jogo com outra pessoa jogando sem explicacao direta.

## Backlog fora do MVP atual

Nao implementar antes do loop base estar divertido:

- Fusao de aliados.
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
- [x] Inimigos tomando dano e morrendo.
- [x] Chance de conversao.
- [x] Aliados orbitando o jogador.
- [x] Aliados atacando inimigos.
- [x] XP.
- [x] Level up.
- [x] Pelo menos 8 upgrades.
- [x] HUD funcional.
- [ ] Tela de derrota completa.
- [x] Reinicio rapido.
- [ ] Partida de pelo menos 5 minutos balanceada.
