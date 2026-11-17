--[[ Ro-Netrium Library V5.9 ]]
--[[ PART 1/4 : Core + Theme(37) + Icons + Guard + Effects + Locked + Stagger ]]
--[[          + Save/Load(+FramePos) + Notify + Action Modal + Movement ]]
--[[ GABUNGKAN PART 1/4 + 2/4 + 3/4 + 4/4 JADI SATU SCRIPT, LALU EXECUTE ]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer

--// Anti duplicate environment
local Env = (typeof(getgenv) == "function" and getgenv()) or _G
local Generation = (type(Env) == "table" and tonumber(Env.RoNetGeneration) or 0) + 1
if type(Env) == "table" then
	Env.RoNetGeneration = Generation
	Env.ZethHubGeneration = Generation
end

local function purgeOldGuis()
	local targets = {
		"Ro-Netrium", "Ro-NetriumUPD", "Ro-NetriumV4", "Ro-NetriumV5",
		"ZethHubV5", "ZethNotifies", "RoNetNotifies", "RoNetAction",
		"ZethGameChecker",
	}
	local parents = { game:GetService("CoreGui"), LocalPlayer:FindFirstChild("PlayerGui") }
	if typeof(gethui) == "function" then
		local ok, hui = pcall(gethui)
		if ok and hui then table.insert(parents, hui) end
	end
	for _, parent in ipairs(parents) do
		if parent then
			for _, child in ipairs(parent:GetChildren()) do
				if child:IsA("ScreenGui") then
					for _, name in ipairs(targets) do
						if child.Name == name then pcall(function() child:Destroy() end) end
					end
				end
			end
		end
	end
end

local PreviousLibrary = type(Env) == "table" and (Env.RoNetLibrary or Env.ZethHubLibrary) or nil
if PreviousLibrary and type(PreviousLibrary.Destroy) == "function" then
	pcall(function() PreviousLibrary:Destroy() end)
end
purgeOldGuis()

local Library = {
	Version = "5.9",
	Accent = Color3.fromRGB(255, 255, 255),
	Rainbow = true,
	ToggleKey = Enum.KeyCode.RightShift,
	Open = true,
	Flags = {},
	Generation = Generation,
	_connections = {},
	_windows = {},
	_destroyed = false,
	AnimationSpeed = 1,
	_searchIndex = {},
	_elements = {},
	_saveFile = "autosave",
	_autoLoaded = false,
	_loading = false,
	SessionStart = os.clock(),
	AutoSave = { Enabled = false, Interval = 60, File = "autosave" },
	AutoLoad = { Enabled = true, File = "autosave" },
	Effects = {
		Particles = true, Crystals = true, GridOverlay = true,
		Glow = true, Ripple = true, Shadow = true,
	},
	-- [FIX 7] posisi frame floating disimpan di sini
	FramePositions = {},
	-- [FIX 8] animasi masuk bertahap
	Stagger = { Enabled = true, Step = 0.035, Max = 0.5 },
	_actionOpen = false,
	_confirmOpen = false,
	_buttonPressLock = false,
}

local Theme = {
	Background = Color3.fromRGB(12, 12, 14),
	Sidebar = Color3.fromRGB(8, 8, 10),
	Element = Color3.fromRGB(22, 22, 26),
	ElementHover = Color3.fromRGB(32, 32, 38),
	Border = Color3.fromRGB(70, 70, 78),
	Text = Color3.fromRGB(255, 255, 255),
	SubText = Color3.fromRGB(165, 165, 172),
	MainBorderThickness = 3,
	ElementBorderThickness = 1.6,
	BorderThickness = 1.6,
	BorderTransparency = 0,
	BorderGlow = true,
	GlowTransparency = 0.62,
	RainbowSpeed = 0.12,
	ParticleCount = 26,
	-- [FIX 6] grid & garis dipertebal supaya kelihatan di HP
	GridThickness = 2,
	GridTransparency = 0.78,
	GridSpacing = 26,
	ScanThickness = 3,
	ScanTransparency = 0.72,
	CrystalSize = 7,
	DotSize = 4,
}
Theme.Close = Color3.fromRGB(225, 70, 70)
Theme.CloseHover = Color3.fromRGB(255, 95, 95)
Theme.ClosePressed = Color3.fromRGB(185, 45, 45)
Theme.CloseText = Color3.fromRGB(255, 255, 255)
Theme.ConfirmBackground = Color3.fromRGB(16, 16, 20)
Theme.ConfirmText = Color3.fromRGB(255, 255, 255)
Theme.ConfirmSubText = Color3.fromRGB(182, 182, 190)
Theme.Neutral = Color3.fromRGB(58, 58, 64)
Theme.NeutralHover = Color3.fromRGB(84, 84, 92)
Theme.Disabled = Color3.fromRGB(96, 96, 102)
Theme.DisabledText = Color3.fromRGB(150, 150, 156)
Theme.Danger = Color3.fromRGB(235, 70, 80)
Theme.DangerHover = Color3.fromRGB(255, 96, 106)
Theme.Success = Color3.fromRGB(46, 220, 120)
Library.CloseColor = Theme.Close
Library.CloseHoverColor = Theme.CloseHover
Library.ClosePressedColor = Theme.ClosePressed

--// 37 THEME PRESETS
local function P(rainbow, accent, bg, sb, el, eh, bd, tx, st)
	return {
		Rainbow = rainbow,
		Accent = accent and Color3.fromRGB(accent[1], accent[2], accent[3]) or nil,
		Colors = {
			Background = Color3.fromRGB(bg[1], bg[2], bg[3]),
			Sidebar = Color3.fromRGB(sb[1], sb[2], sb[3]),
			Element = Color3.fromRGB(el[1], el[2], el[3]),
			ElementHover = Color3.fromRGB(eh[1], eh[2], eh[3]),
			Border = Color3.fromRGB(bd[1], bd[2], bd[3]),
			Text = Color3.fromRGB(tx[1], tx[2], tx[3]),
			SubText = Color3.fromRGB(st[1], st[2], st[3]),
		},
	}
end

Theme.Presets = {
	["Solid"]        = P(false,{255,255,255},{12,12,14},{8,8,10},{22,22,26},{32,32,38},{70,70,78},{255,255,255},{165,165,172}),
	["RGB Rainbow"]  = P(true, nil,          {10,10,12},{7,7,9},  {20,20,24},{30,30,36},{80,80,90},{255,255,255},{170,170,178}),
	["Neon Blue"]    = P(false,{60,170,255}, {9,12,18}, {6,9,14}, {18,24,34},{28,38,54},{55,90,130},{240,248,255},{150,175,200}),
	["Emerald"]      = P(false,{46,230,110}, {10,14,12},{7,10,9}, {18,26,22},{28,40,34},{50,90,70},{240,255,245},{150,190,165}),
	["Sunset"]       = P(false,{255,120,60}, {16,11,12},{11,8,9}, {28,20,22},{42,30,34},{100,60,55},{255,245,240},{200,160,150}),
	["Ocean"]        = P(false,{40,210,220}, {8,14,16}, {5,10,12},{16,26,30},{24,38,44},{45,95,105},{235,255,255},{145,185,190}),
	["Violet"]       = P(false,{170,90,255}, {13,10,18},{9,7,13}, {24,18,34},{36,28,50},{85,60,120},{248,240,255},{180,160,205}),
	["Crimson"]      = P(false,{255,70,90},  {16,9,11}, {11,6,8}, {30,16,20},{44,24,30},{110,45,55},{255,240,242},{205,150,158}),
	["Gold"]         = P(false,{255,200,70}, {15,13,9}, {10,9,6}, {28,24,16},{42,36,24},{105,88,45},{255,250,235},{205,190,150}),
	["Cyberpunk"]    = P(false,{255,40,200}, {10,8,16}, {6,5,11}, {20,14,32},{32,22,50},{90,40,130},{255,240,255},{190,150,210}),
	["Toxic"]        = P(false,{170,255,60}, {10,13,8}, {7,9,5},  {18,24,14},{28,38,22},{65,95,40},{240,255,230},{160,190,135}),
	["Sakura"]       = P(false,{255,140,190},{16,11,14},{11,8,10},{30,20,26},{44,30,38},{110,70,90},{255,242,248},{205,165,185}),
	["Ice"]          = P(false,{150,220,255},{10,13,16},{7,9,12}, {18,24,30},{28,38,46},{60,95,120},{240,250,255},{160,185,205}),
	["Blood Moon"]   = P(false,{220,40,60},  {12,7,8},  {8,5,6},  {24,12,15},{38,20,24},{95,35,45},{255,235,238},{195,140,148}),
	["Forest"]       = P(false,{90,200,120}, {9,12,10}, {6,8,7},  {16,22,18},{26,34,28},{45,80,58},{238,255,244},{150,185,160}),
	["Royal"]        = P(false,{120,90,255}, {11,10,17},{7,7,12}, {20,18,32},{32,28,50},{75,65,125},{245,242,255},{170,165,210}),
	["Amber"]        = P(false,{255,170,50}, {15,12,8}, {10,8,5}, {28,22,14},{42,34,22},{105,80,40},{255,248,235},{205,180,140}),
	["Mono"]         = P(false,{210,210,210},{14,14,14},{9,9,9},  {24,24,24},{34,34,34},{70,70,70},{245,245,245},{160,160,160}),
	["Lava"]         = P(false,{255,90,30},  {14,8,6},  {9,5,4},  {26,14,10},{40,22,16},{100,45,30},{255,240,230},{200,150,130}),
	["Mint"]         = P(false,{80,240,190}, {9,14,13}, {6,10,9}, {16,26,24},{24,38,35},{45,95,85},{235,255,250},{145,190,180}),
	["Peach"]        = P(false,{255,155,120},{16,12,11},{11,8,7}, {30,22,20},{44,32,29},{110,75,68},{255,245,240},{205,170,160}),
	["Midnight"]     = P(false,{90,120,255}, {6,7,14},  {4,5,10}, {14,16,28},{22,26,42},{45,55,100},{235,240,255},{140,150,190}),
	["Rose Gold"]    = P(false,{240,150,140},{18,12,12},{12,8,8}, {32,22,22},{46,32,32},{110,75,72},{255,244,242},{205,170,166}),
	["Aqua"]         = P(false,{50,230,240}, {8,15,17}, {5,10,12},{16,28,32},{24,40,46},{45,100,110},{235,255,255},{145,190,196}),
	["Grape"]        = P(false,{190,70,220}, {14,9,17}, {9,6,12}, {26,16,32},{38,26,46},{95,50,115},{250,240,255},{190,160,205}),
	["Lime"]         = P(false,{200,255,80}, {12,14,8}, {8,10,5}, {22,26,14},{32,38,22},{80,100,45},{248,255,235},{180,196,150}),
	["Steel"]        = P(false,{170,185,200},{13,15,17},{9,10,12},{23,26,30},{33,38,44},{68,78,90},{240,245,250},{160,170,182}),
	["Coral"]        = P(false,{255,110,110},{17,11,11},{12,7,7}, {31,20,20},{45,30,30},{112,62,62},{255,242,242},{206,164,164}),
	["Sky"]          = P(false,{120,200,255},{10,14,19},{7,10,14},{19,26,36},{29,38,52},{58,92,130},{240,248,255},{155,180,205}),
	["Olive"]        = P(false,{180,190,90}, {13,14,9}, {9,10,6}, {24,26,16},{34,38,24},{85,90,48},{248,250,235},{182,188,150}),
	["Magenta"]      = P(false,{255,60,180}, {16,8,14}, {11,5,10},{30,16,26},{44,24,38},{110,45,90},{255,240,250},{205,150,188}),
	["Slate"]        = P(false,{140,160,190},{11,13,16},{8,9,12}, {21,24,29},{31,36,43},{62,72,88},{238,242,248},{152,164,180}),
	["Candy"]        = P(false,{255,130,220},{17,11,17},{12,8,12},{31,20,31},{45,30,45},{112,66,105},{255,242,253},{206,166,200}),
	["Deep Sea"]     = P(false,{40,150,200}, {6,11,15}, {4,8,11}, {13,23,30},{21,34,44},{38,78,100},{230,246,255},{138,172,190}),
	["Autumn"]       = P(false,{230,130,60}, {16,12,8}, {11,8,5}, {29,22,15},{42,32,22},{104,74,42},{255,246,235},{202,176,146}),
	["Neon Pink"]    = P(false,{255,50,150}, {15,8,13}, {10,5,9}, {28,15,24},{42,23,36},{108,42,80},{255,240,248},{204,150,182}),
	["Arctic"]       = P(false,{190,235,255},{11,15,18},{8,11,14},{20,28,34},{30,42,50},{62,98,120},{244,252,255},{164,190,205}),
}

local H_ELEMENT = 38
local H_SLIDER = 46
local H_SECTION = 20
local H_TAB = 34
local TOPBAR_H = 58

Library.Lucide = {}
Library.LucideRect = {}
local fallbackIcons = {
	["home"]="rbxassetid://7733960981", ["settings"]="rbxassetid://7734053495", ["settings-2"]="rbxassetid://8997386997",
	["shield"]="rbxassetid://7734056608", ["shield-check"]="rbxassetid://7734056411", ["key"]="rbxassetid://7733965118",
	["gamepad-2"]="rbxassetid://7733799795", ["folder"]="rbxassetid://7733799185", ["file-text"]="rbxassetid://7733789088",
	["palette"]="rbxassetid://7734021595", ["wrench"]="rbxassetid://7743878358", ["hammer"]="rbxassetid://7733955511",
	["heart"]="rbxassetid://7733956134", ["star"]="rbxassetid://7734068321", ["check"]="rbxassetid://7733715400",
	["x"]="rbxassetid://7743878857", ["search"]="rbxassetid://7734052925", ["globe"]="rbxassetid://7733954760",
	["cpu"]="rbxassetid://7733765045", ["activity"]="rbxassetid://7733655755", ["gauge"]="rbxassetid://7733799969",
	["map-pin"]="rbxassetid://7733992789", ["eye"]="rbxassetid://7733774602", ["eye-off"]="rbxassetid://7733774495",
	["lock"]="rbxassetid://7733992528", ["unlock"]="rbxassetid://7743875263", ["send"]="rbxassetid://7734053039",
	["message-square"]="rbxassetid://7733993369", ["download"]="rbxassetid://7733770755", ["upload"]="rbxassetid://7743875428",
	["refresh-cw"]="rbxassetid://7734051052", ["play"]="rbxassetid://7743871480", ["pause"]="rbxassetid://7734021897",
	["music"]="rbxassetid://7734020554", ["image"]="rbxassetid://7733964126", ["camera"]="rbxassetid://7733708692",
	["mail"]="rbxassetid://7733992732", ["wifi"]="rbxassetid://7743878148", ["sun"]="rbxassetid://7734068495",
	["moon"]="rbxassetid://7743870134", ["cloud"]="rbxassetid://7733746980", ["flame"]="rbxassetid://7733798747",
	["crown"]="rbxassetid://7733765398", ["gem"]="rbxassetid://7733942651", ["banknote"]="rbxassetid://7733674153",
	["shopping-cart"]="rbxassetid://7734056813", ["gift"]="rbxassetid://7733946818", ["package"]="rbxassetid://7734021469",
	["box"]="rbxassetid://7733917120", ["trash-2"]="rbxassetid://7743873772", ["pencil"]="rbxassetid://7734022107",
	["clipboard"]="rbxassetid://7733734762", ["book-open"]="rbxassetid://7733687281", ["calendar"]="rbxassetid://7733919198",
	["timer"]="rbxassetid://7743873443", ["alarm-clock"]="rbxassetid://7733656100", ["watch"]="rbxassetid://7743877668",
	["megaphone"]="rbxassetid://7733993049", ["monitor"]="rbxassetid://7734002839", ["smartphone"]="rbxassetid://7734058979",
	["laptop"]="rbxassetid://7733965386", ["database"]="rbxassetid://7743866778", ["server"]="rbxassetid://7734053426",
	["link"]="rbxassetid://7733978098", ["external-link"]="rbxassetid://7743866903", ["qr-code"]="rbxassetid://7743871575",
	["scan"]="rbxassetid://8997386861", ["flag"]="rbxassetid://7733798691", ["compass"]="rbxassetid://7733924216",
	["map"]="rbxassetid://7733992829", ["navigation"]="rbxassetid://7734020989", ["crosshair"]="rbxassetid://7733765307",
	["target"]="rbxassetid://7743872758", ["bell"]="rbxassetid://7733911828", ["bell-ring"]="rbxassetid://7733675275",
	["info"]="rbxassetid://7733964719", ["terminal"]="rbxassetid://7743872929", ["check-circle"]="rbxassetid://7733919427",
	["x-circle"]="rbxassetid://7743878496", ["help-circle"]="rbxassetid://7733956210", ["user"]="rbxassetid://7743875962",
	["users"]="rbxassetid://7743876054", ["chevron-down"]="rbxassetid://7733717447", ["chevron-right"]="rbxassetid://7733717755",
	["chevron-left"]="rbxassetid://7733717651", ["chevron-up"]="rbxassetid://7733919605", ["log-out"]="rbxassetid://7733992677",
	["log-in"]="rbxassetid://7733992604", ["power"]="rbxassetid://7734042493", ["toggle-left"]="rbxassetid://7734091286",
	["toggle-right"]="rbxassetid://7743873539", ["type"]="rbxassetid://7743874740", ["menu"]="rbxassetid://7733993211",
	["layout-dashboard"]="rbxassetid://7733970318", ["grid"]="rbxassetid://7733955179", ["sidebar"]="rbxassetid://7734058260",
	["shovel"]="rbxassetid://7734056878", ["sliders"]="rbxassetid://7734058803", ["coin"]="rbxassetid://7743866529",
	["wallet"]="rbxassetid://7743877573", ["piggy-bank"]="rbxassetid://7734034513", ["ticket"]="rbxassetid://7734086558",
	["badge-check"]="rbxassetid://7743875503", ["badge"]="rbxassetid://7733692043", ["award"]="rbxassetid://7733673987",
	["battery"]="rbxassetid://7733674820", ["battery-charging"]="rbxassetid://7733674402", ["lightbulb"]="rbxassetid://7733975185",
	["locate"]="rbxassetid://7733992469", ["locate-fixed"]="rbxassetid://7733992424", ["skull"]="rbxassetid://7734068321",
	["sword"]="rbxassetid://7734056878", ["swords"]="rbxassetid://7734056878", ["layers"]="rbxassetid://7733917120",
	["sparkles"]="rbxassetid://7734068321", ["droplet"]="rbxassetid://7734021595", ["border-all"]="rbxassetid://7733955179",
	["border-inner"]="rbxassetid://7734058260", ["clock"]="rbxassetid://7743873443", ["save"]="rbxassetid://7733770755",
	["copy"]="rbxassetid://7733734762", ["list"]="rbxassetid://7733789088", ["shuffle"]="rbxassetid://7734051052",
	["triangle-alert"]="rbxassetid://7733964719", ["alert-triangle"]="rbxassetid://7733964719",
	["shield-alert"]="rbxassetid://7734056608", ["ghost"]="rbxassetid://7733946818",
	["arrow-up"]="rbxassetid://7733919605", ["house"]="rbxassetid://7733960981", ["gear"]="rbxassetid://7734053495",
}
for name, asset in pairs(fallbackIcons) do Library.Lucide[name] = asset end

local IconCache = (type(Env) == "table" and Env.RoNetIconCache) or { Loaded = false, Lucide = {}, Rect = {} }
if type(Env) == "table" then Env.RoNetIconCache = IconCache end
for name, asset in pairs(IconCache.Lucide) do Library.Lucide[name] = asset end
for name, rect in pairs(IconCache.Rect) do Library.LucideRect[name] = rect end

local function fetchIconSource()
	local url = "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua"
	local ok, body = pcall(function() return game:HttpGet(url) end)
	if ok and type(body) == "string" and #body > 0 then return body end
	local req = (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request) or http_request or request
	if req then
		local okReq, res = pcall(function() return req({ Url = url, Method = "GET" }) end)
		if okReq and type(res) == "table" and type(res.Body) == "string" and #res.Body > 0 then return res.Body end
	end
	return nil
end

local function loadIcons()
	if IconCache.Loaded then return end
	IconCache.Loaded = true
	local source = fetchIconSource()
	if not source then return end
	local ok, Icons = pcall(function() return loadstring(source)() end)
	if not ok or type(Icons) ~= "table" then return end
	local tbl = Icons["48px"] or Icons
	for name, data in pairs(tbl) do
		if type(name) == "string" and type(data) == "table" then
			local id, rs, ro = data[1], data[2], data[3]
			if type(id) == "number" and type(rs) == "table" and type(ro) == "table" and rs[1] and rs[2] and ro[1] and ro[2] then
				local asset = "rbxassetid://" .. id
				local rect = { ImageRectOffset = Vector2.new(ro[1], ro[2]), ImageRectSize = Vector2.new(rs[1], rs[2]) }
				IconCache.Lucide[name] = asset
				IconCache.Rect[name] = rect
				Library.Lucide[name] = asset
				Library.LucideRect[name] = rect
			end
		end
	end
end
loadIcons()

local function resolveIcon(icon)
	if icon == nil or icon == false or icon == 0 or icon == "" then return nil, nil, nil end
	if type(icon) == "number" then return "rbxassetid://" .. icon, nil, nil end
	if type(icon) == "string" then
		if icon:sub(1,12) == "rbxassetid://" or icon:sub(1,10) == "rbxasset://"
			or icon:sub(1,11) == "rbxthumb://" or icon:sub(1,7) == "http://" or icon:sub(1,8) == "https://" then
			return icon, nil, nil
		end
		local key = string.match(string.lower(icon), "^%s*(.-)%s*$")
		local asset = Library.Lucide[key]
		local rect = Library.LucideRect[key]
		if not asset or asset == "" then
			asset = Library.Lucide["info"]
			rect = Library.LucideRect["info"]
		end
		return asset, rect and rect.ImageRectOffset, rect and rect.ImageRectSize
	end
	return nil, nil, nil
end

local function setIcon(inst, icon)
	if not inst then return end
	if not (inst:IsA("ImageLabel") or inst:IsA("ImageButton")) then return end
	local asset, off, size = resolveIcon(icon)
	inst.Image = asset or ""
	if off and size then
		inst.ImageRectOffset = off
		inst.ImageRectSize = size
	else
		inst.ImageRectOffset = Vector2.new(0, 0)
		inst.ImageRectSize = Vector2.new(0, 0)
	end
end

local function makeIcon(parent, icon, size, pos, color)
	local asset, off, rs = resolveIcon(icon)
	if not asset or asset == "" then return nil end
	local im = Instance.new("ImageLabel")
	im.Name = "Icon"
	im.Size = size or UDim2.new(0, 16, 0, 16)
	im.Position = pos or UDim2.new(0, 12, 0.5, -8)
	im.BackgroundTransparency = 1
	im.Image = asset
	im.ImageColor3 = color or Theme.Text
	if off and rs then
		im.ImageRectOffset = off
		im.ImageRectSize = rs
	end
	im.Parent = parent
	return im
end

local function Tween(obj, dur, props, style, dir)
	local speed = math.max(0.05, tonumber(Library.AnimationSpeed) or 1)
	local info = TweenInfo.new((dur or .3) / speed, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
	local tw = TweenService:Create(obj, info, props)
	tw:Play()
	return tw
end

local function Corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 7)
	c.Parent = p
	return c
end

local function Stroke(p, col, th)
	local s = Instance.new("UIStroke")
	s.Color = col or Theme.Border
	s.Thickness = th or Theme.BorderThickness
	s.Transparency = Theme.BorderTransparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = p
	return s
end

local function Pad(p, t, l, b, r)
	local d = Instance.new("UIPadding")
	d.PaddingTop = UDim.new(0, t or 0)
	d.PaddingLeft = UDim.new(0, l or 0)
	d.PaddingBottom = UDim.new(0, b or 0)
	d.PaddingRight = UDim.new(0, r or 0)
	d.Parent = p
	return d
end

local function isPressInput(inp)
	return inp ~= nil and (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch)
end

local function contrastOn(bg)
	local b = (bg.R + bg.G + bg.B) / 3
	return b > 0.6 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
end

--// Connect dengan rate-guard (safety net anti runaway)
local function Connect(signal, callback, owner)
	local conn
	local busy = false
	local n, win, mute = 0, os.clock(), 0
	conn = signal:Connect(function(...)
		if Library._destroyed or (type(Env) == "table" and Env.RoNetGeneration ~= Library.Generation) then
			pcall(function() if conn then conn:Disconnect() end end)
			return
		end
		if owner and owner._destroyed then
			pcall(function() if conn then conn:Disconnect() end end)
			return
		end
		local now = os.clock()
		if now < mute then return end
		if now - win >= 0.25 then n = 0 win = now end
		n += 1
		if n > 200 then mute = now + 1 return end
		if busy then return end
		busy = true
		local ok, err = pcall(callback, ...)
		busy = false
		if not ok then warn("[Ro-Net] " .. tostring(err)) end
	end)
	table.insert(Library._connections, conn)
	if owner and owner._connections then table.insert(owner._connections, conn) end
	return conn
end

--// ==========================================================
--// [FIX 1] ABSOLUTE SIZE GUARD
--// Handler lama: ubah Text -> AutomaticSize -> AbsoluteSize berubah
--// -> handler lagi -> loop tak berujung (re-entrancy) & FPS drop.
--// Solusi: (a) hanya proses kalau ukuran BENAR-BENAR berubah,
--//         (b) debounce waktu, (c) guard busy, (d) tulis Text
--//         hanya kalau berbeda.
--// ==========================================================
local function safeSizeConnect(obj, callback, owner)
	if not obj then return nil end
	local lastW, lastH = -1, -1
	local lastRun = 0
	local busy = false
	return Connect(obj:GetPropertyChangedSignal("AbsoluteSize"), function()
		if busy then return end
		if not obj.Parent then return end
		local now = os.clock()
		if now - lastRun < 0.06 then return end
		local s = obj.AbsoluteSize
		if math.abs(s.X - lastW) < 0.75 and math.abs(s.Y - lastH) < 0.75 then return end
		lastW, lastH = s.X, s.Y
		lastRun = now
		busy = true
		pcall(callback)
		busy = false
	end, owner)
end

local fitGuard = setmetatable({}, { __mode = "k" })
local BIG_VEC = Vector2.new(999999, 999999)

local function fitText(textObj, fullText)
	if not textObj or not textObj.Parent then return end
	local now = os.clock()
	local g = fitGuard[textObj]
	if g and now - g < 0.08 then return end
	fitGuard[textObj] = now

	fullText = tostring(fullText or "")
	local w = textObj.AbsoluteSize.X
	if w <= 1 then
		if textObj.Text ~= "" then textObj.Text = "" end
		return
	end
	w = w - 2
	local b0 = TextService:GetTextSize(fullText, textObj.TextSize, textObj.Font, BIG_VEC)
	if b0.X <= w then
		if textObj.Text ~= fullText then textObj.Text = fullText end
		return
	end
	local lo, hi, best = 1, #fullText, "..."
	while lo <= hi do
		local mid = math.floor((lo + hi) / 2)
		local cand = string.sub(fullText, 1, mid) .. "..."
		local bb = TextService:GetTextSize(cand, textObj.TextSize, textObj.Font, BIG_VEC)
		if bb.X <= w then best = cand lo = mid + 1 else hi = mid - 1 end
	end
	if textObj.Text ~= best then textObj.Text = best end
end
Library.FitText = fitText
Library.SafeSizeConnect = safeSizeConnect

--// [FIX 2] Nama key pendek supaya tidak menimpa nama bind
local KEY_SHORT = {
	RightControl = "RCtrl", LeftControl = "LCtrl", RightShift = "RShift", LeftShift = "LShift",
	RightAlt = "RAlt", LeftAlt = "LAlt", RightSuper = "RWin", LeftSuper = "LWin",
	CapsLock = "Caps", NumLock = "NumLk", ScrollLock = "ScrLk", Print = "PrtSc",
	PageUp = "PgUp", PageDown = "PgDn", Insert = "Ins", Delete = "Del",
	Backspace = "Bksp", Backquote = "`", Escape = "Esc", Return = "Enter",
}
local function shortKeyName(k)
	local n = (typeof(k) == "EnumItem" and k.Name) or tostring(k or "None")
	if n == "Unknown" then return "None" end
	return KEY_SHORT[n] or n
end
Library.ShortKeyName = shortKeyName

function Library:GetFlag(flag) return Library.Flags[flag] end

--// FPS / Ping
local fpsFrames, fpsLast = 0, os.clock()
Connect(RunService.RenderStepped, function() fpsFrames += 1 end)
local currentFps, currentPing = 0, 0
task.spawn(function()
	while true do
		task.wait(1)
		if Library._destroyed or (type(Env) == "table" and Env.RoNetGeneration ~= Library.Generation) then return end
		local now = os.clock()
		currentFps = math.floor(fpsFrames / math.max(now - fpsLast, 0.0001))
		fpsFrames, fpsLast = 0, now
		pcall(function() currentPing = math.floor(LocalPlayer:GetNetworkPing() * 1000) end)
	end
end)

--// ==========================================================
--// THEME MANAGER
--// ==========================================================
local ThemeManager = {
	Mode = Library.Rainbow and "RGB Rainbow" or "Solid",
	PresetName = Library.Rainbow and "RGB Rainbow" or "Solid",
	Time = 0, Dirty = true, Gradients = {}, Strokes = {},
}

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

local function accentSeq(c)
	c = (typeof(c) == "Color3" and c) or Color3.new(1, 1, 1)
	return ColorSequence.new{
		ColorSequenceKeypoint.new(0, c:Lerp(Color3.new(0,0,0), .45)),
		ColorSequenceKeypoint.new(.5, c:Lerp(Color3.new(1,1,1), .2)),
		ColorSequenceKeypoint.new(1, c:Lerp(Color3.new(0,0,0), .45)),
	}
end

local function currentRainbowColor(offset)
	offset = tonumber(offset) or 0
	local hue = ((ThemeManager.Time * (tonumber(Theme.RainbowSpeed) or 0.12)) + offset) % 1
	return Color3.fromHSV(hue, 1, 1)
end

function ThemeManager:GetColor(offset)
	if ThemeManager.Mode == "RGB Rainbow" then return currentRainbowColor(offset) end
	return Library.Accent
end

local function refreshRGBColors()
	for i = #ThemeManager.Gradients, 1, -1 do
		local g = ThemeManager.Gradients[i]
		if g and g.Parent then
			g.Color = ThemeManager.Mode == "RGB Rainbow" and rainbowSeq() or accentSeq(Library.Accent)
		else
			table.remove(ThemeManager.Gradients, i)
		end
	end
end

function ThemeManager:NotifyWindows()
	for _, w in ipairs(Library._windows) do
		if w and not w._destroyed then
			w.accent = Library.Accent
			if type(w.listeners) == "table" then
				for _, fn in ipairs(w.listeners) do pcall(fn, w.accent) end
			end
		end
	end
end

function ThemeManager:RefreshWindows()
	for _, w in ipairs(Library._windows) do
		if w and not w._destroyed and type(w.ApplyTheme) == "function" then
			pcall(function() w:ApplyTheme() end)
		end
	end
end

function ThemeManager:Update()
	if ThemeManager.Mode == "RGB Rainbow" then
		Library.Accent = currentRainbowColor(0)
		refreshRGBColors()
		ThemeManager:NotifyWindows()
		ThemeManager.Dirty = false
	elseif ThemeManager.Dirty then
		refreshRGBColors()
		ThemeManager:NotifyWindows()
		ThemeManager.Dirty = false
	end
end

function ThemeManager:SetMode(mode)
	ThemeManager.Mode = mode
	Library.Rainbow = (mode == "RGB Rainbow")
	if not Library.Rainbow and typeof(Library.Accent) ~= "Color3" then Library.Accent = Color3.new(1,1,1) end
	ThemeManager.Dirty = true
	ThemeManager:Update()
end

local function registerRGB(parent)
	if not parent then return nil end
	if parent:IsA("UIStroke") then
		local data = { obj = parent, offset = math.random() }
		table.insert(ThemeManager.Strokes, data)
		parent.Color = ThemeManager.Mode == "RGB Rainbow" and currentRainbowColor(data.offset) or Library.Accent
		return parent
	end
	local g = Instance.new("UIGradient")
	g.Color = ThemeManager.Mode == "RGB Rainbow" and rainbowSeq() or accentSeq(Library.Accent)
	g.Rotation = 35
	g.Parent = parent
	table.insert(ThemeManager.Gradients, g)
	return g
end

local strokeAcc, gradientAcc, accentAcc = 0, 0, 0
Connect(RunService.RenderStepped, function(dt)
	dt = tonumber(dt) or 0.016
	ThemeManager.Time += dt
	strokeAcc += dt
	if strokeAcc >= 0.05 then
		strokeAcc = 0
		for i = #ThemeManager.Strokes, 1, -1 do
			local d = ThemeManager.Strokes[i]
			if d.obj and d.obj.Parent then
				d.obj.Color = ThemeManager.Mode == "RGB Rainbow"
					and currentRainbowColor(d.offset + ThemeManager.Time * 0.08)
					or Library.Accent
			else
				table.remove(ThemeManager.Strokes, i)
			end
		end
	end
	gradientAcc += dt
	if gradientAcc >= 0.08 then
		gradientAcc = 0
		local off = (ThemeManager.Time * 0.18) % 1
		local rot = 35 + math.sin(ThemeManager.Time * 0.7) * 12
		for i = #ThemeManager.Gradients, 1, -1 do
			local g = ThemeManager.Gradients[i]
			if g and g.Parent then
				g.Offset = Vector2.new(off, 0)
				g.Rotation = rot
			else
				table.remove(ThemeManager.Gradients, i)
			end
		end
	end
	accentAcc += dt
	if accentAcc >= 0.12 then
		accentAcc = 0
		ThemeManager:Update()
	end
end)

function Library:SetRainbow(on) ThemeManager:SetMode(on and "RGB Rainbow" or "Solid") end

function Library:SetAccent(c)
	if typeof(c) ~= "Color3" then return end
	Library.Accent = c
	ThemeManager.Dirty = true
	if ThemeManager.Mode ~= "RGB Rainbow" then ThemeManager:Update() end
end

function Library:SetTheme(name)
	local preset = Theme.Presets[name]
	if not preset then return false end
	ThemeManager.PresetName = name
	if type(preset.Colors) == "table" then
		for k, v in pairs(preset.Colors) do Theme[k] = v end
	end
	if preset.Accent then Library.Accent = preset.Accent end
	if preset.Rainbow ~= nil then
		ThemeManager:SetMode(preset.Rainbow and "RGB Rainbow" or "Solid")
	else
		ThemeManager.Dirty = true
		ThemeManager:Update()
	end
	ThemeManager:RefreshWindows()
	return true
end

--// ==========================================================
--// [FIX 6] GRID OVERLAY (dipertebal) + SCANLINE
--// ==========================================================
local function createGridOverlay(parent, owner)
	if not Library.Effects.GridOverlay then return nil end
	local layer = Instance.new("Frame")
	layer.Name = "GridOverlay"
	layer.Size = UDim2.new(1, 0, 1, 0)
	layer.BackgroundTransparency = 1
	layer.BorderSizePixel = 0
	layer.ClipsDescendants = true
	layer.ZIndex = 39
	layer.Active = false
	layer.Parent = parent

	local vLines, hLines = {}, {}
	local scan = Instance.new("Frame")
	scan.Name = "Scanline"
	scan.Size = UDim2.new(1, 0, 0, Theme.ScanThickness)
	scan.BackgroundColor3 = Library.Accent
	scan.BackgroundTransparency = Theme.ScanTransparency
	scan.BorderSizePixel = 0
	scan.ZIndex = 41
	scan.Active = false
	scan.Parent = layer
	Corner(scan, 2)
	local scanGrad = Instance.new("UIGradient")
	scanGrad.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0),
		NumberSequenceKeypoint.new(0.8, 0),
		NumberSequenceKeypoint.new(1, 1),
	}
	scanGrad.Parent = scan

	local function layout()
		local size = layer.AbsoluteSize
		if size.X < 2 or size.Y < 2 then return end
		local spacing = math.max(12, tonumber(Theme.GridSpacing) or 26)
		local th = math.max(1, tonumber(Theme.GridThickness) or 2)
		local tr = math.clamp(tonumber(Theme.GridTransparency) or 0.78, 0, 0.97)
		local nv = math.floor(size.X / spacing)
		local nh = math.floor(size.Y / spacing)
		for i = 1, nv do
			local l = vLines[i]
			if not l then
				l = Instance.new("Frame")
				l.BorderSizePixel = 0
				l.ZIndex = 40
				l.Active = false
				l.Parent = layer
				vLines[i] = l
			end
			l.Size = UDim2.new(0, th, 1, 0)
			l.Position = UDim2.new(0, i * spacing, 0, 0)
			l.BackgroundTransparency = tr
			l.Visible = true
		end
		for i = nv + 1, #vLines do vLines[i].Visible = false end
		for i = 1, nh do
			local l = hLines[i]
			if not l then
				l = Instance.new("Frame")
				l.BorderSizePixel = 0
				l.ZIndex = 40
				l.Active = false
				l.Parent = layer
				hLines[i] = l
			end
			l.Size = UDim2.new(1, 0, 0, th)
			l.Position = UDim2.new(0, 0, 0, i * spacing)
			l.BackgroundTransparency = tr
			l.Visible = true
		end
		for i = nh + 1, #hLines do hLines[i].Visible = false end
		scan.Size = UDim2.new(1, 0, 0, math.max(2, tonumber(Theme.ScanThickness) or 3))
		scan.BackgroundTransparency = math.clamp(tonumber(Theme.ScanTransparency) or 0.72, 0, 0.97)
	end

	task.defer(layout)
	safeSizeConnect(layer, layout, owner)

	local acc = 0
	Connect(RunService.RenderStepped, function(dt)
		if not layer.Parent or not layer.Visible then return end
		acc += (tonumber(dt) or 0.016)
		if acc < 0.05 then return end
		acc = 0
		local c = ThemeManager:GetColor(0.15)
		for _, l in ipairs(vLines) do if l.Visible then l.BackgroundColor3 = c end end
		for _, l in ipairs(hLines) do if l.Visible then l.BackgroundColor3 = c end end
		scan.BackgroundColor3 = c
		local h = layer.AbsoluteSize.Y
		if h > 4 then
			local y = ((os.clock() * 26) % (h + 40)) - 20
			scan.Position = UDim2.new(0, 0, 0, y)
		end
	end, owner)

	layer:SetAttribute("Relayout", true)
	return layer, layout
