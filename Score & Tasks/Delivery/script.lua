-- ===== CONFIG =====
local SupabaseUrl = "YOUR_SUPABASE_URL" -- change me please. :)
local SupabaseKey = "YOUR_SUPABASE_ANON_KEY" -- change me please. :)
local DeliveryScore = 5
-- ===== BOX TOOL =====
local function GiveBox(Player)
    local Tool = Instance.new("Tool")
    Tool.Name = "Box"
    Tool.CanBeDropped = false
    local Part = Instance.new("Part")
    Part.Name = "Handle"
    Part.Size = Vector3.new(1.5, 1.5, 1.5)
    Part.CFrame = CFrame.new(999, 9999, 999)
    Part.Color = Color3.fromRGB(139, 90, 43)
    Part.Material = Enum.Material.SmoothPlastic
    f(Tool)
    Part.Parent = Tool
    giveTool(Player, Tool)
end
-- ===== BUTTON COLOR HELPER =====
local function SetButtonColor(ButtonName, Color)
    local Button = f(ButtonName)
    if Button then
        tween(Button, TweenInfo.new(0.3), {Color = Color})
    end
end
-- ===== INTERACTIONS =====
event("interaction", function(Data)
    local Player = Data.Value[1]
    local InteractionName = Data.Value[2]
    -- ===== DELIVERY START =====
    if InteractionName == "DeliveryStart" then
        if hasTool(Player, "Box") then
            SetButtonColor("DeliveryStart", Color3.new(1, 0, 0))
            task.wait(0.5)
            SetButtonColor("DeliveryStart", Color3.fromRGB(0, 0, 139))
            return
        end
        GiveBox(Player)
        SetButtonColor("DeliveryStart", Color3.fromRGB(0, 0, 139))
    end
    -- ===== DELIVERY END =====
    if InteractionName == "DeliveryEnd" then
        if not hasTool(Player, "Box") then
            SetButtonColor("DeliveryEnd", Color3.new(1, 0, 0))
            task.wait(0.5)
            SetButtonColor("DeliveryEnd", Color3.new(1, 1, 1))
            return
        end
        removeTool(Player, "Box")
        local CurrentScore = getPlayerScore(Player) or 0
        local NewScore = CurrentScore + DeliveryScore
        setPlayerScore(Player, NewScore)
        SetButtonColor("DeliveryStart", Color3.new(1, 1, 1))
        SetButtonColor("DeliveryEnd", Color3.new(0, 1, 0))
        task.wait(0.5)
        SetButtonColor("DeliveryEnd", Color3.new(1, 1, 1))
        -- call edge function
print("Calling edge function...")
        http(
            SupabaseUrl .. "/functions/v1/delivery-complete",
            "post",
            {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. SupabaseKey
            },
            jsonEncode({ player = Player })
        )
print("Edge function called")
    end
end)
