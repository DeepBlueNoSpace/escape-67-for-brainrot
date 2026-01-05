local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Player = Players.LocalPlayer

local GetSafeCharacter = require(ReplicatedStorage.Shared.Modules.GetSafeCharacter)
local Knit = require(ReplicatedStorage.Packages.Knit)
local TrollController = Knit.CreateController({ Name = "TrollController"})

function TrollController:KnitInit() 
   self.TrollService = Knit.GetService("TrollService")
   self.UIController = Knit.GetController("UIController")
end

local FLING_FORCE = 30 


local function GetModelMass(model: Model): number
	local totalMass = 0
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			totalMass += part:GetMass()
		end
	end
	return totalMass
end

local function GetRandomDirection(): Vector3
    return Vector3.new(math.random()*2-1, math.random()*2-1, math.random()*2-1).Unit
end

function TrollController:JumpscareReplicate(target: Player) 
    local character = GetSafeCharacter(target)
    if not character then 
        return 
    end

    local targetP = (character:GetPivot() * CFrame.new(Vector3.new(0,5,-10))).Position
    local head = ReplicatedStorage.Assets.Face:Clone()  
    head.CFrame = CFrame.new(targetP, character:GetPivot().Position)
    head.Parent = workspace

    local s = ReplicatedStorage.Assets.Sound.Scream:Clone()
    s.Parent = head
    s.PlayOnRemove = true 
    s:Destroy() 

    local start = tick()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - start
        if elapsed > 2 then
            connection:Disconnect()
            head:Destroy()
            return
        end
        
        -- random violent offset each frame
        local offset = Vector3.new(
            math.random(-5, 5) * 0.2, 
            math.random(-5, 5) * 0.2, 
            math.random(-5, 5) * 0.2
        )
        local rotation = CFrame.Angles(
            math.rad(math.random(-15, 15)),
            math.rad(math.random(-15, 15)),
            math.rad(math.random(-15, 15))
        )
        
        head.CFrame = CFrame.new(targetP) * rotation + offset
    end)
end

function TrollController:FlingSelf() 
    local character = GetSafeCharacter(Player)
    if not character then 
        return 
    end

        local primaryPart = character.PrimaryPart
    if not primaryPart then 
        return 
    end

    local mass = GetModelMass(character)
    local force = FLING_FORCE * mass
    local direction = GetRandomDirection()
    character.PrimaryPart:ApplyImpulse(force*mass*direction)
end

function TrollController:Jumpscare() 
    local image = self.UIController.MainGui:WaitForChild("Jumpscare")
    image.Visible = true 

    SoundService:PlayLocalSound(ReplicatedStorage.Assets.Sound.Scream)

    local duration = 2.5 -- seconds
    local intensity = 0.05 -- max pixels offset from original position

    local originalPos = image.Position
    local startTime = tick()

    local connection
    connection = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        if elapsed > duration then
            connection:Disconnect()
            image.Position = originalPos
            image.Visible = false
            return
        end

        -- Random jitter
        local offsetX = math.random()*intensity
        local offsetY = math.random()*intensity
        image.Position = originalPos + UDim2.fromScale(offsetX, offsetY)
    end)

end

function TrollController:KnitStart() 
    self.TrollService.FlingClient:Connect(function()
        self:FlingSelf() 
    end)
    self.TrollService.JumpscareClient:Connect(function()
        self:Jumpscare() 
    end)
    self.TrollService.ReplicateJumpscare:Connect(function(target: Player)
        if not (target == Player) then 
            self:JumpscareReplicate(target)
        end
    end)
end

return TrollController