{$I PLUGIN_DEFINES.INC}

unit youtube_api;

interface

uses tntclasses;

const
  {$I APIKEY.INC}

function  YouTube_ConvertUserNameToChannelID(sUserName : String) : String;
procedure YouTube_GetChannelNameAndThumbnail(sChannelID : String; var sTitle,sThumbnail : String);
procedure YouTube_GetCategoryIDs(regionCode : String; uList : TTNTStringList);



implementation


uses classes, WinInet, superobject, misc_utils_unit, sysutils, TNTSysUtils;


function YouTube_ConvertUserNameToChannelID(sUserName : String) : String;
var
  sList    : TStringList;
  jBase    : ISuperObject;
  jItems   : ISuperObject;
  jEntry   : ISuperObject;
  dlStatus : String;
  dlError  : Integer;
  sJSON    : String;
begin
  Result   := '';
  sList    := TStringList.Create;
  dlStatus := '';
  dlError  := 0;
  If DownloadFileToStringList('https://www.googleapis.com/youtube/v3/channels?key='+APIKEY+'&forUsername='+sUserName+'&part=id',sList,dlStatus,dlError,2000) = True then
  Begin
    If sList.Count > 0 then
    Begin
      sJSON := StringReplace(sList.Text,CRLF,'',[rfReplaceAll]);
      {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'JSON User Name : '+CRLF+'---'+CRLF+sList.Text+CRLF+'---'+CRLF);{$ENDIF}
      jBase := SO(sJSON);
      If jBase <> nil then
      Begin
        jItems := jBase.O['items'];
        If jItems <> nil then
        Begin
          If jItems.AsArray.Length > 0 then
          Begin
            jEntry := jItems.AsArray.O[0];
            If jEntry <> nil then
            Begin
              Result := jEntry.S['id'];
              jEntry.Clear(True);
              jEntry := nil;
            End
            {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'JSON entry object returned nil'){$ENDIF};
          End;
          jItems.Clear(True);
          jItems := nil;
          //ShowMessageW(jItems.AsString);
        End
        {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'JSON items object returned nil'){$ENDIF};
        jBase.Clear(True);
        jBase := nil;
      End
      {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'JSON base object returned nil'){$ENDIF};
    End
    {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'Download returned no data on User Name to Channel ID translation'){$ENDIF};
  End
  {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'Download error on User Name to Channel ID translation'){$ENDIF};
  sList.Free;
end;


procedure YouTube_GetChannelNameAndThumbnail(sChannelID : String; var sTitle,sThumbnail : String);
var
  sList    : TStringList;
  jBase    : ISuperObject;
  jItems   : ISuperObject;
  jEntry   : ISuperObject;
  jSnippet : ISuperObject;
  dlStatus : String;
  dlError  : Integer;
  sJSON    : String;
begin
  sTitle     := '';
  sThumbnail := '';

  sList := TStringList.Create;
  If DownloadFileToStringList('https://www.googleapis.com/youtube/v3/channels?key='+APIKEY+'&part=snippet&id='+sChannelID,sList,dlStatus,dlError,2000) = True then
  Begin
    If sList.Count > 0 then
    Begin
      sJSON := StringReplace(sList.Text,CRLF,'',[rfReplaceAll]);
      {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'JSON Channel Snippet : '+CRLF+'---'+CRLF+sList.Text+CRLF+'---'+CRLF);{$ENDIF}
      jBase := SO(sJSON);
      If jBase <> nil then
      Begin
        jItems := jBase.O['items'];
        If jItems <> nil then
        Begin
          If jItems.AsArray.Length > 0 then
          Begin
            jEntry := jItems.AsArray.O[0];
            If jEntry <> nil then
            Begin
              jSnippet := jEntry.O['snippet'];
              If jSnippet <> nil then
              Begin
                sTitle := EncodeTextTags(jSnippet.S['title'],True);
                {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Channel Title: '+UTF8Decode(sTitle));{$ENDIF}

                sThumbnail := GetBestThumbnailURL(jSnippet);
                {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Channel Thumbnail: '+UTF8Decode(sThumbnail));{$ENDIF}
                jSnippet.Clear(True);
                jSnippet := nil;
              End
              {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'JSON snippet object returned nil'){$ENDIF};
              jEntry.Clear(True);
              jEntry := nil;
            End
            {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'JSON entry object returned nil'){$ENDIF};
          End;
          jItems.Clear(True);
          jItems := nil;
        End
        {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'JSON items object returned nil'){$ENDIF};
        jBase.Clear(True);
        jBase := nil;
      End
      {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'JSON base object returned nil'){$ENDIF};
    End
    {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'Download returned no data on User Name to Channel ID translation'){$ENDIF};
  End
  {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'Download error on Channel ID to Channel Name translation'){$ENDIF};

  sList.Free;
end;


procedure YouTube_GetCategoryIDs(regionCode : String; uList : TTNTStringList);
var
  sList    : TStringList;
  jBase    : ISuperObject;
  jItems   : ISuperObject;
  jEntry   : ISuperObject;
  jSnippet : ISuperObject;
  dlStatus : String;
  dlError  : Integer;
  sJSON    : String;
  sTitle   : String;
  cID      : Integer;
  I        : Integer;
begin
  // https://www.googleapis.com/youtube/v3/videoCategories?part=snippet&regionCode=IL&key=[key]

  sList := TStringList.Create;
  If DownloadFileToStringList('https://www.googleapis.com/youtube/v3/videoCategories?part=snippet&regionCode='+regionCode+'&key='+APIKey,sList,dlStatus,dlError,2000) = True then
  Begin
    If sList.Count > 0 then
    Begin
      sJSON := StringReplace(sList.Text,CRLF,'',[rfReplaceAll]);
      {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'JSON Category List Snippet : '+CRLF+'---'+CRLF+sList.Text+CRLF+'---'+CRLF);{$ENDIF}
      jBase := SO(sJSON);
      If jBase <> nil then
      Begin
        jItems := jBase.O['items'];
        If jItems <> nil then
        Begin
          If jItems.AsArray.Length > 0 then For I := 0 to jItems.AsArray.Length-1 do
          Begin
            jEntry := jItems.AsArray.O[I];
            If jEntry <> nil then
            Begin
              cID      := StrToIntDef(jEntry.S['id'],-1);
              jSnippet := jEntry.O['snippet'];
              If jSnippet <> nil then
              Begin
                sTitle := jSnippet.S['title'];

                If (sTitle <> '') and (cID > -1) then uList.AddObject(UTF8StringToWideString(sTitle),TObject(cID));

                jSnippet.Clear(True);
                jSnippet := nil;
              End
              {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'JSON snippet object returned nil'){$ENDIF};
              jEntry.Clear(True);
              jEntry := nil;
            End
            {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'JSON entry object returned nil'){$ENDIF};
          End;
          jItems.Clear(True);
          jItems := nil;
        End
        {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'JSON items object returned nil'){$ENDIF};
        jBase.Clear(True);
        jBase := nil;
      End
      {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'JSON base object returned nil'){$ENDIF};
    End
    {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'Download returned no data on GetCategoyIDs'){$ENDIF};
  End
  {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'Download error on GetCategoyIDs'){$ENDIF};

  sList.Free;


end;


end.
