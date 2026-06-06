# Guia de Arte - Horda Reversa

## Direcao

Estilo alvo: **dark fantasy fofo e legivel**.

O jogo deve parecer sombrio, mas simples de ler em movimento. A prioridade e reconhecer rapidamente:

- jogador;
- inimigos;
- aliados;
- essencias;
- pickups;
- obstaculos solidos;
- objetos quebraveis.

## Protagonista

Direcao atual: **Pequeno Overlord**.

Silhueta:

- cabeca de caveira grande;
- manto curto;
- pequena coroa ou marca de comando;
- olhos/energia verde-ciano;
- corpo pequeno para parecer vulneravel no inicio.

O player nao deve parecer um inimigo comum. Ele deve ter caveira clara, manto escuro e energia necromantica.

## Paleta

- Player: osso claro, manto roxo escuro, energia verde-ciano.
- Inimigos: tons quentes, vermelhos, laranjas, roxos ou amarelos hostis.
- Aliados: mesma silhueta do inimigo, mas com contorno/energia verde-ciano.
- XP: amarelo-verde brilhante.
- Essencias: cor por tipo + silhueta do tipo + letra curta.
- Cura: vermelho/rosa claro.
- Ima de almas: azul-ciano.
- Mapas: chao escuro dessaturado com uma cor secundaria por arena.

## Sprites reais

Agora a meta e substituir os placeholders vetoriais por sprites reais.

Tamanho recomendado para a primeira versao, seguindo o Overlord ja criado:

- player: canvas 64x64, sprite ativo perto de 48-56 px;
- inimigos comuns: canvas 64x64, sprite ativo perto de 40-56 px;
- aliados: canvas 64x64, reaproveitando a silhueta do inimigo;
- bosses: canvas 96x96 ou 128x128;
- pickups: 16x16 ou 24x24;
- objetos quebraveis pequenos: 16x16 ou 32x32;
- objetos solidos de mapa: 32x32 ou 48x48;
- tiles de chao: 16x16.

Regras:

- silhueta antes de detalhe;
- contorno escuro para entidades importantes;
- poucos frames de animacao;
- evitar sprites muito finos;
- nao depender de texto para reconhecer tipo durante combate.

### Direcoes e niveis

O Overlord ja existe com varias direcoes, mas isso nao precisa virar exigencia para todos os sprites.

Recomendacao:

- player: pode usar as direcoes existentes, mas tambem pode funcionar com menos se o gameplay nao pedir leitura direcional precisa;
- inimigos/aliados: 1 direcao ou 2 direcoes espelhadas ja bastam para a primeira versao;
- se um monstro precisar de direcao clara por gameplay, criar apenas as direcoes necessarias.

Convencao tecnica:

- sprites que precisam apontar/rotacionar para atacar devem ser desenhados olhando para a direita/leste;
- isso combina com o angulo 0 do Godot 2D e simplifica rotacao por codigo;
- sprites frontais ou estaticos podem ficar sem rotacao, usando no maximo espelhamento horizontal quando ajudar a leitura;
- evitar rotacionar pixel art muito detalhada se a leitura ficar pior em movimento.

Cada monstro deve ter 3 niveis visuais.

Regra recomendada:

- Nv.1: criatura base, mais natural/selvagem, com poucos sinais necromanticos.
- Nv.2: versao tocada pelo Overlord, mantendo a silhueta mas ganhando caveira, osso, rachaduras ou energia ciano/verde.
- Nv.3: forma final necromantica memoravel, ainda reconhecivel como o mesmo monstro.

Direcao nova:

- os sprites atuais com aparencia de caveira/ossos devem ser tratados como referencia de Nv.2;
- a proxima leva deve criar Nv.1 mais simples para cada comportamento;
- o jogador deve sentir que melhorar/fundir aliados esta transformando criaturas comuns em servos cada vez mais necromanticos;
- Nv.3 deve exagerar a fantasia sem perder leitura: chifres, ossos maiores, aura, runas, escudo ritual, gosma espectral etc.

Para reduzir trabalho, comecar com sprite estatico por nivel em uma direcao principal. Animacoes e direcoes extras entram depois.

Aliados podem usar o mesmo sprite do inimigo com:

- contorno verde/ciano;
- olhos/energia aliada;
- pequena marca de conversao;
- aura leve em Nv.2/Nv.3.

