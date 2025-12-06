# CavernaDoDeserto

**Caverna do Deserto** é um jogo de plataforma vertical 2D multijogador competitivo, desenvolvido na **Godot 4** como Trabalho de Conclusão de Curso na UTFPR.

O objetivo é simples: correr até o topo da caverna, coletar o máximo de maçãs e superar os adversários usando habilidade, estratégia e poderes especiais.


## 🎮 Visão Geral

- **Gênero:** Plataforma vertical competitiva (2D)
- **Engine:** Godot 4.4.1
- **Jogadores:** 1 a 4 jogadores em tela dividida (local)
- **Plataforma:** PC (com suporte a controles/joysticks)
- **Contexto:** Projeto acadêmico para divulgação da universidade, do curso de Computação e da área de desenvolvimento de jogos

O jogo combina corrida, saltos de precisão, armadilhas e habilidades especiais em torneios com múltiplas corridas e voltas sucessivas.  
Além de produto jogável, o projeto também teve como foco o aprendizado prático de desenvolvimento de jogos com Godot.


## 🕹️ Jogabilidade

Principais elementos de jogabilidade:

- **Pulo:** mecânica principal para subir de plataforma em plataforma.
- **Pulo duplo:** permite um segundo pulo no ar, alcançando plataformas mais altas.
- **Corrida até o topo:** vence quem chegar primeiro ao ponto de chegada no topo do mapa.
- **Maçãs:** coletáveis espalhados pelo percurso; a quantidade coletada compõe a pontuação do jogador ao fim da corrida.
- **Sistema de voltas:** ao chegar no topo, o percurso é repetido em novas voltas, com maçãs reposicionadas.
- **Torneios:** sequência de múltiplas corridas; as maçãs coletadas são acumuladas e definem o grande vencedor.
- **Placar de líderes (Leaderboard):** registra as pontuações dos torneios concluídos.
- **Múltiplos caminhos:** trechos do mapa oferecem rotas alternativas, algumas mais curtas e/ou com mais itens.
- **Interferência entre jogadores:** habilidades especiais podem ser usadas para atrapalhar rivais e ganhar vantagem.
- **Obstáculos:** poças de lava e espinhos exigem precisão nos saltos ou uso de poderes para serem ignorados.


## ⚡ Habilidades Especiais

As habilidades especiais são itens de efeito temporário, ativados automaticamente ao serem coletados. Elas podem tanto ajudar o jogador quanto atrapalhar os oponentes:

- **Invencibilidade (Escudo):**  
  Garante invulnerabilidade temporária contra danos de obstáculos e projéteis de outros jogadores. Permite atravessar áreas de lava e ignorar ataques.

- **Projétil (Arco e flechas):**  
  Permite lançar projéteis contra adversários, atrasando-os por um curto período de atordoamento.

- **Super Pulo (Bota com asas):**  
  Aumenta a altura do pulo, facilitando alcançar plataformas mais altas e atalhos.

- **Chuva (Nuvem relampejante):**  
  Reduz drasticamente a velocidade de corrida de todos os outros jogadores, criando uma vantagem momentânea para quem ativou o poder.


## 👤 Personagens

Os personagens são conhecidos como **“Competidores Incansáveis”**:

- Até **4 personagens jogáveis**, todos com:
  - Mesmos movimentos e capacidades (equilíbrio e fairness).
  - **Variações de roupas/estilos**, permitindo que mais de um jogador escolha o mesmo personagem e, ainda assim, permaneça visualmente distinto.
- O foco está na **estratégia e uso de habilidades especiais**, não em atributos individuais de personagem.


## 🎮 Controles

Cada jogador utiliza um joystick dedicado. Os esquemas de controle são pré-definidos:

- **Jogador 1:** Joystick 1  
- **Jogador 2:** Joystick 2  
- **Jogador 3:** Joystick 3  
- **Jogador 4:** Joystick 4  

Esquema básico:

| Ação             | Controle                        |
|------------------|---------------------------------|
| Mover            | Direcional / Analógico esquerdo |
| Pular            | Botão principal (ex.: A / X)    |
| Pausar/Confirmar | Botão de Menu / Start           |


## 📺 Câmera e Tela Dividida

- Perspectiva **side view** (visão lateral).
- A tela é dividida em **faixas verticais**, uma para cada jogador.
- Cada jogador enxerga apenas sua própria “fatia” da corrida, podendo estar em pontos diferentes do percurso.
- O tamanho de cada setor varia com a quantidade de jogadores:
  - 2 jogadores → tela dividida em 2 setores.
  - 3 jogadores → 3 setores.
  - 4 jogadores → 4 setores.

Essa abordagem utiliza **SubViewport** na Godot para renderizar múltiplas câmeras simultaneamente.


## 🧱 Inimigos e Obstáculos

- Os principais **“inimigos”** são os **outros jogadores**, que competem diretamente lado a lado.
- O jogo incentiva:
  - Movimentação precisa e decisões rápidas.
  - Uso ofensivo e defensivo das habilidades especiais.
- **Poças de lava** e **espinhos**:
  - Causam atraso/penalidade ao jogador.
  - Podem ser evitados com movimentação precisa.
  - Podem ser ignorados sob efeito de **Invencibilidade**.
  - Podem ser usados taticamente, forçando o oponente a cair em armadilhas com o uso do **Projétil**.


## 🧭 Telas e Fluxo do Jogo

Fluxo principal de telas:

1. **Menu Principal**
   - Iniciar
   - Placar de Líderes
   - Configurações
   - Sair
   - Silenciar música (mantém efeitos sonoros)

2. **Saguão de Jogadores (Lobby)**
   - Definição da quantidade de jogadores (1 a 4).
   - Jogador entra pressionando um botão (ex.: A) no joystick.
   - Inserção de nome do jogador.
   - Escolha de personagem e variação visual.

3. **Corrida**
   - Tela dividida entre os jogadores.
   - Coleta de maçãs, desvio de armadilhas, uso de habilidades especiais.
   - Sistema de voltas até o final do percurso definido.

4. **Tela de Pausa**
   - Retomar corrida.
   - Sair para o Menu Principal.

5. **Tela de Resultados**
   - Pódio com jogadores ordenados por pontuação.
   - Exibição de nomes e quantidade de maçãs.
   - Continuação do torneio ou retorno ao fluxo de jogo.

6. **Placar de Líderes**
   - Exibe as pontuações registradas dos torneios finalizados.


## 🧾 Interface Durante a Corrida

Em cada setor da tela, o jogador consegue ver:

- **Nome do jogador** (canto superior esquerdo).
- **Contador de maçãs** coletadas.
- **Número da volta** atual.
- **Ícone de habilidade especial ativa**, exibido acima do personagem.
- **Ícone de atordoamento** (estrelas) quando:
  - É atingido por projéteis.
  - Cai em armadilhas como poças de lava ou espinhos.


## 🛠️ Tecnologias Utilizadas

- **Godot Engine 4.4.1**
  - GDScript
  - SubViewport (tela dividida)
  - Sistema de física 2D
  - Animações e organização em cenas
- **Pixel Art** para personagens, cenários e interface.
- **Recursos sonoros** compatíveis com a proposta de jogo de plataforma competitivo.


## 📦 Como Executar o Projeto

1. **Clone o repositório:**

   ```bash
   git clone https://github.com/JVZavatin/caverna-do-deserto.git
   cd caverna-do-deserto
