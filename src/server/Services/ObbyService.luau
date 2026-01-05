local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local AnalyticsService = game:GetService("AnalyticsService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ObbyService = Knit.CreateService({Name = "ObbyService", 
    Client = {RequestRespawn = Knit.CreateSignal()}})

ObbyService.Stages = {} :: {Stage}

export type Stage = {
    Checkpoint: BasePart,
    Spawn: BasePart,
    Id: number
}

function ObbyService:KnitInit()
    self.StagesFolder = workspace:FindFirstChild("Stages") :: Folder
    self.LinkService = Knit.GetService("LinkService")
    assert(self.StagesFolder, "No folder called stages found")
end

function ObbyService:KnitStart()
    self:IndexStages()
    self:HandleRespawning()
    self:HandleKillParts()

    for _, movemementSet in CollectionService:GetTagged("MovePart") do 
        coroutine.wrap(function() 
            self:HandleMovementSet(movemementSet)
        end)()
    end

    CollectionService:GetInstanceAddedSignal("MovePart"):Connect(function(movemementSet: Model) 
        self:HandleMovementSet(movemementSet)
    end)

    for _, movemementSet in CollectionService:GetTagged("MovePartCFrame") do 
        coroutine.wrap(function() 
            self:HandleCFrameMovementSet(movemementSet)
        end)()
    end

    CollectionService:GetInstanceAddedSignal("MovePartCFrame"):Connect(function(movemementSet: Model) 
        self:HandleCFrameMovementSet(movemementSet)
    end)


    for _, swinger in CollectionService:GetTagged("Swinger") do 
        coroutine.wrap(function() 
            self:HandleSwinger(swinger)
        end)()
    end

    CollectionService:GetInstanceAddedSignal("Swinger"):Connect(function(swinger: BasePart) 
        self:HandleSwinger(swinger)
    end)

    ObbyService.Client.RequestRespawn:Connect(function(player: Player)
        self:SpawnPlayersCouple(player)
    end)
end

local function SpawnPlayerOnObby(character: Model, stageValue: number, isRight: boolean) 
    local targetStage = ObbyService.Stages[stageValue]

    if not targetStage then 
        return 
    end

    local baseCFrame = CFrame.new(targetStage.Spawn.Position)
    local nextStage = ObbyService.Stages[stageValue+1]
    if nextStage then 
        baseCFrame = CFrame.new(targetStage.Spawn.Position, nextStage.Spawn.Position)
    end

    if isRight then 
        character:PivotTo(baseCFrame*CFrame.new(Vector3.new(2.5,3,0)))
    else
        character:PivotTo(baseCFrame*CFrame.new(Vector3.new(-2.5,3,0)))
    end
end

function ObbyService:SpawnPlayersCouple(player: Player)
    local partner = ObbyService.LinkService.LinkedPlayers[player]
    if not partner then 
        return 
    end

    if (not player:GetAttribute("Animal")) or (not partner:GetAttribute("Animal")) then 
        player:SetAttribute("Animal", "Cat")
        partner:SetAttribute("Animal", "Mouse")
    end


    local stage = math.max(player.leaderstats.Stage.Value, partner.leaderstats.Stage.Value)
    player.leaderstats.Stage.Value, partner.leaderstats.Stage.Value = stage, stage

    --Mouse == right

    ObbyService.LinkService:MakePlayerAnimal(player)
    ObbyService.LinkService:MakePlayerAnimal(partner)

    task.wait()

    --Move them to the obby
    SpawnPlayerOnObby(player.Character, stage, player:GetAttribute("Animal") == "Mouse")
    SpawnPlayerOnObby(partner.Character, stage, partner:GetAttribute("Animal") == "Mouse")

    player.Character.HumanoidRootPart.Anchored = true
    player.Character.HumanoidRootPart.Anchored = true


    ObbyService.LinkService.Client.StartLink:Fire(player, partner.Character, player:GetAttribute("Animal") == "Mouse")
    ObbyService.LinkService.Client.StartLink:Fire(partner, player.Character, partner:GetAttribute("Animal") == "Mouse")

    task.wait(1)

    player.Character.HumanoidRootPart.Anchored = false
    player.Character.HumanoidRootPart.Anchored = false

