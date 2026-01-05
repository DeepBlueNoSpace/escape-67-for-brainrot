--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage.Assets
local Player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)

local ObbyController = Knit.CreateController({ Name = "ObbyController";})

function ObbyController:KnitInit()
    self.LinkService = Knit.GetService("LinkService")
    self.LinkController = Knit.GetController("LinkController")
end

local function DoButtonPressEffect(button: BasePart)
    local effectAttachment = Assets.ButtonEffects:Clone()
    effectAttachment.Parent = button 

    effectAttachment.Circle:Emit(1)
    effectAttachment.Stars:Emit(30)
    
    local sound = Assets.Sound.ButtonPresses:GetChildren()[math.random(1,3)]:Clone()
    sound.PlayOnRemove = true 
    sound.Parent = effectAttachment
    sound:Destroy()

    coroutine.wrap(function() 
        wait(4)
        effectAttachment:Destroy()
    end)()
end

function ObbyController:KnitStart()
    for _, balloon in CollectionService:GetTagged("HotAirBalloon") do 
        coroutine.wrap(function() 
            self:HandleHotAirBalloon(balloon)
        end)()
    end

    CollectionService:GetInstanceAddedSignal("HotAirBalloon"):Connect(function(balloon: Model) 
        self:HandleHotAirBalloon(balloon)
    end)

    for _, stage in CollectionService:GetTagged("Stage") do 
        coroutine.wrap(function() 
            self:HandleStage(stage)
        end)()
    end

    CollectionService:GetInstanceAddedSignal("Stage"):Connect(function(stage: Folder) 
        self:HandleStage(stage)
    end)

    for _, puzzle in CollectionService:GetTagged("ButtonPuzzle") do 
        coroutine.wrap(function() 
            self:HandleButtonPuzzle(puzzle)
        end)()
    end

    CollectionService:GetInstanceAddedSignal("ButtonPuzzle"):Connect(function(puzzle: Folder) 
        self:HandleButtonPuzzle(puzzle)
    end)

    for _, Trampoline in CollectionService:GetTagged("Trampoline") do 
        coroutine.wrap(function() 
            self:HandleTrampoline(Trampoline)
        end)()
    end

    CollectionService:GetInstanceAddedSignal("Trampoline"):Connect(function(Trampoline: Folder) 
        self:HandleTrampoline(Trampoline)
    end)

    
    for _, part in CollectionService:GetTagged("AnimalExclusive") do 
        coroutine.wrap(function() 
            self:HandleAnimalExclusive(part)
        end)()
    end

    CollectionService:GetInstanceAddedSignal("AnimalExclusive"):Connect(function(part: BasePart) 
        self:HandleAnimalExclusive(part)
    end)

    for _, part in CollectionService:GetTagged("SpinningPart") do 
        coroutine.wrap(function() 
            self:HandleSpinningPart(part)
        end)()
    end

    CollectionService:GetInstanceAddedSignal("SpinningPart"):Connect(function(part: BasePart) 
        self:HandleSpinningPart(part)
    end)

    self.LinkService.PlayAnimalAnimations:Connect(function(animalType: string)
        local character = Player.Character
        character.Animate:Destroy()
        local animTracks = character.Humanoid:GetPlayingAnimationTracks() 
        for _, track in animTracks do 
            track:Stop()
        end

        if animalType == "Cat" then 
            local scriptA = Assets.CatAnimations:Clone()
            scriptA.Name = "Animate"
            scriptA.Parent = character 
        elseif animalType == "Mouse" then 
            local scriptA = Assets.MouseAnimations:Clone()
            scriptA.Name = "Animate"
            scriptA.Parent = character 
        end
    end)
end

local function HandleButtonPress(part: BasePart, animalNeeded: string)
    local character = part.Parent 
    if not character then 
        return 
    end
    if not character:IsA("Model") then 
        return 
    end

    if animalNeeded then 
        if not (character:GetAttribute("Animal") == animalNeeded) then 
            return 
        end
    end

    local tPlayer = Players:GetPlayerFromCharacter(character)
    if not tPlayer then 
        return 
    end

    if not (tPlayer == Player or tPlayer == ObbyController.LinkController.CurrentPartner) then 
        return 
    end 

    return true
