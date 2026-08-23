program RenameEngineTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.TestFramework,
  RenameEngineTestsUnit in 'RenameEngineTestsUnit.pas',
  RenameEngine in '..\RenameEngine.pas';

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
