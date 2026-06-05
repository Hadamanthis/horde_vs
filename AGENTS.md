# AGENTS.md

## Projeto

Estamos construindo **Horda Reversa**, um survivor-like 2D/top-down em Godot 4.6.

A ideia central do jogo é: inimigos derrotados podem ser convertidos em aliados, formando uma horda que cresce visualmente e ajuda o jogador a sobreviver.

## Contexto importante

- O projeto começou como um plataforma 2D de estudo, com pinguim, esqueleto, pulo, mapas e fim de fase.
- A partir do `GDD.md`, a direção atual é mudar para um jogo top-down survivor-like.
- Trate o código atual de plataforma como material de aprendizado/reaproveitamento, não como arquitetura final obrigatória.
- O usuário é iniciante em desenvolvimento de jogos, mas já programa para web. Explique decisões de engine, cenas, nós e sinais quando isso ajudar.

## Prioridades de design

1. Loop jogável antes de conteúdo.
2. Escopo pequeno e terminável.
3. Uma mecânica principal forte: converter inimigos em aliados.
4. Visual legível mesmo com muitos personagens na tela.
5. Partidas curtas, inicialmente 5 minutos no MVP e depois 8 a 12 minutos para itch.io.

## Regras de escopo

- Não adicionar sistemas grandes antes do loop base estar divertido.
- Não implementar fusão, múltiplos mapas, loja permanente, árvore de habilidades, multiplayer, crafting ou história longa no MVP.
- Preferir poucos inimigos bem ajustados a muitos inimigos incompletos.
- Preferir comportamento simples e claro a IA elaborada.
- Quando houver dúvida, seguir o `GDD.md` e registrar ajustes no `SPRINTS.md`.

## Direção técnica

- Engine: Godot 4.6.
- Linguagem: GDScript.
- Primeiro alvo: PC/Web via itch.io.
- Alvo futuro: celular. Evitar decisões que dependam de mouse, teclado complexo ou UI pequena demais.
- MVP sem mira manual: o ataque do jogador deve mirar automaticamente.
- Para aliados, começar com órbita ao redor do jogador por ser mais simples e legível.
- Usar sinais para eventos importantes: morte de inimigo, conversão, coleta de XP, level up, vitória e derrota.
- Manter cenas pequenas e específicas: jogador, inimigo, aliado, projétil, XP, HUD, gerenciadores.
- Tipar explicitamente variáveis, retornos e referências de nós sempre que isso evitar avisos do analisador estático do Godot ou deixar a intenção mais clara.
- Adicionar comentários didáticos nos blocos importantes de código, especialmente quando envolver ciclo de vida da engine, sinais, cenas, nós, estado de jogo ou contas de movimento. Evitar comentários que apenas repetem literalmente a linha.

## Modo de colaboração

- Trabalhar em passos pequenos e jogáveis.
- Ao implementar algo novo, explicar rapidamente o que foi feito e como testar.
- Se uma tarefa ficar grande demais, quebrar em uma entrega menor que rode no Godot.
- Atualizar `SPRINTS.md` quando o planejamento mudar de forma relevante.
