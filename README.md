# Organizador de Arquivos

[![Delphi](https://img.shields.io/badge/Delphi-VCL-EE1F35)](https://www.embarcadero.com/products/delphi)
[![Platform](https://img.shields.io/badge/plataforma-Windows-0078D6?logo=windows)](#)

Aplicativo Windows em Delphi VCL para visualizar, renomear e excluir arquivos
em lote com validação prévia e opção de desfazer a última renomeação.

## Funcionalidades

- Prefixo e sufixo personalizados.
- Busca e substituição sem diferenciar maiúsculas e minúsculas.
- Numeração sequencial em ordem alfabética.
- Prévia obrigatória antes da renomeação.
- Validação de nomes reservados, caracteres inválidos e destinos duplicados.
- Confirmação antes de renomear ou excluir permanentemente.
- Registro local para desfazer a última renomeação.
- Visualização interna de arquivos de texto e imagens.
- Abertura de outros formatos pelo aplicativo padrão do Windows.
- Contadores de arquivos prontos e ignorados.

## Arquitetura

O projeto segue uma separação MVC adaptada ao Delphi VCL:

```text
OrganizadorArquivos/
├── src/
│   ├── controllers/
│   │   └── uRenameController.pas
│   ├── models/
│   │   ├── dmFileOrganizerModel.pas
│   │   └── dmFileOrganizerModel.dfm
│   └── forms/
│       ├── frmMain.pas
│       ├── frmMain.dfm
│       ├── frmFileViewer.pas
│       └── frmFileViewer.dfm
├── tests/
│   ├── uRenameControllerTests.dpr
│   └── uRenameControllerTests.pas
├── FileOrganizer.dpr
├── FileOrganizer.dproj
├── FileOrganizer.rc
└── FileOrganizer.RES
```

- **Controller:** calcula a prévia, valida nomes, renomeia, desfaz e exclui.
- **Model/DataModule:** mantém a solicitação e adapta os dados para as Views.
- **Views:** exibem a tela principal e o visualizador interno de arquivos.

As units e seus métodos possuem documentação XMLDoc para navegação e ajuda de
código dentro do Delphi.

## Formatos visualizados internamente

Imagens: BMP, JPG, JPEG, PNG, GIF, ICO, WMF e EMF.

Textos: TXT, LOG, CSV, TSV, JSON, XML, INI, CFG, fontes Delphi, Markdown, SQL,
scripts, HTML, CSS, JavaScript, TypeScript e YAML.

Os demais formatos são abertos por meio da associação padrão do Windows. Uma
mensagem é apresentada quando não existe aplicativo compatível instalado.

## Como executar

1. Abra `FileOrganizer.dpr` no Delphi 13.
2. Escolha Win32 ou Win64.
3. Execute **Project > Build All**.
4. Inicie o aplicativo pelo IDE.
5. Selecione uma pasta e informe pelo menos uma regra de renomeação.
6. Gere e revise a prévia antes de confirmar.

O projeto mantém `{$R *.res}` no DPR e utiliza DFM para o formulário principal,
o visualizador e o DataModule.

## Testes

Abra `tests/uRenameControllerTests.dpr` no Delphi e execute o projeto DUnitX.
A suíte cobre:

- ordenação alfabética e numeração;
- exclusão do arquivo de log da prévia;
- bloqueio de nomes inválidos;
- execução e desfazer da renomeação.

## Segurança

- O aplicativo não percorre subpastas.
- A exclusão de arquivo é permanente e sempre exige confirmação.
- O desfazer cobre apenas a última operação registrada.
- O arquivo `.organizador-undo.tsv` é temporário e ignorado pelo Git.
- Faça backup antes de operar sobre arquivos importantes.

## Observação sobre compilação

A edição do Delphi disponível neste ambiente não habilita compilação pelo
`dcc32`. A aplicação e os testes devem ser compilados pelo IDE.
