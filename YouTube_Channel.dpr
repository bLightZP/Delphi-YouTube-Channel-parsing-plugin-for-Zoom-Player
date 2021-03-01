{$I YOUTUBE_PLUGIN_DEFINES.INC}

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
  TNTSystem,
  SuperObject,
  WinInet,
  misc_utils_unit,
  YouTube_Channel_configureformunit,
  {$IFDEF LOCALTRACE}
  msgdlgunit,
  {$ENDIF}
  ISO_3166_1_alpha_2_unit,
  youtube_api;

{$R *.res}


Type
  TCategoryPluginRecord =
  Record
    CategoryInput : PChar;
    CategoryID    : PChar;
    CategoryTitle : PChar;
    CategoryThumb : PChar;
    DataPath      : PChar;
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
  // Settings Registry Path and API Key
  //PluginRegKey               : String = 'Software\VirtuaMedia\ZoomPlayer\MediaLibraryPlugins\YouTube Channel';

  // Category flags
  catFlagThumbView           : Integer =      1;     // Enable thumb view (disabled = list view)
  catFlagThumbCrop           : Integer =      2;     // Crop media thumbnails to fit in display area (otherwise pad thumbnails)
  catFlagVideoFramesAsThumb  : Integer =      4;     // Grab thumbnails from video frame
  catFlagDarkenThumbBG       : Integer =      8;     // [Darken thumbnail area background], depreciated by "OPNavThumbDarkBG".
  catFlagJukeBox             : Integer =     16;     // Jukebox mode enabled
  catFlagBGFolderIcon        : Integer =     32;     // Draw folder icon if the folder has a thumbnail
  catFlagScrapeParentFolder  : Integer =     64;     // Scrape the parent folder if no meta-data was found for the media file
  catFlagScrapeMediaInFolder : Integer =    128;     // Create folder thumbnails from first media file within the folder (if scraping is disabled or fails)
  catFlagTitleFromMetaData   : Integer =    256;     // Use meta-data title for the thumb's text instead of the file name
  catFlagNoScraping          : Integer =    512;     // Disable all scraping operations for this folder
  catFlagRescrapeModified    : Integer =   1024;     // Rescrape folders if their "modified" date changes
  catFlagTVJukeBoxNoScrape   : Integer =   2048;     // Switched to TV JukeBox list view without having the parent folder scraped first
  catFlag1stMediaFolderThumb : Integer =   4096;     // Instead of scraping for a folder's name, always use the first media file within the folder instead
  catFlagCropCatThumbnail    : Integer =   8192;     // Crop category thumbnails to fit in display area (otherwise pad thumbnails)
  catFlagScrapeDebugMsgs     : Integer =  16384;     // Show scraper debug messages in meta-data overview
  catFlagScrapeMediaTitle    : Integer =  32768;     // Scrape using media title instead of file name
  catFlagNoDurationOverlay   : Integer =  65536;     // Don't draw the duration/position thumbnail overlay
  catFlagNoFormatOverlay     : Integer = 131072;     // Don't draw the media format thumbnail overlay
  catFlagNoReturnResults     : Integer = 262144;     // Don't expect any result entries from the plugin

  srName                               = 0;
  srExt                                = 1;
  srDate                               = 2;
  srSize                               = 3;
  srPath                               = 4;
  srDuration                           = 5;
  srRandom                             = 6;

  strWorldWide               : String  = 'Worldwide';
  strEverything              : String  = 'Everything';

  pluginRegKey               : String  = 'Software\VirtuaMedia\ZoomPlayer\Plugins\YouTube';
  RegKeyChannelStrategy      : String  = 'ChannelStrategy';
  RegKeyPlaylistID           : String  = 'PlaylistID';
  RegKeyZeroDuration         : String  = 'ZeroDuration';
  RegKeyMaxThumbnailRes      : String  = 'MaxThumbnailRes';
  RegKeyCustomAPIKey         : String  = 'CustomAPIKey';               


var
  iChannelStrategy     : Integer;
  bIncludeZeroDuration : Boolean = False;
  bMaxThumbnailRes     : Boolean = False;
  sCustomAPIKey        : String  = '';


// Called by Zoom Player to free any resources allocated in the DLL prior to unloading the DLL.
Procedure FreePlugin; stdcall;
var
  I : Integer;
  S : String;
begin
  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Free Plugin (before)');{$ENDIF}

  // Save Playlist ID to registry
  S := '';
  For I := 0 to UploadPlaylistList.Count-1 do
  Begin
    If I = 0 then
      S := PUploadPlaylistIDRecord(UploadPlaylistList[I])^.sChannelID+','+PUploadPlaylistIDRecord(UploadPlaylistList[I])^.sPlaylistID else
      S := S+'|'+PUploadPlaylistIDRecord(UploadPlaylistList[I])^.sChannelID+','+PUploadPlaylistIDRecord(UploadPlaylistList[I])^.sPlaylistID;
    Dispose(PUploadPlaylistIDRecord(UploadPlaylistList[I]));
  End;

  SetRegString(HKEY_CURRENT_USER,PluginRegKey,RegKeyPlaylistID,S);


  UploadPlaylistList.Free;
  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Free Plugin (after)');{$ENDIF}
