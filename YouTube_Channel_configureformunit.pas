{$I SCRAPER_DEFINES.INC}

unit YouTube_Channel_configureformunit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

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


var
  ConfigForm         : TConfigForm = nil;
  UploadPlaylistList : TList;

implementation

{$R *.dfm}

uses shellapi;

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


