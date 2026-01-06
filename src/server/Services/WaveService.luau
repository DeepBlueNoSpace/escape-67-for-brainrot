local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local WaveService = Knit.CreateService({Name = "WaveService", 
    Client = {}})

local WaveData = {
    [1] = {
        Speed = 35, 
        Cooldown = 0, 
        ImageId = 'rbxassetid://79587191108521',
        LastEnded = 0,
        Name = "MEGA SLOW 67 😭😭😭",
        NameColor = Color3.fromRGB(118, 184, 255)
    },
    [2] = {
        Speed = 50, 
        Cooldown = 0, 
        ImageId = 'rbxassetid://86472200403531',
        LastEnded = 0,
        Name = "Easy 67 🐸",
        NameColor = Color3.fromRGB(157, 255, 118)
    },
    [3] = {
        Speed = 60, 
        Cooldown = 20, 
        ImageId = 'rbxassetid://137902812626984',
        LastEnded = 0,
        Name = "🍌 67 🍌",
        NameColor = Color3.fromRGB(255, 255, 21)
    },
    [4] = {
        Speed = 80, 
        Cooldown = 30, 
        ImageId = 'rbxassetid://133478646176604',
        LastEnded = 0,
        Name = "Speedy 67 ⚡️",
        NameColor = Color3.fromRGB(0, 0, 0)
    },
    [5] = {
        Speed = 100, 
        Cooldown = 60, 
        ImageId = 'rbxassetid://113741855561466',
        LastEnded = 0,
        Name = "KILLER 67 🔪🔪🔪",
        NameColor = Color3.fromRGB(115, 0, 0)
    },
    [6] = {
        Speed = 200, 
        Cooldown = 20, 
        ImageId = 'rbxassetid://79640394907626',
        LastEnded = 0,
        Name = "😈 DEVIL 67 😈",
        NameColor = Color3.fromRGB(84, 0, 69)
    },
}
function WaveService:KnitInit()
    self.WaveFolder = workspace.Wave
    self.WaveStart = self.WaveFolder.Start
    self.WaveEnd = self.WaveFolder.End

    self.Distance = (self.WaveStart.Position-self.WaveEnd.Position).Magnitude
end

function WaveService:KnitStart()
    coroutine.wrap(function() 
        while true do 
            for waveId, waveData in WaveData do 
                if tick() - waveData.LastEnded > waveData.Cooldown then 
                    self:DoWave(waveId)
                    waveData.LastSent = tick()
                end
            end
            task.wait(1)
        end
    end)()
end

function WaveService:DoWave(id: number)
    local waveData = WaveData[id]

    local wave = self.WaveStart:Clone()
    local timeToFinish = self.Distance/waveData.Speed
    waveData.LastEnded = tick()+timeToFinish
    wave.CFrame = self.WaveStart.CFrame 
    wave.Parent = workspace
    wave.Transparency = 0
    wave.Material = Enum.Material.ForceField
    wave.CanCollide = false

    local decal = Instance.new("Decal")
    decal.ColorMap = waveData.ImageId 
    decal.Parent = wave 

    local gui = ReplicatedStorage.Assets.WaveBillboard:Clone()
    gui.Frame.NameLabel.Text = waveData.Name 
    gui.Frame.NameLabel.TextColor3 = waveData.NameColor 
    gui.Parent = wave 

    wave.Touched:Connect(function(hitPart:BasePart)
        local parent = hitPart.Parent 
        if not parent then 
            return 
        end

        local humanoid = parent:FindFirstChild("Humanoid")
        if humanoid then 
            humanoid.Health = 0 
        end
    end)

    local sT = tick() 

    coroutine.wrap(function() 
        local i = 0 
        while i < 1 do 
            i = (tick()-sT)/timeToFinish
            wave.CFrame = self.WaveStart.CFrame:lerp(self.WaveEnd.CFrame, i)
            task.wait()
        end

        wave:Destroy()
    end)()

end

return WaveService
