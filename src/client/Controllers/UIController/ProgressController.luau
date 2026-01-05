local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local Player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local ButtonUtil = require(ReplicatedStorage.Shared.Modules.ButtonUtil)
local GetSafeCharacter = require(ReplicatedStorage.Shared.Modules.GetSafeCharacter)
local ProductUtil = require(ReplicatedStorage.Shared.Modules.ProductUtil)

local ProgressController = Knit.CreateController({ Name = "ProgressController"})
local SoundService = game:GetService("SoundService")

local noOfStages = 65

local AltStartHeight = workspace.Terrain:WaitForChild("AltitudeStart").WorldPosition.Y 
local AltEndHeight = workspace.Terrain:WaitForChild("AltitudeFinish").WorldPosition.Y 

local delta = AltEndHeight-AltStartHeight
function ProgressController:KnitInit() 
    self.UIController = Knit.GetController("UIController")
end

function ProgressController:KnitStart() 
    local stageValue = Player:WaitForChild("leaderstats"):WaitForChild("Stage")

    self.AltitudeLabel = self.UIController.MainGui:WaitForChild("Altitude")
    self.ProgressBar = self.AltitudeLabel:WaitForChild("ObbyProgress")
    self.ProgressFill = self.ProgressBar:WaitForChild("Fill")
    self.SkipButton = self.ProgressBar:WaitForChild("Skip")
    self.SkipButton.Visible = false 

    stageValue.Changed:Connect(function() 
        if stageValue.Value > 0 then 
            self.SkipButton.Visible = true 
        end
    end)
    
    RunService.Heartbeat:Connect(function() 
        local character = GetSafeCharacter(Player)
        if not character then 
            return 
        end


        self.AltitudeLabel.Text = string.format("Stage: %s/%s", stageValue.Value, noOfStages)
        self.ProgressFill.Size = UDim2.fromScale(stageValue.Value/noOfStages, 1)
    end)

    ButtonUtil.InitStandardInteraction(self.SkipButton)

    self.SkipButton.MouseButton1Click:Connect(function() 
        ProductUtil.PromptPurchase(Player, "Skip")
    end)
end

return ProgressController