local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local MarketplaceService = game:GetService("MarketplaceService")

local Player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local Products = require(ReplicatedStorage.Shared.Data.Products)
local ProductUtil = require(ReplicatedStorage.Shared.Modules.ProductUtil)
local ButtonUtil = require(ReplicatedStorage.Shared.Modules.ButtonUtil)

local TrollFrameController = Knit.CreateController({ Name = "TrollFrameController", IsOpen = false})

function TrollFrameController:KnitInit() 
   self.UIController = Knit.GetController("UIController")
end

function TrollFrameController:KnitStart() 
    self.Frame = self.UIController.MainGui:WaitForChild("TrollFrame")
    self.Button = self.UIController.MainGui:WaitForChild("Trolls")
    self.TrollOptions = self.UIController.MainGui:WaitForChild("TrollOptions")

    self.PoopExplosionButton = self.UIController.MainGui:WaitForChild("PoopExplosion")
    self.PoopExplosionButton.Activated:Connect(function()
        ProductUtil.PromptPurchase(Player, "Poop Explosion")
    end)
    ButtonUtil.InitStandardInteraction(self.PoopExplosionButton)

    self.OpenTween = self.UIController:GenerateOpenAnimation(self.Frame)
	self.CloseTween = self.UIController:GenerateCloseAnimation(self.Frame)

    self.CloseTween:Play() -- puts it in the correct position
    
	self.CloseTween.Completed:Connect(function()
		self.Frame.Visible = false
	end)

    self.Button.MouseButton1Click:Connect(function() 
        if self.IsOpen then 
            self.UIController:AttemptCloseController(self)
        else
            self.UIController:AttemptOpenController(self)
        end
    end)

        
    local closeButton = self.Frame:WaitForChild("Close")
    closeButton.MouseButton1Click:Connect(function() 
        if self.IsOpen then 
            self.UIController:AttemptCloseController(self)
        end
    end)
    
    ButtonUtil.InitStandardInteraction(closeButton)
    ButtonUtil.InitStandardInteraction(self.Button)

    local options = self.Frame:WaitForChild("Options")
    self:HandleTrollBuyButton(options:WaitForChild("Explode"), "Explode All")
    self:HandleTrollBuyButton(options:WaitForChild("Fling"), "Fling All")
    self:HandleTrollBuyButton(options:WaitForChild("Jumpscare"), "Jumpscare All")

    self:HandleTrollOptionMenuButton(self.TrollOptions:WaitForChild("Explode"), "Explode All")
    self:HandleTrollOptionMenuButton(self.TrollOptions:WaitForChild("Fling"), "Fling All")
    self:HandleTrollOptionMenuButton(self.TrollOptions:WaitForChild("Jumpscare"), "Jumpscare All")
end

function TrollFrameController:HandleTrollOptionMenuButton(button: ImageButton, productName: string) 
    ButtonUtil.InitStandardInteraction(button)
    button.MouseButton1Click:Connect(function() 
        ProductUtil.PromptPurchase(Player, productName)
    end)
end

function TrollFrameController:HandleTrollBuyButton(frame: Frame, productName: string)
    local button = frame:WaitForChild("Buy")
    ProductUtil.WriteProductPriceToLabel(button:WaitForChild("Label"), productName)
    ButtonUtil.InitStandardInteraction(button)

    button.MouseButton1Click:Connect(function() 
        ProductUtil.PromptPurchase(Player, productName)
        self.UIController:AttemptCloseController(self)
    end)
end

function TrollFrameController:Open() 
    SoundService:PlayLocalSound(ReplicatedStorage.Assets.Sound.FrameIn)

    self.Frame.Visible = true
    self.OpenTween:Play()
    self.IsOpen = true 
end

function TrollFrameController:Close() 
    SoundService:PlayLocalSound(ReplicatedStorage.Assets.Sound.FrameOut)

    self.CloseTween:Play()
    self.IsOpen = false 
end



return TrollFrameController