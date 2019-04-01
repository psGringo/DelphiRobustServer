object LoadTestFrame: TLoadTestFrame
  Left = 0
  Top = 0
  Width = 602
  Height = 390
  TabOrder = 0
  object Splitter2: TSplitter
    Left = 0
    Top = 217
    Width = 602
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitWidth = 173
  end
  object pTop: TPanel
    Left = 0
    Top = 0
    Width = 602
    Height = 33
    Align = alTop
    Caption = 'pTop'
    TabOrder = 0
    object bStart: TBitBtn
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 75
      Height = 25
      Align = alLeft
      Caption = 'Start'
      TabOrder = 0
      OnClick = bStartClick
    end
    object bStop: TBitBtn
      AlignWithMargins = True
      Left = 85
      Top = 4
      Width = 75
      Height = 25
      Align = alLeft
      Caption = 'Stop'
      TabOrder = 1
      OnClick = bStopClick
    end
    object cmbTests: TComboBox
      AlignWithMargins = True
      Left = 166
      Top = 4
      Width = 432
      Height = 21
      Align = alClient
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 2
      Text = 'DBConnections'
      Items.Strings = (
        'DBConnections')
    end
  end
  object pCenter: TPanel
    Left = 0
    Top = 33
    Width = 602
    Height = 184
    Align = alTop
    Caption = 'pCenter'
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 186
      Top = 1
      Height = 182
      ExplicitLeft = 304
      ExplicitTop = 40
      ExplicitHeight = 100
    end
    object pLeft: TPanel
      Left = 1
      Top = 1
      Width = 185
      Height = 182
      Align = alLeft
      Caption = 'pLeft'
      ShowCaption = False
      TabOrder = 0
      object pDescriptionTop: TPanel
        Left = 1
        Top = 1
        Width = 183
        Height = 24
        Align = alTop
        Caption = 'Description'
        TabOrder = 0
      end
      object mDescription: TMemo
        Left = 1
        Top = 25
        Width = 183
        Height = 156
        Align = alClient
        TabOrder = 1
      end
    end
    object pRight: TPanel
      Left = 189
      Top = 1
      Width = 412
      Height = 182
      Align = alClient
      Caption = 'pLeft'
      ShowCaption = False
      TabOrder = 1
      object pParamsTop: TPanel
        Left = 1
        Top = 1
        Width = 410
        Height = 24
        Align = alTop
        Caption = 'Params'
        TabOrder = 0
      end
      object mParams: TMemo
        Left = 1
        Top = 25
        Width = 410
        Height = 156
        Align = alClient
        Lines.Strings = (
          'countRequestsPerSecond=10')
        TabOrder = 1
      end
    end
  end
  object pBottom: TPanel
    Left = 0
    Top = 220
    Width = 602
    Height = 170
    Align = alClient
    Caption = 'pBottom'
    TabOrder = 2
    object mResultsErrors: TMemo
      Left = 1
      Top = 25
      Width = 600
      Height = 144
      Align = alClient
      Lines.Strings = (
        '')
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object pResultsErrors: TPanel
      Left = 1
      Top = 1
      Width = 600
      Height = 24
      Align = alTop
      Caption = 'ResultsErrors'
      TabOrder = 1
    end
  end
  object Timer: TTimer
    Enabled = False
    OnTimer = TimerTimer
    Left = 288
    Top = 104
  end
  object IdHTTP: TIdHTTP
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 416
    Top = 88
  end
  object IdAntiFreeze: TIdAntiFreeze
    Left = 360
    Top = 152
  end
end