end

local MOVE_PART_VELOCITY = 6
local THRESHOLD = 1.5 -- how close before switching direction


function ObbyService:HandleMovementSet(movementSet: Model)
	local movePart = movementSet:WaitForChild("Part")
	local p0 = movementSet:WaitForChild("Target1").Position
	local p1 = movementSet:WaitForChild("Target2").Position
	
	-- Reset position and anchors
	movePart.Anchored = false
	movePart.Position = p0
	
	-- Set up LinearVelocity mover
	local attachment = Instance.new("Attachment")
	attachment.Parent = movePart
	
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.MaxForce = math.huge
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity.Parent = movePart
	
    local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Attachment0 = attachment
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Responsiveness = 200
	alignOrientation.MaxTorque = math.huge
	alignOrientation.CFrame = movePart.CFrame -- lock current rotation
	alignOrientation.Parent = movePart

	local target = p1
	local direction = (target - movePart.Position).Unit
	linearVelocity.VectorVelocity = direction * MOVE_PART_VELOCITY
	
    for _, obj in movePart:GetDescendants() do 
        if obj:IsA("BasePart") then 
            obj.Anchored =false
        end
    end

	-- Switch direction when reaching a target
	task.spawn(function()
		while movePart.Parent do
	        local direction = (target - movePart.Position).Unit
	        linearVelocity.VectorVelocity = direction * MOVE_PART_VELOCITY

			task.wait(0.05)
			if (movePart.Position - target).Magnitude <= THRESHOLD then
				target = (target == p0) and p1 or p0
				direction = (target - movePart.Position).Unit
				linearVelocity.VectorVelocity = direction * MOVE_PART_VELOCITY
                task.wait(2)
			end
		end
	end)
end


local animTime = 13

function easeInOutQuad(x)
	if x < 0.5 then
		return 2 * x * x
	else
		return 1 - ((-2 * x + 2) ^ 2) / 2
	end
end

function ObbyService:HandleCFrameMovementSet(movementSet: Model)
	local movePart = movementSet:WaitForChild("Part")
	local c0 = movementSet:WaitForChild("Target1").CFrame
	local c1 = movementSet:WaitForChild("Target2").CFrame
	
    local startTime = tick()
	-- Reset position and anchors
	movePart:PivotTo(c0)
	
    local startC, endC = c0,c1 
    local goingUp = true 
	task.spawn(function()
        while true do 
            local seedX = (tick()-startTime)/animTime
		    local i =easeInOutQuad(seedX)
            movePart:PivotTo(startC:lerp(endC, i))

            if seedX > 1 then 
                if goingUp then 
                    startC, endC = c1,c0 
                else
                    startC, endC = c0,c1
                end

                goingUp = not goingUp
                startTime = tick() 
            end

            wait()
        end
	end)
end

function ObbyService:HandleSwinger(swinger: BasePart)
	local rotationA = swinger:WaitForChild("A") :: BasePart
	local rotationB = swinger:WaitForChild("B") :: BasePart

	swinger.CFrame = rotationA.CFrame

	local swingDuration = 6 -- seconds for one A→B→A cycle

	local function easeInOutQuad(t: number): number
		-- t ∈ [0,1], returns eased value ∈ [0,1]
		if t < 0.5 then
			return 2 * t * t
		else
			return 1 - math.pow(-2 * t + 2, 2) / 2
		end
	end

	task.spawn(function()
		local startTime = tick()
		while swinger.Parent do
			local elapsed = (tick() - startTime) % swingDuration
			local halfCycle = swingDuration / 2
			local t = (elapsed % halfCycle) / halfCycle
			local direction = math.floor(elapsed / halfCycle) % 2 -- 0: A→B, 1: B→A
			local eased = easeInOutQuad(t)

			local alpha = direction == 0 and eased or 1 - eased
			swinger.CFrame = rotationA.CFrame:Lerp(rotationB.CFrame, alpha)

			task.wait()
		end
	end)
end