end

--// ==========================================================
--// [FIX 5] PARTICLES: Dot + Crystal + Floating
--// Dipakai juga di Action frame & Close frame
--// ==========================================================
local function createParticleBackground(parent, count, owner)
	local particleLayer, dotLayer, crystalLayer
	count = math.clamp(tonumber(count) or Theme.ParticleCount or 26, 0, 70)

	-- DOT GRID (titik)
	if Library.Effects.Particles then
		dotLayer = Instance.new("Frame")
		dotLayer.Name = "DotLayer"
		dotLayer.Size = UDim2.new(1, 0, 1, 0)
		dotLayer.BackgroundTransparency = 1
		dotLayer.ClipsDescendants = true
		dotLayer.ZIndex = 38
		dotLayer.Active = false
		dotLayer.Parent = parent
		local dots = {}
		local function buildDots()
			local s = dotLayer.AbsoluteSize
			if s.X < 2 or s.Y < 2 then return end
			local sp = 34
			local nx, ny = math.floor(s.X / sp), math.floor(s.Y / sp)
			local need = nx * ny
			for i = 1, need do
				local d = dots[i]
				if not d then
					d = Instance.new("Frame")
					d.BorderSizePixel = 0
					d.AnchorPoint = Vector2.new(0.5, 0.5)
					d.ZIndex = 38
					d.Active = false
					d.Parent = dotLayer
					Corner(d, 99)
					dots[i] = d
				end
				local ix = (i - 1) % nx
				local iy = math.floor((i - 1) / nx)
				local sz = math.max(2, tonumber(Theme.DotSize) or 4)
				d.Size = UDim2.new(0, sz, 0, sz)
				d.Position = UDim2.new(0, ix * sp + sp / 2, 0, iy * sp + sp / 2)
				d.BackgroundTransparency = 0.86
				d.Visible = true
			end
			for i = need + 1, #dots do dots[i].Visible = false end
		end
		task.defer(buildDots)
		safeSizeConnect(dotLayer, buildDots, owner)
		local a = 0
		Connect(RunService.RenderStepped, function(dt)
			if not dotLayer.Parent or not dotLayer.Visible then return end
			a += (tonumber(dt) or 0.016)
			if a < 0.12 then return end
			a = 0
			local c = ThemeManager:GetColor(0.4)
			local t = os.clock()
			for i, d in ipairs(dots) do
				if d.Visible then
					d.BackgroundColor3 = c
					d.BackgroundTransparency = 0.80 + 0.12 * math.sin(t * 1.4 + i * 0.35)
				end
			end
		end, owner)
	end

	-- CRYSTAL (berputar)
	if Library.Effects.Crystals then
		crystalLayer = Instance.new("Frame")
		crystalLayer.Name = "CrystalLayer"
		crystalLayer.Size = UDim2.new(1, 0, 1, 0)
		crystalLayer.BackgroundTransparency = 1
		crystalLayer.ClipsDescendants = true
		crystalLayer.ZIndex = 39
		crystalLayer.Active = false
		crystalLayer.Parent = parent
		local crystals = {}
		local n = math.clamp(math.floor(count / 3), 3, 14)
		for i = 1, n do
			local sz = math.random(5, math.max(6, tonumber(Theme.CrystalSize) or 7) + 4)
			local f = Instance.new("Frame")
			f.Size = UDim2.new(0, sz, 0, sz)
			f.AnchorPoint = Vector2.new(0.5, 0.5)
			f.Position = UDim2.new(math.random(), 0, math.random(), 0)
			f.BackgroundColor3 = Library.Accent
			f.BackgroundTransparency = 0.72
			f.BorderSizePixel = 0
			f.Rotation = math.random(0, 360)
			f.ZIndex = 39
			f.Active = false
			f.Parent = crystalLayer
			Corner(f, 2)
			local st = Stroke(f, Library.Accent, 1.4)
			st.Transparency = 0.5
			crystals[i] = { f = f, st = st, spin = (math.random() - 0.5) * 40, ph = math.random() * 6.28, hue = math.random() }
		end
		local a = 0
		Connect(RunService.RenderStepped, function(dt)
			if not crystalLayer.Parent or not crystalLayer.Visible then return end
			dt = tonumber(dt) or 0.016
			a += dt
			local c = ThemeManager:GetColor(0.6)
			for _, d in ipairs(crystals) do
				if d.f.Parent then
					d.f.Rotation += d.spin * dt
					d.f.BackgroundColor3 = c
					d.st.Color = c
					d.f.BackgroundTransparency = 0.66 + 0.16 * math.sin(os.clock() * 1.1 + d.ph)
				end
			end
		end, owner)
	end

	-- FLOATING PARTICLES
	if Library.Effects.Particles and count > 0 then
		particleLayer = Instance.new("Frame")
		particleLayer.Name = "ParticleLayer"
		particleLayer.Size = UDim2.new(1, 0, 1, 0)
		particleLayer.BackgroundTransparency = 1
		particleLayer.ClipsDescendants = true
		particleLayer.ZIndex = 40
		particleLayer.Active = false
		particleLayer.Parent = parent
		local parts = {}
		for _ = 1, count do
			local size = math.random(2, 5)
			local p = Instance.new("Frame")
			p.AnchorPoint = Vector2.new(0.5, 0.5)
			p.Size = UDim2.new(0, size, 0, size)
			p.Position = UDim2.new(math.random(), 0, math.random(), 0)
			p.BackgroundColor3 = Library.Accent
			p.BackgroundTransparency = math.random(58, 88) / 100
			p.BorderSizePixel = 0
			p.ZIndex = 40
			p.Active = false
			p.Parent = particleLayer
			Corner(p, 99)
			table.insert(parts, {
				f = p, x = nil, y = nil, init = false,
				vx = (math.random() - 0.5) * 16, vy = (math.random() - 0.5) * 16,
				baseT = p.BackgroundTransparency, ph = math.random() * 6.28,
				sp = 0.8 + math.random() * 1.2, hue = math.random(),
			})
		end
		local colAcc = 0
		Connect(RunService.RenderStepped, function(dt)
			if not particleLayer.Parent or not particleLayer.Visible then return end
			dt = tonumber(dt) or 0.016
			local size = particleLayer.AbsoluteSize
			if size.X < 2 or size.Y < 2 then return end
			local t = os.clock()
			colAcc += dt
			local upd = colAcc > 0.12
			if upd then colAcc = 0 end
			local c = ThemeManager:GetColor(0.2)
			for _, d in ipairs(parts) do
				if d.f.Parent then
					if not d.init then
						d.x, d.y = math.random() * size.X, math.random() * size.Y
						d.init = true
					end
					d.x += d.vx * dt
					d.y += d.vy * dt
					if d.x < -12 then d.x = size.X + 12 elseif d.x > size.X + 12 then d.x = -12 end
					if d.y < -12 then d.y = size.Y + 12 elseif d.y > size.Y + 12 then d.y = -12 end
					d.f.Position = UDim2.new(0, d.x, 0, d.y)
					d.f.BackgroundTransparency = math.clamp(d.baseT - (0.5 + 0.5 * math.sin(t * d.sp + d.ph)) * 0.16, 0.05, 0.95)
					if upd then d.f.BackgroundColor3 = c end
				end
			end
		end, owner)
	end

	return particleLayer, dotLayer, crystalLayer
end
Library.CreateParticles = createParticleBackground
Library.CreateGrid = createGridOverlay

--// ==========================================================
--// [FIX 3] LOCKED OVERLAY (button / toggle / slider / dll)
--// cfg.Locked = true            -> terkunci manual
--// cfg.LockBy = "NamaFlag"      -> terbuka kalau flag itu true
--// cfg.LockText = "..."         -> teks overlay
--// obj:SetLocked(bool)          -> kontrol manual
--// ==========================================================
local lockWatchers = {}

