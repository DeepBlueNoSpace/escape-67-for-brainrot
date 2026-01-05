local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")

local Player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local FriendHarrassmentController = Knit.CreateController({ Name = "FriendHarrassmentController", ShowingPullHint = false})


function FriendHarrassmentController:KnitInit()
    self.UIController = Knit.GetController("UIController")
end

function FriendHarrassmentController:KnitStart()
    self.InviteFrame = self.UIController.MainGui:WaitForChild("InviteFrame")
    self.UIController.MainGui:WaitForChild("AddFriends").Activated:Connect(function()
        game:GetService("SocialService"):PromptGameInvite(game.Players.LocalPlayer)
    end)

    coroutine.wrap(function()
        self:Harrass()
    end)()
end


function FriendHarrassmentController:Harrass()
    local onlineFriends = Player:GetFriendsOnline()
    local bestOption, dictStatus = nil, 7
    for _, friendData in onlineFriends do 
        if friendData.LocationType > dictStatus then
            continue
        end

        dictStatus = friendData.LocationType 
        bestOption = friendData
    end

    if not bestOption then 
        --fuckin loner lollll
        return 
    end

    self.InviteFrame:WaitForChild("PlayerDisplay").Text = string.format("%s is online!", bestOption.DisplayName)
    self.InviteFrame:WaitForChild("PlayerImage").Image = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%s&width=420&height=420&format=png", bestOption.VisitorId)
    task.wait(8)

    local startPosition = self.InviteFrame.Position 

    self.InviteFrame.Position = UDim2.fromScale(0.5, 1.3)
    self.InviteFrame.Visible = true 

    self.InviteFrame:TweenPosition(startPosition,Enum.EasingDirection.Out, 
        Enum.EasingStyle.Back, 
        0.4) 

    local inviteButton = self.InviteFrame:WaitForChild("Invite")
    local closeButton = self.InviteFrame:WaitForChild("Close")

    closeButton.Activated:Connect(function()
        self.InviteFrame.Visible = false 
    end)

    inviteButton.Activated:Connect(function()
        self.InviteFrame.Visible = false 
        local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
        experienceInviteOptions.InviteMessageId = "480d9d4d-9791-344a-b932-fe2d9ba1f4af"
        experienceInviteOptions.PromptMessage = "Invite " .. bestOption.DisplayName .. "!"
        experienceInviteOptions.InviteUser =bestOption.VisitorId

        game:GetService("SocialService"):PromptGameInvite(game.Players.LocalPlayer, experienceInviteOptions)
        SocialService:PromptGameInvite(Player, experienceInviteOptions)
    end)

end

return FriendHarrassmentController
