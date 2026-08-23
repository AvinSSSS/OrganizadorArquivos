unit frmMain;

interface

uses
  System.Classes, Vcl.Forms, Vcl.StdCtrls, Vcl.Dialogs, Vcl.Grids,
  Vcl.ExtCtrls, dmFileOrganizerModel, System.ImageList, Vcl.ImgList,
  Vcl.Controls, Winapi.Windows, Winapi.ActiveX, System.SysUtils, System.IOUtils,
  System.StrUtils, System.Types, Vcl.Graphics, Vcl.ComCtrls, Winapi.Messages,
  Winapi.ShellAPI, frmFileViewer;

type
  /// <summary>
  /// View principal para seleção, prévia, renomeação e gestão dos arquivos.
  /// </summary>
  TfrmMain = class(TForm)
    pnlHeader: TPanel;
    lblTitle: TLabel;
    lblSubtitle: TLabel;
    pnlContent: TPanel;
    pnlToolbar: TPanel;
    lblFolder: TLabel;
    edtFolder: TEdit;
    btnPickFolder: TButton;
    lblPrefix: TLabel;
    edtPrefix: TEdit;
    lblSuffix: TLabel;
    edtSuffix: TEdit;
    lblFind: TLabel;
    edtFind: TEdit;
    lblReplace: TLabel;
    edtReplace: TEdit;
    chkNumber: TCheckBox;
    btnBuildPreview: TButton;
    btnApply: TButton;
    btnRevert: TButton;
    pnlGrid: TPanel;
    lblGridTitle: TLabel;
    lblRecordCount: TLabel;
    grdPreview: TStringGrid;
    pnlTotals: TPanel;
    lblTotalFiles: TLabel;
    lblReadyFiles: TLabel;
    lblIgnoredFiles: TLabel;
    pnlFooter: TPanel;
    lblStatus: TLabel;
    ImageList: TImageList;
  private
    /// <summary>Monta a solicitação usando os valores atuais dos controles.</summary>
    function CurrentRequest: TFileOrganizerRequest;
    /// <summary>Atualiza grade, contadores e disponibilidade das ações.</summary>
    procedure ShowPreview;
    /// <summary>Abre o seletor e informa a pasta escolhida ao DataModule.</summary>
    procedure PickFolderClick(Sender: TObject);
    /// <summary>Valida os campos e solicita uma nova prévia.</summary>
    procedure BuildPreviewClick(Sender: TObject);
    /// <summary>Confirma e executa a renomeação dos itens válidos.</summary>
    procedure ApplyClick(Sender: TObject);
    /// <summary>Restaura os nomes registrados pela última operação.</summary>
    procedure RevertClick(Sender: TObject);
    /// <summary>Desenha os ícones do ImageList na coluna de ações.</summary>
    procedure PreviewGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    /// <summary>Resolve a ação clicada na linha da grade.</summary>
    procedure PreviewGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    /// <summary>Abre internamente ou pelo aplicativo padrão o item indicado.</summary>
    procedure ViewItem(const Index: Integer);
    /// <summary>Confirma e exclui permanentemente o item indicado.</summary>
    procedure DeleteItem(const Index: Integer);
  public
    /// <summary>Carrega o DFM e conecta eventos após o streaming.</summary>
    constructor Create(AOwner: TComponent); override;
  end;

var
  frmMainWindow: TfrmMain;

implementation

{$R *.dfm}

constructor TfrmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  grdPreview.Cells[0, 0] := 'Nome atual';
  grdPreview.Cells[1, 0] := 'Novo nome';
  grdPreview.Cells[2, 0] := 'Situação';
  grdPreview.Cells[3, 0] := 'AÇÕES';

  { Eventos ligados após o streaming: o DFM permanece livre de associações. }
  btnPickFolder.OnClick := PickFolderClick;
  btnBuildPreview.OnClick := BuildPreviewClick;
  btnApply.OnClick := ApplyClick;
  btnRevert.OnClick := RevertClick;
  grdPreview.OnDrawCell := PreviewGridDrawCell;
  grdPreview.OnMouseDown := PreviewGridMouseDown;
end;

function TfrmMain.CurrentRequest: TFileOrganizerRequest;
begin
  Result.Folder := edtFolder.Text;
  Result.Prefix := edtPrefix.Text;
  Result.Suffix := edtSuffix.Text;
  Result.FindText := edtFind.Text;
  Result.ReplaceText := edtReplace.Text;
  Result.AddNumber := chkNumber.Checked;
end;

procedure TfrmMain.ShowPreview;
var
  Rows: TArray<TFilePreviewRow>;
  I, SkippedCount: Integer;
begin
  Rows := dmFileOrganizer.PreviewRows;
  if Length(Rows) = 0 then
  begin
    grdPreview.RowCount := 2;
    grdPreview.Cells[0, 1] := '';
    grdPreview.Cells[1, 1] := '';
    grdPreview.Cells[2, 1] := '';
    grdPreview.Cells[3, 1] := '';
  end
  else
    grdPreview.RowCount := Length(Rows) + 1;
  SkippedCount := 0;
  for I := 0 to High(Rows) do
  begin
    grdPreview.Cells[0, I + 1] := Rows[I].OriginalName;
    grdPreview.Cells[1, I + 1] := Rows[I].NewName;
    grdPreview.Cells[2, I + 1] := Rows[I].Status;
    grdPreview.Cells[3, I + 1] := '';
    if Rows[I].Status <> 'Pronto' then
      Inc(SkippedCount);
  end;
  lblStatus.Caption := Format('%d pronto(s)  •  %d ignorado(s)',
    [dmFileOrganizer.ReadyCount, SkippedCount]);
  lblRecordCount.Caption := Format('%d arquivo(s)', [Length(Rows)]);
  lblTotalFiles.Caption := Format('ARQUIVOS  %d', [Length(Rows)]);
  lblReadyFiles.Caption := Format('PRONTOS  %d', [dmFileOrganizer.ReadyCount]);
  lblIgnoredFiles.Caption := Format('IGNORADOS  %d', [SkippedCount]);
  btnApply.Enabled := dmFileOrganizer.ReadyCount > 0;
  btnRevert.Enabled := (dmFileOrganizer.UndoLogPath <> '') and
    TFile.Exists(dmFileOrganizer.UndoLogPath);
