-- ===== VARS =====
local LasersActive = false
local Lasers = {}
local RequiredKeycard = "" -- change with one of the things inside the KeycardRank table thing. None = no keycard required
local KeycardRank = {
    ["L1"] = 1,
    ["L2"] = 2,
    ["L3"] = 3,
    ["L4"] = 4,
    ["O5"] = 5,
}

-- ===== GET LASER PARTS BY NAME =====
local i = 1
while true do
    local Laser = f("Laser" .. i)
    if not Laser then break end

    Laser.CanCollide = false
    Laser.Transparency = 0.9

    table.insert(Lasers, Laser)

    Laser.Touched:Connect(function(Player)
        if not LasersActive then return end
        if Player and getPlayerHealth(Player) > 0 then
            kill(Player)
        end
    end)

    i = i + 1
end

announce("Lasers found: " .. #Lasers)

-- ===== ACCESS DENIED FLICKER =====
local function FlickerDenied(Button)
    tween(Button, TweenInfo.new(0.1), {Color = Color3.new(1, 0, 0)})
    task.wait(0.25)
    tween(Button, TweenInfo.new(0.1), {Color = Color3.new(1, 1, 1)})
    task.wait(0.25)
    tween(Button, TweenInfo.new(0.1), {Color = Color3.new(1, 0, 0)})
    task.wait(0.1)
    tween(Button, TweenInfo.new(0.1), {Color = Color3.new(1, 1, 1)})
end

-- ===== BUTTON TOGGLE =====
event("interaction", function(Data)
    local Player = Data.Value[1]
    local InteractionName = Data.Value[2]

    if InteractionName == "LaserButton" then
        if RequiredKeycard ~= "" then
            local Keycard = getPlayerKeycard(Player)
            local PlayerRank = KeycardRank[Keycard] or 0
            local RequiredRank = KeycardRank[RequiredKeycard] or 0

            if PlayerRank < RequiredRank then
                local Button = f("LaserButton")
                if Button then
                    FlickerDenied(Button)
                end
                return
            end
        end

        LasersActive = not LasersActive

        for _, Laser in pairs(Lasers) do
            Laser.Transparency = LasersActive and 0.3 or 0.9
        end

        if LasersActive then
            announce("WARNING: Laser grid activated.", true)
        else
            announce("Laser grid deactivated.")
        end
    end
end)
