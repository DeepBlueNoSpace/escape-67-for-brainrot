local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Signal = require(ReplicatedStorage.Packages.Signal)

local Player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)

local FrogAnimationController = Knit.CreateController({Name = "FrogAnimationController", LiveAnimations = {}, ChargeStart = Signal.new(), CurrentBind = nil})

function FrogAnimationController:KnitInit()

end


function FrogAnimationController:KnitStart()
    if Player.Character then 
        self:HandleCharacter(Player.Character)
    end

    Player.CharacterAdded:Connect(function(character: Model)
        self:HandleCharacter(character)
    end)

    self.ChargeStart:Connect(function(maxTime: number)
        local chargeAnim = self.LiveAnimations.Charge 
        if not chargeAnim then 
            return 
        end
        chargeAnim:Play(nil,nil,maxTime/chargeAnim.Length)
    end)
end

function FrogAnimationController:LoadAnimations(humanoid: Humanoid)
    for _, animationObject: Animation in ReplicatedStorage.Assets.Animations:GetChildren() do 
        FrogAnimationController.LiveAnimations[animationObject.Name] = humanoid:LoadAnimation(animationObject)
    end
end

function FrogAnimationController:StopAllAnims()
    for _, anim in self.LiveAnimations do 
        anim:Stop()
    end
end

local BASE_WALK_SPEED = 6

function FrogAnimationController:HandleCharacter(character: Model)
    local humanoid = character:WaitForChild("Humanoid")
    self:LoadAnimations(humanoid)

    self.LiveAnimations.Idle:Play()
    humanoid.Jumping:Connect(function(jumping: boolean)
        if jumping then 
            local attach = ReplicatedStorage.Assets.JumpTrail:Clone() 
            attach.Parent = character.HumanoidRootPart

            self:StopAllAnims()
            self.LiveAnimations.Jump:Play(nil,nil,1.5)

            task.spawn(function() 
                task.wait(0.4)
                attach.Trail.Enabled = false 
                task.wait(2)
                attach:Destroy()
            end)
        end
    end)
    humanoid.FreeFalling:Connect(function(isFalling: boolean)
        if isFalling then 
            self:StopAllAnims()
            self.LiveAnimations.Fall:Play(nil,nil,1.5)
        else
            self.LiveAnimations.Fall:Stop()
        end
    end)
    humanoid.Running:Connect(function(speed) 
        if speed > 0 then 
            if self.LiveAnimations.Walk.IsPlaying == false then 
                self.LiveAnimations.Walk:Play(nil, nil, speed/BASE_WALK_SPEED)
            end
            self.LiveAnimations.Walk:AdjustSpeed(speed/BASE_WALK_SPEED)
        else
            self.LiveAnimations.Walk:Stop()
        end
    end)

    humanoid.Died:Connect(function() 
        if self.CurrentBind then 
            self.CurrentBind:Disconnect() 
            self.CurrentBind = nil 
        end
    end)

    if self.CurrentBind then 
        self.CurrentBind:Disconnect() 
        self.CurrentBind = nil 
    end

    local hangTime = 0
    self.CurrentBind = RunService.Heartbeat:Connect(function(dT: number) 
        if humanoid:GetState() == Enum.HumanoidStateType.Freefall then 
            if character.PrimaryPart.AssemblyLinearVelocity.Magnitude > 50 then -- they're falling 
                if not self.LiveAnimations.Fall.IsPlaying then 
                    self.LiveAnimations.Fall:Play()
                    self.LiveAnimations.Dangling:Stop()
                    hangTime = 0
                end
            else
                hangTime += dT
                if hangTime > 0.45 then 
                    self.LiveAnimations.Fall:Stop()
                    if not self.LiveAnimations.Dangling.IsPlaying then 
                    self.LiveAnimations.Dangling:Play(nil,nil,1.3)
                    end
                end
            end
        else
            hangTime = 0 
        end
    end)
end



return FrogAnimationController