end;

procedure TfrmMain.PickFolderClick(Sender: TObject);
var
  Dialog: TFileOpenDialog;
begin
  Dialog := TFileOpenDialog.Create(nil);
  try
    Dialog.Options := [fdoPickFolders, fdoPathMustExist];
    if Dialog.Execute then
    begin
      edtFolder.Text := Dialog.FileName;
      dmFileOrganizer.SelectFolder(Dialog.FileName);
      ShowPreview;
      lblStatus.Caption :=
        'Pasta selecionada. Informe uma regra e clique em Gerar prévia.';
      if edtPrefix.CanFocus then
        edtPrefix.SetFocus;
    end;
  finally
    Dialog.Free;
  end;
end;

procedure TfrmMain.BuildPreviewClick(Sender: TObject);
begin
  if not Assigned(dmFileOrganizer) then
  begin
    ShowMessage('O modelo de dados não foi inicializado.');
    Exit;
  end;
  if not TDirectory.Exists(edtFolder.Text) then
  begin
    ShowMessage('Selecione uma pasta válida.');
    Exit;
  end;
  try
    dmFileOrganizer.BuildPreview(CurrentRequest);
    ShowPreview;
  except
    on E: Exception do
      ShowMessage('Não foi possível gerar a prévia: ' + E.Message);
  end;
end;

procedure TfrmMain.ApplyClick(Sender: TObject);
begin
  if dmFileOrganizer.ReadyCount = 0 then
  begin
    ShowMessage('Gere uma prévia com ao menos um arquivo pronto.');
    Exit;
  end;
  if MessageDlg(Format('Renomear %d arquivo(s)? Revise a prévia antes de continuar.',
    [dmFileOrganizer.ReadyCount]), mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  try
    dmFileOrganizer.Apply;
    ShowMessage('Concluído. A opção Desfazer reverte esta operação.');
    lblStatus.Caption := 'Arquivos renomeados com sucesso.';
    BuildPreviewClick(nil);
  except
    on E: Exception do
      ShowMessage('A operação não foi concluída: ' + E.Message);
  end;
end;

procedure TfrmMain.RevertClick(Sender: TObject);
begin
  try
    dmFileOrganizer.Revert;
    ShowMessage('Operação desfeita.');
    lblStatus.Caption := 'Os nomes originais foram restaurados.';
    BuildPreviewClick(nil);
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TfrmMain.PreviewGridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  CellCanvas: TCanvas;
  SectionWidth, IconY: Integer;
begin
  if (ACol <> 3) or (ARow = 0) or
    (ARow > dmFileOrganizer.ItemCount) then
    Exit;

  CellCanvas := grdPreview.Canvas;
  CellCanvas.Brush.Color := clWhite;
  CellCanvas.FillRect(Rect);
  if ImageList.Count < 2 then
    Exit;

  SectionWidth := Rect.Width div 2;
  IconY := Rect.Top + (Rect.Height - ImageList.Height) div 2;
  ImageList.Draw(CellCanvas,
    Rect.Left + (SectionWidth - ImageList.Width) div 2,
    IconY, 0, True);
  ImageList.Draw(CellCanvas,
    Rect.Left + SectionWidth + (SectionWidth - ImageList.Width) div 2,
    IconY, 1, True);
end;

procedure TfrmMain.PreviewGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ColIndex, RowIndex: Integer;
  ActionRect: TRect;
begin
  if Button <> mbLeft then
    Exit;
  grdPreview.MouseToCell(X, Y, ColIndex, RowIndex);
  if (ColIndex <> 3) or (RowIndex <= 0) or
    (RowIndex > dmFileOrganizer.ItemCount) then
    Exit;

  ActionRect := grdPreview.CellRect(ColIndex, RowIndex);
  if X - ActionRect.Left < ActionRect.Width div 2 then
    ViewItem(RowIndex - 1)
  else
    DeleteItem(RowIndex - 1);
end;

procedure TfrmMain.ViewItem(const Index: Integer);
var
  FileName: string;
begin
  try
    FileName := dmFileOrganizer.FilePath(Index);
    if TfrmFileViewer.CanPreview(FileName) then
      TfrmFileViewer.Execute(Self, FileName)
    else if NativeInt(ShellExecute(Handle, 'open', PChar(FileName), nil, nil,
      SW_SHOWNORMAL)) <= 32 then
      ShowMessage('Não foi possível abrir este tipo de arquivo.');
  except
    on E: Exception do
      ShowMessage('Não foi possível visualizar o arquivo: ' + E.Message);
  end;
end;

procedure TfrmMain.DeleteItem(const Index: Integer);
var
  FileName: string;
begin
  FileName := dmFileOrganizer.FilePath(Index);
  if MessageDlg(Format('Excluir permanentemente o arquivo "%s"?',
    [TPath.GetFileName(FileName)]), mtConfirmation,
    [mbYes, mbNo], 0) <> mrYes then
    Exit;
  try
    dmFileOrganizer.DeleteItem(Index);
    ShowPreview;
    lblStatus.Caption := 'Arquivo excluído com sucesso.';
  except
    on E: Exception do
      ShowMessage('Não foi possível excluir o arquivo: ' + E.Message);
  end;
end;

end.
