unit dmFileOrganizerModelTests;

interface

uses
  DUnitX.TestFramework, dmFileOrganizerModel;

type
  /// <summary>Testes de validação e estado do DataModule.</summary>
  [TestFixture]
  TFileOrganizerModelTests = class
  private
    FFolder: string;
    FModel: TdmFileOrganizer;
    /// <summary>Cria uma solicitação válida para os testes.</summary>
    function ValidRequest: TFileOrganizerRequest;
  public
    /// <summary>Cria o DataModule e uma pasta temporária isolada.</summary>
    [Setup]
    procedure Setup;
    /// <summary>Libera o DataModule e remove a pasta temporária.</summary>
    [TearDown]
    procedure TearDown;
    /// <summary>Bloqueia a prévia quando nenhuma regra foi informada.</summary>
    [Test]
    procedure RequestWithoutRulesIsRejected;
    /// <summary>Bloqueia substituição sem texto para localizar.</summary>
    [Test]
    procedure ReplacementWithoutFindTextIsRejected;
    /// <summary>Bloqueia o acesso a índices inexistentes.</summary>
    [Test]
    procedure InvalidItemIndexIsRejected;
    /// <summary>Move o item à Lixeira e recalcula a prévia.</summary>
    [Test]
    procedure DeleteItemRefreshesPreview;
  end;

implementation

uses
  System.SysUtils, System.IOUtils;

procedure TFileOrganizerModelTests.Setup;
begin
  FFolder := TPath.Combine(TPath.GetTempPath,
    'organizador-model-' +
    TGUID.NewGuid.ToString.Replace('{', '').Replace('}', ''));
  TDirectory.CreateDirectory(FFolder);
  FModel := TdmFileOrganizer.Create(nil);
end;

procedure TFileOrganizerModelTests.TearDown;
begin
  FModel.Free;
  if TDirectory.Exists(FFolder) then
    TDirectory.Delete(FFolder, True);
end;

function TFileOrganizerModelTests.ValidRequest: TFileOrganizerRequest;
begin
  Result := Default(TFileOrganizerRequest);
  Result.Folder := FFolder;
  Result.Prefix := 'novo-';
end;

procedure TFileOrganizerModelTests.RequestWithoutRulesIsRejected;
var
  Request: TFileOrganizerRequest;
  RaisedException: Boolean;
begin
  Request := Default(TFileOrganizerRequest);
  Request.Folder := FFolder;
  RaisedException := False;
  try
    FModel.BuildPreview(Request);
  except
    on E: EArgumentException do
      RaisedException := True;
  end;
  Assert.IsTrue(RaisedException);
end;

procedure TFileOrganizerModelTests.ReplacementWithoutFindTextIsRejected;
var
  Request: TFileOrganizerRequest;
  RaisedException: Boolean;
begin
  Request := ValidRequest;
  Request.ReplaceText := 'substituição';
  RaisedException := False;
  try
    FModel.BuildPreview(Request);
  except
    on E: EArgumentException do
      RaisedException := True;
  end;
  Assert.IsTrue(RaisedException);
end;

procedure TFileOrganizerModelTests.InvalidItemIndexIsRejected;
var
  RaisedException: Boolean;
begin
  RaisedException := False;
  try
    FModel.FilePath(0);
  except
    on E: EArgumentOutOfRangeException do
      RaisedException := True;
  end;
  Assert.IsTrue(RaisedException);
end;

procedure TFileOrganizerModelTests.DeleteItemRefreshesPreview;
var
  Request: TFileOrganizerRequest;
  FileName: string;
begin
  FileName := TPath.Combine(FFolder, 'arquivo.txt');
  TFile.WriteAllText(FileName, 'conteúdo');
  Request := ValidRequest;
  FModel.BuildPreview(Request);
  Assert.AreEqual(1, FModel.ItemCount);

  FModel.DeleteItem(0);

  Assert.AreEqual(0, FModel.ItemCount);
  Assert.IsFalse(TFile.Exists(FileName));
end;

initialization
  TDUnitX.RegisterTestFixture(TFileOrganizerModelTests);

end.
