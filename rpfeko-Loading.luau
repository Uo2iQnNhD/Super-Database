--[[ ============================================================
    RO-NETRIUM • GAME CHECKER LOADING SCREEN (STANDALONE)
    - RGB Rainbow theme + rainbow loading bar
    - Crystal / dot / spark / orb particles + shimmer sweep
    - Fast place check (gated at 90% until info ready)
    - Executor + Server ID line
    - 100% -> execute Detection -> destroy UI
============================================================ ]]

local CONFIG = {
    GuiName   = "RoNetriumGameChecker",
    Brand     = "Ro-Netrium",
    Title     = "GAME CHECKER",
    Subtitle  = "Verifying environment & game support",
    Icon      = "rbxassetid://7734056411", -- shield-check
    Background= Color3.fromRGB(10, 10, 12),
    Element   = Color3.fromRGB(22, 22, 26),
    Text      = Color3.fromRGB(255, 255, 255),
    SubText   = Color3.fromRGB(170, 170, 178),
    RainbowSpeed = 0.14,
    CheckDuration = 5.0,   -- detik 0 -> 90 (cepat)
    FinishDuration = 1, -- detik 90 -> 100
    InfoTimeout = 4.0,     -- max tunggu fetch info
    HoldAt100 = 0.35,
    FadeTime  = 0.4,
    ScriptURL = "https://raw.githubusercontent.com/Zyptrue/xTicAYRgProtection/refs/heads/main/Detection",
}

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

--// [1] Purge GUI lama
local function purgeOld()
    local parents = {}
    pcall(function() table.insert(parents, game:GetService("CoreGui")) end)
    pcall(function() table.insert(parents, LocalPlayer:WaitForChild("PlayerGui")) end)
    if typeof(gethui) == "function" then pcall(function() table.insert(parents, gethui()) end) end
    for _, p in ipairs(parents) do
        if p then
            for _, c in ipairs(p:GetChildren()) do
                if c.Name == CONFIG.GuiName or c.Name == "ZethGameChecker" then
                    pcall(function() c:Destroy() end)
                end
            end
        end
    end
end
purgeOld()

--// [2] Helpers
local function corner(o, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = o; return c
end
local function stroke(o, col, th)
    local s = Instance.new("UIStroke"); s.Color = col; s.Thickness = th or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = o; return s
end
local function label(parent, size, pos, text, ts, font, color, align)
    local l = Instance.new("TextLabel")
    l.Size = size; l.Position = pos; l.BackgroundTransparency = 1
    l.Text = text; l.TextSize = ts; l.Font = font; l.TextColor3 = color
    l.TextXAlignment = align or Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.ZIndex = 7; l.Parent = parent; return l
end
local function rainbowSeq()
    return ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 150, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 120)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 200, 255)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(80, 80, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 200)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
    }
end
local function hueColor(offset)
    return Color3.fromHSV((os.clock() * CONFIG.RainbowSpeed + (offset or 0)) % 1, 1, 1)
end
local function getExecutorName()
    if typeof(identifyexecutor) == "function" then
        local ok, n = pcall(identifyexecutor)
        if ok and type(n) == "string" and n ~= "" then return n end
    end
    if typeof(getexecutorname) == "function" then
        local ok, n = pcall(getexecutorname)
        if ok and type(n) == "string" and n ~= "" then return n end
    end
    if syn then return "Synapse X" end
    if fluxus then return "Fluxus" end
    if KRNL_LOADED then return "Krnl" end
    return "Unknown Executor"
end

--// [3] GUI
local gui = Instance.new("ScreenGui")
gui.Name = CONFIG.GuiName
gui.ResetOnSpawn = false
gui.DisplayOrder = 99999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end) end

local dim = Instance.new("Frame")
dim.Size = UDim2.new(1, 0, 1, 0)
dim.BackgroundColor3 = Color3.new(0, 0, 0)
dim.BackgroundTransparency = 0.5
dim.BorderSizePixel = 0
dim.ZIndex = 1
dim.Parent = gui

--// [4] Particle background (crystal + dot + spark + orb)
local layer = Instance.new("Frame")
layer.Name = "Particles"
layer.Size = UDim2.new(1, 0, 1, 0)
layer.BackgroundTransparency = 1
layer.BorderSizePixel = 0
layer.ClipsDescendants = true
layer.ZIndex = 2
layer.Parent = gui

