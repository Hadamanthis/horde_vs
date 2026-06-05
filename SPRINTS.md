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

Status: em andamento.

### Entregue nesta sprint

- Cristais de XP dropam quando slimes morrem.
- Cristais sao coletados por proximidade.
- Cristais sao atraidos quando o jogador chega perto.
- HUD mostra nivel e progresso de XP.
- Jogador sobe de nivel ao completar a barra.
- Aviso simples aparece ao subir de nivel.

### Proximas entregas

- 3 opcoes simples de upgrade.
- Pelo menos 8 upgrades no total.
- Limite de aliados ajustavel por upgrade.
- Segundo inimigo simples.
- Tela de derrota com estatisticas.
- Feedback visual para ataque dos aliados.
