local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local PositionModelByRoot = require(ReplicatedStorage.Shared.Modules.PositionModelByRoot)
local BrainrotCaptureService = Knit.CreateService({Name = "BrainrotCaptureService", 
    Client = {}, LiveBrainrots = {}, BrainrotsByRarity = {}})


function BrainrotCaptureService:KnitInit()
    self.BaseService = Knit.GetService("BaseService")
end

function BrainrotCaptureService:KnitStart()
    self:SortBrainrotsByRarity()

    local spawnsFolder = workspace.BrainrotSpawns:GetChildren() 

    for _, spawnPart in spawnsFolder do 
        self:SpawnBrainrot(spawnPart)
    end

    Players.PlayerAdded:Connect(function(player) 
        local stolenBrainrotValue = Instance.new("ObjectValue")
        stolenBrainrotValue.Parent = player 
        stolenBrainrotValue.Name = "StolenBrainrot"

        player.CharacterAdded:Connect(function(character) 
            character.Humanoid.Died:Connect(function()
                if stolenBrainrotValue.Value then 
                    stolenBrainrotValue.Value:Destroy()
                    stolenBrainrotValue.Value = nil 
                end
            end)
        end)
    end)
end

function BrainrotCaptureService:ListenToBrainrotSteal(brainrot: Model, callback:(Player)->nil)
    local proximityPrompt = Instance.new("ProximityPrompt")
    proximityPrompt.ActionText = "Steal Brainrot"
    proximityPrompt.RequiresLineOfSight = false
    proximityPrompt.Parent = brainrot

    local conn
    conn = proximityPrompt.Triggered:Connect(function(player: Player)
        if player.StolenBrainrot.Value then 
            return 
        end

        conn:Disconnect()
        conn = nil 
        proximityPrompt:Destroy()

        callback(player)
    end)
end

local OFFSET_RADIUS = 7

function BrainrotCaptureService:SpawnBrainrot(spawnPart: BasePart)
    local rarity = tonumber(spawnPart.Name)

    local selectedBrainrot = self.BrainrotsByRarity[rarity][math.random(1, #self.BrainrotsByRarity[rarity])]:Clone()
    selectedBrainrot.RootPart.CanCollide = true
    selectedBrainrot.RootPart.Anchored = true

    local basePositionCFrame = PositionModelByRoot(selectedBrainrot, spawnPart)
    local offsetAngle = math.random() * math.pi * 2 
    local offsetDistance = OFFSET_RADIUS*math.random()
    selectedBrainrot:PivotTo(basePositionCFrame
        *CFrame.new(Vector3.new(math.sin(offsetAngle)*offsetDistance, 0, math.cos(offsetAngle)*offsetDistance))
        *CFrame.Angles(0,math.random()*math.pi*2,0))


    local billboardGui = ReplicatedStorage.Assets.NameBillboard:Clone()
    billboardGui.Frame.Earnings.Text = string.format("+$%s/s", tostring(selectedBrainrot:GetAttribute("BaseEarnings")))
    billboardGui.Frame.NameLabel.Text = selectedBrainrot.Name 
    billboardGui.Parent = selectedBrainrot.NameBillboardPart

    selectedBrainrot.Parent = workspace

    self:ListenToBrainrotSteal(selectedBrainrot, function(player: Player)
        self:BrainrotStolen(player, selectedBrainrot)

        task.wait(10)
        self:SpawnBrainrot(spawnPart)
    end)
end

function BrainrotCaptureService:BrainrotStolen(player: Player, brainrot: Model)
    local character = player.Character
    if not character then
        warn("Need an edge case here!")
        return 
    end

    for _, object in brainrot:GetDescendants()do 
        if object:IsA("BasePart") then 
            object.CanCollide = false 
            object.Anchored = false
            object.Massless = true 
        end
    end

    local motor6D = Instance.new("Motor6D")
    motor6D.Name = "Motor6D"
    motor6D.Part0 = character.HumanoidRootPart
    motor6D.Part1 = brainrot.PrimaryPart
    motor6D.C0 = CFrame.new()
    motor6D.C1 = CFrame.new(Vector3.new(0,-7,0))
    motor6D.Parent = brainrot.PrimaryPart

    player.StolenBrainrot.Value = brainrot
    
    local playerBase = self.BaseService.PlayerBases[player]
    if not playerBase then 
        warn("This is bad")
        return 
    end

    playerBase:BrainrotStolen() 
end


function BrainrotCaptureService:SortBrainrotsByRarity()
    local brainrotPrefabs = ReplicatedStorage.Assets.Brainrots:GetChildren() 

    for _, brainrot in brainrotPrefabs do 
        local rarity = brainrot:GetAttribute("Rarity")
        if self.BrainrotsByRarity[rarity] then 
            table.insert(self.BrainrotsByRarity[rarity], brainrot)
        else
            self.BrainrotsByRarity[rarity] = {brainrot}
        end
    end
end

return BrainrotCaptureService