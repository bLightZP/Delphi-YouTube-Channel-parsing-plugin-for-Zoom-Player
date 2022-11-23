object ConfigForm: TConfigForm
  Left = 913
  Top = 345
  BorderStyle = bsDialog
  Caption = 'YouTube API Configuration'
  ClientHeight = 253
  ClientWidth = 338
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
    338
    253)
  PixelsPerInch = 96
  TextHeight = 13
  object LabelChannelStrategy: TLabel
    Left = 18
    Top = 86
    Width = 94
    Height = 13
    Caption = 'Channel list strategy'
  end
  object LabelCustomAPIKey: TLabel
    Left = 18
    Top = 48
    Width = 123
    Height = 13
    Caption = 'Custom YouTube API Key'
  end
  object LabelYouTubeTerms: TLabel
    Left = 16
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
    Left = 218
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
    Left = 246
    Top = 213
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 5
  end
  object CancelButton: TButton
    Left = 16
    Top = 213
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 6
  end
  object ChannelStrategyCB: TComboBox
    Left = 154
    Top = 82
    Width = 169
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 1
    Text = 'Use search'
    Items.Strings = (
      'Use search'
      'Use '#39'upload'#39' playlist')
  end
  object ClearCacheButton: TButton
    Left = 154
    Top = 107
    Width = 169
    Height = 31
    Caption = 'Clear '#39'Upload'#39' playlist cache'
    TabOrder = 2
    OnClick = ClearCacheButtonClick
  end
  object IncludeNoDurationCB: TCheckBox
    Left = 18
    Top = 150
    Width = 301
    Height = 17
    Caption = 'Include Live && Placeholder entries (only in search mode)'
    TabOrder = 3
  end
  object MaxThumbnailResCB: TCheckBox
    Left = 18
    Top = 168
    Width = 301
    Height = 17
    Caption = 'Maximum thumbnail resolution (720p, more bandwidth)'
    TabOrder = 4
  end
  object APIKeyEdit: TEdit
    Left = 154
    Top = 46
    Width = 169
    Height = 21
    TabOrder = 0
  end
end
