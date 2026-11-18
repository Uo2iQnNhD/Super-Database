--[[ ============================================================
    GAME CHECKER LOADING SCREEN (STANDALONE / OUTSIDE LIBRARY)
    Method: NumberValue + TweenService progress (event-driven)
    Flow  : 0% -> 100% -> execute Detection -> destroy UI
============================================================ ]]

local CONFIG = {
    GuiName   = "ZethGameChecker",
    Title     = "GAME CHECKER",
    Subtitle  = "Verifying environment & place support",
    Icon      = "rbxassetid://7734056411", -- shield-check
    Accent    = Color3.fromRGB(46, 230, 110),
    Background= Color3.fromRGB(12, 12, 14),
    Element   = Color3.fromRGB(22, 22, 26),
    Text      = Color3.fromRGB(255, 255, 255),
    SubText   = Color3.fromRGB(165, 165, 172),
    Duration  = 4.5,   -- detik untuk progress 0 -> 100
    HoldAt100 = 0.45,  -- jeda sebentar di 100% sebelum execute
    FadeTime  = 0.4,   -- durasi fade out sebelum UI dihapus
    ScriptURL = "https://raw.githubusercontent.com/Zyptrue/xTicAYRgProtection/refs/heads/main/Detection",
}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

--// [1] Bersihkan GUI checker lama (anti duplicate saat re-execute)
local function purgeOld()
    local parents = {}
    pcall(function() table.insert(parents, game:GetService("CoreGui")) end)
    pcall(function() table.insert(parents, LocalPlayer:WaitForChild("PlayerGui")) end)
    if typeof(gethui) == "function" then
        pcall(function() table.insert(parents, gethui()) end)
    end
    for _, parent in ipairs(parents) do
        if parent then
            for _, child in ipairs(parent:GetChildren()) do
                if child.Name == CONFIG.GuiName then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end
end
purgeOld()

--// [2] Helper UI
local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = obj
    return c
end
local function stroke(obj, col, th)
    local s = Instance.new("UIStroke")
    s.Color = col
    s.Thickness = th or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end
local function label(parent, size, pos, text, textSize, font, color, align)
    local l = Instance.new("TextLabel")
    l.Size = size
    l.Position = pos
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextSize = textSize
    l.Font = font
    l.TextColor3 = color
    l.TextXAlignment = align or Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.ZIndex = 3
    l.Parent = parent
    return l
end

--// [3] Build Loading Screen
local gui = Instance.new("ScreenGui")
gui.Name = CONFIG.GuiName
gui.ResetOnSpawn = false
gui.DisplayOrder = 99999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then
    pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
end

local dim = Instance.new("Frame")
dim.Name = "Dim"
dim.Size = UDim2.new(1, 0, 1, 0)
dim.BackgroundColor3 = Color3.new(0, 0, 0)
dim.BackgroundTransparency = 0.45
dim.BorderSizePixel = 0
dim.ZIndex = 1
dim.Parent = gui

local card = Instance.new("Frame")
card.Name = "CheckerCard"
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.new(0.5, 0, 0.5, 0)
card.Size = UDim2.new(0, 470, 0, 240)
card.BackgroundColor3 = CONFIG.Background
card.BorderSizePixel = 0
card.ZIndex = 2
card.Parent = gui
corner(card, 12)
stroke(card, CONFIG.Accent, 2)
pcall(function()
    local shadow = Instance.new("UIDropShadow")
    shadow.Color = Color3.new(0, 0, 0)
    shadow.Transparency = 0.5
    shadow.Size = UDim2.new(0, 26, 0, 26)
    shadow.Offset = Vector2.new(0, 8)
    shadow.Parent = card
end)

local icon = Instance.new("ImageLabel")
icon.Size = UDim2.new(0, 40, 0, 40)
icon.Position = UDim2.new(0, 18, 0, 18)
icon.BackgroundTransparency = 1
icon.Image = CONFIG.Icon
icon.ImageColor3 = CONFIG.Accent
icon.ZIndex = 3
icon.Parent = card

label(card, UDim2.new(1, -150, 0, 22), UDim2.new(0, 68, 0, 20),
    CONFIG.Title, 17, Enum.Font.GothamBlack, CONFIG.Text)
label(card, UDim2.new(1, -150, 0, 16), UDim2.new(0, 68, 0, 44),
    CONFIG.Subtitle, 11, Enum.Font.Gotham, CONFIG.SubText)

local badge = Instance.new("TextLabel")
badge.Size = UDim2.new(0, 130, 0, 24)
badge.Position = UDim2.new(1, -148, 0, 20)
badge.BackgroundColor3 = CONFIG.Element
badge.BorderSizePixel = 0
badge.Text = "CHECKING..."
badge.TextColor3 = CONFIG.SubText
badge.TextSize = 10
badge.Font = Enum.Font.GothamBold
badge.ZIndex = 3
badge.Parent = card
corner(badge, 99)

local gameName = label(card, UDim2.new(1, -36, 0, 20), UDim2.new(0, 18, 0, 82),
    "Detecting place...", 14, Enum.Font.GothamBold, CONFIG.Text)
