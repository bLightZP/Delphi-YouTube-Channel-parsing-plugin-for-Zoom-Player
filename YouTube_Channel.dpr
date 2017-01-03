{$I PLUGIN_DEFINES.INC}

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


      { This sample code uses the SuperObject library for the JSON parsing:
        https://github.com/hgourvest/superobject

        And the TNT Delphi Unicode Controls (compatiable with the last free version)
        to handle a few unicode tasks.

        And optionally, the FastMM/FastCode/FastMove libraries:
        http://sourceforge.net/projects/fastmm/
        }


library YouTube_Channel;

uses
  FastMM4,
  FastMove,
  FastCode,
  Windows,
  SysUtils,
  Classes,
  Forms,
  Controls,
  DateUtils,
  SyncObjs,
  Dialogs,
  StrUtils,
  TNTClasses,
  TNTSysUtils,
  SuperObject,
  WinInet,
  misc_utils_unit;


{$R *.res}


Type
  TCategoryPluginRecord =
  Record
    CategoryInput : PChar;
    CategoryID    : PChar;
    CategoryTitle : PChar;
    CategoryThumb : PChar;
    Scrapers      : PChar;
    TextLines     : Integer;
    DefaultFlags  : Integer;
    SortMode      : Integer;
  End;
  PCategoryPluginRecord = ^TCategoryPluginRecord;

  TCategoryItemList =
  Record
    catItems      : PChar;
    // Format:
    // Each entry contains multiple parameters (listed below).
    // Entries are separated by the "|" character.
    // Any use of the quote character must be encoded as "&quot".
    // "Type=[EntryType]","Path=[Path]","Title=[Title]","Description=[Description]","Thumbnail=[Thumbnail]","Date=[Date]","Duration=[Duration]"|"Type=[entryType]","Path=[Path]","Title=[Title]","Description=[Description]","Thumbnail=[Thumbnail]","Date=[Date]","Duration=[Duration]"|etc...
    //
    // Values:
    // [EntryType]   : 0 = Playable media
    //                 1 = Enter folder
    //                 2 = Append new entries, replace last previous entry (used to trigger the append action).
    //                 3 = Refresh all entries
    // [Path]        : A UTF8 encoded string containing a file path or URL
    // [Title]       : A UTF8 encoded string containing the media's title
    // [Description] : A UTF8 encoded string containing the media's description
    // [Thumbnail]   : A UTF8 encoded string containing the media's thumbnail path or URL
    // [Date]        : A string containing a float number in delphi time encoding representing the publish date and time.
    // [Duration]    : An floating point value representing the media's duration in seconds.
    // [MetaEntry1]  : Displayed in the meta-data's Title area
    // [MetaEntry2]  : Displayed in the meta-data's Date area
    // [MetaEntry3]  : Displayed in the meta-data's Genre/Type area
    // [MetaEntry4]  : Displayed in the meta-data's Overview/Description area
    // [MetaEntry5]  : Displayed in the meta-data's Actors/Media info area
  End;
  PCategoryItemList = ^TCategoryItemList;


Const
  // Settings Registry Path and Key
  PluginRegKey               : String = 'Software\VirtuaMedia\ZoomPlayer\MediaLibraryPlugins\YouTube Channel';
  {$I APIKEY.INC}

  // Category flags
  catFlagThumbView           : Integer =    1;     // Enable thumb view (disabled = list view)
  catFlagThumbCrop           : Integer =    2;     // Crop media thumbnails to fit in display area (otherwise pad thumbnails)
  catFlagVideoFramesAsThumb  : Integer =    4;     // Grab thumbnails from video frame
  catFlagDarkenThumbBG       : Integer =    8;     // [Darken thumbnail area background], depreciated by "OPNavThumbDarkBG".
  catFlagJukeBox             : Integer =   16;     // Jukebox mode enabled
  catFlagBGFolderIcon        : Integer =   32;     // Draw folder icon if the folder has a thumbnail
  catFlagScrapeParentFolder  : Integer =   64;     // Scrape the parent folder if no meta-data was found for the media file
  catFlagScrapeMediaInFolder : Integer =  128;     // Create folder thumbnails from first media file within the folder (if scraping is disabled or fails)
  catFlagTitleFromMetaData   : Integer =  256;     // Use meta-data title for the thumb's text instead of the file name
  catFlagNoScraping          : Integer =  512;     // Disable all scraping operations for this folder
  catFlagRescrapeModified    : Integer = 1024;     // Rescrape folders if their "modified" date changes
  catFlagTVJukeBoxNoScrape   : Integer = 2048;     // Switched to TV JukeBox list view without having the parent folder scraped first
  catFlag1stMediaFolderThumb : Integer = 4096;     // Instead of scraping for a folder's name, always use the first media file within the folder instead
  catFlagCropCatThumbnail    : Integer = 8192;     // Crop category thumbnails to fit in display area (otherwise pad thumbnails)

  srName                                  = 0;
  srExt                                   = 1;
  srDate                                  = 2;
  srSize                                  = 3;
  srPath                                  = 4;
  srDuration                              = 5;
  srRandom                                = 6;


