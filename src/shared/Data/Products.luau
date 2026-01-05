local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)


local Products = {}

Products["Skip"] = {
    ProductId = 3453621578;
    --ProductIdB = 3417933627;

    RewardFunction = function(purchaser: Player)
        local ObbyService = Knit.GetService("ObbyService")
        print'doing skip'
        ObbyService:PlayerSkippedStage(purchaser)
    end
}

Products["Poop Explosion"] = {
    ProductId = 3453740436;
   -- ProductIdB = 3418575127;

    RewardFunction = function(purchaser: Player)
        local TrollService = Knit.GetService("TrollService")
        TrollService:PoopForPlayer(purchaser)
    end
}

Products["Jumpscare Player"] = {
    ProductId = 3453621581;
   -- ProductIdB = 3417933629;
    RewardFunction = function(purchaser: Player)
        local TrollService = Knit.GetService("TrollService")
        TrollService:JumpscareForPlayer(purchaser)
    end
}


Products["Fling All"] = {
    ProductId = 3453621582;
    --ProductIdB = 3417933625;
    RewardFunction = function(purchaser: Player)
        local TrollService = Knit.GetService("TrollService")
        TrollService:FlingAll(purchaser)
    end
}

Products["Explode All"] = {
    ProductId = 3453621579;
   -- ProductIdB = 3417933626;
    RewardFunction = function(purchaser: Player)
        local TrollService = Knit.GetService("TrollService")
        TrollService:ExplodeAll(purchaser)
    end
}

Products["Jumpscare All"] = {
    ProductId = 3453621580;
   -- ProductIdB = 3417933628;
    RewardFunction = function(purchaser: Player)
        local TrollService = Knit.GetService("TrollService")
        TrollService:JumpscareAll(purchaser)
    end
}



return Products