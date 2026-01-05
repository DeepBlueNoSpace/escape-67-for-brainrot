--[[
    SUCK IT AUSTIN HA HA
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Tracks = ReplicatedStorage.Assets.Tracks:GetChildren()

local VOLUME = 0.2

local Knit = require(ReplicatedStorage.Packages.Knit)
local TEST_CONFIGS = require(ReplicatedStorage.Shared.TEST_CONFIGS)
local SoundtrackController = Knit.CreateController({ Name = "SoundtrackController" })

function shuffle(t)
	for i = #t, 2, -1 do
		local j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
end

shuffle(Tracks)

function SoundtrackController:KnitInit()
	--self.DataController = Knit.GetController("DataController")
end

function SoundtrackController:KnitStart()
	local soundObj = Instance.new("Sound")
	soundObj.Parent = SoundService
	soundObj.Volume = VOLUME

	print'gi'
	if TEST_CONFIGS.Is("SOUNDTRACK_OFF") then
		print'its off'
		return
	end


	coroutine.wrap(function()
		while true do
			for _, track in Tracks do
				soundObj.SoundId = track.SoundId
				if not soundObj.IsLoaded then
					soundObj.Loaded:Wait()
				end
				soundObj:Play()
				soundObj.Ended:Wait()
			end
		end
	end)()

	--[[self.DataController:GetReplicaPromise(game.Players.LocalPlayer):andThen(function(replica)
		local function updateVolume()
			soundObj.Volume = replica.Data.Settings.Music and VOLUME or 0
		end
		updateVolume()

		replica:ListenToChange({ "Settings", "Music" }, updateVolume)
	end)]]
end

return SoundtrackController