// Called by Zoom Player to free any resources allocated in the DLL prior to unloading the DLL.
Procedure FreePlugin; stdcall;
begin
  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Free Plugin (before)');{$ENDIF}
  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Free Plugin (after)');{$ENDIF}
end;


// Called by Zoom Player to init any resources.
function InitPlugin : Bool; stdcall;
begin
  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Init Plugin (before)');{$ENDIF}
  Result := True;
  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Init Plugin (after)');{$ENDIF}
end;


// Called by Zoom Player to verify if a configuration dialog is available.
// Return True if a dialog exits and False if no configuration dialog exists.
function CanConfigure : Bool; stdcall;
begin
  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'CanConfigure (before)');{$ENDIF}
  Result := False;
  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'CanConfigure (after)');{$ENDIF}
end;


// Called by Zoom Player to show the plugin's configuration dialog.
Procedure Configure(CenterOnWindow : HWND; CategoryID : PChar); stdcall;
var
  CenterOnRect : TRect;
  tmpInt: Integer;
begin
  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Configure (before)');{$ENDIF}
  {If GetWindowRect(CenterOnWindow,CenterOnRect) = False then
    GetWindowRect(0,CenterOnRect); // Can't find window, center on screen

  ConfigForm := TConfigForm.Create(nil);
  ConfigForm.SetBounds(CenterOnRect.Left+(((CenterOnRect.Right -CenterOnRect.Left)-ConfigForm.Width)  div 2),
                       CenterOnRect.Top +(((CenterOnRect.Bottom-CenterOnRect.Top )-ConfigForm.Height) div 2),ConfigForm.Width,ConfigForm.Height);

  If ConfigForm.ShowModal = mrOK then
  Begin
  End;
  ConfigForm.Free;}
  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Configure (after)');{$ENDIF}
end;


Function CreateCategory(CenterOnWindow : HWND; CategoryData : PCategoryPluginRecord) : Integer; stdcall;
var
  sCatInput   : String;
  sCatInputLC : String;
  sChannelID  : String;
  sTitle      : String;
  sThumbnail  : String;
  sUserName   : WideString;
  sPos        : Integer;
  ePos        : Integer;
  I,I1        : Integer;
  sList       : TStringList;
  dlStatus    : String;
  dlError     : Integer;
  jBase       : ISuperObject;
  jItems      : ISuperObject;
  jEntry      : ISuperObject;
  jSnippet    : ISuperObject;
  sJSON       : String;
  jThumbRez   : ISuperObject;
  jThumb      : ISuperObject;
