
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local ButtonUtil = require(ReplicatedStorage.Shared.Modules.ButtonUtil)

local LinkController = Knit.CreateController({ Name = "LinkController", CurrentPartner = nil;})

function LinkController:KnitInit()
    self.LinkService = Knit.GetService("LinkService")
    self.UIController = Knit.GetController("UIController")
    self.MockAttachment = Instance.new("Attachment")
    self.MockAttachment.Parent = workspace.Terrain
end
local MAX_ROPE_LENGTH = 30
function LinkController:CleanCurrentLink()

end

local function IsNan(value)
	return type(value) == `number` and value ~= value
end

local function HyperSolver(t, d)
	local N = 1e6 
	local EAppx = (1 + 1/N) ^ N 
	local PE = EAppx ^ t 
	local PEIn = 1 / PE 
	local TCt = PE + PEIn - 2
	local TSt = t * (PE - PEIn)

	return t * (2 * TCt - TSt) / (TCt - TSt + (t * t) * d)
end

local function UnitizeDist(dist)
	local CatA = (dist < 0.1 and ((2.3e-1 * dist + 1.344e-1) * (dist ^ 1.15)) 
		or (dist < 0.9 and ((9.071e-2 + 1.462e-1 * dist - 1.962e-1 * dist * dist) * (dist / (1 - dist))) 
			or (math.exp(-1.243) * (dist * dist) / math.sqrt(1 - dist * dist))))
	
	local ApproxT, InverseSq = dist / CatA, 1 / (dist * dist)

	for _ = 1, 4 do -- 4 guess attempts should be more than enough 
		ApproxT = HyperSolver(ApproxT, InverseSq)
	end

	return dist / ApproxT
end

local function EvalCurve(x, l, a)
	return a * (math.cosh((x - l) / a) - 1)
end

local function EvalPointOnRC(ropeConstraint : RopeConstraint, alpha : number)	
	assert(ropeConstraint.Attachment0 and ropeConstraint.Attachment1, `RC Attachments not prepared for {ropeConstraint}`)

	local A0 = (ropeConstraint.Attachment0 :: Attachment).WorldCFrame
	local A1 = (ropeConstraint.Attachment1 :: Attachment).WorldCFrame
	local Length = ropeConstraint.Length

	local A0Pos = A0:ToObjectSpace(A0).Position
	local A1Pos = A0:ToObjectSpace(A1).Position
	local AVec = A1Pos - A0Pos
	
	-- welcome to where i spent a few days working on, enjoy & expect more down the line.
	-- would provide the papers i went by and desmos playgrounds to make sense of all this 
	-- but it's completely idiosyncratic in workflow, evidently...

	local D = math.sqrt(AVec.X ^ 2 + AVec.Z ^ 2)
	local H = AVec.Y
	local S = math.sqrt(Length * Length - H * H)
	local CatA  = S * UnitizeDist(D / S)
	local XL = CatA * math.log(CatA * (math.exp(D / CatA) - 1) / (H + Length))	
	local ADs = A0Pos.Y - EvalCurve(0, XL, CatA)
	local ADe = A1Pos.Y - EvalCurve(D, XL, CatA)
	local X = D * alpha
	local Y = EvalCurve(X, XL, CatA) + ADs + (ADe - ADs) * alpha
	
	local Trans = A0Pos + X * Vector3.new(AVec.X, 0, AVec.Z).Unit + Y * Vector3.yAxis
	Trans = A0:ToWorldSpace(CFrame.new(Trans))

	local IsLinear = IsNan(Trans.X) or IsNan(Trans.Y) or IsNan(Trans.Z)

	return (IsLinear and A0:Lerp(A1, alpha) or Trans).Position
end


--[[local function PositionArm(character, endP, shoulderJoint, arm, basePosition, axisFix)
    local jointWorld = character.Torso.CFrame * shoulderJoint.C0
    local jointPos = jointWorld.Position

    local aimWorld = CFrame.lookAt(jointPos, endP, Vector3.yAxis)


    local rel = character.Torso.CFrame:ToObjectSpace(aimWorld)
    local rx, ry, rz = rel:ToOrientation()
    local rotOnly = CFrame.fromOrientation(rx, ry, rz)

    local length = math.clamp((endP-jointPos).Magnitude, 0, MAX_ROPE_LENGTH)
    arm.Size = Vector3.new( arm.Size.X, length+2,  arm.Size.Z)
    shoulderJoint.C0 = CFrame.new(basePosition) * rotOnly * axisFix * CFrame.new(Vector3.new(0,-1-(length/2),0))
    shoulderJoint.C1 = CFrame.new()
end]]

