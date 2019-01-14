object DelphiRobustService: TDelphiRobustService
  OldCreateOrder = False
  OnCreate = ServiceCreate
  DisplayName = 'DelphiRobustService'
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 150
  Width = 215
end
