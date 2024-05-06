object ConfigForm: TConfigForm
  Left = 586
  Top = 240
  BorderStyle = bsDialog
  Caption = 'YouTube API Configuration'
  ClientHeight = 331
  ClientWidth = 405
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnKeyPress = FormKeyPress
  DesignSize = (
    405
    331)
  PixelsPerInch = 96
  TextHeight = 13
  object LabelChannelStrategy: TLabel
    Left = 18
    Top = 97
    Width = 94
    Height = 13
    Caption = 'Channel list strategy'
  end
  object LabelCustomAPIKey: TLabel
    Left = 18
    Top = 61
    Width = 123
    Height = 13
    Caption = 'Custom YouTube API Key'
  end
  object LabelYouTubeTerms: TLabel
    Left = 18
    Top = 14
    Width = 127
    Height = 13
    Cursor = crHandPoint
    Caption = 'YouTube Terms of Service'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = LabelYouTubeTermsClick
  end
  object LabelGooglePrivacyPolicy: TLabel
    Left = 283
    Top = 14
    Width = 103
    Height = 13
    Cursor = crHandPoint
    Caption = 'Google Privacy Policy'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = LabelGooglePrivacyPolicyClick
  end
  object OKButton: TButton
    Left = 316
    Top = 290
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 8
  end
  object CancelButton: TButton
    Left = 16
    Top = 290
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 9
  end
  object ChannelStrategyCB: TComboBox
    Left = 168
    Top = 93
    Width = 220
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 1
    TabOrder = 1
    Text = 'Use '#39'upload'#39' playlist'
    Items.Strings = (
      'Use search'
      'Use '#39'upload'#39' playlist'
      'Use activities')
  end
  object ClearCacheButton: TButton
    Left = 168
    Top = 118
    Width = 220
    Height = 31
    Caption = 'Clear '#39'Upload'#39' playlist cache'
    TabOrder = 2
    OnClick = ClearCacheButtonClick
  end
  object IncludeNoDurationCB: TCheckBox
    Left = 18
    Top = 178
    Width = 370
    Height = 17
    Caption = 'Include Live && Placeholder entries (only in search mode)'
    TabOrder = 3
  end
  object MaxThumbnailResCB: TCheckBox
    Left = 18
    Top = 203
    Width = 370
    Height = 17
    Caption = 'Maximum thumbnail resolution (720p, more bandwidth)'
    TabOrder = 4
  end
  object APIKeyEdit: TEdit
    Left = 168
    Top = 57
    Width = 220
    Height = 21
    TabOrder = 0
  end
  object FilterDurationCB: TCheckBox
    Left = 18
    Top = 227
    Width = 243
    Height = 17
    Caption = 'Do not list videos shorter than (seconds)'
    TabOrder = 5
  end
  object FilterDurationEdit: TEdit
    Left = 316
    Top = 225
    Width = 75
    Height = 21
    MaxLength = 4
    TabOrder = 6
  end
  object PlaylistChannelTNCB: TCheckBox
    Left = 18
    Top = 251
    Width = 243
    Height = 17
    Caption = 'Prefer channel thumbmail for playlists'
    TabOrder = 7
    Visible = False
  end
end