local function applyLocked(frame, locked, text)
	if not frame or not frame.Parent then return end
	local gate = frame:FindFirstChild("RN_Lock")
	if not gate then
		gate = Instance.new("Frame")
		gate.Name = "RN_Lock"
		gate.Size = UDim2.new(1, 0, 1, 0)
		gate.BackgroundColor3 = Color3.fromRGB(6, 6, 9)
		gate.BackgroundTransparency = 0.32
		gate.BorderSizePixel = 0
		gate.ZIndex = 80
		gate.Active = true
		gate.Parent = frame
		Corner(gate, 8)
		local ic = makeIcon(gate, "lock", UDim2.new(0, 13, 0, 13), UDim2.new(0, 10, 0.5, -6), Color3.fromRGB(235, 235, 240))
		if ic then ic.ZIndex = 81 ic.ImageTransparency = 0.15 end
		local lbl = Instance.new("TextLabel")
		lbl.Name = "LockLabel"
		lbl.Size = UDim2.new(1, -32, 1, 0)
		lbl.Position = UDim2.new(0, 28, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text or "LOCKED"
		lbl.TextColor3 = Color3.fromRGB(238, 238, 244)
		lbl.TextTransparency = 0.12
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 11
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextYAlignment = Enum.TextYAlignment.Center
		lbl.TextTruncate = Enum.TextTruncate.AtEnd
		lbl.ZIndex = 81
		lbl.Parent = gate
	end
	local lbl = gate:FindFirstChild("LockLabel")
	if lbl and text then lbl.Text = text end
	gate.Visible = locked and true or false
end
Library.ApplyLocked = applyLocked

local function setupLock(frame, cfg, obj)
	cfg = cfg or {}
	local state = { locked = false, text = cfg.LockText }
	local function resolve()
		local locked = false
		if cfg.LockBy and cfg.LockBy ~= "" then
			locked = not (Library.Flags[cfg.LockBy] and true or false)
			if not state.text then
				state.text = "Enable " .. tostring(cfg.LockBy) .. " first"
			end
		end
		if cfg.Locked == true then locked = true end
		if state.manual ~= nil then locked = state.manual end
		state.locked = locked
		applyLocked(frame, locked, state.text or "LOCKED")
	end
	if cfg.LockBy and cfg.LockBy ~= "" then
		table.insert(lockWatchers, { flag = cfg.LockBy, fn = resolve })
	end
	resolve()
	if obj then
		obj.SetLocked = function(self, v)
			state.manual = v and true or false
			resolve()
		end
		obj.IsLocked = function() return state.locked end
	end
	return state
end
Library.SetupLock = setupLock

local function notifyLockWatchers(flag)
	for _, w in ipairs(lockWatchers) do
		if w.flag == flag then pcall(w.fn) end
	end
end
Library.NotifyLockWatchers = notifyLockWatchers

--// ==========================================================
--// [FIX 8] STAGGER ENTER ANIMATION (anti lag saat buka tab)
--// ==========================================================
local function playEnter(frame, order)
	if not frame or not frame.Parent then return end
	if not Library.Stagger.Enabled then return end
	local sc = frame:FindFirstChildOfClass("UIScale")
	if not sc then
		sc = Instance.new("UIScale")
		sc.Parent = frame
	end
	sc.Scale = 0.94
	local baseT = frame.BackgroundTransparency
	if frame:IsA("Frame") and baseT < 1 then frame.BackgroundTransparency = 1 end
	local delayTime = math.min((tonumber(order) or 0) * Library.Stagger.Step, Library.Stagger.Max)
	task.delay(delayTime, function()
		if not frame.Parent then return end
		Tween(sc, 0.28, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		if frame:IsA("Frame") and baseT < 1 then
			Tween(frame, 0.22, { BackgroundTransparency = baseT })
		end
	end)
end
Library.PlayEnter = playEnter

local function staggerChildren(container)
	if not container or not Library.Stagger.Enabled then return end
	local i = 0
	for _, ch in ipairs(container:GetChildren()) do
		if ch:IsA("Frame") and ch.Visible then
			i += 1
			local sc = ch:FindFirstChildOfClass("UIScale")
			if not sc then
				sc = Instance.new("UIScale")
				sc.Parent = ch
			end
			sc.Scale = 0.96
			local d = math.min(i * (Library.Stagger.Step * 0.7), Library.Stagger.Max)
			task.delay(d, function()
				if ch.Parent then Tween(sc, 0.24, { Scale = 1 }, Enum.EasingStyle.Quint) end
			end)
		end
	end
end
Library.StaggerChildren = staggerChildren

--// ==========================================================
--// SEARCH + ELEMENT REGISTRY
--// ==========================================================
function Library:_RegisterSearch(data)
	if Library._destroyed then return end
	data.Index = #Library._searchIndex + 1
	data._removed = false
	table.insert(Library._searchIndex, data)
end

function Library:Search(query)
	query = string.lower(tostring(query or ""))
	local out = {}
	if query == "" then return out end
	for _, item in ipairs(Library._searchIndex) do
		if not item._removed then
			if item.Window and item.Window._destroyed then
			elseif item.Frame and not item.Frame.Parent then
			else
				local kw = ""
				if type(item.Keywords) == "table" then
					for _, v in ipairs(item.Keywords) do kw = kw .. " " .. tostring(v) end
				end
				local hay = string.lower(table.concat({
					tostring(item.Name or ""), tostring(item.Type or ""),
					tostring(item.TabName or ""), tostring(item.Flag or ""), kw,
				}, " "))
				if string.find(hay, query, 1, true) then table.insert(out, item) end
			end
		end
	end
	table.sort(out, function(a, b) return #tostring(a.Name or "") < #tostring(b.Name or "") end)
	return out
end

local function registerElement(windowRef, tabRef, tabName, frameRef, cfgRef, elementType, objRef)
	cfgRef = cfgRef or {}
	local displayName = cfgRef.Name or cfgRef.Title or elementType
	local flag = cfgRef.Flag
	if flag and flag ~= "" then
		Library._elements[flag] = {
			Type = elementType, Object = objRef, Name = displayName,
			Tab = tabRef, TabName = tabName, Frame = frameRef,
			Window = windowRef, Config = cfgRef,
		}
	end
	Library:_RegisterSearch({
		Name = displayName, Type = elementType, Tab = tabRef, TabName = tabName,
		Frame = frameRef, Flag = flag, Keywords = cfgRef.Keywords, Window = windowRef,
	})
	return objRef
end

--// ==========================================================
--// [FIX 7] FRAME POSITION PERSISTENCE
--// ==========================================================
function Library:SetFramePosition(name, x, y)
	if not name then return end
	Library.FramePositions[name] = { X = math.floor(x), Y = math.floor(y) }
end

function Library:GetFramePosition(name)
	local p = Library.FramePositions[name]
	if type(p) == "table" and tonumber(p.X) and tonumber(p.Y) then
		return tonumber(p.X), tonumber(p.Y)
	end
	return nil
end

function Library:ClearFramePositions()
	Library.FramePositions = {}
end

--// ==========================================================
--// SAVE / LOAD SYSTEM (+ Theme + Effects + FramePositions)
--// ==========================================================
local SAVE_FOLDER = "Ro-Netrium/Saves"

local function sanitizeFileName(name)
	name = tostring(name or "autosave")
	name = name:gsub("[^%w_%-%.]", "_"):gsub("^_+", ""):gsub("_+$", "")
	if name == "" then name = "autosave" end
	if #name > 64 then name = name:sub(1, 64) end
	return name
end

local function saveFilePath(name) return SAVE_FOLDER .. "/" .. sanitizeFileName(name) .. ".json" end

local function ensureFolder()
	if typeof(makefolder) == "function" then
		pcall(makefolder, "Ro-Netrium")
		pcall(makefolder, SAVE_FOLDER)
	end
end

local function listSaveFiles()
	local files = {}
	if typeof(listfiles) ~= "function" then return files end
	ensureFolder()
	local ok, res = pcall(listfiles, SAVE_FOLDER)
	if ok and type(res) == "table" then
		for _, v in ipairs(res) do
			local s = tostring(v)
			local name = s:match("([^/\\]+)%.json$") or s:match("^([%w_%-%.]+)%.json$")
			if name then files[#files + 1] = name end
		end
	end
	table.sort(files)
	return files
end

local function getSaveOptions()
	local files = listSaveFiles()
	if #files == 0 then return { "(no saves)" } end
	return files
end

local function writeSaveRaw(name, text)
	if typeof(writefile) ~= "function" then return false, "writefile is not available in this executor." end
	ensureFolder()
	local ok = pcall(writefile, saveFilePath(name), text)
	return ok, ok and nil or "Failed to write file."
end

local function readSaveRaw(name)
	if typeof(readfile) ~= "function" then return nil, "readfile is not available in this executor." end
	if typeof(isfile) == "function" then
		local ok, exists = pcall(isfile, saveFilePath(name))
		if not ok or not exists then return nil, "File not found." end
	end
	local ok, content = pcall(readfile, saveFilePath(name))
	if ok and type(content) == "string" and #content > 0 then return content end
	return nil, "Failed to read file."
end

local function encodeValue(v)
	if typeof(v) == "Color3" then return { __type = "Color3", R = v.R, G = v.G, B = v.B }
	elseif typeof(v) == "EnumItem" and v.EnumType == Enum.KeyCode then return { __type = "KeyCode", Name = v.Name } end
	return v
end

local function decodeValue(v)
	if type(v) == "table" then
		if v.__type == "Color3" then return Color3.new(v.R or 1, v.G or 1, v.B or 1)
		elseif v.__type == "KeyCode" then return Enum.KeyCode[v.Name] or Enum.KeyCode.Unknown end
	end
	return v
end

local function buildPayload(name)
	local values = {}
	for flag, val in pairs(Library.Flags) do values[flag] = encodeValue(val) end
	local placeId = 0
	pcall(function() placeId = game.PlaceId end)
	local positions = {}
	for k, v in pairs(Library.FramePositions) do
		if type(v) == "table" then positions[k] = { X = v.X, Y = v.Y } end
	end
	return {
		Meta = {
			Library = "Ro-Netrium", Version = Library.Version,
			SavedAt = os.time(), PlaceId = placeId, FileName = name or Library._saveFile,
		},
		Values = values,
		Positions = positions,
		Theme = {
			Preset = ThemeManager.PresetName,
			Rainbow = Library.Rainbow,
			Accent = encodeValue(Library.Accent),
			RainbowSpeed = Theme.RainbowSpeed,
			MainBorderThickness = Theme.MainBorderThickness,
			ElementBorderThickness = Theme.ElementBorderThickness,
			AnimationSpeed = Library.AnimationSpeed,
			GridThickness = Theme.GridThickness,
			GridTransparency = Theme.GridTransparency,
			GridSpacing = Theme.GridSpacing,
			ScanThickness = Theme.ScanThickness,
			BorderGlow = Theme.BorderGlow,
		},
		Effects = {
			Particles = Library.Effects.Particles,
			Crystals = Library.Effects.Crystals,
			GridOverlay = Library.Effects.GridOverlay,
			Glow = Library.Effects.Glow,
			Ripple = Library.Effects.Ripple,
			Shadow = Library.Effects.Shadow,
		},
	}
end

function Library:SaveToFile(name)
	name = sanitizeFileName(name)
	local okEnc, encoded = pcall(function() return HttpService:JSONEncode(buildPayload(name)) end)
	if not okEnc then return false, "Failed to encode JSON." end
	return writeSaveRaw(name, encoded)
end

function Library:ExportConfigString()
	local ok, s = pcall(function() return HttpService:JSONEncode(buildPayload(Library._saveFile)) end)
	if ok then return s end
	return nil
end

local function applyPayload(data, applyTheme)
	if type(data) ~= "table" then return false end
	Library._loading = true

	-- Theme & effects dulu supaya elemen baru ikut warna
	if applyTheme ~= false and type(data.Theme) == "table" then
		local t = data.Theme
		if t.Preset and Theme.Presets[t.Preset] then Library:SetTheme(t.Preset) end
		if tonumber(t.RainbowSpeed) then Theme.RainbowSpeed = tonumber(t.RainbowSpeed) end
		if tonumber(t.MainBorderThickness) then Theme.MainBorderThickness = tonumber(t.MainBorderThickness) end
		if tonumber(t.ElementBorderThickness) then
			Theme.ElementBorderThickness = tonumber(t.ElementBorderThickness)
			Theme.BorderThickness = Theme.ElementBorderThickness
		end
		if tonumber(t.AnimationSpeed) then Library.AnimationSpeed = tonumber(t.AnimationSpeed) end
		if tonumber(t.GridThickness) then Theme.GridThickness = tonumber(t.GridThickness) end
		if tonumber(t.GridTransparency) then Theme.GridTransparency = tonumber(t.GridTransparency) end
		if tonumber(t.GridSpacing) then Theme.GridSpacing = tonumber(t.GridSpacing) end
		if tonumber(t.ScanThickness) then Theme.ScanThickness = tonumber(t.ScanThickness) end
		if t.BorderGlow ~= nil then Theme.BorderGlow = t.BorderGlow and true or false end
		if t.Rainbow ~= nil then Library:SetRainbow(t.Rainbow and true or false) end
		local acc = decodeValue(t.Accent)
		if typeof(acc) == "Color3" and not Library.Rainbow then Library:SetAccent(acc) end
	end
	if type(data.Effects) == "table" then
		for k, v in pairs(data.Effects) do
			if Library.Effects[k] ~= nil then Library.Effects[k] = v and true or false end
		end
	end

	-- Flags
	for flag, encoded in pairs(data.Values or {}) do
		local value = decodeValue(encoded)
		Library.Flags[flag] = value
		local el = Library._elements[flag]
		if el and el.Object then
			pcall(function()
				local ty = el.Type
				if ty == "toggle" or ty == "slider" then el.Object:Set(value)
				elseif ty == "textbox" or ty == "input" then el.Object:Set(tostring(value or ""))
				elseif ty == "dropdown" then el.Object:Set(tostring(value or ""))
				elseif ty == "multidropdown" then el.Object:Set(value)
				elseif ty == "keybind" then
					local kc = value
					if typeof(kc) == "string" then kc = Enum.KeyCode[kc] or Enum.KeyCode.Unknown end
					if typeof(kc) == "EnumItem" and kc.EnumType == Enum.KeyCode then el.Object:SetKey(kc) end
				elseif ty == "colorpicker" then
					if typeof(value) == "Color3" then el.Object:Set(value) end
				end
			end)
		end
		notifyLockWatchers(flag)
	end

	-- [FIX 7] posisi frame
	if type(data.Positions) == "table" then
		for k, v in pairs(data.Positions) do
			if type(v) == "table" and tonumber(v.X) and tonumber(v.Y) then
				Library.FramePositions[k] = { X = tonumber(v.X), Y = tonumber(v.Y) }
			end
		end
		for _, w in ipairs(Library._windows) do
			if w and not w._destroyed and type(w.ApplyFramePositions) == "function" then
				pcall(function() w:ApplyFramePositions() end)
			end
		end
	end

	Library._loading = false
	ThemeManager:RefreshWindows()
	return true
end

function Library:LoadFromFile(name)
	name = sanitizeFileName(name)
	local raw, err = readSaveRaw(name)
	if not raw then return false, err end
	local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
	if not ok or type(data) ~= "table" then return false, "Save file is corrupted / invalid JSON." end
	local done = applyPayload(data, true)
	if done then Library._saveFile = name end
	return done, done and nil or "Failed to apply config."
end

function Library:ImportConfigString(s)
	local ok, data = pcall(function() return HttpService:JSONDecode(tostring(s or "")) end)
	if not ok or type(data) ~= "table" then return false, "Invalid config string." end
	return applyPayload(data, true)
end

function Library:DeleteSave(name)
	name = sanitizeFileName(name)
	local del = (typeof(delfile) == "function" and delfile) or (typeof(deletefile) == "function" and deletefile) or nil
	if not del then return false, "delfile / deletefile is not available." end
	local ok = pcall(del, saveFilePath(name))
	return ok, ok and nil or "Failed to delete file."
end

Library.GetSaveOptions = getSaveOptions
Library.ListSaves = listSaveFiles

task.spawn(function()
	local timer = 0
	while true do
		task.wait(1)
		if Library._destroyed or (type(Env) == "table" and Env.RoNetGeneration ~= Library.Generation) then return end
		if Library.AutoSave.Enabled then
			timer += 1
			if timer >= math.max(5, tonumber(Library.AutoSave.Interval) or 60) then
				timer = 0
				pcall(function() Library:SaveToFile(Library._saveFile or "autosave") end)
			end
		else
			timer = 0
		end
	end
end)

--// ==========================================================
--// NOTIFICATION SYSTEM
--// ==========================================================
Library.NotificationWidth = Library.NotificationWidth or 320
Library.NotificationRightOffset = Library.NotificationRightOffset or 16
Library.NotificationTopOffset = Library.NotificationTopOffset or 12

local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "RoNetNotifies"
NotifGui.ResetOnSpawn = false
NotifGui.DisplayOrder = 9999
NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotifGui.IgnoreGuiInset = true
pcall(function() NotifGui.Parent = game:GetService("CoreGui") end)
if not NotifGui.Parent then pcall(function() NotifGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end) end

local notifyContainer, notifyList
local function rebuildNotifyContainer()
	if not NotifGui or not NotifGui.Parent then
		NotifGui = Instance.new("ScreenGui")
		NotifGui.Name = "RoNetNotifies"
		NotifGui.ResetOnSpawn = false
		NotifGui.DisplayOrder = 9999
		NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		NotifGui.IgnoreGuiInset = true
		pcall(function() NotifGui.Parent = game:GetService("CoreGui") end)
		if not NotifGui.Parent then pcall(function() NotifGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end) end
	end
	if not notifyContainer or not notifyContainer.Parent then
		notifyContainer = Instance.new("Frame")
		notifyContainer.Name = "NotifyContainer"
		notifyContainer.Size = UDim2.new(0, Library.NotificationWidth, 1, -24)
		notifyContainer.Position = UDim2.new(1, -(Library.NotificationWidth + Library.NotificationRightOffset), 0, Library.NotificationTopOffset)
		notifyContainer.BackgroundTransparency = 1
		notifyContainer.BorderSizePixel = 0
		notifyContainer.Parent = NotifGui
		notifyList = Instance.new("UIListLayout")
		notifyList.SortOrder = Enum.SortOrder.LayoutOrder
		notifyList.Padding = UDim.new(0, 8)
		notifyList.HorizontalAlignment = Enum.HorizontalAlignment.Center
		notifyList.VerticalAlignment = Enum.VerticalAlignment.Top
		notifyList.Parent = notifyContainer
	end
end
rebuildNotifyContainer()

local function notifyToText(value)
	if type(value) == "table" then return table.concat(value, "\n") end
	return tostring(value or "")
end

function Library:Notify(...)
	if Library._destroyed then return end
	local first = ...
	local cfg
	if type(first) == "table" then
		cfg = first
	else
		cfg = { Content = first, Duration = select(2, ...), Title = select(3, ...), Image = select(4, ...) }
	end
	local content = notifyToText(cfg.Content or cfg.Text or cfg.Message or "")
	local title = notifyToText(cfg.Title or cfg.title or "")
	local image = cfg.Image or cfg.Icon or cfg.icon
	if image == nil and (title ~= "" or content ~= "") then image = "info" end
	local duration = tonumber(cfg.Duration or cfg.duration) or 5
	if duration < 0.1 then duration = 0.1 end
	local accent = cfg.Color or cfg.Accent or Library.Accent
	if typeof(accent) ~= "Color3" then accent = Library.Accent end
	local hasTitle, hasContent = title ~= "", content ~= ""
	local hasIcon = image ~= nil and image ~= "" and image ~= 0
	if not hasTitle and not hasContent and not hasIcon then return end

	Library._notifyOrder = (Library._notifyOrder or 0) - 1
	local order = Library._notifyOrder
	task.spawn(function()
		if Library._destroyed then return end
		rebuildNotifyContainer()
		local holder = Instance.new("Frame")
		holder.Name = "NotifyHolder"
		holder.Size = UDim2.new(1, 0, 0, 0)
		holder.AutomaticSize = Enum.AutomaticSize.Y
		holder.BackgroundTransparency = 1
		holder.BorderSizePixel = 0
		holder.ClipsDescendants = true
		holder.LayoutOrder = order
		holder.Parent = notifyContainer

		local n = Instance.new("Frame")
		n.Name = "Notification"
		n.Size = UDim2.new(1, 0, 0, 0)
		n.AutomaticSize = Enum.AutomaticSize.Y
		n.BackgroundColor3 = Theme.Element
		n.BackgroundTransparency = 1
		n.BorderSizePixel = 0
		n.ClipsDescendants = true
		n.Position = UDim2.new(1, 36, 0, 0)
		n.Parent = holder
		Corner(n, 10)
		local st = Stroke(n, Color3.new(1,1,1), 1.5)
		st.Transparency = 1
		registerRGB(st)
		Pad(n, 12, 12, 10, 12)
		local nl = Instance.new("UIListLayout")
		nl.SortOrder = Enum.SortOrder.LayoutOrder
		nl.Padding = UDim.new(0, 8)
		nl.HorizontalAlignment = Enum.HorizontalAlignment.Center
		nl.Parent = n

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 0)
		row.AutomaticSize = Enum.AutomaticSize.Y
		row.BackgroundTransparency = 1
		row.BorderSizePixel = 0
		row.LayoutOrder = 1
		row.Parent = n
		local rl = Instance.new("UIListLayout")
		rl.FillDirection = Enum.FillDirection.Horizontal
		rl.SortOrder = Enum.SortOrder.LayoutOrder
		rl.Padding = UDim.new(0, 10)
		rl.VerticalAlignment = Enum.VerticalAlignment.Center
		rl.Parent = row

		local icon
		if hasIcon then
			icon = Instance.new("ImageLabel")
			icon.Size = UDim2.new(0, 32, 0, 32)
			icon.BackgroundTransparency = 1
			icon.ImageTransparency = 1
			icon.ImageColor3 = accent
			icon.LayoutOrder = 1
			icon.Parent = row
			setIcon(icon, image)
		end
		local textBox = Instance.new("Frame")
		textBox.Size = UDim2.new(1, hasIcon and -42 or 0, 0, 0)
		textBox.AutomaticSize = Enum.AutomaticSize.Y
		textBox.BackgroundTransparency = 1
		textBox.BorderSizePixel = 0
		textBox.LayoutOrder = 2
		textBox.Parent = row
		local tl = Instance.new("UIListLayout")
		tl.SortOrder = Enum.SortOrder.LayoutOrder
		tl.Padding = UDim.new(0, 3)
		tl.Parent = textBox

		local titleLbl, contentLbl
		if hasTitle then
			titleLbl = Instance.new("TextLabel")
			titleLbl.Size = UDim2.new(1, 0, 0, 0)
			titleLbl.AutomaticSize = Enum.AutomaticSize.Y
			titleLbl.BackgroundTransparency = 1
			titleLbl.Text = title
			titleLbl.TextColor3 = accent
			titleLbl.TextSize = 14
			titleLbl.Font = Enum.Font.GothamBold
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left
			titleLbl.TextWrapped = true
			titleLbl.TextTransparency = 1
			titleLbl.LayoutOrder = 1
			titleLbl.Parent = textBox
		end
		if hasContent then
			contentLbl = Instance.new("TextLabel")
			contentLbl.Size = UDim2.new(1, 0, 0, 0)
			contentLbl.AutomaticSize = Enum.AutomaticSize.Y
			contentLbl.BackgroundTransparency = 1
			contentLbl.Text = content
			contentLbl.TextColor3 = Color3.fromRGB(232, 232, 232)
			contentLbl.TextSize = 12
			contentLbl.Font = Enum.Font.Gotham
			contentLbl.TextXAlignment = Enum.TextXAlignment.Left
			contentLbl.TextWrapped = true
			contentLbl.TextTransparency = 1
			contentLbl.LayoutOrder = 2
			contentLbl.Parent = textBox
		end

		local track = Instance.new("Frame")
		track.Size = UDim2.new(1, 0, 0, 4)
		track.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		track.BackgroundTransparency = 0.25
		track.BorderSizePixel = 0
		track.ClipsDescendants = true
		track.LayoutOrder = 2
		track.Parent = n
		Corner(track, 99)
		local fill = Instance.new("Frame")
		fill.Size = UDim2.new(1, 0, 1, 0)
		fill.BackgroundColor3 = accent
		fill.BorderSizePixel = 0
		fill.Parent = track
		Corner(fill, 99)

		task.wait()
		Tween(n, 0.35, { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0 }, Enum.EasingStyle.Back)
		Tween(st, 0.35, { Transparency = 0 })
		if icon then Tween(icon, 0.28, { ImageTransparency = 0 }) end
		if titleLbl then Tween(titleLbl, 0.28, { TextTransparency = 0 }) end
		if contentLbl then Tween(contentLbl, 0.28, { TextTransparency = 0 }) end
		Tween(fill, duration, { Size = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Linear)

		task.delay(duration, function()
			if not holder or not holder.Parent then return end
			Tween(n, 0.3, { Position = UDim2.new(1, 36, 0, 0), BackgroundTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			Tween(st, 0.3, { Transparency = 1 })
			if icon then Tween(icon, 0.25, { ImageTransparency = 1 }) end
			if titleLbl then Tween(titleLbl, 0.25, { TextTransparency = 1 }) end
			if contentLbl then Tween(contentLbl, 0.25, { TextTransparency = 1 }) end
			task.delay(0.32, function() if holder and holder.Parent then holder:Destroy() end end)
		end)
	end)
end

--// ==========================================================
--// [FIX 4 + 5] ACTION / WARNING MODAL (Yes / No) + PARTICLES
--// Library:Action{ Title, Content, ConfirmText, CancelText,
--//                 Danger, Cooldown, OnConfirm, OnCancel }
--// ==========================================================
local ActionGui = Instance.new("ScreenGui")
ActionGui.Name = "RoNetAction"
ActionGui.ResetOnSpawn = false
ActionGui.DisplayOrder = 10000
ActionGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ActionGui.IgnoreGuiInset = true
pcall(function() ActionGui.Parent = game:GetService("CoreGui") end)
if not ActionGui.Parent then pcall(function() ActionGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end) end

local activeAction = nil

local function closeAction()
	if not activeAction then return end
	local a = activeAction
	activeAction = nil
	Library._actionOpen = false
	Library._buttonPressLock = false
	if a.modal and a.modal.Parent then
		Tween(a.scale, 0.18, { Scale = 0.9 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		Tween(a.modal, 0.18, { BackgroundTransparency = 1 })
		if a.blocker then Tween(a.blocker, 0.2, { BackgroundTransparency = 1 }) end
		task.delay(0.22, function()
			if a.root and a.root.Parent then a.root:Destroy() end
		end)
	end
end
Library.CloseAction = closeAction

function Library:Action(cfg)
	cfg = cfg or {}
	if Library._destroyed then return end
	closeAction()
	Library._actionOpen = true
	Library._buttonPressLock = true

	local danger = cfg.Danger ~= false
	local accent = (typeof(cfg.Accent) == "Color3" and cfg.Accent)
		or (danger and Theme.Danger or Library.Accent)
	local hover = danger and Theme.DangerHover or accent:Lerp(Color3.new(1,1,1), 0.18)

	local root = Instance.new("Frame")
	root.Name = "ActionRoot"
	root.Size = UDim2.new(1, 0, 1, 0)
	root.BackgroundTransparency = 1
	root.ZIndex = 9000
	root.Parent = ActionGui

	local blocker = Instance.new("TextButton")
	blocker.Name = "Blocker"
	blocker.Size = UDim2.new(1, 0, 1, 0)
	blocker.BackgroundColor3 = Color3.new(0, 0, 0)
	blocker.BackgroundTransparency = 1
	blocker.BorderSizePixel = 0
	blocker.Text = ""
	blocker.AutoButtonColor = false
	blocker.ZIndex = 9000
	blocker.Parent = root
	Tween(blocker, 0.2, { BackgroundTransparency = 0.45 })

	local modal = Instance.new("Frame")
	modal.Name = "ActionModal"
	modal.AnchorPoint = Vector2.new(0.5, 0.5)
	modal.Position = UDim2.new(0.5, 0, 0.5, 0)
	modal.Size = UDim2.new(0, 372, 0, 214)
	modal.BackgroundColor3 = Theme.ConfirmBackground
	modal.BackgroundTransparency = 1
	modal.BorderSizePixel = 0
	modal.ClipsDescendants = true
	modal.ZIndex = 9001
	modal.Parent = root
	Corner(modal, 12)
	local mStroke = Stroke(modal, accent, 2)
	mStroke.Transparency = 1
	registerRGB(mStroke)

	local scale = Instance.new("UIScale")
	scale.Scale = 0.88
	scale.Parent = modal

	-- [FIX 5] partikel + grid di dalam action frame
	createGridOverlay(modal, nil)
	createParticleBackground(modal, 16, nil)

	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.ZIndex = 9005
	content.Parent = modal

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, -28, 0, 34)
	header.Position = UDim2.new(0, 14, 0, 14)
	header.BackgroundTransparency = 1
	header.ZIndex = 9006
	header.Parent = content
	local hl = Instance.new("UIListLayout")
	hl.FillDirection = Enum.FillDirection.Horizontal
	hl.SortOrder = Enum.SortOrder.LayoutOrder
	hl.Padding = UDim.new(0, 10)
	hl.VerticalAlignment = Enum.VerticalAlignment.Center
	hl.Parent = header
	local hIcon = makeIcon(header, cfg.Icon or (danger and "triangle-alert" or "help-circle"),
		UDim2.new(0, 22, 0, 22), UDim2.new(0, 0, 0, 0), accent)
	if hIcon then hIcon.LayoutOrder = 1 hIcon.ZIndex = 9007 end
	local tLbl = Instance.new("TextLabel")
	tLbl.Size = UDim2.new(1, -34, 1, 0)
	tLbl.BackgroundTransparency = 1
	tLbl.Text = tostring(cfg.Title or "Confirm Action")
	tLbl.TextColor3 = Theme.ConfirmText
	tLbl.TextSize = 17
	tLbl.Font = Enum.Font.GothamBlack
	tLbl.TextXAlignment = Enum.TextXAlignment.Left
	tLbl.TextTruncate = Enum.TextTruncate.AtEnd
	tLbl.LayoutOrder = 2
	tLbl.ZIndex = 9007
	tLbl.Parent = header

	local div = Instance.new("Frame")
	div.Size = UDim2.new(1, -28, 0, 2)
	div.Position = UDim2.new(0, 14, 0, 54)
	div.BackgroundColor3 = accent
	div.BackgroundTransparency = 0.4
	div.BorderSizePixel = 0
	div.ZIndex = 9006
	div.Parent = content
	Corner(div, 99)
	local dg = Instance.new("UIGradient")
	dg.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.12, 0),
		NumberSequenceKeypoint.new(0.88, 0), NumberSequenceKeypoint.new(1, 1),
	}
	dg.Parent = div

	local cLbl = Instance.new("TextLabel")
	cLbl.Size = UDim2.new(1, -28, 0, 62)
	cLbl.Position = UDim2.new(0, 14, 0, 66)
	cLbl.BackgroundTransparency = 1
	cLbl.Text = tostring(cfg.Content or "Are you sure you want to continue?")
	cLbl.TextColor3 = Theme.ConfirmSubText
	cLbl.TextSize = 12
	cLbl.Font = Enum.Font.Gotham
	cLbl.TextXAlignment = Enum.TextXAlignment.Left
	cLbl.TextYAlignment = Enum.TextYAlignment.Top
	cLbl.TextWrapped = true
	cLbl.ZIndex = 9006
	cLbl.Parent = content

	local btnRow = Instance.new("Frame")
	btnRow.Size = UDim2.new(1, -28, 0, 40)
	btnRow.Position = UDim2.new(0, 14, 1, -54)
	btnRow.BackgroundTransparency = 1
	btnRow.ZIndex = 9006
	btnRow.Parent = content
	local bl = Instance.new("UIListLayout")
	bl.FillDirection = Enum.FillDirection.Horizontal
	bl.HorizontalAlignment = Enum.HorizontalAlignment.Right
	bl.VerticalAlignment = Enum.VerticalAlignment.Center
	bl.Padding = UDim.new(0, 12)
	bl.Parent = btnRow

	local function mkBtn(text, bg, tc, order)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0, 104, 0, 36)
		b.BackgroundColor3 = bg
		b.Text = text
		b.TextColor3 = tc
		b.TextSize = 14
		b.Font = Enum.Font.GothamBold
		b.AutoButtonColor = false
		b.LayoutOrder = order
		b.ZIndex = 9007
		b.Parent = btnRow
		Corner(b, 7)
		local bs = Instance.new("UIScale")
		bs.Parent = b
		b.MouseEnter:Connect(function() Tween(b, .15, { BackgroundColor3 = bg:Lerp(Color3.new(1,1,1), 0.14) }) end)
		b.MouseLeave:Connect(function() Tween(b, .15, { BackgroundColor3 = bg }) end)
		b.InputBegan:Connect(function(i) if isPressInput(i) then Tween(bs, .07, { Scale = .9 }) end end)
		b.InputEnded:Connect(function(i) if isPressInput(i) then Tween(bs, .12, { Scale = 1 }) end end)
		return b
	end

	local noBtn = mkBtn(tostring(cfg.CancelText or "No"), Theme.Neutral, Theme.ConfirmText, 1)
	local yesBtn = mkBtn(tostring(cfg.ConfirmText or "Yes"), accent, contrastOn(accent), 2)

	activeAction = { root = root, modal = modal, blocker = blocker, scale = scale }

	Tween(scale, 0.24, { Scale = 1 }, Enum.EasingStyle.Back)
	Tween(modal, 0.2, { BackgroundTransparency = 0.04 })
	Tween(mStroke, 0.24, { Transparency = 0.15 })

	local cd = tonumber(cfg.Cooldown) or 0
	local canYes = cd <= 0
	if cd > 0 then
		yesBtn.BackgroundColor3 = Theme.Disabled
		yesBtn.TextColor3 = Theme.DisabledText
		task.spawn(function()
			for i = math.ceil(cd), 1, -1 do
				if not yesBtn.Parent then return end
				yesBtn.Text = "WAIT (" .. i .. ")"
				task.wait(1)
			end
			if yesBtn.Parent then
				yesBtn.Text = tostring(cfg.ConfirmText or "Yes")
				yesBtn.BackgroundColor3 = accent
				yesBtn.TextColor3 = contrastOn(accent)
				canYes = true
			end
		end)
	end

	noBtn.MouseButton1Click:Connect(function()
		closeAction()
		if cfg.OnCancel then task.spawn(cfg.OnCancel) end
	end)
	yesBtn.MouseButton1Click:Connect(function()
		if not canYes then
			Tween(yesBtn, .06, { Rotation = -4 })
			task.delay(.06, function() if yesBtn.Parent then Tween(yesBtn, .06, { Rotation = 4 }) end end)
			task.delay(.12, function() if yesBtn.Parent then Tween(yesBtn, .06, { Rotation = 0 }) end end)
			return
		end
		closeAction()
		if cfg.OnConfirm then task.spawn(cfg.OnConfirm) end
	end)
	if cfg.CloseOnBlocker then
		blocker.MouseButton1Click:Connect(function()
			closeAction()
			if cfg.OnCancel then task.spawn(cfg.OnCancel) end
		end)
	end

	return { Close = closeAction }
end

--// ==========================================================
--// GLOBAL HELPERS
--// ==========================================================
local function formatDuration(sec)
	sec = math.max(0, math.floor(tonumber(sec) or 0))
	return string.format("%dh %02dm %02ds", math.floor(sec / 3600), math.floor((sec % 3600) / 60), sec % 60)
end

local function copyToClipboard(text)
	text = tostring(text or "")
	local fn = (typeof(setclipboard) == "function" and setclipboard)
		or (typeof(toclipboard) == "function" and toclipboard)
		or (typeof(setrbxclipboard) == "function" and setrbxclipboard)
		or (typeof(writeclipboard) == "function" and writeclipboard)
		or (syn and typeof(syn.write_clipboard) == "function" and syn.write_clipboard)
		or (typeof(Clipboard) == "table" and typeof(Clipboard.set) == "function" and Clipboard.set)
		or nil
	if not fn then return false end
	return (pcall(fn, text))
end

local function rejoinServer()
	local ok, err = pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end)
	if ok then return true end
	local ok2, err2 = pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
	if ok2 then return true end
	return false, err2 or err
end

local function joinScriptText()
	return string.format(
		'game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)',
		game.PlaceId, tostring(game.JobId))
end

local function executeRemoteScript(url, name)
	name = tostring(name or url)
	task.spawn(function()
		local ok, source = pcall(function() return game:HttpGet(url) end)
		if not ok or type(source) ~= "string" or source == "" then
			Library:Notify("Failed to fetch: " .. name, 5, "Error", "x-circle")
			return
		end
		local chunk, loadErr = loadstring(source)
		if not chunk then
			Library:Notify("Load error: " .. name .. "\n" .. tostring(loadErr), 5, "Error", "x-circle")
			return
		end
		local ran, runErr = pcall(chunk)
		if not ran then
			Library:Notify("Runtime error: " .. name .. "\n" .. tostring(runErr), 5, "Error", "x-circle")
		else
			Library:Notify("Executed: " .. name, 4, "Success", "check-circle")
		end
	end)
end

--// MOVEMENT MODULE
Library.Movement = {
	InfJump = false,
	WalkSpeedActive = false, WalkSpeedValue = 16,
	JumpPowerActive = false, JumpPowerValue = 50,
}
local Movement = Library.Movement

local function getHumanoid()
	local char = LocalPlayer.Character
	if not char then return nil end
	return char:FindFirstChildOfClass("Humanoid")
end

local function applyMovement()
	local hum = getHumanoid()
	if not hum then return end
	pcall(function()
		if Movement.WalkSpeedActive then hum.WalkSpeed = Movement.WalkSpeedValue end
		if Movement.JumpPowerActive then
			hum.UseJumpPower = true
			hum.JumpPower = Movement.JumpPowerValue
		end
	end)
end

function Movement:SetInfJump(on) self.InfJump = on and true or false end
function Movement:SetWalkSpeedActive(on)
	self.WalkSpeedActive = on and true or false
	if on then applyMovement() else
		local hum = getHumanoid()
		if hum then pcall(function() hum.WalkSpeed = 16 end) end
	end
end
function Movement:SetWalkSpeed(v)
	self.WalkSpeedValue = tonumber(v) or 16
	if self.WalkSpeedActive then applyMovement() end
end
function Movement:SetJumpPowerActive(on)
	self.JumpPowerActive = on and true or false
	if on then applyMovement() else
		local hum = getHumanoid()
		if hum then pcall(function() hum.JumpPower = 50 end) end
	end
end
function Movement:SetJumpPower(v)
	self.JumpPowerValue = tonumber(v) or 50
	if self.JumpPowerActive then applyMovement() end
end

Connect(UserInputService.JumpRequest, function()
	if Movement.InfJump then
		local hum = getHumanoid()
		if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
	end
end)
Connect(LocalPlayer.CharacterAdded, function()
	task.wait(0.5)
	applyMovement()
end)
task.spawn(function()
	while true do
		task.wait(0.5)
		if Library._destroyed or (type(Env) == "table" and Env.RoNetGeneration ~= Library.Generation) then return end
		if Movement.WalkSpeedActive or Movement.JumpPowerActive then applyMovement() end
	end
end)

--// ==========================================================
--// PART 1/4 SELESAI
--// JANGAN EXECUTE SENDIRI. LANJUTKAN DENGAN PART 2/4
--// (CreateWindow, Topbar, Tags, Keybind List FIX, Sidebar,
--//  Tabs + Stagger, Section, Label, Paragraph, Toggle, Slider)
--// ==========================================================

--// ==========================================================
--// PART 2/4 : CreateWindow s/d CreateSlider
--// SAMBUNGKAN SETELAH PART 1/4
--// ==========================================================

function Library:CreateWindow(config)
if Library._destroyed or (type(Env) == "table" and Env.RoNetGeneration ~= Library.Generation) then return nil end
config = config or {}
local title = config.Title or "Ro-Netrium"
local subtitle = config.Subtitle or "UI Library"
local OPEN_SIZE = config.Size or UDim2.new(0, 620, 0, 430)

local gui = Instance.new("ScreenGui")
gui.Name = "Ro-NetriumV5"
gui.ResetOnSpawn = false
gui.DisplayOrder = 998
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local themeRefs = {}
local function registerThemeRef(obj, prop, key)
	if not obj then return end
	table.insert(themeRefs, { obj = obj, prop = prop, key = key })
end

local main = Instance.new("Frame")
main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.Size = OPEN_SIZE
main.BackgroundColor3 = Theme.Background
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Active = true
main.ZIndex = 40
main.Parent = gui
Corner(main, 12)
registerThemeRef(main, "BackgroundColor3", "Background")

local mainStroke = Stroke(main, Color3.new(1, 1, 1), Theme.MainBorderThickness)
registerRGB(mainStroke)

local mainGlow
if Theme.BorderGlow and Library.Effects.Glow then
	mainGlow = Instance.new("UIStroke")
	mainGlow.Name = "MainBorderGlow"
	mainGlow.Thickness = Theme.MainBorderThickness + 2.4
	mainGlow.Transparency = Theme.GlowTransparency or 0.62
	mainGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	mainGlow.Parent = main
	registerRGB(mainGlow)
end

if Library.Effects.Shadow then
	pcall(function()
		local sh = Instance.new("UIDropShadow")
		sh.Color = Color3.new(0, 0, 0)
		sh.Transparency = 0.45
		sh.Size = UDim2.new(0, 26, 0, 26)
		sh.Offset = Vector2.new(0, 10)
		sh.Parent = main
	end)
end

--// [FIX 5/6] efek visual di dalam window
local gridLayer, gridRelayout = createGridOverlay(main, nil)
local particleLayer, dotLayer, crystalLayer = createParticleBackground(main, Theme.ParticleCount, nil)

--// Tooltip
local Tooltip = Instance.new("Frame")
Tooltip.Size = UDim2.new(0, 10, 0, 22)
Tooltip.BackgroundColor3 = Color3.fromRGB(5, 5, 7)
Tooltip.BorderSizePixel = 0
Tooltip.ZIndex = 300
Tooltip.Visible = false
Tooltip.Parent = gui
Corner(Tooltip, 5)
Stroke(Tooltip, Color3.new(1, 1, 1), 1).Transparency = 0.8
local ttText = Instance.new("TextLabel")
ttText.Size = UDim2.new(1, -12, 1, 0)
ttText.Position = UDim2.new(0, 6, 0, 0)
ttText.BackgroundTransparency = 1
ttText.TextColor3 = Color3.fromRGB(255, 255, 255)
ttText.TextSize = 11
ttText.Font = Enum.Font.Gotham
ttText.TextXAlignment = Enum.TextXAlignment.Left
ttText.ZIndex = 301
ttText.Parent = Tooltip

local function ShowTooltip(text)
	ttText.Text = tostring(text or "")
	local b = TextService:GetTextSize(ttText.Text, 11, Enum.Font.Gotham, Vector2.new(400, 22))
	Tooltip.Size = UDim2.new(0, math.min(b.X + 14, 320), 0, 22)
	Tooltip.Visible = true
end
local function HideTooltip() Tooltip.Visible = false end
local function addTooltip(obj, text)
	if not text or text == "" then return end
	obj.MouseEnter:Connect(function() ShowTooltip(text) end)
	obj.MouseLeave:Connect(HideTooltip)
end

local ttAcc = 0
Connect(RunService.RenderStepped, function(dt)
	if not Tooltip.Visible then return end
	ttAcc += (tonumber(dt) or 0.016)
	if ttAcc < 0.03 then return end
	ttAcc = 0
	local m = UserInputService:GetMouseLocation()
	Tooltip.Position = UDim2.new(0, m.X + 16, 0, m.Y + 16)
end, nil)

--// ==========================================================
--// TOPBAR
--// ==========================================================
local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, 0, 0, TOPBAR_H)
topbar.BackgroundTransparency = 1
topbar.ZIndex = 45
topbar.Parent = main

local titleRow = Instance.new("Frame")
titleRow.Size = UDim2.new(1, -112, 0, 24)
titleRow.Position = UDim2.new(0, 16, 0, 7)
titleRow.BackgroundTransparency = 1
titleRow.ZIndex = 46
titleRow.Active = false
titleRow.Parent = topbar
local titleLayout = Instance.new("UIListLayout")
titleLayout.FillDirection = Enum.FillDirection.Horizontal
titleLayout.SortOrder = Enum.SortOrder.LayoutOrder
titleLayout.Padding = UDim.new(0, 8)
titleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
titleLayout.Parent = titleRow

--// Dot hijau di holder terpisah (title tidak bergeser saat pulse)
local dotHolder = Instance.new("Frame")
dotHolder.Name = "StatusDotHolder"
dotHolder.Size = UDim2.new(0, 14, 0, 14)
dotHolder.BackgroundTransparency = 1
dotHolder.BorderSizePixel = 0
dotHolder.LayoutOrder = 1
dotHolder.ZIndex = 47
dotHolder.Parent = titleRow
local statusDot = Instance.new("Frame")
statusDot.AnchorPoint = Vector2.new(0.5, 0.5)
statusDot.Position = UDim2.new(0.5, 0, 0.5, 0)
statusDot.Size = UDim2.new(0, 8, 0, 8)
statusDot.BackgroundColor3 = Color3.fromRGB(46, 230, 110)
statusDot.BorderSizePixel = 0
statusDot.ZIndex = 47
statusDot.Parent = dotHolder
Corner(statusDot, 99)
local dotScale = Instance.new("UIScale")
dotScale.Parent = statusDot
task.spawn(function()
	while dotHolder.Parent and statusDot.Parent do
		if Library._destroyed then return end
		Tween(statusDot, 0.6, { BackgroundTransparency = 0.45 })
		Tween(dotScale, 0.6, { Scale = 1.3 })
		task.wait(0.62)
		if not statusDot.Parent then return end
		Tween(statusDot, 0.6, { BackgroundTransparency = 0 })
		Tween(dotScale, 0.6, { Scale = 1 })
		task.wait(0.62)
	end
end)

local titleSeparator = Instance.new("Frame")
titleSeparator.Size = UDim2.new(0, 2, 0, 15)
titleSeparator.BackgroundColor3 = Theme.Border
titleSeparator.BorderSizePixel = 0
titleSeparator.LayoutOrder = 2
titleSeparator.ZIndex = 47
titleSeparator.Parent = titleRow
registerThemeRef(titleSeparator, "BackgroundColor3", "Border")

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(0, 0, 0, 18)
titleLbl.AutomaticSize = Enum.AutomaticSize.X
titleLbl.BackgroundTransparency = 1
titleLbl.Text = title
titleLbl.TextColor3 = Theme.Text
titleLbl.TextSize = 15
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.LayoutOrder = 3
titleLbl.ZIndex = 47
titleLbl.Parent = titleRow
registerThemeRef(titleLbl, "TextColor3", "Text")

local tagRow = Instance.new("Frame")
tagRow.Size = UDim2.new(0, 0, 0, 22)
tagRow.AutomaticSize = Enum.AutomaticSize.X
tagRow.BackgroundTransparency = 1
tagRow.ZIndex = 47
tagRow.Active = false
tagRow.LayoutOrder = 4
tagRow.Parent = titleRow
local tagLayout = Instance.new("UIListLayout")
tagLayout.FillDirection = Enum.FillDirection.Horizontal
tagLayout.SortOrder = Enum.SortOrder.LayoutOrder
tagLayout.Padding = UDim.new(0, 6)
tagLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tagLayout.Parent = tagRow

local subLbl = Instance.new("TextLabel")
subLbl.Size = UDim2.new(0.65, 0, 0, 14)
subLbl.Position = UDim2.new(0, 16, 0, 32)
subLbl.BackgroundTransparency = 1
subLbl.Text = subtitle
subLbl.TextColor3 = Theme.SubText
subLbl.TextSize = 11
subLbl.Font = Enum.Font.Gotham
subLbl.TextXAlignment = Enum.TextXAlignment.Left
subLbl.TextTruncate = Enum.TextTruncate.AtEnd
subLbl.ZIndex = 46
subLbl.Parent = topbar
registerThemeRef(subLbl, "TextColor3", "SubText")

local window
local function getCloseColor() return (window and window.closeColor) or Theme.Close end
local function getCloseHover() return (window and window.closeHoverColor) or Theme.CloseHover end
local function getClosePressed() return (window and window.closePressedColor) or Theme.ClosePressed end
local function getCloseText() return (window and window.closeTextColor) or Theme.CloseText end

local function iconButton(xoff, kind)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 26, 0, 26)
	b.Position = UDim2.new(1, xoff, 0.5, -13)
	b.BackgroundColor3 = Theme.Element
	b.BorderSizePixel = 0
	b.Text = ""
	b.AutoButtonColor = false
	b.ZIndex = 48
	b.Parent = topbar
	Corner(b, 6)
	registerThemeRef(b, "BackgroundColor3", "Element")
	local scale = Instance.new("UIScale")
	scale.Parent = b
	local lines, overlay = {}, nil

	if kind == "close" then
		overlay = Instance.new("Frame")
		overlay.AnchorPoint = Vector2.new(0.5, 0.5)
		overlay.Position = UDim2.new(0.5, 0, 0.5, 0)
		overlay.Size = UDim2.new(0, 0, 0, 0)
		overlay.BackgroundColor3 = getCloseColor()
		overlay.BackgroundTransparency = 1
		overlay.BorderSizePixel = 0
		overlay.ZIndex = 48
		overlay.Visible = false
		overlay.Parent = b
		Corner(overlay, 99)
		for _, rot in ipairs({ 45, -45 }) do
			local l = Instance.new("Frame")
			l.Size = UDim2.new(0, 12, 0, 2)
			l.Position = UDim2.new(0.5, -6, 0.5, -1)
			l.Rotation = rot
			l.BackgroundColor3 = Theme.SubText
			l.BorderSizePixel = 0
			l.ZIndex = 49
			l.Parent = b
			table.insert(lines, l)
			registerThemeRef(l, "BackgroundColor3", "SubText")
		end
		b.MouseEnter:Connect(function()
			if Library._confirmOpen or Library._actionOpen then return end
			Tween(b, .2, { BackgroundColor3 = getCloseHover() })
			for _, l in ipairs(lines) do Tween(l, .2, { BackgroundColor3 = getCloseText() }) end
		end)
		b.MouseLeave:Connect(function()
			Tween(b, .2, { BackgroundColor3 = Theme.Element })
			for _, l in ipairs(lines) do Tween(l, .2, { BackgroundColor3 = Theme.SubText }) end
		end)
	else
		local l = Instance.new("Frame")
		l.Size = UDim2.new(0, 12, 0, 2)
		l.Position = UDim2.new(0.5, -6, 0.5, -1)
		l.BackgroundColor3 = Theme.SubText
		l.BorderSizePixel = 0
		l.ZIndex = 49
		l.Parent = b
		table.insert(lines, l)
		registerThemeRef(l, "BackgroundColor3", "SubText")
		b.MouseEnter:Connect(function()
			if Library._confirmOpen or Library._actionOpen then return end
			Tween(b, .2, { BackgroundColor3 = Theme.ElementHover })
			for _, x in ipairs(lines) do Tween(x, .2, { BackgroundColor3 = Theme.Text }) end
		end)
		b.MouseLeave:Connect(function()
			Tween(b, .2, { BackgroundColor3 = Theme.Element })
			for _, x in ipairs(lines) do Tween(x, .2, { BackgroundColor3 = Theme.SubText }) end
		end)
	end

	b.InputBegan:Connect(function(inp)
		if not isPressInput(inp) then return end
		Library._buttonPressLock = true
		if kind == "close" and overlay then
			overlay.Visible = true
			overlay.Size = UDim2.new(0, 0, 0, 0)
			overlay.BackgroundColor3 = getClosePressed()
			overlay.BackgroundTransparency = 0.12
			Tween(overlay, 0.34, { Size = UDim2.new(0, 76, 0, 76), BackgroundTransparency = 1 }, Enum.EasingStyle.Quart)
			task.delay(0.35, function() if overlay.Parent then overlay.Visible = false end end)
			Tween(scale, .08, { Scale = .82 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
			Tween(b, .08, { BackgroundColor3 = getClosePressed() })
			for _, l in ipairs(lines) do Tween(l, .08, { BackgroundColor3 = getCloseText() }) end
		else
			Tween(scale, .08, { Scale = .86 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
			Tween(b, .08, { BackgroundColor3 = Theme.ElementHover })
			for _, l in ipairs(lines) do Tween(l, .08, { BackgroundColor3 = Theme.Text }) end
		end
	end)
	b.InputEnded:Connect(function(inp)
		if not isPressInput(inp) then return end
		if not Library._confirmOpen and not Library._actionOpen then Library._buttonPressLock = false end
		local hovered = false
		pcall(function() hovered = b:IsHovered() end)
		if kind == "close" then
			Tween(b, .16, { BackgroundColor3 = hovered and getCloseHover() or Theme.Element })
			for _, l in ipairs(lines) do Tween(l, .16, { BackgroundColor3 = hovered and getCloseText() or Theme.SubText }) end
		else
			Tween(b, .16, { BackgroundColor3 = hovered and Theme.ElementHover or Theme.Element })
			for _, l in ipairs(lines) do Tween(l, .16, { BackgroundColor3 = hovered and Theme.Text or Theme.SubText }) end
		end
		Tween(scale, .14, { Scale = 1 }, Enum.EasingStyle.Back)
	end)

	return b, { btn = b, lines = lines, overlay = overlay, scale = scale }
end

local minimizeBtn, minimizeBtnData = iconButton(-62, "min")
local closeBtn, closeBtnData = iconButton(-32, "close")

window = {
	accent = config.Accent or Library.Accent,
	closeColor = config.CloseColor or Theme.Close,
	closeHoverColor = config.CloseHoverColor or Theme.CloseHover,
	closePressedColor = config.ClosePressedColor or Theme.ClosePressed,
	closeTextColor = config.CloseTextColor or Theme.CloseText,
	listeners = {},
	offset = Vector2.new(0, 0),
	_connections = {},
	_destroyed = false,
	_gui = gui,
	_main = main,
	_closeConfirmCleanup = nil,
	_closeButtonData = closeBtnData,
	_minimizeButtonData = minimizeBtnData,
	_themeRefs = themeRefs,
	_floatingFrames = {},
	confirmTitle = config.ConfirmTitle or "Close Window",
	confirmSubtitle = config.ConfirmSubtitle or "Are you sure you want to close this window? Unsaved changes will be lost.",
}

if config.Accent and typeof(config.Accent) == "Color3" then
	Library.Accent = config.Accent
	ThemeManager.Dirty = true
end

function window:ApplyTheme()
	if self._destroyed then return end
	for _, ref in ipairs(themeRefs) do
		if ref.obj and ref.obj.Parent then
			local c = Theme[ref.key]
			if c then pcall(function() ref.obj[ref.prop] = c end) end
		end
	end
	if mainStroke then mainStroke.Thickness = Theme.MainBorderThickness end
	if mainGlow then
		mainGlow.Thickness = Theme.MainBorderThickness + 2.4
		mainGlow.Visible = Theme.BorderGlow and Library.Effects.Glow
	end
	if gridLayer then gridLayer.Visible = Library.Effects.GridOverlay end
	if particleLayer then particleLayer.Visible = Library.Effects.Particles end
	if dotLayer then dotLayer.Visible = Library.Effects.Particles end
	if crystalLayer then crystalLayer.Visible = Library.Effects.Crystals end
	if gridRelayout then pcall(gridRelayout) end
end

function window:Destroy()
	if self._destroyed then return end
	self._destroyed = true
	if self._closeConfirmCleanup then pcall(self._closeConfirmCleanup) end
	for _, c in ipairs(self._connections) do pcall(function() c:Disconnect() end) end
	self._connections = {}
	self.listeners = {}
	self._themeRefs = {}
	local rm = {}
	for flag, el in pairs(Library._elements) do
		if el.Window == self then rm[#rm + 1] = flag end
	end
	for _, flag in ipairs(rm) do Library._elements[flag] = nil end
	for _, item in ipairs(Library._searchIndex) do
		if item.Window == self then item._removed = true end
	end
	pcall(function() gui:Destroy() end)
	for i, w in ipairs(Library._windows) do
		if w == self then table.remove(Library._windows, i) break end
	end
	if #Library._windows == 0 then Library.Open = false end
end

table.insert(Library._windows, window)

function window:onAccent(fn)
	table.insert(self.listeners, fn)
	fn(self.accent)
end

function window:SetCloseColor(color, hover, pressed, text)
	if typeof(color) == "Color3" then self.closeColor = color end
	if typeof(hover) == "Color3" then self.closeHoverColor = hover end
	if typeof(pressed) == "Color3" then self.closePressedColor = pressed end
	if typeof(text) == "Color3" then self.closeTextColor = text end
end

function window:SetConfirmText(t, s)
	if t ~= nil then self.confirmTitle = tostring(t) end
	if s ~= nil then self.confirmSubtitle = tostring(s) end
end

--// [TAG + ICON] holder Frame + UIListLayout supaya icon & teks tidak tumpang tindih
function window:AddTag(cfg)
	cfg = cfg or {}
	if type(cfg) == "string" then cfg = { Text = cfg } end
	local bg = cfg.Color or cfg.BackgroundColor3 or window.accent
	local tc = cfg.TextColor or cfg.TextColor3 or contrastOn(bg)

	local tag = Instance.new("Frame")
	tag.Name = "Tag"
	tag.Size = UDim2.new(0, 0, 0, 22)
	tag.AutomaticSize = Enum.AutomaticSize.X
	tag.BackgroundColor3 = bg
	tag.BorderSizePixel = 0
	tag.ZIndex = 47
	tag.Active = false
	tag.Parent = tagRow
	Corner(tag, 99)
	Pad(tag, 0, 9, 0, 9)
	local lay = Instance.new("UIListLayout")
	lay.FillDirection = Enum.FillDirection.Horizontal
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	lay.Padding = UDim.new(0, 5)
	lay.VerticalAlignment = Enum.VerticalAlignment.Center
	lay.Parent = tag

	if cfg.Icon then
		local ic = makeIcon(tag, cfg.Icon, UDim2.new(0, 12, 0, 12), UDim2.new(0, 0, 0, 0), tc)
		if ic then ic.LayoutOrder = 1 ic.ZIndex = 48 end
	end
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0, 0, 0, 22)
	lbl.AutomaticSize = Enum.AutomaticSize.X
	lbl.BackgroundTransparency = 1
	lbl.Text = tostring(cfg.Text or cfg.Name or cfg.Title or "Tag")
	lbl.TextColor3 = tc
	lbl.TextSize = 11
	lbl.Font = Enum.Font.GothamBold
	lbl.TextXAlignment = Enum.TextXAlignment.Center
	lbl.LayoutOrder = 2
	lbl.ZIndex = 48
	lbl.Parent = tag

	if cfg.FollowAccent then
		window:onAccent(function(c)
			tag.BackgroundColor3 = c
			lbl.TextColor3 = contrastOn(c)
		end)
	end
	return tag
end

local tagCount = 0
local function addConfigTag(v)
	tagCount += 1
	if type(v) == "string" then v = { Text = v } end
	local bg = v.Color or v.BackgroundColor3
	local follow = false
	if not bg then
		if tagCount == 1 then bg = Color3.fromRGB(255, 204, 0)
		elseif tagCount == 2 then bg = Color3.fromRGB(46, 230, 110)
		else bg = window.accent follow = true end
	end
	window:AddTag({
		Text = v.Text or v.Name or v.Title or "Tag",
		Icon = v.Icon,
		Color = bg,
		TextColor = v.TextColor or v.TextColor3,
		FollowAccent = follow,
	})
end

local tagsConfig = config.Tags
if tagsConfig == nil then
	tagsConfig = {
		{ Text = "V5.9", Icon = "sparkles", Color = Color3.fromRGB(255, 204, 0), TextColor = Color3.new(0, 0, 0) },
		{ Text = "STABLE", Icon = "shield-check", Color = Color3.fromRGB(46, 230, 110), TextColor = Color3.new(0, 0, 0) },
	}
end
if tagsConfig ~= false and type(tagsConfig) == "table" then
	if tagsConfig.Text or tagsConfig.Name or tagsConfig.Title then
		addConfigTag(tagsConfig)
	else
		for _, v in ipairs(tagsConfig) do addConfigTag(v) end
	end
end

--// ==========================================================
--// RESIZE + DRAG (+ simpan posisi window)
--// ==========================================================
local resizeHandle = Instance.new("TextButton")
resizeHandle.Size = UDim2.new(0, 16, 0, 16)
resizeHandle.Position = UDim2.new(1, -17, 1, -17)
resizeHandle.BackgroundTransparency = 1
resizeHandle.Text = ""
resizeHandle.AutoButtonColor = false
resizeHandle.ZIndex = 55
resizeHandle.Parent = main
for i = 0, 2 do
	local d = Instance.new("Frame")
	d.Size = UDim2.new(0, 3 + i * 4, 0, 2)
	d.AnchorPoint = Vector2.new(1, 1)
	d.Position = UDim2.new(1, -2, 1, -2 - i * 4)
	d.BackgroundColor3 = Theme.SubText
	d.BorderSizePixel = 0
	d.ZIndex = 56
	d.Parent = resizeHandle
	registerThemeRef(d, "BackgroundColor3", "SubText")
end

local function inputPos(inp)
	if inp.UserInputType == Enum.UserInputType.Touch
		or inp.UserInputType == Enum.UserInputType.MouseMovement
		or inp.UserInputType == Enum.UserInputType.MouseButton1 then
		return inp.Position
	end
	return nil
end

local resizing, resizeStart, resizeOrig = false, nil, nil
Connect(resizeHandle.InputBegan, function(inp)
	if Library._confirmOpen or Library._actionOpen or Library._buttonPressLock then return end
	if isPressInput(inp) then
		resizing = true
		resizeStart = inputPos(inp)
		resizeOrig = main.Size
	end
end, window)

local dragging, dragStart, dragOrig = false, nil, nil
Connect(topbar.InputBegan, function(inp)
	if Library._confirmOpen or Library._actionOpen or Library._buttonPressLock then return end
	if isPressInput(inp) then
		dragging = true
		dragStart = inp.Position
		dragOrig = window.offset
	end
end, window)

Connect(UserInputService.InputChanged, function(inp)
	if Library._confirmOpen or Library._actionOpen then dragging = false resizing = false return end
	local pos = inputPos(inp)
	if not pos then return end
	if resizing and resizeStart then
		local d = pos - resizeStart
		main.Size = UDim2.new(0, math.clamp(resizeOrig.X.Offset + d.X, 480, 1100), 0, math.clamp(resizeOrig.Y.Offset + d.Y, 340, 780))
	elseif dragging and dragStart then
		local d = pos - dragStart
		local vp = workspace.CurrentCamera.ViewportSize
		local x = math.clamp(dragOrig.X + d.X, -(vp.X / 2 - 90), vp.X / 2 - 90)
		local y = math.clamp(dragOrig.Y + d.Y, -(vp.Y / 2 - 60), vp.Y / 2 - 60)
		window.offset = Vector2.new(x, y)
		main.Position = UDim2.new(0.5, x, 0.5, y)
	end
end, window)

Connect(UserInputService.InputEnded, function(inp)
	if not isPressInput(inp) then return end
	if dragging then
		Library:SetFramePosition("MainWindow", window.offset.X, window.offset.Y)
	end
	dragging = false
	resizing = false
	if not Library._confirmOpen and not Library._actionOpen then Library._buttonPressLock = false end
end, window)

--// ==========================================================
--// SIDEBAR
--// ==========================================================
local SIDE_PAD = 8
local SEARCH_H = 34
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 156, 1, -TOPBAR_H)
sidebar.Position = UDim2.new(0, 0, 0, TOPBAR_H)
sidebar.BackgroundColor3 = Theme.Sidebar
sidebar.BorderSizePixel = 0
sidebar.ClipsDescendants = true
sidebar.ZIndex = 41
sidebar.Parent = main
Corner(sidebar, 10)
registerThemeRef(sidebar, "BackgroundColor3", "Sidebar")
local sideStroke = Stroke(sidebar, Theme.Border, 1.2)
sideStroke.Transparency = 0.35
registerThemeRef(sideStroke, "Color", "Border")

local searchBar = Instance.new("Frame")
searchBar.Size = UDim2.new(1, -(SIDE_PAD * 2), 0, SEARCH_H)
searchBar.Position = UDim2.new(0, SIDE_PAD, 0, SIDE_PAD)
searchBar.BackgroundColor3 = Theme.Element
searchBar.BackgroundTransparency = 0.08
searchBar.BorderSizePixel = 0
searchBar.ZIndex = 43
searchBar.Parent = sidebar
Corner(searchBar, 8)
registerThemeRef(searchBar, "BackgroundColor3", "Element")
local searchStroke = Stroke(searchBar, Theme.Border, 1.4)
registerThemeRef(searchStroke, "Color", "Border")
local searchIcon = makeIcon(searchBar, "search", UDim2.new(0, 14, 0, 14), UDim2.new(0, 10, 0.5, -7), Theme.SubText)
if searchIcon then registerThemeRef(searchIcon, "ImageColor3", "SubText") end
local searchInput = Instance.new("TextBox")
searchInput.Size = UDim2.new(1, -42, 0, 26)
searchInput.Position = UDim2.new(0, 32, 0.5, -13)
searchInput.BackgroundTransparency = 1
searchInput.BorderSizePixel = 0
searchInput.PlaceholderText = "Search..."
searchInput.PlaceholderColor3 = Theme.SubText
searchInput.Text = ""
searchInput.TextColor3 = Theme.Text
searchInput.TextSize = 12
searchInput.Font = Enum.Font.GothamMedium
searchInput.TextXAlignment = Enum.TextXAlignment.Left
searchInput.ClearTextOnFocus = false
searchInput.ZIndex = 44
searchInput.Parent = searchBar
registerThemeRef(searchInput, "TextColor3", "Text")
registerThemeRef(searchInput, "PlaceholderColor3", "SubText")

local tabScroll = Instance.new("ScrollingFrame")
tabScroll.Size = UDim2.new(1, -(SIDE_PAD * 2), 1, -(SEARCH_H + SIDE_PAD * 2 + 32))
tabScroll.Position = UDim2.new(0, SIDE_PAD, 0, SEARCH_H + SIDE_PAD + 6)
tabScroll.BackgroundTransparency = 1
tabScroll.BorderSizePixel = 0
tabScroll.ScrollBarThickness = 3
tabScroll.ScrollBarImageColor3 = window.accent
tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
tabScroll.ScrollingDirection = Enum.ScrollingDirection.Y
tabScroll.ZIndex = 42
tabScroll.Parent = sidebar
window:onAccent(function(c) tabScroll.ScrollBarImageColor3 = c end)
local sideList = Instance.new("UIListLayout")
sideList.SortOrder = Enum.SortOrder.LayoutOrder
sideList.Padding = UDim.new(0, 5)
sideList.Parent = tabScroll
local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop = UDim.new(0, 2)
sidePad.PaddingBottom = UDim.new(0, 12)
sidePad.PaddingRight = UDim.new(0, 4)
sidePad.Parent = tabScroll

--// CONTENT
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -156, 1, -TOPBAR_H)
content.Position = UDim2.new(0, 156, 0, TOPBAR_H)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = window.accent
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.ZIndex = 41
content.Parent = main
window:onAccent(function(c) content.ScrollBarImageColor3 = c end)

local container = Instance.new("Frame")
container.Size = UDim2.new(1, -24, 0, 0)
container.Position = UDim2.new(0, 12, 0, 10)
container.BackgroundTransparency = 1
container.AutomaticSize = Enum.AutomaticSize.Y
container.Parent = content
local containerList = Instance.new("UIListLayout")
containerList.SortOrder = Enum.SortOrder.LayoutOrder
containerList.Padding = UDim.new(0, 8)
containerList.Parent = container
local containerPad = Instance.new("UIPadding")
containerPad.PaddingBottom = UDim.new(0, 16)
containerPad.Parent = container

--// SEARCH RESULTS
local searchResults = Instance.new("ScrollingFrame")
searchResults.Size = UDim2.new(0, 0, 0, 0)
searchResults.BackgroundColor3 = Theme.Element
searchResults.BackgroundTransparency = 0.02
searchResults.BorderSizePixel = 0
searchResults.ScrollBarThickness = 2
searchResults.ScrollBarImageColor3 = Theme.Border
searchResults.AutomaticCanvasSize = Enum.AutomaticSize.Y
searchResults.CanvasSize = UDim2.new(0, 0, 0, 0)
searchResults.Visible = false
searchResults.ZIndex = 250
searchResults.Parent = gui
Corner(searchResults, 8)
registerThemeRef(searchResults, "BackgroundColor3", "Element")
local srStroke = Stroke(searchResults, Theme.Border, 1.5)
registerThemeRef(srStroke, "Color", "Border")
Pad(searchResults, 4, 4, 4, 4)
local srList = Instance.new("UIListLayout")
srList.SortOrder = Enum.SortOrder.LayoutOrder
srList.Padding = UDim.new(0, 4)
srList.Parent = searchResults

local function clearSearchResults()
	for _, c in ipairs(searchResults:GetChildren()) do
		if c:IsA("TextButton") or c.Name == "EmptyResult" then c:Destroy() end
	end
end
local function closeSearchResults()
	searchResults.Visible = false
	searchResults.Size = UDim2.new(0, 0, 0, 0)
end
local function pulseFrame(f)
	if not f or not f.Parent then return end
	local st = Instance.new("UIStroke")
	st.Color = window.accent
	st.Thickness = 2.5
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	st.Parent = f
	Tween(st, .7, { Transparency = 1 })
	task.delay(.72, function() if st.Parent then st:Destroy() end end)
end
local function scrollToFrame(f)
	if not f or not f.Parent then return end
	task.delay(0.08, function()
		if not f.Parent or not content.Parent then return end
		local y = f.AbsolutePosition.Y - content.AbsolutePosition.Y + content.CanvasPosition.Y - 70
		content.CanvasPosition = Vector2.new(0, math.max(0, y))
	end)
end
local function addSearchResult(item)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 32)
	b.BackgroundColor3 = Theme.Element
	b.BackgroundTransparency = 0.18
	b.BorderSizePixel = 0
	b.Text = ""
	b.AutoButtonColor = false
	b.ZIndex = 251
	b.Parent = searchResults
	Corner(b, 6)
	local nl = Instance.new("TextLabel")
	nl.Size = UDim2.new(1, -60, 1, 0)
	nl.Position = UDim2.new(0, 8, 0, 0)
	nl.BackgroundTransparency = 1
	nl.Text = item.Name or "Unknown"
	nl.TextColor3 = Theme.Text
	nl.TextSize = 12
	nl.Font = Enum.Font.GothamMedium
	nl.TextXAlignment = Enum.TextXAlignment.Left
	nl.TextTruncate = Enum.TextTruncate.AtEnd
	nl.ZIndex = 252
	nl.Parent = b
	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.new(0, 50, 1, 0)
	tl.Position = UDim2.new(1, -56, 0, 0)
	tl.BackgroundTransparency = 1
	tl.Text = string.upper(tostring(item.Type or "?"):sub(1, 5))
	tl.TextColor3 = window.accent
	tl.TextSize = 10
	tl.Font = Enum.Font.GothamBold
	tl.TextXAlignment = Enum.TextXAlignment.Right
	tl.ZIndex = 252
	tl.Parent = b
	b.MouseEnter:Connect(function() Tween(b, .14, { BackgroundTransparency = .06 }) end)
	b.MouseLeave:Connect(function() Tween(b, .14, { BackgroundTransparency = .18 }) end)
	b.MouseButton1Click:Connect(function()
		closeSearchResults()
		pcall(function() searchInput:ReleaseFocus() end)
		if item.Window and item.Window._destroyed then return end
		if item.Tab and item.Tab.Activate then item.Tab:Activate() end
		if item.Frame then scrollToFrame(item.Frame) pulseFrame(item.Frame) end
	end)
end
local function updateSearchResults()
	clearSearchResults()
	local q = searchInput.Text or ""
	if #q < 1 then closeSearchResults() return end
	local matches = Library:Search(q)
	local shown = 0
	for _, item in ipairs(matches) do
		if shown >= 12 then break end
		addSearchResult(item)
		shown += 1
	end
	local w = math.max(210, searchBar.AbsoluteSize.X)
	if shown == 0 then
		local e = Instance.new("TextLabel")
		e.Name = "EmptyResult"
		e.Size = UDim2.new(1, 0, 0, 28)
		e.BackgroundTransparency = 1
		e.Text = "No results"
		e.TextColor3 = Theme.SubText
		e.TextSize = 12
		e.Font = Enum.Font.Gotham
		e.ZIndex = 251
		e.Parent = searchResults
		searchResults.Size = UDim2.new(0, w, 0, 36)
	else
		searchResults.Size = UDim2.new(0, w, 0, math.min(240, shown * 36 + 8))
	end
	searchResults.Visible = true
end
Connect(searchInput:GetPropertyChangedSignal("Text"), updateSearchResults, window)
local srAcc = 0
Connect(RunService.RenderStepped, function(dt)
	if not searchResults.Visible then return end
	srAcc += (tonumber(dt) or 0.016)
	if srAcc < 0.05 then return end
	srAcc = 0
	if searchBar.Parent then
		searchResults.Position = UDim2.new(0, searchBar.AbsolutePosition.X, 0, searchBar.AbsolutePosition.Y + searchBar.AbsoluteSize.Y + 4)
	end
end, window)
Connect(UserInputService.InputBegan, function(inp, gp)
	if gp then return end
	if inp.KeyCode == Enum.KeyCode.Escape then
		closeSearchResults()
		pcall(function() searchInput:ReleaseFocus() end)
	end
end, window)

--// ==========================================================
--// [FIX 2] KEYBIND LIST — nama & key TIDAK tertimpa
--// Kolom key fixed 72px + truncate, nama sisa ruang.
--// ==========================================================
local kbEnabled = true
local kbRows = 0
local windowOpen = true
local KeybindList = Instance.new("Frame")
KeybindList.Name = "KeybindList"
KeybindList.AnchorPoint = Vector2.new(1, 1)
KeybindList.Position = UDim2.new(1, -12, 1, -12)
KeybindList.Size = UDim2.new(0, 208, 0, 30)
KeybindList.BackgroundColor3 = Theme.Background
KeybindList.BackgroundTransparency = 0.08
KeybindList.BorderSizePixel = 0
KeybindList.ZIndex = 100
KeybindList.AutomaticSize = Enum.AutomaticSize.Y
KeybindList.Visible = false
KeybindList.Parent = gui
Corner(KeybindList, 8)
registerThemeRef(KeybindList, "BackgroundColor3", "Background")
registerRGB(Stroke(KeybindList, Color3.new(1, 1, 1), 2.2))
local kbIcon = makeIcon(KeybindList, "key", UDim2.new(0, 14, 0, 14), UDim2.new(0, 9, 0, 8), Theme.Text)
if kbIcon then registerThemeRef(kbIcon, "ImageColor3", "Text") end
local kbTitle = Instance.new("TextLabel")
kbTitle.Size = UDim2.new(1, -32, 0, 30)
kbTitle.Position = UDim2.new(0, 28, 0, 0)
kbTitle.BackgroundTransparency = 1
kbTitle.Text = "KEYBINDS"
kbTitle.TextColor3 = Theme.Text
kbTitle.TextSize = 10
kbTitle.Font = Enum.Font.GothamBold
kbTitle.TextXAlignment = Enum.TextXAlignment.Left
kbTitle.Parent = KeybindList
registerThemeRef(kbTitle, "TextColor3", "Text")
local kbRowsFrame = Instance.new("Frame")
kbRowsFrame.Size = UDim2.new(1, -14, 0, 0)
kbRowsFrame.Position = UDim2.new(0, 7, 0, 30)
kbRowsFrame.BackgroundTransparency = 1
kbRowsFrame.AutomaticSize = Enum.AutomaticSize.Y
kbRowsFrame.Parent = KeybindList
local kbRowList = Instance.new("UIListLayout")
kbRowList.SortOrder = Enum.SortOrder.LayoutOrder
kbRowList.Padding = UDim.new(0, 3)
kbRowList.Parent = kbRowsFrame
local kbBottom = Instance.new("UIPadding")
kbBottom.PaddingBottom = UDim.new(0, 8)
kbBottom.Parent = KeybindList

local function refreshKbVis()
	KeybindList.Visible = windowOpen and kbEnabled and kbRows > 0
end
function window:ToggleKeybindList(state)
	kbEnabled = (state == nil) and not kbEnabled or (state and true or false)
	refreshKbVis()
end

local KB_KEY_W = 74
function window:AddKeybind(name, keyName)
	kbRows += 1
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 16)
	row.BackgroundTransparency = 1
	row.Parent = kbRowsFrame

	local nLbl = Instance.new("TextLabel")
	nLbl.Name = "BindName"
	nLbl.Size = UDim2.new(1, -(KB_KEY_W + 8), 1, 0)
	nLbl.Position = UDim2.new(0, 0, 0, 0)
	nLbl.BackgroundTransparency = 1
	nLbl.Text = tostring(name or "Bind")
	nLbl.TextColor3 = Theme.SubText
	nLbl.TextSize = 11
	nLbl.Font = Enum.Font.Gotham
	nLbl.TextXAlignment = Enum.TextXAlignment.Left
	nLbl.TextYAlignment = Enum.TextYAlignment.Center
	nLbl.TextTruncate = Enum.TextTruncate.AtEnd
	nLbl.Parent = row
	registerThemeRef(nLbl, "TextColor3", "SubText")

	local kLbl = Instance.new("TextLabel")
	kLbl.Name = "BindKey"
	kLbl.Size = UDim2.new(0, KB_KEY_W, 1, 0)
	kLbl.Position = UDim2.new(1, -KB_KEY_W, 0, 0)
	kLbl.BackgroundTransparency = 1
	kLbl.Text = shortKeyName(keyName)
	kLbl.TextColor3 = window.accent
	kLbl.TextSize = 11
	kLbl.Font = Enum.Font.GothamBold
	kLbl.TextXAlignment = Enum.TextXAlignment.Right
	kLbl.TextYAlignment = Enum.TextYAlignment.Center
	kLbl.TextTruncate = Enum.TextTruncate.AtEnd
	kLbl.Parent = row
	window:onAccent(function(c) kLbl.TextColor3 = c end)

	refreshKbVis()
	return {
		Set = function(_, k) kLbl.Text = shortKeyName(k) end,
		SetName = function(_, n) nLbl.Text = tostring(n or "") end,
		Remove = function()
			if row.Parent then row:Destroy() kbRows = math.max(0, kbRows - 1) refreshKbVis() end
		end,
	}
end

--// ==========================================================
--// TABS (+ [FIX 8] stagger saat pindah tab)
--// ==========================================================
function window:CreateTab(name, icon)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, H_TAB)
	btn.BackgroundColor3 = window.accent
	btn.BackgroundTransparency = 1
	btn.BorderSizePixel = 0
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.ZIndex = 42
	btn.Parent = tabScroll
	Corner(btn, 7)

	local ind = Instance.new("Frame")
	ind.Size = UDim2.new(0, 3, 0, 16)
	ind.Position = UDim2.new(0, 6, 0.5, -8)
	ind.BackgroundColor3 = window.accent
	ind.BackgroundTransparency = 1
	ind.BorderSizePixel = 0
	ind.ZIndex = 43
	ind.Parent = btn
	Corner(ind, 2)

	local tabIcon = makeIcon(btn, icon, UDim2.new(0, 16, 0, 16), UDim2.new(0, 14, 0.5, -8), Theme.SubText)
	if tabIcon then tabIcon.ZIndex = 43 registerThemeRef(tabIcon, "ImageColor3", "SubText") end
	local labelX = tabIcon and 36 or 14
	local tabLbl = Instance.new("TextLabel")
	tabLbl.Size = UDim2.new(1, -(labelX + 8), 1, 0)
	tabLbl.Position = UDim2.new(0, labelX, 0, 0)
	tabLbl.BackgroundTransparency = 1
	tabLbl.Text = name
	tabLbl.Font = Enum.Font.GothamMedium
	tabLbl.TextSize = 13
	tabLbl.TextColor3 = Theme.SubText
	tabLbl.TextXAlignment = Enum.TextXAlignment.Left
	tabLbl.TextTruncate = Enum.TextTruncate.AtEnd
	tabLbl.ZIndex = 43
	tabLbl.Parent = btn
	registerThemeRef(tabLbl, "TextColor3", "SubText")

	local tabContent = Instance.new("Frame")
	tabContent.Size = UDim2.new(1, 0, 0, 0)
	tabContent.BackgroundTransparency = 1
	tabContent.AutomaticSize = Enum.AutomaticSize.Y
	tabContent.Visible = false
	tabContent.LayoutOrder = btn.LayoutOrder
	tabContent.Parent = container
	local tabList = Instance.new("UIListLayout")
	tabList.SortOrder = Enum.SortOrder.LayoutOrder
	tabList.Padding = UDim.new(0, 8)
	tabList.Parent = tabContent

	local tab = { content = tabContent, btn = btn, ind = ind, window = window, name = name, _order = 0 }
	local function curAccent() return window.accent end
	local function setActive(on)
		if on then
			Tween(btn, .2, { BackgroundColor3 = curAccent(), BackgroundTransparency = .84 })
			Tween(tabLbl, .2, { TextColor3 = Theme.Text })
			Tween(ind, .2, { BackgroundTransparency = 0 })
			if tabIcon then Tween(tabIcon, .2, { ImageColor3 = curAccent() }) end
		else
			Tween(btn, .2, { BackgroundTransparency = 1 })
			Tween(tabLbl, .2, { TextColor3 = Theme.SubText })
			Tween(ind, .2, { BackgroundTransparency = 1 })
			if tabIcon then Tween(tabIcon, .2, { ImageColor3 = Theme.SubText }) end
		end
	end

	function tab:Activate()
		if window.currentTab == tabContent then return end
		if window.currentTab then
			window.currentTab.Visible = false
			if window.currentTabData then window.currentTabData.setActive(false) end
		end
		tabContent.Visible = true
		setActive(true)
		window.currentTab = tabContent
		window.currentTabData = { setActive = setActive }
		content.CanvasPosition = Vector2.new(0, 0)
		-- [FIX 8] muncul bertahap, tidak sekaligus
		staggerChildren(tabContent)
	end
	function tab:NextOrder()
		self._order += 1
		return self._order
	end

	btn.MouseEnter:Connect(function()
		if window.currentTab ~= tabContent then
			Tween(tabLbl, .2, { TextColor3 = Theme.Text })
			Tween(btn, .2, { BackgroundTransparency = .93 })
		end
	end)
	btn.MouseLeave:Connect(function()
		if window.currentTab ~= tabContent then
			Tween(tabLbl, .2, { TextColor3 = Theme.SubText })
			Tween(btn, .2, { BackgroundColor3 = curAccent(), BackgroundTransparency = 1 })
		end
	end)
	Connect(btn.MouseButton1Click, function() tab:Activate() end, window)
	window:onAccent(function(c)
		ind.BackgroundColor3 = c
		if window.currentTab == tabContent then btn.BackgroundColor3 = c end
	end)
	if not window.currentTab then tab:Activate() end

	--// ELEMENT BASE
	local function elementFrame(h)
		local f = Instance.new("Frame")
		f.Size = UDim2.new(1, 0, 0, h)
		f.BackgroundColor3 = Theme.Element
		f.BorderSizePixel = 0
		f.Parent = tabContent
		Corner(f, 8)
		registerThemeRef(f, "BackgroundColor3", "Element")
		local s = Stroke(f, Theme.Border, Theme.ElementBorderThickness)
		registerThemeRef(s, "Color", "Border")
		playEnter(f, tab:NextOrder())
		return f, s
	end

	local function hoverBorder(f, s, colFn, lockState)
		f.MouseEnter:Connect(function()
			if lockState and lockState.locked then return end
			Tween(f, .18, { BackgroundColor3 = Theme.ElementHover })
			Tween(s, .18, { Color = (colFn and colFn()) or window.accent, Thickness = Theme.ElementBorderThickness + 0.4 })
		end)
		f.MouseLeave:Connect(function()
			Tween(f, .18, { BackgroundColor3 = Theme.Element })
			Tween(s, .18, { Color = Theme.Border, Thickness = Theme.ElementBorderThickness })
		end)
	end

	--// SECTION
	function tab:CreateSection(text)
		local holder = Instance.new("Frame")
		holder.Size = UDim2.new(1, 0, 0, H_SECTION)
		holder.BackgroundTransparency = 1
		holder.Parent = tabContent
		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(0, 3, 0, 12)
		bar.Position = UDim2.new(0, 2, 0.5, -6)
		bar.BackgroundColor3 = window.accent
		bar.BorderSizePixel = 0
		bar.Parent = holder
		Corner(bar, 2)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -14, 1, 0)
		lbl.Position = UDim2.new(0, 12, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = tostring(text or ""):upper()
		lbl.TextColor3 = Theme.SubText
		lbl.TextSize = 11
		lbl.Font = Enum.Font.GothamBold
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = holder
		registerThemeRef(lbl, "TextColor3", "SubText")
		window:onAccent(function(c) bar.BackgroundColor3 = c end)
		playEnter(holder, tab:NextOrder())
		return holder
	end

	--// LABEL
	function tab:CreateLabel(text)
		text = tostring(text or "")
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, 0, 0, 18)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = Theme.Text
		lbl.TextSize = 12
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextWrapped = true
		lbl.Parent = tabContent
		registerThemeRef(lbl, "TextColor3", "Text")
		playEnter(lbl, tab:NextOrder())
		local obj = { Set = function(_, t) lbl.Text = tostring(t or "") end }
		registerElement(window, tab, name, lbl, { Name = text, Keywords = { "label", "text" } }, "label", obj)
		return obj
	end

	--// PARAGRAPH
	function tab:CreateParagraph(cfg)
		cfg = cfg or {}
		local function toText(v)
			if type(v) == "table" then return table.concat(v, "\n") end
			return tostring(v or "")
		end
		local titleText = toText(cfg.Title)
		local contentText = toText(cfg.Content)
		local hasTitle, hasContent = titleText ~= "", contentText ~= ""

		local f = Instance.new("Frame")
		f.Size = UDim2.new(1, 0, 0, 0)
		f.AutomaticSize = Enum.AutomaticSize.Y
		f.BackgroundColor3 = Theme.Element
		f.BorderSizePixel = 0
		f.Parent = tabContent
		Corner(f, 8)
		registerThemeRef(f, "BackgroundColor3", "Element")
		local s = Stroke(f, Theme.Border, Theme.ElementBorderThickness)
		registerThemeRef(s, "Color", "Border")
		Pad(f, 12, 12, 12, 12)
		local lay = Instance.new("UIListLayout")
		lay.SortOrder = Enum.SortOrder.LayoutOrder
		lay.Padding = UDim.new(0, 0)
		lay.Parent = f
		local sc = Instance.new("UISizeConstraint")
		sc.MinSize = Vector2.new(0, 52)
		sc.Parent = f

		local tRow = Instance.new("Frame")
		tRow.Size = UDim2.new(1, 0, 0, 0)
		tRow.AutomaticSize = Enum.AutomaticSize.Y
		tRow.BackgroundTransparency = 1
		tRow.LayoutOrder = 1
		tRow.Parent = f
		local rl = Instance.new("UIListLayout")
		rl.FillDirection = Enum.FillDirection.Horizontal
		rl.SortOrder = Enum.SortOrder.LayoutOrder
		rl.Padding = UDim.new(0, 8)
		rl.VerticalAlignment = Enum.VerticalAlignment.Center
		rl.Parent = tRow

		local iconOffset = 0
		if cfg.Icon and cfg.Icon ~= "" then
			local ic = makeIcon(tRow, cfg.Icon, UDim2.new(0, 18, 0, 18), UDim2.new(0, 0, 0, 0), window.accent)
			if ic then
				ic.LayoutOrder = 1
				iconOffset = 26
				window:onAccent(function(c) if ic.Parent then ic.ImageColor3 = c end end)
			end
		end
		local titleObj = Instance.new("TextLabel")
		titleObj.Size = UDim2.new(1, -iconOffset, 0, 0)
		titleObj.AutomaticSize = Enum.AutomaticSize.Y
		titleObj.BackgroundTransparency = 1
		titleObj.Text = titleText
		titleObj.TextColor3 = Theme.Text
		titleObj.TextSize = 13
		titleObj.Font = Enum.Font.GothamBold
		titleObj.TextXAlignment = Enum.TextXAlignment.Left
		titleObj.TextWrapped = true
		titleObj.LayoutOrder = 2
		titleObj.Visible = hasTitle
		titleObj.Parent = tRow
		registerThemeRef(titleObj, "TextColor3", "Text")
		tRow.Visible = (iconOffset > 0) or hasTitle

		local sp1 = Instance.new("Frame")
		sp1.Size = UDim2.new(1, 0, 0, 9)
		sp1.BackgroundTransparency = 1
		sp1.LayoutOrder = 2
		sp1.Visible = hasTitle and hasContent
		sp1.Parent = f
		local divider = Instance.new("Frame")
		divider.Size = UDim2.new(1, 0, 0, 2)
		divider.BackgroundColor3 = window.accent
		divider.BackgroundTransparency = 0.3
		divider.BorderSizePixel = 0
		divider.LayoutOrder = 3
		divider.Visible = hasTitle and hasContent
		divider.Parent = f
		Corner(divider, 1)
		window:onAccent(function(c) if divider.Parent then divider.BackgroundColor3 = c end end)
		local sp2 = Instance.new("Frame")
		sp2.Size = UDim2.new(1, 0, 0, 9)
		sp2.BackgroundTransparency = 1
		sp2.LayoutOrder = 4
		sp2.Visible = hasTitle and hasContent
		sp2.Parent = f

		local contentObj = Instance.new("TextLabel")
		contentObj.Size = UDim2.new(1, 0, 0, 0)
		contentObj.AutomaticSize = Enum.AutomaticSize.Y
		contentObj.BackgroundTransparency = 1
		contentObj.Text = contentText
		contentObj.TextColor3 = Theme.SubText
		contentObj.TextSize = 12
		contentObj.Font = Enum.Font.Gotham
		contentObj.TextXAlignment = Enum.TextXAlignment.Left
		contentObj.TextWrapped = true
		contentObj.LayoutOrder = 5
		contentObj.Visible = hasContent
		contentObj.Parent = f
		registerThemeRef(contentObj, "TextColor3", "SubText")

		playEnter(f, tab:NextOrder())
		local lockState = setupLock(f, cfg, nil)
		hoverBorder(f, s, function() return window.accent end, lockState)

		local para = {}
		function para:Set(newCfg)
			if type(newCfg) == "table" then
				if newCfg.Title ~= nil then
					titleText = toText(newCfg.Title)
					hasTitle = titleText ~= ""
					titleObj.Text = titleText
					titleObj.Visible = hasTitle
					tRow.Visible = (iconOffset > 0) or hasTitle
				end
				if newCfg.Content ~= nil then
					contentText = toText(newCfg.Content)
					hasContent = contentText ~= ""
					contentObj.Text = contentText
					contentObj.Visible = hasContent
				end
			else
				contentText = toText(newCfg)
				hasContent = contentText ~= ""
				contentObj.Text = contentText
				contentObj.Visible = hasContent
			end
			local showLine = hasTitle and hasContent
			sp1.Visible = showLine
			divider.Visible = showLine
			sp2.Visible = showLine
		end
		para.SetLocked = function(_, v) lockState.manual = v and true or false applyLocked(f, lockState.manual, lockState.text) end
		registerElement(window, tab, name, f, cfg, "paragraph", para)
		return para
	end

	--// TOGGLE (+ Locked)
	function tab:CreateToggle(cfg)
		cfg = cfg or {}
		local col = cfg.Color
		local f, s = elementFrame(H_ELEMENT)
		local ic = makeIcon(f, cfg.Icon)
		if ic then registerThemeRef(ic, "ImageColor3", "Text") end
		local lx = ic and 34 or 12
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -(lx + 58), 1, 0)
		lbl.Position = UDim2.new(0, lx, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = cfg.Name or cfg.Title or "Toggle"
		lbl.TextColor3 = Theme.Text
		lbl.TextSize = 13
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextTruncate = Enum.TextTruncate.AtEnd
		lbl.Parent = f
		registerThemeRef(lbl, "TextColor3", "Text")

		local switch = Instance.new("TextButton")
		switch.Size = UDim2.new(0, 40, 0, 20)
		switch.Position = UDim2.new(1, -52, 0.5, -10)
		switch.BackgroundColor3 = Theme.Border
		switch.BorderSizePixel = 0
		switch.Text = ""
		switch.AutoButtonColor = false
		switch.Parent = f
		Corner(switch, 99)
		registerThemeRef(switch, "BackgroundColor3", "Border")
		local circle = Instance.new("Frame")
		circle.Size = UDim2.new(0, 14, 0, 14)
		circle.Position = UDim2.new(0, 3, 0, 3)
		circle.BackgroundColor3 = Theme.SubText
		circle.BorderSizePixel = 0
		circle.Parent = switch
		Corner(circle, 99)
		registerThemeRef(circle, "BackgroundColor3", "SubText")

		local enabled = cfg.Default or false
		local function accent() return col or window.accent end
		local lockState
		local function update()
			if enabled then
				Tween(switch, .2, { BackgroundColor3 = accent() })
				Tween(circle, .2, { Position = UDim2.new(1, -17, 0, 3), BackgroundColor3 = Color3.new(1, 1, 1) })
			else
				Tween(switch, .2, { BackgroundColor3 = Theme.Border })
				Tween(circle, .2, { Position = UDim2.new(0, 3, 0, 3), BackgroundColor3 = Theme.SubText })
			end
			if cfg.Flag then
				Library.Flags[cfg.Flag] = enabled
				notifyLockWatchers(cfg.Flag)
			end
		end
		update()
		window:onAccent(function() update() end)

		local obj = {}
		lockState = setupLock(f, cfg, obj)
		hoverBorder(f, s, accent, lockState)

		switch.MouseButton1Click:Connect(function()
			if lockState.locked then return end
			enabled = not enabled
			update()
			if cfg.Callback then task.spawn(cfg.Callback, enabled) end
		end)
		addTooltip(f, cfg.Tooltip)

		function obj:Set(v)
			enabled = v and true or false
			update()
			if cfg.Callback then task.spawn(cfg.Callback, enabled) end
		end
		function obj:Get() return enabled end
		registerElement(window, tab, name, f, cfg, "toggle", obj)
		return obj
	end

	--// SLIDER (+ Locked)
	function tab:CreateSlider(cfg)
		cfg = cfg or {}
		local min, max = cfg.Min or 0, cfg.Max or 100
		local value = cfg.Default or min
		local col = cfg.Color
		local f, s = elementFrame(H_SLIDER)
		local ic = makeIcon(f, cfg.Icon, UDim2.new(0, 16, 0, 16), UDim2.new(0, 12, 0, 7))
		if ic then registerThemeRef(ic, "ImageColor3", "Text") end
		local lx = ic and 34 or 12
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.6, -lx, 0, 16)
		lbl.Position = UDim2.new(0, lx, 0, 7)
		lbl.BackgroundTransparency = 1
		lbl.Text = cfg.Name or cfg.Title or "Slider"
		lbl.TextColor3 = Theme.Text
		lbl.TextSize = 13
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextTruncate = Enum.TextTruncate.AtEnd
		lbl.Parent = f
		registerThemeRef(lbl, "TextColor3", "Text")

		local val = Instance.new("TextLabel")
		val.Size = UDim2.new(0.4, -12, 0, 16)
		val.Position = UDim2.new(0.6, 0, 0, 7)
		val.BackgroundTransparency = 1
		val.Text = tostring(value)
		val.TextColor3 = col or window.accent
		val.TextSize = 13
		val.Font = Enum.Font.GothamBold
		val.TextXAlignment = Enum.TextXAlignment.Right
		val.Parent = f

		local track = Instance.new("Frame")
		track.Size = UDim2.new(1, -24, 0, 6)
		track.Position = UDim2.new(0, 12, 0, 30)
		track.BackgroundColor3 = Theme.Border
		track.BorderSizePixel = 0
		track.Parent = f
		Corner(track, 99)
		registerThemeRef(track, "BackgroundColor3", "Border")
		local fill = Instance.new("Frame")
		fill.BackgroundColor3 = col or window.accent
		fill.BorderSizePixel = 0
		fill.Parent = track
		Corner(fill, 99)
		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 12, 0, 12)
		knob.BackgroundColor3 = Color3.new(1, 1, 1)
		knob.BorderSizePixel = 0
		knob.Parent = track
		Corner(knob, 99)
		local knobStroke = Stroke(knob, col or window.accent, 2)

		local hit = Instance.new("TextButton")
		hit.Size = UDim2.new(1, -24, 0, 18)
		hit.Position = UDim2.new(0, 12, 0, 24)
		hit.BackgroundTransparency = 1
		hit.Text = ""
		hit.AutoButtonColor = false
		hit.Parent = f

		local step = tonumber(cfg.Step) or 1
		if step <= 0 then step = 1 end
		local function snap(x)
			if step >= 1 then return math.floor(x + 0.0001) end
			return math.floor((x / step) + 0.5) * step
		end
		local function apply(v, fire)
			value = math.clamp(snap(v), min, max)
			local rel = (value - min) / math.max(0.0001, max - min)
			fill.Size = UDim2.new(rel, 0, 1, 0)
			knob.Position = UDim2.new(rel, -6, 0.5, -6)
			if cfg.Format then val.Text = cfg.Format(value)
			elseif step < 1 then val.Text = string.format("%.2f", value)
			else val.Text = tostring(value) end
			if cfg.Flag then
				Library.Flags[cfg.Flag] = value
				notifyLockWatchers(cfg.Flag)
			end
			if fire and cfg.Callback then task.spawn(cfg.Callback, value) end
		end
		apply(value, false)
		window:onAccent(function(c)
			if not col then
				val.TextColor3 = c
				fill.BackgroundColor3 = c
				knobStroke.Color = c
			end
		end)

		local obj = {}
		local lockState = setupLock(f, cfg, obj)
		hoverBorder(f, s, function() return col or window.accent end, lockState)

		local sliding = false
		hit.InputBegan:Connect(function(inp)
			if lockState.locked then return end
			if isPressInput(inp) then
				sliding = true
				local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
				apply(min + (max - min) * rel, true)
			end
		end)
		Connect(UserInputService.InputChanged, function(inp)
			if sliding and not lockState.locked and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
				local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
				apply(min + (max - min) * rel, true)
			end
		end, window)
		Connect(UserInputService.InputEnded, function(inp)
			if isPressInput(inp) then sliding = false end
		end, window)
		addTooltip(f, cfg.Tooltip)

		function obj:Set(v) apply(v, true) end
		function obj:Get() return value end
		registerElement(window, tab, name, f, cfg, "slider", obj)
		return obj
	end

