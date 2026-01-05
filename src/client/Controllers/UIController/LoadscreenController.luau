local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local ButtonUtil = require(ReplicatedStorage.Shared.Modules.ButtonUtil)
local TEST_CONFIGS = require(ReplicatedStorage.Shared.TEST_CONFIGS)

local LoadscreenController = Knit.CreateController({ Name = "LoadscreenController", IsOpen = false})

function LoadscreenController:KnitInit() 
   self.UIController = Knit.GetController("UIController")
end


function LoadscreenController:KnitStart() 
    self.LoadScreenUI = self.UIController.PlayerGui:WaitForChild("LoadScreen")
    self.Frame = self.LoadScreenUI:WaitForChild("Frame")
    self.Button = self.Frame:WaitForChild("Button")

    if TEST_CONFIGS.Is("DISABLE_LOADSCREEN") then 
        self.LoadScreenUI:Destroy()
        return 
    end

    ButtonUtil.InitStandardInteraction(self.Button)

    local tween = TweenService:Create(self.Button, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = self.Button.Position})
    self.Button.Position = UDim2.fromScale(0.5, 1.3)
    self.Button.Visible = false 

    task.wait(3)
    self.Button.Visible = true 
    
    SoundService:PlayLocalSound(ReplicatedStorage.Assets.Sound.FrameIn)

    tween:Play() 

    self.Button.Activated:Wait()

    SoundService:PlayLocalSound(ReplicatedStorage.Assets.Sound.FrameOut)
    TweenService:Create(self.Frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.fromScale(0, 1)}):Play()
end


return LoadscreenController