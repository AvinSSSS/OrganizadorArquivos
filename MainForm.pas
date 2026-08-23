unit MainForm;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, Vcl.Forms, Vcl.Controls,
  Vcl.StdCtrls, Vcl.Dialogs, Vcl.Grids, RenameEngine;

type
  TMainWindow = class(TForm)
  private
    FFolder, FPrefix, FSuffix, FFind, FReplace: TEdit;
    FNumber: TCheckBox;
    FGrid: TStringGrid;
    FStatus: TLabel;
    FItems: TArray<TRenameItem>;
    procedure Pick(Sender: TObject);
    procedure BuildPreview(Sender: TObject);
    procedure Apply(Sender: TObject);
    procedure Revert(Sender: TObject);
    function LogPath: string;
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  MainWindow: TMainWindow;

implementation

constructor TMainWindow.Create(AOwner: TComponent);
var
  Button: TButton;
  LabelControl: TLabel;
  X: Integer;
  procedure AddField(const CaptionText: string; var Edit: TEdit; Width: Integer);
  begin
    LabelControl := TLabel.Create(Self);
    LabelControl.Parent := Self;
    LabelControl.Caption := CaptionText;
    LabelControl.SetBounds(X, 60, Width, 18);
    Edit := TEdit.Create(Self);
    Edit.Parent := Self;
    Edit.SetBounds(X, 80, Width, 25);
    Inc(X, Width + 10);
  end;
begin
  inherited;
  Caption := 'Organizador de Arquivos';
  Width := 1100;
  Height := 700;
  Position := poScreenCenter;
  Constraints.MinWidth := 820;
  Constraints.MinHeight := 520;
  FFolder := TEdit.Create(Self);
  FFolder.Parent := Self;
  FFolder.SetBounds(10, 15, 880, 27);
  FFolder.Anchors := [akLeft, akTop, akRight];
  Button := TButton.Create(Self);
  Button.Parent := Self;
  Button.Caption := 'Pasta...';
  Button.SetBounds(900, 13, 90, 30);
  Button.Anchors := [akTop, akRight];
  Button.OnClick := Pick;
  X := 10;
  AddField('Prefixo', FPrefix, 150);
  AddField('Sufixo', FSuffix, 150);
  AddField('Localizar', FFind, 180);
  AddField('Substituir', FReplace, 180);
  FNumber := TCheckBox.Create(Self);
  FNumber.Parent := Self;
  FNumber.Caption := 'Numerar em ordem alfabética';
  FNumber.SetBounds(X, 82, 210, 22);
  Button := TButton.Create(Self);
  Button.Parent := Self;
  Button.Caption := 'Gerar prévia';
  Button.SetBounds(10, 120, 120, 30);
  Button.OnClick := BuildPreview;
  Button := TButton.Create(Self);
  Button.Parent := Self;
  Button.Caption := 'Renomear';
  Button.SetBounds(140, 120, 110, 30);
  Button.OnClick := Apply;
  Button := TButton.Create(Self);
  Button.Parent := Self;
  Button.Caption := 'Desfazer';
  Button.SetBounds(260, 120, 100, 30);
  Button.OnClick := Revert;
  FStatus := TLabel.Create(Self);
  FStatus.Parent := Self;
  FStatus.Caption := 'Selecione uma pasta e gere a prévia.';
  FStatus.SetBounds(380, 127, 600, 20);
  FGrid := TStringGrid.Create(Self);
  FGrid.Parent := Self;
  FGrid.SetBounds(10, 165, 1060, 485);
  FGrid.Anchors := [akLeft, akTop, akRight, akBottom];
  FGrid.ColCount := 3;
  FGrid.RowCount := 2;
  FGrid.FixedRows := 1;
  FGrid.Options := FGrid.Options + [goColSizing, goRowSelect];
  FGrid.Cells[0, 0] := 'Original';
  FGrid.Cells[1, 0] := 'Novo nome';
  FGrid.Cells[2, 0] := 'Status';
  FGrid.ColWidths[0] := 410;
  FGrid.ColWidths[1] := 410;
  FGrid.ColWidths[2] := 200;
end;

procedure TMainWindow.Pick(Sender: TObject);
var
  Dialog: TFileOpenDialog;
begin
  Dialog := TFileOpenDialog.Create(nil);
  try
    Dialog.Options := [fdoPickFolders, fdoPathMustExist];
    if Dialog.Execute then
    begin
      FFolder.Text := Dialog.FileName;
      BuildPreview(nil);
    end;
  finally
    Dialog.Free;
  end;
end;

function TMainWindow.LogPath: string;
begin
  Result := TPath.Combine(FFolder.Text, '.organizador-undo.tsv');
end;

procedure TMainWindow.BuildPreview(Sender: TObject);
var
  I, ReadyCount, SkippedCount: Integer;
  StatusText: string;
begin
  if not TDirectory.Exists(FFolder.Text) then
  begin
    ShowMessage('Selecione uma pasta válida.');
    Exit;
  end;
  try
    FItems := Preview(FFolder.Text, FPrefix.Text, FSuffix.Text, FFind.Text,
      FReplace.Text, FNumber.Checked);
    FGrid.RowCount := Length(FItems) + 1;
    ReadyCount := 0;
    SkippedCount := 0;
    for I := 0 to High(FItems) do
    begin
      FGrid.Cells[0, I + 1] := ExtractFileName(FItems[I].Source);
      FGrid.Cells[1, I + 1] := ExtractFileName(FItems[I].Target);
      StatusText := FItems[I].ErrorText;
      if StatusText = '' then
      begin
        StatusText := 'Pronto';
        Inc(ReadyCount);
      end
      else
        Inc(SkippedCount);
      FGrid.Cells[2, I + 1] := StatusText;
    end;
    FStatus.Caption := Format('%d pronto(s) - %d ignorado(s)',
      [ReadyCount, SkippedCount]);
  except
    on E: Exception do
      ShowMessage('Não foi possível gerar a prévia: ' + E.Message);
  end;
end;

procedure TMainWindow.Apply(Sender: TObject);
var
  Item: TRenameItem;
  ReadyCount: Integer;
begin
  ReadyCount := 0;
  for Item in FItems do
    if Item.ErrorText = '' then Inc(ReadyCount);
  if ReadyCount = 0 then
  begin
    ShowMessage('Gere uma prévia com ao menos um arquivo pronto.');
    Exit;
  end;
  if MessageDlg(Format('Renomear %d arquivo(s)? Revise a prévia antes de continuar.',
    [ReadyCount]), mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
  try
    Execute(FItems, LogPath);
    ShowMessage('Concluído. A opção Desfazer reverte esta operação.');
    BuildPreview(nil);
  except
    on E: Exception do
      ShowMessage('A operação não foi concluída: ' + E.Message);
  end;
end;

procedure TMainWindow.Revert(Sender: TObject);
begin
  try
    Undo(LogPath);
    ShowMessage('Operação desfeita.');
    BuildPreview(nil);
  except
    on E: Exception do ShowMessage(E.Message);
  end;
end;

end.
