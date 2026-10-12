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
- Confirmação antes de renomear ou mover um arquivo para a Lixeira.
- Rollback automático se uma renomeação em lote falhar parcialmente.
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
│   ├── uRenameControllerTests.pas
│   └── dmFileOrganizerModelTests.pas
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

Diretório de trabalho: raiz do checkout (`D:/Fontes/Projetos/OrganizadorArquivos`
no projeto principal, ou a raiz da worktree isolada). É necessário Windows com
Delphi 13, suporte VCL e compilador da plataforma escolhida. Não há instalação
via npm/pip nem arquivo `.env`: pasta e regras são informadas pela interface.

1. Abra [FileOrganizer.dpr](FileOrganizer.dpr) no Delphi 13.
2. Escolha Win32 ou Win64.
3. Execute **Project > Build All**.
4. Inicie o aplicativo pelo IDE.
5. Selecione uma pasta e informe pelo menos uma regra de renomeação.
6. Gere e revise a prévia antes de confirmar.

O projeto mantém `{$R *.res}` no DPR e utiliza DFM para o formulário principal,
o visualizador e o DataModule. Preserve esses recursos junto às units.
O [FileOrganizer.dproj](FileOrganizer.dproj) define `Platform` (Win32 por padrão),
`Config` (Base por padrão) e saídas em `./$(Platform)/$(Config)`.
`BDS` e `BDSCOMMONDIR` são macros do ambiente Delphi usadas para manifesto,
ícones e estilos VCL; não são variáveis de configuração do aplicativo.

## Testes

A partir da raiz do checkout, abra
[tests/uRenameControllerTests.dpr](tests/uRenameControllerTests.dpr) no Delphi.
As units `DUnitX.TestFramework` e `DUnitX.Loggers.Console` precisam estar
resolvíveis no Library/Search Path da plataforma escolhida; o repositório não
inclui o código DUnitX nem um `.dproj` de testes. Compile pelo IDE e execute o
projeto de console. O runner usa RTTI, registra os dois fixtures e define
`ExitCode := 1` quando há teste reprovado.

Há oito métodos `[Test]`: quatro no
[controller](tests/uRenameControllerTests.pas) e quatro no
[DataModule](tests/dmFileOrganizerModelTests.pas). A suíte cobre:

- ordenação alfabética e numeração;
- exclusão do arquivo de log da prévia;
- bloqueio de nomes inválidos;
- execução e desfazer da renomeação;
- rollback após falha parcial;
- validação das regras no DataModule;
- índices inválidos e atualização após enviar um arquivo à Lixeira.

Os fixtures criam pastas exclusivas em `TPath.GetTempPath` com GUID e arquivos
textuais sintéticos (`alfa.txt`, `zeta.txt`, `arquivo.txt`, `primeiro.txt`),
e removem suas pastas no TearDown. `DeleteItemRefreshesPreview` chama a Lixeira
real do Windows via `SHFileOperation`; não usa mock e depende do suporte da
Lixeira no volume temporário. O arquivo reciclado não é removido pelo TearDown.

Esses testes não exercitam formulários, diálogos de confirmação, visualizador,
associações de arquivos ou falha parcial durante o desfazer. Para conferir a
interface, use uma pasta descartável com `alfa.txt` e `zeta.txt`, gere uma prévia
com apenas numeração e confira `0001_alfa.txt`/`0002_zeta.txt`; depois confirme,
desfaça e confira os nomes originais. Confira separadamente a visualização TXT,
as confirmações e a Lixeira com arquivos sintéticos. A prévia percorre e ordena
os arquivos de forma síncrona; não há teste de desempenho de pastas grandes.

## Segurança

- O aplicativo não percorre subpastas.
- A exclusão exige confirmação e envia o arquivo para a Lixeira do Windows.
- O desfazer cobre apenas a última operação registrada.
- O arquivo `.organizador-undo.tsv` é temporário e ignorado pelo Git.
- Faça backup antes de operar sobre arquivos importantes.

## Observação sobre compilação

A edição do Delphi disponível neste ambiente não habilita compilação pelo
`dcc32`. A aplicação e os testes devem ser compilados pelo IDE.
