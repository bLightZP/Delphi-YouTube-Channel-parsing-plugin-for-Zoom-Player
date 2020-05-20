unit misc_utils_unit;


     {********************************************************************
      | This Source Code is subject to the terms of the                  |
      | Mozilla Public License, v. 2.0. If a copy of the MPL was not     |
      | distributed with this file, You can obtain one at                |
      | https://mozilla.org/MPL/2.0/.                                    |
      |                                                                  |
      | Software distributed under the License is distributed on an      |
      | "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or   |
      | implied. See the License for the specific language governing     |
      | rights and limitations under the License.                        |
      ********************************************************************}

      { This sample code uses the TNT Delphi Unicode Controls (compatiable
        with the last free version) to handle a few unicode tasks. }

interface

uses
  Windows, Classes, TNTClasses, ShellAPI, shlobj;


const
  // You must obtain your own key, it's free
  URLIdentifier     : String = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)';

type
  Fixed_IShellLinkW = interface(IUnknown) { sl }
    [SID_IShellLinkW]
    function GetPath(pszFile: PWideChar; cchMaxPath: Integer;
      var pfd: TWin32FindDataW; fFlags: DWORD): HResult; stdcall; // was "TWin32FindData", which is wrong.
    function GetIDList(var ppidl: PItemIDList): HResult; stdcall;
    function SetIDList(pidl: PItemIDList): HResult; stdcall;
    function GetDescription(pszName: PWideChar; cchMaxName: Integer): HResult; stdcall;
    function SetDescription(pszName: PWideChar): HResult; stdcall;
    function GetWorkingDirectory(pszDir: PWideChar; cchMaxPath: Integer): HResult; stdcall;
    function SetWorkingDirectory(pszDir: PWideChar): HResult; stdcall;
    function GetArguments(pszArgs: PWideChar; cchMaxPath: Integer): HResult; stdcall;
    function SetArguments(pszArgs: PWideChar): HResult; stdcall;
    function GetHotkey(var pwHotkey: Word): HResult; stdcall;
    function SetHotkey(wHotkey: Word): HResult; stdcall;
    function GetShowCmd(out piShowCmd: Integer): HResult; stdcall;
    function SetShowCmd(iShowCmd: Integer): HResult; stdcall;
    function GetIconLocation(pszIconPath: PWideChar; cchIconPath: Integer;
      out piIcon: Integer): HResult; stdcall;
    function SetIconLocation(pszIconPath: PWideChar; iIcon: Integer): HResult; stdcall;
    function SetRelativePath(pszPathRel: PWideChar; dwReserved: DWORD): HResult; stdcall;
    function Resolve(Wnd: HWND; fFlags: DWORD): HResult; stdcall;
    function SetPath(pszFile: PWideChar): HResult; stdcall;
  end;


function  TickCount64 : Int64;

procedure DebugMsgF(FileName : WideString; Txt : WideString);
procedure DebugMsgFT(FileName : WideString; Txt : WideString);

function  DownloadFileToStringList(URL : String; fStream : TStringList; var Status : String; var ErrorCode: Integer; TimeOut : DWord) : Boolean; overload;
function  DownloadFileToStream(URL : String; fStream : TMemoryStream; var Status : String; var ErrorCode: Integer; TimeOut : DWord) : Boolean; overload;
function  DownloadImageToFile(URL : String; ImageFilePath, ImageFileName : WideString; var Status : String; var ErrorCode: Integer; TimeOut : DWord) : Boolean; overload;
procedure DownloadImageToFileThreaded(URL : String; ImageFilePath, ImageFileName : WideString; var Status : String; var ErrorCode: Integer; TimeOut : DWord; var SuccessCode, DownloadEnded : Boolean);

function  EncodeFileName(S : WideString) : WideString;
function  DecodeFileName(S : WideString) : WideString;

function  URLEncodeUTF8(stInput : widestring) : string;
function  HTMLUnicodeToUTF8(const AStr: String): String;
function  EncodeURIComponent(const ASrc: string): UTF8String;

function  SetRegString(BaseKey : HKey; SubKey : String; KeyEntry : String; KeyValue : String) : Boolean;
function  GetRegString(BaseKey : HKey; SubKey : String; KeyEntry : String) : String;
function  SetRegDWord(BaseKey : HKey; SubKey : String; KeyEntry : String; KeyValue : Integer) : Boolean;
function  GetRegDWord(BaseKey : HKey; SubKey : String; KeyEntry : String) : Integer;

function  AddBackSlash(S : WideString) : WideString; Overload;
function  ConvertCharsToSpaces(S : WideString) : WideString;

function  DecodeTextTags(S : WideString; RemoveSuffix : Boolean) : WideString;
function  EncodeTextTags(S : WideString; AddSuffix : Boolean) : WideString;

function  StripURLHash(sURL : String) : String;

procedure FileExtIntoStringList(fPath,fExt : WideString; fList : TTNTStrings; Recursive : Boolean);

function  EncodeDuration(Dur : Integer) : WideString;
function  TimeDifferenceToStr(nowTS,thenTS : TDateTime) : String;
function  UTF8StringToWideString(Const S : UTF8String) : WideString;
function  WideStringToUTF8String(Const S : WideString) : UTF8String;
function  IntToStrDelimiter(iSrc : Int64; dChar : Char) : String;
function  DosToAnsi(S: String): String;
function  WidePosEx(SubStr, S : WideString; Offset : Cardinal = 1) : Integer;
function  EnDeCrypt(const Value : String) : String;

function  EraseFile(FileName : WideString) : Boolean;

function  InputComboW(ownerWindow: THandle; const ACaption, APrompt: Widestring; const AList: TTNTStrings; var AOutput : WideString) : Boolean;

procedure Split(S : String; Ch : Char; sList : TStrings); overload;
procedure Split(S : WideString; Ch : Char; sList : TTNTStrings); overload;

function  sParamCount(S : WideString) : Integer;
function  GetSParam(PItem : Integer; PList : WideString; StripSpace : Boolean) : WideString; Overload;
function  GetSLeftParam(S : String) : String;
function  GetSRightParam(S : WideString; StripSpace : Boolean) : WideString;

Function  ExtractFileNameNoExt(FileName : WideString) : WideString;
function  WidePosRev(SubStr, S : WideString) : Integer;
function  WideExtractFilePathEx(FileName : WideString) : WideString;
function  StringToFloat(S : String) : Double;
function  StringToFloatDef(S : String; dValue : Double) : Double;

function  FileAgeW(const FileName: widestring): Integer;
function  GetFileSize(FileName : Widestring) : Int64;
function  WideExtractFileNameEx(FileName : WideString) : WideString;
function  GetCurrentDLLPath : WideString;
function  HashWideString(S : WideString) : Integer;

function  WinExecAndWait32(FileName : WideString; Visibility : integer; waitforexec,console : boolean) : Integer;
procedure GetShortCutFileName(FileName : WideString; var NewFileName,NewParameters : Widestring);

implementation

uses
  SysUtils, SyncObjs, TNTSysUtils, wininet, dateutils, graphics ,forms, tntforms, stdctrls, tntStdCtrls, controls, ActiveX;

type
  TDownloadThread = Class(TThread)
    procedure execute; override;
  public
    DownloadEnded  : PBoolean;
    SuccessCode    : PBoolean;
    URL            : String;
    ImageFilePath  : WideString;
    ImageFileName  : WideString;
    Status         : PString;
    ErrorCode      : PInteger;
    TimeOut        : DWord;
  end;

