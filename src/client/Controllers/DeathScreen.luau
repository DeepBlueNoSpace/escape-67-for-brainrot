local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local Player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local ProductUtil = require(ReplicatedStorage.Shared.Modules.ProductUtil)
local GetSafeCharacter = require(ReplicatedStorage.Shared.Modules.GetSafeCharacter)

local DeathScreenController = Knit.CreateController({ Name = "DeathScreenController"})

function DeathScreenController:KnitInit() 
    self.ObbyService = Knit.GetService("ObbyService")
    self.UIController = Knit.GetController("UIController")
end

local cantPressRespawn = true 

function DeathScreenController:KnitStart()
    self.DeathFrame = self.UIController.MainGui:WaitForChild("Death")

    --Listen to deaths
    local currentCharacter = Player.Character 
    if currentCharacter then 
        local humanoid = currentCharacter:FindFirstChild("Humanoid") 
        if humanoid then 
            humanoid.Died:Connect(function() 
                self:ShowDeathScreen()
            end)
        end
    end

    Player.CharacterAdded:Connect(function(character: Model)
        self.DeathFrame.Visible = false

        local humanoid = character:WaitForChild("Humanoid") :: Humanoid
        humanoid.Died:Connect(function() 
            self:ShowDeathScreen()
        end)
    end)

    self.DeathFrame:WaitForChild("Respawn").MouseButton1Click:Connect(function() 
        if cantPressRespawn then 
            ProductUtil.PromptPurchase(Player, "Skip")
            return 
        end

        self.ObbyService.RequestRespawn:Fire()
    end)

    self.DeathFrame:WaitForChild("Skip").MouseButton1Click:Connect(function() 
        ProductUtil.PromptPurchase(Player, "Skip")
    end)

    self.RespawnButton = self.DeathFrame:WaitForChild("Respawn")
end

function DeathScreenController:ShowDeathScreen()
    local character = Player.Character
    if not character then 
        self.ObbyService.RequestRespawn:Fire()
        return
    end

    if character:GetAttribute("Animal") then 
        self.DeathFrame.Visible = true
        cantPressRespawn = true 

        self.RespawnButton:WaitForChild("Label").Text = "RETRY"

        cantPressRespawn = false 

        self.RespawnButton.BackgroundColor3 = Color3.fromRGB(0, 224, 255)
    else 

        self.ObbyService.RequestRespawn:Fire()
    end
end

return DeathScreenController