--// ==========================================================
--// PART 2/4 SELESAI — LANJUT PART 3/4
--// (Button+Confirm, Textbox, Input, Dropdown, MultiDropdown,
--//  Keybind, ColorPicker, Mini Toggle, QuickBar & Net Perf
--//  dengan simpan posisi)
--// ==========================================================

--// ==========================================================
--// PART 3/4 : CreateButton s/d Net Performance + Frame Position
--// SAMBUNGKAN SETELAH PART 2/4
--// ==========================================================

	--// BUTTON (+ [FIX 4] Confirm Action, + [FIX 3] Locked)
	function tab:CreateButton(cfg)
		cfg = cfg or {}
		local col = cfg.Color
		local f, s = elementFrame(H_ELEMENT)
		local ic = makeIcon(f, cfg.Icon)
		if ic then registerThemeRef(ic, "ImageColor3", "Text") end
		local lx = ic and 34 or 12
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -(lx + 30), 1, 0)
		lbl.Position = UDim2.new(0, lx, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = cfg.Name or cfg.Title or "Button"
		lbl.TextColor3 = Theme.Text
		lbl.TextSize = 13
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextTruncate = Enum.TextTruncate.AtEnd
		lbl.Parent = f
		registerThemeRef(lbl, "TextColor3", "Text")

		local arrow = Instance.new("TextLabel")
		arrow.Size = UDim2.new(0, 20, 1, 0)
		arrow.Position = UDim2.new(1, -28, 0, 0)
		arrow.BackgroundTransparency = 1
		arrow.Text = "›"
		arrow.TextColor3 = col or window.accent
		arrow.TextSize = 18
		arrow.Font = Enum.Font.GothamBold
		arrow.Parent = f
		window:onAccent(function(c) if not col then arrow.TextColor3 = c end end)

		local obj = {}
		local lockState = setupLock(f, cfg, obj)
		hoverBorder(f, s, function() return col or window.accent end, lockState)

		local click = Instance.new("TextButton")
		click.Size = UDim2.new(1, 0, 1, 0)
		click.BackgroundTransparency = 1
		click.Text = ""
		click.AutoButtonColor = false
		click.Parent = f

		local function runCallback()
			if cfg.Callback then task.spawn(cfg.Callback) end
		end

		local function doClick()
			if lockState.locked then return end
			if Library.Effects.Ripple then
				f.ClipsDescendants = true
				local r = Instance.new("Frame")
				r.AnchorPoint = Vector2.new(0.5, 0.5)
				r.Position = UDim2.new(0.5, 0, 0.5, 0)
				r.Size = UDim2.new(0, 0, 0, 0)
				r.BackgroundColor3 = col or window.accent
				r.BackgroundTransparency = 0.55
				r.BorderSizePixel = 0
				r.ZIndex = (f.ZIndex or 1) + 1
				r.Parent = f
				Corner(r, 99)
				Tween(r, .45, { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 }, Enum.EasingStyle.Quart)
				task.delay(.46, function() if r.Parent then r:Destroy() end end)
			end
			Tween(f, .1, { Size = UDim2.new(1, -6, 0, H_ELEMENT - 2) }, Enum.EasingStyle.Back)
			task.delay(.12, function()
				if f.Parent then Tween(f, .15, { Size = UDim2.new(1, 0, 0, H_ELEMENT) }, Enum.EasingStyle.Back) end
			end)

			-- [FIX 4] minta konfirmasi dulu kalau cfg.Confirm aktif
			if cfg.Confirm then
				local c = (type(cfg.Confirm) == "table") and cfg.Confirm or {}
				Library:Action({
					Title = c.Title or ("Confirm: " .. tostring(cfg.Name or cfg.Title or "Action")),
					Content = c.Content or "Are you sure you want to run this action?",
					Icon = c.Icon or cfg.Icon or "help-circle",
					ConfirmText = c.ConfirmText or "Yes",
					CancelText = c.CancelText or "No",
					Danger = c.Danger,
					Cooldown = c.Cooldown,
					Accent = c.Accent,
					CloseOnBlocker = c.CloseOnBlocker,
					OnConfirm = runCallback,
					OnCancel = c.OnCancel,
				})
			else
				runCallback()
			end
		end

		click.MouseButton1Click:Connect(doClick)
		addTooltip(f, cfg.Tooltip)
		obj.Fire = function() doClick() end
		registerElement(window, tab, name, f, cfg, "button", obj)
		return obj
	end

	--// TEXTBOX
	function tab:CreateTextbox(cfg)
		cfg = cfg or {}
		local col = cfg.Color
		local f, s = elementFrame(H_ELEMENT)
		local ic = makeIcon(f, cfg.Icon)
		if ic then registerThemeRef(ic, "ImageColor3", "Text") end
		local lx = ic and 34 or 12
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -(lx + 152), 1, 0)
		lbl.Position = UDim2.new(0, lx, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = cfg.Name or cfg.Title or "Textbox"
		lbl.TextColor3 = Theme.Text
		lbl.TextSize = 13
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextTruncate = Enum.TextTruncate.AtEnd
		lbl.Parent = f
		registerThemeRef(lbl, "TextColor3", "Text")

		local box = Instance.new("TextBox")
		box.Size = UDim2.new(0, 140, 0, 24)
		box.Position = UDim2.new(1, -152, 0.5, -12)
		box.BackgroundColor3 = Theme.Background
		box.BorderSizePixel = 0
		box.PlaceholderText = cfg.PlaceholderText or cfg.Placeholder or "Type here..."
		box.PlaceholderColor3 = Theme.SubText
		box.Text = cfg.Default or ""
		box.TextColor3 = col or window.accent
		box.TextSize = 12
		box.Font = Enum.Font.Gotham
		box.ClearTextOnFocus = cfg.ClearTextOnFocus or false
		box.Parent = f
		Corner(box, 6)
		registerThemeRef(box, "BackgroundColor3", "Background")
		registerThemeRef(box, "PlaceholderColor3", "SubText")
		local bs = Stroke(box, Theme.Border, 1)
		registerThemeRef(bs, "Color", "Border")
		Pad(box, 0, 8, 0, 8)
		if cfg.Flag then Library.Flags[cfg.Flag] = box.Text end
		window:onAccent(function(c) if not col then box.TextColor3 = c end end)

		local obj = {}
		local lockState = setupLock(f, cfg, obj)
		hoverBorder(f, s, function() return col or window.accent end, lockState)

		box:GetPropertyChangedSignal("Text"):Connect(function()
			if lockState.locked then return end
			if cfg.Flag then Library.Flags[cfg.Flag] = box.Text notifyLockWatchers(cfg.Flag) end
			if cfg.Callback then task.spawn(cfg.Callback, box.Text) end
		end)
		addTooltip(f, cfg.Tooltip)
		obj.Set = function(_, t) box.Text = tostring(t or "") end
		obj.Get = function() return box.Text end
		registerElement(window, tab, name, f, cfg, "textbox", obj)
		return obj
	end

	--// INPUT
	function tab:CreateInput(cfg)
		cfg = cfg or {}
		local col = cfg.Color
		local value = cfg.CurrentValue or cfg.Default or ""
		local f, s = elementFrame(H_ELEMENT)
		local ic = makeIcon(f, cfg.Icon)
		if ic then registerThemeRef(ic, "ImageColor3", "Text") end
		local lx = ic and 34 or 12
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -(lx + 152), 1, 0)
		lbl.Position = UDim2.new(0, lx, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = cfg.Name or cfg.Title or "Input"
		lbl.TextColor3 = Theme.Text
		lbl.TextSize = 13
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextTruncate = Enum.TextTruncate.AtEnd
		lbl.Parent = f
		registerThemeRef(lbl, "TextColor3", "Text")

		local box = Instance.new("TextBox")
		box.Size = UDim2.new(0, 140, 0, 24)
		box.Position = UDim2.new(1, -152, 0.5, -12)
		box.BackgroundColor3 = Theme.Background
		box.BorderSizePixel = 0
		box.PlaceholderText = cfg.PlaceholderText or cfg.Placeholder or "Input here..."
		box.PlaceholderColor3 = Theme.SubText
		box.Text = value
		box.TextColor3 = col or window.accent
		box.TextSize = 12
		box.Font = Enum.Font.Gotham
		box.ClearTextOnFocus = false
		box.Parent = f
		Corner(box, 6)
		registerThemeRef(box, "BackgroundColor3", "Background")
		registerThemeRef(box, "PlaceholderColor3", "SubText")
		local bs = Stroke(box, Theme.Border, 1)
		registerThemeRef(bs, "Color", "Border")
		Pad(box, 0, 8, 0, 8)
		if cfg.Flag then Library.Flags[cfg.Flag] = value end
		window:onAccent(function(c) if not col then box.TextColor3 = c end end)

		local obj = {}
		local lockState = setupLock(f, cfg, obj)
		hoverBorder(f, s, function() return col or window.accent end, lockState)

		local suppress = false
		box:GetPropertyChangedSignal("Text"):Connect(function()
			if suppress or lockState.locked then return end
			value = box.Text
			if cfg.Flag then Library.Flags[cfg.Flag] = value notifyLockWatchers(cfg.Flag) end
			if cfg.Callback then task.spawn(cfg.Callback, value) end
		end)
		box.FocusLost:Connect(function()
			if cfg.RemoveTextAfterFocusLost then
				suppress = true box.Text = "" suppress = false
			end
		end)
		addTooltip(f, cfg.Tooltip)
		obj.Set = function(_, t)
			value = tostring(t or "")
			box.Text = value
			if cfg.Flag then Library.Flags[cfg.Flag] = value notifyLockWatchers(cfg.Flag) end
		end
		obj.Get = function() return value end
		registerElement(window, tab, name, f, cfg, "input", obj)
		return obj
	end

	--// DROPDOWN  [FIX 1] fitText + safeSizeConnect (no raw AbsoluteSize)
	function tab:CreateDropdown(cfg)
		cfg = cfg or {}
		local options = {}
		for _, v in ipairs(cfg.Options or {}) do table.insert(options, tostring(v)) end
		local col = cfg.Color
		local headerH = H_ELEMENT
		local gap = 4
		local listH = math.min(#options * 30, 150)
		local openH = headerH + gap + listH + 6

		local f, s = elementFrame(headerH)
		f.ClipsDescendants = true
		local ic = makeIcon(f, cfg.Icon, UDim2.new(0, 16, 0, 16), UDim2.new(0, 12, 0, 11), Theme.SubText)
		if ic then registerThemeRef(ic, "ImageColor3", "SubText") end
		local lx = ic and 34 or 12

		local nameFull = tostring(cfg.Name or cfg.Title or "Dropdown")
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.5, -lx - 10, 0, headerH)
		lbl.Position = UDim2.new(0, lx, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = nameFull
		lbl.TextColor3 = Theme.SubText
		lbl.TextSize = 13
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextYAlignment = Enum.TextYAlignment.Center
		lbl.TextTruncate = Enum.TextTruncate.AtEnd
		lbl.Parent = f
		registerThemeRef(lbl, "TextColor3", "SubText")

		local valueFull = tostring(cfg.Default or options[1] or "...")
		local val = Instance.new("TextLabel")
		val.Size = UDim2.new(0.5, -40, 0, headerH)
		val.Position = UDim2.new(0.5, 6, 0, 0)
		val.BackgroundTransparency = 1
		val.Text = valueFull
		val.TextColor3 = Theme.Text
		val.TextSize = 13
		val.Font = Enum.Font.GothamMedium
		val.TextXAlignment = Enum.TextXAlignment.Right
		val.TextYAlignment = Enum.TextYAlignment.Center
		val.TextTruncate = Enum.TextTruncate.AtEnd
		val.Parent = f
		registerThemeRef(val, "TextColor3", "Text")

		local function refreshLbl() fitText(lbl, nameFull) end
		local function refreshVal() fitText(val, valueFull) end
		task.spawn(function() task.wait() refreshLbl() refreshVal() end)
		safeSizeConnect(lbl, refreshLbl, window)
		safeSizeConnect(val, refreshVal, window)

		if cfg.Flag then Library.Flags[cfg.Flag] = valueFull end

		local arrow = Instance.new("TextLabel")
		arrow.Size = UDim2.new(0, 16, 0, 16)
		arrow.Position = UDim2.new(1, -26, 0, 11)
		arrow.BackgroundTransparency = 1
		arrow.Text = "›"
		arrow.TextColor3 = Theme.SubText
		arrow.TextSize = 16
		arrow.Font = Enum.Font.GothamBold
		arrow.Rotation = 90
		arrow.Parent = f
		registerThemeRef(arrow, "TextColor3", "SubText")

		local list = Instance.new("ScrollingFrame")
		list.Size = UDim2.new(1, -12, 0, 0)
		list.Position = UDim2.new(0, 6, 0, headerH + gap)
		list.BackgroundTransparency = 1
		list.BorderSizePixel = 0
		list.ScrollBarThickness = 2
		list.ScrollBarImageColor3 = Theme.Border
		list.AutomaticCanvasSize = Enum.AutomaticSize.Y
		list.CanvasSize = UDim2.new(0, 0, 0, 0)
		list.Parent = f
		local ll = Instance.new("UIListLayout")
		ll.SortOrder = Enum.SortOrder.LayoutOrder
		ll.Padding = UDim.new(0, 2)
		ll.Parent = list

		local isOpen = false
		local obj = {}
		local lockState = setupLock(f, cfg, obj)

		local function toggleOpen()
			if lockState.locked then return end
			isOpen = not isOpen
			if isOpen then
				Tween(f, .3, { Size = UDim2.new(1, 0, 0, openH) })
				Tween(list, .3, { Size = UDim2.new(1, -12, 0, listH) })
				Tween(arrow, .3, { Rotation = -90, TextColor3 = col or window.accent })
			else
				Tween(f, .3, { Size = UDim2.new(1, 0, 0, headerH) })
				Tween(list, .3, { Size = UDim2.new(1, -12, 0, 0) })
				Tween(arrow, .3, { Rotation = 90, TextColor3 = Theme.SubText })
			end
		end

		local function setValue(t)
			valueFull = tostring(t or "")
			refreshVal()
			if cfg.Flag then Library.Flags[cfg.Flag] = valueFull notifyLockWatchers(cfg.Flag) end
		end

		local function addOption(opt)
			opt = tostring(opt or "")
			local o = Instance.new("TextButton")
			o.Size = UDim2.new(1, 0, 0, 28)
			o.BackgroundColor3 = Color3.new(1, 1, 1)
			o.BackgroundTransparency = 1
			o.BorderSizePixel = 0
			o.Text = opt
			o.TextColor3 = Theme.SubText
			o.TextSize = 12
			o.Font = Enum.Font.Gotham
			o.TextXAlignment = Enum.TextXAlignment.Left
			o.TextTruncate = Enum.TextTruncate.AtEnd
			o.AutoButtonColor = false
			o.Parent = list
			Corner(o, 5)
			Pad(o, 0, 8, 0, 8)
			o.MouseEnter:Connect(function()
				Tween(o, .15, { BackgroundTransparency = .85, BackgroundColor3 = col or window.accent, TextColor3 = Theme.Text })
			end)
			o.MouseLeave:Connect(function()
				Tween(o, .15, { BackgroundTransparency = 1, TextColor3 = Theme.SubText })
			end)
			o.MouseButton1Click:Connect(function()
				setValue(opt)
				toggleOpen()
				if cfg.Callback then task.spawn(cfg.Callback, opt) end
			end)
		end
		for _, opt in ipairs(options) do addOption(opt) end

		local head = Instance.new("TextButton")
		head.Size = UDim2.new(1, 0, 0, headerH)
		head.BackgroundTransparency = 1
		head.Text = ""
		head.AutoButtonColor = false
		head.Parent = f
		head.MouseButton1Click:Connect(toggleOpen)
		hoverBorder(f, s, function() return col or window.accent end, lockState)
		addTooltip(f, cfg.Tooltip)

		obj.Refresh = function(_, newOpts)
			for _, c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
			options = {}
			for _, v in ipairs(newOpts or {}) do table.insert(options, tostring(v)) end
			listH = math.min(#options * 30, 150)
			openH = headerH + gap + listH + 6
			for _, opt in ipairs(options) do addOption(opt) end
			refreshVal()
			if isOpen then
				Tween(f, .25, { Size = UDim2.new(1, 0, 0, openH) })
				Tween(list, .25, { Size = UDim2.new(1, -12, 0, listH) })
			end
		end
		obj.Set = function(_, t)
			setValue(t)
			if cfg.Callback then task.spawn(cfg.Callback, valueFull) end
		end
		obj.Get = function() return valueFull end
		registerElement(window, tab, name, f, cfg, "dropdown", obj)
		return obj
	end

	--// MULTI DROPDOWN  [FIX 1] guarded
	function tab:CreateMultiDropdown(cfg)
		cfg = cfg or {}
		local options = {}
		for _, v in ipairs(cfg.Options or {}) do table.insert(options, tostring(v)) end
		local col = cfg.Color
		local headerH = H_ELEMENT
		local gap = 4
		local actionH = 30
		local optH = 30
		local maxList = 180
		local selected, selectedMap = {}, {}

		local function initSelected(def)
			selected, selectedMap = {}, {}
			if type(def) == "table" then
				for _, v in ipairs(def) do
					local sv = tostring(v)
					if not selectedMap[sv] then selectedMap[sv] = true table.insert(selected, sv) end
				end
			elseif type(def) == "string" and def ~= "" then
				for part in def:gmatch("[^,]+") do
					local sv = part:gsub("^%s*(.-)%s*$", "%1")
					if sv ~= "" and not selectedMap[sv] then selectedMap[sv] = true table.insert(selected, sv) end
				end
			end
		end
		initSelected(cfg.Default)

		local listH = math.min(#options * optH + actionH, maxList)
		local openH = headerH + gap + listH + 6
		local f, s = elementFrame(headerH)
		f.ClipsDescendants = true
		local ic = makeIcon(f, cfg.Icon, UDim2.new(0, 16, 0, 16), UDim2.new(0, 12, 0, 11), Theme.SubText)
		if ic then registerThemeRef(ic, "ImageColor3", "SubText") end
		local lx = ic and 34 or 12

		local nameFull = tostring(cfg.Name or cfg.Title or "Multi Select")
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.5, -lx - 10, 0, headerH)
		lbl.Position = UDim2.new(0, lx, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = nameFull
		lbl.TextColor3 = Theme.SubText
		lbl.TextSize = 13
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextTruncate = Enum.TextTruncate.AtEnd
		lbl.Parent = f
		registerThemeRef(lbl, "TextColor3", "SubText")

		local val = Instance.new("TextLabel")
		val.Size = UDim2.new(0.5, -40, 0, headerH)
		val.Position = UDim2.new(0.5, 6, 0, 0)
		val.BackgroundTransparency = 1
		val.TextColor3 = Theme.Text
		val.TextSize = 13
		val.Font = Enum.Font.GothamMedium
		val.TextXAlignment = Enum.TextXAlignment.Right
		val.TextTruncate = Enum.TextTruncate.AtEnd
		val.Parent = f
		registerThemeRef(val, "TextColor3", "Text")

		local function formatValue()
			if cfg.Format then return tostring(cfg.Format(selected)) end
			local n = #selected
			if n == 0 then return cfg.Placeholder or "None"
			elseif n == 1 then return selected[1]
			else return n .. " selected" end
		end
		local function refreshLbl() fitText(lbl, nameFull) end
		local function refreshVal() fitText(val, formatValue()) end
		task.spawn(function() task.wait() refreshLbl() refreshVal() end)
		safeSizeConnect(lbl, refreshLbl, window)
		safeSizeConnect(val, refreshVal, window)
		if cfg.Flag then Library.Flags[cfg.Flag] = table.clone(selected) end

		local arrow = Instance.new("TextLabel")
		arrow.Size = UDim2.new(0, 16, 0, 16)
		arrow.Position = UDim2.new(1, -26, 0, 11)
		arrow.BackgroundTransparency = 1
		arrow.Text = "›"
		arrow.TextColor3 = Theme.SubText
		arrow.TextSize = 16
		arrow.Font = Enum.Font.GothamBold
		arrow.Rotation = 90
		arrow.Parent = f
		registerThemeRef(arrow, "TextColor3", "SubText")

		local list = Instance.new("ScrollingFrame")
		list.Size = UDim2.new(1, -12, 0, 0)
		list.Position = UDim2.new(0, 6, 0, headerH + gap)
		list.BackgroundTransparency = 1
		list.BorderSizePixel = 0
		list.ScrollBarThickness = 2
		list.ScrollBarImageColor3 = Theme.Border
		list.AutomaticCanvasSize = Enum.AutomaticSize.Y
		list.CanvasSize = UDim2.new(0, 0, 0, 0)
		list.Parent = f
		local ll = Instance.new("UIListLayout")
		ll.SortOrder = Enum.SortOrder.LayoutOrder
		ll.Padding = UDim.new(0, 2)
		ll.Parent = list

		local actionBar = Instance.new("Frame")
		actionBar.Size = UDim2.new(1, 0, 0, actionH - 4)
		actionBar.BackgroundTransparency = 1
		actionBar.LayoutOrder = 0
		actionBar.Parent = list
		local al = Instance.new("UIListLayout")
		al.FillDirection = Enum.FillDirection.Horizontal
		al.SortOrder = Enum.SortOrder.LayoutOrder
		al.Padding = UDim.new(0, 6)
		al.VerticalAlignment = Enum.VerticalAlignment.Center
		al.Parent = actionBar

		local optionRows = {}
		local function refreshRowVisual(opt)
			local row = optionRows[opt]
			if not row then return end
			local isOn = selectedMap[opt] == true
			local ac = col or window.accent
			if isOn then
				Tween(row.box, .15, { BackgroundColor3 = ac, BackgroundTransparency = 0 })
				row.check.ImageTransparency = 0
				row.check.ImageColor3 = contrastOn(ac)
				Tween(row.lbl, .15, { TextColor3 = Theme.Text })
				Tween(row.row, .15, { BackgroundTransparency = 0.9 })
			else
				Tween(row.box, .15, { BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.4 })
				row.check.ImageTransparency = 1
				Tween(row.lbl, .15, { TextColor3 = Theme.SubText })
				Tween(row.row, .15, { BackgroundTransparency = 1 })
			end
		end
		local function refreshAllVisuals()
			for opt in pairs(optionRows) do refreshRowVisual(opt) end
			refreshVal()
		end
		local function commit(fire)
			if cfg.Flag then Library.Flags[cfg.Flag] = table.clone(selected) notifyLockWatchers(cfg.Flag) end
			refreshVal()
			if fire and cfg.Callback and not Library._loading then
				task.spawn(cfg.Callback, table.clone(selected))
			end
		end

		local obj = {}
		local lockState = setupLock(f, cfg, obj)

		local function toggleOption(opt)
			if lockState.locked then return end
			opt = tostring(opt)
			if selectedMap[opt] then
				selectedMap[opt] = nil
				for i = #selected, 1, -1 do if selected[i] == opt then table.remove(selected, i) break end end
			else
				selectedMap[opt] = true
				table.insert(selected, opt)
			end
			refreshRowVisual(opt)
			commit(true)
		end

		local function actionButton(text, order, fn)
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(0.5, -3, 1, -4)
			b.BackgroundColor3 = Theme.ElementHover
			b.BackgroundTransparency = 0.25
			b.BorderSizePixel = 0
			b.Text = text
			b.TextColor3 = Theme.SubText
			b.TextSize = 11
			b.Font = Enum.Font.GothamBold
			b.AutoButtonColor = false
			b.LayoutOrder = order
			b.Parent = actionBar
			Corner(b, 5)
			b.MouseEnter:Connect(function() Tween(b, .14, { BackgroundTransparency = 0, TextColor3 = Theme.Text }) end)
			b.MouseLeave:Connect(function() Tween(b, .14, { BackgroundTransparency = 0.25, TextColor3 = Theme.SubText }) end)
			b.MouseButton1Click:Connect(function() if not lockState.locked then fn() end end)
			return b
		end
		actionButton("Select All", 1, function()
			selected, selectedMap = {}, {}
			for _, opt in ipairs(options) do selectedMap[opt] = true table.insert(selected, opt) end
			refreshAllVisuals() commit(true)
		end)
		actionButton("Clear All", 2, function()
			selected, selectedMap = {}, {}
			refreshAllVisuals() commit(true)
		end)

		local function addOption(opt, order)
			opt = tostring(opt or "")
			local row = Instance.new("TextButton")
			row.Size = UDim2.new(1, 0, 0, optH)
			row.BackgroundColor3 = Color3.new(1, 1, 1)
			row.BackgroundTransparency = 1
			row.BorderSizePixel = 0
			row.Text = ""
			row.AutoButtonColor = false
			row.LayoutOrder = order
			row.Parent = list
			Corner(row, 5)
			Pad(row, 0, 8, 0, 8)
			local box = Instance.new("Frame")
			box.AnchorPoint = Vector2.new(0, 0.5)
			box.Size = UDim2.new(0, 16, 0, 16)
			box.Position = UDim2.new(0, 0, 0.5, 0)
			box.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			box.BackgroundTransparency = 0.4
			box.BorderSizePixel = 0
			box.Parent = row
			Corner(box, 4)
			Stroke(box, Theme.Border, 1.2)
			local check = Instance.new("ImageLabel")
			check.AnchorPoint = Vector2.new(0.5, 0.5)
			check.Size = UDim2.new(0, 12, 0, 12)
			check.Position = UDim2.new(0.5, 0, 0.5, 0)
			check.BackgroundTransparency = 1
			check.ImageTransparency = 1
			check.Parent = box
			setIcon(check, "check")
			local lo = Instance.new("TextLabel")
			lo.Size = UDim2.new(1, -28, 1, 0)
			lo.Position = UDim2.new(0, 24, 0, 0)
			lo.BackgroundTransparency = 1
			lo.Text = opt
			lo.TextColor3 = Theme.SubText
			lo.TextSize = 12
			lo.Font = Enum.Font.Gotham
			lo.TextXAlignment = Enum.TextXAlignment.Left
			lo.TextTruncate = Enum.TextTruncate.AtEnd
			lo.Parent = row
			row.MouseEnter:Connect(function()
				if not selectedMap[opt] then Tween(row, .14, { BackgroundTransparency = 0.9 }) end
			end)
			row.MouseLeave:Connect(function()
				if not selectedMap[opt] then Tween(row, .14, { BackgroundTransparency = 1 }) end
			end)
			row.MouseButton1Click:Connect(function() toggleOption(opt) end)
			optionRows[opt] = { row = row, box = box, check = check, lbl = lo }
			refreshRowVisual(opt)
		end
		for i, opt in ipairs(options) do addOption(opt, i) end

		local isOpen = false
		local function toggleOpen()
			if lockState.locked then return end
			isOpen = not isOpen
			if isOpen then
				listH = math.min(#options * optH + actionH, maxList)
				openH = headerH + gap + listH + 6
				Tween(f, .3, { Size = UDim2.new(1, 0, 0, openH) })
				Tween(list, .3, { Size = UDim2.new(1, -12, 0, listH) })
				Tween(arrow, .3, { Rotation = -90, TextColor3 = col or window.accent })
			else
				Tween(f, .3, { Size = UDim2.new(1, 0, 0, headerH) })
				Tween(list, .3, { Size = UDim2.new(1, -12, 0, 0) })
				Tween(arrow, .3, { Rotation = 90, TextColor3 = Theme.SubText })
			end
		end
		local head = Instance.new("TextButton")
		head.Size = UDim2.new(1, 0, 0, headerH)
		head.BackgroundTransparency = 1
		head.Text = ""
		head.AutoButtonColor = false
		head.Parent = f
		head.MouseButton1Click:Connect(toggleOpen)
		hoverBorder(f, s, function() return col or window.accent end, lockState)
		addTooltip(f, cfg.Tooltip)
		window:onAccent(function() refreshAllVisuals() end)

		obj.Refresh = function(_, newOpts)
			for _, c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
			optionRows = {}
			options = {}
			for _, v in ipairs(newOpts or {}) do table.insert(options, tostring(v)) end
			local newMap, newArr = {}, {}
			for _, opt in ipairs(options) do newMap[opt] = true end
			for _, opt in ipairs(selected) do if newMap[opt] then table.insert(newArr, opt) end end
			selected = newArr
			selectedMap = {}
			for _, opt in ipairs(selected) do selectedMap[opt] = true end
			for i, opt in ipairs(options) do addOption(opt, i) end
			refreshAllVisuals()
			if isOpen then
				listH = math.min(#options * optH + actionH, maxList)
				openH = headerH + gap + listH + 6
				Tween(f, .25, { Size = UDim2.new(1, 0, 0, openH) })
				Tween(list, .25, { Size = UDim2.new(1, -12, 0, listH) })
			end
		end
		obj.Set = function(_, t) initSelected(t) refreshAllVisuals() commit(true) end
		obj.Get = function() return table.clone(selected) end
		obj.GetString = function(sep) return table.concat(selected, sep or ", ") end
		registerElement(window, tab, name, f, cfg, "multidropdown", obj)
		return obj
	end

	--// KEYBIND  [FIX 2] shortKeyName + kolom fixed
	function tab:CreateKeybind(cfg)
		cfg = cfg or {}
		local col = cfg.Color
		local f, s = elementFrame(H_ELEMENT)
		local ic = makeIcon(f, cfg.Icon)
		if ic then registerThemeRef(ic, "ImageColor3", "Text") end
		local lx = ic and 34 or 12
		local displayName = tostring(cfg.Name or cfg.Title or "Keybind")
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -(lx + 96), 1, 0)
		lbl.Position = UDim2.new(0, lx, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = displayName
		lbl.TextColor3 = Theme.Text
		lbl.TextSize = 13
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextTruncate = Enum.TextTruncate.AtEnd
		lbl.Parent = f
		registerThemeRef(lbl, "TextColor3", "Text")

		local badge = Instance.new("TextButton")
		badge.Size = UDim2.new(0, 84, 0, 22)
		badge.Position = UDim2.new(1, -96, 0.5, -11)
		badge.BackgroundColor3 = Theme.Background
		badge.BorderSizePixel = 0
		badge.TextColor3 = col or window.accent
		badge.TextSize = 11
		badge.Font = Enum.Font.GothamBold
		badge.AutoButtonColor = false
		badge.TextTruncate = Enum.TextTruncate.AtEnd
		badge.Parent = f
		Corner(badge, 5)
		registerThemeRef(badge, "BackgroundColor3", "Background")
		local bs = Stroke(badge, Theme.Border, 1)
		registerThemeRef(bs, "Color", "Border")

		local current = cfg.CurrentKeybind or cfg.Default or Enum.KeyCode.Unknown
		if type(current) == "string" then current = Enum.KeyCode[current] or Enum.KeyCode.Unknown end
		local hold = cfg.HoldToInteract or false
		local binding, holding = false, false
		badge.Text = shortKeyName(current)
		if cfg.Flag then Library.Flags[cfg.Flag] = current.Name end
		local kbRow = window:AddKeybind(displayName, current)

		local obj = {}
		local lockState = setupLock(f, cfg, obj)
		hoverBorder(f, s, function() return col or window.accent end, lockState)

		local function setKey(k)
			current = k
			local txt = shortKeyName(k)
			badge.Text = txt
			kbRow:Set(k)
			if cfg.Flag then Library.Flags[cfg.Flag] = current.Name notifyLockWatchers(cfg.Flag) end
		end
		window:onAccent(function(c) if not col and not binding then badge.TextColor3 = c end end)

		badge.MouseButton1Click:Connect(function()
			if lockState.locked then return end
			binding = true
			badge.Text = "..."
			badge.TextColor3 = col or window.accent
		end)
		Connect(UserInputService.InputBegan, function(inp, gp)
			if gp then return end
			if binding and inp.UserInputType == Enum.UserInputType.Keyboard then
				binding = false
				if inp.KeyCode == Enum.KeyCode.Escape then
					setKey(Enum.KeyCode.Unknown)
				else
					setKey(inp.KeyCode)
				end
				badge.TextColor3 = col or window.accent
				if cfg.Callback then task.spawn(cfg.Callback, current) end
			elseif not binding and not lockState.locked and current ~= Enum.KeyCode.Unknown and inp.KeyCode == current then
				if hold then
					holding = true
					if cfg.Callback then task.spawn(cfg.Callback, true) end
				else
					if cfg.Callback then task.spawn(cfg.Callback, current) end
				end
			end
		end, window)
		Connect(UserInputService.InputEnded, function(inp)
			if holding and inp.KeyCode == current then
				holding = false
				if cfg.Callback then task.spawn(cfg.Callback, false) end
			end
		end, window)
		addTooltip(f, cfg.Tooltip)
		obj.SetKey = function(_, k)
			if type(k) == "string" then k = Enum.KeyCode[k] or Enum.KeyCode.Unknown end
			setKey(k)
		end
		obj.GetKey = function() return current end
		registerElement(window, tab, name, f, cfg, "keybind", obj)
		return obj
	end

	--// COLOR PICKER (HSV)  [FIX 1] guarded
	function tab:CreateColorPicker(cfg)
		cfg = cfg or {}
		local startCol = (typeof(cfg.Default) == "Color3" and cfg.Default) or Color3.fromRGB(255, 80, 80)
		local hue, sat, val = startCol:ToHSV()
		local col = Color3.fromHSV(hue, sat, val)
		local f, s = elementFrame(H_ELEMENT)
		f.ClipsDescendants = true
		local ic = makeIcon(f, cfg.Icon, UDim2.new(0, 16, 0, 16), UDim2.new(0, 12, 0, 11), Theme.SubText)
		if ic then registerThemeRef(ic, "ImageColor3", "SubText") end
		local lx = ic and 34 or 12

		local nameFull = tostring(cfg.Name or cfg.Title or "Color Picker")
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -(lx + 78), 0, H_ELEMENT)
		lbl.Position = UDim2.new(0, lx, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = nameFull
		lbl.TextColor3 = Theme.Text
		lbl.TextSize = 13
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextTruncate = Enum.TextTruncate.AtEnd
		lbl.Parent = f
		registerThemeRef(lbl, "TextColor3", "Text")
		local function refreshLbl() fitText(lbl, nameFull) end
		task.spawn(function() task.wait() refreshLbl() end)
		safeSizeConnect(lbl, refreshLbl, window)

		local swatch = Instance.new("TextButton")
		swatch.Size = UDim2.new(0, 42, 0, 20)
		swatch.Position = UDim2.new(1, -54, 0, 9)
		swatch.BackgroundColor3 = col
		swatch.BorderSizePixel = 0
		swatch.Text = ""
		swatch.AutoButtonColor = false
		swatch.Parent = f
		Corner(swatch, 5)
		Stroke(swatch, Color3.new(1, 1, 1), 1).Transparency = .75

		local padTop = H_ELEMENT + 6
		local svH, hueH = 84, 12
		local gridCell, gridPad, gridCols = 20, 4, 6
		local presets = {
			Color3.fromRGB(255,70,70), Color3.fromRGB(255,120,60), Color3.fromRGB(255,170,50),
			Color3.fromRGB(255,215,60), Color3.fromRGB(220,240,60), Color3.fromRGB(150,235,70),
			Color3.fromRGB(80,230,110), Color3.fromRGB(50,225,160), Color3.fromRGB(50,220,210),
			Color3.fromRGB(60,180,240), Color3.fromRGB(70,130,255), Color3.fromRGB(110,90,255),
			Color3.fromRGB(150,80,255), Color3.fromRGB(190,80,250), Color3.fromRGB(230,80,220),
			Color3.fromRGB(255,80,170), Color3.fromRGB(255,90,130), Color3.fromRGB(255,255,255),
			Color3.fromRGB(200,200,210), Color3.fromRGB(150,150,160), Color3.fromRGB(110,110,120),
			Color3.fromRGB(70,70,80), Color3.fromRGB(40,40,48), Color3.fromRGB(15,15,20),
		}
		local gridRows = math.ceil(#presets / gridCols)
		local gridH = gridRows * (gridCell + gridPad) - gridPad
		local openH = padTop + svH + 6 + hueH + 6 + gridH + 8

		local svPad = Instance.new("Frame")
		svPad.Size = UDim2.new(1, -16, 0, svH)
		svPad.Position = UDim2.new(0, 8, 0, padTop)
		svPad.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
		svPad.BorderSizePixel = 0
		svPad.Parent = f
		Corner(svPad, 6)
		local satLayer = Instance.new("Frame")
		satLayer.Size = UDim2.new(1, 0, 1, 0)
		satLayer.BackgroundColor3 = Color3.new(1, 1, 1)
		satLayer.BorderSizePixel = 0
		satLayer.Parent = svPad
		local sg = Instance.new("UIGradient")
		sg.Transparency = NumberSequence.new{ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }
		sg.Parent = satLayer
		local valLayer = Instance.new("Frame")
		valLayer.Size = UDim2.new(1, 0, 1, 0)
		valLayer.BackgroundColor3 = Color3.new(0, 0, 0)
		valLayer.BorderSizePixel = 0
		valLayer.Parent = satLayer
		local vg = Instance.new("UIGradient")
		vg.Transparency = NumberSequence.new{ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }
		vg.Rotation = 90
		vg.Parent = valLayer
		local svPointer = Instance.new("Frame")
		svPointer.AnchorPoint = Vector2.new(0.5, 0.5)
		svPointer.Size = UDim2.new(0, 12, 0, 12)
		svPointer.Position = UDim2.new(sat, 0, 1 - val, 0)
		svPointer.BackgroundColor3 = Color3.new(1, 1, 1)
		svPointer.BorderSizePixel = 0
		svPointer.ZIndex = 2
		svPointer.Parent = valLayer
		Corner(svPointer, 99)
		Stroke(svPointer, Color3.new(0, 0, 0), 1.5)

		local hueY = padTop + svH + 6
		local hueBar = Instance.new("Frame")
		hueBar.Size = UDim2.new(1, -16, 0, hueH)
		hueBar.Position = UDim2.new(0, 8, 0, hueY)
		hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
		hueBar.BorderSizePixel = 0
		hueBar.Parent = f
		Corner(hueBar, 99)
		local hg = Instance.new("UIGradient")
		hg.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
			ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255,150,0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,120)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,200,255)),
			ColorSequenceKeypoint.new(0.66, Color3.fromRGB(80,80,255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,200)),
			ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,0)),
		}
		hg.Parent = hueBar
		local huePointer = Instance.new("Frame")
		huePointer.AnchorPoint = Vector2.new(0.5, 0.5)
		huePointer.Size = UDim2.new(0, 10, 0, hueH + 4)
		huePointer.Position = UDim2.new(hue, 0, 0.5, 0)
		huePointer.BackgroundColor3 = Color3.new(1, 1, 1)
		huePointer.BorderSizePixel = 0
		huePointer.ZIndex = 2
		huePointer.Parent = hueBar
		Corner(huePointer, 99)

		local gridFrame = Instance.new("Frame")
		gridFrame.Size = UDim2.new(1, -16, 0, gridH)
		gridFrame.Position = UDim2.new(0, 8, 0, hueY + hueH + 6)
		gridFrame.BackgroundTransparency = 1
		gridFrame.Parent = f
		local gl = Instance.new("UIGridLayout")
		gl.CellSize = UDim2.new(0, gridCell, 0, gridCell)
		gl.CellPadding = UDim2.new(0, gridPad, 0, gridPad)
		gl.SortOrder = Enum.SortOrder.LayoutOrder
		gl.Parent = gridFrame

		local isOpen = false
		local obj = {}
		local lockState = setupLock(f, cfg, obj)

		local function applyVisuals(fire)
			col = Color3.fromHSV(hue, sat, val)
			svPad.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
			svPointer.Position = UDim2.new(sat, 0, 1 - val, 0)
			huePointer.Position = UDim2.new(hue, 0, 0.5, 0)
			swatch.BackgroundColor3 = col
			if cfg.Flag then Library.Flags[cfg.Flag] = col notifyLockWatchers(cfg.Flag) end
			if fire and cfg.Callback and not Library._loading then task.spawn(cfg.Callback, col) end
		end
		applyVisuals(false)

		local function togglePicker()
			if lockState.locked then return end
			isOpen = not isOpen
			Tween(f, .3, { Size = UDim2.new(1, 0, 0, isOpen and openH or H_ELEMENT) })
		end

		local dragSV = false
		local function svFromInput(inp)
			local abs, sz = svPad.AbsolutePosition, svPad.AbsoluteSize
			if sz.X < 1 or sz.Y < 1 then return end
			sat = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1)
			val = 1 - math.clamp((inp.Position.Y - abs.Y) / sz.Y, 0, 1)
			applyVisuals(false)
		end
		svPad.InputBegan:Connect(function(inp)
			if isOpen and not lockState.locked and isPressInput(inp) then dragSV = true svFromInput(inp) end
		end)
		local dragHue = false
		local function hueFromInput(inp)
			local abs, sz = hueBar.AbsolutePosition, hueBar.AbsoluteSize
			if sz.X < 1 then return end
			hue = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1)
			applyVisuals(false)
		end
		hueBar.InputBegan:Connect(function(inp)
			if isOpen and not lockState.locked and isPressInput(inp) then dragHue = true hueFromInput(inp) end
		end)
		Connect(UserInputService.InputChanged, function(inp)
			if not isOpen then return end
			if inp.UserInputType ~= Enum.UserInputType.MouseMovement and inp.UserInputType ~= Enum.UserInputType.Touch then return end
			if dragSV then svFromInput(inp) end
			if dragHue then hueFromInput(inp) end
		end, window)
		Connect(UserInputService.InputEnded, function(inp)
			if not isPressInput(inp) then return end
			if dragSV then dragSV = false applyVisuals(true) end
			if dragHue then dragHue = false applyVisuals(true) end
		end, window)

		for i, pc in ipairs(presets) do
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(0, gridCell, 0, gridCell)
			b.BackgroundColor3 = pc
			b.BorderSizePixel = 0
			b.Text = ""
			b.AutoButtonColor = false
			b.LayoutOrder = i
			b.Parent = gridFrame
			Corner(b, 5)
			b.MouseButton1Click:Connect(function()
				if lockState.locked then return end
				hue, sat, val = pc:ToHSV()
				applyVisuals(true)
			end)
		end

		swatch.MouseButton1Click:Connect(togglePicker)
		hoverBorder(f, s, function() return col end, lockState)
		addTooltip(f, cfg.Tooltip)
		obj.Set = function(_, c)
			if typeof(c) ~= "Color3" then return end
			hue, sat, val = c:ToHSV()
			applyVisuals(true)
		end
		obj.Get = function() return col end
		registerElement(window, tab, name, f, cfg, "colorpicker", obj)
		return obj
	end

	return tab
