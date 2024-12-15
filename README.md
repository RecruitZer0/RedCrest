# Começando:

Leia esse aqui para começar a entender como as coisas são escritas em Godot.

[Link](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)


## Pontos Importantes

- Conceito de Nós
	- [Link](https://en.wikipedia.org/wiki/Node_(computer_science))

O que tirar dessa informação.
Todo **nó** em Godot é um object instanciado de uma classe.

> Pra quem veio de [Unity](Eeeeeeewwwwww, porque tu fez isso contigo!), cada "nó" é uma mistura de "prefab" com "scritibable object"

- Conceito de estado de máquina para Player
	- [Link](https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/)
	- Minha sugestão é fazer uma implementação disso usando um **nó** base como `Node2d` ou `Node3d`, muito frequente precisa de `position` para os sub elementos caso tenha.


## Estrutura de arquivos do projeto

Essa é uma sugestão de estrutura de pastas para facilitar a navegação no projecto. Como não tenho certeza de todos os aspecto do projeto, use com parcimônia essa estrutura:

```sh 
- assets
    - _downloaded
    - sfx
    - music
    - graphics
- scenes
- screens
- singleton
```

`assets`: diretório geral para tudo que é asset. Entenda asset como "tudo que não é parte da logica do jogo ou não é parte da engine".

Se a mesma pessoa for responsável por varias partes dos assets (`sfx` e `music`) agrupe isso, para ajudar quem estiver atualizando isso.

Considerando que várias pessoas irão trabalhar no mesmo projeto, os assets podem mudar drasticamente, nesse caso mantenha esse com um sub-diretório para cada assunto ou parte especifica:

```sh
- assets
    - graphics
        - player
        - tilemaps
        - ui_buttons
        - [...cada diretório para uma coisa]
```

`scenes`: Esse diretório é um generalista de elementos usados no `jogo` que não fazem parte de `ui` diretamente. Como por exemplo, coletáveis, personagens, níveis, e todo o resto.

> Pra quem veio da unity, como tudo é um "prefab", organize essa pasta como um repositório de prefabs para fazer instancias dentro do nível, player ou qualquer outro elemento.

Use sub-diretórios para organizar para cada grupo de scenes, por exemplo:

```shser 
- scenes
    - actor
        - actor.tscn
        - actor.gd
        - ...
        - player
            - player.tscn
            - player.gd
```

Nesse caso o `actor` é a classe basica, e o `player` herda de `actor`, e isso é visualizado dentro da estrutura de pasta.

`screen` esse diretório é generalista para todas as "telas" do jogo como por exemplo a Tela de aberta do jogo, um splash screen customizado, tela de opções, tela de fim do jogo, tela de créditos, e todos as outras telas relacionadas.

Como sugestão eu deixaria uma pasta para elementos de UI, para reaprovietar os mesmo elementos ao invés de criar elementos novos em cada tela. 

```sh
- screens
    - ui_elements
        - custom_buttom
        - game_overlay
        - ...
    - start_screen
        - start_screen.tscn
```

`singleton` essa é a pasta para os "autoloads" do godot. (Eu geralmente uso o termo singleton porque é isso o que o autoload é, mas pode usar o termo autoload tbm, importante é entender que essa pasta existe e cada um dos scripts/cenas aqui serão carregados pelo autoload)

> Autoload pode ser uma `scene` ao invés de um `script`. USE ISSO!

Minha sugestão de autoloads

```sh
- singleton
    - scene_manager
    - audio_manager
    - game_manager
```

`SceneManager`: Responsável por fazer a transição entre cenas. Ele tbm pode ter elementos para fazer o fade-in/out da tela, sabe como carregar os recursos ou quando inicia já carrega todos os níveis (não recomendo, mas dependendo do tamanho pode ser uma opção), mostra o "loading" em caso de necessidade.

`AudioManager`: responsável por fazer os barulhos, se for música ele tem tbm um _AudioPlayer_ tocando a musica, como ele é um singleton, mesmo que o level faça reload o estado do player de musica não muda e a musica continua tocando. Ele tbm irá reproduzir os efeitos sonoros. Pode criar dinamicamente a classe de `AudioPlayer` e fazer a instancia (e tbm remover quando o efeito terminar), ou deixar alguns `AudioPlayer` já prontos e rotacionar um a um, em caso de necessidade. Essa classe tbm será responável por guardar os valores de "volume", assim como ter uma referncia para o `AudioBus` e ajustar o volume de forma adequada.

> Dica: Volume funciona em _db_ que usa uma escala logaritica, o Godot já tem uma função para converter `db_linear` e o oposto `linear_db`.

`GameManager`: responsável pelas regras do jogo, essa é a classe que vai ter a referencia do jogador, fazer o spawn/remove to jogador, controlar quando e como fazer a troca de níveis, e tbm será responsável por fazer pausa ou qualquer outro controle do jogo. Minha recomendação é deixar aqui tbm uma referencia da `Camera` que está sendo usada, e quando precisar acionar a camera pegar a referencia direto desse singleton, o mesmo para o player.

> Minha sugestão caso precise. Use singleton para exibir dialogos no jogo, deixando separado.

## Estrutura de Código

Estou assumindo que o jogo será um _beat-em up_, essa é minha sugestão inicial, não sei quais problemas serão encontrados no caminho, e caso tenha problema em algum momento é procurar uma solução ideal para isso.

`BaseLevel`: Classe responsável por ter os métodos de `spawn` do player, fazer o reload to nível caso necessário, ou transitar para o próximo nível (isso pode ser delegado para uma outra classe), adicione uns `@export` para colocar os nós da posição inicial do player e tbm para colocar a game camera.

Sugestão de estrutura, irei colocar o nome da classe (e em parenteses de quem ela herda se não for nativo, se herdar de multiplos irei colocar uma seta de quem herda).

```sh
- BaseLevel(Node)
    - GameCamera(Camera)
    - LevelLayout(Node)
        - Player(Actor -> Character)
        - Enemies(Actor -> Character)
    - PlayerStartPos(Marker)
```

Com uma estrutura simple assim se pode colocar o que precisar dentro do nível e organizar ele.

`GameCamera`: Classe para a camera, colocar funcões para `Shake`, `Zoom` e talvez pequenas alterações de perpectiva (caso precise). Herda da camera base (2d ou 3d).

`LevelLayout`: Classe base com o modelo do layout da fase, dependendo de quem for fazer os níveis vale a pena fazer varias instancias da classe base para cada nivel, Dependendo de quem for fazer, deixe os inimigos como parte desse arquivo, ou deixe a logica para isso para o `BaseLevel` caso os inimigos precisem fazer `Spawn`/`Despawn`.

`Actor`: Classe base para o player e inimigos. Essa classe é focada no mais basico, movimentação e animações do _ator_ dentro do jogo. O que isso é responsável:

- Movimentação: não acoplado ao jogador ou input do jogador
- Animação: trocar, mudar, e animar

Sugestão de estrutura:

```sh
- Actor(Character)
    - Sprite
    - Sprite, Sombra
    - AnimationPlayer
    - HitBox(Area)
    - HurtBox(Area)
    - StateMachine(Node)
```

Use o `AnimationPlayer` como base para fazer a animação do sprite, minha sugestão é usar o nome do estado como nome da animação para evitar ficar colocando as animação na mão.

Use cena herdada para fazer a cena do `Player` e `BaseEnemy` (Olha no menu Scene -> new Inherited Scene), se precisar entender o conceito veja esse video: [link](https://www.youtube.com/watch?v=qgxDBA9TC6s)

```sh 
- Player(Actor)
    - Health(Node)
    - PlayerInput(Node)
    - StateMachine, que herda do Actor
       - Idle(PlayerState -> BaseState -> Node)
       - Move(PlayerState -> BaseState -> Node)
       - Jump(PlayerState -> BaseState -> Node)
       - ...
```

```sh 
- BaseEnemy(Actor)
    - Health(Node)
    - StateMachine, que herda do Actor
       - Idle, esses estados podem ser agnósticos ao tipo de inimigo, mas isso dá um pouco mais de trabalho
       - Move(EnemyState -> BaseState -> Node)
       - Jump(EnemyState -> BaseState -> Node)
       - ...
```


O resto use os elementos herdados da classe pai.

No caso do player `PlayerInput` é a classe que é reponsável por receber os inputs do controle (e quanto receber ou não em case de cutscene)

Nessa estrutura os estados são o que fazem o grosso do player, `Idle` sabe o que fazer em idle, qual animação usar, e o que fazer quando o player aperta algum botão que o faz trocar de cena, por exemplo. `Move` por exemplo sabe como usar os métodos do `Actor` para mover o nó, e assim por diante. Cada estado deve (em geral) ser o mais atómico possível.

`HitBox` e `HurtBox` são os resposável por enviar o sinal de quando recebem o hit. Aqui é uma escolha pessoal, eu prefiro que o `HitBox` tenha um `resource` ou um `Node` para geração de um `Damage(Resource)` e isso é passado para o `HurtBox` quando recebe dano e o `HurtBox` faz o sinal para com o dano. Nesse caso o `Actor` terá um método para escutar pelo sinal de dano. Eu colocaria um método abstrado no `Actor` e deixo o `Player` e o `BaseEnemy` saber o que fazer com isso.

Como sugestão, coloca um `Timer` dentro do `HurtBox` para ter um _colddown_ ao receber dano, isso para evitar de um hit dar multiplos danos no mesmo alvo.

`StateMachine` é responsável por saber qual é o estado atual e como trocar de estados. Eu prefiro usar nós para manter os estados, fica mais fácil de viualizar os nós no editor, e facilita para quem for dar manutenção de entender. O GDQuest fez um tutorial bom para esse conceito [aqui](https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/). Eu costumo tbm ter uma classe para `BaseState` que tem apenas os métodos para entrar, sair e fazer o update a cada frame. E o `Player` tem o `PlayerState` que tem algumas referencias uteis para o player, e o `EnemyState` tbm para o enemy.