local particles = {}
local function addParticle(kind)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.ZIndex = 2
    f.Active = false
    local d = { f = f, kind = kind, hue = math.random(), phase = math.random() * 6.28, speed = 0.6 + math.random() * 1.4 }
    if kind == "crystal" then
        local s = math.random(6, 14)
        f.Size = UDim2.new(0, s, 0, s)
        f.Rotation = 45
        corner(f, 2)
        f.BackgroundTransparency = 0.55 + math.random() * 0.25
        d.vx = (math.random() - 0.5) * 22
        d.vy = (math.random() - 0.5) * 22
        d.spin = (math.random() - 0.5) * 60
    elseif kind == "dot" then
        local s = math.random(2, 5)
        f.Size = UDim2.new(0, s, 0, s)
        corner(f, 99)
        f.BackgroundTransparency = 0.4 + math.random() * 0.35
        d.vx = (math.random() - 0.5) * 30
        d.vy = (math.random() - 0.5) * 30
        d.spin = 0
    elseif kind == "spark" then
        local s = math.random(2, 3)
        f.Size = UDim2.new(0, s, 0, s)
        corner(f, 99)
        f.BackgroundTransparency = 0.35
        d.vx = (math.random() - 0.5) * 10
        d.vy = -(30 + math.random() * 40)
        d.spin = 0
    else -- orb
        local s = math.random(18, 30)
        f.Size = UDim2.new(0, s, 0, s)
        corner(f, 99)
        f.BackgroundTransparency = 0.88
        d.vx = (math.random() - 0.5) * 12
        d.vy = (math.random() - 0.5) * 12
        d.spin = 0
    end
    d.baseT = f.BackgroundTransparency
    d.x = nil; d.y = nil
    f.Parent = layer
    table.insert(particles, d)
end
for _ = 1, 14 do addParticle("crystal") end
for _ = 1, 18 do addParticle("dot") end
for _ = 1, 12 do addParticle("spark") end
for _ = 1, 6  do addParticle("orb") end

--// [5] Card (fixed layout, no overflow)
local card = Instance.new("Frame")
card.Name = "CheckerCard"
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.new(0.5, 0, 0.5, 0)
card.Size = UDim2.new(0, 500, 0, 204)
card.BackgroundColor3 = CONFIG.Background
card.BorderSizePixel = 0
card.ClipsDescendants = true
card.ZIndex = 5
card.Parent = gui
corner(card, 12)
local cardStroke = stroke(card, Color3.new(1, 1, 1), 2)
local cardGlow = stroke(card, Color3.new(1, 1, 1), 5)
cardGlow.Transparency = 0.72
pcall(function()
    local sh = Instance.new("UIDropShadow")
    sh.Color = Color3.new(0, 0, 0); sh.Transparency = 0.5
    sh.Size = UDim2.new(0, 26, 0, 26); sh.Offset = Vector2.new(0, 8)
    sh.Parent = card
end)

-- Shimmer sweep
local shimmer = Instance.new("Frame")
shimmer.Name = "Shimmer"
shimmer.Size = UDim2.new(0, 70, 1, 0)
shimmer.Position = UDim2.new(-0.2, 0, 0, 0)
shimmer.BackgroundColor3 = Color3.new(1, 1, 1)
shimmer.BorderSizePixel = 0
shimmer.ZIndex = 6
shimmer.Parent = card
local shimGrad = Instance.new("UIGradient")
shimGrad.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0.88),
    NumberSequenceKeypoint.new(1, 1),
}
shimGrad.Parent = shimmer

local icon = Instance.new("ImageLabel")
icon.Size = UDim2.new(0, 40, 0, 40)
icon.Position = UDim2.new(0, 18, 0, 18)
icon.BackgroundTransparency = 1
icon.Image = CONFIG.Icon
icon.ImageColor3 = Color3.new(1, 1, 1)
icon.ZIndex = 7
icon.Parent = card

label(card, UDim2.new(1, -160, 0, 22), UDim2.new(0, 68, 0, 20), CONFIG.Title, 17, Enum.Font.GothamBlack, CONFIG.Text)
label(card, UDim2.new(1, -160, 0, 16), UDim2.new(0, 68, 0, 44), CONFIG.Subtitle, 11, Enum.Font.Gotham, CONFIG.SubText)

local badge = Instance.new("TextLabel")
badge.Size = UDim2.new(0, 130, 0, 24)
badge.Position = UDim2.new(1, -148, 0, 20)
badge.BackgroundColor3 = CONFIG.Element
badge.BorderSizePixel = 0
badge.Text = "CHECKING..."
badge.TextColor3 = CONFIG.SubText
badge.TextSize = 10
badge.Font = Enum.Font.GothamBold
badge.ZIndex = 7
badge.Parent = card
corner(badge, 99)