end

--// ==========================================================
--// [FIX 7] FLOATING FRAME REGISTRY + APPLY POSITIONS
--// ==========================================================
local function registerFloating(name, frame, applyFn)
	window._floatingFrames[name] = { frame = frame, apply = applyFn }
	local x, y = Library:GetFramePosition(name)
	if x then pcall(applyFn, x, y) end
end

function window:ApplyFramePositions()
	if self._destroyed then return end
	for fname, d in pairs(self._floatingFrames) do
		local x, y = Library:GetFramePosition(fname)
		if x and d.frame and d.frame.Parent then pcall(d.apply, x, y) end
	end
	local mx, my = Library:GetFramePosition("MainWindow")
	if mx then
		self.offset = Vector2.new(mx, my)
		main.Position = UDim2.new(0.5, mx, 0.5, my)
	end
end

--// ==========================================================
--// MINI TOGGLE (Hide / Show UI) + save posisi
--// ==========================================================
local MINI_W, MINI_H, MINI_ICON, MINI_LINE = 168, 42, 22, 3
local MiniToggle = Instance.new("TextButton")
MiniToggle.Name = "RoNetMini"
MiniToggle.AnchorPoint = Vector2.new(0.5, 0.5)
MiniToggle.Position = UDim2.new(0, 112, 0.5, 0)
MiniToggle.Size = UDim2.new(0, MINI_W, 0, MINI_H)
MiniToggle.BackgroundColor3 = Theme.Background
MiniToggle.BackgroundTransparency = 0.05
MiniToggle.BorderSizePixel = 0
MiniToggle.Text = ""
MiniToggle.AutoButtonColor = false
MiniToggle.ZIndex = 60
MiniToggle.Parent = gui
Corner(MiniToggle, 12)
registerThemeRef(MiniToggle, "BackgroundColor3", "Background")
registerRGB(Stroke(MiniToggle, Color3.new(1, 1, 1), Theme.MainBorderThickness))
Pad(MiniToggle, 0, 14, 0, 14)
local miniLayout = Instance.new("UIListLayout")
miniLayout.FillDirection = Enum.FillDirection.Horizontal
miniLayout.SortOrder = Enum.SortOrder.LayoutOrder
miniLayout.Padding = UDim.new(0, 10)
miniLayout.VerticalAlignment = Enum.VerticalAlignment.Center
miniLayout.Parent = MiniToggle
local miniIconFrame = Instance.new("Frame")
miniIconFrame.Size = UDim2.new(0, MINI_ICON, 0, MINI_ICON)
miniIconFrame.BackgroundTransparency = 1
miniIconFrame.LayoutOrder = 1
miniIconFrame.ZIndex = 61
miniIconFrame.Parent = MiniToggle
local miniLines = {}
local function makeMiniLine(y)
	local l = Instance.new("Frame")
	l.AnchorPoint = Vector2.new(0.5, 0.5)
	l.Position = UDim2.new(0.5, 0, 0.5, y)
	l.Size = UDim2.new(0, MINI_ICON, 0, MINI_LINE)
	l.BackgroundColor3 = Theme.Text
	l.BorderSizePixel = 0
	l.ZIndex = 62
	l.Parent = miniIconFrame
	Corner(l, 2)
	table.insert(miniLines, l)
	registerThemeRef(l, "BackgroundColor3", "Text")
	return l
