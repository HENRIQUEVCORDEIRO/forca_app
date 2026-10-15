INTEGRANTES:

- Felipe Martins dos Santos Silva
- Henrique Veras Cordeiro
- Jordan Fernandes de Carvalho
- Antônio Ivo da Silva Gomes

# forca_app

Versão mobile do tradicional jogo da forca para Android, desenvolvido em Flutter e Dart como parte da primeira avaliação da disciplina de Programação Mobile (2026.2). Funciona totalmente offline, com respostas, categorias, níveis e dicas carregados de um arquivo JSON local.

## Principais funcionalidades

- Escolha da categoria e do nível de dificuldade antes de iniciar a partida
- Respostas com uma ou mais palavras, com espaços e hífens exibidos automaticamente
- Comparação de letras ignorando acentuação (por exemplo, Ç e C contam como a mesma letra)
- Forca desenhada progressivamente a cada erro, com limite de cinco tentativas
- Sistema de dicas, liberado uma vez por rodada
- Condição de vitória ao descobrir todas as letras da resposta

## Tecnologias utilizadas

- Flutter 3.47.3
- Dart 3.13.3

## Como executar

1. Clone o repositório: `git clone https://github.com/HENRIQUEVCORDEIRO/forca_app`
2. Entre na pasta do projeto: `cd forca_app`
3. Baixe as dependências: `flutter pub get`
4. Inicie em um dispositivo ou emulador Android: `flutter run`

## Verificação do projeto

- `flutter analyze` — análise estática, executada sem erros nem avisos
- `flutter test` — suíte de testes automatizados

## Estrutura da aplicação

```
pubspec.yaml                            # nome do pacote, dependências e declaração de assets
analysis_options.yaml                   # regras do analyzer (flutter_lints) e pastas excluídas
.gitattributes                          # normaliza fim de linha: LF no repositório, nativo no checkout
.gitignore                              # ignora .dart_tool/, build/ e arquivos gerados
.metadata                              # controle de versão do Flutter (gerado automaticamente)

lib/
├── main.dart                           # app, seleção de categoria/dificuldade, rota e estado da rodada
├── domain/                             # regras de negócio puras, sem depender do Flutter
│   ├── answer_category.dart            # enum das categorias, com rótulo em português
│   ├── difficulty.dart                 # enum das dificuldades, com rótulo em português
│   ├── answer_character.dart           # um caractere da resposta: letra ou caractere estrutural
│   ├── letter_normalizer.dart          # converte uma letra acentuada na sua base sem acento
│   └── hangman_entry.dart              # entrada tipada: resposta, categoria, dificuldade e dicas
├── data/                               # leitura e validação da origem dos dados
│   ├── entries_load_exception.dart     # exceção única para toda falha de carregamento
│   └── hangman_entries_repository.dart # carrega o JSON do asset e valida cada entrada
├── screens/
│   └── game_screen.dart                # a tela do jogo: tabuleiro, forca, teclado e dica
├── widgets/                            # peças visuais reutilizáveis
│   ├── answer_board.dart               # tabuleiro com as letras da resposta e o '_' das ocultas
│   ├── hangman_character.dart          # anima os quadros da forca conforme o número de erros
│   ├── hint_panel.dart                 # botão e cartão que exibem a dica
│   └── letter_keyboard.dart            # teclado QWERTY com marcação das letras já usadas
├── controllers/
│   └── game_controller.dart            # estado da rodada: categoria, dificuldade e erros
└── theme/
    └── app_theme.dart                  # cores, fontes e ThemeData do aplicativo

assets/
├── data/
│   └── hangman_entries.json            # as 120 respostas com categoria, dificuldade e dicas
└── images/character/frames/             # quadros da animação da forca

test/                                   # espelha a pasta lib/ arquivo a arquivo
android/                                # projeto nativo do Android, gerado pelo Flutter
docs/                                   # enunciado da avaliação
```
