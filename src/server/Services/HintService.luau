local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local HintService = Knit.CreateService({Name = "HintService", Client = {HintClient = Knit.CreateSignal()}})

function HintService:KnitInit()

end

function HintService:KnitStart()

end

function HintService:HintToClients(hintId: string, clients: {Player})
    for _, client in clients do 
        self:HintClient(hintId, client)
    end
end
function HintService:HintClient(hintId: string, client: Player)
    self.Client.HintClient:Fire(client, hintId)
end

return HintService
