# 🗂️ Organizador de Arquivos em Lote

[![Delphi](https://img.shields.io/badge/Delphi-VCL-EE1F35)](https://www.embarcadero.com/products/delphi)
[![Platform](https://img.shields.io/badge/plataforma-Windows-0078D6?logo=windows)](#)

Utilitário Windows para renomear muitos arquivos com segurança, permitindo conferir o resultado antes de alterar qualquer nome.

## ✨ Funcionalidades

- Prefixo e sufixo personalizados.
- Busca e substituição de texto sem diferenciar maiúsculas e minúsculas.
- Numeração sequencial com quatro dígitos.
- Pré-visualização obrigatória de nome original e nome final.
- Detecção de destinos duplicados ou já existentes.
- Confirmação antes da execução.
- Log local e desfazer da última operação.

## 🛠️ Arquitetura

- `RenameEngine.pas`: cria a prévia, valida conflitos, executa e desfaz.
- `MainForm.pas`: interface VCL construída em código.
- `.organizador-undo.tsv`: registro temporário criado na pasta processada.

## 🚀 Como executar

1. Abra `FileOrganizer.dpr` no Delphi 13.
2. Compile para Win32 ou Win64 e execute pelo IDE.
3. Escolha uma pasta descartável para o primeiro teste.
4. Defina regras, clique em **Gerar prévia** e confira todos os conflitos.
5. Confirme a operação somente depois da revisão.

## 🧪 Cenários recomendados de teste

- Dois arquivos produzindo o mesmo destino.
- Destino que já existe na pasta.
- Acentos, espaços, nomes longos e extensões diferentes.
- Interrupção parcial e uso do log para desfazer.
- Pastas com centenas ou milhares de arquivos.

## ⚠️ Segurança

Faça backup antes de processar arquivos importantes. O desfazer cobre apenas a última operação registrada e depende de os arquivos não terem sido movidos ou alterados depois da renomeação.

---

## 🇬🇧 English

Delphi VCL batch renamer with mandatory preview, prefix/suffix and replacement rules, numbering, conflict detection, operation logging and one-step undo.
