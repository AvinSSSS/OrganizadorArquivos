program FileOrganizer;
uses Vcl.Forms, MainForm in 'MainForm.pas', RenameEngine in 'RenameEngine.pas';
begin Application.Initialize; Application.MainFormOnTaskbar := True; Application.CreateForm(TMainWindow, MainWindow); Application.Run; end.