end
makeMiniLine(-8) makeMiniLine(0) makeMiniLine(8)
local miniSep = Instance.new("Frame")
miniSep.Size = UDim2.new(0, 2, 0, MINI_ICON)
miniSep.BackgroundColor3 = Theme.Border
miniSep.BorderSizePixel = 0
miniSep.LayoutOrder = 2
miniSep.ZIndex = 61
miniSep.Parent = MiniToggle
registerThemeRef(miniSep, "BackgroundColor3", "Border")
local miniLbl = Instance.new("TextLabel")
miniLbl.Size = UDim2.new(0, 0, 0, MINI_ICON)
miniLbl.AutomaticSize = Enum.AutomaticSize.X
miniLbl.BackgroundTransparency = 1
miniLbl.Text = "Hide UI"
miniLbl.TextColor3 = Theme.Text
miniLbl.TextSize = 12
miniLbl.Font = Enum.Font.GothamBold
miniLbl.TextXAlignment = Enum.TextXAlignment.Left
miniLbl.LayoutOrder = 3
miniLbl.ZIndex = 61
miniLbl.Parent = MiniToggle
registerThemeRef(miniLbl, "TextColor3", "Text")
MiniToggle.MouseEnter:Connect(function() Tween(MiniToggle, .2, { BackgroundColor3 = Theme.ElementHover }) end)
MiniToggle.MouseLeave:Connect(function() Tween(MiniToggle, .2, { BackgroundColor3 = Theme.Background }) end)

local function setMiniIcon(open)
	local lineSize = UDim2.new(0, MINI_ICON, 0, MINI_LINE)
	if open then
		Tween(miniLines[1], .25, { Position = UDim2.new(0.5, 0, 0.5, 0), Rotation = 45, BackgroundTransparency = 0, Size = lineSize })
		Tween(miniLines[2], .25, { Position = UDim2.new(0.5, 0, 0.5, 0), Rotation = -45, BackgroundTransparency = 0, Size = lineSize })
		Tween(miniLines[3], .15, { BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, MINI_LINE) })
	else
		Tween(miniLines[1], .25, { Position = UDim2.new(0.5, 0, 0.5, -8), Rotation = 0, BackgroundTransparency = 0, Size = lineSize })
		Tween(miniLines[2], .25, { Position = UDim2.new(0.5, 0, 0.5, 0), Rotation = 0, BackgroundTransparency = 0, Size = lineSize })
		Tween(miniLines[3], .25, { Position = UDim2.new(0.5, 0, 0.5, 8), Rotation = 0, BackgroundTransparency = 0, Size = lineSize })
	end
end
local function setMiniLabel(open)
	miniLbl.Text = open and "Hide UI" or "Show UI"
	Tween(miniLbl, .2, { TextColor3 = open and Theme.Text or Theme.SubText })
end

local mDrag, mStart, mMoved = false, nil, 0
local mOrigX, mOrigY = 112, 0
Connect(MiniToggle.InputBegan, function(inp)
	if isPressInput(inp) then
		mDrag = true mMoved = 0 mStart = inp.Position
		local c = MiniToggle.AbsolutePosition + MiniToggle.AbsoluteSize / 2
		mOrigX, mOrigY = c.X, c.Y
	end
end, window)
Connect(UserInputService.InputChanged, function(inp)
	if mDrag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
		local d = inp.Position - mStart
		mMoved = math.max(mMoved, math.abs(d.X) + math.abs(d.Y))
		MiniToggle.Position = UDim2.new(0, mOrigX + d.X, 0, mOrigY + d.Y)
	end
end, window)
Connect(UserInputService.InputEnded, function(inp)
	if isPressInput(inp) then
		if mDrag and mMoved > 6 then
			Library:SetFramePosition("MiniToggle", MiniToggle.Position.X.Offset, MiniToggle.Position.Y.Offset)
		end
		mDrag = false
	end
end, window)
registerFloating("MiniToggle", MiniToggle, function(x, y)
	MiniToggle.Position = UDim2.new(0, x, 0, y)
	mOrigX, mOrigY = x, y
end)

function window:Toggle(force)
	if self._destroyed then return end
	if self._closeConfirmCleanup then pcall(self._closeConfirmCleanup) end
	closeSearchResults()
	local open = (force ~= nil) and force or not Library.Open
	Library.Open = open
	windowOpen = open
	refreshKbVis()
	if open then
		main.Visible = true
		Tween(main, .35, { Size = OPEN_SIZE }, Enum.EasingStyle.Back)
		if window.currentTab then staggerChildren(window.currentTab) end
	else
		Tween(main, .25, { Size = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In).Completed:Connect(function()
			if not Library.Open and not window._destroyed and main.Parent then main.Visible = false end
		end)
	end
	setMiniIcon(open)
	setMiniLabel(open)
end
MiniToggle.MouseButton1Click:Connect(function()
	if mMoved > 8 then return end
	window:Toggle()
end)
function window:SetInfoCard(_) end
minimizeBtn.MouseButton1Click:Connect(function() window:Toggle(false) end)

--// ==========================================================
--// QUICK BAR (+ flags + save posisi)
--// ==========================================================
if config.QuickBar ~= false then
	local QB_W, QB_HEADER_H = 236, 30
	local quickBar = Instance.new("Frame")
	quickBar.Name = "QuickBar"
	quickBar.AnchorPoint = Vector2.new(0.5, 0)
	quickBar.Position = UDim2.new(0.5, 0, 0, 92)
	quickBar.Size = UDim2.new(0, QB_W, 0, QB_HEADER_H)
	quickBar.BackgroundColor3 = Theme.Background
	quickBar.BackgroundTransparency = 0.1
	quickBar.BorderSizePixel = 0
	quickBar.ClipsDescendants = true
	quickBar.ZIndex = 70
	quickBar.Parent = gui
	Corner(quickBar, 9)
	registerThemeRef(quickBar, "BackgroundColor3", "Background")
	registerRGB(Stroke(quickBar, Color3.new(1, 1, 1), 1.8))

	local qbHeader = Instance.new("TextButton")
	qbHeader.Size = UDim2.new(1, 0, 0, QB_HEADER_H)
	qbHeader.BackgroundTransparency = 1
	qbHeader.Text = ""
	qbHeader.AutoButtonColor = false
	qbHeader.ZIndex = 71
	qbHeader.Parent = quickBar
	local qbIcon = makeIcon(qbHeader, "gauge", UDim2.new(0, 14, 0, 14), UDim2.new(0, 10, 0.5, -7), Theme.Text)
	if qbIcon then registerThemeRef(qbIcon, "ImageColor3", "Text") end
	local qbTitle = Instance.new("TextLabel")
	qbTitle.Size = UDim2.new(1, -60, 1, 0)
	qbTitle.Position = UDim2.new(0, 30, 0, 0)
	qbTitle.BackgroundTransparency = 1
	qbTitle.Text = config.QuickBarTitle or "Quick Bar"
	qbTitle.TextColor3 = Theme.Text
	qbTitle.TextSize = 12
	qbTitle.Font = Enum.Font.GothamBold
	qbTitle.TextXAlignment = Enum.TextXAlignment.Left
	qbTitle.TextTruncate = Enum.TextTruncate.AtEnd
	qbTitle.ZIndex = 71
	qbTitle.Parent = qbHeader
	registerThemeRef(qbTitle, "TextColor3", "Text")
	local qbChevron = Instance.new("TextLabel")
	qbChevron.Size = UDim2.new(0, 16, 0, 16)
	qbChevron.Position = UDim2.new(1, -24, 0.5, -8)
	qbChevron.BackgroundTransparency = 1
	qbChevron.Text = "›"
	qbChevron.TextColor3 = Theme.SubText
	qbChevron.TextSize = 14
	qbChevron.Font = Enum.Font.GothamBold
	qbChevron.Rotation = 90
	qbChevron.ZIndex = 71
	qbChevron.Parent = qbHeader
	registerThemeRef(qbChevron, "TextColor3", "SubText")

	local qbBody = Instance.new("Frame")
	qbBody.Size = UDim2.new(1, -12, 0, 0)
	qbBody.Position = UDim2.new(0, 6, 0, QB_HEADER_H + 2)
	qbBody.BackgroundTransparency = 1
	qbBody.ZIndex = 71
	qbBody.Parent = quickBar
	local qbList = Instance.new("UIListLayout")
	qbList.SortOrder = Enum.SortOrder.LayoutOrder
	qbList.Padding = UDim.new(0, 5)
	qbList.Parent = qbBody
	local qbPad = Instance.new("UIPadding")
	qbPad.PaddingBottom = UDim.new(0, 6)
	qbPad.Parent = qbBody

	local qbOpen = true
	local function setQuickBarOpen(on, instant)
		qbOpen = on and true or false
		local bodyH = qbOpen and (qbList.AbsoluteContentSize.Y + 8) or 0
		local targetH = QB_HEADER_H + 2 + bodyH
		if instant then
			quickBar.Size = UDim2.new(0, QB_W, 0, targetH)
			qbBody.Visible = qbOpen
		else
			if qbOpen then qbBody.Visible = true end
			Tween(quickBar, 0.25, { Size = UDim2.new(0, QB_W, 0, targetH) })
			if not qbOpen then
				task.delay(0.26, function()
					if quickBar.Parent and not qbOpen then qbBody.Visible = false end
				end)
			end
		end
		Tween(qbChevron, 0.25, { Rotation = qbOpen and 90 or -90 })
	end

	local function qbToggleRow(title, flag, default, callback)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 24)
		row.BackgroundColor3 = Theme.Element
		row.BackgroundTransparency = 0.35
		row.BorderSizePixel = 0
		row.ZIndex = 72
		row.Parent = qbBody
		Corner(row, 6)
		registerThemeRef(row, "BackgroundColor3", "Element")
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -48, 1, 0)
		lbl.Position = UDim2.new(0, 8, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = title
		lbl.TextColor3 = Theme.Text
		lbl.TextSize = 11
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextTruncate = Enum.TextTruncate.AtEnd
		lbl.ZIndex = 73
		lbl.Parent = row
		registerThemeRef(lbl, "TextColor3", "Text")
		local sw = Instance.new("TextButton")
		sw.Size = UDim2.new(0, 32, 0, 16)
		sw.Position = UDim2.new(1, -40, 0.5, -8)
		sw.BackgroundColor3 = Theme.Border
		sw.BorderSizePixel = 0
		sw.Text = ""
		sw.AutoButtonColor = false
		sw.ZIndex = 73
		sw.Parent = row
		Corner(sw, 99)
		registerThemeRef(sw, "BackgroundColor3", "Border")
		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 12, 0, 12)
		knob.Position = UDim2.new(0, 2, 0, 2)
		knob.BackgroundColor3 = Theme.SubText
		knob.BorderSizePixel = 0
		knob.ZIndex = 74
		knob.Parent = sw
		Corner(knob, 99)
		registerThemeRef(knob, "BackgroundColor3", "SubText")
		local on = default and true or false
		if flag then Library.Flags[flag] = on end
		local function update()
			if on then
				Tween(sw, .2, { BackgroundColor3 = window.accent })
				Tween(knob, .2, { Position = UDim2.new(1, -14, 0, 2), BackgroundColor3 = Color3.new(1, 1, 1) })
			else
				Tween(sw, .2, { BackgroundColor3 = Theme.Border })
				Tween(knob, .2, { Position = UDim2.new(0, 2, 0, 2), BackgroundColor3 = Theme.SubText })
			end
			if flag then Library.Flags[flag] = on notifyLockWatchers(flag) end
		end
		update()
		window:onAccent(function() update() end)
		sw.MouseButton1Click:Connect(function()
			on = not on
			update()
			if callback then task.spawn(callback, on) end
		end)
		return { Set = function(_, v)
			on = v and true or false
			update()
			if callback then task.spawn(callback, on) end
		end }
	end

	local function qbSliderRow(title, flag, min, max, default, callback)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 32)
		row.BackgroundColor3 = Theme.Element
		row.BackgroundTransparency = 0.35
		row.BorderSizePixel = 0
		row.ZIndex = 72
		row.Parent = qbBody
		Corner(row, 6)
		registerThemeRef(row, "BackgroundColor3", "Element")
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.6, -8, 0, 14)
		lbl.Position = UDim2.new(0, 8, 0, 4)
		lbl.BackgroundTransparency = 1
		lbl.Text = title
		lbl.TextColor3 = Theme.Text
		lbl.TextSize = 11
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.ZIndex = 73
		lbl.Parent = row
		registerThemeRef(lbl, "TextColor3", "Text")
		local val = Instance.new("TextLabel")
		val.Size = UDim2.new(0.4, -8, 0, 14)
		val.Position = UDim2.new(0.6, 0, 0, 4)
		val.BackgroundTransparency = 1
		val.Text = tostring(default)
		val.TextColor3 = window.accent
		val.TextSize = 11
		val.Font = Enum.Font.GothamBold
		val.TextXAlignment = Enum.TextXAlignment.Right
		val.ZIndex = 73
		val.Parent = row
		local track = Instance.new("Frame")
		track.Size = UDim2.new(1, -16, 0, 4)
		track.Position = UDim2.new(0, 8, 0, 21)
		track.BackgroundColor3 = Theme.Border
		track.BorderSizePixel = 0
		track.ClipsDescendants = true
		track.ZIndex = 73
		track.Parent = row
		Corner(track, 99)
		registerThemeRef(track, "BackgroundColor3", "Border")
		local fill = Instance.new("Frame")
		fill.Size = UDim2.new(0, 0, 1, 0)
		fill.BackgroundColor3 = window.accent
		fill.BorderSizePixel = 0
		fill.ZIndex = 74
		fill.Parent = track
		Corner(fill, 99)
		local value = default
		if flag then Library.Flags[flag] = value end
		local function apply(v, fire)
			value = math.clamp(math.floor(v + 0.5), min, max)
			fill.Size = UDim2.new((value - min) / math.max(0.0001, max - min), 0, 1, 0)
			val.Text = tostring(value)
			if flag then Library.Flags[flag] = value notifyLockWatchers(flag) end
			if fire and callback then task.spawn(callback, value) end
		end
		apply(value, false)
		window:onAccent(function(c) val.TextColor3 = c fill.BackgroundColor3 = c end)
		local hit = Instance.new("TextButton")
		hit.Size = UDim2.new(1, -16, 0, 14)
		hit.Position = UDim2.new(0, 8, 0, 16)
		hit.BackgroundTransparency = 1
		hit.Text = ""
		hit.AutoButtonColor = false
		hit.ZIndex = 75
		hit.Parent = row
		local sliding = false
		hit.InputBegan:Connect(function(inp)
			if isPressInput(inp) then
				sliding = true
				local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
				apply(min + (max - min) * rel, true)
			end
		end)
		Connect(UserInputService.InputChanged, function(inp)
			if sliding and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
				local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
				apply(min + (max - min) * rel, true)
			end
		end, window)
		Connect(UserInputService.InputEnded, function(inp) if isPressInput(inp) then sliding = false end end, window)
		return { Set = function(_, v) apply(v, true) end }
	end

	window.QuickBarRows = {
		InfJump = qbToggleRow("Inf Jump", "QB_InfJump", false, function(on) Library.Movement:SetInfJump(on) end),
		WalkToggle = qbToggleRow("WalkSpeed", "QB_WalkSpeedOn", false, function(on) Library.Movement:SetWalkSpeedActive(on) end),
		WalkSlider = qbSliderRow("WalkSpeed", "QB_WalkSpeed", 0, 500, 16, function(v) Library.Movement:SetWalkSpeed(v) end),
		JumpToggle = qbToggleRow("JumpPower", "QB_JumpPowerOn", false, function(on) Library.Movement:SetJumpPowerActive(on) end),
		JumpSlider = qbSliderRow("JumpPower", "QB_JumpPower", 0, 500, 50, function(v) Library.Movement:SetJumpPower(v) end),
	}
	setQuickBarOpen(true, true)

	local qbDrag, qbStart, qbMoved = false, nil, 0
	local qbOrigX, qbOrigY = 0, 92
	Connect(qbHeader.InputBegan, function(inp)
		if isPressInput(inp) then
			qbDrag = true qbMoved = 0 qbStart = inp.Position
			qbOrigX = quickBar.Position.X.Offset
			qbOrigY = quickBar.Position.Y.Offset
		end
	end, window)
	Connect(UserInputService.InputChanged, function(inp)
		if qbDrag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			local d = inp.Position - qbStart
			qbMoved = math.max(qbMoved, math.abs(d.X) + math.abs(d.Y))
			quickBar.Position = UDim2.new(0.5, qbOrigX + d.X, 0, qbOrigY + d.Y)
		end
	end, window)
	Connect(UserInputService.InputEnded, function(inp)
		if isPressInput(inp) then
			if qbDrag and qbMoved > 6 then
				Library:SetFramePosition("QuickBar", quickBar.Position.X.Offset, quickBar.Position.Y.Offset)
			end
			qbDrag = false
		end
	end, window)
	qbHeader.MouseButton1Click:Connect(function()
		if qbMoved > 6 then return end
		setQuickBarOpen(not qbOpen)
	end)
	registerFloating("QuickBar", quickBar, function(x, y)
		quickBar.Position = UDim2.new(0.5, x, 0, y)
		qbOrigX, qbOrigY = x, y
	end)
	function window:SetQuickBarVisible(v) quickBar.Visible = v and true or false end
	function window:ToggleQuickBar(force) setQuickBarOpen((force == nil) and not qbOpen or force) end
end

