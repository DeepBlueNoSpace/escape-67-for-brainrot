local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local BaseService = Knit.CreateService({Name = "BaseService", PlayerBases = {}, Plots = {},
    Client = {}})

local Base = require(script.Base)

function BaseService:KnitInit()
    self.DataService = Knit.GetService("DataService")
end

function BaseService:KnitStart()
    --init plots 
    for _, plotPart in workspace.Plots:GetChildren() do 
        local base = Base.new(plotPart)
        self.Plots[plotPart] = base
    end

    self.DataService.SaveReplicaCreated:Connect(function(player, replica)
        --find free base 
         self:GivePlayerBase(player, replica)
   
    end)
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character: Model)
            local playerBase = self.PlayerBases[player]
            character:MoveTo(playerBase.Model:GetPivot().Position)
        end)
    end)

    task.spawn(function()        
        while true do 
            for _, base in self.PlayerBases do 
                base:TickMoney()
            end
            task.wait(1)
        end
    end)


end


function BaseService:GivePlayerBase(player: Player, replica)
    for _, base in self.Plots do 
        if base.Owner == nil then 
            base:SetOwner(player, replica)
            self.PlayerBases[player] = base
            return 
        end
    end
end



return BaseService
