local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local AnalyticsService = game:GetService("AnalyticsService")

local Assets = ReplicatedStorage.Assets 

local Knit = require(ReplicatedStorage.Packages.Knit)
local GetSafeCharacter = require(ReplicatedStorage.Shared.Modules.GetSafeCharacter)
local TEST_CONFIGS = require(ReplicatedStorage.Shared.TEST_CONFIGS)
local LinkStation = require(script.LinkStation)

local LinkService = Knit.CreateService({Name = "LinkService", 
    Client = {StartLink = Knit.CreateSignal(), LinkDestroyed = Knit.CreateSignal(), StationEntered = Knit.CreateSignal(), SetFrogPosition = Knit.CreateSignal(), 
    SetPartner = Knit.CreateSignal(), PlayAnimalAnimations = Knit.CreateSignal(), SendCat = Knit.CreateSignal()}, LinkedPlayers = {}, 
    LinkStations = {}, LinkParts = {}, Debouncer = {}})

function LinkService:KnitInit()
    self.HintService = Knit.GetService("HintService")
    
    Players.PlayerRemoving:Connect(function(player: Player)
        if self.LinkedPlayers[player] then 
            self:UnlinkPlayer(player, true)
        end
    end)

    self.ObbyService = Knit.GetService("ObbyService")
end


function LinkService:UnlinkPlayer(player: Player)
    local linkedWith = self.LinkedPlayers[player]
    self.LinkedPlayers[player] = nil

    player:SetAttribute("Animal", nil)

    self.Client.LinkDestroyed:Fire(player, true)
    if linkedWith.Parent == Players then 
        self:UnlinkPlayer(linkedWith)        
    end
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then 
        leaderstats.Stage.Value = 0 
    end
    
    player:LoadCharacter()
end

function LinkService:MakePlayerAnimal(player: Player)
    --this code needs to be elsewhere
    local character = player.Character 
    if not character then 
        return 
    end
    character:Destroy()

    local cat = ReplicatedStorage.Assets.CatTemplate:Clone() 
    cat.Parent = workspace
    player.Character = cat
    character = cat 
    self.Client.SendCat:Fire(player, cat)

--[[
    character["Right Arm"].CanCollide = false
    character["Right Arm"].CanQuery = false
    character["Right Arm"].CanTouch = false
    character["Right Arm"].Massless = true

    character["Left Arm"].CanCollide = false
    character["Left Arm"].CanQuery = false
    character["Left Arm"].CanTouch = false
    character["Left Arm"].Massless = true
]]
    character.Humanoid.Died:Connect(function() 
        local linkedWith1 = self.LinkedPlayers[player]
        if linkedWith1 then 
            self.Client.LinkDestroyed:Fire(linkedWith1)
        end
    end)

    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 1

    local animal = player:GetAttribute("Animal")
    if animal == "Cat" then 
        character.Humanoid.WalkSpeed = 15
        character.Humanoid.JumpHeight = 10
        highlight.OutlineColor = Color3.fromRGB(255, 52, 52)
    elseif animal == "Mouse" then 
        character.Humanoid.WalkSpeed = 17
        character.Humanoid.JumpHeight = 7
        highlight.OutlineColor = Color3.fromRGB(0, 98, 255)
    end

    highlight.Parent = character
    character:SetAttribute("Animal", animal)

    for _, x in character:GetDescendants() do 
        if x:IsA("BasePart") then 
            x.CollisionGroup = "Players"
        end
    end
    return player.Character
end



function LinkService:KnitStart()
    for _, linkStationModel in CollectionService:GetTagged('LinkStation') do 
        local station = LinkStation.new(linkStationModel)
        self.LinkStations[station] = true 
    end

    RunService.Heartbeat:Connect(function() 
        for station, _ in self.LinkStations do 
            station:Update()
        end

        --[[
        for linkPart, players in self.LinkParts do 
            if players.PlayerA.Parent == nil or players.PlayerB.Parent == nil then 
                linkPart:Destroy() 
                self.LinkParts[linkPart] = nil 
                continue 
            end 

            local characterA, characterB = GetSafeCharacter(players.PlayerA), GetSafeCharacter(players.PlayerB)
            if (not characterA) or (not characterB) then 
                continue 
            end

            local p = (characterA.Head.Position+characterB.Head.Position)/2
            linkPart.Position = p 
        end]]
    end)
end

function LinkService:AttemptLink(playerA: Player, playerB: Player)
    if self.LinkedPlayers[playerA] or self.LinkedPlayers[playerB] then 
        return 
    end
    
    local characterA = GetSafeCharacter(playerA)
    local characterB = GetSafeCharacter(playerB)
    if not (characterA and characterB) then 
        return 
    end

    self.LinkedPlayers[playerA] = playerB
    self.LinkedPlayers[playerB] = playerA

    playerA.leaderstats.Stage.Value = 1
    playerB.leaderstats.Stage.Value = 1

    self.Client.SetPartner:Fire(playerA, playerB.Name)
    self.Client.SetPartner:Fire(playerB, playerA.Name)

    playerA:SetAttribute("Animal", "Mouse")
    playerB:SetAttribute("Animal", "Cat")

    if TEST_CONFIGS.Is("TEST_STAGE") then 
        playerA.leaderstats.Stage.Value = TEST_CONFIGS.TEST_STAGE
        playerB.leaderstats.Stage.Value = TEST_CONFIGS.TEST_STAGE

        self.ObbyService:SpawnPlayersCouple(playerA)
        return
    end 
    
    AnalyticsService:LogOnboardingFunnelStepEvent(
        playerA,
        2, -- Step number
        "Player Linked" -- Step name
    )
    AnalyticsService:LogOnboardingFunnelStepEvent(
        playerB,
        2, -- Step number
        "Player Linked" -- Step name
    )

    self.ObbyService:SpawnPlayersCouple(playerA)
end


return LinkService