--// ==========================================================
--// NET PERFORMANCE BAR (+ save posisi)
--// ==========================================================
if config.NetStatsBar ~= false then
	local NSB_W, NSB_HEADER_H = 196, 28
	local netStatsBar = Instance.new("Frame")
	netStatsBar.Name = "NetPerformance"
	netStatsBar.AnchorPoint = Vector2.new(0.5, 0)
	netStatsBar.Position = UDim2.new(0.5, 0, 0, 130)
	netStatsBar.Size = UDim2.new(0, NSB_W, 0, NSB_HEADER_H)
	netStatsBar.BackgroundColor3 = Theme.Background
	netStatsBar.BackgroundTransparency = 0.1
	netStatsBar.BorderSizePixel = 0
	netStatsBar.ClipsDescendants = true
	netStatsBar.ZIndex = 70
	netStatsBar.Parent = gui
	Corner(netStatsBar, 9)
	registerThemeRef(netStatsBar, "BackgroundColor3", "Background")
	registerRGB(Stroke(netStatsBar, Color3.new(1, 1, 1), 1.8))

	local nsbHeader = Instance.new("TextButton")
	nsbHeader.Size = UDim2.new(1, 0, 0, NSB_HEADER_H)
	nsbHeader.BackgroundTransparency = 1
	nsbHeader.Text = ""
	nsbHeader.AutoButtonColor = false
	nsbHeader.ZIndex = 71
	nsbHeader.Parent = netStatsBar
	local nsbIcon = makeIcon(nsbHeader, "wifi", UDim2.new(0, 14, 0, 14), UDim2.new(0, 10, 0.5, -7), Theme.Text)
	if nsbIcon then registerThemeRef(nsbIcon, "ImageColor3", "Text") end
	local nsbTitle = Instance.new("TextLabel")
	nsbTitle.Size = UDim2.new(1, -60, 1, 0)
	nsbTitle.Position = UDim2.new(0, 30, 0, 0)
	nsbTitle.BackgroundTransparency = 1
	nsbTitle.Text = config.NetStatsBarTitle or "Net Performance"
	nsbTitle.TextColor3 = Theme.Text
	nsbTitle.TextSize = 12
	nsbTitle.Font = Enum.Font.GothamBold
	nsbTitle.TextXAlignment = Enum.TextXAlignment.Left
	nsbTitle.TextTruncate = Enum.TextTruncate.AtEnd
	nsbTitle.ZIndex = 71
	nsbTitle.Parent = nsbHeader
	registerThemeRef(nsbTitle, "TextColor3", "Text")
	local nsbChevron = Instance.new("TextLabel")
	nsbChevron.Size = UDim2.new(0, 16, 0, 16)
	nsbChevron.Position = UDim2.new(1, -24, 0.5, -8)
	nsbChevron.BackgroundTransparency = 1
	nsbChevron.Text = "›"
	nsbChevron.TextColor3 = Theme.SubText
	nsbChevron.TextSize = 14
	nsbChevron.Font = Enum.Font.GothamBold
	nsbChevron.Rotation = 90
	nsbChevron.ZIndex = 71
	nsbChevron.Parent = nsbHeader
	registerThemeRef(nsbChevron, "TextColor3", "SubText")

	local nsbBody = Instance.new("Frame")
	nsbBody.Size = UDim2.new(1, -12, 0, 0)
	nsbBody.Position = UDim2.new(0, 6, 0, NSB_HEADER_H + 2)
	nsbBody.BackgroundTransparency = 1
	nsbBody.ZIndex = 71
	nsbBody.Parent = netStatsBar
	local nsbList = Instance.new("UIListLayout")
	nsbList.SortOrder = Enum.SortOrder.LayoutOrder
	nsbList.Padding = UDim.new(0, 4)
	nsbList.Parent = nsbBody
	local nsbPad = Instance.new("UIPadding")
	nsbPad.PaddingBottom = UDim.new(0, 6)
	nsbPad.Parent = nsbBody

	local nsbOpen = true
	local function setNetStatsBarOpen(on, instant)
		nsbOpen = on and true or false
		local bodyH = nsbOpen and (nsbList.AbsoluteContentSize.Y + 8) or 0
		local targetH = NSB_HEADER_H + 2 + bodyH
		if instant then
			netStatsBar.Size = UDim2.new(0, NSB_W, 0, targetH)
			nsbBody.Visible = nsbOpen
		else
			if nsbOpen then nsbBody.Visible = true end
			Tween(netStatsBar, 0.25, { Size = UDim2.new(0, NSB_W, 0, targetH) })
			if not nsbOpen then
				task.delay(0.26, function()
					if netStatsBar.Parent and not nsbOpen then nsbBody.Visible = false end
				end)
			end
		end
		Tween(nsbChevron, 0.25, { Rotation = nsbOpen and 90 or -90 })
	end

	local function nsbRow(labelText)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 22)
		row.BackgroundColor3 = Theme.Element
		row.BackgroundTransparency = 0.35
		row.BorderSizePixel = 0
		row.ZIndex = 72
		row.Parent = nsbBody
		Corner(row, 6)
		registerThemeRef(row, "BackgroundColor3", "Element")
		local l = Instance.new("TextLabel")
		l.Size = UDim2.new(0.5, -8, 1, 0)
		l.Position = UDim2.new(0, 8, 0, 0)
		l.BackgroundTransparency = 1
		l.Text = labelText
		l.TextColor3 = Theme.Text
		l.TextSize = 11
		l.Font = Enum.Font.GothamMedium
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.ZIndex = 73
		l.Parent = row
		registerThemeRef(l, "TextColor3", "Text")
		local v = Instance.new("TextLabel")
		v.Size = UDim2.new(0.5, -8, 1, 0)
		v.Position = UDim2.new(0.5, 0, 0, 0)
		v.BackgroundTransparency = 1
		v.Text = "--"
		v.TextColor3 = window.accent
		v.TextSize = 11
		v.Font = Enum.Font.GothamBold
		v.TextXAlignment = Enum.TextXAlignment.Right
		v.ZIndex = 73
		v.Parent = row
		window:onAccent(function(c) v.TextColor3 = c end)
		return v
	end
	local nsbPingVal = nsbRow("Ping")
	local nsbFpsVal = nsbRow("FPS")
	setNetStatsBarOpen(true, true)

	local nsbDrag, nsbStart, nsbMoved = false, nil, 0
	local nsbOrigX, nsbOrigY = 0, 130
	Connect(nsbHeader.InputBegan, function(inp)
		if isPressInput(inp) then
			nsbDrag = true nsbMoved = 0 nsbStart = inp.Position
			nsbOrigX = netStatsBar.Position.X.Offset
			nsbOrigY = netStatsBar.Position.Y.Offset
		end
	end, window)
	Connect(UserInputService.InputChanged, function(inp)
		if nsbDrag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			local d = inp.Position - nsbStart
			nsbMoved = math.max(nsbMoved, math.abs(d.X) + math.abs(d.Y))
			netStatsBar.Position = UDim2.new(0.5, nsbOrigX + d.X, 0, nsbOrigY + d.Y)
		end
	end, window)
	Connect(UserInputService.InputEnded, function(inp)
		if isPressInput(inp) then
			if nsbDrag and nsbMoved > 6 then
				Library:SetFramePosition("NetPerformance", netStatsBar.Position.X.Offset, netStatsBar.Position.Y.Offset)
			end
			nsbDrag = false
		end
	end, window)
	nsbHeader.MouseButton1Click:Connect(function()
		if nsbMoved > 6 then return end
		setNetStatsBarOpen(not nsbOpen)
	end)
	registerFloating("NetPerformance", netStatsBar, function(x, y)
		netStatsBar.Position = UDim2.new(0.5, x, 0, y)
		nsbOrigX, nsbOrigY = x, y
	end)

	task.spawn(function()
		while netStatsBar.Parent do
			task.wait(1)
			if window._destroyed or Library._destroyed then return end
			nsbPingVal.Text = currentPing .. " ms"
			nsbFpsVal.Text = math.min(currentFps, 999) .. " FPS"
		end
	end)
	function window:SetNetStatsBarVisible(v) netStatsBar.Visible = v and true or false end
	function window:ToggleNetStatsBar(force) setNetStatsBarOpen((force == nil) and not nsbOpen or force) end
end

--// ==========================================================
--// SIDEBAR NET STATS (bawah sidebar)
--// ==========================================================
local sidebarNetStats = Instance.new("Frame")
sidebarNetStats.Size = UDim2.new(1, -(SIDE_PAD * 2), 0, 24)
sidebarNetStats.Position = UDim2.new(0, SIDE_PAD, 1, -30)
sidebarNetStats.BackgroundColor3 = Theme.Element
sidebarNetStats.BackgroundTransparency = 0.2
sidebarNetStats.BorderSizePixel = 0
sidebarNetStats.ZIndex = 42
sidebarNetStats.Parent = sidebar
Corner(sidebarNetStats, 6)
registerThemeRef(sidebarNetStats, "BackgroundColor3", "Element")
local snsPing = Instance.new("TextLabel")
snsPing.Size = UDim2.new(0.5, -4, 1, 0)
snsPing.Position = UDim2.new(0, 4, 0, 0)
snsPing.BackgroundTransparency = 1
snsPing.Text = "Ping: --"
snsPing.TextColor3 = Theme.SubText
snsPing.TextSize = 10
snsPing.Font = Enum.Font.GothamMedium
snsPing.TextXAlignment = Enum.TextXAlignment.Left
snsPing.ZIndex = 43
snsPing.Parent = sidebarNetStats
registerThemeRef(snsPing, "TextColor3", "SubText")
local snsFps = Instance.new("TextLabel")
snsFps.Size = UDim2.new(0.5, -4, 1, 0)
snsFps.Position = UDim2.new(0.5, 0, 0, 0)
snsFps.BackgroundTransparency = 1
snsFps.Text = "FPS: --"
snsFps.TextColor3 = window.accent
snsFps.TextSize = 10
snsFps.Font = Enum.Font.GothamBold
snsFps.TextXAlignment = Enum.TextXAlignment.Right
snsFps.ZIndex = 43
snsFps.Parent = sidebarNetStats
window:onAccent(function(c) snsFps.TextColor3 = c end)
task.spawn(function()
	while sidebarNetStats.Parent do
		task.wait(1)
		if window._destroyed or Library._destroyed then return end
		snsPing.Text = "Ping: " .. currentPing .. "ms"
		snsFps.Text = "FPS: " .. math.min(currentFps, 999)
	end
end)

--// ==========================================================
--// PART 3/4 SELESAI — LANJUT PART 4/4
--// (Close Confirm + Partikel, Home Tab, Tools Tab, Theme Tab,
--//  Save/Load + Overwrite + Export/Import, Library:Destroy, return)
--// ==========================================================

--// ==========================================================
--// PART 4/4 : Close Confirm + Home + Tools + Theme + Save/Load
--//            + Library:Destroy + return Library
--// SAMBUNGKAN SETELAH PART 3/4. INI BAGIAN TERAKHIR.
--// ==========================================================

--// ==========================================================
--// [FIX 4 + 5] CLOSE CONFIRMATION (Yes/No + Grid + Partikel)
--// ==========================================================
local CONFIRM_COOLDOWN = tonumber(config.ConfirmCooldown) or 3
local confirmModal, confirmBlocker, confirmRoot = nil, nil, nil

local function destroyCloseConfirm()
	if confirmRoot and confirmRoot.Parent then
		local root = confirmRoot
		local sc = confirmModal and confirmModal:FindFirstChildOfClass("UIScale")
		if sc then Tween(sc, 0.18, { Scale = 0.9 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In) end
		if confirmModal then Tween(confirmModal, 0.18, { BackgroundTransparency = 1 }) end
		if confirmBlocker then Tween(confirmBlocker, 0.2, { BackgroundTransparency = 1 }) end
		task.delay(0.22, function() if root and root.Parent then root:Destroy() end end)
	end
	confirmRoot, confirmModal, confirmBlocker = nil, nil, nil
	Library._confirmOpen = false
	Library._buttonPressLock = false
	if window and not window._destroyed then window._closeConfirmCleanup = nil end
end
window._closeConfirmCleanup = destroyCloseConfirm

local function showCloseConfirmation()
	destroyCloseConfirm()
	Library._confirmOpen = true
	Library._buttonPressLock = true
	dragging = false
	resizing = false
	closeSearchResults()

	local cd = window._closeButtonData
	if cd and cd.btn and cd.btn.Parent then
		pcall(function() Tween(cd.btn, .15, { BackgroundColor3 = Theme.Element }) end)
		if cd.lines then
			for _, l in ipairs(cd.lines) do pcall(function() Tween(l, .15, { BackgroundColor3 = Theme.SubText }) end) end
		end
	end

	local closeColor = window.closeColor or Theme.Close
	local closeHover = window.closeHoverColor or Theme.CloseHover
	local closeText = window.closeTextColor or Theme.CloseText

	confirmRoot = Instance.new("Frame")
	confirmRoot.Name = "CloseConfirmRoot"
	confirmRoot.Size = UDim2.new(1, 0, 1, 0)
	confirmRoot.BackgroundTransparency = 1
	confirmRoot.ZIndex = 9000
	confirmRoot.Parent = main

	confirmBlocker = Instance.new("TextButton")
	confirmBlocker.Size = UDim2.new(1, 0, 1, 0)
	confirmBlocker.BackgroundColor3 = Color3.new(0, 0, 0)
	confirmBlocker.BackgroundTransparency = 1
	confirmBlocker.BorderSizePixel = 0
	confirmBlocker.Text = ""
	confirmBlocker.AutoButtonColor = false
	confirmBlocker.ZIndex = 9000
	confirmBlocker.Parent = confirmRoot
	Tween(confirmBlocker, 0.2, { BackgroundTransparency = 0.45 })

	confirmModal = Instance.new("Frame")
	confirmModal.Name = "CloseConfirmModal"
	confirmModal.AnchorPoint = Vector2.new(0.5, 0.5)
	confirmModal.Position = UDim2.new(0.5, 0, 0.5, 0)
	confirmModal.Size = UDim2.new(0, 372, 0, 214)
	confirmModal.BackgroundColor3 = Theme.ConfirmBackground
	confirmModal.BackgroundTransparency = 1
	confirmModal.BorderSizePixel = 0
	confirmModal.ClipsDescendants = true
	confirmModal.ZIndex = 9001
	confirmModal.Parent = confirmRoot
	Corner(confirmModal, 12)
	local mStroke = Stroke(confirmModal, closeColor, 2)
	mStroke.Transparency = 1
	local mScale = Instance.new("UIScale")
	mScale.Scale = 0.88
	mScale.Parent = confirmModal

	-- [FIX 5] partikel + grid di dalam close frame
	createGridOverlay(confirmModal, window)
	createParticleBackground(confirmModal, 16, window)

	local body = Instance.new("Frame")
	body.Size = UDim2.new(1, 0, 1, 0)
	body.BackgroundTransparency = 1
	body.ZIndex = 9005
	body.Parent = confirmModal

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, -28, 0, 34)
	header.Position = UDim2.new(0, 14, 0, 14)
	header.BackgroundTransparency = 1
	header.ZIndex = 9006
	header.Parent = body
	local hl = Instance.new("UIListLayout")
	hl.FillDirection = Enum.FillDirection.Horizontal
	hl.SortOrder = Enum.SortOrder.LayoutOrder
	hl.Padding = UDim.new(0, 10)
	hl.VerticalAlignment = Enum.VerticalAlignment.Center
	hl.Parent = header
	local hIcon = makeIcon(header, "x-circle", UDim2.new(0, 22, 0, 22), UDim2.new(0, 0, 0, 0), closeColor)
	if hIcon then hIcon.LayoutOrder = 1 hIcon.ZIndex = 9007 end
	local cTitle = Instance.new("TextLabel")
	cTitle.Size = UDim2.new(1, -34, 1, 0)
	cTitle.BackgroundTransparency = 1
	cTitle.Text = tostring(window.confirmTitle or "Close Window")
	cTitle.TextColor3 = Theme.ConfirmText
	cTitle.TextSize = 17
	cTitle.Font = Enum.Font.GothamBlack
	cTitle.TextXAlignment = Enum.TextXAlignment.Left
	cTitle.TextTruncate = Enum.TextTruncate.AtEnd
	cTitle.LayoutOrder = 2
	cTitle.ZIndex = 9007
	cTitle.Parent = header

	local divider = Instance.new("Frame")
	divider.Size = UDim2.new(1, -28, 0, 2)
	divider.Position = UDim2.new(0, 14, 0, 54)
	divider.BackgroundColor3 = closeColor
	divider.BackgroundTransparency = 0.4
	divider.BorderSizePixel = 0
	divider.ZIndex = 9006
	divider.Parent = body
	Corner(divider, 99)
	local dg = Instance.new("UIGradient")
	dg.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.12, 0),
		NumberSequenceKeypoint.new(0.88, 0), NumberSequenceKeypoint.new(1, 1),
	}
	dg.Parent = divider

	local cSub = Instance.new("TextLabel")
	cSub.Size = UDim2.new(1, -28, 0, 62)
	cSub.Position = UDim2.new(0, 14, 0, 66)
	cSub.BackgroundTransparency = 1
	cSub.Text = tostring(window.confirmSubtitle or "")
	cSub.TextColor3 = Theme.ConfirmSubText
	cSub.TextSize = 12
	cSub.Font = Enum.Font.Gotham
	cSub.TextXAlignment = Enum.TextXAlignment.Left
	cSub.TextYAlignment = Enum.TextYAlignment.Top
	cSub.TextWrapped = true
	cSub.ZIndex = 9006
	cSub.Parent = body

	local btnRow = Instance.new("Frame")
	btnRow.Size = UDim2.new(1, -28, 0, 40)
	btnRow.Position = UDim2.new(0, 14, 1, -54)
	btnRow.BackgroundTransparency = 1
	btnRow.ZIndex = 9006
	btnRow.Parent = body
	local bl = Instance.new("UIListLayout")
	bl.FillDirection = Enum.FillDirection.Horizontal
	bl.HorizontalAlignment = Enum.HorizontalAlignment.Right
	bl.VerticalAlignment = Enum.VerticalAlignment.Center
	bl.Padding = UDim.new(0, 12)
	bl.Parent = btnRow

	local noBtn = Instance.new("TextButton")
	noBtn.Size = UDim2.new(0, 104, 0, 36)
	noBtn.BackgroundColor3 = Theme.Neutral
	noBtn.Text = "No"
	noBtn.TextColor3 = Theme.ConfirmText
	noBtn.TextSize = 14
	noBtn.Font = Enum.Font.GothamBold
	noBtn.AutoButtonColor = false
	noBtn.LayoutOrder = 1
	noBtn.ZIndex = 9007
	noBtn.Parent = btnRow
	Corner(noBtn, 7)
	noBtn.MouseEnter:Connect(function() Tween(noBtn, .15, { BackgroundColor3 = Theme.NeutralHover }) end)
	noBtn.MouseLeave:Connect(function() Tween(noBtn, .15, { BackgroundColor3 = Theme.Neutral }) end)
	noBtn.MouseButton1Click:Connect(function() destroyCloseConfirm() end)

	local yesBtn = Instance.new("TextButton")
	yesBtn.Size = UDim2.new(0, 104, 0, 36)
	yesBtn.BackgroundColor3 = closeColor
	yesBtn.Text = "Yes"
	yesBtn.TextColor3 = closeText
	yesBtn.TextSize = 14
	yesBtn.Font = Enum.Font.GothamBold
	yesBtn.AutoButtonColor = false
	yesBtn.LayoutOrder = 2
	yesBtn.ZIndex = 9007
	yesBtn.Parent = btnRow
	Corner(yesBtn, 7)

	Tween(mScale, 0.24, { Scale = 1 }, Enum.EasingStyle.Back)
	Tween(confirmModal, 0.2, { BackgroundTransparency = 0.04 })
	Tween(mStroke, 0.24, { Transparency = 0.15 })

	local canYes = CONFIRM_COOLDOWN <= 0
	if CONFIRM_COOLDOWN > 0 then
		yesBtn.BackgroundColor3 = Theme.Disabled
		yesBtn.TextColor3 = Theme.DisabledText
		task.spawn(function()
			for i = math.ceil(CONFIRM_COOLDOWN), 1, -1 do
				if not yesBtn.Parent then return end
				yesBtn.Text = "WAIT (" .. i .. ")"
				task.wait(1)
			end
			if yesBtn.Parent then
				yesBtn.Text = "Yes"
				yesBtn.BackgroundColor3 = window.closeColor or closeColor
				yesBtn.TextColor3 = window.closeTextColor or closeText
				canYes = true
			end
		end)
	end
	yesBtn.MouseEnter:Connect(function() if canYes then Tween(yesBtn, .15, { BackgroundColor3 = closeHover }) end end)
	yesBtn.MouseLeave:Connect(function() if canYes then Tween(yesBtn, .15, { BackgroundColor3 = closeColor }) end end)
	yesBtn.MouseButton1Click:Connect(function()
		if canYes then
			destroyCloseConfirm()
			window:Destroy()
		else
			Tween(yesBtn, .06, { Rotation = -4 })
			task.delay(.06, function() if yesBtn.Parent then Tween(yesBtn, .06, { Rotation = 4 }) end end)
			task.delay(.12, function() if yesBtn.Parent then Tween(yesBtn, .06, { Rotation = 0 }) end end)
		end
	end)

	Connect(main:GetPropertyChangedSignal("Visible"), function()
		if not main.Visible then destroyCloseConfirm() end
	end, window)
end
closeBtn.MouseButton1Click:Connect(function() showCloseConfirmation() end)

Connect(UserInputService.InputBegan, function(inp, gp)
	if gp then return end
	if Library._confirmOpen or Library._actionOpen then return end
	if inp.KeyCode == Library.ToggleKey then window:Toggle() end
end, window)

setMiniIcon(true)
setMiniLabel(true)

--// AUTOLOAD
local function performAutoLoad(delayTime)
	if not Library.AutoLoad.Enabled or Library._autoLoaded then return end
	Library._autoLoaded = true
	task.delay(delayTime or 0, function()
		if Library._destroyed or window._destroyed then return end
		local files = listSaveFiles()
		if #files == 0 then return end
		local target = Library.AutoLoad.File
		if not target or target == "" then target = "autosave" end
		local found = false
		for _, f in ipairs(files) do if f == target then found = true break end end
		if not found then target = files[1] end
		local ok = Library:LoadFromFile(target)
		if ok then
			Library._saveFile = target
			window:ApplyFramePositions()
			Library:Notify("Auto loaded: " .. target, 3, "Loader", "upload")
		end
	end)
end