local gameName = label(card, UDim2.new(1, -36, 0, 20), UDim2.new(0, 18, 0, 78), "Detecting place...", 14, Enum.Font.GothamBold, CONFIG.Text)
local meta1 = label(card, UDim2.new(1, -36, 0, 14), UDim2.new(0, 18, 0, 100), "PlaceId -  |  Universe -", 10, Enum.Font.Gotham, CONFIG.SubText)
local meta2 = label(card, UDim2.new(1, -36, 0, 14), UDim2.new(0, 18, 0, 116), "Executor: -  |  Server ID: -", 10, Enum.Font.Gotham, CONFIG.SubText)

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -36, 0, 1)
divider.Position = UDim2.new(0, 18, 0, 138)
divider.BackgroundColor3 = Color3.new(1, 1, 1)
divider.BackgroundTransparency = 0.55
divider.BorderSizePixel = 0
divider.ZIndex = 7
divider.Parent = card
corner(divider, 99)

local stepLbl = label(card, UDim2.new(1, -100, 0, 16), UDim2.new(0, 18, 0, 150), "Starting...", 11, Enum.Font.GothamMedium, CONFIG.SubText)
local pctLbl = label(card, UDim2.new(0, 64, 0, 16), UDim2.new(1, -82, 0, 150), "0%", 11, Enum.Font.GothamBold, Color3.new(1, 1, 1), Enum.TextXAlignment.Right)

local track = Instance.new("Frame")
track.Size = UDim2.new(1, -36, 0, 6)
track.Position = UDim2.new(0, 18, 0, 172)
track.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
track.BackgroundTransparency = 0.2
track.BorderSizePixel = 0
track.ClipsDescendants = true
track.ZIndex = 7
track.Parent = card
corner(track, 99)

local fill = Instance.new("Frame")
fill.Size = UDim2.new(0, 0, 1, 0)
fill.BackgroundColor3 = Color3.new(1, 1, 1)
fill.BorderSizePixel = 0
fill.ZIndex = 8
fill.Parent = track
corner(fill, 99)
local fillGrad = Instance.new("UIGradient")
fillGrad.Color = rainbowSeq()
fillGrad.Parent = fill

--// [6] Info fetch (paralel, cepat, gated)
local placeId, universeId = 0, 0
pcall(function() placeId = game.PlaceId end)
pcall(function() universeId = game.GameId end)
local jobId = tostring(game.JobId or "")
local serverShort = (jobId ~= "" and string.sub(jobId, 1, 8) .. "…") or "Private/Studio"
meta1.Text = "PlaceId " .. placeId .. "  |  Universe " .. universeId
meta2.Text = "Executor: " .. getExecutorName() .. "  |  Server ID: " .. serverShort

local infoReady = false
task.spawn(function()
    local name, creator = "Unknown Place", "Unknown"
    local ok, product = pcall(function() return MarketplaceService:GetProductInfo(placeId) end)
    if ok and type(product) == "table" then
        if type(product.Name) == "string" and product.Name ~= "" then name = product.Name end
        if type(product.Creator) == "table" and type(product.Creator.Name) == "string" then creator = product.Creator.Name end
    end
    if gameName.Parent then
        gameName.Text = name
        meta1.Text = "PlaceId " .. placeId .. "  |  Universe " .. universeId .. "  |  by " .. creator
    end
    infoReady = true
end)

--// [7] Steps
local steps = {
    { at = 0,  text = "Initializing executor environment" },
    { at = 20, text = "Connecting to Roblox services" },
    { at = 40, text = "Detecting current place" },
    { at = 65, text = "Verifying game support" },
    { at = 85, text = "Preparing protection module" },
}
local function stepFor(v)
    local cur = steps[1].text
    for _, s in ipairs(steps) do if v >= s.at then cur = s.text end end
    return cur
end

