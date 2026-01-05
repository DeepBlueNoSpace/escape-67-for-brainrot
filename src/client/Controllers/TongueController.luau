--!nonstrict

--[[
⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
LEGACY CODE 
⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
NOT USED ANYMORE
⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local GetSafeCharacter = require(ReplicatedStorage.Shared.Modules.GetSafeCharacter)

local TongueController = Knit.CreateController({ Name = "TongueController", Tonguing = false})

local MAX_TONGUE_RANGE = 30

function TongueController:KnitInit()
   -- self.TongueService = Knit.GetService("TongueService")
end

function TongueController:KnitStart()
    if true then 
        return 
    end

    UserInputService.InputBegan:Connect(function(inputObject: InputObject, gameProcessed: boolean) 
        if gameProcessed then 
            return
        end

        if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then 
            if self.Tonguing then
           --     self.TongueService.RequestStopTonguing:Fire()
            else
                self:FireTongue()
            end
        end
    end)

   -- self.TongueService.TonguingEnded:Connect(function()
   --     self.Tonguing = false
   -- end)
end

function TongueController:FireTongue()
    if self.Tonguing then 
        return 
    end

    local camera = workspace.CurrentCamera

    local mouseP = Player:GetMouse()
    local ray = camera:ScreenPointToRay(mouseP.X, mouseP.Y)
    local rayOrigin = ray.Origin
    local rayDirection = ray.Direction * MAX_TONGUE_RANGE

    local params = RaycastParams.new():AddToFilter(Player.Character)
    local result = workspace:Raycast(rayOrigin, rayDirection, params)

    if result then 
        self:TonguePull(result.Position)
    end
end

function TongueController:TonguePull(hitPosition: Vector3)
    local character = GetSafeCharacter(Player)
    if not character then 
        return 
    end

    LastTonguing = tick()
    self.Tonguing = true
    self.TongueService.RequestTonguing:Fire(hitPosition) -- this is liable to break

end

return TongueController 
