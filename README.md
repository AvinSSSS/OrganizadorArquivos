# 🗂️ Organizador de Arquivos em Lote

[![Delphi](https://img.shields.io/badge/Delphi-VCL-EE1F35)](https://www.embarcadero.com/products/delphi)
[![Platform](https://img.shields.io/badge/plataforma-Windows-0078D6?logo=windows)](#)

Utilitário Windows para renomear muitos arquivos com segurança, permitindo conferir o resultado antes de alterar qualquer nome.

## ✨ Funcionalidades

- Prefixo e sufixo personalizados.
- Busca e substituição de texto sem diferenciar maiúsculas e minúsculas.
- Numeração sequencial com quatro dígitos.
- Ordem alfabética determinística antes da numeração.
- Pré-visualização obrigatória de nome original e nome final.
- Detecção de nomes inválidos, destinos duplicados ou já existentes.
- Confirmação antes da execução.
- Log local resistente a caracteres especiais e desfazer validado da última operação.
- Resumo de arquivos prontos e ignorados antes da confirmação.

## 🛠️ Arquitetura

- `RenameEngine.pas`: cria a prévia, valida conflitos, executa e desfaz.
- `MainForm.pas`: interface VCL construída em código.
- `FileOrganizer.dproj`: configurações Win32/Win64, Debug/Release e DPI do projeto.
- `.organizador-undo.tsv`: registro temporário criado na pasta processada.
- `tests/`: testes DUnitX do motor de prévia, execução e desfazer.

## 🚀 Como executar

1. Abra `FileOrganizer.dpr` no Delphi 13.
2. Compile para Win32 ou Win64 e execute pelo IDE.
3. Escolha uma pasta descartável para o primeiro teste.
4. Defina regras, clique em **Gerar prévia** e confira todos os conflitos.
5. Confirme a operação somente depois da revisão.

## 🧪 Testes automatizados

Abra `tests/RenameEngineTests.dpr` no Delphi e execute o projeto de console. A
suíte valida ordenação/numeração, exclusão segura do arquivo de log, bloqueio de
nomes inválidos e o ciclo completo de renomear/desfazer.

> A edição do Delphi disponível neste ambiente não permite compilação pelo
> `dcc32`; a aplicação e os testes devem ser compilados pelo IDE.

## 🧪 Cenários recomendados de teste

- Dois arquivos produzindo o mesmo destino.
- Destino que já existe na pasta.
- Acentos, espaços, nomes longos e extensões diferentes.
- Interrupção parcial e uso do log para desfazer.
- Pastas com centenas ou milhares de arquivos.

## ⚠️ Segurança

O aplicativo trabalha somente na pasta selecionada, não percorre subpastas e não
envia dados pela rede. Faça backup antes de processar arquivos importantes. O
desfazer cobre apenas a última operação registrada e é bloqueado se algum nome
original ou renomeado tiver sido ocupado, movido ou removido depois da operação.

---

## 🇬🇧 English

Delphi VCL batch renamer with mandatory preview, prefix/suffix and replacement rules, numbering, conflict detection, operation logging and one-step undo.
