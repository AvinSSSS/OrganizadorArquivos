unit RenameEngineTestsUnit;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TRenameEngineTests = class
  private
    FFolder: string;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure PreviewIsAlphabeticalAndDoesNotIncludeUndoLog;
    [Test]
    procedure InvalidWindowsNameIsBlocked;
    [Test]
    procedure ExecuteCanBeUndone;
  end;

implementation

uses
  System.SysUtils, System.IOUtils, RenameEngine;

procedure TRenameEngineTests.Setup;
begin
  FFolder := TPath.Combine(TPath.GetTempPath,
    'organizador-' + TGUID.NewGuid.ToString.Replace('{', '').Replace('}', ''));
  TDirectory.CreateDirectory(FFolder);
end;

procedure TRenameEngineTests.TearDown;
begin
  if TDirectory.Exists(FFolder) then
    TDirectory.Delete(FFolder, True);
end;

procedure TRenameEngineTests.PreviewIsAlphabeticalAndDoesNotIncludeUndoLog;
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

procedure TRenameEngineTests.InvalidWindowsNameIsBlocked;
var
  Items: TArray<TRenameItem>;
begin
  TFile.WriteAllText(TPath.Combine(FFolder, 'arquivo.txt'), 'x');
  Items := Preview(FFolder, 'invalido:', '', '', '', False);
  Assert.AreEqual('Nome inválido no Windows', Items[0].ErrorText);
end;

procedure TRenameEngineTests.ExecuteCanBeUndone;
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

initialization
  TDUnitX.RegisterTestFixture(TRenameEngineTests);

end.
