local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local Assets = ReplicatedStorage.Assets
local Player = Players.LocalPlayer


local Knit = require(ReplicatedStorage.Packages.Knit)
local GetSafeCharacter = require(ReplicatedStorage.Shared.Modules.GetSafeCharacter)
local Signal = require(ReplicatedStorage.Packages.Signal)

local ShiftLockController = Knit.CreateController({ Name = "ShiftLockController", Locked = false,})

function ShiftLockController:KnitInit()
    self.UIController = Knit.GetController("UIController")
    self.FrogAnimationController = Knit.GetController("FrogAnimationController")
end

function ShiftLockController:HandleMobileJump()
  
end

function ShiftLockController:KnitStart()

end




return ShiftLockController