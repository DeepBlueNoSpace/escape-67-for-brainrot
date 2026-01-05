local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local Player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)

local FlingOthersController = Knit.CreateController({ Name = "FlingOthersController"})

function FlingOthersController:KnitInit()
    self.TrollService = Knit.GetService("TrollService")
end 

function FlingOthersController:KnitStart() 
    for _, player in Players:GetPlayers() do 
        if not(player == Player) then 
            self:HandlePlayer(player)
        end
    end

    Players.PlayerAdded:Connect(function(player: Player)
        self:HandlePlayer(player)
    end)
end

function FlingOthersController:HandlePlayer(player: Player)
    if player.Character then 
        self:HandlePlayerCharacter(player)
    end

    player.CharacterAdded:Connect(function()
        self:HandlePlayerCharacter(player)
    end)
end 

function FlingOthersController:HandlePlayerCharacter(player: Player)
  --[[  local character = player.Character 
    local hrp = character:WaitForChild("HumanoidRootPart", 3)
    if not hrp then 
        return 
    end

    local proximityPrompt = Instance.new("ProximityPrompt")
    proximityPrompt.ActionText = " 😈😈😈 JUMPSCARE PLAYER"
    proximityPrompt.Parent = hrp 
    proximityPrompt.RequiresLineOfSight = false

    proximityPrompt.Triggered:Connect(function()
        self.TrollService.RequestScare:Fire(player)
    end)]]
end



return FlingOthersController