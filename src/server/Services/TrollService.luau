local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local ProductUtil = require(ReplicatedStorage.Shared.Modules.ProductUtil)

local TrollService = Knit.CreateService({Name = "TrollService", 
    Client = {RequestScare = Knit.CreateSignal(), FlingClient = Knit.CreateSignal(), 
    JumpscareClient = Knit.CreateSignal(), ReplicateJumpscare = Knit.CreateSignal()}})

local LastScareRequest = {} --[Flinger] = flingeeToBe 

function TrollService:KnitInit()
    --[[self.LinkService = Knit.GetService("LinkService")
    self.ChatService = Knit.GetService("ChatService")

    self.Client.RequestScare:Connect(function(player: Player, targetPlayer: Player)
        LastScareRequest[player] = targetPlayer
        ProductUtil.PromptPurchase(player, "Jumpscare Player")
    end)]]
end

function TrollService:FlingPlayer(player: Player)
    self.Client.FlingClient:Fire(player)
end

function TrollService:ExplodePlayer(player: Player)
    local character = player.Character
    if not character then 
        return 
    end

    local explosion = Instance.new("Explosion", workspace)
    explosion.Position = character.HumanoidRootPart.Position
    explosion.BlastPressure = 200000
    explosion.BlastRadius = 20
    explosion.DestroyJointRadiusPercent = 0
end

function TrollService:PoopForPlayer(player: Player)
    local character = player.Character
    if not character then 
        return 
    end

    local attachment = ReplicatedStorage.Assets.PoopExplosion:Clone() 
    attachment.Parent = character.PrimaryPart
    attachment.Poop.Enabled = true 
    attachment.Fart.Enabled = true 
    attachment.Sound:Play()

    task.spawn(function()
        task.wait(3.5)
        TweenService:Create(attachment.Poop, TweenInfo.new(0.5), {["Rate"] = 0}):Play()
        TweenService:Create(attachment.Fart, TweenInfo.new(0.5), {["Rate"] = 0}):Play()
        task.wait(3)
        attachment:Destroy()
    end)

    local linkedPlayed = self.LinkService.LinkedPlayers[player]
    if linkedPlayed then 
        local targetCharacter = linkedPlayed.Character
        if not targetCharacter then 
            return 
        end
        task.spawn(function()
            local odor = ReplicatedStorage.Assets.Odor:Clone()
            odor.Parent = linkedPlayed.Character.PrimaryPart 
            task.wait(10)
            odor:Destroy()
        end)
    end
end

function TrollService:FlingAll(flinger: Player)
    for _, player in Players:GetPlayers() do 
        if player ~= flinger and self.LinkService.LinkedPlayers[flinger] ~= player then 
            self:FlingPlayer(player)
            self.ChatService:MessageClients(string.format("%s has [FLUNG] %s", flinger.Name, player.Name), Players:GetPlayers())
            task.wait(0.3)
        end
    end
end

function TrollService:ExplodeAll(flinger: Player)
    for _, player in Players:GetPlayers() do 
        if player ~= flinger and self.LinkService.LinkedPlayers[flinger] ~= player then 
            self:ExplodePlayer(player)
            self.ChatService:MessageClients(string.format("%s has [EXPLODER] %s", flinger.Name, player.Name), Players:GetPlayers())
            task.wait(0.3)
        end
    end
end

function TrollService:JumpscareAll(flinger: Player)
    for _, player in Players:GetPlayers() do 
        if player ~= flinger and self.LinkService.LinkedPlayers[flinger] ~= player then 
            self.Client.JumpscareClient:Fire(player)
            self.Client.ReplicateJumpscare:FireAll(player)
            self.ChatService:MessageClients(string.format("%s has [JUMP SCARED] %s", flinger.Name, player.Name), Players:GetPlayers())
            task.wait(0.3)
        end
    end
end

function TrollService:JumpscareForPlayer(player: Player)
    local target = LastScareRequest[player]
    if not target then 
        return
    end
    --self:FlingPlayer(target)
    self.Client.ReplicateJumpscare:FireAll(target)
    self.Client.JumpscareClient:Fire(target)
    self.ChatService:MessageClients(string.format("%s has [JUMP SCARED] %s", player.Name, target.Name), Players:GetPlayers())
end


return TrollService