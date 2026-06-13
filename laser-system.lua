-- ===== VARS =====
local LasersActive = false
local Lasers = {}

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

-- ===== BUTTON TOGGLE =====
event("interaction", function(Data)
    local InteractionName = Data.Value[2]

    if InteractionName == "LaserButton" then
        LasersActive = not LasersActive

        for _, Laser in pairs(Lasers) do
            Laser.Transparency = LasersActive and 0.3 or 0.9
        end

        if LasersActive then
            announce("WARNING: Laser grid activated.")
        else
            announce("Laser grid deactivated.", true)
        end
    end
end)
