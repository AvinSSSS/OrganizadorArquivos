program FileOrganizerControllerTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.TestFramework,
  uRenameControllerTests in 'uRenameControllerTests.pas',
  dmFileOrganizerModelTests in 'dmFileOrganizerModelTests.pas',
  uRenameController in '..\src\controllers\uRenameController.pas',
  dmFileOrganizerModel in '..\src\models\dmFileOrganizerModel.pas' {dmFileOrganizer: TDataModule};

var
  Runner: ITestRunner;
  Results: IRunResults;
begin
  Runner := TDUnitX.CreateRunner;
  Runner.UseRTTI := True;
  Runner.AddLogger(TDUnitXConsoleLogger.Create(True));
  Results := Runner.Execute;
  if not Results.AllPassed then
    ExitCode := 1;
end.
