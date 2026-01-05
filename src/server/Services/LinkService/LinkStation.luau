local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local GetSafeCharacter = require(ReplicatedStorage.Shared.Modules.GetSafeCharacter)
local TEST_CONFIGS = require(ReplicatedStorage.Shared.TEST_CONFIGS)

local EMPTY_COLOR = Color3.fromRGB(221, 221, 221)
local IN_COLOR = Color3.fromRGB(17, 228, 0)
local LEAVE_COLOR = Color3.fromRGB(196, 40, 28)

local LINK_TIME = 3
if TEST_CONFIGS.Is("QUICK_PAIR") then 
    LINK_TIME= 0.2
end



local LinkStation = {}
LinkStation.__index = LinkStation

function LinkStation.new(station: Model)
    local self = setmetatable({}, LinkStation)
    self.LinkService = Knit.GetService("LinkService")

    self.Model = station
    self.Tube1 = station:FindFirstChild("1")
    self.Tube2 = station:FindFirstChild("2")

    self.Volume1 = self.Tube1.Volume 
    self.Volume2 = self.Tube2.Volume 

    self.FrontGlass1 = self.Tube1.FrontGlass 
    self.FrontGlassInitCFrame1 = self.Tube1.FrontGlass.CFrame 
    self.FrontGlassClosed1 = self.Tube1.FrontGlassClosed 
    self.FrontGlassInitSize = self.Tube1.FrontGlass.Size 

    self.FrontGlass2 = self.Tube2.FrontGlass 
    self.FrontGlassInitCFrame2 = self.Tube2.FrontGlass.CFrame 
    self.FrontGlassClosed2 = self.Tube2.FrontGlassClosed 

    self.LastLink = 0 

    self.Tube1Occupant = nil; 
    self.Tube2Occupant = nil; 

    self.IsReady = false
    self.CountdownStart = 0 

    return self
end

local function isPointInPart(part, point)
	local relative = part.CFrame:PointToObjectSpace(point)
	local size = part.Size * 0.5
	return math.abs(relative.X) <= size.X
		and math.abs(relative.Y) <= size.Y
		and math.abs(relative.Z) <= size.Z
end

function LinkStation:SetTubeColor(tubeModel: Model, color: Color3, lerp: boolean?)
    for _, object in tubeModel:GetChildren() do 
        if object.Name == "Glass" or object.Name == "FrontGlass"  then 
            if lerp then 
                object.Color = object.Color:lerp(color, 0.1) 
            else
                object.Color = color 
            end
        end
    end
end

local LERP_AMN = 0.2
function LinkStation:Update()
    --check for colors
	local occ1, occ2 = self:CheckForOccupants()

    --boo copy and paste
    if occ1 then 
        if self.Tube1Occupant ~= occ1 then 
            self.LinkService.Client.StationEntered:Fire(occ1, self.Model.ExitPoint.Position)
            self.Tube1Occupant = occ1 
        end

        self:SetTubeColor(self.Tube1, IN_COLOR)
        self.FrontGlass1.Size = self.FrontGlass1.Size:lerp(self.FrontGlassClosed1.Size,LERP_AMN)
        self.FrontGlass1.CFrame = self.FrontGlass1.CFrame:lerp(self.FrontGlassClosed1.CFrame,LERP_AMN)
    else 
        self.LinkDebounce = false

        if self.Tube1Occupant then 
            self.Tube1Occupant = nil -- he left!
            self:SetTubeColor(self.Tube1, LEAVE_COLOR)
        else
            self:SetTubeColor(self.Tube1, EMPTY_COLOR, true)
        end
        self.FrontGlass1.Size = self.FrontGlass1.Size:lerp(self.FrontGlassInitSize,LERP_AMN)
        self.FrontGlass1.CFrame = self.FrontGlass1.CFrame:lerp(self.FrontGlassInitCFrame1,LERP_AMN)
    end

     if occ2 then 
        if self.Tube2Occupant ~= occ2 then 
            self.LinkService.Client.StationEntered:Fire(occ2, self.Model.ExitPoint.Position)
            self.Tube2Occupant = occ2 
        end
        self:SetTubeColor(self.Tube2, IN_COLOR)

        self.FrontGlass2.Size = self.FrontGlass2.Size:lerp(self.FrontGlassClosed2.Size,LERP_AMN)
        self.FrontGlass2.CFrame = self.FrontGlass2.CFrame:lerp(self.FrontGlassClosed2.CFrame,LERP_AMN)
    else 
        self.LinkDebounce = false

        if self.Tube2Occupant then 
            self.Tube2Occupant = nil -- he left!
            self:SetTubeColor(self.Tube2, LEAVE_COLOR)
        else
            self:SetTubeColor(self.Tube2, EMPTY_COLOR, true)
        end

        self.FrontGlass2.Size = self.FrontGlass2.Size:lerp(self.FrontGlassInitSize,LERP_AMN)
        self.FrontGlass2.CFrame = self.FrontGlass2.CFrame:lerp(self.FrontGlassInitCFrame2,LERP_AMN)
    end

    if self.Tube1Occupant and self.Tube2Occupant then 
        local t = tick()
        if self.IsReady then 
            if t-self.CountdownStart > LINK_TIME then 
                if self.LinkDebounce then 
                    return 
                end

                self.LinkDebounce = true
                self.LinkService:AttemptLink(self.Tube1Occupant, self.Tube2Occupant)
            end
        else
            self.IsReady = true 
            self.CountdownStart = t 
        end
    end
end

function LinkStation:CheckForOccupants()
    local tube1Occupant = false
    local tube2Occupant = false
    for _, player in Players:GetPlayers() do 
        local character = GetSafeCharacter(player)
        if not character then
            continue 
        end

        local head = character:FindFirstChild("Head") or character:FindFirstChild("HEAD")
        if not head then 
            continue
        end
        
        if isPointInPart(self.Volume1, head.Position) then 
            tube1Occupant = player 
        elseif isPointInPart(self.Volume2, head.Position) then 
            tube2Occupant = player 
        end
    end

    return tube1Occupant, tube2Occupant
end


return LinkStation