local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local ProductUtil = require(ReplicatedStorage.Shared.Modules.ProductUtil)
local MonetisationService = Knit.CreateService({Name = "MonetisationService"})

function MarketplaceService.ProcessReceipt(receiptInfo)
	-- Check the data store to determine if the product was already granted
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local product = ProductUtil.GetProductFromId(receiptInfo.ProductId)
	if not product then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local success = true
	if product.RewardFunction then
		product.RewardFunction(player)
	end

	if not success then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end


	return Enum.ProductPurchaseDecision.PurchaseGranted
end


return MonetisationService