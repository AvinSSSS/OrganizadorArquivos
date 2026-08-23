program FileOrganizer;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  frmMain in 'src\forms\frmMain.pas' {frmMain},
  dmFileOrganizerModel in 'src\models\dmFileOrganizerModel.pas' {dmFileOrganizer: TDataModule},
  uRenameController in 'src\controllers\uRenameController.pas',
  frmFileViewer in 'src\forms\frmFileViewer.pas' {frmFileViewerWindow};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10');
  Application.Title := 'Organizador de Arquivos';
  Application.CreateForm(TdmFileOrganizer, dmFileOrganizer);
  Application.CreateForm(TfrmMain, frmMainWindow);
  Application.Run;
end.
