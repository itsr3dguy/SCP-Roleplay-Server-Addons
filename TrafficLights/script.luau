-- ============================== CONFIG ==============================
-- ACTUATED one-direction-at-a-time 4-way. Each direction = the light those cars
-- see + the road pad they wait on. A player standing on a pad = a car waiting.
local DIRECTIONS = {
    { light = "TrafficLightOneSouth", pad = "TrafficPadOneNorth" },  -- cars from North
    { light = "TrafficLightOneWest",  pad = "TrafficPadOneEast"  },  -- cars from East
    { light = "TrafficLightOneNorth", pad = "TrafficPadOneSouth" },  -- cars from South
    { light = "TrafficLightOneEast",  pad = "TrafficPadOneWest"  },  -- cars from West
}

-- Crosswalk light heads (all green together on a ped phase). A/B = the two objects.
local CROSSWALK_LIGHTS = {
    "CrosswalkLightOneSouthA", "CrosswalkLightOneSouthB",
    "CrosswalkLightOneNorthA", "CrosswalkLightOneNorthB",
    "CrosswalkLightOneEastA",  "CrosswalkLightOneEastB",
    "CrosswalkLightOneWestA",  "CrosswalkLightOneWestB",
}

-- Pedestrian buttons (interaction parts, by name).
local BUTTONS = {
    "CrosswalkButtonOneSouthA", "CrosswalkButtonOneSouthB",
    "CrosswalkButtonOneNorthA", "CrosswalkButtonOneNorthB",
    "CrosswalkButtonOneWestA",  "CrosswalkButtonOneWestB",
    "CrosswalkButtonOneEastA",  "CrosswalkButtonOneEastB",
}

-- Timings (seconds).
local MIN_GREEN  = 4    -- a green lasts at least this long before it can switch
local AMBER_TIME = 2
local PED_GREEN  = 7
local ALL_RED    = 1.5
local PAD_HEIGHT = 6    -- how far above the pad still counts as "on" it

-- Colors.
local RED   = Color3.new(0.85, 0.10, 0.10)
local AMBER = Color3.new(0.95, 0.65, 0.05)
local GREEN = Color3.new(0.15, 0.80, 0.20)

local TICK = 0.2

-- ============================== STATE ==============================
local current = 1          -- index of the currently-green direction
local phase   = "GREEN"    -- GREEN, AMBER, PED, PED_CLEAR
local timer   = 0
local nextDir = nil        -- index to switch to, or "PED"
local pedRequested = false

local function paintNames(names, color)
    for _, name in ipairs(names) do
        local p = f(name)
        if p then p.Color = color end
    end
end

-- Is a car (player) standing on this direction's pad?
local function hasCar(dir)
    local pad = f(dir.pad)
    if not pad then return false end
    local c = pad.Position
    local sx, sz = pad.Size.X / 2, pad.Size.Z / 2
    for _, name in ipairs(getPlayers()) do
        local pos = getPlayerPosition(name)
        if pos then
            local dx, dy, dz = pos.X - c.X, pos.Y - c.Y, pos.Z - c.Z
            if math.abs(dx) <= sx and math.abs(dz) <= sz and math.abs(dy) <= PAD_HEIGHT then
                return true
            end
        end
    end
    return false
end

-- Next direction (round-robin from current) that has a car waiting; nil if none.
local function nextDemanded()
    local n = #DIRECTIONS
    for step = 1, n do
        local idx = ((current - 1 + step) % n) + 1
        if idx ~= current and hasCar(DIRECTIONS[idx]) then return idx end
    end
    return nil
end

local function render()
    for i, dir in ipairs(DIRECTIONS) do
        local col = RED
        if phase == "GREEN" and i == current then col = GREEN
        elseif phase == "AMBER" and i == current then col = AMBER end
        paintNames({ dir.light }, col)
    end
    paintNames(CROSSWALK_LIGHTS, (phase == "PED") and GREEN or RED)
end

-- ============================== EVENTS ==============================
event("interaction", function(Data)
    local part = Data.Value[2]
    for _, b in ipairs(BUTTONS) do
        if part == b then
            pedRequested = true
        end
    end
end)

-- ============================== STARTUP CHECK ==============================
-- Verify every light and pad exists. (Buttons are interaction parts, checked live.)
local missing = {}
local function check(name)
    if f(name) == nil then missing[#missing + 1] = name end
end
for _, dir in ipairs(DIRECTIONS) do check(dir.light); check(dir.pad) end
for _, name in ipairs(CROSSWALK_LIGHTS) do check(name) end

if #missing == 0 then
    print("[TL] All parts found. :D")
else
    print("[TL] Missing: " .. table.concat(missing, ", "))
end

-- ============================== MASTER LOOP ==============================
render()

while true do
    wait(TICK)
    timer = timer + TICK

    if phase == "GREEN" then
        if timer >= MIN_GREEN then
            if pedRequested then
                nextDir = "PED"; phase = "AMBER"; timer = 0; render()
            else
                local nd = nextDemanded()
                if nd then
                    nextDir = nd; phase = "AMBER"; timer = 0; render()
                end
                -- otherwise: stay green (rest on this direction)
            end
        end

    elseif phase == "AMBER" then
        if timer >= AMBER_TIME then
            if nextDir == "PED" then
                phase = "PED"; pedRequested = false
            else
                current = nextDir; phase = "GREEN"
            end
            timer = 0; render()
        end

    elseif phase == "PED" then
        if timer >= PED_GREEN then phase = "PED_CLEAR"; timer = 0; render() end

    elseif phase == "PED_CLEAR" then
        if timer >= ALL_RED then phase = "GREEN"; timer = 0; render() end
    end
end
