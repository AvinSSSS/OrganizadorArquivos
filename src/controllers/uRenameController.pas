unit uRenameController;

interface

uses
  System.SysUtils, System.IOUtils, System.Generics.Collections;

type
  /// <summary>Representa uma alteração de nome calculada pelo controller.</summary>
  TRenameItem = record
    /// <summary>Caminho absoluto atual do arquivo.</summary>
    Source: string;
    /// <summary>Caminho absoluto calculado para o novo nome.</summary>
    Target: string;
    /// <summary>Motivo que impede a operação; vazio quando o item é válido.</summary>
    ErrorText: string;
  end;

/// <summary>Calcula e valida as alterações sem modificar os arquivos.</summary>
/// <param name="Folder">Pasta cujos arquivos serão processados.</param>
/// <param name="Prefix">Texto acrescentado antes do nome.</param>
/// <param name="Suffix">Texto acrescentado depois do nome.</param>
/// <param name="FindText">Texto que deve ser localizado.</param>
/// <param name="ReplaceText">Texto usado na substituição.</param>
/// <param name="AddNumber">Indica se os nomes receberão numeração sequencial.</param>
/// <returns>Itens ordenados alfabeticamente com destino e validação.</returns>
function Preview(const Folder, Prefix, Suffix, FindText, ReplaceText: string;
  AddNumber: Boolean): TArray<TRenameItem>;

/// <summary>Executa os itens válidos e grava o registro de desfazer.</summary>
/// <param name="Items">Itens anteriormente produzidos por Preview.</param>
/// <param name="LogFile">Caminho do registro da operação.</param>
procedure Execute(const Items: TArray<TRenameItem>; const LogFile: string);

/// <summary>Restaura os nomes usando o registro da última operação.</summary>
/// <param name="LogFile">Caminho do registro que será consumido.</param>
procedure Undo(const LogFile: string);

/// <summary>Exclui permanentemente um arquivo após validar o caminho.</summary>
/// <param name="FileName">Caminho absoluto do arquivo.</param>
procedure DeleteFile(const FileName: string);

implementation

uses
  System.Classes, System.Generics.Defaults, System.NetEncoding;

const
  UndoFileName = '.organizador-undo.tsv';

