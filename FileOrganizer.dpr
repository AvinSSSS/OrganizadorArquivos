program FileOrganizer;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas',
  RenameEngine in 'RenameEngine.pas';

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Organizador de Arquivos';
  Application.CreateForm(TMainWindow, MainWindow);
  Application.Run;
end.
