unit RenameEngine;
interface
uses System.SysUtils, System.IOUtils, System.Generics.Collections;
type TRenameItem = record Source, Target, ErrorText: string; end;
function Preview(const Folder, Prefix, Suffix, FindText, ReplaceText: string; AddNumber: Boolean): TArray<TRenameItem>;
procedure Execute(const Items: TArray<TRenameItem>; const LogFile: string);
procedure Undo(const LogFile: string);
implementation
function Preview(const Folder, Prefix, Suffix, FindText, ReplaceText: string; AddNumber: Boolean): TArray<TRenameItem>;
var Files: TArray<string>; I: Integer; Base, Ext, NewBase: string; Seen: TDictionary<string,Boolean>;
begin Files:=TDirectory.GetFiles(Folder); SetLength(Result,Length(Files)); Seen:=TDictionary<string,Boolean>.Create; try for I:=0 to High(Files) do begin Base:=TPath.GetFileNameWithoutExtension(Files[I]); Ext:=TPath.GetExtension(Files[I]); NewBase:=Base; if FindText<>'' then NewBase:=StringReplace(NewBase,FindText,ReplaceText,[rfReplaceAll,rfIgnoreCase]); if AddNumber then NewBase:=Format('%.4d_%s',[I+1,NewBase]); Result[I].Source:=Files[I]; Result[I].Target:=TPath.Combine(Folder,Prefix+NewBase+Suffix+Ext); if SameText(Result[I].Source,Result[I].Target) then Result[I].ErrorText:='Sem alteração' else if TFile.Exists(Result[I].Target) or Seen.ContainsKey(LowerCase(Result[I].Target)) then Result[I].ErrorText:='Conflito de nome' else Seen.Add(LowerCase(Result[I].Target),True); end; finally Seen.Free; end; end;
procedure Execute(const Items: TArray<TRenameItem>; const LogFile: string); var Item: TRenameItem; Log: TStringList; begin Log:=TStringList.Create; try for Item in Items do if Item.ErrorText='' then begin TFile.Move(Item.Source,Item.Target); Log.Add(Item.Target+#9+Item.Source); end; Log.SaveToFile(LogFile,TEncoding.UTF8); except on E: Exception do begin Log.SaveToFile(LogFile,TEncoding.UTF8); raise; end; end; Log.Free; end;
procedure Undo(const LogFile: string); var Lines:TStringList; I,P:Integer; Current,Original:string; begin if not TFile.Exists(LogFile) then raise Exception.Create('Nenhuma operação para desfazer.'); Lines:=TStringList.Create; try Lines.LoadFromFile(LogFile,TEncoding.UTF8); for I:=Lines.Count-1 downto 0 do begin P:=Pos(#9,Lines[I]); Current:=Copy(Lines[I],1,P-1); Original:=Copy(Lines[I],P+1,MaxInt); if TFile.Exists(Current) and not TFile.Exists(Original) then TFile.Move(Current,Original); end; TFile.Delete(LogFile); finally Lines.Free; end; end;
end.