/// <summary>Verifica caracteres, sufixos e nomes reservados do Windows.</summary>
function HasInvalidFileName(const Value: string): Boolean;
const
  InvalidChars: array[0..8] of Char = ('<', '>', ':', '"', '/', '\', '|', '?', '*');
  ReservedNames: array[0..21] of string = (
    'CON', 'PRN', 'AUX', 'NUL', 'COM1', 'COM2', 'COM3', 'COM4', 'COM5',
    'COM6', 'COM7', 'COM8', 'COM9', 'LPT1', 'LPT2', 'LPT3', 'LPT4',
    'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9');
var
  C, Invalid: Char;
  Reserved, Stem: string;
begin
  if Value = '' then Exit(True);
  Result := Value[Length(Value)] in [' ', '.'];
  if Result then Exit;
  for C in Value do
  begin
    if Ord(C) < 32 then Exit(True);
    for Invalid in InvalidChars do
      if C = Invalid then Exit(True);
  end;
  Stem := UpperCase(TPath.GetFileNameWithoutExtension(Value));
  for Reserved in ReservedNames do
    if Stem = Reserved then Exit(True);
end;

function Preview(const Folder, Prefix, Suffix, FindText, ReplaceText: string;
  AddNumber: Boolean): TArray<TRenameItem>;
var
  Files: TArray<string>;
  Items: TList<TRenameItem>;
  Seen: TDictionary<string, Boolean>;
  Item: TRenameItem;
  FileName, BaseName, Extension, NewBase, NewName, Key: string;
  I: Integer;
begin
  if not TDirectory.Exists(Folder) then
    raise EDirectoryNotFoundException.Create('A pasta selecionada não existe.');
  Files := TDirectory.GetFiles(Folder);
  TArray.Sort<string>(Files, TComparer<string>.Construct(
    function(const Left, Right: string): Integer
    begin
      Result := CompareText(Left, Right);
    end));
  Items := TList<TRenameItem>.Create;
  Seen := TDictionary<string, Boolean>.Create;
  try
    for I := 0 to High(Files) do
    begin
      FileName := TPath.GetFileName(Files[I]);
      if SameText(FileName, UndoFileName) then Continue;
      BaseName := TPath.GetFileNameWithoutExtension(Files[I]);
      Extension := TPath.GetExtension(Files[I]);
      NewBase := BaseName;
      if FindText <> '' then
        NewBase := StringReplace(NewBase, FindText, ReplaceText,
          [rfReplaceAll, rfIgnoreCase]);
      if AddNumber then
        NewBase := Format('%.4d_%s', [Items.Count + 1, NewBase]);
      NewName := Prefix + NewBase + Suffix + Extension;
      Item.Source := Files[I];
      Item.Target := TPath.Combine(Folder, NewName);
      Item.ErrorText := '';
      Key := LowerCase(Item.Target);
      if SameText(Item.Source, Item.Target) then
        Item.ErrorText := 'Sem alteração'
      else if HasInvalidFileName(NewName) then
        Item.ErrorText := 'Nome inválido no Windows'
      else if Length(NewName) > 255 then
        Item.ErrorText := 'Nome maior que 255 caracteres'
      else if Seen.ContainsKey(Key) then
        Item.ErrorText := 'Destino duplicado'
      else if TFile.Exists(Item.Target) then
        Item.ErrorText := 'Destino já existe'
      else
        Seen.Add(Key, True);
      Items.Add(Item);
    end;
    Result := Items.ToArray;
  finally
    Seen.Free;
    Items.Free;
  end;
end;

/// <summary>Codifica um caminho para armazenamento seguro no log TSV.</summary>
function EncodePath(const Value: string): string;
begin
  Result := TNetEncoding.Base64.Encode(Value);
end;

/// <summary>Decodifica um caminho previamente armazenado no log TSV.</summary>
function DecodePath(const Value: string): string;
begin
  Result := TNetEncoding.Base64.Decode(Value);
end;

procedure Execute(const Items: TArray<TRenameItem>; const LogFile: string);
var
  Item: TRenameItem;
  Log: TStringList;
  MovedCount: Integer;
begin
  Log := TStringList.Create;
  try
    MovedCount := 0;
    for Item in Items do
      if Item.ErrorText = '' then
      begin
        TFile.Move(Item.Source, Item.Target);
        Log.Add(EncodePath(Item.Target) + #9 + EncodePath(Item.Source));
        Log.SaveToFile(LogFile, TEncoding.UTF8);
        Inc(MovedCount);
      end;
    if MovedCount = 0 then
      raise Exception.Create('Nenhum arquivo está pronto para renomear.');
  finally
    Log.Free;
  end;
end;

procedure DeleteFile(const FileName: string);
begin
  if Trim(FileName) = '' then
    raise EArgumentException.Create('O arquivo não foi informado.');
  if not TFile.Exists(FileName) then
    raise EFileNotFoundException.CreateFmt('O arquivo "%s" não existe.',
      [TPath.GetFileName(FileName)]);
  TFile.Delete(FileName);
end;

procedure Undo(const LogFile: string);
var
  Lines: TStringList;
  CurrentPaths, OriginalPaths: TArray<string>;
  I, Separator: Integer;
begin
  if not TFile.Exists(LogFile) then
    raise Exception.Create('Nenhuma operação para desfazer.');
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(LogFile, TEncoding.UTF8);
    if Lines.Count = 0 then
      raise Exception.Create('O registro de desfazer está vazio.');
    SetLength(CurrentPaths, Lines.Count);
    SetLength(OriginalPaths, Lines.Count);
    for I := 0 to Lines.Count - 1 do
    begin
      Separator := Pos(#9, Lines[I]);
      if Separator = 0 then
        raise Exception.Create('O registro de desfazer está danificado.');
      try
        CurrentPaths[I] := DecodePath(Copy(Lines[I], 1, Separator - 1));
        OriginalPaths[I] := DecodePath(Copy(Lines[I], Separator + 1, MaxInt));
      except
        raise Exception.Create('O registro de desfazer está danificado.');
      end;
      if not TFile.Exists(CurrentPaths[I]) then
        raise Exception.CreateFmt('Não foi possível localizar "%s".',
          [TPath.GetFileName(CurrentPaths[I])]);
      if TFile.Exists(OriginalPaths[I]) then
        raise Exception.CreateFmt('O nome original "%s" já está em uso.',
          [TPath.GetFileName(OriginalPaths[I])]);
    end;
    for I := Lines.Count - 1 downto 0 do
      TFile.Move(CurrentPaths[I], OriginalPaths[I]);
    TFile.Delete(LogFile);
  finally
    Lines.Free;
  end;
end;

end.