### Animacoes minimas

Para a primeira leva de sprites reais:

- idle: 2 frames;
- movimento: 4 frames;
- ataque especial: pode ser efeito separado, nao precisa estar todo no sprite.

Se ficar grande demais, priorizar sprites estaticos fortes antes de animacao.

### Pipeline recomendado

1. Definir roster final de monstros por comportamento.
2. Gerar ou desenhar 1 sprite estatico Nv.1 para cada criatura.
3. Revisar silhueta em Godot.
4. Criar Nv.2 e Nv.3.
5. Criar versoes aliadas por recolor/contorno.
6. So depois animar ou criar direcoes extras, se o monstro realmente precisar.

## Ferramentas sugeridas

### Editor principal

Usar **Aseprite** se puder comprar. E o padrao mais confortavel para pixel art, animacao e export de spritesheet.

Alternativas gratuitas:

- **Pixelorama**: open source, bom para animacao, camadas, tilemaps e exportacao.
- **Pix2D**: gratuito/open source, roda online e desktop.
- **Piskel**: simples, online, bom para comecar rapido e exportar spritesheets.

### IA para gerar base

Usar IA como rascunho/base, nao como asset final direto.

Ferramentas candidatas:

- **SpriteLab**: focada em sprites pixel art, transparencia, animacao e rotacao.
- **PixelLab.ai** ou ferramentas similares: boas para explorar conceitos e variações.
- **ChatGPT/image generation**: bom para conceito visual e exploracao de direcao, mas o resultado precisa ser limpo em editor pixel art.

Regra: toda arte gerada por IA deve passar por limpeza manual para garantir grade, paleta, silhueta e consistencia.

## Roster visual proposto

Os comportamentos do prototipo podem continuar, mas os nomes/monstros devem ficar mais memoraveis.

### Slime

Manter. E simples, legivel e bom para ensinar o loop.

Papel: enxame corpo a corpo.

### Bat

Manter ou virar **Morcego de Osso**.

Papel: cacador rapido.

### Boar

Trocar visualmente. O comportamento de investida e bom, mas "boar" e pouco memoravel para o tema.

Opcoes melhores:

- **Carneiro Caveira**: chifres, investida clara, silhueta forte.
- **Caveira Chifruda**: cabeca flutuante que avanca.
- **Cervo Ossudo**: mais estranho e necromantico, mas pode ser menos legivel.

Recomendacao: **Carneiro Caveira**.

### Totem

Manter como **Totem Profano**.

Papel: area/territorio.

### Spitter

Trocar nome/visual para **Cuspideira Ossaria** ou **Crânio Cuspidor**.

Papel: atirador.

### Crawler

Trocar visual para **Verme de Ossos** ou **Rastejante Putrido**.

Papel: rastro/controle de chao.

Recomendacao: **Verme de Ossos**.

### Shield

Trocar visual para **Guardiao Escudo** ou **Caveira Guardiã**.

Papel: defesa/bloqueio.

Recomendacao: **Guardiao Escudo**.

## Progressao visual por nivel

Regra geral: Nv.1 deve parecer a criatura antes da influencia forte do Overlord; Nv.2 usa a direcao atual de caveira/ossos; Nv.3 exagera a forma necromantica e deve combinar com a habilidade final.

### Slime

- Nv.1: gosma simples, arredondada, sem caveira, com olho ou brilho fraco.
- Nv.2: slime com cranio/mascara ossea dentro da gosma.
- Nv.3: gosma espectral maior com mandibula ou arco de osso para justificar golpe em arco.

### Bat

- Nv.1: morcego escuro simples, asas grandes e corpo pequeno.
- Nv.2: morcego de osso, com cranio e costelas aparentes.
- Nv.3: morcego espectral com asas rasgadas e rastro ciano, bom para cacada em cadeia.

### Carneiro

- Nv.1: carneiro/fera de investida, chifres claros, ainda vivo ou sombrio.
- Nv.2: carneiro caveira, com cranio e chifres mais duros.
- Nv.3: carneiro necromantico pesado, chifres rachados com energia, bom para investida sismica.

### Totem

- Nv.1: totem de madeira/pedra escura com simbolo simples.
- Nv.2: totem profano com caveira, ossos e runas.
- Nv.3: altar pequeno flutuante ou totem duplo, com aura ritual clara.

