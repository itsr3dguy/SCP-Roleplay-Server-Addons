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

local KeycardRank = {
    ["L1"] = 1, ["L2"] = 2, ["L3"] = 3, ["L4"] = 4, ["O5"] = 5,
}

-- ===== TERMINAL REGISTRY =====
local TerminalCount = 1 -- Number of terminals in your map. Name them ReportTerminal1, ReportTerminal2, etc.
local Terminals = {}

for i = 1, TerminalCount do
    local Name = "ReportTerminal" .. i
    local Part = f(Name)

    if Part then
        local Light = Instance.new("PointLight")
        Light.Brightness = 0
        Light.Range = 16
        Light.Color = Color3.fromRGB(255, 255, 255)
        Light.Parent = Part

        local function MakeSound(SoundId)
            local Sound = Instance.new("Sound")
            Sound.SoundId = SoundId
            Sound.Volume = 3
            Sound.Parent = Part
            return Sound
        end

        Terminals[Name] = {
            Part   = Part,
            Light  = Light,
            SoundA = MakeSound(SoundActivate),
            SoundC = MakeSound(SoundComplete),
            SoundI = MakeSound(SoundIncorrect),
            InUse  = false,
            User   = nil,
        }

        print("Registered terminal: " .. Name)
    else
        print("Terminal not found: " .. Name)
    end
end

-- ===== STATE =====
local PlayerTerminal  = {}
local AwaitingReport  = {}
local AwaitingConfirm = {}

-- ===== HELPERS =====
local function GetTerminal(Player)
    local Name = PlayerTerminal[Player]
    if not Name then return nil end
    return Terminals[Name]
end

local function PlaySound(Sound)
    Sound:Stop()
    playSound(Sound)
end

local function PlaySoundOnce(SoundId, Part)
    local Sound = Instance.new("Sound")
    Sound.SoundId = SoundId
    Sound.Volume = 3
    Sound.Parent = Part
    playSound(Sound)
end

local function SetLight(T, Color, Brightness)
    tween(T.Light, TweenInfo.new(0.2), {
        Color = Color,
        Brightness = Brightness
    })
end

local function FlickerLight(T, Color)
    SetLight(T, Color, 5)
    task.wait(0.2)
    SetLight(T, Color, 1)
    task.wait(0.15)
    SetLight(T, Color, 5)
    task.wait(0.2)
    SetLight(T, Color, 0)
end

local function PulseLight(T, Color)
    SetLight(T, Color, 3)
end

local function ResetTerminal(Player)
    local T = GetTerminal(Player)
    if T then
        T.InUse = false
        T.User  = nil
        FlickerLight(T, Color3.fromRGB(255, 0, 0))
        PlaySound(T.SoundI)
    end
    AwaitingReport[Player]  = nil
    AwaitingConfirm[Player] = nil
    PlayerTerminal[Player]  = nil
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
        jsonEncode({
            player  = Player,
            message = ReportText
        })
    )

    local CurrentScore = getPlayerScore(Player) or 0
    setPlayerScore(Player, CurrentScore + ReportScore)

    if T then
        T.InUse = false
        T.User  = nil
        FlickerLight(T, Color3.fromRGB(0, 220, 50))
        PlaySound(T.SoundC)
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

-- ===== INTERACTIONS =====
event("interaction", function(Data)
    local Player = Data.Value[1]
    local InteractionName = Data.Value[2]

    local T = Terminals[InteractionName]
    if not T then return end

    if not HasAccess(Player) then
        FlickerLight(T, Color3.fromRGB(255, 0, 0))
        PlaySound(T.SoundI)
        return
    end

    if T.InUse and T.User ~= Player then
        FlickerLight(T, Color3.fromRGB(255, 0, 0))
        return
    end

    if AwaitingReport[Player] or AwaitingConfirm[Player] then return end

    T.InUse = true
    T.User  = Player
    PlayerTerminal[Player] = InteractionName
    AwaitingReport[Player] = true

    FlickerLight(T, Color3.fromRGB(0, 100, 255))
    PlaySound(T.SoundA)

    local SessionPlayer = Player
    task.delay(ReportTimeout, function()
        if AwaitingReport[SessionPlayer] then
            ResetTerminal(SessionPlayer)
        end
    end)
end)

-- ===== CHAT LISTENER =====
event("chatted", function(Data)
    local Player = Data.Value[1]
    local Message = Data.Value[2]
    local MsgLower = Message:lower()

    local T = GetTerminal(Player)
    if not T then return end
    if T.User ~= Player then return end

    -- ===== CONFIRMATION STAGE =====
    if AwaitingConfirm[Player] ~= nil then
        local FirstWord = MsgLower:match("^(%S+)")

        if FirstWord == "yes" or FirstWord == "y" then
            local ReportText = AwaitingConfirm[Player]
            AwaitingConfirm[Player] = nil
            SetLight(T, Color3.fromRGB(0, 0, 0), 0)
            SubmitReport(Player, ReportText)
        elseif FirstWord == "no" or FirstWord == "n" then
            AwaitingConfirm[Player] = nil
            SetLight(T, Color3.fromRGB(0, 0, 0), 0)
            FlickerLight(T, Color3.fromRGB(255, 0, 0))
            PlaySound(T.SoundI)
            T.InUse = false
            T.User  = nil
            PlayerTerminal[Player] = nil
        end
        return
    end

    -- ===== REPORT STAGE =====
    if not AwaitingReport[Player] then return end

    local Prefix = Message:sub(1, 7):upper()

    if Prefix ~= "REPORT " then
        ResetTerminal(Player)
        return
    end

    local ReportText = Message:sub(8)

    AwaitingReport[Player]  = nil
    AwaitingConfirm[Player] = ReportText

    PulseLight(T, Color3.fromRGB(0, 180, 80))
    PlaySoundOnce(SoundConfirm, T.Part)

    local ConfirmPlayer = Player
    local ConfirmText   = ReportText
    task.delay(ConfirmTimeout, function()
        if AwaitingConfirm[ConfirmPlayer] == ConfirmText then
            ResetTerminal(ConfirmPlayer)
        end
    end)
end)