--// [8] Rainbow + particle + shimmer engine (single loop)
local engineConn
engineConn = RunService.RenderStepped:Connect(function(dt)
    if not gui.Parent then
        if engineConn then engineConn:Disconnect() end
        return
    end
    dt = tonumber(dt) or 0.016
    local t = os.clock()
    -- rainbow accents
    local c0 = hueColor(0)
    cardStroke.Color = c0
    cardGlow.Color = hueColor(0.15)
    cardGlow.Transparency = 0.66 + 0.1 * math.sin(t * 2)
    icon.ImageColor3 = c0
    pctLbl.TextColor3 = c0
    divider.BackgroundColor3 = hueColor(0.3)
    fillGrad.Offset = Vector2.new((t * 0.25) % 1, 0)
    -- shimmer sweep
    local sx = ((t * 0.35) % 1.4) - 0.2
    shimmer.Position = UDim2.new(sx, 0, 0, 0)
    -- particles
    local sz = layer.AbsoluteSize
    if sz.X > 1 and sz.Y > 1 then
        for _, d in ipairs(particles) do
            if d.f.Parent then
                if d.x == nil then
                    d.x = math.random() * sz.X
                    d.y = (d.kind == "spark") and (sz.Y + 10) or (math.random() * sz.Y)
                end
                d.x += d.vx * dt
                d.y += d.vy * dt
                if d.kind == "spark" then
                    if d.y < -12 then d.y = sz.Y + 10; d.x = math.random() * sz.X end
                else
                    if d.x < -20 then d.x = sz.X + 20 elseif d.x > sz.X + 20 then d.x = -20 end
                    if d.y < -20 then d.y = sz.Y + 20 elseif d.y > sz.Y + 20 then d.y = -20 end
                end
                d.f.Position = UDim2.new(0, d.x, 0, d.y)
                if d.spin ~= 0 then d.f.Rotation = 45 + t * d.spin end
                local pulse = 0.5 + 0.5 * math.sin(t * d.speed + d.phase)
                d.f.BackgroundTransparency = math.clamp(d.baseT - pulse * 0.18, 0.05, 0.95)
                d.f.BackgroundColor3 = hueColor(d.hue)
            end
        end
    end
end)

--// [9] Execute protection
local function executeProtection()
    local lastErr
    for _ = 1, 2 do
        local ok, err = pcall(function()
            local src = game:HttpGet(CONFIG.ScriptURL)
            local fn, cerr = loadstring(src)
            if not fn then error(cerr or "compile error") end
            fn()
        end)
        if ok then return true end
        lastErr = err
        task.wait(0.4)
    end
    warn("[Ro-Netrium] Gagal execute protection: " .. tostring(lastErr))
    return false
end

--// [10] Progress: 0->90, gate until info ready, 90->100, execute, destroy
local progress = Instance.new("NumberValue")
progress.Value = 0
progress.Changed:Connect(function(v)
    if not fill.Parent then return end
    fill.Size = UDim2.new(math.clamp(v / 100, 0, 1), 0, 1, 0)
    pctLbl.Text = math.floor(v + 0.5) .. "%"
    stepLbl.Text = stepFor(v)
end)

local function finish()
    if not gui.Parent then return end
    progress.Value = 100
    badge.Text = "VERIFIED"
    badge.TextColor3 = hueColor(0)
    stepLbl.Text = "Executing protection module..."
    task.wait(CONFIG.HoldAt100)
    task.spawn(executeProtection)
    TweenService:Create(dim, TweenInfo.new(CONFIG.FadeTime), { BackgroundTransparency = 1 }):Play()
    TweenService:Create(layer, TweenInfo.new(CONFIG.FadeTime), { BackgroundTransparency = 1 }):Play()
    local sc = Instance.new("UIScale"); sc.Scale = 1; sc.Parent = card
    TweenService:Create(sc, TweenInfo.new(CONFIG.FadeTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Scale = 0.9 }):Play()
    TweenService:Create(card, TweenInfo.new(CONFIG.FadeTime), { BackgroundTransparency = 1 }):Play()
    task.delay(CONFIG.FadeTime + 0.05, function()
        if engineConn then engineConn:Disconnect() end
        pcall(function() gui:Destroy() end)
    end)
end

local t1 = TweenService:Create(progress, TweenInfo.new(CONFIG.CheckDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { Value = 90 })
t1.Completed:Connect(function()
    task.spawn(function()
        local waited = 0
        while not infoReady and waited < CONFIG.InfoTimeout do
            stepLbl.Text = "Fetching place info..."
            task.wait(0.1)
            waited += 0.1
        end
        if not infoReady and gameName.Parent then
            gameName.Text = "Place " .. placeId
        end
        local t2 = TweenService:Create(progress, TweenInfo.new(CONFIG.FinishDuration, Enum.EasingStyle.Linear), { Value = 100 })
        t2.Completed:Connect(finish)
        t2:Play()
    end)
end)
t1:Play()