### Spitter

- Nv.1: criatura cuspideira pequena, boca/bico claro, sem caveira dominante.
- Nv.2: cranio cuspidor ou cuspideira ossaria.
- Nv.3: cranio maior rachado com duas mandibulas ou tres focos de tiro, bom para tiro dividido.

### Crawler

- Nv.1: verme/rastreador putrido simples, baixo e comprido.
- Nv.2: verme de ossos, com segmentos de costela.
- Nv.3: centopeia necromantica curta com espinhos e rastro venenoso forte.

### Shield

- Nv.1: guardiao pequeno com escudo bruto, mais pedra/metal do que caveira.
- Nv.2: guardiao escudo com mascara de caveira.
- Nv.3: guardiao ritual com escudo circular/ossario, bom para barreira circular.

## Assets conceituais gerados

Primeira folha de conceitos criada em:

- `sprites/enemies/concepts/enemy_roster_sheet_magenta.png`: folha original com fundo magenta para recorte.
- `sprites/enemies/concepts/enemy_roster_sheet_transparent.png`: folha com transparencia.
- `sprites/enemies/concepts/enemy_roster_concepts_64.png`: folha de comparacao em canvas 64x64.
- `sprites/enemies/concepts/individual/`: recortes individuais 64x64.
- `sprites/enemies/level_1/enemy_roster_level_1_magenta.png`: folha original dos monstros Nv.1.
- `sprites/enemies/level_1/enemy_roster_level_1_transparent.png`: folha Nv.1 com transparencia.
- `sprites/enemies/level_1/enemy_roster_level_1_64.png`: folha Nv.1 em celulas 64x64.
- `sprites/enemies/level_1/individual/`: recortes individuais Nv.1 em 64x64.
- `sprites/enemies/level_3/enemy_roster_level_3_magenta.png`: folha original dos monstros Nv.3.
- `sprites/enemies/level_3/enemy_roster_level_3_transparent.png`: folha Nv.3 com transparencia.
- `sprites/enemies/level_3/enemy_roster_level_3_64.png`: folha Nv.3 em celulas 64x64.
- `sprites/enemies/level_3/individual/`: recortes individuais Nv.3 em 64x64.

Ordem da folha:

1. Slime
2. Morcego de Osso
3. Carneiro Caveira
4. Totem Profano
5. Cranio Cuspidor
6. Verme de Ossos
7. Guardiao Escudo

Observacoes:

- Slime, Carneiro Caveira, Cranio Cuspidor e Guardiao Escudo parecem mais fortes como primeira direcao.
- Morcego de Osso e Verme de Ossos podem precisar de nova iteracao para ficarem mais memoraveis.
- Usar magenta `#ff00ff` como chroma key quando houver sprites verdes.
- Inimigos comuns e aliados Nv.1 usam os recortes de `level_1`.
- Aliados Nv.2 usam cenas concretas `*AllyLevel2.tscn`, com sprites de `concepts/individual`, stats e parametros proprios.
- Aliados Nv.3 usam cenas concretas `*AllyLevel3.tscn`, com sprites de `level_3/individual`, stats mais agressivos e silhuetas mais ameacadoras.
- Evitar trocar apenas sprite por codigo para representar evolucao; cada nivel importante deve virar uma entidade/cena ajustavel no Inspector.

## Arenas

### Cemiterio dos Fracos

Cor secundaria: verde musgo/cinza frio.

Elementos:

- lapides;
- ossos;
- terra escura;
- pequenas ruinas.

### Bosque das Ossadas

Cor secundaria: verde seco/azul escuro.

Elementos:

- arvores secas;
- troncos;
- pedras;
- clareiras.

### Ruinas do Overlord

Cor secundaria: ciano/roxo magico.

Elementos:

- colunas quebradas;
- altares;
- simbolos no chao;
- pedras antigas.

## Objetos

Objetos solidos devem parecer pesados: arvores grossas, pedras grandes, colunas.

Objetos quebraveis devem parecer frageis: lapides rachadas, vasos, ossarios, altares pequenos.

## Efeitos

Prioridade:

1. XP indo ate o jogador.
2. Cura no jogador.
3. Fusao de aliados.
4. Captura de essencia.
5. Quebra de objetos.

Efeitos devem ser curtos, claros e nao esconder inimigos.
