local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local WalkSpeedData = require(ReplicatedStorage.Shared.Data.WalkSpeedData)

local SpeedShopController = Knit.CreateController({ Name = "SpeedShopController", IsOpen = false})

local DEFAULT_WALK_SPEED = game.StarterPlayer.CharacterWalkSpeed


function SpeedShopController:KnitInit() 
   self.UIController = Knit.GetController("UIController")
   self.WalkSpeedService = Knit.GetService("WalkSpeedService")
   self.DataController = Knit.GetController("DataController")
end

function SpeedShopController:KnitStart() 
   self.Frame = self.UIController.MainGui:WaitForChild("SpeedShop")

   self.OpenTween = self.UIController:GenerateOpenAnimation(self.Frame)
	self.CloseTween = self.UIController:GenerateCloseAnimation(self.Frame)

   self.CloseTween:Play() -- puts it in the correct position
    
	self.CloseTween.Completed:Connect(function()
		self.Frame.Visible = false
	end)

   local shopPart = workspace:WaitForChild("Shops"):WaitForChild("Speed")
   self.UIController:InitProximityOpening(self, shopPart)

   local optionsFrame = self.Frame:WaitForChild("Options")
   

   local currentSpeedLabel = self.Frame:WaitForChild("CurrentSpeed")
   self.DataController:GetReplicaPromise(Players.LocalPlayer):andThen(function(replica)
      currentSpeedLabel.Text = string.format("Speed: %s", DEFAULT_WALK_SPEED+replica.Data.WalkSpeedUpgrades)

      replica:ListenToChange("WalkSpeedUpgrades", function()
         currentSpeedLabel.Text = string.format("Speed: %s", DEFAULT_WALK_SPEED+replica.Data.WalkSpeedUpgrades)
      end)

      self:HandleOptionsFrame(optionsFrame:WaitForChild("1"), 1, replica)
      self:HandleOptionsFrame(optionsFrame:WaitForChild("5"), 5, replica)
      self:HandleOptionsFrame(optionsFrame:WaitForChild("10"), 10, replica)
   end)
end

function SpeedShopController:HandleOptionsFrame(frame: Frame, upgrades: number, replica)
   local buyButton = frame:WaitForChild("Buy")
   local priceLabel = buyButton:WaitForChild("Label")

   buyButton.MouseButton1Click:Connect(function() 
      self.WalkSpeedService.RequestWalkSpeedUpgrade:Fire(upgrades)
   end)

   local function updatePrice()
      priceLabel.Text = string.format("$%s", WalkSpeedData.CalculatePriceForUpgrades(replica.Data.WalkSpeedUpgrades, upgrades))
   end
   updatePrice()  

   replica:ListenToChange("WalkSpeedUpgrades", updatePrice)
end


function SpeedShopController:Open() 
   -- SoundService:PlayLocalSound(ReplicatedStorage.Assets.Sound.FrameIn)

    self.Frame.Visible = true
    self.OpenTween:Play()
    self.IsOpen = true 
end

function SpeedShopController:Close() 
    --SoundService:PlayLocalSound(ReplicatedStorage.Assets.Sound.FrameOut)

    self.CloseTween:Play()
    self.IsOpen = false 
end




return SpeedShopController