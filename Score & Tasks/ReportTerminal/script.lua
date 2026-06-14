-- ===== CONFIG =====
local SupabaseUrl = "YOUR_SUPABASE_URL" -- change me please. :)
local SupabaseKey = "YOUR_SUPABASE_ANON_KEY" -- change me please. :)
local SoundActivate  = "rbxassetid://114843079311542"
local SoundComplete  = "rbxassetid://136687499892456"
local SoundIncorrect = "rbxassetid://134658487228492"
local SoundConfirm   = "rbxassetid://74004042428981"

local ReportTimeout  = 300 -- 5 minutes to type report
local ConfirmTimeout = 10  -- 10 seconds to confirm
local RequiredKeycard = "" -- leave empty for no requirement, or set to "L1", "L2", "L3", "L4", "O5"

local KeycardRank = {
    ["L1"] = 1,
    ["L2"] = 2,
    ["L3"] = 3,
    ["L4"] = 4,
    ["O5"] = 5,
}

-- ===== STATE =====
local AwaitingReport  = {}
local AwaitingConfirm = {}
local TerminalInUse   = false
local TerminalUser    = nil

-- ===== SETUP TERMINAL =====
local Terminal = f("ReportTerminal")

-- ===== SETUP LIGHT =====
local Light = Instance.new("PointLight")
Light.Brightness = 0
Light.Range = 16
Light.Color = Color3.fromRGB(255, 255, 255)
Light.Parent = Terminal

-- ===== SETUP SOUNDS =====
local function MakeSound(SoundId)
    local Sound = Instance.new("Sound")
    Sound.SoundId = SoundId
    Sound.Volume = 3
    Sound.Parent = Terminal
    return Sound
end

local SoundA = MakeSound(SoundActivate)
local SoundC = MakeSound(SoundComplete)
local SoundI = MakeSound(SoundIncorrect)

local function PlaySound(Sound)
    Sound:Stop()
    playSound(Sound)
end

local function PlaySoundOnce(SoundId)
    local Sound = Instance.new("Sound")
    Sound.SoundId = SoundId
    Sound.Volume = 3
    Sound.Parent = Terminal
    playSound(Sound)
end

-- ===== LIGHT HELPERS =====
local function SetLight(Color, Brightness)
    tween(Light, TweenInfo.new(0.2), {
        Color = Color,
        Brightness = Brightness
    })
end

local function FlickerLight(Color)
    SetLight(Color, 5)
    task.wait(0.2)
    SetLight(Color, 1)
    task.wait(0.15)
    SetLight(Color, 5)
    task.wait(0.2)
    SetLight(Color, 0)
end

local function PulseLight(Color)
    SetLight(Color, 3)
end

-- ===== RESET TERMINAL =====
local function ResetTerminal(Player)
    AwaitingReport[Player]  = nil
    AwaitingConfirm[Player] = nil
    TerminalInUse           = false
    TerminalUser            = nil

    FlickerLight(Color3.fromRGB(255, 0, 0))
    PlaySound(SoundI)
    print("Terminal reset, session expired for " .. tostring(Player))
end

-- ===== SUBMIT =====
local function SubmitReport(Player, ReportText)
    http(
        SupabaseUrl .. "/rest/v1/reports",
        "post",
        {
            ["Content-Type"] = "application/json",
            ["apikey"] = SupabaseKey,
            ["Authorization"] = "Bearer " .. SupabaseKey,
            ["Prefer"] = "return=minimal"
        },
        jsonEncode({
            player = Player,
            message = ReportText
        })
    )

    TerminalInUse = false
    TerminalUser  = nil

    FlickerLight(Color3.fromRGB(0, 220, 50))
    PlaySound(SoundC)
    print("Report filed successfully by " .. Player)
end

-- ===== KEYCARD CHECK =====
local function HasAccess(Player)
    if RequiredKeycard == "" then return true end
    local Keycard = getPlayerKeycard(Player)
    local PlayerRank = KeycardRank[Keycard] or 0
    local RequiredRank = KeycardRank[RequiredKeycard] or 0
    return PlayerRank >= RequiredRank
end

-- ===== INTERACTIONS =====
event("interaction", function(Data)
    local Player = Data.Value[1]
    local InteractionName = Data.Value[2]

    if InteractionName == "ReportTerminal" then
        -- keycard check
        if not HasAccess(Player) then
            FlickerLight(Color3.fromRGB(255, 0, 0))
            PlaySound(SoundI)
            print("Access denied for " .. Player .. " — insufficient keycard")
            return
        end

        -- block if terminal already in use by someone else
        if TerminalInUse and TerminalUser ~= Player then
            FlickerLight(Color3.fromRGB(255, 0, 0))
            print("Terminal in use by " .. tostring(TerminalUser) .. ", blocked " .. Player)
            return
        end

        if AwaitingReport[Player] or AwaitingConfirm[Player] then return end

        TerminalInUse = true
        TerminalUser  = Player
        AwaitingReport[Player] = true

        FlickerLight(Color3.fromRGB(0, 100, 255))
        PlaySound(SoundA)

        print("Report session opened for " .. Player)

        -- 5 minute report timeout
        local SessionPlayer = Player
        task.delay(ReportTimeout, function()
            if AwaitingReport[SessionPlayer] then
                print("Report timed out for " .. SessionPlayer)
                ResetTerminal(SessionPlayer)
            end
        end)
    end
end)

-- ===== CHAT LISTENER =====
event("chatted", function(Data)
    local Player = Data.Value[1]
    local Message = Data.Value[2]
    local MsgLower = Message:lower()

    -- ===== CONFIRMATION STAGE =====
    if AwaitingConfirm[Player] then
        if MsgLower == "yes" or MsgLower == "y" then
            local ReportText = AwaitingConfirm[Player]
            AwaitingConfirm[Player] = nil
            SetLight(Color3.fromRGB(0, 0, 0), 0)
            SubmitReport(Player, ReportText)
        elseif MsgLower == "no" or MsgLower == "n" then
            AwaitingConfirm[Player] = nil
            TerminalInUse = false
            TerminalUser  = nil
            SetLight(Color3.fromRGB(0, 0, 0), 0)
            FlickerLight(Color3.fromRGB(255, 0, 0))
            PlaySound(SoundI)
            print("Report cancelled by " .. Player)
        end
        return
    end

    -- ===== REPORT STAGE =====
    if not AwaitingReport[Player] then return end

    local Prefix = Message:sub(1, 7):upper()

    if Prefix ~= "REPORT " then
        ResetTerminal(Player)
        print("Incorrect format from " .. Player .. ", session closed")
        return
    end

    local ReportText = Message:sub(8)

    AwaitingReport[Player]  = nil
    AwaitingConfirm[Player] = ReportText

    PulseLight(Color3.fromRGB(0, 180, 80))
    PlaySoundOnce(SoundConfirm)

    print("Awaiting confirmation from " .. Player .. " for: " .. ReportText)

    -- 10 second confirm timeout
    local ConfirmPlayer = Player
    local ConfirmText   = ReportText
    task.delay(ConfirmTimeout, function()
        if AwaitingConfirm[ConfirmPlayer] == ConfirmText then
            print("Confirm timed out for " .. ConfirmPlayer)
            ResetTerminal(ConfirmPlayer)
        end
    end)
end)
