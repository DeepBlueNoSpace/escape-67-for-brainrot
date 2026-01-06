local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local GetSafeCharacter = require(ReplicatedStorage.Shared.Modules.GetSafeCharacter)
local WalkSpeedData = require(ReplicatedStorage.Shared.Data.WalkSpeedData)
local Knit = require(ReplicatedStorage.Packages.Knit)
local WalkSpeedService = Knit.CreateService({Name = "WalkSpeedService", Client = {RequestWalkSpeedUpgrade = Knit.CreateSignal()}})

function WalkSpeedService:KnitInit()
    self.DataService = Knit.GetService("DataService")
end

local DEFAULT_WALK_SPEED = game.StarterPlayer.CharacterWalkSpeed

function WalkSpeedService:KnitStart()
    self.DataService.SaveReplicaCreated:Connect(function(player: Player)
        local replica =  self.DataService:GetReplica(player)
        self:HandlePlayer(player, replica)

    end)


    self.Client.RequestWalkSpeedUpgrade:Connect(function(player: Player, upgrades: number)
        local replica = self.DataService:GetReplica(player)
        if not replica then 
            return 
        end

        if upgrades < 1 or upgrades > 10 then 
            return 
        end

        local cost = WalkSpeedData.CalculatePriceForUpgrades(replica.Data.WalkSpeedUpgrades, upgrades)
        if replica.Data.Cash < cost then 
            return 
        end

        replica:SetValue("Cash", replica.Data.Cash - cost)
        replica:SetValue("WalkSpeedUpgrades", replica.Data.WalkSpeedUpgrades+upgrades)
        self:SetCharacterWalkSpeed(player, replica.Data.WalkSpeedUpgrades)
    end)
end

function WalkSpeedService:HandlePlayer(player: Player, replica)
    if GetSafeCharacter(player) then 
        self:SetCharacterWalkSpeed(player, replica.Data.WalkSpeedUpgrades)
    end

    player.CharacterAdded:Connect(function()
        self:SetCharacterWalkSpeed(player, replica.Data.WalkSpeedUpgrades)
    end)
end

function WalkSpeedService:SetCharacterWalkSpeed(player: Player, walkSpeedUpgrades)
    local character = GetSafeCharacter(player)
    character.Humanoid.WalkSpeed = DEFAULT_WALK_SPEED + walkSpeedUpgrades
end

return WalkSpeedService
