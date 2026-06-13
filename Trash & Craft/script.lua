-- ===== CONFIG =====
local CraftingRecipes = {
    ["Pistol"] = {"Gun Barrel", "Magazine", "Gunpowder", "Spring", "Duct Tape"}
}

local TrashLootTable = {
    "Gun Barrel", "Magazine", "Gunpowder", "Spring", "Duct Tape"
}

local SearchCooldown = 30 -- seconds
local LastSearched = {} -- [player_bin_key] = tick()

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

            giveTool(Player, "Pistol") -- existing in-game tool name
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
        if math.random() < 0.9 then
            Item = TrashLootTable[math.random(1, #TrashLootTable)]
        else
            Item = "stinky boot"
        end

        local Tool = CreateComponentTool(Item)
        giveTool(Player, Tool)
    end
end)
