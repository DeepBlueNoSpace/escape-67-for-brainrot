local WalkSpeedData = {}
WalkSpeedData.BaseUpgradePrice = 100
WalkSpeedData.UpgradePricePercentage = 1.35

function WalkSpeedData.CalculateNextLevelPrice(level: number)
    return math.floor((WalkSpeedData.BaseUpgradePrice * WalkSpeedData.UpgradePricePercentage ^ level)+0.5)
end

function WalkSpeedData.CalculatePriceForUpgrades(startLevel: number, upgradesToBuy: number)
    local price = 0 
    for i = startLevel, (startLevel+upgradesToBuy)-1 do 
        price += WalkSpeedData.CalculateNextLevelPrice(i)
    end

    return price
end

return WalkSpeedData