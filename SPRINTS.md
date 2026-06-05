# SPRINTS.md

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

### Como testar

1. Abrir o projeto no Godot.
2. Rodar a cena principal.
3. Mover com WASD ou setas.
4. Observar o ataque automatico acertando slimes.
5. Derrotar slimes ate alguns virarem aliados verdes.
6. Confirmar que aliados orbitam e causam dano em inimigos proximos.
7. Deixar inimigos encostarem no jogador para testar dano e derrota.
8. Apertar R para reiniciar.

### Decisoes tomadas

- Os personagens sao desenhados por script com circulos coloridos para acelerar o loop jogavel.
- Colisao fisica ainda nao e o foco; dano por contato e acerto de projetil usam distancia.
- A primeira formacao de aliados usa orbita, como recomendado no GDD.
- Existe apenas um tipo de inimigo por enquanto: slime.
- Ainda nao foram implementados XP, level up, upgrades ou menus, pois pertencem a Sprint 2.
- Aliados ja causam dano em inimigos proximos, mas ainda precisam de feedback visual de ataque para o jogador perceber melhor.

## Sprint 2 - Loop completo

Objetivo: transformar o prototipo em uma partida curta com progressao basica.

Status: concluida em 2026-06-05.

### Entregue nesta sprint

- Cristais de XP dropam quando slimes morrem.
- Cristais sao coletados por proximidade.
- Cristais sao atraidos quando o jogador chega perto.
- HUD mostra nivel e progresso de XP.
- Jogador sobe de nivel ao completar a barra.
- Aviso simples aparece ao subir de nivel.
- Estrutura de arquivos reorganizada: entidades em `scenes/entities/` e `scripts/entities/`, jogo/gerenciadores em `scripts/game/`.
- Corrigida dependencia fragil do tipo global `XPOrb` em `game.gd`; o jogo agora conversa com a cena de XP por contrato de metodo/sinal.
- Cristais de XP ficaram maiores, com brilho e contorno para melhorar leitura.
- Fundo da partida agora considera o zoom da camera para evitar a sensacao de "janela" cinza movel.
- Level up agora pausa a partida e oferece 3 upgrades.
- Implementados 8 upgrades basicos: dano do orbe, velocidade de ataque, velocidade do jogador, chance de conversao, limite de aliados, dano dos aliados, vida maxima e alcance de coleta.
- Gameplay foi agrupado em `World`, permitindo pausar inimigos, aliados, projetis e XP juntos durante a escolha de upgrade.
- Spawn de inimigos agora acontece fora da area visivel da camera com margem segura.
- `Player.tscn` e `XPOrb.tscn` passaram a ter nos `Visual` editaveis no editor, reduzindo uso de desenho escondido em script.
- HUD de debug mostra valores usados pelo codigo para validar comportamento em jogo.
- Dano por contato foi centralizado no `Game`: se houver inimigo encostando, aplica dano fixo por tick.
- Inimigos ganharam separacao simples para evitar pilhas visualmente perfeitas.

## Sprint 3 - Conteudo e organizacao de inimigos

Objetivo: com o loop base funcionando, comecar a adicionar conteudo pequeno e organizado sem perder legibilidade.

Status: em andamento.

### Entregue nesta sprint

- Criada uma cena concreta para cada inimigo: `Slime.tscn` e `Bat.tscn`.
- Criado um script base compartilhado para inimigos em `scripts/entities/enemies/enemy.gd`.
- Cada cena de inimigo guarda seus proprios valores: vida, velocidade, dano de contato, XP, cores e separacao.
- Slime teve separacao reduzida para evitar espalhamento exagerado.
- Morcego implementado como segundo inimigo simples: mais rapido, menos vida e cor roxa.
- Spawn agora escolhe slimes no comeco e passa a misturar morcegos depois de alguns segundos.
- Debug mostra quantidade de slimes, quantidade de morcegos e ultimo tipo spawnado.

### Proximas entregas

- Tela de derrota com estatisticas.
- Feedback visual para ataque dos aliados.

## Sprint 4 - Aliados por tipo

Objetivo: garantir que a mecanica principal de conversao preserve a identidade visual do inimigo convertido.

Status: em andamento.

### Entregue nesta sprint

- Criadas cenas concretas de aliados: `SlimeAlly.tscn` e `BatAlly.tscn`.
- Criado padrao de script base compartilhado para aliados em `scripts/entities/allies/ally.gd`.
- Conversao agora escolhe a cena aliada pelo `enemy_type`.
- Bat convertido agora vira bat aliado, nao slime aliado.
- Debug mostra quantidade de aliados slime, aliados bat e ultima conversao.

### Proximas entregas

- Tela de derrota com estatisticas.
- Feedback visual mais claro para ataque dos aliados.
