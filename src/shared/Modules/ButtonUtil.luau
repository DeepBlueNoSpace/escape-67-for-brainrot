local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

--local CLICK_SFX = ReplicatedStorage.Assets.Audio.UI.Roblox_UI_Bright_Click
local CLICK_SFX = ReplicatedStorage.Assets.Sound.Click

local Knit = require(ReplicatedStorage.Packages.Knit)

local Trove = require(Knit.Packages.Trove)

local ButtonUtil = {}

function ButtonUtil.HookHover(frame, enterCallback, exitCallback)
	local trove = Trove.new()

	trove:Add(frame.MouseEnter:Connect(function()
		enterCallback()
	end))

	trove:Add(frame.MouseLeave:Connect(function()
		exitCallback()
	end))

	return trove
end

function ButtonUtil.HookClickSFX(button)
	local trove = Trove.new()

	trove:Add(button.Activated:Connect(function()
		SoundService:PlayLocalSound(CLICK_SFX)
	end))

	return trove
end

-- pulse when hovering
-- sfx on click
function ButtonUtil.InitStandardInteraction(button, scaleAmount)
	local trove = Trove.new()
	-- NIC HOPE YOU ARE HAPPY

    local defSize = button.Size
	scaleAmount = scaleAmount or 0.03

    
	trove:Add(ButtonUtil.HookHover(button, function()
		TweenService:Create(button, TweenInfo.new(0.15), { Size = UDim2.new(defSize.X.Scale + scaleAmount, 0, defSize.Y.Scale + scaleAmount, 0) }):Play()
	end, function()
		TweenService:Create(button, TweenInfo.new(0.15), { Size = UDim2.new(defSize.X.Scale, 0, defSize.Y.Scale, 0) }):Play()
	end))

	trove:Add(ButtonUtil.HookClickSFX(button))

	return trove
end

return ButtonUtil
