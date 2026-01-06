local function positionModelByRoot(model, targetPart)
	local primaryPart = model.PrimaryPart
	if not primaryPart then
		return
	end

	-- 1. Get the world-space bounding box
	local modelCFrame, modelSize = model:GetBoundingBox()
	
	-- 2. Find the world Y-coordinate of the model's bottom
	local modelBottomY = modelCFrame.Y - (modelSize.Y / 2)
	
	-- 3. Find how far the PrimaryPart is above the model's bottom
	-- This works even if the PrimaryPart is at the very top, bottom, or outside
	local primaryPartOffset = primaryPart.Position.Y - modelBottomY
	
	-- 4. Calculate the Target's Top Y-coordinate
	local targetTopY = targetPart.Position.Y + (targetPart.Size.Y / 2)
	
	-- 5. Final Position: Target Top + the internal offset of the PrimaryPart
	local finalPosition = Vector3.new(
		targetPart.Position.X, 
		targetTopY + primaryPartOffset, 
		targetPart.Position.Z
	)
	
	-- 6. Move the model
	-- We construct a new CFrame using the target position but keeping the model's rotation
	local currentRotation = primaryPart.CFrame - primaryPart.CFrame.Position
	return currentRotation + finalPosition
end


return positionModelByRoot