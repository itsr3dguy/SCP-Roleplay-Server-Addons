-- ===== CONFIG =====
local SupabaseUrl = "YOUR_SUPABASE_URL" -- change me please. :)
local SupabaseKey = "YOUR_SUPABASE_ANON_KEY" -- change me please. :)
local SoundActivate  = "rbxassetid://114843079311542"
local SoundComplete  = "rbxassetid://136687499892456"
local SoundIncorrect = "rbxassetid://134658487228492"
local SoundConfirm   = "rbxassetid://74004042428981"

local ReportTimeout  = 300
local ConfirmTimeout = 10
local RequiredKeycard = ""
local ReportScore = 10
local TerminalCount = 1 -- Number of terminals in your map. Name them ReportTerminal1, ReportTerminal2, etc. Optional exits: ReportExit1, ReportExit2, etc. (each ends only its matching terminal's session)
local LightHeight = 2 -- studs above the terminal to place the light

local KeycardRank = {
    ["L1"] = 1, ["L2"] = 2, ["L3"] = 3, ["L4"] = 4, ["O5"] = 5,
}

-- ===== STATE =====
local Terminals       = {}
local ExitParts       = {}
local PlayerTerminal  = {}
local AwaitingReport  = {}
local AwaitingConfirm = {}
local SessionToken    = {}

-- ===== HELPERS =====
local function GetTerminal(Player)
    local Name = PlayerTerminal[Player]
    if not Name then return nil end
    return Terminals[Name]
end

local function IsSessionActive(Player)
    return AwaitingReport[Player] or AwaitingConfirm[Player] ~= nil
end

local function PlaySound(Part, SoundId)
    local Sound = Instance.new("Sound")
    Sound.SoundId = SoundId
    Sound.Volume = 3
    Sound.Parent = Part
    playSound(Sound)
end

-- ===== LIGHT (temp part, created/destroyed on demand) =====
local function RemoveLight(T)
    if T.LightPart then
        T.LightPart:Destroy()
        T.LightPart = nil
    end
end

local function ShowLight(T, Color, Brightness)
    RemoveLight(T)

    local LightPart = Instance.new("Part")
    LightPart.Anchored = true
    LightPart.CanCollide = false
    LightPart.Transparency = 1
    LightPart.Size = Vector3.new(0.2, 0.2, 0.2)

    f(LightPart)

    local Pos = T.Part.Position
    LightPart.Position = Vector3.new(Pos.X, Pos.Y + LightHeight, Pos.Z)

    local Light = Instance.new("PointLight")
    Light.Brightness = Brightness
    Light.Range = 16
    Light.Color = Color
    Light.Parent = LightPart

    T.LightPart = LightPart
end

local function FlickerLight(T, Color)
    ShowLight(T, Color, 5)
    task.wait(0.2)
    RemoveLight(T)
    task.wait(0.15)
    ShowLight(T, Color, 5)
    task.wait(0.2)
    RemoveLight(T)
end

local function PulseLight(T, Color)
    ShowLight(T, Color, 3)
end

local function EndSession(Player)
    SessionToken[Player] = (SessionToken[Player] or 0) + 1
    local T = GetTerminal(Player)
    if T then
        T.InUse = false
        T.User  = nil
        RemoveLight(T)
    end
    AwaitingReport[Player]  = nil
    AwaitingConfirm[Player] = nil
    PlayerTerminal[Player]  = nil
end

local function HasAccess(Player)
    if RequiredKeycard == "" then return true end
    local Keycard = getPlayerKeycard(Player)
    local PlayerRank   = KeycardRank[Keycard] or 0
    local RequiredRank = KeycardRank[RequiredKeycard] or 0
    return PlayerRank >= RequiredRank
end

local function SubmitReport(Player, ReportText)
    local T = GetTerminal(Player)

    http(
        SupabaseUrl .. "/functions/v1/report-complete",
        "post",
        {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. SupabaseKey
        },
        jsonEncode({ player = Player, message = ReportText })
    )

    local CurrentScore = getPlayerScore(Player) or 0
    setPlayerScore(Player, CurrentScore + ReportScore)

    if T then
        FlickerLight(T, Color3.fromRGB(0, 220, 50))
        PlaySound(T.Part, SoundComplete)
    end

    EndSession(Player)
end

-- ===== REGISTRATION POLLING =====
local function RegisterAll()
    -- terminals
    for i = 1, TerminalCount do
        local Name = "ReportTerminal" .. i
        if not Terminals[Name] then
            local Part = f(Name)
            if Part then
                Terminals[Name] = {
                    Part      = Part,
                    LightPart = nil,
                    InUse     = false,
                    User      = nil,
                }
                print("Registered terminal: " .. Name)
            end
        end
    end

    -- exits (each ReportExitN ends only ReportTerminalN's session)
    for i = 1, TerminalCount do
        local Name = "ReportExit" .. i
        if not ExitParts[Name] then
            local ExitPart = f(Name)
            if ExitPart then
                local TerminalName = "ReportTerminal" .. i
                ExitPart.Touched:Connect(function(Player)
                    if Player
                    and IsSessionActive(Player)
                    and PlayerTerminal[Player] == TerminalName then
                        local T = GetTerminal(Player)
                        if T then
                            FlickerLight(T, Color3.fromRGB(255, 0, 0))
                            PlaySound(T.Part, SoundIncorrect)
                        end
                        EndSession(Player)
                    end
                end)
                ExitParts[Name] = true
                print("Registered exit: " .. Name .. " -> " .. TerminalName)
            end
        end
    end
end

task.spawn(function()
    while true do
        RegisterAll()
        task.wait(3)
    end
end)

-- ===== DEATH / SPAWN / LEFT =====
event("death", function(Data)
    local Player = Data.Value
    if Player and IsSessionActive(Player) then EndSession(Player) end
end)

event("spawned", function(Data)
    local Player = Data.Value
    if Player and IsSessionActive(Player) then EndSession(Player) end
end)

event("left", function(Data)
    local Player = Data.Value
    if Player and IsSessionActive(Player) then EndSession(Player) end
end)

-- ===== INTERACTIONS =====
event("interaction", function(Data)
    local Player = Data.Value[1]
    local InteractionName = Data.Value[2]

    local T = Terminals[InteractionName]
    if not T then return end

    if not HasAccess(Player) then
        FlickerLight(T, Color3.fromRGB(255, 0, 0))
        PlaySound(T.Part, SoundIncorrect)
        return
    end

    if T.InUse and T.User ~= Player then
        FlickerLight(T, Color3.fromRGB(255, 0, 0))
        return
    end

    if IsSessionActive(Player) then return end

    T.InUse = true
    T.User  = Player
    PlayerTerminal[Player] = InteractionName
    AwaitingReport[Player] = true

    local MyToken = (SessionToken[Player] or 0)

    FlickerLight(T, Color3.fromRGB(0, 100, 255))
    PlaySound(T.Part, SoundActivate)

    task.delay(ReportTimeout, function()
        if SessionToken[Player] == MyToken and AwaitingReport[Player] then
            FlickerLight(T, Color3.fromRGB(255, 0, 0))
            PlaySound(T.Part, SoundIncorrect)
            EndSession(Player)
        end
    end)
end)

-- ===== CHAT LISTENER =====
event("chatted", function(Data)
    local Player = Data.Value[1]
    local Message = Data.Value[2]
    local MsgLower = Message:lower()

    if not IsSessionActive(Player) then return end

    local T = GetTerminal(Player)
    if not T then return end
    if T.User ~= Player then return end

    -- ===== CONFIRMATION STAGE =====
    if AwaitingConfirm[Player] ~= nil then
        local FirstWord = MsgLower:match("^(%S+)")

        if FirstWord == "yes" or FirstWord == "y" then
            local ReportText = AwaitingConfirm[Player]
            SubmitReport(Player, ReportText)
        elseif FirstWord == "no" or FirstWord == "n" then
            FlickerLight(T, Color3.fromRGB(255, 0, 0))
            PlaySound(T.Part, SoundIncorrect)
            EndSession(Player)
        end
        return
    end

    -- ===== REPORT STAGE =====
    if not AwaitingReport[Player] then return end

    local Prefix = Message:sub(1, 7):upper()

    if Prefix ~= "REPORT " then
        FlickerLight(T, Color3.fromRGB(255, 0, 0))
        PlaySound(T.Part, SoundIncorrect)
        EndSession(Player)
        return
    end

    local ReportText = Message:sub(8)

    AwaitingReport[Player]  = nil
    AwaitingConfirm[Player] = ReportText

    local MyToken = (SessionToken[Player] or 0)

    PulseLight(T, Color3.fromRGB(0, 180, 80))
    PlaySound(T.Part, SoundConfirm)

    task.delay(ConfirmTimeout, function()
        if SessionToken[Player] == MyToken and AwaitingConfirm[Player] == ReportText then
            FlickerLight(T, Color3.fromRGB(255, 0, 0))
            PlaySound(T.Part, SoundIncorrect)
            EndSession(Player)
        end
    end)
end)
