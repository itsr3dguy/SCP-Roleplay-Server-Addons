-- ===== CONFIG =====
local SupabaseUrl = "YOUR_SUPABASE_URL" -- change me please. :)
local SupabaseKey = "YOUR_SUPABASE_ANON_KEY" -- change me please. :)
local DeliveryScore = 5
local SoundStart      = "rbxassetid://88349156845443"
local SoundEnd        = "rbxassetid://125705519082042"
local SoundNoBoxes    = "rbxassetid://130167698615173" -- end pressed without boxes
local SoundHasBoxes   = "rbxassetid://128833235265400" -- start pressed while already holding boxes

local BoxMesh    = "rbxassetid://104428136064222"
local BoxTexture = "rbxassetid://98782465982020"

-- ===== SOUND HELPER =====
local function PlaySound(PartName, SoundId)
    local Part = f(PartName)
    if not Part then return end
    local Sound = Instance.new("Sound")
    Sound.SoundId = SoundId
    Sound.Volume = 3
    Sound.RollOffMode = Enum.RollOffMode.Linear
    Sound.RollOffMinDistance = 50
    Sound.RollOffMaxDistance = 100
    Sound.Parent = Part
    playSound(Sound)
end

-- ===== BOX TOOL =====
local function GiveBox(Player)
    local Tool = Instance.new("Tool")
    Tool.Name = "Boxes"
    Tool.CanBeDropped = false

    local Part = Instance.new("Part")
    Part.Name = "Handle"
    Part.Size = Vector3.new(1.5, 1.5, 1.5)
    Part.CFrame = CFrame.new(999, 9999, 999)
	Tool.Grip = CFrame.Angles(0, math.rad(-90), math.rad(-90))

    f(Tool)
    Part.Parent = Tool

    -- apply mesh + texture
    local Mesh = Instance.new("SpecialMesh")
    Mesh.MeshType = Enum.MeshType.FileMesh
    Mesh.MeshId = BoxMesh
    Mesh.TextureId = BoxTexture
	Mesh.Scale = Vector3.new(4, 4, 4)
	Mesh.Offset = Vector3.new(1, 0, 0.5)
    Mesh.Parent = Part

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
        if hasTool(Player, "Boxes") then
            SetButtonColor("DeliveryStart", Color3.new(1, 0, 0))
            PlaySound("DeliveryStart", SoundHasBoxes)
            task.wait(0.5)
            SetButtonColor("DeliveryStart", Color3.fromRGB(0, 0, 139))
            return
        end
        GiveBox(Player)
        SetButtonColor("DeliveryStart", Color3.fromRGB(0, 0, 139))
        PlaySound("DeliveryStart", SoundStart)
    end

    -- ===== DELIVERY END =====
    if InteractionName == "DeliveryEnd" then
        if not hasTool(Player, "Boxes") then
            SetButtonColor("DeliveryEnd", Color3.new(1, 0, 0))
            PlaySound("DeliveryEnd", SoundNoBoxes)
            task.wait(0.5)
            SetButtonColor("DeliveryEnd", Color3.new(1, 1, 1))
            return
        end
        removeTool(Player, "Boxes")
        local CurrentScore = getPlayerScore(Player) or 0
        local NewScore = CurrentScore + DeliveryScore
        setPlayerScore(Player, NewScore)
        SetButtonColor("DeliveryStart", Color3.new(1, 1, 1))
        SetButtonColor("DeliveryEnd", Color3.new(0, 1, 0))
        PlaySound("DeliveryEnd", SoundEnd)
        task.wait(0.5)
        SetButtonColor("DeliveryEnd", Color3.new(1, 1, 1))

        http(
            SupabaseUrl .. "/functions/v1/delivery-complete",
            "post",
            {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. SupabaseKey
            },
            jsonEncode({ player = Player })
        )
    end
end)
