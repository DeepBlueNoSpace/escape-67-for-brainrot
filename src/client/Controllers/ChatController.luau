local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local ChatController = Knit.CreateController({ Name = "ChatController"})

function ChatController:KnitInit() 
    self.ChatService = Knit.GetService("ChatService")
end

function ChatController:KnitStart() 
    self.ChatService.BroadcastMessage:Connect(function(message)
        TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(message)
    end)
end

return ChatController

