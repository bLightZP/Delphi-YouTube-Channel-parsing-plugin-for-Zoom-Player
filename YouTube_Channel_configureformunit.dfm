object ConfigForm: TConfigForm
  Left = 701
  Top = 352
  BorderStyle = bsDialog
  Caption = 'YouTube API Configuration'
  ClientHeight = 210
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
    210)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 60
    Width = 94
    Height = 13
    Caption = 'Channel list strategy'
  end
  object Label2: TLabel
    Left = 16
    Top = 22
    Width = 123
    Height = 13
    Caption = 'Custom YouTube API Key'
  end
  object OKButton: TButton
    Left = 246
    Top = 170
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 5
  end
  object CancelButton: TButton
    Left = 16
    Top = 170
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 6
  end
  object ChannelStrategyCB: TComboBox
    Left = 152
    Top = 56
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
    Left = 152
    Top = 81
    Width = 169
    Height = 31
    Caption = 'Clear '#39'Upload'#39' playlist cache'
    TabOrder = 2
    OnClick = ClearCacheButtonClick
  end
  object IncludeNoDurationCB: TCheckBox
    Left = 16
    Top = 124
    Width = 301
    Height = 17
    Caption = 'Include Live && Placeholder entries (only in search mode)'
    TabOrder = 3
  end
  object MaxThumbnailResCB: TCheckBox
    Left = 16
    Top = 142
    Width = 301
    Height = 17
    Caption = 'Maximum thumbnail resolution (720p, more bandwidth)'
    TabOrder = 4
  end
  object APIKeyEdit: TEdit
    Left = 152
    Top = 20
    Width = 169
    Height = 21
    TabOrder = 0
  end
end
