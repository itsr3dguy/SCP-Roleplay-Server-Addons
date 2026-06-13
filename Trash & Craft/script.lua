-- ===== CONFIG =====
local CraftingRecipes = {
    ["Pistol"] = {"Gun Barrel", "Magazine", "Gunpowder", "Spring", "Duct Tape"}
}
local TrashLootTable = {
    "Gun Barrel", "Magazine", "Gunpowder", "Spring", "Duct Tape"
}
local SearchCooldown = 30 -- seconds
local LastSearched = {} -- [player_bin_key] = tick()

local WeightHave = 1    -- weight if player already has the item
local WeightNeed = 10   -- weight if player doesn't have the item
local StinkyBootChance = 0.05 -- 5% chance of stinky boot

-- ===== HELPER: CREATE A SIMPLE ITEM TOOL =====
local function CreateComponentTool(Name)
    local Tool = Instance.new("Tool")
    Tool.Name = Name
    Tool.CanBeDropped = true
    local Part = Instance.new("Part")
    Part.Name = "Handle"
    Part.Size = Vector3.new(1, 1, 1)
    Part.CFrame = CFrame.new(999, 9999, 999)
    f(Tool)
    Part.Parent = Tool
    return Tool
end

-- ===== WEIGHTED LOOT PICKER =====
local function PickLoot(Player)
    local WeightedTable = {}

    for _, Item in pairs(TrashLootTable) do
        local Weight = hasTool(Player, Item) and WeightHave or WeightNeed
        for j = 1, Weight do
            table.insert(WeightedTable, Item)
        end
    end

    return WeightedTable[math.random(1, #WeightedTable)]
end

-- ===== INTERACTIONS =====
event("interaction", function(Data)
    local Player = Data.Value[1]
    local InteractionName = Data.Value[2]

    -- ===== CRAFTING TABLE =====
    if InteractionName == "CraftingTable" then
        local Recipe = CraftingRecipes["Pistol"]
        local HasAll = true

        for _, Item in pairs(Recipe) do
            if not hasTool(Player, Item) then
                HasAll = false
                break
            end
        end

        if HasAll then
            for _, Item in pairs(Recipe) do
                removeTool(Player, Item)
            end
            giveTool(Player, "Pistol")
        end
    end

    -- ===== TRASH BIN SEARCH (any bin: TrashBin1, TrashBin2, ...) =====
    if InteractionName:sub(1, 8) == "TrashBin" then
        local Key = Player .. "_" .. InteractionName
        local Now = tick()
        local Last = LastSearched[Key] or 0

        if Now - Last < SearchCooldown then
            return
        end

        LastSearched[Key] = Now

        local Item
        if math.random() < StinkyBootChance then
            Item = "Stinky Boot"
        else
            Item = PickLoot(Player)
        end

        local Tool = CreateComponentTool(Item)
        giveTool(Player, Tool)
    end
end)