end;


// Called by Zoom Player to init any resources.
function InitPlugin : Bool; stdcall;
var
  I      : Integer;
  iPos   : Integer;
  S      : String;
  sList  : TStringList;
  nEntry : PUploadPlaylistIDRecord;
begin
  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Init Plugin (before)');{$ENDIF}
  I := GetRegDWord(HKEY_CURRENT_USER,PluginRegKey,RegKeyChannelStrategy);
  If I > -1 then iChannelStrategy := I;

  I := GetRegDWord(HKEY_CURRENT_USER,PluginRegKey,RegKeyZeroDuration);
  If (I = 0) or (I = 1) then bIncludeZeroDuration := Boolean(I);

  I := GetRegDWord(HKEY_CURRENT_USER,PluginRegKey,RegKeyMaxThumbnailRes);
  If (I = 0) or (I = 1) then bMaxThumbnailRes := Boolean(I);

  UploadPlaylistList := TList.Create;

  S := GetRegString(HKEY_CURRENT_USER,PluginRegKey,RegKeyPlaylistID);
  If S <> '' then
  Begin
    sList := TStringList.Create;
    Split(S,'|',sList);
    For I := 0 to sList.Count-1 do
    Begin
      New(nEntry);

      iPos := Pos(',',sList[I]);
      nEntry^.sChannelID  := Copy(sList[I],1,iPos-1);
      nEntry^.sPlaylistID := Copy(sList[I],iPos+1,Length(sList[I])-iPos);

      UploadPlaylistList.Add(nEntry);
    End;
    sList.Free;

    // Limit cache size to 200 entries by deleting the oldest entries
    While UploadPlaylistList.Count > 200 do
    Begin
      Dispose(PUploadPlaylistIDRecord(UploadPlaylistList[0]));
      UploadPlaylistList.Delete(0);
    End;
  End;

  S := GetRegString(HKEY_CURRENT_USER,PluginRegKey,RegKeyCustomAPIKey);
  If S <> '' then
  Begin
    APIKey        := S;
    sCustomAPIKey := S;
  End
  Else APIKey := APIKeyDefault;

  Result := True;
  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Init Plugin (after)');{$ENDIF}
end;


// Called by Zoom Player to verify if a configuration dialog is available.
// Return True if a dialog exits and False if no configuration dialog exists.
function CanConfigure : Bool; stdcall;
begin
  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'CanConfigure (before)');{$ENDIF}
  Result := True;
  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'CanConfigure (after)');{$ENDIF}
end;


// Called by Zoom Player to show the plugin's configuration dialog.
Procedure Configure(CenterOnWindow : HWND; CategoryID : PChar); stdcall;
var
  CenterOnRect : TRect;
  tmpInt       : Integer;
begin
  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Configure (before)');{$ENDIF}
  If GetWindowRect(CenterOnWindow,CenterOnRect) = False then
    GetWindowRect(0,CenterOnRect); // Can't find window, center on screen

  ConfigForm := TConfigForm.Create(nil);
  ConfigForm.SetBounds(CenterOnRect.Left+(((CenterOnRect.Right -CenterOnRect.Left)-ConfigForm.Width)  div 2),
                       CenterOnRect.Top +(((CenterOnRect.Bottom-CenterOnRect.Top )-ConfigForm.Height) div 2),ConfigForm.Width,ConfigForm.Height);

  ConfigForm.ChannelStrategyCB.ItemIndex := iChannelStrategy;
  ConfigForm.ClearCacheButton.Enabled    := UploadPlaylistList.Count > 0;

  ConfigForm.IncludeNoDurationCB.Checked := bIncludeZeroDuration;
  ConfigForm.MaxThumbnailResCB.Checked   := bMaxThumbnailRes;
  ConfigForm.APIKeyEdit.Text             := sCustomAPIKey;

  If ConfigForm.ShowModal = mrOK then
  Begin
    // Save to registry
    If iChannelStrategy <> ConfigForm.ChannelStrategyCB.ItemIndex then
    Begin
      iChannelStrategy := ConfigForm.ChannelStrategyCB.ItemIndex;
      SetRegDWord(HKEY_CURRENT_USER,PluginRegKey,RegKeyChannelStrategy,iChannelStrategy);
    End;
    bIncludeZeroDuration := ConfigForm.IncludeNoDurationCB.Checked;
    bMaxThumbnailRes     := ConfigForm.MaxThumbnailResCB.Checked;

    SetRegDWord(HKEY_CURRENT_USER,PluginRegKey,RegKeyZeroDuration,Integer(bIncludeZeroDuration));
    SetRegDWord(HKEY_CURRENT_USER,PluginRegKey,RegKeyMaxThumbnailRes,Integer(bMaxThumbnailRes));

    sCustomAPIKey := ConfigForm.APIKeyEdit.Text;
    If sCustomAPIKey <> '' then APIKey := sCustomAPIKey else APIKey := APIKeyDefault;
    SetRegString(HKEY_CURRENT_USER,PluginRegKey,RegKeyCustomAPIKey,sCustomAPIKey);
  End;
  ConfigForm.Free;
  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Configure (after)');{$ENDIF}