function ObbyService:IndexStages()
    for _, stageFolder: Folder in self.StagesFolder:GetChildren() do 
        local stageData = {
            Checkpoint = stageFolder:FindFirstChild("Checkpoint"),
            Spawn = stageFolder:FindFirstChild("Spawn"),
            Id = tonumber(stageFolder.Name)
        } :: Stage

        assert(stageData.Checkpoint, string.format("No checkpoint found for stage %s", stageFolder.Name))
        assert(stageData.Checkpoint, string.format("No spawn found for stage %s", stageFolder.Name))
        assert(stageData.Id, string.format("Invalid name for stage %s", stageFolder.Name))

        stageData.Checkpoint.Transparency = 1

        self:HandleStage(stageData)
        ObbyService.Stages[stageData.Id] = stageData
    end
end

local function GetPlayerFromPart(part: Instance): Player?
    for _, player: Player in Players:GetPlayers() do 
        local character = player.Character 
        if not character then 
            continue 
        end

        if part:IsDescendantOf(character) then 
            if character.Humanoid.Health > 0 then 
                return player 
            end
        end
    end

    return nil
end

function ObbyService:PlayerSkippedStage(player: Player)
    local playerStats = player:FindFirstChild('leaderstats')
    if not playerStats then 
        return 
    end

    local currentStageValue = playerStats.Stage.Value 
    playerStats.Stage.Value = currentStageValue+1
    
    self:SpawnPlayersCouple(player)
end

function ObbyService:EvaluateMovingPlayerToStage(player: Player, stageId: number)
    local playerStats = player:FindFirstChild('leaderstats')
    if not playerStats then 
        return 
    end

    if self.LinkService.LinkedPlayers[player] == nil then 
        --Players should only ever progress IF they are linked
        return 
    end

    local currentStageValue = playerStats.Stage.Value 
    if currentStageValue < stageId then 
        playerStats.Stage.Value = stageId
         AnalyticsService:LogOnboardingFunnelStepEvent(
            player,
            2+stageId, -- Step number
            string.format("Reached stage %s", tostring(stageId)) -- Step name
        )
    end

    local linkedWith = self.LinkService.LinkedPlayers[player]
    if linkedWith then 
        local leaderstats = linkedWith:FindFirstChild("leaderstats")
        if leaderstats then 
            if leaderstats.Stage.Value < playerStats.Stage.Value then 
                leaderstats.Stage.Value = playerStats.Stage.Value
            elseif playerStats.Stage.Value < leaderstats.Stage.Value then 
                playerStats.Stage.Value = leaderstats.Stage.Value 
            end
        end
    end
end

function ObbyService:HandleStage(stageData: Stage)
    stageData.Checkpoint.Touched:Connect(function(part: Instance)
        local player = GetPlayerFromPart(part)
        if player then 
            self:EvaluateMovingPlayerToStage(player, stageData.Id)
        end
    end)
end

function ObbyService:HandleKillParts()
    for _, part in CollectionService:GetTagged("Kill") do 
        if part:IsA("BasePart") then 
            part.Touched:Connect(function(touchingPart: BasePart) 
                local touchingPlayer = GetPlayerFromPart(touchingPart)
                if touchingPlayer then 
                    touchingPlayer.Character.Humanoid.Health = 0
                end
            end)
        end
    end
end

function ObbyService:HandleRespawning()
    Players.PlayerAdded:Connect(function(player: Player) 
        AnalyticsService:LogOnboardingFunnelStepEvent(
            player,
            1, -- Step number
            "Player Joined" -- Step name
        )
        
        local leaderstats = player:WaitForChild("leaderstats") :: Model
        local stage = leaderstats:WaitForChild("Stage") :: NumberValue

        player.CharacterAdded:Connect(function(character: Model)
            for _, x in character:GetDescendants() do 
                if x:IsA("BasePart") then 
                    x.CollisionGroup = "Players"
                end
            end
        end)
    end)
end

--[[
local selectedModel = game:GetService("Selection"):Get()[1]

local base = selectedModel.PrimaryPart 
for _, object in selectedModel:GetDescendants() do 
    if object:IsA("BasePart") and object~= base then 
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = base
        weld.Part1 = object
        weld.Parent = object
    end
end]]
return ObbyService