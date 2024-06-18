{$I YOUTUBE_PLUGIN_DEFINES.INC}

unit YouTube_Channel_configureformunit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;


const
  pluginRegKey                : String  = 'Software\VirtuaMedia\ZoomPlayer\Plugins\YouTube';
  RegKeyChannelStrategy       : String  = 'ChannelStrategy';
  RegKeyPlaylistID            : String  = 'PlaylistID';
  RegKeyZeroDuration          : String  = 'ZeroDuration';
  RegKeyMaxThumbnailRes       : String  = 'MaxThumbnailRes';
  RegKeyCustomAPIKey          : String  = 'CustomAPIKey';

  RegKeyFilterDurationEnabled : String  = 'FilterDurationEnabled';
  RegKeyFilterDurationSeconds : String  = 'FilterDurationSeconds';
  RegKeyYouTubeVideoFetch     : String  = 'YouTubeVideoFetch';

  {$IFDEF PLAYLISTMODE}
  RegKeyPlaylistChannelTN     : String  = 'PlaylistChannelTN';
  {$ENDIF}


var
  iChannelStrategy     : Integer;
  bIncludeZeroDuration : Boolean = False;
  bMaxThumbnailRes     : Boolean = False;
  sCustomAPIKey        : String  = '';
  bFilterDuration      : Boolean = False;
  iFilterDuration      : Integer = 62;
  YouTube_VideoFetch   : Integer = 0;

  {$IFDEF PLAYLISTMODE}
  bPlaylistChannelTN   : Boolean = True;
  {$ENDIF}


type
  TConfigForm = class(TForm)
    OKButton: TButton;
    CancelButton: TButton;
    LabelChannelStrategy: TLabel;
    ChannelStrategyCB: TComboBox;
    ClearCacheButton: TButton;
    IncludeNoDurationCB: TCheckBox;
    MaxThumbnailResCB: TCheckBox;
    LabelCustomAPIKey: TLabel;
    APIKeyEdit: TEdit;
    LabelYouTubeTerms: TLabel;
    LabelGooglePrivacyPolicy: TLabel;
    FilterDurationCB: TCheckBox;
    FilterDurationEdit: TEdit;
    PlaylistChannelTNCB: TCheckBox;
    FetchVideoLabel: TLabel;
    VideoFetchCB: TComboBox;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure edtMinMediaNameLengthForScrapingByNameKeyPress(
      Sender: TObject; var Key: Char);
    procedure ClearCacheButtonClick(Sender: TObject);
    procedure LabelYouTubeTermsClick(Sender: TObject);
    procedure LabelGooglePrivacyPolicyClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


  TUploadPlaylistIDRecord =
  Record
    sChannelID  : String;
    sPlaylistID : String;
  End;
  PUploadPlaylistIDRecord = ^TUploadPlaylistIDRecord;

  procedure LoadPluginConfig;

var
  ConfigForm         : TConfigForm = nil;
  UploadPlaylistList : TList;

implementation

{$R *.dfm}

uses shellapi, misc_utils_unit, youtube_api;


procedure LoadPluginConfig;
var
  I      : Integer;
  S      : String;
begin
  I := GetRegDWord(HKEY_CURRENT_USER,PluginRegKey,RegKeyChannelStrategy);
  If I > -1 then iChannelStrategy := I;

  I := GetRegDWord(HKEY_CURRENT_USER,PluginRegKey,RegKeyZeroDuration);
  If (I = 0) or (I = 1) then bIncludeZeroDuration := Boolean(I);

  I := GetRegDWord(HKEY_CURRENT_USER,PluginRegKey,RegKeyMaxThumbnailRes);
  If (I = 0) or (I = 1) then bMaxThumbnailRes := Boolean(I);

  S := GetRegString(HKEY_CURRENT_USER,PluginRegKey,RegKeyCustomAPIKey);
  If S <> '' then
  Begin
    APIKey        := S;
    sCustomAPIKey := S;
  End
  Else APIKey := APIKeyDefault;


  I := GetRegDWord(HKEY_CURRENT_USER,PluginRegKey,RegKeyFilterDurationEnabled);
  If (I = 0) or (I = 1) then bFilterDuration := Boolean(I);

  I := GetRegDWord(HKEY_CURRENT_USER,PluginRegKey,RegKeyFilterDurationSeconds);
  If (I > 0) and (I < 10000) then iFilterDuration := I;

  I := GetRegDWord(HKEY_CURRENT_USER,PluginRegKey,RegKeyYouTubeVideoFetch);
  If (I = 0) or (I = 1) then YouTube_VideoFetch := I;

  {$IFDEF PLAYLISTMODE}
  I := GetRegDWord(HKEY_CURRENT_USER,PluginRegKey,RegKeyPlaylistChannelTN);
  If (I = 0) or (I = 1) then bPlaylistChannelTN := Boolean(I);
  {$ENDIF}
end;


procedure TConfigForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  If Key = #27 then
  Begin
    Key := #0;
    Close;
  End;
end;

procedure TConfigForm.edtMinMediaNameLengthForScrapingByNameKeyPress(
  Sender: TObject; var Key: Char);
begin
  if not(Key in [#0..#31,'0'..'9']) then Key := #0;
end;


procedure TConfigForm.ClearCacheButtonClick(Sender: TObject);
var
  I : Integer;
begin
  For I := 0 to UploadPlaylistList.Count-1 do Dispose(PUploadPlaylistIDRecord(UploadPlaylistList[I]));
  UploadPlaylistList.Clear;

  ClearCacheButton.Enabled := False;
end;


procedure TConfigForm.LabelYouTubeTermsClick(Sender: TObject);
begin
  ShellExecute(0,'open','https://www.youtube.com/t/terms',nil,nil,0);
end;


procedure TConfigForm.LabelGooglePrivacyPolicyClick(Sender: TObject);
begin
  ShellExecute(0,'open','https://policies.google.com/privacy',nil,nil,0);
end;


end.


