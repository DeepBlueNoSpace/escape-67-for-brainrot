local function GetSafeCharacter(player): Model?
	local character = player.Character
	if not character then
		return
	end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	if humanoid.Health <= 0 then
		return nil
	end

	if character.Parent == nil then
		return
	end

	return character
end



return GetSafeCharacter