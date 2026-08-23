unit uRenameControllerTests;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  /// <summary>Testes de regressão do controller de renomeação.</summary>
  TRenameControllerTests = class
  private
    FFolder: string;
  public
    [Setup]
    /// <summary>Cria uma pasta temporária isolada para cada teste.</summary>
    procedure Setup;
    [TearDown]
    /// <summary>Remove a pasta temporária e seus arquivos.</summary>
    procedure TearDown;
    [Test]
    /// <summary>Valida ordenação, numeração e exclusão do log da prévia.</summary>
    procedure PreviewIsAlphabeticalAndDoesNotIncludeUndoLog;
    [Test]
    /// <summary>Garante o bloqueio de nomes inválidos no Windows.</summary>
    procedure InvalidWindowsNameIsBlocked;
    [Test]
    /// <summary>Valida o ciclo completo de executar e desfazer.</summary>
    procedure ExecuteCanBeUndone;
    [Test]
    /// <summary>Garante rollback quando uma renomeação intermediária falha.</summary>
    procedure ExecuteRollsBackAfterPartialFailure;
  end;

implementation

uses
  System.SysUtils, System.IOUtils, uRenameController;

procedure TRenameControllerTests.Setup;
begin
  FFolder := TPath.Combine(TPath.GetTempPath,
    'organizador-' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', ''));
  TDirectory.CreateDirectory(FFolder);
end;

procedure TRenameControllerTests.TearDown;
begin
  if TDirectory.Exists(FFolder) then
    TDirectory.Delete(FFolder, True);
end;

procedure TRenameControllerTests.PreviewIsAlphabeticalAndDoesNotIncludeUndoLog;
var
  Items: TArray<TRenameItem>;
begin
  TFile.WriteAllText(TPath.Combine(FFolder, 'zeta.txt'), 'z');
  TFile.WriteAllText(TPath.Combine(FFolder, 'alfa.txt'), 'a');
  TFile.WriteAllText(TPath.Combine(FFolder, '.organizador-undo.tsv'), 'log');
  Items := Preview(FFolder, '', '', '', '', True);
  Assert.AreEqual(2, Length(Items));
  Assert.AreEqual('0001_alfa.txt', TPath.GetFileName(Items[0].Target));
  Assert.AreEqual('0002_zeta.txt', TPath.GetFileName(Items[1].Target));
end;

procedure TRenameControllerTests.InvalidWindowsNameIsBlocked;
var
  Items: TArray<TRenameItem>;
begin
  TFile.WriteAllText(TPath.Combine(FFolder, 'arquivo.txt'), 'x');
  Items := Preview(FFolder, 'invalido:', '', '', '', False);
  Assert.AreEqual('Nome inválido no Windows', Items[0].ErrorText);
end;

procedure TRenameControllerTests.ExecuteCanBeUndone;
var
  Items: TArray<TRenameItem>;
  LogFile: string;
begin
  TFile.WriteAllText(TPath.Combine(FFolder, 'arquivo.txt'), 'conteudo');
  LogFile := TPath.Combine(FFolder, '.organizador-undo.tsv');
  Items := Preview(FFolder, 'novo-', '', '', '', False);
  Execute(Items, LogFile);
  Assert.IsTrue(TFile.Exists(TPath.Combine(FFolder, 'novo-arquivo.txt')));
  Undo(LogFile);
  Assert.IsTrue(TFile.Exists(TPath.Combine(FFolder, 'arquivo.txt')));
  Assert.IsFalse(TFile.Exists(LogFile));
end;

procedure TRenameControllerTests.ExecuteRollsBackAfterPartialFailure;
var
  Items: TArray<TRenameItem>;
  OriginalFile, FirstTarget, LogFile: string;
  RaisedException: Boolean;
begin
  OriginalFile := TPath.Combine(FFolder, 'primeiro.txt');
  FirstTarget := TPath.Combine(FFolder, 'renomeado.txt');
  LogFile := TPath.Combine(FFolder, '.organizador-undo.tsv');
  TFile.WriteAllText(OriginalFile, 'conteúdo');

  SetLength(Items, 2);
  Items[0].Source := OriginalFile;
  Items[0].Target := FirstTarget;
  Items[0].ErrorText := '';
  Items[1].Source := TPath.Combine(FFolder, 'inexistente.txt');
  Items[1].Target := TPath.Combine(FFolder, 'destino.txt');
  Items[1].ErrorText := '';

  RaisedException := False;
  try
    Execute(Items, LogFile);
  except
    on E: Exception do
      RaisedException := True;
  end;

  Assert.IsTrue(RaisedException, 'A falha intermediária deveria ser propagada.');
  Assert.IsTrue(TFile.Exists(OriginalFile),
    'O primeiro arquivo deveria ter sido restaurado.');
  Assert.IsFalse(TFile.Exists(FirstTarget));
  Assert.IsFalse(TFile.Exists(LogFile));
end;

initialization
  TDUnitX.RegisterTestFixture(TRenameControllerTests);

end.