var
  TickCountLast    : DWORD = 0;
  TickCountBase    : Int64 = 0;
  DebugStartTime   : Int64 = -1;
  qTimer64Freq     : Int64;
  csDebug          : TCriticalSection;


function TickCount64 : Int64;
begin
  Result := GetTickCount;
  If Result < TickCountLast then TickCountBase := TickCountBase+$100000000;
  TickCountLast := Result;
  Result := Result+TickCountBase;
end;


procedure DebugMsgFT(FileName : WideString; Txt : WideString);
var
  S,S1 : String;
  i64  : Int64;
begin
  If FileName <> '' then
  Begin
    QueryPerformanceCounter(i64);
    S := FloatToStrF(((i64-DebugStartTime)*1000) / qTimer64Freq,ffFixed,15,3);
    While Length(S) < 12 do S := ' '+S;
    S1 := DateToStr(Date)+' '+TimeToStr(Time);
    DebugMsgF(FileName,S1+' ['+S+'] : '+Txt);
  End;
end;


procedure DebugMsgF(FileName : WideString; Txt : WideString);
var
  fStream  : TTNTFileStream;
  S        : String;
begin
  If FileName <> '' then
  Begin
    csDebug.Enter;
    Try
      If WideFileExists(FileName) = True then
      Begin
        Try
          fStream := TTNTFileStream.Create(FileName,fmOpenWrite);
        Except
          fStream := nil;
        End;
      End
        else
      Begin
        Try
           fStream := TTNTFileStream.Create(FileName,fmCreate);
        Except
          fStream := nil;
        End;
      End;
      If fStream <> nil then
      Begin
        S := UTF8Encode(Txt)+CRLF;
        fStream.Seek(0,soFromEnd);
        fStream.Write(S[1],Length(S));
        fStream.Free;
       End;
    Finally
      csDebug.Leave;
    End;
  End;
end;


function  DownloadFileToStringList(URL : String; fStream : TStringList; var Status : String; var ErrorCode: Integer; TimeOut : DWord) : Boolean;
var
  MemStream : TMemoryStream;
begin
  Result := False;
  If fStream <> nil then
  Begin
    MemStream := TMemoryStream.Create;
    Result := DownloadFileToStream(URL,MemStream,Status,ErrorCode,TimeOut);
    MemStream.Position := 0;
    fStream.LoadFromStream(MemStream);
    MemStream.Free;
  End;
end;


