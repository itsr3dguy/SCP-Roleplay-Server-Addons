-- ===== CONFIG =====
local SupabaseUrl = "https://qjerrbhmlinqnzspfpoo.supabase.co"
local SupabaseKey = "sb_publishable_4ykI9eiygFXvuP3fOl1YMA_qTZJKpfL"
local SoundActivate  = "rbxassetid://114843079311542"
local SoundComplete  = "rbxassetid://136687499892456"
local SoundIncorrect = "rbxassetid://134658487228492"
local SoundConfirm   = "rbxassetid://74004042428981"

-- ===== STATE =====
local AwaitingReport  = {}
local AwaitingConfirm = {}

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
local SoundQ = MakeSound(SoundConfirm)

local function PlaySound(Sound)
    Sound:Stop()
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

    FlickerLight(Color3.fromRGB(0, 220, 50))
    PlaySound(SoundC)
    print("Report filed successfully by " .. Player)
end

-- ===== INTERACTIONS =====
event("interaction", function(Data)
    local Player = Data.Value[1]
    local InteractionName = Data.Value[2]

    if InteractionName == "ReportTerminal" then
        if AwaitingReport[Player] or AwaitingConfirm[Player] then return end
        AwaitingReport[Player] = true

        FlickerLight(Color3.fromRGB(0, 100, 255))
        PlaySound(SoundA)

        print("Report session opened for " .. Player)
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
        AwaitingReport[Player] = nil
        FlickerLight(Color3.fromRGB(255, 0, 0))
        PlaySound(SoundI)
        print("Incorrect format from " .. Player .. ", session closed")
        return
    end

    local ReportText = Message:sub(8)

    AwaitingReport[Player] = nil
    AwaitingConfirm[Player] = ReportText

    PulseLight(Color3.fromRGB(0, 180, 80))
    PlaySound(SoundQ)

    print("Awaiting confirmation from " .. Player .. " for: " .. ReportText)
end)
