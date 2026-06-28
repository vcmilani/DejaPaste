# Déjà Paste

Editor de texto simples para macOS que remove automaticamente toda formatação ao colar.

## Funcionalidades

- **Cola sem formatação**: qualquer texto colado (de páginas web, Word, PDF, etc.) é automaticamente convertido para texto puro
- **Copia texto puro**: o botão Copiar garante que o conteúdo vai para o clipboard sem formatação
- **Contador**: mostra caracteres, palavras e linhas em tempo real
- **Suporte a RTF e HTML**: remove formatação de qualquer fonte

## Atalhos de teclado

| Ação | Atalho |
|------|--------|
| Colar como texto puro | ⌘V |
| Copiar | ⌘C |
| Limpar tudo | ⌘⌫ |
| Desfazer | ⌘Z |

## Como abrir no Xcode

1. Abra o arquivo `Déjà Paste.xcodeproj` no Xcode
2. Selecione o target **Déjà Paste**
3. Em **Signing & Capabilities**, selecione seu Apple ID em Team
4. Pressione ⌘R para compilar e executar

## Requisitos

- macOS 13.0 (Ventura) ou superior
- Xcode 15 ou superior

## Estrutura do projeto

```
Déjà Paste/
├── Déjà PasteApp.swift      # Entry point
├── ContentView.swift        # Interface principal
├── EditorViewModel.swift    # Lógica de remoção de formatação
├── PlainTextEditor.swift    # NSTextView com intercepção de paste
└── AppCommands.swift        # Comandos e atalhos do menu
```