--// ==========================================================
--// HOME TAB
--// ==========================================================
if config.InfoTab ~= false then
	local homeTab = window:CreateTab(config.InfoTabName or "Home", "home")
	homeTab.btn.LayoutOrder = -100
	homeTab.content.LayoutOrder = -100

	local function infoRow(height)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, height)
		row.BackgroundTransparency = 1
		row.Parent = homeTab.content
		local lay = Instance.new("UIListLayout")
		lay.FillDirection = Enum.FillDirection.Horizontal
		lay.SortOrder = Enum.SortOrder.LayoutOrder
		lay.Padding = UDim.new(0, 8)
		lay.Parent = row
		return row
	end

	local function infoCard(parent, titleText, iconName, height, scaleX, offsetX)
		local card = Instance.new("Frame")
		card.Size = UDim2.new(scaleX or 0.5, offsetX or -4, 0, height)
		card.BackgroundColor3 = Theme.Element
		card.BorderSizePixel = 0
		card.ZIndex = 1
		card.Parent = parent
		Corner(card, 8)
		registerThemeRef(card, "BackgroundColor3", "Element")
		local st = Stroke(card, Theme.Border, Theme.ElementBorderThickness)
		registerThemeRef(st, "Color", "Border")
		local ic = makeIcon(card, iconName, UDim2.new(0, 14, 0, 14), UDim2.new(0, 10, 0, 9), window.accent)
		if ic then
			ic.ZIndex = 2
			window:onAccent(function(c) if ic.Parent then ic.ImageColor3 = c end end)
		end
		local t = Instance.new("TextLabel")
		t.Size = UDim2.new(1, -34, 0, 16)
		t.Position = UDim2.new(0, 30, 0, 8)
		t.BackgroundTransparency = 1
		t.Text = tostring(titleText or ""):upper()
		t.TextColor3 = Theme.SubText
		t.TextSize = 10
		t.Font = Enum.Font.GothamBold
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.TextTruncate = Enum.TextTruncate.AtEnd
		t.ZIndex = 2
		t.Parent = card
		registerThemeRef(t, "TextColor3", "SubText")
		local body = Instance.new("Frame")
		body.Size = UDim2.new(1, -16, 1, -30)
		body.Position = UDim2.new(0, 8, 0, 28)
		body.BackgroundTransparency = 1
		body.ZIndex = 2
		body.Parent = card
		playEnter(card, homeTab:NextOrder())
		return card, body
	end

	local function infoButtonRow(parent, posY, height)
		local r = Instance.new("Frame")
		r.Size = UDim2.new(1, 0, 0, height or 24)
		r.Position = UDim2.new(0, 0, 0, posY)
		r.BackgroundTransparency = 1
		r.ZIndex = 3
		r.Parent = parent
		local lay = Instance.new("UIListLayout")
		lay.FillDirection = Enum.FillDirection.Horizontal
		lay.SortOrder = Enum.SortOrder.LayoutOrder
		lay.Padding = UDim.new(0, 6)
		lay.Parent = r
		return r
	end

	local function infoButton(parent, text, order, callback)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0.5, -3, 1, 0)
		b.LayoutOrder = order or 1
		b.BackgroundColor3 = Theme.Background
		b.BorderSizePixel = 0
		b.Text = text
		b.TextColor3 = Theme.Text
		b.TextSize = 10
		b.Font = Enum.Font.GothamBold
		b.AutoButtonColor = false
		b.TextTruncate = Enum.TextTruncate.AtEnd
		b.ZIndex = 4
		b.Parent = parent
		Corner(b, 5)
		registerThemeRef(b, "BackgroundColor3", "Background")
		registerThemeRef(b, "TextColor3", "Text")
		local bs = Stroke(b, Theme.Border, 1)
		registerThemeRef(bs, "Color", "Border")
		b.MouseEnter:Connect(function() Tween(b, .15, { BackgroundColor3 = Theme.ElementHover }) end)
		b.MouseLeave:Connect(function() Tween(b, .15, { BackgroundColor3 = Theme.Background }) end)
		b.MouseButton1Click:Connect(function() if callback then task.spawn(callback) end end)
		return b
	end

	local function infoLabel(parent, posY, height, textSize, font, themeKey, truncate)
		local l = Instance.new("TextLabel")
		l.Size = UDim2.new(1, 0, 0, height)
		l.Position = UDim2.new(0, 0, 0, posY)
		l.BackgroundTransparency = 1
		l.TextColor3 = Theme[themeKey] or Theme.Text
		l.TextSize = textSize
		l.Font = font
		l.TextXAlignment = Enum.TextXAlignment.Left
		if truncate then l.TextTruncate = Enum.TextTruncate.AtEnd end
		l.ZIndex = 3
		l.Parent = parent
		registerThemeRef(l, "TextColor3", themeKey or "Text")
		return l
	end

	local function makeSparkline(parent, barCount)
		barCount = barCount or 22
		local holder = Instance.new("Frame")
		holder.Size = UDim2.new(1, 0, 0, 16)
		holder.BackgroundTransparency = 1
		holder.ClipsDescendants = true
		holder.ZIndex = 3
		holder.Parent = parent
		local lay = Instance.new("UIListLayout")
		lay.FillDirection = Enum.FillDirection.Horizontal
		lay.SortOrder = Enum.SortOrder.LayoutOrder
		lay.Padding = UDim.new(0, 2)
		lay.VerticalAlignment = Enum.VerticalAlignment.Bottom
		lay.Parent = holder
		local bars = {}
		for i = 1, barCount do
			local bar = Instance.new("Frame")
			bar.Size = UDim2.new(1 / barCount, -2, 0.08, 0)
			bar.BackgroundColor3 = window.accent
			bar.BorderSizePixel = 0
			bar.LayoutOrder = i
			bar.Parent = holder
			Corner(bar, 1)
			bars[i] = bar
		end
		window:onAccent(function(c)
			for _, bar in ipairs(bars) do if bar.Parent then bar.BackgroundColor3 = c end end
		end)
		local history = {}
		local spark = {}
		function spark:Push(value, maxV)
			table.insert(history, tonumber(value) or 0)
			if #history > barCount then table.remove(history, 1) end
			maxV = math.max(tonumber(maxV) or 1, 1)
			for i = 1, barCount do
				local idx = #history - barCount + i
				local v = (idx >= 1) and history[idx] or 0
				bars[i].Size = UDim2.new(1 / barCount, -2, math.clamp(v / maxV, 0.06, 1), 0)
			end
		end
		return spark, holder
	end

	-- ROW 1: Operator + Place
	local row1 = infoRow(150)
	local opCard, opBody = infoCard(row1, "Operator", "user", 150, 0.5, -4)
	local avatar = Instance.new("ImageLabel")
	avatar.Size = UDim2.new(0, 44, 0, 44)
	avatar.BackgroundColor3 = Theme.Background
	avatar.BorderSizePixel = 0
	avatar.ZIndex = 3
	avatar.Parent = opBody
	Corner(avatar, 99)
	registerThemeRef(avatar, "BackgroundColor3", "Background")
	registerRGB(Stroke(avatar, Color3.new(1, 1, 1), 2))
	pcall(function()
		avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"
	end)
	local opName = infoLabel(opBody, 0, 16, 12, Enum.Font.GothamBold, "Text", true)
	opName.Position = UDim2.new(0, 52, 0, 0)
	opName.Size = UDim2.new(1, -52, 0, 16)
	opName.Text = LocalPlayer.DisplayName
	local opUser = infoLabel(opBody, 17, 13, 10, Enum.Font.Gotham, "SubText", true)
	opUser.Position = UDim2.new(0, 52, 0, 17)
	opUser.Size = UDim2.new(1, -52, 0, 13)
	opUser.Text = "@" .. LocalPlayer.Name
	local opId = infoLabel(opBody, 31, 13, 10, Enum.Font.Gotham, "SubText", true)
	opId.Position = UDim2.new(0, 52, 0, 31)
	opId.Size = UDim2.new(1, -52, 0, 13)
	opId.Text = "UserId " .. tostring(LocalPlayer.UserId)
	local opBtnRow = infoButtonRow(opBody, 96, 24)
	infoButton(opBtnRow, "Copy UserId", 1, function()
		local ok = copyToClipboard(tostring(LocalPlayer.UserId))
		Library:Notify(ok and ("UserId copied: " .. LocalPlayer.UserId) or "Clipboard unavailable.", 3, "Operator", ok and "check-circle" or "x-circle")
	end)
	infoButton(opBtnRow, "Copy Name", 2, function()
		local ok = copyToClipboard(LocalPlayer.Name)
		Library:Notify(ok and ("Name copied: " .. LocalPlayer.Name) or "Clipboard unavailable.", 3, "Operator", ok and "check-circle" or "x-circle")
	end)

	local plCard, plBody = infoCard(row1, "Place", "map-pin", 150, 0.5, -4)
	local placeName = "Unknown Place"
	local placeId = game.PlaceId or 0
	pcall(function()
		local info = game:GetService("MarketplaceService"):GetProductInfo(placeId)
		if info and info.Name then placeName = info.Name end
	end)
	local plName = infoLabel(plBody, 0, 16, 12, Enum.Font.GothamBold, "Text", true)
	plName.Text = placeName
	local plId = infoLabel(plBody, 18, 13, 10, Enum.Font.Gotham, "SubText", true)
	plId.Text = "PlaceId " .. tostring(placeId)
	local plJob = infoLabel(plBody, 33, 13, 10, Enum.Font.Gotham, "SubText", true)
	plJob.Text = "JobId " .. tostring(game.JobId or "Unknown")
	local plDivider = Instance.new("Frame")
	plDivider.Size = UDim2.new(1, 0, 0, 2)
	plDivider.Position = UDim2.new(0, 0, 0, 52)
	plDivider.BackgroundColor3 = Theme.Border
	plDivider.BorderSizePixel = 0
	plDivider.Parent = plBody
	registerThemeRef(plDivider, "BackgroundColor3", "Border")
	local plBtnA = infoButtonRow(plBody, 58, 24)
	infoButton(plBtnA, "Rejoin Server", 1, function()
		Library:Action({
			Title = "Rejoin Server",
			Content = "You will be teleported back into this same server. Continue?",
			Icon = "refresh-cw", Danger = false,
			OnConfirm = function()
				Library:Notify("Rejoining server...", 3, "Place", "refresh-cw")
				local ok, err = rejoinServer()
				if not ok then Library:Notify("Rejoin failed: " .. tostring(err), 4, "Place", "x-circle") end
			end,
		})
	end)
	infoButton(plBtnA, "Copy Job ID", 2, function()
		local ok = copyToClipboard(tostring(game.JobId))
		Library:Notify(ok and "Job ID copied." or "Clipboard unavailable.", 3, "Place", ok and "check-circle" or "x-circle")
	end)
	local plBtnB = infoButtonRow(plBody, 86, 24)
	infoButton(plBtnB, "Copy PlaceId", 1, function()
		local ok = copyToClipboard(tostring(game.PlaceId))
		Library:Notify(ok and ("PlaceId copied: " .. game.PlaceId) or "Clipboard unavailable.", 3, "Place", ok and "check-circle" or "x-circle")
	end)
	infoButton(plBtnB, "Copy Join Script", 2, function()
		local ok = copyToClipboard(joinScriptText())
		Library:Notify(ok and "Join script copied." or "Clipboard unavailable.", 3, "Place", ok and "check-circle" or "x-circle")
	end)

	-- ROW 2: FPS / Ping / Session
	local row2 = infoRow(86)
	local fpsCard, fpsBody = infoCard(row2, "Frame Rate", "activity", 86, 1 / 3, -6)
	local fpsValue = infoLabel(fpsBody, 2, 20, 16, Enum.Font.GothamBlack, "Text", false)
	fpsValue.Text = "-- FPS"
	window:onAccent(function(c) if fpsValue.Parent then fpsValue.TextColor3 = c end end)
	local fpsSpark, fpsHolder = makeSparkline(fpsBody, 22)
	fpsHolder.Position = UDim2.new(0, 0, 1, -16)
	local pingCard, pingBody = infoCard(row2, "Network Ping", "wifi", 86, 1 / 3, -6)
	local pingValue = infoLabel(pingBody, 2, 20, 16, Enum.Font.GothamBlack, "Text", false)
	pingValue.Text = "-- ms"
	window:onAccent(function(c) if pingValue.Parent then pingValue.TextColor3 = c end end)
	local pingSpark, pingHolder = makeSparkline(pingBody, 22)
	pingHolder.Position = UDim2.new(0, 0, 1, -16)
	local sesCard, sesBody = infoCard(row2, "Session & Server", "clock", 86, 1 / 3, -6)
	local sesValue = infoLabel(sesBody, 0, 18, 14, Enum.Font.GothamBold, "Text", false)
	sesValue.Text = "0h 00m 00s"
	local sesPlayers = infoLabel(sesBody, 20, 13, 10, Enum.Font.Gotham, "SubText", true)
	sesPlayers.Text = "Players: --/--"
	local sesServer = infoLabel(sesBody, 34, 13, 10, Enum.Font.Gotham, "SubText", true)
	sesServer.Text = "Server up: --"

	-- ROW 3: Website (big copy button)
	local WEB_URL = config.WebsiteUrl or "https://u721rd.mimo.run/Ro-NetriumV4.html"
	local row3 = infoRow(64)
	local webCard, webBody = infoCard(row3, "Website", "globe", 64, 1, 0)
	local webInput = Instance.new("TextBox")
	webInput.Size = UDim2.new(1, -120, 1, 0)
	webInput.BackgroundColor3 = Theme.Background
	webInput.BorderSizePixel = 0
	webInput.Text = WEB_URL
	webInput.TextColor3 = Theme.SubText
	webInput.TextSize = 11
	webInput.Font = Enum.Font.Gotham
	webInput.TextXAlignment = Enum.TextXAlignment.Left
	webInput.ClearTextOnFocus = false
	webInput.TextEditable = false
	webInput.Parent = webBody
	Corner(webInput, 6)
	registerThemeRef(webInput, "BackgroundColor3", "Background")
	registerThemeRef(webInput, "TextColor3", "SubText")
	Pad(webInput, 0, 10, 0, 10)
	local webCopyBtn = Instance.new("TextButton")
	webCopyBtn.Size = UDim2.new(0, 112, 1, 0)
	webCopyBtn.Position = UDim2.new(1, -112, 0, 0)
	webCopyBtn.BackgroundColor3 = window.accent
	webCopyBtn.BorderSizePixel = 0
	webCopyBtn.Text = ""
	webCopyBtn.AutoButtonColor = false
	webCopyBtn.ZIndex = 4
	webCopyBtn.Parent = webBody
	Corner(webCopyBtn, 6)
	local webScale = Instance.new("UIScale")
	webScale.Parent = webCopyBtn
	local webIcon = makeIcon(webCopyBtn, "copy", UDim2.new(0, 14, 0, 14), UDim2.new(0, 10, 0.5, -7), contrastOn(window.accent))
	if webIcon then webIcon.ZIndex = 5 end
	local webLabel = Instance.new("TextLabel")
	webLabel.Size = UDim2.new(1, -30, 1, 0)
	webLabel.Position = UDim2.new(0, 28, 0, 0)
	webLabel.BackgroundTransparency = 1
	webLabel.Text = "COPY LINK"
	webLabel.TextColor3 = contrastOn(window.accent)
	webLabel.TextSize = 11
	webLabel.Font = Enum.Font.GothamBold
	webLabel.ZIndex = 5
	webLabel.Parent = webCopyBtn
	window:onAccent(function(c)
		webCopyBtn.BackgroundColor3 = c
		local tc = contrastOn(c)
		webLabel.TextColor3 = tc
		if webIcon then webIcon.ImageColor3 = tc end
	end)
	webCopyBtn.MouseEnter:Connect(function() Tween(webCopyBtn, .15, { BackgroundColor3 = window.accent:Lerp(Color3.new(1,1,1), 0.15) }) end)
	webCopyBtn.MouseLeave:Connect(function() Tween(webCopyBtn, .15, { BackgroundColor3 = window.accent }) end)
	local webCopying = false
	webCopyBtn.MouseButton1Click:Connect(function()
		if webCopying then return end
		webCopying = true
		Tween(webScale, .08, { Scale = 0.92 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		task.delay(.09, function() if webScale.Parent then Tween(webScale, .12, { Scale = 1 }) end end)
		local ok = copyToClipboard(WEB_URL)
		Library:Notify(ok and "Website link copied!" or "Clipboard unavailable.", 3, "Website", ok and "check-circle" or "x-circle")
		webLabel.Text = ok and "COPIED!" or "FAILED"
		task.delay(1.2, function()
			if webLabel.Parent then webLabel.Text = "COPY LINK" end
			webCopying = false
		end)
	end)

	task.spawn(function()
		while homeTab.content.Parent do
			task.wait(1)
			if window._destroyed or Library._destroyed then return end
			if not fpsValue.Parent then return end
			fpsValue.Text = math.min(currentFps, 999) .. " FPS"
			pingValue.Text = currentPing .. " ms"
			fpsSpark:Push(currentFps, math.max(120, currentFps))
			pingSpark:Push(currentPing, math.max(200, currentPing))
			sesValue.Text = formatDuration(os.clock() - (Library.SessionStart or 0))
			local pc = #Players:GetPlayers()
			local mp = 0
			pcall(function() mp = Players.MaxPlayers end)
			sesPlayers.Text = "Players: " .. pc .. "/" .. ((mp and mp > 0) and mp or pc)
			local up = 0
			pcall(function() up = workspace.DistributedGameTime end)
			sesServer.Text = "Server up: " .. formatDuration(up)
		end
	end)
end

--// ==========================================================
--// TOOLS TAB
--// ==========================================================
if config.ToolsTab ~= false then
	local ToolsTab = window:CreateTab("Tools", "wrench")
	ToolsTab.btn.LayoutOrder = 9997
	ToolsTab.content.LayoutOrder = 9997

	ToolsTab:CreateSection("Movement")
	ToolsTab:CreateParagraph({
		Title = "Movement Tools",
		Content = "WalkSpeed, JumpPower and Infinite Jump live in the QUICK BAR (floating bar). Drag it by the header, collapse with the chevron. Its position is saved with your config.",
		Icon = "gauge",
	})

	ToolsTab:CreateSection("External Scripts")
	local TOOL_OPTIONS = {
		"♾️ Infinite Yield",
		"🖥️ Executor Editor [BETA]",
		"📌 Waypoint Manager [S.W.P]",
		"🛡️ Anti-Fling [Protection]",
		"🎭 Animation Roblox",
		"👁️ Esp Monster [Beta]",
	}
	local TOOL_URLS = {
		["♾️ Infinite Yield"] = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source",
		["🖥️ Executor Editor [BETA]"] = "https://raw.githubusercontent.com/zeutronxsite/nf5guunQd-exec/refs/heads/main/executor.luau",
		["📌 Waypoint Manager [S.W.P]"] = "https://raw.githubusercontent.com/Uo2iQnNhD/Maintenance/refs/heads/main/xtvqz7us-Waypoint.lua",
		["🛡️ Anti-Fling [Protection]"] = "https://pastebin.com/raw/MhJDcWjR",
		["🎭 Animation Roblox"] = "https://raw.githubusercontent.com/Bac0nHck/Scripts/refs/heads/main/BundleAnimations.lua",
		["👁️ Esp Monster [Beta]"] = "https://raw.githubusercontent.com/Uo2iQnNhD/Maintenance/refs/heads/main/aXXcS4rE-Esp%20Monster.lua",
	}
	local selectedToolScripts = {}
	ToolsTab:CreateMultiDropdown({
		Name = "Select Scripts", Icon = "layers", Options = TOOL_OPTIONS,
		Default = {}, Placeholder = "None selected", Flag = "RoNet_ToolScripts",
		Callback = function(list)
			selectedToolScripts = (type(list) == "table") and list or {}
		end,
	})
	ToolsTab:CreateButton({
		Name = "Execute Selected Scripts", Icon = "play",
		Confirm = { Title = "Execute Scripts", Content = "External scripts can change your game state. Run the selected scripts?", Icon = "triangle-alert" },
		Callback = function()
			if #selectedToolScripts == 0 then
				Library:Notify("Please select at least one script.", 4, "Error", "x-circle")
				return
			end
			local count = #selectedToolScripts
			Library:Notify("Executing " .. count .. " script(s)...", 4, "Status", "check")
			task.spawn(function()
				for i, name in ipairs(selectedToolScripts) do
					local url = TOOL_URLS[name]
					if url then executeRemoteScript(url, name)
					else Library:Notify("URL not found: " .. tostring(name), 4, "Error", "x-circle") end
					if i < count then task.wait(1.2) end
				end
			end)
		end,
	})

	ToolsTab:CreateSection("More Tools")

	-- Join / Leave notifications
	Library._joinLeaveEnabled = false
	local jlGui = Instance.new("ScreenGui")
	jlGui.Name = "RoNetJoinLeave"
	jlGui.ResetOnSpawn = false
	jlGui.DisplayOrder = 9990
	jlGui.IgnoreGuiInset = true
	jlGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	pcall(function() jlGui.Parent = game:GetService("CoreGui") end)
	if not jlGui.Parent then jlGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
	local jlActive, jlQueue, jlBusy = {}, {}, false
	local processQueue
	local function jlPositions()
		for i, f in ipairs(jlActive) do
			if f.Parent then
				Tween(f, 0.4, { Position = UDim2.new(1, -340, 1, -(100 + (#jlActive - i) * 90)) })
			end
		end
	end
	local function showJoinLeave(pName, pId, joining)
		local col = joining and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(255, 80, 80)
		local f = Instance.new("Frame")
		f.Size = UDim2.new(0, 320, 0, 80)
		f.Position = UDim2.new(1, 20, 1, 20)
		f.BackgroundColor3 = Color3.fromRGB(22, 22, 27)
		f.BorderSizePixel = 0
		f.Parent = jlGui
		Corner(f, 10)
		Stroke(f, col, 2)
		local av = Instance.new("ImageLabel")
		av.Size = UDim2.new(0, 50, 0, 50)
		av.Position = UDim2.new(0, 12, 0, 15)
		av.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
		av.BorderSizePixel = 0
		av.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(pId or 0) .. "&w=150&h=150"
		av.Parent = f
		Corner(av, 99)
		local t = Instance.new("TextLabel")
		t.Size = UDim2.new(1, -75, 0, 20)
		t.Position = UDim2.new(0, 72, 0, 12)
		t.BackgroundTransparency = 1
		t.Text = joining and "Joined the Server" or "Left the Server"
		t.TextColor3 = col
		t.TextSize = 14
		t.Font = Enum.Font.GothamBold
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.Parent = f
		local n = Instance.new("TextLabel")
		n.Size = UDim2.new(1, -75, 0, 20)
		n.Position = UDim2.new(0, 72, 0, 30)
		n.BackgroundTransparency = 1
		n.Text = tostring(pName)
		n.TextColor3 = Color3.fromRGB(255, 255, 255)
		n.TextSize = 15
		n.Font = Enum.Font.GothamBold
		n.TextXAlignment = Enum.TextXAlignment.Left
		n.TextTruncate = Enum.TextTruncate.AtEnd
		n.Parent = f
		local cnt = #Players:GetPlayers()
		if not joining then cnt = math.max(0, cnt - 1) end
		local mx = 99
		pcall(function() if Players.MaxPlayers > 0 then mx = Players.MaxPlayers end end)
		local iL = Instance.new("TextLabel")
		iL.Size = UDim2.new(1, -75, 0, 18)
		iL.Position = UDim2.new(0, 72, 0, 50)
		iL.BackgroundTransparency = 1
		iL.Text = string.format("Players: %d/%d | %s", cnt, mx, os.date("%H:%M:%S"))
		iL.TextColor3 = Color3.fromRGB(150, 150, 155)
		iL.TextSize = 11
		iL.Font = Enum.Font.Gotham
		iL.TextXAlignment = Enum.TextXAlignment.Left
		iL.Parent = f
		table.insert(jlActive, f)
		jlPositions()
		task.delay(4, function()
			if not f.Parent then return end
			Tween(f, 0.4, { Position = UDim2.new(1, 20, 1, 20), BackgroundTransparency = 1 })
			for _, d in ipairs({ av, t, n, iL }) do
				pcall(function()
					Tween(d, 0.4, { [d:IsA("ImageLabel") and "ImageTransparency" or "TextTransparency"] = 1 })
				end)
			end
			task.delay(0.45, function()
				if f.Parent then f:Destroy() end
				for idx, fr in ipairs(jlActive) do if fr == f then table.remove(jlActive, idx) break end end
				jlPositions()
			end)
		end)
	end
	processQueue = function()
		if jlBusy or #jlQueue == 0 then return end
		jlBusy = true
		local d = table.remove(jlQueue, 1)
		showJoinLeave(d.name, d.id, d.joining)
		task.delay(0.5, function() jlBusy = false processQueue() end)
	end
	Connect(Players.PlayerAdded, function(p)
		if not Library._joinLeaveEnabled then return end
		table.insert(jlQueue, { name = p.Name, id = p.UserId, joining = true })
		processQueue()
	end, window)
	Connect(Players.PlayerRemoving, function(p)
		if not Library._joinLeaveEnabled then return end
		table.insert(jlQueue, { name = p.Name, id = p.UserId, joining = false })
		processQueue()
	end, window)
	ToolsTab:CreateToggle({
		Name = "Player Notification", Flag = "RoNet_JoinLeave", Default = false, Icon = "users",
		Tooltip = "Show player join/leave notifications",
		Callback = function(v)
			Library._joinLeaveEnabled = v
			if v then
				table.insert(jlQueue, { name = LocalPlayer.Name .. " (You)", id = LocalPlayer.UserId, joining = true })
				processQueue()
			end
		end,
	})

	-- Built-in ESP (names kept for compatibility)
	local espOn, espObjs, espConns, espLoop = false, {}, {}, nil
	local function teamColor(p)
		local ok, t = pcall(function() return p.Team end)
		if ok and t then
			local ok2, c = pcall(function() return t.TeamColor.Color end)
			if ok2 and typeof(c) == "Color3" then return c end
		end
		return Color3.fromRGB(255, 255, 255)
	end
	local function clearESP(p)
		local d = espObjs[p]
		if d then
			pcall(function() if d.bb then d.bb:Destroy() end end)
			pcall(function() if d.hl then d.hl:Destroy() end end)
			espObjs[p] = nil
		end
		local c = espConns[p]
		if c then pcall(function() c:Disconnect() end) espConns[p] = nil end
	end
	local function clearAllESP()
		for p in pairs(espObjs) do clearESP(p) end
		for p in pairs(espConns) do clearESP(p) end
		espObjs = {}
	end
	local function makeESP(p)
		if p == LocalPlayer then return end
		local function setup(char)
			if not char then return end
			local head = char:WaitForChild("Head", 5)
			local hum = char:WaitForChild("Humanoid", 5)
			local hrp = char:WaitForChild("HumanoidRootPart", 5)
			if not head or not hum or not hrp then return end
			local c = teamColor(p)
			local old = char:FindFirstChild("PlayerESP_HL")
			if old then old:Destroy() end
			local oldBB = head:FindFirstChild("PlayerESP_GUI")
			if oldBB then oldBB:Destroy() end
			local hl = Instance.new("Highlight")
			hl.Name = "PlayerESP_HL"
			hl.FillColor = c
			hl.OutlineColor = Color3.new(0, 0, 0)
			hl.FillTransparency = 0.7
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Adornee = char
			hl.Parent = char
			local bb = Instance.new("BillboardGui")
			bb.Name = "PlayerESP_GUI"
			bb.Adornee = head
			bb.Size = UDim2.new(0, 140, 0, 46)
			bb.StudsOffset = Vector3.new(0, 3, 0)
			bb.AlwaysOnTop = true
			bb.Parent = head
			local nl = Instance.new("TextLabel")
			nl.Size = UDim2.new(1, 0, 0, 14)
			nl.BackgroundTransparency = 1
			nl.Text = p.Name
			nl.TextColor3 = c
			nl.TextStrokeTransparency = 0
			nl.Font = Enum.Font.GothamBold
			nl.TextSize = 12
			nl.Parent = bb
			local dl = Instance.new("TextLabel")
			dl.Size = UDim2.new(1, 0, 0, 12)
			dl.Position = UDim2.new(0, 0, 0, 14)
			dl.BackgroundTransparency = 1
			dl.Text = "[0m]"
			dl.TextColor3 = Color3.new(1, 1, 1)
			dl.TextStrokeTransparency = 0
			dl.Font = Enum.Font.GothamBold
			dl.TextSize = 11
			dl.Parent = bb
			local hl2 = Instance.new("TextLabel")
			hl2.Size = UDim2.new(1, 0, 0, 12)
			hl2.Position = UDim2.new(0, 0, 0, 28)
			hl2.BackgroundTransparency = 1
			hl2.Text = "HP: 100/100"
			hl2.TextColor3 = Color3.fromRGB(0, 255, 0)
			hl2.TextStrokeTransparency = 0
			hl2.Font = Enum.Font.GothamBold
			hl2.TextSize = 11
			hl2.Parent = bb
			espObjs[p] = { bb = bb, hl = hl, hum = hum, hrp = hrp, dist = dl, hp = hl2 }
		end
		if p.Character then setup(p.Character) end
		if not espConns[p] then
			espConns[p] = p.CharacterAdded:Connect(function(char)
				if espOn then task.wait(0.5) setup(char) end
			end)
		end
	end
	local function toggleESP(state)
		espOn = state
		if state then
			for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then makeESP(p) end end
			if espLoop then espLoop:Disconnect() end
			local acc = 0
			espLoop = Connect(RunService.RenderStepped, function(dt)
				acc += (tonumber(dt) or 0.016)
				if acc < 0.2 then return end
				acc = 0
				local myChar = LocalPlayer.Character
				local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
				for _, d in pairs(espObjs) do
					pcall(function()
						if d.hum and d.hum.Parent and d.hp then
							local pct = math.clamp(d.hum.Health / math.max(1, d.hum.MaxHealth), 0, 1)
							d.hp.Text = string.format("HP: %d/%d", math.floor(d.hum.Health), math.floor(d.hum.MaxHealth))
							d.hp.TextColor3 = pct > 0.6 and Color3.fromRGB(0,255,0) or (pct > 0.3 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,0,0))
						end
						if myHRP and d.hrp and d.hrp.Parent and d.dist then
							d.dist.Text = string.format("[%dm]", math.floor((myHRP.Position - d.hrp.Position).Magnitude))
						end
					end)
				end
			end, window)
		else
			if espLoop then espLoop:Disconnect() espLoop = nil end
			clearAllESP()
		end
	end
	Connect(Players.PlayerAdded, function(p) if espOn and p ~= LocalPlayer then makeESP(p) end end, window)
	Connect(Players.PlayerRemoving, function(p) clearESP(p) end, window)
	ToolsTab:CreateToggle({
		Name = "ESP Player", Flag = "ESPPlayerToggle", Default = false, Icon = "eye",
		Tooltip = "Built-in ESP with HP, distance and team color",
		Callback = function(v) toggleESP(v) end,
	})
	ToolsTab:CreateButton({
		Name = "Korblox & Headless", Icon = "gem",
		Tooltip = "Client-side only, not real",
		Confirm = { Title = "Korblox & Headless", Content = "This runs an external client-side script. Continue?", Danger = false },
		Callback = function()
			executeRemoteScript("https://raw.githubusercontent.com/Uo2iQnNhD/Maintenance/refs/heads/main/SYtg4g76-Korblox%20%26%20Headless.lua", "Korblox & Headless")
		end,
	})
end

--// ==========================================================
--// THEME TAB (+ [FIX 6] grid controls, + [FIX 8] stagger)
--// ==========================================================
if config.ThemeTab ~= false then
	local themeTab = window:CreateTab("Theme & Settings", "palette")
	themeTab.btn.LayoutOrder = 9998
	themeTab.content.LayoutOrder = 9998

	local presetNames = {}
	for k in pairs(Theme.Presets) do table.insert(presetNames, k) end
	table.sort(presetNames)

	themeTab:CreateSection("Theme Engine")
	themeTab:CreateDropdown({
		Name = "Theme Preset", Options = presetNames,
		Default = ThemeManager.PresetName, Flag = "RoNet_ThemePreset", Icon = "palette",
		Callback = function(v)
			Library:SetTheme(v)
			local rb = Library._elements["RoNet_Rainbow"]
			if rb and rb.Object and not Library._loading then
				rb.Object:Set(ThemeManager.Mode == "RGB Rainbow")
			end
		end,
	})
	themeTab:CreateToggle({
		Name = "RGB Rainbow", Flag = "RoNet_Rainbow", Default = Library.Rainbow, Icon = "activity",
		Callback = function(v) Library:SetRainbow(v) end,
	})
	themeTab:CreateColorPicker({
		Name = "Accent Color", Default = Library.Accent, Flag = "RoNet_Accent", Icon = "droplet",
		Callback = function(c) Library:SetAccent(c) end,
	})
	themeTab:CreateSlider({
		Name = "Rainbow Speed", Min = 0.02, Max = 0.5, Default = Theme.RainbowSpeed, Step = 0.01,
		Flag = "RoNet_RainbowSpeed", Icon = "activity",
		Format = function(v) return string.format("%.2f", v) end,
		Callback = function(v) Theme.RainbowSpeed = v end,
	})

	themeTab:CreateSection("Borders")
	themeTab:CreateSlider({
		Name = "Main Border Thickness", Min = 1, Max = 6, Default = Theme.MainBorderThickness, Step = 0.1,
		Flag = "RoNet_MainBorder", Icon = "border-all",
		Format = function(v) return string.format("%.1f", v) end,
		Callback = function(v)
			Theme.MainBorderThickness = v
			if mainStroke then mainStroke.Thickness = v end
			if mainGlow then mainGlow.Thickness = v + 2.4 end
		end,
	})
	themeTab:CreateSlider({
		Name = "Element Border Thickness", Min = 0.5, Max = 4, Default = Theme.ElementBorderThickness, Step = 0.1,
		Flag = "RoNet_ElemBorder", Icon = "border-inner",
		Format = function(v) return string.format("%.1f", v) end,
		Callback = function(v)
			Theme.ElementBorderThickness = v
			Theme.BorderThickness = v
			ThemeManager:RefreshWindows()
		end,
	})
	themeTab:CreateToggle({
		Name = "Border Glow", Flag = "RoNet_Glow", Default = Theme.BorderGlow, Icon = "sun",
		Callback = function(v)
			Theme.BorderGlow = v
			Library.Effects.Glow = v
			if mainGlow then mainGlow.Visible = v end
		end,
	})

	-- [FIX 6] grid terlalu tipis di HP -> sekarang bisa diatur
	themeTab:CreateSection("Grid & Effects")
	themeTab:CreateToggle({
		Name = "Grid Overlay", Flag = "RoNet_Grid", Default = Library.Effects.GridOverlay, Icon = "grid",
		Callback = function(v)
			Library.Effects.GridOverlay = v
			if gridLayer then gridLayer.Visible = v end
			if gridRelayout then pcall(gridRelayout) end
		end,
	})
	themeTab:CreateSlider({
		Name = "Grid Line Thickness", Min = 1, Max = 6, Default = Theme.GridThickness, Step = 1,
		Flag = "RoNet_GridThickness", Icon = "border-all",
		Format = function(v) return tostring(v) .. "px" end,
		Callback = function(v) Theme.GridThickness = v if gridRelayout then pcall(gridRelayout) end end,
	})
	themeTab:CreateSlider({
		Name = "Grid Visibility", Min = 0.2, Max = 0.95, Default = Theme.GridTransparency, Step = 0.01,
		Flag = "RoNet_GridTrans", Icon = "eye",
		Format = function(v) return string.format("%d%%", math.floor((1 - v) * 100)) end,
		Callback = function(v) Theme.GridTransparency = v if gridRelayout then pcall(gridRelayout) end end,
	})
	themeTab:CreateSlider({
		Name = "Grid Spacing", Min = 14, Max = 60, Default = Theme.GridSpacing, Step = 1,
		Flag = "RoNet_GridSpacing", Icon = "layout-dashboard",
		Format = function(v) return tostring(v) .. "px" end,
		Callback = function(v) Theme.GridSpacing = v if gridRelayout then pcall(gridRelayout) end end,
	})
	themeTab:CreateSlider({
		Name = "Scanline Thickness", Min = 2, Max = 8, Default = Theme.ScanThickness, Step = 1,
		Flag = "RoNet_ScanThickness", Icon = "activity",
		Format = function(v) return tostring(v) .. "px" end,
		Callback = function(v) Theme.ScanThickness = v if gridRelayout then pcall(gridRelayout) end end,
	})
	themeTab:CreateToggle({
		Name = "Floating Particles", Flag = "RoNet_Particles", Default = Library.Effects.Particles, Icon = "sparkles",
		Callback = function(v)
			Library.Effects.Particles = v
			if particleLayer then particleLayer.Visible = v end
			if dotLayer then dotLayer.Visible = v end
		end,
	})
	themeTab:CreateToggle({
		Name = "Crystals", Flag = "RoNet_Crystals", Default = Library.Effects.Crystals, Icon = "gem",
		Callback = function(v)
			Library.Effects.Crystals = v
			if crystalLayer then crystalLayer.Visible = v end
		end,
	})
	themeTab:CreateToggle({
		Name = "Button Ripple", Flag = "RoNet_Ripple", Default = Library.Effects.Ripple, Icon = "target",
		Callback = function(v) Library.Effects.Ripple = v end,
	})

	themeTab:CreateSection("Animation")
	themeTab:CreateSlider({
		Name = "Animation Speed", Min = 0.25, Max = 2.5, Default = Library.AnimationSpeed, Step = 0.05,
		Flag = "RoNet_AnimSpeed", Icon = "gauge",
		Format = function(v) return string.format("%.2fx", v) end,
		Callback = function(v) Library.AnimationSpeed = v end,
	})
	themeTab:CreateToggle({
		Name = "Stagger Load Animation", Flag = "RoNet_Stagger", Default = Library.Stagger.Enabled, Icon = "layers",
		Tooltip = "Elements appear one-by-one instead of all at once (reduces lag spikes)",
		Callback = function(v) Library.Stagger.Enabled = v end,
	})
	themeTab:CreateSlider({
		Name = "Stagger Step", Min = 0.01, Max = 0.1, Default = Library.Stagger.Step, Step = 0.005,
		Flag = "RoNet_StaggerStep", Icon = "timer",
		Format = function(v) return string.format("%.3fs", v) end,
		Callback = function(v) Library.Stagger.Step = v end,
	})

	themeTab:CreateSection("Settings")
	themeTab:CreateButton({
		Name = "Reset Frame Positions", Icon = "refresh-cw",
		Confirm = { Title = "Reset Positions", Content = "Quick Bar, Net Performance, Mini Toggle and the main window will return to their default positions.", Danger = false },
		Callback = function()
			Library:ClearFramePositions()
			Library.FramePositions = {}
			window.offset = Vector2.new(0, 0)
			main.Position = UDim2.new(0.5, 0, 0.5, 0)
			Library:Notify("Frame positions reset. Re-drag to save new ones.", 4, "Layout", "refresh-cw")
		end,
	})
	themeTab:CreateButton({
		Name = "Destroy Interface", Icon = "trash-2",
		Confirm = {
			Title = "Destroy Interface",
			Content = "This will completely remove Ro-Netrium and stop all its loops. This cannot be undone.",
			Icon = "trash-2", Danger = true, Cooldown = 3,
		},
		Callback = function()
			Library:Notify("Destroying interface...", 3, "Warning", "shield-alert")
			task.wait(0.4)
			Library:Destroy()
		end,
	})
end

--// ==========================================================
--// SAVE / LOAD TAB (+ frame positions)
--// ==========================================================
if config.SaveLoad ~= false then
	local sysTab = window:CreateTab("Save / Load", "database")
	sysTab.btn.LayoutOrder = 9999
	sysTab.content.LayoutOrder = 9999

	sysTab:CreateSection("File Manager")
	local fileNameInput = sysTab:CreateInput({
		Name = "File Name", Flag = "RoNet_FileName",
		CurrentValue = Library._saveFile or "autosave",
		PlaceholderText = "autosave", Icon = "file-text",
	})
	local fileDropdown = sysTab:CreateDropdown({
		Name = "Saved Files", Options = getSaveOptions(),
		Flag = "RoNet_SelectedSave", Icon = "folder",
	})
	sysTab:CreateButton({
		Name = "Refresh Saves", Icon = "refresh-cw",
		Callback = function()
			fileDropdown:Refresh(getSaveOptions())
			Library:Notify("Save list refreshed.", 3, "Save/Load", "refresh-cw")
		end,
	})
	sysTab:CreateButton({
		Name = "Save Current Config", Icon = "download",
		Callback = function()
			local fname = fileNameInput:Get()
			if fname == "" then fname = Library._saveFile or "autosave" end
			local ok, err = Library:SaveToFile(fname)
			if ok then
				Library._saveFile = fname
				fileDropdown:Refresh(getSaveOptions())
				fileDropdown:Set(fname)
				Library:Notify("Saved: " .. fname .. " (incl. frame positions)", 4, "Saved", "check-circle")
			else
				Library:Notify(err or "Failed to save file.", 4, "Error", "x-circle")
			end
		end,
	})
	sysTab:CreateButton({
		Name = "Overwrite Selected File", Icon = "save",
		Confirm = { Title = "Overwrite Config", Content = "The selected save file will be replaced with your current settings and frame positions.", Icon = "triangle-alert" },
		Callback = function()
			local fname = fileDropdown:Get()
			if not fname or fname == "" or fname == "(no saves)" then
				Library:Notify("Select a save file first.", 4, "Overwrite", "info")
				return
			end
			local ok, err = Library:SaveToFile(fname)
			if ok then
				Library._saveFile = fname
				fileNameInput:Set(fname)
				Library:Notify("Overwritten: " .. fname, 4, "Saved", "check-circle")
			else
				Library:Notify(err or "Failed to overwrite.", 4, "Error", "x-circle")
			end
		end,
	})
	sysTab:CreateButton({
		Name = "Load Selected File", Icon = "upload",
		Confirm = { Title = "Load Config", Content = "Your current toggles, theme and frame positions will be replaced by the selected file.", Danger = false },
		Callback = function()
			local fname = fileDropdown:Get()
			if not fname or fname == "" or fname == "(no saves)" then fname = fileNameInput:Get() end
			if not fname or fname == "" or fname == "(no saves)" then
				Library:Notify("Select a save file first.", 4, "Load", "info")
				return
			end
			local ok, err = Library:LoadFromFile(fname)
			if ok then
				fileNameInput:Set(fname)
				window:ApplyFramePositions()
				Library:Notify("Loaded: " .. fname, 4, "Loaded", "check-circle")
			else
				Library:Notify(err or "Failed to load file.", 4, "Error", "x-circle")
			end
		end,
	})
	sysTab:CreateButton({
		Name = "Delete Selected File", Icon = "trash-2",
		Confirm = { Title = "Delete Save", Content = "This permanently deletes the selected save file.", Icon = "trash-2", Danger = true },
		Callback = function()
			local fname = fileDropdown:Get()
			if not fname or fname == "" or fname == "(no saves)" then
				Library:Notify("No file selected.", 4, "Delete", "info")
				return
			end
			local ok, err = Library:DeleteSave(fname)
			if ok then
				fileDropdown:Refresh(getSaveOptions())
				Library:Notify("Deleted: " .. fname, 4, "Deleted", "trash-2")
			else
				Library:Notify(err or "Failed to delete file.", 4, "Error", "x-circle")
			end
		end,
	})

	sysTab:CreateSection("Share Config")
	sysTab:CreateButton({
		Name = "Export Config (Clipboard)", Icon = "clipboard",
		Callback = function()
			local s = Library:ExportConfigString()
			if not s then Library:Notify("Failed to encode config.", 4, "Export", "x-circle") return end
			local ok = copyToClipboard(s)
			Library:Notify(ok and "Config copied to clipboard." or "Clipboard unavailable.", 4, "Export", ok and "check-circle" or "x-circle")
		end,
	})
	local importBox = sysTab:CreateTextbox({
		Name = "Import String", Icon = "download", Placeholder = "Paste config JSON...", Flag = "RoNet_ImportStr",
	})
	sysTab:CreateButton({
		Name = "Import Config", Icon = "upload",
		Confirm = { Title = "Import Config", Content = "This will apply the pasted config string, replacing current settings.", Icon = "triangle-alert" },
		Callback = function()
			local s = importBox:Get()
			if not s or s == "" then Library:Notify("Paste a config string first.", 4, "Import", "info") return end
			local ok, err = Library:ImportConfigString(s)
			if ok then
				window:ApplyFramePositions()
				Library:Notify("Config imported.", 4, "Import", "check-circle")
			else
				Library:Notify(err or "Invalid config.", 4, "Error", "x-circle")
			end
		end,
	})

	sysTab:CreateSection("Automation")
	sysTab:CreateToggle({
		Name = "Auto Save", Flag = "RoNet_AutoSave", Default = Library.AutoSave.Enabled, Icon = "timer",
		Callback = function(v) Library.AutoSave.Enabled = v end,
	})
	sysTab:CreateSlider({
		Name = "Auto Save Interval (sec)", Min = 10, Max = 600, Default = Library.AutoSave.Interval, Step = 5,
		Flag = "RoNet_AutoSaveInterval", Icon = "clock",
		Callback = function(v) Library.AutoSave.Interval = v end,
	})
	sysTab:CreateToggle({
		Name = "Auto Load On Start", Flag = "RoNet_AutoLoad", Default = Library.AutoLoad.Enabled, Icon = "power",
		Callback = function(v)
			Library.AutoLoad.Enabled = v
			if v then performAutoLoad(0.3) end
		end,
	})
	sysTab:CreateParagraph({
		Title = "What gets saved", Icon = "info",
		Content = {
			"• All element flags (toggles, sliders, dropdowns, keybinds, colors)",
			"• Theme preset, accent, borders, grid & effect settings",
			"• Frame positions: Main Window, Quick Bar, Net Performance, Mini Toggle",
		},
	})
end

--// Restore posisi frame tersimpan (sebelum autoload supaya tidak dobel)
window:ApplyFramePositions()
if Library.AutoLoad.Enabled then performAutoLoad(1.5) end

return window
end

--// ==========================================================
--// LIBRARY DESTROY
--// ==========================================================
function Library:Destroy()
	if Library._destroyed then return end
	Library._destroyed = true
	pcall(function() Library:CloseAction() end)
	for _, w in ipairs(table.clone(Library._windows)) do
		if w and type(w.Destroy) == "function" then pcall(function() w:Destroy() end) end
	end
	Library._windows = {}
	for _, c in ipairs(Library._connections) do pcall(function() c:Disconnect() end) end
	Library._connections = {}
	Library._elements = {}
	Library._searchIndex = {}
	pcall(function() if NotifGui then NotifGui:Destroy() end end)
	pcall(function() if ActionGui then ActionGui:Destroy() end end)
	local parents = { game:GetService("CoreGui"), LocalPlayer:FindFirstChild("PlayerGui") }
	if typeof(gethui) == "function" then
		local ok, hui = pcall(gethui)
		if ok and hui then table.insert(parents, hui) end
	end
	for _, parent in ipairs(parents) do
		if parent then
			for _, child in ipairs(parent:GetChildren()) do
				if child:IsA("ScreenGui") and (child.Name == "Ro-NetriumV5" or child.Name == "RoNetNotifies"
					or child.Name == "RoNetAction" or child.Name == "RoNetJoinLeave") then
					pcall(function() child:Destroy() end)
				end
			end
		end
	end
	if type(Env) == "table" then
		Env.RoNetLibrary = nil
		Env.ZethHubLibrary = nil
	end
end

if type(Env) == "table" then
	Env.RoNetLibrary = Library
	Env.ZethHubLibrary = Library
end

return Library

--// ==========================================================
--// PART 4/4 SELESAI • SCRIPT LENGKAP (V5.9)
--// GABUNGKAN URUT: PART 1/4 + 2/4 + 3/4 + 4/4
--// JADI SATU FILE, LALU UPLOAD / EXECUTE.
--// ==========================================================