end

function ObbyController:HandleStage(stage: Folder)
    local endGate = stage:WaitForChild("EndGate")
    local blueButton = endGate:WaitForChild("BlueButton"):WaitForChild("Button")
    local redButton = endGate:WaitForChild("RedButton"):WaitForChild("Button")
    local gate = endGate:WaitForChild("Gate")

    local bluePressed = false 
    local redPressed = false 
    local opened = false 

    local function OpenGate()
        for _, obj in gate:GetChildren() do 
            if obj.Name == "Opening" then 
                local ySize = obj.Size.Y 
                local curPosition = obj.Position 

                coroutine.wrap(function() 
                    for i = 1, ySize-1 do 
                        obj.Size = Vector3.new(obj.Size.X, ySize-i, obj.Size.Z)
                        obj.Position = curPosition+Vector3.new(0,i/2,0)
                        wait(0.3)
                    end
                end)()
            end
            opened = true
        end
    end

    local function EvaluateToOpenGate()
        if opened then 
            return 
        end

        if redPressed and bluePressed then 
            OpenGate()
        end
    end
    blueButton.Material = Enum.Material.Glass
    blueButton.Transparency = 0.5
    blueButton.Color = Color3.fromRGB(27,42,53)
    redButton.Material = Enum.Material.Glass
    redButton.Transparency = 0.5
    redButton.Color = Color3.fromRGB(27,42,53)

    local mouseDecal = Instance.new("Decal")
    mouseDecal.Texture = "rbxassetid://116297769964877"
    mouseDecal.Face = Enum.NormalId.Top
    mouseDecal.Transparency = 0.5
    mouseDecal.Parent = blueButton

    local catDecal = mouseDecal:Clone()
    catDecal.Parent = redButton
    catDecal.Texture = 'rbxassetid://81789025898994'


    blueButton.Touched:Connect(function(part: BasePart)
        if bluePressed then 
            return 
        end
        
        local successfulPress = HandleButtonPress(part, "Mouse")
        if successfulPress then 
            mouseDecal.Transparency = 0 
            blueButton.Transparency = 0 
            blueButton.Color = Color3.fromRGB(144,198,255)

            DoButtonPressEffect(blueButton)

            bluePressed = true 
            EvaluateToOpenGate()
        end
    end)

     redButton.Touched:Connect(function(part: BasePart)
        if redPressed then 
            return 
        end

        local successfulPress = HandleButtonPress(part, "Cat")
        if successfulPress then 
            catDecal.Transparency = 0 
            redButton.Transparency = 0 
            redButton.Color = Color3.fromRGB(255,133,135)

            DoButtonPressEffect(redButton)

            redPressed = true 
            EvaluateToOpenGate()
        end
    end)
end

local function GetModelMass(model: Model): number
	local totalMass = 0
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			totalMass += part:GetMass()
		end
	end
	return totalMass
end

local bouncePower = 15

function ObbyController:HandleTrampoline(trampoline: BasePart)
    local debounce = false 
    trampoline.Touched:Connect(function(part)
        if debounce then 
            return 
        end

        if not(Player.Character == part.Parent) then 
            return 
        end

        local root = Player.Character:FindFirstChild("HumanoidRootPart")
        local characterMass = GetModelMass(Player.Character)
        if root then
            debounce = true
            root.AssemblyLinearVelocity = Vector3.new(
                root.AssemblyLinearVelocity.X,
                bouncePower*characterMass,
                root.AssemblyLinearVelocity.Z
            )

            task.wait(0.3)
            debounce = false
        end
    end)
end

