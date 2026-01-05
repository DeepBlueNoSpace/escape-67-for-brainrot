local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local Camera = workspace.CurrentCamera

local Knit = require(ReplicatedStorage.Packages.Knit)
local GetSafeCharacter = require(ReplicatedStorage.Shared.Modules.GetSafeCharacter)

local JumpscarePromptController = Knit.CreateController({ Name = "JumpscarePromptController"})

local DISPLAY_DISTANCE = 30

function JumpscarePromptController:KnitInit()
    self.TrollService = Knit.GetService("TrollService")
    self.UIController = Knit.GetController("UIController")
end

function JumpscarePromptController:KnitStart()
    local attachment = ReplicatedStorage.Assets.JumpscareAttachment:Clone()
    local billboard = attachment.BillboardGui
    billboard.Parent = self.UIController.PlayerGui 
    billboard.Adornee = attachment

    local currentTarget = nil
    billboard.Button.MouseButton1Click:Connect(function()
        print(currentTarget)
        if not currentTarget then 
            return 
        end
        self.TrollService.RequestScare:Fire(currentTarget)
    end)

    RunService.Heartbeat:Connect(function()
        local closetPlayer, closestCharacter, closestDistance = nil, nil, math.huge 
        for _, player in Players:GetPlayers() do 
            if player == Player then 
                continue 
            end

            local targetCharacter = GetSafeCharacter(player)
            if not targetCharacter then 
                continue 
            end 

            local distance = (Camera.CFrame.Position-targetCharacter.HumanoidRootPart.Position).Magnitude 
            if distance > closestDistance or distance > DISPLAY_DISTANCE then 
                continue 
            end

            closetPlayer = player
            closestCharacter = targetCharacter
        end

        if closetPlayer then 
            currentTarget = closetPlayer
            billboard.Adornee = closestCharacter:FindFirstChild("HEAD") or closestCharacter:FindFirstChild("Head")
            billboard.Enabled = true

            if closestCharacter:FindFirstChild("IsFrog") then 
                billboard.ExtentsOffsetWorldSpace = Vector3.new(0,5,0)
            else
                billboard.ExtentsOffsetWorldSpace = Vector3.new(0,12,0)
            end
        else
            currentTarget = nil 
            billboard.Adornee = nil
            billboard.Enabled = false
        end
    end)
end

return JumpscarePromptController