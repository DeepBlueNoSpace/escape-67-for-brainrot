local ReplicatedStorage = game.ReplicatedStorage
local PositionModelByRoot = require(ReplicatedStorage.Shared.Modules.PositionModelByRoot)

local Base = {}
Base.__index = Base

function Base.new(plotRoot: BasePart)
    local self = setmetatable({}, Base)
    self.Owner = nil
    self.OwnerReplica = nil 
    local baseModel = ReplicatedStorage.Assets.BasePrefab:Clone()
    baseModel:PivotTo(plotRoot.CFrame)
    baseModel.Parent = workspace 

    self.Model = baseModel
    self.BrainrotSlots = {}
    self.BrainrotSlotsFolder = self.Model.BrainrotSlots 

    return self 
end

function Base:SetOwner(player: Player, ownerReplica)
    self.Owner = player 
    self.OwnerReplica = ownerReplica

    self:SetUpSlots()

    local character = player.Character
    if character then 
        character:PivotTo(self.Model.BasePart.CFrame)
    end
end

function Base:BrainrotStolen() 
    for _, slotData in self.BrainrotSlots do 
        if slotData.Occupied then 
            return 
        end

        slotData.ProximityPrompt.Enabled = true 
        slotData.ProximityPrompt.ActionText = "Place Brainrot?"
    end
end

function Base:BrainrotCaptured() 
    --called when a captured brainrot has been retrived
    for _, slot in self.BrainrotSlots do 
        if slot.Occupied then 
            continue 
        end

        slot.ProximityPrompt.Enabled = false
    end
end

function Base:TickMoney() 
    for _, slotData in self.BrainrotSlots do 
        if slotData.Occupied == false then 
            continue 
        end
        local moneyToAdd = slotData.BrainrotModel:GetAttribute("BaseEarnings")
        slotData.SetMoney(slotData.EarnedCurrency + moneyToAdd)
    end
end

local SELL_MULT = 30 -- gives x seconds worth of earnings

function Base:SetUpSlots() 
    for _, slot in pairs(self.BrainrotSlotsFolder:GetChildren()) do 
        local proximityPrompt = Instance.new("ProximityPrompt")
        proximityPrompt.Enabled = false 
        proximityPrompt.RequiresLineOfSight = false
        proximityPrompt.Parent = slot 

        local slotData =  {
            Occupied = false,
            EarnedCurrency = 0,
            BrainrotUpgrades = 0,
            BrainrotModel = nil,
            ProximityPrompt = proximityPrompt,
        }

        local cashPart = slot.CashPart 
        local function SetMoney(money: number)
            slotData.EarnedCurrency = money 
            cashPart.SurfaceGui.TextLabel.Text = string.format("$%s", tostring(money))
        end

        slotData.SetMoney = SetMoney

        self.BrainrotSlots[slot] = slotData

        local function FillSlot(brainrot)
            slotData.Occupied = true 
            slotData.BrainrotModel = brainrot

            brainrot.PrimaryPart.Anchored = true 
            brainrot.PrimaryPart.Transparency = 0 
            brainrot.PrimaryPart.Material = Enum.Material.Neon
            brainrot.PrimaryPart.Motor6D:Destroy()
            brainrot:PivotTo(PositionModelByRoot(brainrot, slot.PrimaryPart))

            proximityPrompt.ActionText = "Sell Brainrot?"
            self:BrainrotCaptured()
        end

        local function AttemptSell()
            local value = slotData.BrainrotModel:GetAttribute("BaseEarnings") * SELL_MULT 
            self.OwnerReplica:SetValue("Cash", self.OwnerReplica.Data.Cash + value)
            
            slotData.BrainrotModel:Destroy()
            slotData.BrainrotModel = nil 
            slotData.Occupied = false

            slotData.ProximityPrompt.Enabled = false
        end

        proximityPrompt.Triggered:Connect(function(Player)
            if not(Player == self.Owner) then 
                return 
            end

            if slotData.Occupied then 
                -- they're trying to sell the brainrot 
                AttemptSell()
                return 
            end

            -- they're trying to place a brainrot here
            local brainrot = Player.StolenBrainrot.Value 
            if not brainrot then 
                return 
            end

            FillSlot(brainrot)
            Player.StolenBrainrot.Value = nil
        end)

        cashPart.Touched:Connect(function(touchPart: Part)
            local character = self.Owner.Character
            if not character then 
                return 
            end

            if not touchPart:IsDescendantOf(character) then 
                return 
            end

            self.OwnerReplica:SetValue("Cash", self.OwnerReplica.Data.Cash + slotData.EarnedCurrency)
            slotData.SetMoney(0)
        end)
    end
end

return Base