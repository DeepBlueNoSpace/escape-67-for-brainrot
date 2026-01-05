local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local ButtonUtil = require(ReplicatedStorage.Shared.Modules.ButtonUtil)

local PartnerLeftController = Knit.CreateController({ Name = "PartnerLeftController", IsOpen = false})
local SoundService = game:GetService("SoundService")

function PartnerLeftController:KnitInit() 
    self.UIController = Knit.GetController("UIController")
    self.LinkService = Knit.GetService("LinkService")
    self.ObbyService = Knit.GetService("ObbyService")
end

function PartnerLeftController:KnitStart() 
    self.Frame = self.UIController.MainGui:WaitForChild("PartnerLeft")
    self.Button = self.Frame:WaitForChild("Button")

    self.Button.MouseButton1Click:Connect(function() 
        if self.IsOpen then 
            self.UIController:AttemptCloseController(self)
        end
    end)
    
    ButtonUtil.InitStandardInteraction(self.Button)

    self.OpenTween = self.UIController:GenerateOpenAnimation(self.Frame)
	self.CloseTween = self.UIController:GenerateCloseAnimation(self.Frame)

    self.CloseTween:Play() -- puts it in the correct position
    
	self.CloseTween.Completed:Connect(function()
        self.ObbyService.RequestRespawn:Fire()
		self.Frame.Visible = false
	end)

    self.LinkService.LinkDestroyed:Connect(function(partnerLeft: boolean) 
        if not partnerLeft then 
            return 
        end

        self.UIController:AttemptOpenController(self)
    end)
end


function PartnerLeftController:Open() 
    SoundService:PlayLocalSound(ReplicatedStorage.Assets.Sound.FrameIn)

    self.Frame.Visible = true
    self.OpenTween:Play()
    self.IsOpen = true 
end

function PartnerLeftController:Close() 
    SoundService:PlayLocalSound(ReplicatedStorage.Assets.Sound.FrameOut)

    self.CloseTween:Play()
    self.IsOpen = false 
end



return PartnerLeftController
