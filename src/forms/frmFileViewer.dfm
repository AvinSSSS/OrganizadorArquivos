object frmFileViewerWindow: TfrmFileViewer
  Left = 0
  Top = 0
  Caption = 'Visualização de arquivo'
  ClientHeight = 640
  ClientWidth = 960
  Color = 16250354
  Constraints.MinHeight = 480
  Constraints.MinWidth = 640
  Font.Charset = DEFAULT_CHARSET
  Font.Color = 3485227
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 17
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 960
    Height = 64
    Align = alTop
    BevelOuter = bvNone
    Color = 10840623
    ParentBackground = False
    StyleElements = [seFont, seBorder]
    TabOrder = 0
    DesignSize = (
      960
      64)
    object lblTitle: TLabel
      Left = 24
      Top = 19
      Width = 58
      Height = 25
      Caption = 'Arquivo'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -17
      Font.Name = 'Segoe UI Semibold'
      Font.Style = []
      ParentFont = False
    end
    object btnClose: TButton
      Left = 852
      Top = 15
      Width = 84
      Height = 34
      Anchors = [akTop, akRight]
      Caption = 'Fechar'
      ModalResult = 8
      TabOrder = 0
    end
  end
  object memText: TMemo
    Left = 16
    Top = 80
    Width = 928
    Height = 544
    Align = alClient
    BorderStyle = bsNone
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
    WordWrap = False
  end
  object pnlImage: TPanel
    Left = 0
    Top = 64
    Width = 960
    Height = 576
    Align = alClient
    BevelOuter = bvNone
    Color = 16250354
    ParentBackground = False
    StyleElements = [seFont, seBorder]
    TabOrder = 2
    object imgPreview: TImage
      Left = 0
      Top = 0
      Width = 960
      Height = 576
      Align = alClient
      Center = True
      Proportional = True
      Stretch = True
    end
  end
end