(*
function DownloadFileToStringList(URL : String; fStream : TStringList) : Boolean;
var
  Status    : String;
  ErrorCode : DWord;
begin
  Result := DownloadFileToStringList(URL,fStream,Status,ErrorCode,0);
end;
(**)


function DownloadFileToStream(URL : String; fStream : TMemoryStream; var Status : String; var ErrorCode: Integer; TimeOut : DWord) : Boolean;
type
  DLBufType = Array[0..1024] of Char;
const
  MaxRetryAttempts = 5;
  RetryInterval = 1; //seconds
var
  NetHandle  : HINTERNET;
  URLHandle  : HINTERNET;
  DLBuf      : ^DLBufType;
  BytesRead  : DWord;
  infoBuffer : Array [0..512] of char;
  bufLen     : DWORD;
  Tmp        : DWord;
  iAttemptsLeft : Integer;
  AttemptAgain  : Boolean;
  RetryAfter: String;
begin
  Result := False;
  Status := '';
  ErrorCode := 0;
  If fStream <> nil then
  Begin
    NetHandle := InternetOpen(PChar(URLIdentifier),INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
    If Assigned(NetHandle) then
    Begin
      If TimeOut > 0 then
      Begin
        InternetSetOption(NetHandle,INTERNET_OPTION_CONNECT_TIMEOUT,@TimeOut,Sizeof(TimeOut));
        InternetSetOption(NetHandle,INTERNET_OPTION_SEND_TIMEOUT   ,@TimeOut,Sizeof(TimeOut));
        InternetSetOption(NetHandle,INTERNET_OPTION_RECEIVE_TIMEOUT,@TimeOut,Sizeof(TimeOut));
      End;

      iAttemptsLeft := MaxRetryAttempts;
      repeat
        AttemptAgain := False;

        UrlHandle := InternetOpenUrl(NetHandle,PChar(URL),nil,0,INTERNET_FLAG_RELOAD,0);
        If Assigned(UrlHandle) then
        Begin
          tmp    := 0;
          bufLen := Length(infoBuffer);

          If HttpQueryInfo(UrlHandle,HTTP_QUERY_STATUS_CODE,@infoBuffer[0],bufLen,tmp) = True then
          Begin
            Status := infoBuffer;

            RetryAfter := '';
            If Status = '429' then
            Begin
              //To get all headers use the following code
              //  HttpQueryInfo(UrlHandle,HTTP_QUERY_RAW_HEADERS_CRLF,@Headers[0],bufLen,tmp);
              //for guidance and hints on buffer sizes and in/out params see:
              //  https://msdn.microsoft.com/en-us/library/windows/desktop/aa385373%28v=vs.85%29.aspx

              //Retry-After
              //X-RateLimit-Limit: 40
              //X-RateLimit-Remaining: 39
              //X-RateLimit-Reset: 1453056622
              bufLen := Length(infoBuffer);
              infoBuffer := 'Retry-After';
              if HttpQueryInfo(UrlHandle,HTTP_QUERY_CUSTOM,@infoBuffer[0],bufLen,tmp) then
                RetryAfter := infoBuffer
              else RetryAfter := '';
            End;

            New(DLBuf);
            fStream.Clear;
            Repeat
              ZeroMemory(DLBuf,Sizeof(DLBufType));
              If InternetReadFile(UrlHandle,DLBuf,SizeOf(DLBufType),BytesRead) = True then
                If BytesRead > 0 then fStream.Write(DLBuf^,BytesRead);
            Until (BytesRead = 0);
            Dispose(DLBuf);

            If Status = '200' then Result := True
            else If Status = '429' then // 429 - Too Many Requests
            Begin
              AttemptAgain := True;
              Dec(iAttemptsLeft);
              Sleep(1000 * StrToIntDef(RetryAfter, RetryInterval));
            End
          End;
          InternetCloseHandle(UrlHandle);
        End
          else ErrorCode := GetLastError;
      until
        not (AttemptAgain and (iAttemptsLeft > 0));
      InternetCloseHandle(NetHandle);
    End;
  End;
end;


(*
function DownloadFileToStream(URL : String; fStream : TMemoryStream) : Boolean;
var
  Status    : String;
  ErrorCode : DWord;
begin
  Result := DownloadFileToStream(URL,fStream,Status,ErrorCode,0);
end;
(**)

procedure TDownloadThread.execute;
begin
  SuccessCode^   := DownloadImageToFile(URL,ImageFilePath,ImageFileName,Status^,ErrorCode^,TimeOut);
  DownloadEnded^ := True;
end;


procedure DownloadImageToFileThreaded(URL : String; ImageFilePath, ImageFileName : WideString; var Status : String; var ErrorCode: Integer; TimeOut : DWord; var SuccessCode, DownloadEnded : Boolean);
var
  DownloadThread : TDownloadthread;
begin
  DownloadThread                    := TDownloadThread.Create(True);
  DownloadThread.Priority           := tpIdle;
  DownloadThread.FreeOnTerminate    := True;
  DownloadThread.URL                := URL;
  DownloadThread.ImageFilePath      := ImageFilePath;
  DownloadThread.ImageFileName      := ImageFileName;
  DownloadThread.Status             := @Status;
  DownloadThread.ErrorCode          := @ErrorCode;
  DownloadThread.TimeOut            := TimeOut;
  DownloadThread.SuccessCode        := @SuccessCode;
  DownloadThread.SuccessCode^       := False;
  DownloadThread.DownloadEnded      := @DownloadEnded;
  DownloadThread.DownloadEnded^     := False;

  DownloadThread.Resume;
end;


function  DownloadImageToFile(URL : String; ImageFilePath, ImageFileName : WideString; var Status : String; var ErrorCode: Integer; TimeOut : DWord) : Boolean;
var
  iStream : TMemoryStream;
  fStream : TTNTFileStream;
begin
  Result := False;
  // Download image to memory stream
  iStream := TMemoryStream.Create;
  iStream.Clear;
  If DownloadFileToStream(URL,iStream,Status,ErrorCode,TimeOut) = True then
  Begin
    If iStream.Size > 0 then
    Begin
      // Create the destination folder if it doesn't exist
      If WideDirectoryExists(ImageFilePath) = False then WideForceDirectories(ImageFilePath);

      // Save the source image to disk
      Try
        fStream := TTNTFileStream.Create(ImageFilePath+ImageFileName,fmCreate);
      Except
        fStream := nil
      End;
      If fStream <> nil then
      Begin
        iStream.Position := 0;
        Try
          fStream.CopyFrom(iStream,iStream.Size);
          Result := True;
        Finally
          fStream.Free;
        End;
      End;
    End;
  End;
  iStream.Free;
end;


(*
function DownloadImageToFile(URL : String; ImageFilePath, ImageFileName : WideString) : Boolean;
var
  Status    : String;
  ErrorCode : DWord;
begin
  Result := DownloadImageToFile(URL,ImageFilePath,ImageFileName,Status,ErrorCode,0);
end;
(**)


function URLEncodeUTF8(stInput : widestring) : string;
const
  Hex : array[0..255] of string = (
    '%00', '%01', '%02', '%03', '%04', '%05', '%06', '%07',
    '%08', '%09', '%0a', '%0b', '%0c', '%0d', '%0e', '%0f',
    '%10', '%11', '%12', '%13', '%14', '%15', '%16', '%17',
    '%18', '%19', '%1a', '%1b', '%1c', '%1d', '%1e', '%1f',
    '%20', '%21', '%22', '%23', '%24', '%25', '%26', '%27',
    '%28', '%29', '%2a', '%2b', '%2c', '%2d', '%2e', '%2f',
    '%30', '%31', '%32', '%33', '%34', '%35', '%36', '%37',
    '%38', '%39', '%3a', '%3b', '%3c', '%3d', '%3e', '%3f',
    '%40', '%41', '%42', '%43', '%44', '%45', '%46', '%47',
    '%48', '%49', '%4a', '%4b', '%4c', '%4d', '%4e', '%4f',
    '%50', '%51', '%52', '%53', '%54', '%55', '%56', '%57',
    '%58', '%59', '%5a', '%5b', '%5c', '%5d', '%5e', '%5f',
    '%60', '%61', '%62', '%63', '%64', '%65', '%66', '%67',
    '%68', '%69', '%6a', '%6b', '%6c', '%6d', '%6e', '%6f',
    '%70', '%71', '%72', '%73', '%74', '%75', '%76', '%77',
    '%78', '%79', '%7a', '%7b', '%7c', '%7d', '%7e', '%7f',
    '%80', '%81', '%82', '%83', '%84', '%85', '%86', '%87',
    '%88', '%89', '%8a', '%8b', '%8c', '%8d', '%8e', '%8f',
    '%90', '%91', '%92', '%93', '%94', '%95', '%96', '%97',
    '%98', '%99', '%9a', '%9b', '%9c', '%9d', '%9e', '%9f',
    '%a0', '%a1', '%a2', '%a3', '%a4', '%a5', '%a6', '%a7',
    '%a8', '%a9', '%aa', '%ab', '%ac', '%ad', '%ae', '%af',
    '%b0', '%b1', '%b2', '%b3', '%b4', '%b5', '%b6', '%b7',
    '%b8', '%b9', '%ba', '%bb', '%bc', '%bd', '%be', '%bf',
    '%c0', '%c1', '%c2', '%c3', '%c4', '%c5', '%c6', '%c7',
    '%c8', '%c9', '%ca', '%cb', '%cc', '%cd', '%ce', '%cf',
    '%d0', '%d1', '%d2', '%d3', '%d4', '%d5', '%d6', '%d7',
    '%d8', '%d9', '%da', '%db', '%dc', '%dd', '%de', '%df',
    '%e0', '%e1', '%e2', '%e3', '%e4', '%e5', '%e6', '%e7',
    '%e8', '%e9', '%ea', '%eb', '%ec', '%ed', '%ee', '%ef',
    '%f0', '%f1', '%f2', '%f3', '%f4', '%f5', '%f6', '%f7',
    '%f8', '%f9', '%fa', '%fb', '%fc', '%fd', '%fe', '%ff');
var
  iLen,iIndex : integer;
  stEncoded   : string;
  ch          : widechar;
begin
  iLen := Length(stInput);
  stEncoded := '';
  for iIndex := 1 to iLen do
  begin
    ch := stInput[iIndex];
    If (ch >= 'A') and (ch <= 'Z') then stEncoded := stEncoded + ch
      else
    If (ch >= 'a') and (ch <= 'z') then stEncoded := stEncoded + ch
      else
    If (ch >= '0') and (ch <= '9') then stEncoded := stEncoded + ch
      else
    If (ch = ' ') then stEncoded := stEncoded + '%20'//'+'
      else
    If ((ch = '-') or (ch = '_') or (ch = '.') or (ch = '!') or (ch = '*') or (ch = '~') or (ch = '\')  or (ch = '(') or (ch = ')')) then stEncoded := stEncoded + ch
      else
    If (Ord(ch) <= $07F) then stEncoded := stEncoded + hex[Ord(ch)]
      else
    If (Ord(ch) <= $7FF) then
    begin
      stEncoded := stEncoded + hex[$c0 or (Ord(ch) shr 6)];
      stEncoded := stEncoded + hex[$80 or (Ord(ch) and $3F)];
    end
      else
    begin
      stEncoded := stEncoded + hex[$e0 or (Ord(ch) shr 12)];
      stEncoded := stEncoded + hex[$80 or ((Ord(ch) shr 6) and ($3F))];
      stEncoded := stEncoded + hex[$80 or ((Ord(ch)) and ($3F))];
    end;
  end;
  result := (stEncoded);
end;



function EncodeURIComponent(const ASrc: string): UTF8String;
const
  HexMap: UTF8String = '0123456789ABCDEF';

  function IsSafeChar(ch: Integer): Boolean;
  begin
    if (ch >= 48) and (ch <= 57) then Result := True    // 0-9
    else if (ch >= 65) and (ch <= 90) then Result := True  // A-Z
    else if (ch >= 97) and (ch <= 122) then Result := True  // a-z
    else if (ch = 33) then Result := True // !
    else if (ch >= 39) and (ch <= 42) then Result := True // '()*
    else if (ch >= 45) and (ch <= 46) then Result := True // -.
    else if (ch = 95) then Result := True // _
    else if (ch = 126) then Result := True // ~
    else Result := False;
  end;
var
  I, J: Integer;
  ASrcUTF8: UTF8String;
begin
  Result := '';    {Do not Localize}

  ASrcUTF8 := UTF8Encode(ASrc);
  // UTF8Encode call not strictly necessary but
  // prevents implicit conversion warning

  I := 1; J := 1;
  SetLength(Result, Length(ASrcUTF8) * 3); // space to %xx encode every byte
  while I <= Length(ASrcUTF8) do
  begin
    if IsSafeChar(Ord(ASrcUTF8[I])) then
    begin
      Result[J] := ASrcUTF8[I];
      Inc(J);
    end
    else if ASrcUTF8[I] = ' ' then
    begin
      Result[J] := '+';
      Inc(J);
    end
    else
    begin
      Result[J] := '%';
      Result[J+1] := HexMap[(Ord(ASrcUTF8[I]) shr 4) + 1];
      Result[J+2] := HexMap[(Ord(ASrcUTF8[I]) and 15) + 1];
      Inc(J,3);
    end;
    Inc(I);
  end;

  SetLength(Result, J-1);
end;


function  GetRegString(BaseKey : HKey; SubKey : String; KeyEntry : String) : String;
var
  RegHandle : HKey;
  RegType   : LPDWord;
  BufSize   : LPDWord;
  KeyValue  : String;
begin
  Result := '';
  If RegOpenKeyEx(BaseKey,PChar(SubKey),0,KEY_READ,RegHandle) = ERROR_SUCCESS then
  Begin
    New(RegType);
    New(BufSize);
    RegType^ := Reg_SZ;
    BufSize^ := 65535;
    SetLength(KeyValue,65535);
    If RegQueryValueEx(RegHandle,PChar(KeyEntry),nil,RegType,@KeyValue[1],BufSize) = ERROR_SUCCESS then
    Begin
      If BufSize^ > 0 then SetLength(KeyValue,BufSize^-1) else KeyValue := '';
      Result := KeyValue;
    End;
    Dispose(BufSize);
    Dispose(RegType);
    RegCloseKey(RegHandle);
  End;
end;


function SetRegString(BaseKey : HKey; SubKey : String; KeyEntry : String; KeyValue : String) : Boolean;
var
  RegHandle : HKey;
  S         : String;
  I         : Integer;
begin
  Result := False;
  If RegCreateKeyEx(BaseKey,PChar(SubKey),0,nil,REG_OPTION_NON_VOLATILE,KEY_ALL_ACCESS,nil,RegHandle,@I) = ERROR_SUCCESS then
  Begin
    If KeyValue = '' then S := #0 else S := KeyValue;
    Result := RegSetValueEx(RegHandle,@KeyEntry[1],0,REG_SZ,@S[1],Length(S)) = ERROR_SUCCESS;
    RegCloseKey(RegHandle);
  End;
end;


function SetRegDWord(BaseKey : HKey; SubKey : String; KeyEntry : String; KeyValue : Integer) : Boolean;
var
  RegHandle : HKey;
  I         : Integer;
begin
  Result := False;
  If RegCreateKeyEx(BaseKey,PChar(SubKey),0,nil,REG_OPTION_NON_VOLATILE,KEY_ALL_ACCESS,nil,RegHandle,@I) = ERROR_SUCCESS then
  Begin
    If RegSetValueEx(RegHandle,PChar(KeyEntry),0,REG_DWORD,@KeyValue,4) = ERROR_SUCCESS then Result := True;
    RegCloseKey(RegHandle);
  End;
end;


function GetRegDWord(BaseKey : HKey; SubKey : String; KeyEntry : String) : Integer;
var
  RegHandle : HKey;
  RegType   : LPDWord;
  BufSize   : LPDWord;
  KeyValue  : Integer;
begin
  Result := -1;
  If RegOpenKeyEx(BaseKey,PChar(SubKey),0,KEY_READ,RegHandle) = ERROR_SUCCESS then
  Begin
    New(RegType);
    New(BufSize);
    RegType^ := Reg_DWORD;
    BufSize^ := 4;
    If RegQueryValueEx(RegHandle,PChar(KeyEntry),nil,RegType,@KeyValue,BufSize) = ERROR_SUCCESS then
    Begin
      Result := KeyValue;
    End;
    Dispose(BufSize);
    Dispose(RegType);
    RegCloseKey(RegHandle);
  End;
end;



function AddBackSlash(S : WideString) : WideString; Overload;
var I : Integer;
begin
  I := Length(S);
  If I > 0 then If (S[I] <> '\') and (S[I] <> '/') then S := S+'\';
  Result := S;
end;


function ConvertCharsToSpaces(S : WideString) : WideString;
begin
  Result := TNT_WideStringReplace(TNT_WideStringReplace(TNT_WideStringReplace(S,'-', ' ', [rfReplaceAll]), '.', ' ', [rfReplaceAll]), '_', ' ', [rfReplaceAll]);
end;


function  StripURLHash(sURL : String) : String;
var
  iPos : Integer;
begin
  iPos := Pos('#',sURL);
  If iPos > 0 then
  Begin
    Result := Copy(sURL,1,iPos-1);
  End
  Else Result := sURL;
end;


procedure FileExtIntoStringList(fPath,fExt : WideString; fList : TTNTStrings; Recursive : Boolean);
var
  sRec : TSearchRecW;
begin
  If WideFindFirst(fPath+'*.*',faAnyFile,sRec) = 0 then
  Begin
    Repeat
      If (Recursive = True) and (sRec.Attr and faDirectory = faDirectory) and (sRec.Name <> '.') and (sRec.Name <> '..') then
      Begin
        FileExtIntoStringList(AddBackSlash(fPath+sRec.Name),fExt,fList,Recursive);
      End
        else
      If (sRec.Attr and faVolumeID = 0) and (sRec.Attr and faDirectory = 0) then
      Begin
        If WideCompareText(WideExtractFileExt(sRec.Name),fExt) = 0 then
          fList.Add(fPath+sRec.Name);
      End;
    Until WideFindNext(sRec) <> 0;
    WideFindClose(sRec);
  End;
end;


function DecodeTextTags(S : WideString; RemoveSuffix : Boolean) : WideString;
var
  S1 : WideString;
begin
  If RemoveSuffix = True then S1 := ';' else S1 := '';
  S := TNT_WideStringReplace(S,'&apos' +S1,'''',[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'&comma'+S1,',' ,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'&quot' +S1,'"' ,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'&lt'   +S1,'<' ,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'&gt'   +S1,'>' ,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'&amp'  +S1,'&' ,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'&pipe' +S1,'|' ,[rfReplaceAll]);
  Result := S;
end;


function EncodeTextTags(S : WideString; AddSuffix : Boolean) : WideString;
var
  S1 : WideString;
  I  : Integer;
begin
  If AddSuffix = True then S1 := ';' else S1 := '';
  S := TNT_WideStringReplace(S,'&' ,'&amp'  +S1,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'''','&apos' +S1,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,',' ,'&comma'+S1,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'"' ,'&quot' +S1,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'<' ,'&lt'   +S1,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'>' ,'&gt'   +S1,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'|' ,'&pipe' +S1,[rfReplaceAll]);


  //for I := 1 to Length(S) do If Ord(S[I]) = $2028 then S[I] := #32;
  for I := 1 to Length(S) do If Word(S[I]) = $2028 then S[I] := #32;
  Result := S;
end;


function EncodeDuration(Dur : Integer) : WideString;
var
  dHours   : Integer;
  dMinutes : Integer;
  dSeconds : Integer;
begin
  dHours   := Dur div 3600;
  Dec(Dur,dHours*3600);
  dMinutes := Dur div 60;
  Dec(Dur,dMinutes*60);
  dSeconds := Dur;

  If dHours > 0 then
    Result := IntToStr(dHours)  +'h '+IntToStr(dMinutes)+'m' else
    Result := IntToStr(dMinutes)+'m '+IntToStr(dSeconds)+'s';
end;


function  TimeDifferenceToStr(nowTS,thenTS : TDateTime) : String;
const
  yearInSec  : Int64 = 31557600;
  monthInSec : Int64 = 2629800;
  dayInSec   : Int64 = 86400;
  hourInSec  : Int64 = 3600;
  minInSec   : Int64 = 60;
var
  secDiff    : Int64;
  minDiff    : Int64;
  hourDiff   : Int64;
  dayDiff    : Int64;
  monthDiff  : Int64;
  yearDiff   : Int64;
begin
  secDiff := SecondsBetween(nowTS,thenTS);

  yearDiff := secDiff div yearInSec;
  Dec(secDiff,yearDiff*yearInSec);

  monthDiff := secDiff div monthInSec;
  Dec(secDiff,monthDiff*monthInSec);

  dayDiff := secDiff div dayInSec;
  Dec(secDiff,dayDiff*dayInSec);

  hourDiff := secDiff div hourInSec;
  Dec(secDiff,hourDiff*hourInSec);

  minDiff := secDiff div minInSec;
  Dec(secDiff,minDiff*minInSec);

  Result := '';
  If yearDiff > 0 then
  Begin
    If yearDiff = 1 then
      Result := IntToStr(yearDiff)+' year' else
      Result := IntToStr(yearDiff)+' years';
  End
    else
  If monthDiff > 0 then
  Begin
    If monthDiff = 1 then
      Result := IntToStr(monthDiff)+' month' else
      Result := IntToStr(monthDiff)+' months';
  End
    else
  If dayDiff > 0 then
  Begin
    If dayDiff = 1 then
      Result := IntToStr(dayDiff)+' day' else
      Result := IntToStr(dayDiff)+' days';
  End
    else
  If hourDiff > 0 then
  Begin
    If hourDiff = 1 then
      Result := IntToStr(hourDiff)+' hour' else
      Result := IntToStr(hourDiff)+' hours';
  End
    else
  If minDiff > 0 then
  Begin
    If minDiff = 1 then
      Result := IntToStr(minDiff)+' minute' else
      Result := IntToStr(minDiff)+' minutes';
  End
    else
  If secDiff > 0 then
  Begin
    If secDiff = 1 then
      Result := IntToStr(secDiff)+' second' else
      Result := IntToStr(secDiff)+' seconds';
  End
end;


function UTF8StringToWideString(Const S : UTF8String) : WideString;
var
  iLen :Integer;
  sw   :WideString;
begin
  Result := '';
  if Length(S) = 0 then Exit;
  iLen := MultiByteToWideChar(CP_UTF8,0,PAnsiChar(s),-1,nil,0);
  SetLength(sw,iLen);
  MultiByteToWideChar(CP_UTF8,0,PAnsiChar(s),-1,PWideChar(sw),iLen);
  iLen := Pos(#0,sw);
  If iLen > 0 then SetLength(sw,iLen-1);
  Result := sw;
end;


function WideStringToUTF8String(Const S : WideString) : UTF8String;
var
  iLen:Integer;
  su  :UTF8String;
begin
  result := '';
  if Length(s)=0 then Exit;
  iLen :=WideCharToMultiByte(CP_UTF8,0,PWideChar(s),-1,nil,0,nil,nil);
  SetLength(su,iLen);
  WideCharToMultiByte(CP_UTF8,0,PWideChar(s),-1,PAnsiChar(su),iLen,nil,nil);
  Result:=su;
end;


function IntToStrDelimiter(iSrc : Int64; dChar : Char) : String;
var
  I : Integer;
  S : String;
begin
  S      := IntToStr(iSrc);
  Result := S;
  I      := Length(S)-2;
  While I > 1 do
  Begin
    Insert(dChar,Result,I);
    Dec(I,3);
  End;
end;


function DosToAnsi(S: String): String;
begin
  SetLength(Result, Length(S));
  OEMToCharBuff(PChar(S), PChar(Result), Length(S));
end;


function InputComboW(ownerWindow: THandle; const ACaption, APrompt: Widestring; const AList: TTNTStrings; var AOutput : WideString) : Boolean;

  function GetCharSize(Canvas: TCanvas): TPoint;
  var
    I: Integer;
    Buffer: array[0..51] of Char;
  begin
    for I := 0 to 25 do Buffer[I] := Chr(I + Ord('A'));
    for I := 0 to 25 do Buffer[I + 26] := Chr(I + Ord('a'));
    GetTextExtentPoint(Canvas.Handle, Buffer, 52, TSize(Result));
    Result.X := Result.X div 52;
  end;  
  
var
  Form         : TTNTForm;
  Prompt       : TTNTLabel;
  Combo        : TTNTComboBox;
  DialogUnits  : TPoint;
  ButtonTop,
  ButtonWidth,
  ButtonHeight : Integer;
  CenterOnRect : TRect;
begin
  AOutput := '';
  Result  := False;
  Form    := TTNTForm.Create(nil);
  with Form do
    try
      Canvas.Font := Font;
      DialogUnits := GetCharSize(Canvas);
      BorderStyle := bsDialog;
      Caption     := ACaption;
      ClientWidth := MulDiv(180, DialogUnits.X, 4);
      Prompt      := TTNTLabel.Create(Form);
      with Prompt do
      begin
        Parent   := Form;
        Caption  := APrompt;
        Left     := MulDiv(8, DialogUnits.X, 4);
        Top      := MulDiv(8, DialogUnits.Y, 8);
        Constraints.MaxWidth := MulDiv(164, DialogUnits.X, 4);
        WordWrap := True;
      end;
      Combo := TTNTComboBox.Create(Form);
      with Combo do
      begin
        Parent     := Form;
        Style      := csDropDownList;
        Items.Assign(AList);
        ItemIndex  := 0;
        Left       := Prompt.Left;
        Top        := Prompt.Top + Prompt.Height + 5;
        Width      := MulDiv(164, DialogUnits.X, 4);
      end;
      ButtonTop    := Combo.Top + Combo.Height + 15;
      ButtonWidth  := MulDiv(50, DialogUnits.X, 4);
      ButtonHeight := MulDiv(14, DialogUnits.Y, 8);
      with TTNTButton.Create(Form) do
      begin
        Parent      := Form;
        Caption     := 'OK';
        ModalResult := mrOk;
        default     := True;
        SetBounds(MulDiv(38, DialogUnits.X, 4), ButtonTop, ButtonWidth, ButtonHeight);
      end;
      with TTNTButton.Create(Form) do
      begin
        Parent      := Form;
        Caption     := 'Cancel';
        ModalResult := mrCancel;
        Cancel      := True;
        SetBounds(MulDiv(92, DialogUnits.X, 4), Combo.Top + Combo.Height + 15, ButtonWidth, ButtonHeight);
        Form.ClientHeight := Top + Height + 13;
      end;

      If GetWindowRect(ownerWindow,CenterOnRect) = False then
        GetWindowRect(0,CenterOnRect); // Can't find window, center on screen

      SetBounds(CenterOnRect.Left+(((CenterOnRect.Right-CenterOnRect.Left)-Width) div 2),CenterOnRect.Top+(((CenterOnRect.Bottom-CenterOnRect.Top)-Height) div 2),Width,Height);

      if ShowModal = mrOk then
      begin
        AOutput := Combo.Text;
        Result  := True;
      end;
    finally
      Form.Free;
    end;
end;

// Based on : http://stackoverflow.com/questions/1657105/delphi-html-decode
// With modifications to maintain UTF8Encoding while converting &#0000 type unicode characters
function HTMLUnicodeToUTF8(const AStr: String): String;
var
  Sp, Cp, Tp : PChar;
  S          : String;
  I, Code    : Integer;
  sWide      : WideString;
begin
  Result := '';
  Sp := PChar(AStr);
  Cp := Sp;
  try
    while Sp^ <> #0 do
    begin
      case Sp^ of
        '&': begin
               Cp := Sp;
               Inc(Sp);
               case Sp^ of
                 'a': if AnsiStrPos(Sp, 'amp;') = Sp then  { do not localize }
                      begin
                        Inc(Sp,3);
                        Result := Result+'&';
                      end;
                 'l',
                 'g': if (AnsiStrPos(Sp, 'lt;') = Sp) or (AnsiStrPos(Sp, 'gt;') = Sp) then { do not localize }
                      begin
                        Cp := Sp;
                        Inc(Sp, 2);
                        while (Sp^ <> ';') and (Sp^ <> #0) do Inc(Sp);
                        if Cp^ = 'l' then Result := Result+'<' else Result := Result+'>';
                      end;
                 'q': if AnsiStrPos(Sp, 'quot;') = Sp then  { do not localize }
                      begin
                        Inc(Sp,4);
                        Result := Result+'"';
                      end;
                 '#': begin
                        Tp := Sp;
                        Inc(Tp);
                        while (Sp^ <> ';') and (Sp^ <> #0) do Inc(Sp);
                        SetString(S, Tp, Sp - Tp);
                        Val(S, I, Code);
                        sWide := WideChar(I);
                        Result := Result+UTF8Encode(sWide);
                      end;
                 else
                   begin
                     Result := '';
                     Exit;
                   end;
               end;
           end
      else ;
        Result := Result+Sp^;
      end;
      Inc(Sp);
    end;
  except
    Result := '';
  end;
end;


procedure Split(S : String; Ch : Char; sList : TStrings); overload;
var
  I : Integer;
begin
  While Pos(Ch,S) > 0 do
  Begin
    I := Pos(Ch,S);
    sList.Add(Copy(S,1,I-1));
    Delete(S,1,I);
  End;
  If Length(S) > 0 then sList.Add(S);
end;


procedure Split(S : WideString; Ch : Char; sList : TTNTStrings); overload;
var
  I : Integer;
begin
  While Pos(Ch,S) > 0 do
  Begin
    I := Pos(Ch,S);
    sList.Add(Copy(S,1,I-1));
    Delete(S,1,I);
  End;
  If Length(S) > 0 then sList.Add(S);
end;


function EncodeFileName(S : WideString) : WideString;
begin
  // Invalid Chars \/:"*?<>|
  S := TNT_WideStringReplace(S,'/' ,'&sl'    ,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'\' ,'&bsl'   ,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,':' ,'&colon' ,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'"' ,'&quot'  ,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'*' ,'&star'  ,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'?' ,'&qmark' ,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'<' ,'&lt'    ,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'>' ,'&gt'    ,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'|' ,'&pipe'  ,[rfReplaceAll]);

  Result := S;
end;


function DecodeFileName(S : WideString) : WideString;
begin
  // Invalid Chars \/:"*?<>|
  S := TNT_WideStringReplace(S,'&sl'    ,'/' ,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'&bsl'   ,'\' ,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'&colon' ,':' ,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'&quot'  ,'"' ,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'&star'  ,'*' ,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'&qmark' ,'?' ,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'&lt'    ,'<' ,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'&gt'    ,'>' ,[rfReplaceAll]);
  S := TNT_WideStringReplace(S,'&pipe'  ,'|' ,[rfReplaceAll]);

  Result := S;
end;


function sParamCount(S : WideString) : Integer;
var
  I,I1    : Integer;
  inBlock : Boolean;
  sLen    : Integer;
begin
  // fixed 06-dec-2016, no accounting for empty string
  I1 := 0;
  sLen := Length(S);
  If sLen > 0 then
  Begin
    If Pos('"',S) > 0 then
    Begin
      inBlock := False;
      For I := 1 to sLen do
      Begin
        If (S[I] = '"') and (I = 1) then inBlock := True
          else
        If (S[I] = '(') and (I < sLen) then
        Begin
          If S[I+1] = '"' then inBlock := True;
        End
          else
        If (S[I] = ',') and (I < sLen) and (inBlock = False) then
        Begin
          Inc(I1);
          If S[I+1] = '"' then inBlock := True;
        End
          else
        If (inBlock = True) and (I < sLen) then
        Begin
          If (S[I+1] = '"') then inBlock := False;
        End;
      End;
    End
    Else For I := 1 to sLen do If S[I] = ',' then Inc(I1);
    Result := I1+1;
  End
  Else Result := 0;
end;


function GetSParam(PItem : Integer; PList : WideString; StripSpace : Boolean) : WideString; Overload;
var
//  S      : WideString;
  I,I1   : Integer;
  iStart : Integer;
  iEnd   : Integer;
  pPos   : Integer;
  pEnd   : Integer;
  Count  : Integer;
  sLen   : Integer;
  inBlock: Boolean;
begin
  I1 := 0;
  sLen := Length(PList);
  For I := sLen downto 1 do If PList[I] = ')' then
  Begin
    I1 := I;
    Break;
  End;

  I  := Pos('(',PList);
  If (I > 0) and (I1 > 0) then
  Begin
    iStart  := I+1;  // Starting Position
    pPos    := iStart;
    iEnd    := I1-1; // End Position
    Count   := 1;    // Parameter Count
    inBlock := False;

    If WidePosEx('"',PList,iStart) > 0 then // Special processing for strings
    Begin
      If pItem > Count then // Find Parameter Position
      Begin
        For I := iStart to iEnd do
        Begin
          If (PList[I] = '"') and (I = iStart) then inBlock := True
            else
          If (PList[I] = ',') and (I < sLen) and (inBlock = False) then
          Begin
            Inc(Count);
            If PList[I+1] = '"' then inBlock := True;
          End
            else
          If (inBlock = True) and (I < sLen) then
          Begin
            If (PList[I+1] = '"') then inBlock := False;
          End;
          If Count = PItem then
          Begin
            pPos := I+1;
            Break;
          End;
        End;
      End
        else
      Begin
        pPos := iStart;
        If PList[iStart] = '"' then inBlock := True;
      End;
      // Find End Position of Parameter
      If inBlock = True then
        pEnd := WidePosEx('"',PList,pPos+1) else
        pEnd := WidePosEx(',',PList,pPos+1)-1;

      If pEnd <= 0 then pEnd := iEnd; // In case this is the last Parameter
      If (PList[pPos] = '"') and (PList[pEnd] = '"') then
      Begin
        Inc(pPos);
        Dec(pEnd);
      End;
    End
      else
    Begin
      If pItem > Count then // Find Parameter Position
      Begin
        For I := IStart to iEnd do If PList[I] = ',' then
        Begin
          Inc(Count);
          If Count = PItem then
          Begin
            pPos := I+1;
            Break;
          End;
        End;
      End
      Else pPos := iStart;
      pEnd := WidePosEx(',',PList,pPos)-1; // Find End Position of Parameter
      If pEnd <= 0 then pEnd := iEnd;   // In case this is the last Parameter
    End;

    If Count = PItem then
    Begin
      Result := Copy(PList,pPos,(pEnd+1)-pPos);

      If (StripSpace = True) and (Pos(#32,Result) > 0) then
      Begin
        For I := 1 to Length(Result) do
        Begin
          iStart := I;
          If Result[I] <> #32 then Break;
        End;
        For I := Length(Result) downto iStart do
        Begin
          iEnd := I;
          If Result[I] <> #32 then Break;
        End;
        Result := Copy(Result,iStart,(iEnd+1)-iStart);
      End
    End
    Else Result := '';
  End;
end;


function GetSLeftParam(S : String) : String;
var
  sP : Integer;
begin
  sP := Pos('=',S)-1;
  If sP > 0 then
  Begin
    Result := Trim(Copy(S,1,sP));
  End
  Else Result := '';
end;

function GetSRightParam(S : WideString; StripSpace : Boolean) : WideString;
var
  sP   : Integer;
begin
  sP := Pos('=',S)+1;
  If sP > 0 then
  Begin
    Result := Copy(S,sP,Length(S)-(SP-1));
    If StripSpace = True then Result := Trim(Result);
  End
  Else Result := '';
end;


function WidePosEx(SubStr, S : WideString; Offset : Cardinal = 1) : Integer;
var
  I,I1   : Integer;
  subLen : Integer;
  sLen   : Integer;
  Found  : Boolean;
begin
  Result := 0;
  subLen := Length(SubStr);
  sLen   := Length(S);
  If (S = '') or (SubStr = '') or (subLen > sLen) then Exit;
  For I := Offset to sLen-(subLen-1) do
  Begin
    Found := True;
    For I1 := I to I+(subLen-1) do If S[I1] <> SubStr[(I1-I)+1] then Begin Found := False; Break; End;
    If Found = True then
    Begin
      Result := I;
      Break;
    End;
  End;
end;


function EraseFile(FileName : WideString) : Boolean;
begin
  If Win32PlatformIsUnicode = True then
    Result := DeleteFileW(PWideChar(FileName)) else
    Result := DeleteFileA(PChar(String(FileName)));
end;


Function ExtractFileNameNoExt(FileName : WideString) : WideString;
var
  I : Integer;
begin
  If Length(FileName) > 0 then
  Begin
    Result := WideExtractFileName(FileName);
    For I := Length(Result) downto 1 do If Result[I] = '.' then
    Begin
      If I > 1 then Result := Copy(Result,1,I-1);
      Break;
    End;
  End
  Else Result := '';
end;


function WidePosRev(SubStr, S : WideString) : Integer;
var
  I,I1   : Integer;
  subLen : Integer;
  sLen   : Integer;
  Found  : Boolean;
begin
  Result := 0;
  subLen := Length(SubStr);
  sLen   := Length(S);
  If (S = '') or (SubStr = '') or (subLen > sLen) then Exit;
  For I := sLen-(subLen-1) downto 1 do
  Begin
    Found := True;
    For I1 := I to I+(subLen-1) do If S[I1] <> SubStr[(I1-I)+1] then Begin Found := False; Break; End;
    If Found = True then
    Begin
      Result := I;
      Break;
    End;
  End;
end;


function WideExtractFilePathEx(FileName : WideString) : WideString;
var I : Integer;
begin
  If Pos('//',FileName) = 1 then // Support network paths
  Begin
    I      := WidePosRev('/',FileName)+1;
    Result := Copy(FileName,1,I-1);
  End
    else
  Begin
    // Check for URL
    I := Pos('://',FileName);
    If I > 0 then Result := Copy(FileName,1,I+2) else Result := WideExtractFilePath(FileName);
  End;
end;


function StringToFloat(S : String) : Double;
begin
  If S <> '' then
  Begin
    If (Pos(',',S) > 0) and (DecimalSeparator = '.') then S[Pos(',',S)] := '.';
    If (Pos('.',S) > 0) and (DecimalSeparator = ',') then S[Pos('.',S)] := ',';
    Result := StrToFloat(S);
  End
  Else Result := 0;
end;


function StringToFloatDef(S : String; dValue : Double) : Double;
begin
  If S <> '' then
  Begin
    If (Pos(',',S) > 0) and (DecimalSeparator = '.') then S[Pos(',',S)] := '.';
    If (Pos('.',S) > 0) and (DecimalSeparator = ',') then S[Pos('.',S)] := ',';
    Result := StrToFloatDef(S,dValue);
  End
  Else Result := 0;
end;


function FileAgeW(const FileName: widestring): Integer;
var
  Handle        : THandle;
  FindDataW     : TWin32FindDataW;
  FindDataA     : TWin32FindDataA;
  LocalFileTime : TFileTime;
begin
  If Win32PlatformIsUnicode then
    Handle := FindFirstFileW(PWideChar(FileName), FindDataW) else
    Handle := FindFirstFileA(PChar(String(FileName)), FindDataA);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(Handle);
    If Win32PlatformIsUnicode then
    Begin
      If (FindDataW.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
      Begin
        FileTimeToLocalFileTime(FindDataW.ftLastWriteTime, LocalFileTime);
        If FileTimeToDosDateTime(LocalFileTime, LongRec(Result).Hi,LongRec(Result).Lo) then Exit;
      End;
    End
      else
    Begin
      If (FindDataA.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
      begin
        FileTimeToLocalFileTime(FindDataA.ftLastWriteTime, LocalFileTime);
        If FileTimeToDosDateTime(LocalFileTime, LongRec(Result).Hi,LongRec(Result).Lo) then Exit;
      end;
    End;
  end;
  Result := -1;
end;


function GetFileSize(FileName : Widestring) : Int64;
var
  sRec : TSearchRecW;
  nLen : Integer;
  FFileHandle: THandle;
  i64  : Int64;
  fData : WIN32_FILE_ATTRIBUTE_DATA;
begin
  Result := -1;
  nLen := Length(FileName);
  If (nLen > 0) then
  Begin
    If Char(FileName[nLen]) in ['\','/'] then FileName := Copy(FileName,1,nLen-1);
    If Win32PlatformIsUnicode = False then
    Begin
      If GetFileAttributesExA(PChar(String(FileName)),GetFileExInfoStandard,@fData) = True then
        If fData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY = 0 then
      Begin
        Int64Rec(Result).Lo := fData.nFileSizeLow;
        Int64Rec(Result).Hi := fData.nFileSizeHigh;
      End;
    End
      else
    Begin
      If GetFileAttributesExW(PWideChar(FileName),GetFileExInfoStandard,@fData) = True then
        If fData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY = 0 then
      Begin
        Int64Rec(Result).Lo := fData.nFileSizeLow;
        Int64Rec(Result).Hi := fData.nFileSizeHigh;
      End;
    End;
  End;
end;


function WideExtractFileNameEx(FileName : WideString) : WideString;
var I,I1,iLen : Integer;
begin
  If Pos('//',FileName) = 1 then // Support network paths
  Begin
    I      := WidePosRev('/',FileName)+1;
    Result := Copy(FileName,I,Length(FileName)-(I-1));
  End
    else
  Begin
    I := Pos('://',FileName);
    If I > 0 then
    Begin
      I1 := WidePosRev('/',FileName);
      iLen := Length(FileName);
      If (I1 > 0) and (I1 <> iLen) then
      Begin
        // File name in path
        Result := Copy(FileName,I1+1,iLen-(I1));
      End
        else
      Begin
        // Full URL Path
        Result := Copy(FileName,I+3,Length(FileName)-(I+2))
      End;
    End
    Else Result := WideExtractFileName(FileName);
  End;
end;


function GetCurrentDLLPath : WideString;
var
  szFileNameA : Array[0..MAX_PATH] of Char;
  szFileNameW : Array[0..MAX_PATH] of WideChar;
  I           : Integer;

begin
  If Win32PlatformIsUnicode = True then
  Begin
    FillChar(szFileNameW, SizeOf(szFileNameW), #0);
    GetModuleFileNameW(hInstance, szFileNameW, MAX_PATH);
    Result := WideExtractFilePath(szFileNameW);
  End
    else
  Begin
    FillChar(szFileNameA, SizeOf(szFileNameA), #0);
    GetModuleFileNameA(hInstance, szFileNameA, MAX_PATH);
    Result := ExtractFilePath(szFileNameA);
  End;
  I := Length(Result);
  If I > 0 then If Result[I] <> '\' then Result := Result+'\';
end;


function HashWideString(S : WideString) : Integer;
var
  I : Integer;
  P : PByteArray;
  Len : Integer;
begin
  Result := 0;
  //S := TNT_WideLowercase(S);
  Len := Length(S);
  If Win32PlatformIsUnicode = False then
    S := TNT_WideLowercase(S) else
    CharLowerBuffW{TNT-ALLOW CharLowerBuffW}(@S[1], Len);

  P := @S[1];
  For I := 0 to (Len shl 1)-1 do
    Result := ((Result shl 2) or (Result shr ((4{SizeOf(Result)} shl 3)-2))) xor P[I];
end;


Function WinExecAndWait32(FileName : WideString; Visibility : integer; waitforexec,console : boolean):integer;
var
  FileNameA   : String;
  //WorkDir     : WideString;
  StartupInfo : TStartupInfo;
  ProcessInfo : TProcessInformation;
  RunResult   : LongBool;
  ECResult    : LongWord;
  Flags       : DWord;
  S,S1        : WideString;
begin
  //GetDirWide(WorkDir);
  If WideCompareText(WideExtractFileExt(FileName),'.lnk') = 0 then
  Begin
    GetShortCutFileName(FileName,S,S1);
    If S <> '' then FileName := S;
  End;


  FillChar(StartupInfo,Sizeof(StartupInfo),0);
  StartupInfo.cb          := Sizeof(StartupInfo);
  StartupInfo.dwFlags     := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := Visibility;
  If Console then Flags := CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS else Flags := NORMAL_PRIORITY_CLASS;

  If Win32PlatformIsUnicode = True then
  Begin
    FileName := FileName+#0;
    RunResult :=
      CreateProcessW(nil,
      @FileName[1],                  { pointer to command line string }
      nil,                           { pointer to process security attributes }
      nil,                           { pointer to thread security attributes }
      false,                         { handle inheritance flag }
      Flags,                         { creation flags }
      nil,                           { pointer to new environment block }
      nil,                           { pointer to current directory name }
      StartupInfo,                   { pointer to STARTUPINFO }
      ProcessInfo);                  { pointer to PROCESS_INF }
  End
    else
  Begin
    FileNameA := FileName+#0;
    RunResult :=
      CreateProcessA(nil,
      @FileNameA[1],                 { pointer to command line string }
      nil,                           { pointer to process security attributes }
      nil,                           { pointer to thread security attributes }
      false,                         { handle inheritance flag }
      flags,                         { creation flags }
      nil,                           { pointer to new environment block }
      nil,                           { pointer to current directory name }
      StartupInfo,                   { pointer to STARTUPINFO }
      ProcessInfo);                  { pointer to PROCESS_INF }
  End;
  If RunResult = False then Result := -1 else
  Begin
    If WaitForExec = True then
    Begin
      WaitforSingleObject(ProcessInfo.hProcess,INFINITE);
      GetExitCodeProcess(ProcessInfo.hProcess,ECResult);
      Result := ECResult;
    End
    Else Result := 0;
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
  end;
end;



procedure GetShortCutFileName(FileName : WideString; var NewFileName,NewParameters : Widestring);
var
  //LinkObj   : IUnknown;
  LinkIntA  : IShellLinkA;
  LinkIntW  : Fixed_IShellLinkW;
  LinkFile  : IPersistFile;
  //FileBufA  : Array[0..MAX_PATH] of Char;
  //FileBufW  : Array[0..MAX_PATH] of PWideChar;
  FindDataA : TWin32FindDataA;
  FindDataW : TWin32FindDataW;
  sW        : WideString;
  sA        : String;
begin
  If WideFileExists(FileName) = True then
  Begin
    NewFileName   := FileName;
    NewParameters := '';
    If Win32PlatformIsUnicode = False then
    Begin
      If CoCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER,IShellLinkA, LinkIntA) = S_OK then
      Begin
        LinkFile  := LinkIntA as IPersistFile;
        If LinkFile.Load(PWideChar(FileName),STGM_READ) = S_OK then
        Begin
          SetLength(sA,MAX_PATH);
          If LinkIntA.GetPath(@sA[1],MAX_PATH,FindDataA,SLGP_UNCPRIORITY) = NOERROR then
          Begin
            SetLength(sA,Pos(#0,sA)-1);
            NewFileName := sA;
          End;
          SetLength(sA,MAX_PATH);
          If LinkIntA.GetArguments(@sA[1],MAX_PATH) = NOERROR then
          Begin
            SetLength(sA,Pos(#0,sA)-1);
            NewParameters := sA;
          End;
        End;
        LinkIntA := nil;
        LinkFile := nil;
      End;
    End
      else
    Begin
      If CoCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER,IID_IShellLinkW, LinkIntW) = S_OK then
      Begin
        LinkFile  := LinkIntW as IPersistFile;
        If LinkFile.Load(PWideChar(FileName),STGM_READ) = S_OK then
        Begin
          SetLength(sW,MAX_PATH);
          If LinkIntW.GetPath(@sW[1],MAX_PATH,FindDataW,SLGP_UNCPRIORITY) = NOERROR then
          Begin
            SetLength(sW,Pos(#0,sW)-1);
            NewFileName := sW;
          End;
          SetLength(sW,MAX_PATH);
          If LinkIntW.GetArguments(@sW[1],MAX_PATH) = NOERROR then
          Begin
            SetLength(sW,Pos(#0,sW)-1);
            NewParameters := sW;
          End;
        End;
        LinkIntW := nil;
        LinkFile := nil;
      End;
    End;
  End;
end;


function EnDeCrypt(const Value : String) : String;
var
  CharIndex : integer;
begin
  Result := Value;
  for CharIndex := 1 to Length(Value) do
    Result[CharIndex] := chr(not(ord(Value[CharIndex])));
end;


initialization
  QueryPerformanceFrequency(qTimer64Freq);
  QueryPerformanceCounter(DebugStartTime);
  csDebug := TCriticalSection.Create;

finalization
  csDebug.Free;

end.