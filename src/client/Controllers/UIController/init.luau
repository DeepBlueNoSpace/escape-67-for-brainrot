local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local GetSafeCharacter = require(ReplicatedStorage.Shared.Modules.GetSafeCharacter)

local UIController = Knit.CreateController({ Name = "UIController", OpenController = nil,
	DefaultOpenPosition = UDim2.fromScale(0.5, 0.5) :: UDim2,
	DefaultClosePosition = UDim2.fromScale(0.5, -0.5) :: UDim2,})

function UIController:KnitInit() 
    self.PlayerGui = Player:WaitForChild("PlayerGui")
    self.MainGui = self.PlayerGui:WaitForChild("Main")
    self.DataController = Knit.GetController("DataController")
end

function UIController:KnitStart() 
    local cashLabel = self.MainGui:WaitForChild("Cash")
    self.DataController:GetReplicaPromise(Player):andThen(function(replica)
        cashLabel.Text = string.format("$%s", replica.Data.Cash) 
        replica:ListenToChange("Cash", function()
            cashLabel.Text = string.format("$%s", replica.Data.Cash) 
        end)
    end)
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
    if controller.IsOpen == false then 
        return 
    end

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

local CLOSE_OFFSET = 2

function UIController:InitProximityOpening(controller, shopPart: BasePart)
    local openDistance = shopPart:GetAttribute("OpenDistance")
    local shopPosition = shopPart.Position
    local closeDistance = openDistance + CLOSE_OFFSET

    local bind
    bind = RunService.Heartbeat:Connect(function()
        local character = GetSafeCharacter()
        if not character then 
            self:AttemptCloseController(controller)
            return 
        end

        local characterPosition = character:GetPivot().Position
        local distance = (characterPosition-shopPosition).magnitude
        if controller.IsOpen and distance > closeDistance then 
            self:AttemptCloseController(controller)
        elseif controller.IsOpen == false and distance < openDistance then 
            self:AttemptOpenController(controller)
        end
    end)

    return bind
end


return UIController