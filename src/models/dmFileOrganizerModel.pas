unit dmFileOrganizerModel;

interface

uses
  System.Classes, uRenameController;

type
  /// <summary>Reúne a pasta e as regras informadas pela View.</summary>
  TFileOrganizerRequest = record
    Folder: string;
    Prefix: string;
    Suffix: string;
    FindText: string;
    ReplaceText: string;
    AddNumber: Boolean;
  end;

  /// <summary>DTO preparado para exibição de uma linha na grade.</summary>
  TFilePreviewRow = record
    SourcePath: string;
    OriginalName: string;
    NewName: string;
    Status: string;
  end;

  /// <summary>
  /// Mantém o estado da operação e adapta o controller para as Views.
  /// </summary>
  TdmFileOrganizer = class(TDataModule)
  private
    FRequest: TFileOrganizerRequest;
    FItems: TArray<TRenameItem>;
    /// <summary>Obtém o caminho do log associado à pasta atual.</summary>
    function GetUndoLogPath: string;
    /// <summary>Valida pasta, regras e dependências entre os parâmetros.</summary>
    procedure ValidateRequest(const Request: TFileOrganizerRequest);
  public
    /// <summary>Seleciona uma nova pasta e descarta a prévia anterior.</summary>
    procedure SelectFolder(const Folder: string);
    /// <summary>Valida a solicitação e solicita a prévia ao controller.</summary>
    procedure BuildPreview(const Request: TFileOrganizerRequest);
    /// <summary>Converte os itens internos em linhas próprias para a View.</summary>
    function PreviewRows: TArray<TFilePreviewRow>;
    /// <summary>Retorna quantos itens podem ser renomeados.</summary>
    function ReadyCount: Integer;
    /// <summary>Retorna a quantidade total de itens da prévia.</summary>
    function ItemCount: Integer;
    /// <summary>Retorna o caminho do item no índice informado.</summary>
    function FilePath(const Index: Integer): string;
    /// <summary>Exclui o item e recalcula a prévia atual.</summary>
    procedure DeleteItem(const Index: Integer);
    /// <summary>Aplica todos os itens válidos da prévia.</summary>
    procedure Apply;
    /// <summary>Desfaz a última operação registrada na pasta.</summary>
    procedure Revert;
    property UndoLogPath: string read GetUndoLogPath;
  end;

var
  dmFileOrganizer: TdmFileOrganizer;

implementation

uses
  System.IOUtils, System.SysUtils;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TdmFileOrganizer.ValidateRequest(
  const Request: TFileOrganizerRequest);
begin
  if Trim(Request.Folder) = '' then
    raise EArgumentException.Create('Selecione uma pasta.');
  if not TDirectory.Exists(Request.Folder) then
    raise EDirectoryNotFoundException.Create('A pasta selecionada não existe.');

  if (Request.Prefix = '') and (Request.Suffix = '') and
    (Request.FindText = '') and not Request.AddNumber then
    raise EArgumentException.Create(
      'Informe ao menos uma regra: prefixo, sufixo, texto para localizar ou numeração.');

  if (Request.FindText = '') and (Request.ReplaceText <> '') then
    raise EArgumentException.Create(
      'Informe o texto que deve ser localizado antes de preencher a substituição.');
end;

procedure TdmFileOrganizer.SelectFolder(const Folder: string);
begin
  FRequest := Default(TFileOrganizerRequest);
  FRequest.Folder := Folder;
  FItems := nil;
end;

procedure TdmFileOrganizer.BuildPreview(const Request: TFileOrganizerRequest);
begin
  ValidateRequest(Request);
  FRequest := Request;
  FItems := uRenameController.Preview(FRequest.Folder, FRequest.Prefix,
    FRequest.Suffix, FRequest.FindText, FRequest.ReplaceText,
    FRequest.AddNumber);
end;

function TdmFileOrganizer.PreviewRows: TArray<TFilePreviewRow>;
var
  I: Integer;
begin
  SetLength(Result, Length(FItems));
  for I := 0 to High(FItems) do
  begin
    Result[I].SourcePath := FItems[I].Source;
    Result[I].OriginalName := TPath.GetFileName(FItems[I].Source);
    Result[I].NewName := TPath.GetFileName(FItems[I].Target);
    if FItems[I].ErrorText = '' then
      Result[I].Status := 'Pronto'
    else
      Result[I].Status := FItems[I].ErrorText;
  end;
end;

function TdmFileOrganizer.ItemCount: Integer;
begin
  Result := Length(FItems);
end;

function TdmFileOrganizer.FilePath(const Index: Integer): string;
begin
  if (Index < 0) or (Index > High(FItems)) then
    raise EArgumentOutOfRangeException.Create('O arquivo selecionado é inválido.');
  Result := FItems[Index].Source;
end;

procedure TdmFileOrganizer.DeleteItem(const Index: Integer);
begin
  uRenameController.RecycleFile(FilePath(Index));
  BuildPreview(FRequest);
end;

function TdmFileOrganizer.ReadyCount: Integer;
var
  Item: TRenameItem;
begin
  Result := 0;
  for Item in FItems do
    if Item.ErrorText = '' then
      Inc(Result);
end;

function TdmFileOrganizer.GetUndoLogPath: string;
begin
  if Trim(FRequest.Folder) = '' then
    Exit('');
  Result := TPath.Combine(FRequest.Folder, '.organizador-undo.tsv');
end;

procedure TdmFileOrganizer.Apply;
begin
  if ReadyCount = 0 then
    raise Exception.Create('Gere uma prévia com ao menos um arquivo pronto.');
  uRenameController.Execute(FItems, UndoLogPath);
end;

procedure TdmFileOrganizer.Revert;
begin
  uRenameController.Undo(UndoLogPath);
end;

end.