local gameMeta = label(card, UDim2.new(1, -36, 0, 16), UDim2.new(0, 18, 0, 104),
    "PlaceId -  |  Universe -  |  by -", 10, Enum.Font.Gotham, CONFIG.SubText)

local stepLbl = label(card, UDim2.new(1, -100, 0, 16), UDim2.new(0, 18, 1, -44),
    "Starting...", 11, Enum.Font.GothamMedium, CONFIG.SubText)
local pctLbl = label(card, UDim2.new(0, 64, 0, 16), UDim2.new(1, -82, 1, -44),
    "0%", 11, Enum.Font.GothamBold, CONFIG.Accent, Enum.TextXAlignment.Right)

local track = Instance.new("Frame")
track.Size = UDim2.new(1, -36, 0, 5)
track.Position = UDim2.new(0, 18, 1, -24)
track.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
track.BackgroundTransparency = 0.2
track.BorderSizePixel = 0
track.ClipsDescendants = true
track.ZIndex = 3
track.Parent = card
corner(track, 99)

local fill = Instance.new("Frame")
fill.Size = UDim2.new(0, 0, 1, 0)
fill.BackgroundColor3 = CONFIG.Accent
fill.BorderSizePixel = 0
fill.ZIndex = 4
fill.Parent = track
corner(fill, 99)

--// [4] Data game (di-fetch saat progress melewati 40%)
local infoFetched = false
local function fetchGameInfo()
    local placeId, universeId = 0, 0
    pcall(function() placeId = game.PlaceId end)
    pcall(function() universeId = game.GameId end)
    local name, creator = "Unknown Place", "Unknown"
    local ok, product = pcall(function()
        return MarketplaceService:GetProductInfo(placeId)
    end)
    if ok and type(product) == "table" then
        if type(product.Name) == "string" and product.Name ~= "" then
            name = product.Name
        end
        if type(product.Creator) == "table" and type(product.Creator.Name) == "string" then
            creator = product.Creator.Name
        end
    end
    if gameName.Parent then
        gameName.Text = name
        gameMeta.Text = "PlaceId " .. tostring(placeId) .. "  |  Universe " .. tostring(universeId) .. "  |  by " .. creator
    end
end

--// [5] Step text berdasarkan threshold persen
local steps = {
    { at = 0,   text = "Initializing executor environment" },
    { at = 20,  text = "Connecting to Roblox services" },
    { at = 40,  text = "Detecting current place" },
    { at = 65,  text = "Verifying game support" },
    { at = 85,  text = "Preparing protection module" },
    { at = 100, text = "Complete" },
}
local function stepFor(v)
    local cur = steps[1].text
    for _, s in ipairs(steps) do
        if v >= s.at then cur = s.text end
    end
    return cur
end

--// [6] METHOD BARU: progress = NumberValue di-tween, UI update via Changed
local progress = Instance.new("NumberValue")
progress.Value = 0

progress.Changed:Connect(function(v)
    if not fill.Parent then return end
    fill.Size = UDim2.new(math.clamp(v / 100, 0, 1), 0, 1, 0)
    pctLbl.Text = math.floor(v + 0.5) .. "%"
    stepLbl.Text = stepFor(v)
    if not infoFetched and v >= 40 then
        infoFetched = true
        task.spawn(fetchGameInfo)
    end
end)

--// [7] Eksekusi script protection (dipanggil saat 100%)
local function executeProtection()
    local lastErr
    for attempt = 1, 2 do
        local ok, err = pcall(function()
            local source = game:HttpGet(CONFIG.ScriptURL)
            local fn, compileErr = loadstring(source)
            if not fn then
                error(compileErr or "compile error")
            end
            fn()
        end)
        if ok then
            return true
        end
        lastErr = err
        task.wait(0.5)
    end
    warn("[GameChecker] Gagal execute protection: " .. tostring(lastErr))
    return false
end

--// [8] Saat tween selesai (100%) -> execute -> hapus UI
local progressTween = TweenService:Create(
    progress,
    TweenInfo.new(CONFIG.Duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
    { Value = 100 }
)

progressTween.Completed:Connect(function()
    if not gui.Parent then return end
    progress.Value = 100
    badge.Text = "VERIFIED"
    badge.TextColor3 = CONFIG.Accent
    stepLbl.Text = "Executing protection module..."
    task.wait(CONFIG.HoldAt100)

    -- Execute script detection (spawn agar tidak blocking fade-out)
    task.spawn(executeProtection)

    -- Fade out lalu HAPUS UI loading screen
    TweenService:Create(dim, TweenInfo.new(CONFIG.FadeTime), {
        BackgroundTransparency = 1,
    }):Play()
    local scale = Instance.new("UIScale")
    scale.Scale = 1
    scale.Parent = card
    TweenService:Create(scale, TweenInfo.new(CONFIG.FadeTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Scale = 0.9,
    }):Play()
    TweenService:Create(card, TweenInfo.new(CONFIG.FadeTime), {
        BackgroundTransparency = 1,
    }):Play()
    task.delay(CONFIG.FadeTime + 0.05, function()
        pcall(function() gui:Destroy() end)
    end)
end)

progressTween:Play()