begin
  // CategoryInput = URL
  // CategoryID    = Parsed category ID returned to the player for later calls to GetList.
  // CategoryThumb = Thumbnail to use for the category
  // TextLines     = Number of text lines to display
  // SortMode      = Sort mode to enable when creating the category (srName .. srRandom)
  // Scrapers      = Return recommended scraper list
  // DefaultFlags  = Default category flags for this category

  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'CreateCategory (before)');{$ENDIF}
  Result       := E_FAIL;
  If CategoryData = nil then
  Begin
    {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Exit on "CategoryData = nil"');{$ENDIF}
    Exit;
  End;

  sCatInput    := CategoryData^.CategoryInput;
  sCatInputLC  := Lowercase(sCatInput);
  sChannelID   := '';
  sThumbnail   := '';
  CategoryData^.CategoryID    := '';
  CategoryData^.CategoryTitle := '';
  CategoryData^.CategoryThumb := '';
  CategoryData^.Scrapers      := '';
  CategoryData^.TextLines     := 2;
  CategoryData^.SortMode      := srDate;
  CategoryData^.DefaultFlags  := catFlagThumbView or catFlagThumbCrop or catFlagTitleFromMetaData;

  If sCatInput <> '' then
  Begin
    // Try to find the Channel ID by input URL
    sPos := Pos('/channel/',sCatInputLC);
    If sPos > 0 then
    Begin
      ePos := PosEx('/',sCatInput,sPos+10);
      If ePos > 0 then
        sChannelID := Copy(sCatInput,sPos+9,ePos-(sPos+9)) else
        sChannelID := Copy(sCatInput,sPos+9,Length(sCatInput)-(sPos+8));
    End
      else
    Begin
      // Try to find the Channel ID by user name in input URL
      {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Convert User Name to Channel ID');{$ENDIF}
      sPos := Pos('/user/',sCatInputLC);
      If sPos > 0 then
      Begin
        ePos := PosEx('/',sCatInput,sPos+7);
        If ePos > 0 then
          sUserName := Copy(sCatInput,sPos+6,ePos-(sPos+6)) else
          sUserName := Copy(sCatInput,sPos+6,Length(sCatInput)-(sPos+5));

        {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'User Name: '+sUserName);{$ENDIF}

        If sUserName <> '' then
        Begin
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
                      sChannelID := jEntry.S['id'];
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
        End;
      End;
    End;

    If sChannelID <> '' then
    Begin
      {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Channel ID: '+sChannelID);{$ENDIF}
      CategoryData^.CategoryID := PChar(sChannelID);

      // Get Channel name
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
                    CategoryData^.CategoryTitle := PChar(sTitle);
                    {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Channel Title: '+UTF8Decode(sTitle));{$ENDIF}

                    sThumbnail := GetBestThumbnailURL(jSnippet);
                    If sThumbnail <> '' then CategoryData^.CategoryThumb := PChar(sThumbnail);
                    {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Channel Thumbnail: '+UTF8Decode(sThumbnail));{$ENDIF}
                    If sTitle <> '' then Result := S_OK;
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
    End
    {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'No Channel ID detected'){$ENDIF};
  End;

  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'CreateCategory, Result : '+IntToHex(Result,8)+' (after)');{$ENDIF}
end;


Function GetList(CategoryID : PChar; CategoryPath : PChar; ItemList : PCategoryItemList) : Integer; stdcall;
type
  TYouTubeVideoRecord =
  Record
    ytvType         : Integer;
    ytvPath         : WideString;
    ytvTitle        : WideString;
    ytvDescription  : WideString;
    ytvPublished    : TDateTime;
    ytvThumbnail    : String;
    ytvDuration     : Integer;
    ytvViewCount    : Integer;
    ytvLikeCount    : Integer;
    ytvDislikeCount : Integer;
  End;
  PYouTubeVideoRecord = ^TYouTubeVideoRecord;

const
  YouTube_VideoFetch : Integer = 25;

var
  S           : String;
  sID         : String;
  I,I1        : Integer;
  sList       : TStringList;
  jBase       : ISuperObject;
  jItems      : ISuperObject;
  jEntry      : ISuperObject;
  jSnippet    : ISuperObject;
  dlStatus    : String;
  dlError     : Integer;
  sJSON       : String;
  sURL        : String;
  sToken      : String;
  sItemList   : String;
  ytvList     : TList;
  ytvEntry    : PYouTubeVideoRecord;

  procedure WipeYTVentry(Entry : PYouTubeVideoRecord);
  begin
    ytvEntry^.ytvType         := 0;
    ytvEntry^.ytvPath         := '';
    ytvEntry^.ytvTitle        := '';
    ytvEntry^.ytvDescription  := '';
    ytvEntry^.ytvPublished    := 0;;
    ytvEntry^.ytvThumbnail    := '';
    ytvEntry^.ytvDuration     := 0;
    ytvEntry^.ytvViewCount    := 0;
    ytvEntry^.ytvLikeCount    := 0;
    ytvEntry^.ytvDislikeCount := 0;
  end;

  function YTVrecordToString(Entry : PYouTubeVideoRecord) : WideString;
  var
    sPath       : String;
    sDuration   : String;
    sDate       : WideString;
    sMetaLikes  : String;
    iMetaRating : Integer;
  Begin
    Case Entry^.ytvType of
      0    : sPath := 'https://www.youtube.com/watch?v='+Entry^.ytvPath;
      else   sPath := Entry^.ytvPath;
    End;
    If Entry^.ytvPublished > 0 then sDate := TimeDifferenceToStr(Now,Entry^.ytvPublished) else sDate := '';

    sMetaLikes := 'Likes :\n'+IntToStr(Entry^.ytvLikeCount)+'\n\nDislikes :\n'+IntToStr(Entry^.ytvDislikeCount);

    sDuration := EncodeDuration(Entry^.ytvDuration);

    // Generate a rating value based on ratio between likes and dislikes
    iMetaRating := 0;
    If Entry^.ytvLikeCount+Entry^.ytvDislikeCount > 0 then
      iMetaRating := Round((100*Entry^.ytvLikeCount)/(Entry^.ytvLikeCount+Entry^.ytvDislikeCount));

    // [MetaEntry1]  :  // Displayed in the meta-data's Title area
    // [MetaEntry2]  :  // Displayed in the meta-data's Date area
    // [MetaEntry3]  :  // Displayed in the meta-data's Duration
    // [MetaEntry4]  :  // Displayed in the meta-data's Genre/Type area
    // [MetaEntry5]  :  // Displayed in the meta-data's Overview/Description area
    // [MetaEntry6]  :  // Displayed in the meta-data's Actors/Media info area
    // [MetaRating]  :  // Meta rating, value of 0-100, 0=disabled

    Result := '"Type='        +IntToStr(Entry^.ytvType)+'",'+
              '"Path='        +sPath+'",'+
              '"Title='       +EncodeTextTags(Entry^.ytvTitle,True)+'",'+
              '"Description=' +EncodeTextTags(Entry^.ytvDescription,True)+'",'+
              '"Thumbnail='   +Entry^.ytvThumbnail+'",'+
              '"Duration='    +FloatToStr(Entry^.ytvDuration)+'",'+
              '"Date='        +FloatToStr(Entry^.ytvPublished)+'",'+
              '"MetaEntry1='  +EncodeTextTags(Entry^.ytvTitle,True)+'",'+
              '"MetaEntry2='  +sDate+'",'+
              '"MetaEntry3='  +sDuration+'",'+
              '"MetaEntry4='  +IntToStr(Entry^.ytvViewCount)+' views",'+
              '"MetaEntry5='  +EncodeTextTags(Entry^.ytvDescription,True)+'",'+
              '"MetaEntry6='  +sMetaLikes+'",'+
              '"MetaRating='  +IntToStr(iMetaRating)+'"';
  End;


begin
  // CategoryID   = A unique category identifier, in our case, a YouTube channel's "Channel ID".
  // CategoryPath = Used to the pass a path or parameter, in our case, a YouTube channel's next page Token.
  // ItemList     = Return a list of items and meta-data

  // ItemType :
  // 0 = Playable item
  // 1 = Enter Folder, retrieve new list with additional 'categorypath'.
  // 2 = Append items to list, removing this entry

  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'GetList (before)');{$ENDIF}
  Result             := E_FAIL;
  ItemList^.catItems := '';

  //https://www.googleapis.com/youtube/v3/search?key=AIzaSyBieQxSpir6Y2-iYPokdu90UxqM_skzZFo&channelId=UClFSU9_bUb4Rc6OYfTt5SPw&part=snippet,id&order=date&maxResults=3

  sList   := TStringList.Create;
  ytvList := TList.Create;
  sURL    := 'https://www.googleapis.com/youtube/v3/search?key='+APIKey+'&channelId='+CategoryID+'&part=snippet,id&order=date&type=video&maxResults='+IntToStr(YouTube_VideoFetch);
  sToken  := CategoryPath;
  If sToken <> '' then sURL := sURL+'&pageToken='+sToken;
  sToken  := '';

  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Search URL : '+sURL);{$ENDIF}
  If DownloadFileToStringList(sURL,sList,dlStatus,dlError,2000) = True then
  Begin
    sJSON := StringReplace(sList.Text,CRLF,'',[rfReplaceAll]);
    {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'JSON Search Snippet+ID : '+CRLF+'---'+CRLF+sList.Text+CRLF+'---'+CRLF);{$ENDIF}

    jBase := SO(sJSON);
    If jBase <> nil then
    Begin
      sToken := jBase.S['nextPageToken'];
      {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Next page token : '+sToken);{$ENDIF}
      jItems := jBase.O['items'];
      If jItems <> nil then
      Begin
        If jItems.AsArray.Length > 0 then For I := 0 to jItems.AsArray.Length-1 do
        Begin
          New(ytvEntry);
          WipeYTVentry(ytvEntry);

          jEntry := jItems.AsArray.O[I];
          If jEntry <> nil then
          Begin
            jSnippet := jEntry.O['id'];
            If jSnippet <> nil then
            Begin
              ytvEntry^.ytvPath := jSnippet.S['videoId'];

              {If ytvEntry^.ytvPath = 'Y6tzhAg0fQQ' then //     "title": "100 OnePlus 3T Giveaway! +¦++GÇÖ-»",
              Begin
                I1 := 0;
              End;}

              jSnippet.Clear(True);
              jSnippet := nil;
            End
            {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'JSON id object returned nil'){$ENDIF};

            jSnippet := jEntry.O['snippet'];
            If jSnippet <> nil then
            Begin
              ytvEntry^.ytvTitle       := UTF8StringToWideString(jSnippet.S['title']);
              ytvEntry^.ytvDescription := UTF8StringToWideString(jSnippet.S['description']);
              S := jSnippet.S['publishedAt'];
              Try
                // format: 2016-12-04T20:00:02.000Z
                ytvEntry^.ytvPublished := EncodeDateTime(
                    StrToInt(Copy(S, 1,4)),  // Year
                    StrToInt(Copy(S, 6,2)),  // Month
                    StrToInt(Copy(S, 9,2)),  // Day
                    StrToInt(Copy(S,12,2)),  // Hour
                    StrToInt(Copy(S,15,2)),  // Minute
                    StrToInt(Copy(S,18,2)),  // Second
                    StrToInt(Copy(S,21,3))); // MS
              Except
                {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Published Exception on : '+S);{$ENDIF}
                ytvEntry^.ytvPublished := 0;;
              End;

              ytvEntry^.ytvThumbnail := GetBestThumbnailURL(jSnippet);

              jSnippet.Clear(True);
              jSnippet := nil;
            End
            {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'JSON snippet object returned nil'){$ENDIF};

            // Add entry to list
            If (ytvEntry^.ytvPath <> '') and (ytvEntry^.ytvTitle <> '') then
            Begin
              ytvList.Add(ytvEntry);
            End
            Else Dispose(ytvEntry);

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

    // https://www.youtube.com/watch?v=N0BIAUYFcxU
    //    {
    //     "kind": "youtube#searchListResponse",
    //     "etag": "\"5C5HHOaBSHC5ZXfkrT4ZlRCi01A/EFjNL6IxYVD4f8fuRl77ZFkfKs8\"",
    //     "nextPageToken": "CAEQAA",
    //     "regionCode": "IL",
    //     "pageInfo": {
    //      "totalResults": 2008,
    //      "resultsPerPage": 1
    //     },
    //     "items": [
    //      {
    //       "kind": "youtube#searchResult",
    //       "etag": "\"5C5HHOaBSHC5ZXfkrT4ZlRCi01A/R8anyl6gDNxlk44-_lOTm7fXF1E\"",
    //       "id": {
    //        "kind": "youtube#video",
    //        "videoId": "N0BIAUYFcxU"
    //       },
    //       "snippet": {
    //        "publishedAt": "2016-12-04T20:00:02.000Z",
    //        "channelId": "UClFSU9_bUb4Rc6OYfTt5SPw",
    //        "title": "NO! Stop Complaining and Suck It Up!",
    //        "description": "SUCK. IT. UP. Seriously, does no one remember Bambi?! HAVE A GREAT F'KN DAY STUFFS!: http://DeFrancoPocketTee.com TheDeFrancoFam Vlog: ...",
    //        "thumbnails": {
    //         "default": {
    //          "url": "https://i.ytimg.com/vi/N0BIAUYFcxU/default.jpg",
    //          "width": 120,
    //          "height": 90
    //         },
    //         "medium": {
    //          "url": "https://i.ytimg.com/vi/N0BIAUYFcxU/mqdefault.jpg",
    //          "width": 320,
    //          "height": 180
    //         },
    //         "high": {
    //          "url": "https://i.ytimg.com/vi/N0BIAUYFcxU/hqdefault.jpg",
    //          "width": 480,
    //          "height": 360
    //         }
    //        },
    //        "channelTitle": "Philip DeFranco",
    //        "liveBroadcastContent": "none"
    //       }
    //      }
    //     ]
    //    }

  End
  {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'ERROR, download failed:'+CRLF+sList.Text){$ENDIF};

  // To get the video duration, we must make a second call:
  // https://www.googleapis.com/youtube/v3/videos?part=contentDetails&id=[videoID],[videoID],[videoID]&key={Your API KEY}


  If (ytvList.Count > 0) then
  Begin
    // Get a list of video IDs
    sList.Clear;
    sItemList := '';
    For I := 0 to ytvList.Count-1 do
    Begin
      If I = 0 then
        sItemList := PYouTubeVideoRecord(ytvList[I])^.ytvPath else
        sItemList := sItemList+','+PYouTubeVideoRecord(ytvList[I])^.ytvPath;
    End;

    sURL := 'https://www.googleapis.com/youtube/v3/videos?part=contentDetails,statistics&id='+sItemList+'&key='+APIKey;
    {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Video ID Search URL : '+sURL);{$ENDIF}
    If DownloadFileToStringList(sURL,sList,dlStatus,dlError,2000) = True then
    Begin
      {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'JSON : '+CRLF+'---'+CRLF+sList.Text+CRLF+'---'+CRLF);{$ENDIF}
      sJSON := StringReplace(sList.Text,CRLF,'',[rfReplaceAll]);

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
              sID := jEntry.S['id'];
              For I1 := 0 to ytvList.Count-1 do If sID = PYouTubeVideoRecord(ytvList[I1])^.ytvPath then
              Begin
                jSnippet := jEntry.O['contentDetails'];
                If jSnippet <> nil then
                Begin
                  S := jSnippet.S['duration'];
                  PYouTubeVideoRecord(ytvList[I1])^.ytvDuration := YouTubeISO8601toSeconds(S);
                  jSnippet.Clear(True);
                  jSnippet := nil;
                End
                {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'JSON contentDetails object returned nil'){$ENDIF};

                jSnippet := jEntry.O['statistics'];
                If jSnippet <> nil then
                Begin
                  PYouTubeVideoRecord(ytvList[I1])^.ytvViewCount    := jSnippet.I['viewCount'];
                  PYouTubeVideoRecord(ytvList[I1])^.ytvLikeCount    := jSnippet.I['likeCount'];
                  PYouTubeVideoRecord(ytvList[I1])^.ytvDislikeCount := jSnippet.I['dislikeCount'];
                  jSnippet.Clear(True);
                  jSnippet := nil;
                End
                {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'JSON statistics object returned nil'){$ENDIF};
                Break;
              End;
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
      {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'JSON items object returned nil'){$ENDIF};
    End;


    // Add a 'refresh' entry
    New(ytvEntry);
    WipeYTVentry(ytvEntry);
    ytvEntry^.ytvPath := 'refresh';
    ytvEntry^.ytvType := 3;
    ytvList.Insert(0,ytvEntry);

    // Add a 'next page' entry
    If (sToken <> '') then
    Begin
      New(ytvEntry);
      WipeYTVentry(ytvEntry);
      ytvEntry^.ytvPath := sToken;
      ytvEntry^.ytvType := 2;
      ytvList.Add(ytvEntry);
    End;

    For I := 0 to ytvList.Count-1 do
    Begin
      If I = 0 then
        sItemList := YTVrecordToString(PYouTubeVideoRecord(ytvList[I])) else
        sItemList := sItemList+'|'+YTVrecordToString(PYouTubeVideoRecord(ytvList[I]));
      {$IFDEF LOCALTRACE}
      With PYouTubeVideoRecord(ytvList[I])^ do
      Begin
        DebugMsgFT  (LogInit,'Type         : '+IntToStr(ytvType));
        If ytvType = 0 then
        Begin
          DebugMsgFT(LogInit,'Path         : https://www.youtube.com/watch?v='+ytvPath);
          DebugMsgFT(LogInit,'Title        : '+ytvTitle);
          DebugMsgFT(LogInit,'Description  : '+ytvDescription);
          DebugMsgFT(LogInit,'Thumbnail    : '+ytvThumbnail);
          DebugMsgFT(LogInit,'ViewCount    : '+IntToStr(ytvViewCount));
          DebugMsgFT(LogInit,'LikeCount    : '+IntToStr(ytvLikeCount));
          DebugMsgFT(LogInit,'DislikeCount : '+IntToStr(ytvDislikeCount));
          DebugMsgFT(LogInit,'Duration     : '+IntToStr(ytvDuration)+' seconds');
          If ytvPublished > 0 then
            DebugMsgFT(LogInit,'Published    : '+DateTimeToStr(ytvPublished)+CRLF) else
            DebugMsgFT(LogInit,'Published    : Unknown!'+CRLF);
        End
          else
        Begin
          DebugMsgFT(LogInit,'Path         : '+ytvPath+CRLF);
        End;
      End;
      {$ENDIF}
    End;

    ItemList^.catItems := PChar(UTF8Encode(sItemList));
    Result := S_OK;
  End;

  For I := 0 to ytvList.Count-1 do Dispose(PYouTubeVideoRecord(ytvList[I]));
  ytvList.Free;
  sList.Free;

  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'GetList (after)');{$ENDIF}
end;


// The string to display for the users when asking for input, in our case, a youtube channel URL
function GetInputID : PChar; stdcall;
begin
  Result := 'Enter YouTube channel URL :';
end;


// The string to display for the users when asking for input, in our case, a youtube channel URL
function RequireTitle : Bool; stdcall;
begin
  Result := False;
end;


{
 Creating:
 1. Create a new "YouTube" video channel category, specify a channel URL.
 2. Call "CreateCategory" and return channel id, recommended scrapers and default category flags for the new category.

 Display:
 1. Call "GetList".
    GetList format:
    [ITEM_TYPE],[VIDEO_ID],[URL],[TITLE],[DESCRIPTION],[THUMBNAIL_URL],[PUBLISH_DATE]|....
}


exports
   InitPlugin,
   FreePlugin,
   CanConfigure,
   Configure,
   GetList,
   CreateCategory,
   RequireTitle,
   GetInputID;


begin
end.


// https://www.googleapis.com/youtube/v3/videos?id=dw7K4oMQZcU&key=AIzaSyBieQxSpir6Y2-iYPokdu90UxqM_skzZFo&fields=items%28id,snippet%28channelId,title,categoryId%29,statistics%29&part=snippet,statistics

// https://www.googleapis.com/youtube/v3/


// Get channel ID by username
//                                                   [ CHANNEL ID           ]     [ API KEY                             ]
// https://www.googleapis.com/youtube/v3/channels?id=UC1yBKRuGpC1tSM73A0ZjYjQ&key=AIzaSyBieQxSpir6Y2-iYPokdu90UxqM_skzZFo&part=contentDetails


// https://www.googleapis.com/youtube/v3/channels?part=contentDetails&forUsername=UC1yBKRuGpC1tSM73A0ZjYjQ&key=AIzaSyBieQxSpir6Y2-iYPokdu90UxqM_skzZFo
//
// result:
// {
//  "kind": "youtube#channelListResponse",
//  "etag": "\"5C5HHOaBSHC5ZXfkrT4ZlRCi01A/7bfDushoFIxrk51TE25bcHAjytw\"",
//  "pageInfo": {
//   "totalResults": 1,
//   "resultsPerPage": 5
//  },
//  "items": [
//   {
//    "kind": "youtube#channel",
//    "etag": "\"5C5HHOaBSHC5ZXfkrT4ZlRCi01A/EoFLsZS4VGCiU6pUkUSqSg2NS0Y\"",
//    "id": "UCVXd2_qKL7m3rbu8Txv6fPQ",
//    "contentDetails": {
//     "relatedPlaylists": {
//      "uploads": "UUVXd2_qKL7m3rbu8Txv6fPQ",
//      "watchHistory": "HL",
//      "watchLater": "WL"
//     }
//    }
//   }
//  ]
// }


// Get playlist of all videos for a channel (using playlistId)
// https://www.googleapis.com/youtube/v3/playlistItems?part=snippet%2CcontentDetails&maxResults=50&playlistId=UU1yBKRuGpC1tSM73A0ZjYjQ&key=AIzaSyBieQxSpir6Y2-iYPokdu90UxqM_skzZFo

// In the result, the "nextPageToken" can be used with the "&pageToken=" parameter to get the next page.

