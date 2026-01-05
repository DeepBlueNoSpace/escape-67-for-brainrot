local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local ProductData = require(ReplicatedStorage.Shared.Data.Products)

local ProductUtil = {}

function ProductUtil.GetProductFromId(id: number)
    for _, product in ProductData do 
        if product.ProductId == id or product.ProductIdB == id then 
            return product 
        end
    end
    return nil 
end

function ProductUtil.PromptPurchase(player, string)
	local id, bId = ProductData[string].ProductId, ProductData[string].ProductIdB
	if bId and player.UserId%2== 0 then 
		MarketplaceService:PromptProductPurchase(player, bId)
	else
		MarketplaceService:PromptProductPurchase(player, id)
	end
end


function ProductUtil.GetProductPrice(id)
	local product = ProductData[id]
	if not product then
		ProductUtil.GetProductFromId(id)
	end

	if not product then
		return "??"
	end

	if product.RobuxPrice then
		return product.RobuxPrice
	end

	local success, info

	if product.IsGamepass then
		success, info = pcall(function()
			return MarketplaceService:GetProductInfo(product.ProductId, Enum.InfoType.GamePass)
		end)
	else
		success, info = pcall(function()
			return MarketplaceService:GetProductInfo(product.ProductId, Enum.InfoType.Product)
		end)
	end

	if success and info and info.PriceInRobux then
		product.RobuxPrice = info.PriceInRobux
		return info.PriceInRobux
	else
		warn("Failed to fetch Robux price for ProductId:", product.ProductId)
		return "??"
	end
end



local function FormatRobuxText(amount)
	local formatted = tostring(amount):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
	return "" .. formatted
end

function ProductUtil.WriteProductPriceToLabel(label, id)
	coroutine.wrap(function()
		local price = ProductUtil.GetProductPrice(id)
		label.Text = FormatRobuxText(price)
	end)()
end


return ProductUtil