function ObbyController:HandleButtonPuzzle(puzzle: Folder)
    local buttonsFolder = puzzle:WaitForChild("Buttons")
    local targetsFolder = puzzle:WaitForChild("Targets")

    local buttons = {} -- [button] = pressed: boolean

    local function DoSuccess()
        local successAttributes = targetsFolder:GetAttributes()

        for _, object in targetsFolder:GetChildren() do 
            if object:IsA("Model") then 
                for _, dObject in object:GetDescendants() do 
                    if dObject:IsA("BasePart") then 
                        for attribute, value in successAttributes do 
                            dObject[attribute] = value
                        end
                        if object:GetAttribute("ForceTransparency") then 
                            dObject.Transparency = object:GetAttribute("ForceTransparency")
                        end
                    end
                end
            elseif object:IsA("BasePart") then 
                for attribute, value in successAttributes do 
                    object[attribute] = value
                end
            end
        end
    end

    local function EvaluateSuccess()
        for _, pressed in buttons do 
            if not pressed then 
                return 
            end
        end

        DoSuccess()
    end

    local function HandleButton(button: BasePart) 
        buttons[button] = false 

        button.Material = Enum.Material.Neon 
        
        local targetAnimal = button:GetAttribute("AnimalNeeded")
        if targetAnimal == "Cat" then 
            local catDecal = Instance.new("Decal")
            catDecal.Texture = "rbxassetid://81789025898994"
            catDecal.Face = Enum.NormalId.Top
            catDecal.Transparency = 0.5
            catDecal.Parent = button
        elseif targetAnimal == "Mouse" then 
            local mouseDecal = Instance.new("Decal")
            mouseDecal.Texture = "rbxassetid://116297769964877"
            mouseDecal.Face = Enum.NormalId.Top
            mouseDecal.Transparency = 0.5
            mouseDecal.Parent = button
            
        end
        
        local buttonPart = button--button:WaitForChild("Button")
        buttonPart.Touched:Connect(function(part: BasePart) 
            if buttons[button] then 
                return 
            end
            local result = HandleButtonPress(part, targetAnimal)
            if result then 
                button.Color = Color3.fromRGB(0, 255, 21)
                DoButtonPressEffect(button)

                buttons[button] = true
                EvaluateSuccess()
            end
        end)
    end

    for _, button in buttonsFolder:GetChildren() do 
        HandleButton(button)
    end

    buttonsFolder.ChildAdded:Connect(HandleButton)
end


local rotationSpeed =  50

function ObbyController:HandleSpinningPart(part: BasePart)
    local angle = 0
    local startCFrame = part.CFrame 

    RunService.RenderStepped:Connect(function(dT: number) 
        angle+= dT*rotationSpeed
        part.CFrame = startCFrame * CFrame.Angles(0, math.rad(angle),0)
    end)
end

function ObbyController:HandleHotAirBalloon(balloon: Model)
    local main = balloon:WaitForChild("Meshes/AirBalloonHeart_Plane")
    balloon.PrimaryPart = main 

	-- Randomize amplitude (how far it moves) and period (how fast)
	local amplitude = math.random(3,6) -- studs
	local period = math.random(7,9) -- seconds
	local offset = math.random() * math.pi * 2 -- random starting phase

	local baseY = main.Position.Y

    local x = tick()
	RunService.RenderStepped:Connect(function()
		-- Smooth sinusoidal motion
		local dy = math.sin(((tick()-x) / period) * math.pi * 2 + offset) * amplitude
		balloon:PivotTo(CFrame.new(main.Position.X, baseY + dy, main.Position.Z))
	end)
    
end

function ObbyController:HandleAnimalExclusive(part: BasePart)
    local animalType = part:GetAttribute("AnimalNeeded")

    local function UpdatePart(character: Model?)
        if character and character:GetAttribute("Animal") == animalType then 
            part.Transparency = 0 
            part.CanCollide = true
        else
            part.Transparency = 0.5
            part.CanCollide = false
        end
    end

    UpdatePart(Player.Character)
    do
        if Player.Character then 
            local sig1 = Player.Character:GetAttributeChangedSignal("Animal"):Connect(function() 
                UpdatePart(Player.Character)
            end)

            local humanoid = Player.Character:WaitForChild("Humanoid")
            humanoid.Died:Connect(function()
                sig1:Disconnect()
            end)
        end
    end

    Player.CharacterAdded:Connect(function(character: Model)
            UpdatePart(Player.Character)

       local sig1 = character:GetAttributeChangedSignal("Animal"):Connect(function() 
            UpdatePart(character)
        end)

        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            sig1:Disconnect()
        end)
    end)
end



return ObbyController