end;


// Called by Zoom Player to verify if the plugin can refresh itself (name/thumbnail).
function CanRefresh : Bool; stdcall;
begin
  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'CanRefresh (before)');{$ENDIF}
  {$IF DEFINED(SEARCHMODE) or DEFINED(TRENDINGMODE)}   // YouTube Search Plugin
  Result := False;
  {$ELSE}
  Result := True;
  {$IFEND}
  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'CanRefresh (after)');{$ENDIF}
end;


// Called by Zoom Player to show the refresh the category (name/thumbnail).
Function Refresh(CategoryData : PCategoryPluginRecord) : Integer; stdcall; 
var
  sCatInput   : String;
  sTitle      : String;
  sPlaylistID : String;
  sThumbnail  : String;
  I           : Integer;
begin
  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Refresh (before)');{$ENDIF}
  Result       := E_FAIL;
  If CategoryData = nil then
  Begin
    {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Exit on "CategoryData = nil"');{$ENDIF}
    Exit;
  End;

  sCatInput    := CategoryData^.CategoryInput;
  sPlaylistID  := '';
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
    {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Categoty Input: '+sCatInput);{$ENDIF}

    // Remove playlist ID
    I := Pos(',',sCatInput);
    If I > 0 then sCatInput := Copy(sCatInput,1,I-1);

    // Get Channel Title, Thumbnail & Upload playlist ID
    YouTube_GetChannelDetails(sCatInput,sTitle,sThumbnail,sPlaylistID,bMaxThumbnailRes);

    // was used for alternative method of downloading youtube videos, sadly it returned them in a bad order.
    If sPlaylistID <> '' then
      CategoryData^.CategoryID := PChar(sCatInput+','+sPlaylistID) else
      CategoryData^.CategoryID := PChar(sCatInput);

    If sTitle <> '' then
    Begin
      CategoryData^.CategoryTitle := PChar(sTitle);
      If sThumbnail <> '' then CategoryData^.CategoryThumb := PChar(sThumbnail);
      Result := S_OK;
    End;
  End
  {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'No Channel ID specified!'){$ENDIF};

  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Refresh (after)');{$ENDIF}
end;


Function CreateCategory(CenterOnWindow : HWND; CategoryData : PCategoryPluginRecord) : Integer; stdcall;
const
  urlTypeNone    = 0;
  urlTypeUser    = 1;
  urlTypeChannel = 2;
var
  sCatInput      : String;
  sCatInputLC    : String;
  sChannelID     : String;
  sPlaylistID    : String;
  sTitle         : String;
  sThumbnail     : String;
  sCatID         : String;
  sUserName      : WideString;
  sPos           : Integer;
  ePos           : Integer;
  I,I1           : Integer;
  sList          : TStringList;
  uList          : TTNTStringList;
  uStr           : WideString;
  nEntry         : PUploadPlaylistIDRecord;
  Found          : Boolean;
  iOfs           : Integer;
  urlType        : Integer;

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
  //ShowMessageW(sCatInput+ ' / '+UTF8Decode(sCatInput));
  sCatInputLC  := Lowercase(sCatInput);
  sChannelID   := '';
  sPlaylistID  := '';
  sThumbnail   := '';
  CategoryData^.CategoryID    := '';
  CategoryData^.CategoryTitle := '';
  CategoryData^.CategoryThumb := '';
  CategoryData^.Scrapers      := '';
  CategoryData^.TextLines     := 2;
  CategoryData^.SortMode      := srDate;
  CategoryData^.DefaultFlags  := catFlagThumbView or catFlagThumbCrop or catFlagTitleFromMetaData or catFlagNoFormatOverlay;

  {$IFDEF SEARCHMODE}
    // **********************************************************************************
    // ********************************* YouTube Search *********************************
    // **********************************************************************************

    CategoryData^.CategoryID    := PChar(sCatInput);
    CategoryData^.CategoryTitle := PChar('Search:'+sCatInput);
    CategoryData^.CategoryThumb := PChar(UTF8Encode(GetCurrentDLLPath)+'YouTube_Search.jpg');
    Result := S_OK;
  {$ELSE}
    {$IFDEF TRENDINGMODE}
      // **********************************************************************************
      // ********************************* YouTube Trends *********************************
      // **********************************************************************************

      If sCatInput = strWorldWide then
      Begin
        sCatID := strWorldWide;
      End
        else
      // Convert language name to ISO 3166-1 alpha-2 code
      For I := 0 to ISO_3166_1_alpha_2_Count-1 do If sCatInput = ISO_3166_1_alpha_2_str[I] then
      Begin
        sCatID := ISO_3166_1_alpha_2[I];
        Break;
      End;
      uList := TTNTStringList.Create;

      If sCatID <> strWorldWide then
      Begin
        // YouTube category lists only work per-country, it doesn't work globally
        YouTube_GetCategoryIDs(sCatID,uList);
      End;

      uStr := '';
      uList.InsertObject(0,strEverything,TObject(-1));
      If misc_utils_unit.InputComboW(CenterOnWindow,'Category :', '', uList,uStr) = True then
      Begin
        For I := 0 to uList.Count-1 do If uStr = uList[I] then
        Begin
          sCatID := sCatID+','+IntToStr(Integer(uList.Objects[I]));
          CategoryData^.CategoryTitle := PChar(UTF8Encode(EncodeTextTags('Trending: '+uList[I]+' in '+sCatInput,True)));
          Break;
        End;
        CategoryData^.CategoryID    := PChar(sCatID);
        CategoryData^.CategoryThumb := PChar(UTF8Encode(GetCurrentDLLPath)+'YouTube_Trending.jpg');
        Result := S_OK;
      End
      Else Result := S_FALSE; // prevents an error dialog, used for "cancel".

      uList.Free;

      // Get list of automatically generated video categories
      // https://www.googleapis.com/youtube/v3/videoCategories?part=snippet&regionCode=IL&key=API_KEY
    {$ELSE}
      {$IFDEF PLAYLISTMODE}
        // ***********************************************************************************
        // ******************************** YouTube PlayList *********************************
        // ***********************************************************************************
        sCatID := Trim(sCatInput);
        I := Pos('?list=',Lowercase(sCatID));
        If I > 0 then
        Begin
          sCatID := Copy(sCatID,I+6,Length(sCatID)-(I+5));
          CategoryData^.CategoryID    := PChar(sCatID);
          CategoryData^.CategoryThumb := PChar(UTF8Encode(GetCurrentDLLPath)+'YouTube_Playlist.jpg');
          Result := S_OK;
        End;
      {$ELSE}
        // ***********************************************************************************
        // ********************************* YouTube Channel *********************************
        // ***********************************************************************************

        If sCatInput <> '' then
        Begin
          // Try to find the Channel ID by input URL
          iOfs := 10;
          sPos := Pos('/channel/',sCatInputLC);

          If sPos > 0 then
          Begin
            ePos := PosEx('/',sCatInput,sPos+iOfs);
            If ePos > 0 then
              sChannelID := Copy(sCatInput,sPos+(iOfs-1),ePos-(sPos+(iOfs-1))) else
              sChannelID := Copy(sCatInput,sPos+(iOfs-1),Length(sCatInput)-(sPos+(iOfs-2)));
          End
            else
          Begin
            // Try to find the Channel ID by user name in input URL
            {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Convert User Name to Channel ID');{$ENDIF}
            urlType := urlTypeNone;
            iOfs    := 7;
            sPos    := Pos('/user/',sCatInputLC);
            If sPos = 0 then
            Begin
              iOfs := 4;
              sPos := Pos('/c/',sCatInputLC);
              If sPos > 0 then urlType := urlTypeChannel;
            End
            Else urlType := urlTypeUser;
            If sPos > 0 then
            Begin
              ePos := PosEx('/',sCatInput,sPos+iOfs);
              If ePos > 0 then
                sUserName := Copy(sCatInput,sPos+(iOfs-1),ePos-(sPos+(iOfs-1))) else
                sUserName := Copy(sCatInput,sPos+(iOfs-1),Length(sCatInput)-(sPos+(iOfs-2)));

              {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'User Name: '+sUserName);{$ENDIF}
              Case urlType of
                urlTypeUser    : If sUserName <> '' then sChannelID := YouTube_ConvertUserNameToChannelID(sUserName);
                urlTypeChannel : If sUserName <> '' then sChannelID := YouTube_ConvertChannelNameToChannelID(sUserName);
              End;
            End;
          End;

          If sChannelID <> '' then
          Begin
            {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Channel ID: '+sChannelID);{$ENDIF}

            // Get Channel Title, Thumbnail & Upload playlist ID
            YouTube_GetChannelDetails(sChannelID,sTitle,sThumbnail,sPlaylistID,bMaxThumbnailRes);

            CategoryData^.CategoryID := PChar(sChannelID);

            // Check if we have the UploadID cached
            Found := False;
            For I := 0 to UploadPlaylistList.Count-1 do If PUploadPlaylistIDRecord(UploadPlaylistList[I])^.sChannelID = sChannelID then
            Begin
              Found := True;
              Break;
            End;

            // If UploadID is not cached, add it to the cache.
            If Found = False then
            Begin
              New(nEntry);
              nEntry^.sChannelID  := sChannelID;
              nEntry^.sPlaylistID := sPlaylistID;
              UploadPlaylistList.Add(nEntry);
            End;

            If sTitle <> '' then
            Begin
              CategoryData^.CategoryTitle := PChar(sTitle);
              If sThumbnail <> '' then CategoryData^.CategoryThumb := PChar(sThumbnail);
              Result := S_OK;
            End;
          End
          {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'No Channel ID detected'){$ENDIF};
        End;
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}

  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'CreateCategory, Result : '+IntToHex(Result,8)+' (after)');{$ENDIF}
end;


function DeleteCategory(CenterOnWindow : HWND; CategoryID,DataPath : PChar) : Integer; stdcall;
begin
  Result := S_OK;
end;


Function GetList(CategoryID, CategoryPath, DataPath : PChar; ItemList : PCategoryItemList) : Integer; stdcall;
type
  TYouTubeVideoRecord =
  Record
    ytvType         : Integer;
    ytvPath         : WideString;
    ytvChannelName  : WideString;
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
  YouTube_VideoFetchUpload : Integer = 50;
  YouTube_VideoFetchSearch : Integer = 25;

var
  S,S1        : String;
  sID         : String;
  I,I1        : Integer;
  iLen        : Integer;
  sList       : TStringList;
  jBase       : ISuperObject;
  jItems      : ISuperObject;
  jEntry      : ISuperObject;
  jSnippet    : ISuperObject;
  jResourceID : ISuperObject;
  dlStatus    : String;
  dlError     : Integer;
  sJSON       : String;
  sURL        : String;
  sUTF8       : String;
  sToken      : String;
  sItemList   : WideString;
  sIDList     : String;
  ytvList     : TList;
  ytvEntry    : PYouTubeVideoRecord;
  mStream     : TMemoryStream;
  sPlaylistID : String;
  xThumbnail  : String;
  xTitle      : String;
  nEntry      : PUploadPlaylistIDRecord;
  tz          : TTimeZoneInformation;
  TZBias      : Integer;
  {$IFDEF TRENDINGMODE}
  iCatType    : Integer;
  sCatRegion  : String;
  {$ENDIF}


  function SortByPublishDate(Item1, Item2: PYouTubeVideoRecord) : Integer;
  begin
    {if TZPFileClass(Item1).zplSize = TZPFileClass(Item2).zplSize then
      Result := flSortByName(Item1,Item2)
    else if TZPFileClass(Item1).zplSize < TZPFileClass(Item2).zplSize then
      Result := -1
    else
      Result := 1;}
    If Item1^.ytvPublished > Item2^.ytvPublished then Result := -1 else
      If Item1^.ytvPublished < Item2^.ytvPublished then Result := 1 else Result := 0;
  end;


  procedure WipeYTVentry(Entry : PYouTubeVideoRecord);
  begin
    ytvEntry^.ytvType         := 0;
    ytvEntry^.ytvPath         := '';
    ytvEntry^.ytvChannelName  := '';
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
    sTitle      : WideString;
    sMetaLikes  : String;
    iMetaRating : Integer;
  Begin
    Case Entry^.ytvType of
      0    : sPath := 'https://www.youtube.com/watch?v='+Entry^.ytvPath;
      else   sPath := Entry^.ytvPath;
    End;
    If Entry^.ytvPublished > 0 then sDate := TimeDifferenceToStr(IncMillisecond(Now,TZBias),Entry^.ytvPublished) else sDate := '';

        // #9/TAB is used for right-alignment of text
    sMetaLikes :=
      IntToStrDelimiter(Entry^.ytvViewCount   ,',')+' views\n\n'+
      IntToStrDelimiter(Entry^.ytvLikeCount   ,',')+' likes\n\n'+
      IntToStrDelimiter(Entry^.ytvDislikeCount,',')+' dislikes';

    //If Entry^.ytvChannelName <> '' then sMetaLikes := Entry^.ytvChannelName+'\n\n'+sMetaLikes;

    sDuration := EncodeDuration(Entry^.ytvDuration);
    sTitle    := Entry^.ytvTitle;
    //If Entry^.ytvChannelName <> '' then sTitle := sTitle+'  @'+Entry^.ytvChannelName;

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
              // user login not implemented, no way to pass the last play position
              //'"Position='    +FloatToStr(Entry^.ytvPosition)+'",'+
              '"Date='        +FloatToStr(Entry^.ytvPublished)+'",'+
              '"MetaEntry1='  +EncodeTextTags(sTitle,True)+'",'+
              '"MetaEntry2='  +sDate+'",'+
              '"MetaEntry3='  +sDuration+'",'+
              '"MetaEntry4='  +Entry^.ytvChannelName+'",'+
              '"MetaEntry5='  +EncodeTextTags(Entry^.ytvDescription,True)+'",'+
              '"MetaEntry6='  +sMetaLikes+'",'+
              '"MetaRating='  +IntToStr(iMetaRating)+'"';
  End;


begin
  // **** Getting upload playlist:
  // https://www.googleapis.com/youtube/v3/channels?key=[apikey]&part=contentDetails&id=[ChannelID]
  //
  // **** Getting playlist data:
  // https://www.googleapis.com/youtube/v3/playlistitems?key=[apikey]&part=snippet,id&playlistId=[playlistId]&maxResults='+IntToStr(YouTube_VideoFetch)
  // e.g. : https://www.googleapis.com/youtube/v3/playlistItems?key=AIzaSyBieQxSpir6Y2-iYPokdu90UxqM_skzZFo&part=snippet,id&playlistId=UUEK3tT7DcfWGWJpNEDBdWog&maxResults=25

  // CategoryID   = A unique category identifier, in our case, a YouTube channel's "Channel ID".
  // CategoryPath = Used to the pass a path or parameter, in our case, a YouTube channel's next page Token.
  // ItemList     = Return a list of items and meta-data

  // ItemType :
  // 0 = Playable item
  // 1 = Enter Folder, retrieve new list with additional 'categorypath'.
  // 2 = Append items to list, removing this entry

  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'GetList (before)');{$ENDIF}
  Result             := E_FAIL;

  sList       := TStringList.Create;
  ytvList     := TList.Create;
  sPlaylistID := '';

  // Get Timezone information
  If GetTimeZoneInformation(tz) = TIME_ZONE_ID_DAYLIGHT then
  Begin
    TZBias := (tz.Bias+tz.DaylightBias)*60000;
  End
  Else TZBias := tz.Bias*60000;


  {$IFDEF SEARCHMODE}
    // ******************************************************************
    // ************************** Search mode ***************************
    // ******************************************************************

    //https://www.googleapis.com/youtube/v3/search?part=snippet,id&q=[Search]&type=video&key={YOUR_API_KEY}
    sURL    := 'https://www.googleapis.com/youtube/v3/search?key='+APIKey+'&q='+URLEncodeUTF8(UTF8Decode(CategoryID))+'&part=snippet,id&order=relevance&type=video&maxResults='+IntToStr(YouTube_VideoFetchSearch);
    //ShowMessageW(CategoryID+' / '+UTF8Decode(CategoryID)+' / '+ URLEncodeUTF8(UTF8Decode(S)));
  {$ELSE}

    {$IFDEF TRENDINGMODE}
      // ******************************************************************
      // **************************** Trending ****************************
      // ******************************************************************

      S := CategoryID;
      I := Pos(',',S);
      If I > 0 then
      Begin
        iCatType   := StrToIntDef(Copy(S,I+1,Length(S)-I),-1);
        sCatRegion := Copy(S,1,I-1);
      End
        else
      Begin
        iCatType   := -1;
        sCatRegion := S;
      End;

      // Trending in country with specific category
      //https://www.googleapis.com/youtube/v3/videos?part=contentDetails&chart=mostPopular&videoCategoryId=10&maxResults=25&key=API_KEY

      // Trending in country
      //https://www.googleapis.com/youtube/v3/videos?part=contentDetails&chart=mostPopular&regionCode=IN&maxResults=25&key=API_KEY
      If sCatRegion <> strWorldwide then S := '&regionCode='+sCatRegion else S := '';
      If iCatType > -1 then S := S+'&videoCategoryId='+IntToStr(iCatType);
      sURL    := 'https://www.googleapis.com/youtube/v3/videos?part=snippet,id&chart=mostPopular'+S+'&maxResults='+IntToStr(YouTube_VideoFetchSearch)+'&key='+APIKey;
    {$ELSE}

      {$IFDEF PLAYLISTMODE}
        // ******************************************************************
        // **************************** Play List ***************************
        // ******************************************************************
        sURL := 'https://www.googleapis.com/youtube/v3/playlistItems?key='+APIKey+'&playlistId='+CategoryID+'&part=snippet,id&order=date&type=video&maxResults='+IntToStr(YouTube_VideoFetchUpload);
        sPlaylistID := CategoryID;
      {$ELSE}
        // ******************************************************************
        // ************************** Channel List **************************
        // ******************************************************************

        S := CategoryID;

        Case iChannelStrategy of
          0 : // Search
          Begin
            sURL := 'https://www.googleapis.com/youtube/v3/search?key='+APIKey+'&channelId='+S+'&part=snippet,id&order=date&type=video&maxResults='+IntToStr(YouTube_VideoFetchSearch);
          End;
          1 : // 'Upload' playlist
          Begin
            // Find the 'upload' playlist ID
            For I := 0 to UploadPlaylistList.Count-1 do If S = PUploadPlaylistIDRecord(UploadPlaylistList[I])^.sChannelID then
            Begin
              // Match found
              sPlaylistID := PUploadPlaylistIDRecord(UploadPlaylistList[I])^.sPlaylistID;
              Break;
            End;

            // No Upload PlaylistID, try getting again.
            If sPlaylistID = '' then
            Begin
              YouTube_GetChannelDetails(S,xTitle,xThumbnail,sPlaylistID,bMaxThumbnailRes);
              New(nEntry);
              nEntry^.sChannelID  := S;
              nEntry^.sPlaylistID := sPlaylistID;
              UploadPlaylistList.Add(nEntry)
            End;

            sURL := 'https://www.googleapis.com/youtube/v3/playlistItems?key='+APIKey+'&playlistId='+sPlaylistID+'&part=snippet,id&order=date&type=video&maxResults='+IntToStr(YouTube_VideoFetchUpload);
          End;
        End;
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
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
            If sPlaylistID = '' then
            Begin
              // Parse channel/search/trending
              {$IFDEF TRENDINGMODE}
              ytvEntry^.ytvPath := jEntry.S['id'];
              {$ELSE}
              jSnippet := jEntry.O['id'];
              If jSnippet <> nil then
              Begin
                ytvEntry^.ytvPath := jSnippet.S['videoId'];
                jSnippet.Clear(True);
                jSnippet := nil;
              End
              {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'JSON id object returned nil'){$ENDIF};
              {$ENDIF}

              jSnippet := jEntry.O['snippet'];
              If jSnippet <> nil then
              Begin
                //{$IF Defined(TRENDINGMODE) or Defined(SEARCHMODE)}
                //ytvEntry^.ytvChannelName := UTF8StringToWideString(jSnippet.S['channelTitle']);
                ytvEntry^.ytvChannelName := UTF8StringToWideString(HTMLUnicodeToUTF8(jSnippet.S['channelTitle']));
                //{$IFEND}

                //ytvEntry^.ytvTitle       := UTF8StringToWideString(jSnippet.S['title']);
                //ytvEntry^.ytvDescription := UTF8StringToWideString(jSnippet.S['description']);
                ytvEntry^.ytvTitle       := UTF8StringToWideString(HTMLUnicodeToUTF8(jSnippet.S['title']));
                ytvEntry^.ytvDescription := UTF8StringToWideString(HTMLUnicodeToUTF8(jSnippet.S['description']));

                S := jSnippet.S['publishedAt'];
                Try
                  // new format: 2020-05-13T21:46:00Z
                  // old format: 2016-12-04T20:00:02.000Z
                  ytvEntry^.ytvPublished := EncodeDateTime(
                      StrToInt(Copy(S, 1,4)),  // Year
                      StrToInt(Copy(S, 6,2)),  // Month
                      StrToInt(Copy(S, 9,2)),  // Day
                      StrToInt(Copy(S,12,2)),  // Hour
                      StrToInt(Copy(S,15,2)),  // Minute
                      StrToInt(Copy(S,18,2)),  // Second
                      {StrToInt(Copy(S,21,3))}0); // MS
                Except
                  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Published Exception on : '+S);{$ENDIF}
                  ytvEntry^.ytvPublished := 0;;
                End;

                ytvEntry^.ytvThumbnail := YouTube_GetBestThumbnailURL(jSnippet,bMaxThumbnailRes);

                jSnippet.Clear(True);
                jSnippet := nil;
              End
              {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'JSON snippet object returned nil'){$ENDIF};
            End
              else
            Begin
              // Parse playlist
              jSnippet := jEntry.O['snippet'];
              If jSnippet <> nil then
              Begin
                {ytvEntry^.ytvChannelName := UTF8StringToWideString(HTMLUnicodeToUTF8(jSnippet.S['channelTitle']));
                ytvEntry^.ytvTitle       := UTF8StringToWideString(HTMLUnicodeToUTF8(jSnippet.S['title']));
                ytvEntry^.ytvDescription := UTF8StringToWideString(HTMLUnicodeToUTF8(jSnippet.S['description']));}

                // HTMLUnicodeToUTF8 does not work here, the text is not encoded like the search method.
                ytvEntry^.ytvChannelName := UTF8StringToWideString(jSnippet.S['channelTitle']);
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
                ytvEntry^.ytvThumbnail := YouTube_GetBestThumbnailURL(jSnippet,bMaxThumbnailRes);

                jResourceID := jSnippet.O['resourceId'];
                If jResourceID <> nil then
                Begin
                  ytvEntry^.ytvPath := jResourceID.S['videoId'];
                  jResourceID.Clear(True);
                  jResourceID := nil;
                End;
                jSnippet.Clear(True);
                jSnippet := nil;
              End
              {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'JSON snippet object returned nil'){$ENDIF};
            End;

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
    For I := 0 to ytvList.Count-1 do
    Begin
      If I = 0 then
        sIDList := PYouTubeVideoRecord(ytvList[I])^.ytvPath else
        sIDList := sIDList+','+PYouTubeVideoRecord(ytvList[I])^.ytvPath;
    End;

    sURL := 'https://www.googleapis.com/youtube/v3/videos?part=contentDetails,statistics&id='+sIDList+'&key='+APIKey;
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
                  PYouTubeVideoRecord(ytvList[I1])^.ytvDuration := YouTube_ISO8601toSeconds(S);
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
  End;

  // Sort by publish date when using 'upload' playlist id.
  If iChannelStrategy = 1 then ytvList.Sort(@SortByPublishDate);

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

  mStream := TMemoryStream.Create;
  For I := 0 to ytvList.Count-1 do If ((PYouTubeVideoRecord(ytvList[I])^.ytvDuration > 0) or (bIncludeZeroDuration = True)) or (PYouTubeVideoRecord(ytvList[I])^.ytvType <> 0) then
  Begin
    If I = 0 then
      sUTF8 := UTF8Encode(YTVrecordToString(PYouTubeVideoRecord(ytvList[I]))) else
      sUTF8 := '|'+UTF8Encode(YTVrecordToString(PYouTubeVideoRecord(ytvList[I])));
      //sItemList := YTVrecordToString(PYouTubeVideoRecord(ytvList[I])) else
      //sItemList := sItemList+'|'+YTVrecordToString(PYouTubeVideoRecord(ytvList[I]));

    mStream.Write(sUTF8[1],Length(sUTF8));

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

  //sUTF8 := UTF8Encode(sItemList);
  //Len  := Length(sUTF8);
  If mStream.Size > 0 then
  Begin
    If mStream.Size < 1024*1024 then
    //If iLen < 1024*1024 then
    Begin
      {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'Result size : '+IntToStr(mStream.Size)+' bytes');{$ENDIF}
      sUTF8 := #0;
      mStream.Write(sUTF8[1],1);
      mStream.Position := 0;
      mStream.Read(ItemList^.catItems^,mStream.Size);
      //Move(sUTF8[1],ItemList^.catItems^,iLen);
    End
    {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'YouTube parsed results larger than the 1mb buffer!!!'){$ENDIF};
  End
  {$IFDEF LOCALTRACE}Else DebugMsgFT(LogInit,'No data received!'){$ENDIF};
  mStream.Free;

  Result := S_OK;
  //End;

  For I := 0 to ytvList.Count-1 do Dispose(PYouTubeVideoRecord(ytvList[I]));
  ytvList.Free;
  sList.Free;

  {$IFDEF LOCALTRACE}DebugMsgFT(LogInit,'GetList (after)');{$ENDIF}
end;


// The string to display for the users when asking for input, in our case, a youtube channel URL
function GetInputID : PChar; stdcall;
var
  I     : Integer;
  sList : TStringList;
  S     : String;

begin
  {$IFDEF SEARCHMODE}
  Result := 'YouTube Search :';
  {$ELSE}
    {$IFDEF TRENDINGMODE}
    S := 'Trending in :';

    // Provide country options
    sList := TStringList.Create;
    For I := 0 to ISO_3166_1_alpha_2_Count-1 do sList.Add(ISO_3166_1_alpha_2_str[I]);
    sList.Sort;
    sList.Insert(0,strWorldWide);
    For I := 0 to sList.Count-1 do S := S+'|'+sList[I];
    sList.Free;
    Result := PChar(S);
    {$ELSE}
      {$IFDEF PLAYLISTMODE}
        Result := 'Enter YouTube playlist URL :';
      {$ELSE}
        Result := 'Enter YouTube channel URL :';
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
end;


// The string to display for the users when asking for input, in our case, a youtube channel URL
function RequireTitle : Bool; stdcall;
begin
  {$IFDEF PLAYLISTMODE}
    Result := True;
  {$ELSE}
    Result := False;
  {$ENDIF}
end;


function RequireInput : Bool; stdcall;
begin
  {$IFDEF PLAYLISTMODE}
    Result := True;
  {$ELSE}
    Result := False;
  {$ENDIF}
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
   CanRefresh,
   Refresh,
   CanConfigure,
   Configure,
   GetList,
   CreateCategory,
   DeleteCategory,
   RequireTitle,
   RequireInput,
   GetInputID;


begin
  // Required to notify the memory manager that this DLL is being called from a multi-threaded application!
  IsMultiThread := True;
end.