local function PositionFakeArm(fakeArm, startP, endP, axisFix)
    local midPosition = (startP+endP)/2
    fakeArm.CFrame = CFrame.new(midPosition, endP)*axisFix

    local length = (endP-startP).Magnitude+0.5
    fakeArm.Size = Vector3.new(1, length,  1)
end

local rightArmDisable = 120672342280869
local leftArmDisable = 96540918570231

local rightAnimObject = Instance.new("Animation")
rightAnimObject.AnimationId = "http://www.roblox.com/asset/?id="..rightArmDisable

local leftAnimObject = Instance.new("Animation")
leftAnimObject.AnimationId = "http://www.roblox.com/asset/?id="..leftArmDisable

local function GetModelMass(model: Model): number
	local totalMass = 0
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			totalMass += part:GetMass()
		end
	end
	return totalMass
end

function LinkController:KnitStart()
    self.PullButton = self.UIController.MainGui:WaitForChild("Pull")

    self.LinkService.SendCat:Connect(function(cat: Model)
        workspace.Camera.CameraSubject = cat
    end)

    self.IsPulling = false 
    ButtonUtil.InitStandardInteraction(self.PullButton)

    self.PullButton.InputBegan:Connect(function(inputObject: InputObject) 
        if inputObject.UserInputType == Enum.UserInputType.Touch or inputObject.UserInputType == Enum.UserInputType.MouseButton1 then 
            self.Inputting = true
        end
    end)
    
    self.PullButton.InputEnded:Connect(function(inputObject: InputObject) 
        if inputObject.UserInputType == Enum.UserInputType.MouseMovement then 
            return 
        end

        if inputObject.UserInputType == Enum.UserInputType.Touch or inputObject.UserInputType == Enum.UserInputType.MouseButton1 then 
            self.Inputting = false
        end
    end)

    local linkBind = nil
    self.LinkService.StartLink:Connect(function(targetCharacter: Model, isRight: boolean)
        task.wait(0.5)

        if true then 
            return 
        end

        local targetAttachment = targetCharacter:WaitForChild("Torso"):WaitForChild("RightCollarAttachment")
        local ownAttachment = Instance.new("Attachment")
        ownAttachment.Parent = Player.Character.HumanoidRootPart

        local force = Instance.new("VectorForce")
        force.Force = Vector3.new(0,200*GetModelMass(Player.Character),0)
        force.Parent = ownAttachment
        force.Attachment0 = ownAttachment
        force.Enabled = false

        local leftChar, rightChar = targetCharacter, Player.Character
        if isRight then 
            leftChar, rightChar = Player.Character, targetCharacter
            local leftAnim = Player.Character.Humanoid:LoadAnimation(leftAnimObject)
            leftAnim:Play()
        else
            local rightAnim = Player.Character.Humanoid:LoadAnimation(rightAnimObject)
            rightAnim:Play()
            
        end

        local fakeAttachment = Instance.new("Attachment")
        fakeAttachment.Parent = workspace.Terrain 

        local leftTorso = leftChar.Torso

        local p = Instance.new("Part")
        p.Size = Vector3.new(1,1,1)
        p.CanCollide = false 
        p.Anchored = false 
        
        local tA = Instance.new("Attachment")
        tA.Parent = p 
        p.Anchored = false
        p.Parent = workspace
        p.CFrame = targetAttachment.WorldCFrame
        p.Transparency = 1 

        local rope = Instance.new("RopeConstraint")
        rope.Attachment0 = ownAttachment
        rope.Parent = targetCharacter
        rope.Length = MAX_ROPE_LENGTH 
        rope.Visible = false
        rope. WinchForce = 3000000
        rope.WinchSpeed = 10
        rope.WinchTarget = 0

        
        local leftShoulder = leftTorso["Left Shoulder"]
        local leftArm = leftChar["Left Arm"]

        leftShoulder:Destroy()
    
        local leftBaseC0  = leftShoulder.C0        
        local leftBasePos = leftBaseC0.Position

        local rightShoulder = rightChar.Torso["Right Shoulder"]
                rightShoulder:Destroy()

        local rightArm = rightChar["Right Arm"]

        local rightBaseC0 = rightShoulder.C0
        local rightBasePos = rightBaseC0.Position

        local axisFix = CFrame.Angles(math.rad(90), 0, 0)

        targetCharacter.Humanoid.Died:Connect(function()
            if linkBind then 
                linkBind:Disconnect()
                linkBind = nil
            end
        end)

        Player.Character.Humanoid.Died:Connect(function()
            if linkBind then 
                linkBind:Disconnect()
                linkBind = nil
            end
        end)

        if linkBind then 
            linkBind:Disconnect()
            linkBind = nil
        end

        local fakeLeftArm = Instance.new("Part") --lleftChar["Left Arm"]:Clone()
        fakeLeftArm.CanCollide = false 
        fakeLeftArm.CanQuery = false 
        fakeLeftArm.Anchored = true
        fakeLeftArm.Parent = workspace
        fakeLeftArm.Size = leftChar["Left Arm"].Size 
        fakeLeftArm.Color = leftChar["Left Arm"].Color
        leftChar["Left Arm"].Transparency = 0

        local fakeRightArm = Instance.new("Part") --leftChar["Right Arm"]:Clone()
        fakeRightArm.CanCollide = false 
        fakeRightArm.CanQuery = false 
        fakeRightArm.Parent = workspace
        fakeRightArm.Size = rightChar["Right Arm"].Size 
        fakeRightArm.Color = rightChar["Right Arm"].Color
        fakeRightArm.Anchored = true
        rightChar["Right Arm"].Transparency = 0

      --  leftChar["Left Arm"].Transparency = 1 
      --  rightChar["Right Arm"].Transparency = 1 

        local firstRun = true 
        local target = nil 
        linkBind = RunService.RenderStepped:Connect(function()
            if isRight then 
                self.MockAttachment.WorldPosition = targetCharacter.Torso.LeftCollarAttachment.WorldPosition
            else
                self.MockAttachment.WorldPosition = targetCharacter.Torso.RightCollarAttachment.WorldPosition
            end

            
            if firstRun then 
                firstRun = false
                rope.Attachment1 = self.MockAttachment
                return 
            end

            local endP = EvalPointOnRC(rope, 0.5)
            if target then 
                target = target:lerp(endP,0.3)
            else
                target = endP
            end

            
        
            local minYHeight = math.min(leftChar.Torso.LeftCollarAttachment.WorldPosition.Y, rightChar.Torso.RightCollarAttachment.WorldPosition.Y)-3
            local finalYHeight = math.max(target.Y, minYHeight)
            target = Vector3.new(target.X, finalYHeight, target.Z)

            local distance = (leftChar.Torso.LeftCollarAttachment.WorldPosition
                -rightChar.Torso.RightCollarAttachment.WorldPosition).Magnitude+2
            rope.Length = math.clamp(distance+2, 2, MAX_ROPE_LENGTH)

            PositionFakeArm(leftChar['Left Arm'], leftChar.Torso.LeftCollarAttachment.WorldPosition, target, axisFix)
            PositionFakeArm(rightChar['Right Arm'], rightChar.Torso.RightCollarAttachment.WorldPosition, target, axisFix)

            if UserInputService:IsKeyDown(Enum.KeyCode.T) or self.Inputting then 
                if self.MockAttachment.WorldPosition.Y > ownAttachment.WorldPosition.Y  then 
                    force.Enabled = true
                else 
                    force.Enabled = false
                end
               rope.WinchEnabled = true
            else
                force.Enabled = false
                rope.WinchEnabled = false
            end
        end)
    end)

    self.LinkService.LinkDestroyed:Connect(function() 
        self:CleanCurrentLink()
        if linkBind then 
            linkBind:Disconnect()
            linkBind = nil 
        end
    end)

    self.LinkService.SetPartner:Connect(function(partnerName: string?)
        Knit.GetController("UIController").MainGui:WaitForChild("ExitStation").Visible = false 
        
        local partner = Players[partnerName]
        self.CurrentPartner = partner
    end)
end


return LinkController


