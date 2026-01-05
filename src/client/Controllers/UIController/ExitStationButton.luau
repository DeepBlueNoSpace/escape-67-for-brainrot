--This probably didnt need to be its own script but here we are
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local ButtonUtil = require(ReplicatedStorage.Shared.Modules.ButtonUtil)
local GetSafeCharacter = require(ReplicatedStorage.Shared.Modules.GetSafeCharacter)

local ExitStationButtonController = Knit.CreateController({ Name = "ExitStationButtonController", ExitLocation = nil})

function ExitStationButtonController:KnitInit() 
    self.UIController = Knit.GetController("UIController")
    self.LinkController = Knit.GetController("LinkController")
    self.LinkService = Knit.GetService("LinkService")
end

function ExitStationButtonController:KnitStart() 
    self.Button = self.UIController.MainGui:WaitForChild("ExitStation")
    ButtonUtil.InitStandardInteraction(self.Button)

    self.Button.MouseButton1Click:Connect(function() 
        self.Button.Visible = false 
        
        local character = GetSafeCharacter(Player)  
        if character and self.ExitLocation then 
            character:MoveTo(self.ExitLocation)
        end
    end)

    self.LinkService.StationEntered:Connect(function(exitLocation: Vector3) 
        self.ExitLocation = exitLocation 
        self.Button.Visible = true
    end)

    RunService.Heartbeat:Connect(function()
        if self.LinkController.ActiveTongue then 
            self.Button.Visible = false 
        end
    end)
end


return ExitStationButtonController