object Main: TMain
  Left = 0
  Top = 0
  Caption = 'DelphiRobustServer GUI'
  ClientHeight = 401
  ClientWidth = 841
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 19
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 841
    Height = 382
    ActivePage = tsMain
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object tsMain: TTabSheet
      Caption = 'Main'
      inline MF: TMainFrame
        Left = 0
        Top = 0
        Width = 833
        Height = 349
        Align = alClient
        TabOrder = 0
        ExplicitWidth = 833
        ExplicitHeight = 349
        inherited eRequest: TEdit
          Width = 823
          ExplicitWidth = 823
        end
        inherited mAnswer: TMemo
          Width = 827
          Height = 107
          ExplicitWidth = 827
          ExplicitHeight = 107
        end
        inherited pAnswerTop: TPanel
          Width = 833
          ExplicitWidth = 833
        end
        inherited pPost: TPanel
          Width = 827
          ExplicitWidth = 827
          inherited pPostParamsTop: TPanel
            Width = 821
            ExplicitWidth = 821
            inherited cbPostType: TComboBox
              Width = 815
              ExplicitWidth = 815
            end
          end
          inherited mPostParams: TMemo
            Width = 821
            ExplicitWidth = 821
          end
        end
        inherited pTop: TPanel
          Width = 833
          ExplicitWidth = 833
          inherited bPause: TBitBtn
            OnClick = MFbPauseClick
          end
          inherited bInstallService: TBitBtn
            OnClick = MFbInstallServiceClick
          end
        end
        inherited pUrlEncode: TPanel
          Width = 827
          ExplicitWidth = 827
          inherited bDoUrlEncode: TBitBtn
            Left = 730
            ExplicitLeft = 730
          end
          inherited eUrlEncodeValue: TEdit
            Width = 720
            ExplicitWidth = 720
          end
        end
        inherited ilPics: TImageList
          Left = 480
          Top = 247
          Bitmap = {
            494C010104000800B80010001000FFFFFFFF2110FFFFFFFFFFFFFFFF424D3600
            0000000000003600000028000000400000002000000001002000000000000020
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000C0704104C291766160B
            0625000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000ECB95500EBB54A00EBB5
            4A00EBB54A00EBB54A00EBB54A00EBB54A00EBB54A00EBB54A00EBB54A00EBB5
            4A00EBB54A00EBB54A00ECB95500000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000001A0F0820B9602DDEA758
            29CD4324125B0603020C00000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000F6D79C00B8450000B845
            0000B8450000B8450000B8450000B8450000B8450000B8450000B8450000B845
            0000B8450000B8450000B845000000000000EFC46F00EBB54A00EBB54A00EBB5
            4A00EBB54A00EBB54A00EBB54A00EBB54A00EBB54A00EBB54A00EBB54A00EBB5
            4A00EBB54A00EBB54A00EBB54A00EFC46F000000000000000000E7864900E786
            4900E7864900E7864900E7864900E7864900E7864900E7864900E7864900E786
            4900E7864900000000000000000000000000000000001A0F0920BC5F2BE1DA6F
            2FFFD27134F58B4D25A926160C37000000030000000000000000000000000000
            00000000000000000000000000000000000000000000F6D79C00F6AA5700F6A5
            4A00F6A03E00F69C3300F6972800F6921D00F68E1400F6890C00F6840400F680
            0000F6800000F6800000B845000000000000EBB54A00EBB54A00EBB54A00EBB5
            4A00F0C77700F5DAA400F5DAA400F5DAA400F5DAA400F5DAA400F5DAA400EDBC
            5B00EBB54A00EBB54A00EBB54A00EBB54A000000000000000000E7864900E786
            4900E7864900E7864900E7864900E7864900E7864900E7864900E7864900E786
            4900E7864900000000000000000000000000000000001A0F0920BC5F2BE1DA6F
            2EFFDE7734FFE2803BFFC9793BE569422381110A061C00000000000000000000
            00000000000000000000000000000000000000000000F6D79C00F6AF6400F6AA
            5700F6A54A00F6A03E00F69C3300F6972800F6921D00F68E1400F6890C00F684
            0400F6800000F6800000B845000000000000EBB54A00EBB54A00EBB54A00EBB5
            4A00F5DAA400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F2D0
            8D00EBB54A00EBB54A00EBB54A00EBB54A000000000000000000E7864900E786
            4900E7864900E7864900E7864900E7864900E7864900E7864900E7864900E786
            4900E7864900000000000000000000000000000000001A0F0820BC5F2BE1D96D
            2DFFDD7533FFE17E39FFE68740FFE78F47FDB3733CCA452D18580403010B0000
            00000000000000000000000000000000000000000000F6D79C00F6B47200F6AF
            6400F6AA5700F6A54A00F6A03E00F69C3300F6972800F6921D00F68E1400F689
            0C00F6840400F6800000B845000000000000EBB54A00EBB54A00EBB54A00EBB5
            4A0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F5DA
            A400EBB54A00EBB54A00EBB54A00EBB54A000000000000000000E7864900E786
            4900E7864900E7864900E7864900E7864900E7864900E7864900E7864900E786
            4900E786490000000000000000000000000000000000190E0820BC5E2AE1D86C
            2CFFDC7332FFE07B37FFE4843DFFE88B43FFEC9349FFE0914BF48F5E32A62618
            0D350000000300000000000000000000000000000000F6D79C00F6B88000F6B4
            7200F6AF6400F6AA5700F6A54A00F6A03E00F69C3300F6972800F6921D00F68E
            1400F6890C00F6840400B845000000000000EBB54A00EBB54A00EBB54A00EBB5
            4A0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F8E6
            C300EBB54A00EBB54A00EBB54A00EBB54A000000000000000000E7864900E786
            4900E7864900E7864900E7864900E7864900E7864900E7864900E7864900E786
            4900E786490000000000000000000000000000000000190E0820BA5C28E1D769
            2AFFDA7030FFDE7735FFE17E3AFFE5863FFFE88C43FFEB9147FFEC954AFFCB82
            43E36541227D1009051A000000000000000000000000F6D79C00F6B88000F6B8
            8000F6B47200F6AF6400F6AA5700F6A54A00F6A03E00F69C3300F6972800F692
            1D00F68E1400F6890C00B845000000000000EBB54A00EBB54A00EBB54A00EBB5
            4A00FCF3E200FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
            0000EBB54A00EBB54A00EBB54A00EBB54A000000000000000000E7864900E786
            4900E7864900E7864900E7864900E7864900E7864900E7864900E7864900E786
            4900E7864900000000000000000000000000000000001A100A20BC6433E1D668
            2AFFD86C2CFFDC7331FFDF7936FFE2803AFFE4853EFFE68941FFE88C43FFE98D
            44FFE38A43FCAB6836C92E1C0E410000000000000000F6D79C00F6B88000F6B8
            8000F6B88000F6B67800F6B16B00F6AC5D00F6A75000F6A03E00F69C3300F697
            2800F6921D00F68E1400B845000000000000EBB54A00EBB54A00EBB54A00EBB5
            4A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FCF3
            E200EBB54A00EBB54A00EBB54A00EBB54A000000000000000000E7864900E786
            4900E7864900E7864900E7864900E7864900E7864900E7864900E7864900E786
            4900E7864900000000000000000000000000000000001A100A20BE6E41E1DA76
            3EFFD86F32FFD96E2EFFDC7331FFDE7835FFE17D39FFE2813BFFE3833DFFE484
            3DFFE3833DFFD27B3CEE4B2C175D0000000000000000F6D79C00F6B88000F6B8
            8000F6B88000F6B88000F6B67800F6B16B00F6AC5D00F6A75000F6A34400F69E
            3800F6992D00F6952300B845000000000000EBB54A00EBB54A00EBB54A00EBB5
            4A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00EBB54A00EBB54A00EBB54A00EBB54A000000000000000000E7864900E786
            4900E7864900E7864900E7864900E7864900E7864900E7864900E7864900E786
            4900E78649000000000000000000000000000000000019100A20BE6D41E1DB7C
            46FFDC7D45FFDC793EFFDB7537FFDC7534FFDD7634FFDE7835FFDF7A37FFD97A
            39F9995A2CB3331D0F3E020000030000000000000000F6D79C00F6B88000F6B8
            8000F6B88000F6B88000F6B88000F6B67800F6B16B00F6AC5D00F6A75000F6A3
            4400F69E3800F6992D00B845000000000000EBB54A00EBB54A00EBB54A00EDBC
            5B00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00EDBC5B00EBB54A00EBB54A00EBB54A000000000000000000E7864900E786
            4900E7864900E7864900E7864900E7864900E7864900E7864900E7864900E786
            4900E786490000000000000000000000000000000000190F0A20BD6C41E1DA7A
            46FFDB7C47FFDC7E48FFDE8148FFDE8146FFDE8043FFDE7F42FEB76936D5532F
            19640A05030E00000000000000000000000000000000F6D79C00F6B88000F6B8
            8000F6B88000F6B88000F6B88000F6B88000F6B67800F6B16B00F6AC5D00F6A7
            5000F6A34400F69E3800B845000000000000EBB54A00EBB54A00EBB54A00F0C7
            7700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00F0C77700EBB54A00EBB54A00EBB54A000000000000000000E7864900E786
            4900E7864900E7864900E7864900E7864900000000000000000000000000F9E1
            D100E786490000000000000000000000000000000000190F0A20BC6B41E1D979
            46FFDA7A46FFDB7C47FFDC7E48FFDD8149FFCB7A46EC774A2B8E1B1109220000
            00000000000000000000000000000000000000000000F6D79C00F6B88000F6B8
            8000F6B88000F6B88000F6B88000F6B88000F6B88000F6B67800F6B16B00F6AC
            5D00F6A75000F6A34400B845000000000000EBB54A00EBB54A00EBB54A000000
            0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF0000000000EBB54A00EBB54A00EBB54A000000000000000000E7864900E786
            4900E7864900E7864900E7864900E78649000000000000000000F9E1D100E786
            4900EDA4760000000000000000000000000000000000190F0A20BC6B41E1D878
            46FFD97946FFDA7A47FFD57947F9985B36B6341F134103020104000000000000
            00000000000000000000000000000000000000000000F6D79C00F6B88000F6B8
            8000F6B88000F6B88000F6B88000F6B88000F6B88000F6B88000F6B67800F6B1
            6B00F6AC5D00F6A75000B845000000000000EBB54A00EBB54A00EBB54A00F2D0
            8D00F5DAA400F5DAA400FFFFFF00F8E6C300FCF3E200FCF3E200F5DAA400F5DA
            A400F2D08D00EBB54A00EBB54A00EBB54A000000000000000000E7864900E786
            4900E7864900E7864900E7864900E786490000000000F9E1D100E7864900EDA4
            76000000000000000000000000000000000000000000190F0A20BC6A41E1D777
            46FFD87846FFB3633AD7542F1C680B06030F0000000000000000000000000000
            00000000000000000000000000000000000000000000F6D79C00F6B88000F6B8
            8000F6B88000F6B88000F6B88000F6B88000F6B88000F6B88000F6B88000F6B6
            7800F6B16B00F6AC5D00B845000000000000EBB54A00EBB54A00EBB54A00EBB5
            4A00EBB54A00EBB54A00F8E6C300FCF3E200FFFFFF00F5DAA400EBB54A00EBB5
            4A00EBB54A00EBB54A00EBB54A00EBB54A000000000000000000E7864900E786
            4900E7864900E7864900E7864900E7864900F9E1D100E7864900EDA476000000
            00000000000000000000000000000000000000000000190F0A20BC6A43E2C66F
            43EE754027911B0D082400000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000F6D79C00F6D79C00F6D7
            9C00F6D79C00F6D79C00F6D79C00F6D79C00F6D79C00F6D79C00F6D79C00F6D7
            9C00F6D79C00F6D79C00F6D79C0000000000ECB95500EBB54A00EBB54A00EBB5
            4A00EBB54A00EBB54A00EDBC5B00F0C77700F0C77700EDBC5B00EBB54A00EBB5
            4A00EBB54A00EBB54A00EBB54A00ECB955000000000000000000E7864900E786
            4900E7864900E7864900E7864900E7864900E7864900EDA47600000000000000
            000000000000000000000000000000000000000000000F0906157D492F9B3E23
            1650030100050000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000FCF1DD00EFC46F00EFC46F00EBB5
            4A00EBB54A00EBB54A00EBB54A00EBB54A00EBB54A00EBB54A00EBB54A00EBB5
            4A00EBB54A00EFC46F00EFC46F00FCF1DD000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000424D3E000000000000003E000000
            2800000040000000200000000100010000000000000100000000000000000000
            000000000000000000000000FFFFFF0000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000008FFFFFFF8001FFFF83FF80010000C007
            80FF80010000C007807F80010000C007801F80010800C007800780010800C007
            800380010010C007800180010000C007800180010000C007800180010000C007
            800780010000C0E7801F80011008C0C7803F80010000C08F80FF80010000C01F
            83FF80010000C03F87FFFFFF0000FFFF00000000000000000000000000000000
            000000000000}
        end
      end
    end
    object tsLoadTests: TTabSheet
      Caption = 'LoadTests'
      ImageIndex = 1
      inline LoadTestFrame1: TLoadTestFrame
        Left = 0
        Top = 0
        Width = 833
        Height = 349
        Align = alClient
        TabOrder = 0
        ExplicitWidth = 833
        ExplicitHeight = 349
        inherited Splitter2: TSplitter
          Width = 833
          ExplicitWidth = 833
        end
        inherited pTop: TPanel
          Width = 833
          ExplicitWidth = 833
          inherited cmbTests: TComboBox
            Width = 663
            Height = 26
            ExplicitWidth = 663
            ExplicitHeight = 26
          end
        end
        inherited pCenter: TPanel
          Width = 833
          ExplicitWidth = 833
          inherited pRight: TPanel
            Width = 643
            ExplicitWidth = 643
            inherited pParamsTop: TPanel
              Width = 641
              ExplicitWidth = 641
            end
            inherited mParams: TMemo
              Width = 641
              ExplicitWidth = 641
            end
          end
        end
        inherited pBottom: TPanel
          Width = 833
          Height = 129
          ExplicitWidth = 833
          ExplicitHeight = 129
          inherited mResultsErrors: TMemo
            Width = 831
            Height = 103
            ExplicitWidth = 831
            ExplicitHeight = 103
          end
          inherited pResultsErrors: TPanel
            Width = 831
            ExplicitWidth = 831
          end
        end
      end
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 382
    Width = 841
    Height = 19
    Panels = <
      item
        Text = 'Stoped'
        Width = 80
      end
      item
        Width = 120
      end
      item
        Width = 150
      end
      item
        Width = 100
      end
      item
        Width = 100
      end>
  end
end
