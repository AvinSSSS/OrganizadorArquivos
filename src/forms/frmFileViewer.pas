unit frmFileViewer;

interface

uses
  System.Classes, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  /// <summary>View modal para leitura interna de textos e imagens.</summary>
  TfrmFileViewer = class(TForm)
    pnlHeader: TPanel;
    lblTitle: TLabel;
    btnClose: TButton;
    memText: TMemo;
    pnlImage: TPanel;
    imgPreview: TImage;
  private
    /// <summary>Carrega o arquivo no controle adequado ao seu tipo.</summary>
    procedure LoadFile(const FileName: string);
    /// <summary>Indica se a extensão é tratada como conteúdo textual.</summary>
    class function IsTextFile(const FileName: string): Boolean; static;
    /// <summary>Indica se a extensão possui suporte nativo de imagem.</summary>
    class function IsImageFile(const FileName: string): Boolean; static;
  public
    /// <summary>Informa se o arquivo pode ser exibido dentro do aplicativo.</summary>
    class function CanPreview(const FileName: string): Boolean; static;
    /// <summary>Cria e apresenta o visualizador modal para o arquivo.</summary>
    class procedure Execute(AOwner: TComponent; const FileName: string); static;
  end;

var
  frmFileViewerWindow: TfrmFileViewer;

implementation

uses
  System.SysUtils, System.IOUtils, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage,
  Vcl.Imaging.GIFImg;

{$R *.dfm}

class function TfrmFileViewer.IsTextFile(const FileName: string): Boolean;
const
  Extensions: array[0..24] of string = (
    '.txt', '.log', '.csv', '.tsv', '.json', '.xml', '.ini', '.cfg', '.conf',
    '.pas', '.dpr', '.dfm', '.dproj', '.md', '.sql', '.bat', '.cmd', '.ps1',
    '.html', '.htm', '.css', '.js', '.ts', '.yaml', '.yml');
var
  Extension, Candidate: string;
begin
  Extension := LowerCase(TPath.GetExtension(FileName));
  Result := False;
  for Candidate in Extensions do
    if Extension = Candidate then
      Exit(True);
end;

class function TfrmFileViewer.IsImageFile(const FileName: string): Boolean;
const
  Extensions: array[0..7] of string = (
    '.bmp', '.jpg', '.jpeg', '.png', '.gif', '.ico', '.wmf', '.emf');
var
  Extension, Candidate: string;
begin
  Extension := LowerCase(TPath.GetExtension(FileName));
  Result := False;
  for Candidate in Extensions do
    if Extension = Candidate then
      Exit(True);
end;

class function TfrmFileViewer.CanPreview(const FileName: string): Boolean;
begin
  Result := IsTextFile(FileName) or IsImageFile(FileName);
end;

class procedure TfrmFileViewer.Execute(AOwner: TComponent;
  const FileName: string);
var
  Viewer: TfrmFileViewer;
begin
  Viewer := TfrmFileViewer.Create(AOwner);
  try
    Viewer.LoadFile(FileName);
    Viewer.ShowModal;
  finally
    Viewer.Free;
  end;
end;

procedure TfrmFileViewer.LoadFile(const FileName: string);
begin
  Caption := TPath.GetFileName(FileName) + ' - Visualização';
  lblTitle.Caption := TPath.GetFileName(FileName);
  memText.Visible := IsTextFile(FileName);
  pnlImage.Visible := IsImageFile(FileName);

  if memText.Visible then
  begin
    memText.Lines.LoadFromFile(FileName);
    memText.BringToFront;
  end
  else
  begin
    imgPreview.Picture.LoadFromFile(FileName);
    pnlImage.BringToFront;
  end;
end;

end.
