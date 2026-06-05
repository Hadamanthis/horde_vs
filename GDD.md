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

Quando um inimigo morre, existe uma chance de ele virar aliado.

### Regras

* Apenas inimigos comuns podem ser convertidos no MVP.
* Chefes não podem ser convertidos.
* Se o jogador atingiu o limite de aliados, o inimigo não é convertido.
* A chance de conversão pode aumentar com upgrades.
* Inimigos convertidos mantêm uma versão simplificada de sua habilidade original.

### Exemplo

Um slime inimigo anda até o jogador e causa dano por contato.
Quando convertido, vira um slime aliado que segue o jogador e bate em inimigos próximos.

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

Ao subir de nível, aparecem 3 opções de upgrade.

### Regras

* O jogo pausa durante a escolha.
* O jogador escolhe 1 upgrade.
* Upgrades podem ser comuns, raros ou lendários.
* No MVP, não precisa mostrar raridade visual complexa.

## 17. Upgrades

### 17.1 Upgrades do jogador

* +10% velocidade
* +15% dano do orbe
* +10% velocidade de ataque
* +1 projétil
* +20 vida máxima
* +10% alcance de coleta

### 17.2 Upgrades de conversão

* +10% chance de conversão
* +3 limite de aliados
* aliados causam +15% dano
* aliados recebem +20% vida
* aliados atacam +10% mais rápido
* aliados explodem ao morrer

### 17.3 Upgrades especiais

#### Horda Faminta

Aliados causam mais dano quanto maior for a quantidade de aliados ativos.

#### Pacto Instável

Aumenta muito a chance de conversão, mas reduz a vida máxima do jogador.

#### Fusão Sombria

A cada 3 aliados do mesmo tipo, eles se fundem em uma versão maior e mais forte.

Para o MVP, a fusão pode ficar como stretch goal.

## 18. Sistema de fusão

### Status

Não obrigatório para o primeiro MVP.

### Conceito

Quando o jogador possui 3 aliados iguais, eles podem virar uma versão superior.

Exemplo:

3 slimes pequenos viram 1 slime grande.

### Benefício

* menos poluição visual;
* sensação de evolução;
* cria objetivo secundário.

### Risco

Pode complicar o balanceamento.

### Recomendação

Implementar apenas depois que o loop base estiver divertido.

## 19. Mapa

### MVP

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

## 20. Arte

### Direção visual

Pixel art simples ou arte 2D minimalista.

### Recomendação para iniciante

Usar sprites pequenos e simples:

* personagem 16x16 ou 32x32;
* inimigos 16x16 ou 32x32;
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
* 4 inimigos;
* 3 tipos de aliados;
* 1 boss;
* 12 a 15 upgrades;
* tela inicial;
* tela de vitória;
* tela de derrota;
* música;
* efeitos sonoros;
* página da itch.io com descrição, controles e GIF curto.

## 28. Stretch goals

Adicionar apenas se o jogo base já estiver divertido.

* sistema de fusão de aliados;
* mais um personagem jogável;
* upgrades raros;
* mapa alternativo;
* conquistas internas;
* salvamento de recorde;
* modo infinito;
* efeitos de partículas melhores;
* tela de estatísticas pós-jogo.

## 29. O que não fazer na primeira versão

Evitar:

* múltiplos mapas;
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

Solução: fechar a primeira versão com apenas 1 mapa, 4 inimigos e 1 personagem.

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
