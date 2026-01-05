local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local UIController = Knit.CreateController({ Name = "UIController", OpenController = nil,
	DefaultOpenPosition = UDim2.fromScale(0.5, 0.5) :: UDim2,
	DefaultClosePosition = UDim2.fromScale(0.5, -0.5) :: UDim2,})

function UIController:KnitInit() 
    self.PlayerGui = Player:WaitForChild("PlayerGui")
    self.MainGui = self.PlayerGui:WaitForChild("Main")
end

function UIController:AttemptOpenController(controller) 
    if self.OpenController then 
        if self.OpenController.BlockClose then 
            return false
        end

        self.OpenController:Close()
        self.OpenController = nil 
    end

    controller:Open()
    self.OpenController = controller

    return true
end


function UIController:AttemptCloseController(controller) 
    controller:Close()
    if self.OpenController == controller then 
        self.OpenController = nil
    end
    
    return true
end

function UIController:GenerateOpenAnimation(frame: Frame, overrideOpenPosition: UDim2?): Tween
	local tweenInfo = TweenInfo.new(0.23, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local openTween = TweenService:Create(frame, tweenInfo, { ["Position"] = overrideOpenPosition or self.DefaultOpenPosition })

	return openTween
end

function UIController:GenerateCloseAnimation(frame: Frame): Tween
	local tweenInfo = TweenInfo.new(0.23, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	local closeTween = TweenService:Create(frame, tweenInfo, { ["Position"] = self.DefaultClosePosition })

	return closeTween
end


return UIController