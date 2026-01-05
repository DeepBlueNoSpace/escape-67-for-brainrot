local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local ChatService = Knit.CreateService({Name = "ChatService", Client = {BroadcastMessage = Knit.CreateSignal()}})

function ChatService:KnitInit()

end

function ChatService:KnitStart()

end

function ChatService:MessageClients(message: string, clients: {Player})
    for _, client in clients do 
        self:MessageClient(message, client)
    end
end
function ChatService:MessageClient(message: string, client: Player)
    self.Client.BroadcastMessage:Fire(client, message)
end

return ChatService
