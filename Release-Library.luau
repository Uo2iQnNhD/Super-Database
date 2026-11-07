--[[ ZETHUB - Library V5.5 Updated by Exterminate0 ]]
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

--// Anti duplicate environment
local Env = (typeof(getgenv) == "function" and getgenv()) or _G
local Generation = (type(Env) == "table" and tonumber(Env.ZethHubGeneration) or 0) + 1
if type(Env) == "table" then
	Env.ZethHubGeneration = Generation
end

local function purgeOldGuis()
	local targets = {"ZethHubV5","ZethNotifies","ZethLoadingScreen","ZethQuickBar"}
	local parents = {game:GetService("CoreGui"), LocalPlayer:FindFirstChild("PlayerGui")}
	if typeof(gethui) == "function" then
		local ok, hui = pcall(gethui)
		if ok and hui then table.insert(parents, hui) end
	end
	for _, parent in ipairs(parents) do
		if parent then
			for _, child in ipairs(parent:GetChildren()) do
				if child:IsA("ScreenGui") then
					for _, name in ipairs(targets) do
						if child.Name == name then
							pcall(function() child:Destroy() end)
						end
					end
				end
			end
		end
	end
end

local PreviousLibrary = type(Env) == "table" and Env.ZethHubLibrary or nil
if PreviousLibrary and type(PreviousLibrary.Destroy) == "function" then
	pcall(function() PreviousLibrary:Destroy() end)
end
purgeOldGuis()

local Library = {
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
	AutoSave = { Enabled = false, Interval = 60, File = "autosave" },
	AutoLoad = { Enabled = true, File = "autosave" },
	Effects = { Particles = true, Glow = true, Ripple = true, Shadow = true },
	--// V5.5 NEW
	QuickBar = { Enabled = true, Position = Vector2.new(20, 200) },
	LoadingScreen = { Enabled = true, HubName = "ZETHUB", Version = "V5.5 (2026-11-07)" },
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
	GlowTransparency = 0.68,
	RainbowSpeed = 0.12,
	ParticleCount = 28,
}

Theme.Close = Color3.fromRGB(225, 70, 70)
Theme.CloseHover = Color3.fromRGB(255, 95, 95)
Theme.ClosePressed = Color3.fromRGB(185, 45, 45)
Theme.CloseText = Color3.fromRGB(255, 255, 255)
Theme.ConfirmBackground = Color3.fromRGB(18, 18, 18)
Theme.ConfirmText = Color3.fromRGB(255, 255, 255)
Theme.ConfirmSubText = Color3.fromRGB(180, 180, 180)
Theme.Neutral = Color3.fromRGB(60, 60, 60)
Theme.NeutralHover = Color3.fromRGB(85, 85, 85)
Theme.Disabled = Color3.fromRGB(100, 100, 100)
Theme.DisabledText = Color3.fromRGB(150, 150, 150)

Library.CloseColor = Theme.Close
Library.CloseHoverColor = Theme.CloseHover
Library.ClosePressedColor = Theme.ClosePressed

Theme.Presets = {
	["Solid"] = { Rainbow = false, Accent = Color3.fromRGB(255,255,255), Colors = {
		Background = Color3.fromRGB(12,12,14), Sidebar = Color3.fromRGB(8,8,10),
		Element = Color3.fromRGB(22,22,26), ElementHover = Color3.fromRGB(32,32,38),
		Border = Color3.fromRGB(70,70,78), Text = Color3.fromRGB(255,255,255),
		SubText = Color3.fromRGB(165,165,172),
	}},
	["RGB Rainbow"] = { Rainbow = true, Colors = {
		Background = Color3.fromRGB(10,10,12), Sidebar = Color3.fromRGB(7,7,9),
		Element = Color3.fromRGB(20,20,24), ElementHover = Color3.fromRGB(30,30,36),
		Border = Color3.fromRGB(80,80,90), Text = Color3.fromRGB(255,255,255),
		SubText = Color3.fromRGB(170,170,178),
	}},
	["Neon Blue"] = { Rainbow = false, Accent = Color3.fromRGB(60,170,255), Colors = {
		Background = Color3.fromRGB(9,12,18), Sidebar = Color3.fromRGB(6,9,14),
		Element = Color3.fromRGB(18,24,34), ElementHover = Color3.fromRGB(28,38,54),
		Border = Color3.fromRGB(55,90,130), Text = Color3.fromRGB(240,248,255),
		SubText = Color3.fromRGB(150,175,200),
	}},
	["Emerald"] = { Rainbow = false, Accent = Color3.fromRGB(46,230,110), Colors = {
		Background = Color3.fromRGB(10,14,12), Sidebar = Color3.fromRGB(7,10,9),
		Element = Color3.fromRGB(18,26,22), ElementHover = Color3.fromRGB(28,40,34),
		Border = Color3.fromRGB(50,90,70), Text = Color3.fromRGB(240,255,245),
		SubText = Color3.fromRGB(150,190,165),
	}},
	["Sunset"] = { Rainbow = false, Accent = Color3.fromRGB(255,120,60), Colors = {
		Background = Color3.fromRGB(16,11,12), Sidebar = Color3.fromRGB(11,8,9),
		Element = Color3.fromRGB(28,20,22), ElementHover = Color3.fromRGB(42,30,34),
		Border = Color3.fromRGB(100,60,55), Text = Color3.fromRGB(255,245,240),
		SubText = Color3.fromRGB(200,160,150),
	}},
	["Ocean"] = { Rainbow = false, Accent = Color3.fromRGB(40,210,220), Colors = {
		Background = Color3.fromRGB(8,14,16), Sidebar = Color3.fromRGB(5,10,12),
		Element = Color3.fromRGB(16,26,30), ElementHover = Color3.fromRGB(24,38,44),
		Border = Color3.fromRGB(45,95,105), Text = Color3.fromRGB(235,255,255),
		SubText = Color3.fromRGB(145,185,190),
	}},
	["Violet"] = { Rainbow = false, Accent = Color3.fromRGB(170,90,255), Colors = {
		Background = Color3.fromRGB(13,10,18), Sidebar = Color3.fromRGB(9,7,13),
		Element = Color3.fromRGB(24,18,34), ElementHover = Color3.fromRGB(36,28,50),
		Border = Color3.fromRGB(85,60,120), Text = Color3.fromRGB(248,240,255),
		SubText = Color3.fromRGB(180,160,205),
	}},
	["Crimson"] = { Rainbow = false, Accent = Color3.fromRGB(255,70,90), Colors = {
		Background = Color3.fromRGB(16,9,11), Sidebar = Color3.fromRGB(11,6,8),
		Element = Color3.fromRGB(30,16,20), ElementHover = Color3.fromRGB(44,24,30),
		Border = Color3.fromRGB(110,45,55), Text = Color3.fromRGB(255,240,242),
		SubText = Color3.fromRGB(205,150,158),
	}},
	["Gold"] = { Rainbow = false, Accent = Color3.fromRGB(255,200,70), Colors = {
		Background = Color3.fromRGB(15,13,9), Sidebar = Color3.fromRGB(10,9,6),
		Element = Color3.fromRGB(28,24,16), ElementHover = Color3.fromRGB(42,36,24),
		Border = Color3.fromRGB(105,88,45), Text = Color3.fromRGB(255,250,235),
		SubText = Color3.fromRGB(205,190,150),
	}},
	["Cyberpunk"] = { Rainbow = false, Accent = Color3.fromRGB(255,40,200), Colors = {
		Background = Color3.fromRGB(10,8,16), Sidebar = Color3.fromRGB(6,5,11),
		Element = Color3.fromRGB(20,14,32), ElementHover = Color3.fromRGB(32,22,50),
		Border = Color3.fromRGB(90,40,130), Text = Color3.fromRGB(255,240,255),
		SubText = Color3.fromRGB(190,150,210),
	}},
	["Toxic"] = { Rainbow = false, Accent = Color3.fromRGB(170,255,60), Colors = {
		Background = Color3.fromRGB(10,13,8), Sidebar = Color3.fromRGB(7,9,5),
		Element = Color3.fromRGB(18,24,14), ElementHover = Color3.fromRGB(28,38,22),
		Border = Color3.fromRGB(65,95,40), Text = Color3.fromRGB(240,255,230),
		SubText = Color3.fromRGB(160,190,135),
	}},
	["Sakura"] = { Rainbow = false, Accent = Color3.fromRGB(255,140,190), Colors = {
		Background = Color3.fromRGB(16,11,14), Sidebar = Color3.fromRGB(11,8,10),
		Element = Color3.fromRGB(30,20,26), ElementHover = Color3.fromRGB(44,30,38),
		Border = Color3.fromRGB(110,70,90), Text = Color3.fromRGB(255,242,248),
		SubText = Color3.fromRGB(205,165,185),
	}},
	["Ice"] = { Rainbow = false, Accent = Color3.fromRGB(150,220,255), Colors = {
		Background = Color3.fromRGB(10,13,16), Sidebar = Color3.fromRGB(7,9,12),
		Element = Color3.fromRGB(18,24,30), ElementHover = Color3.fromRGB(28,38,46),
		Border = Color3.fromRGB(60,95,120), Text = Color3.fromRGB(240,250,255),
		SubText = Color3.fromRGB(160,185,205),
	}},
	["Blood Moon"] = { Rainbow = false, Accent = Color3.fromRGB(220,40,60), Colors = {
		Background = Color3.fromRGB(12,7,8), Sidebar = Color3.fromRGB(8,5,6),
		Element = Color3.fromRGB(24,12,15), ElementHover = Color3.fromRGB(38,20,24),
		Border = Color3.fromRGB(95,35,45), Text = Color3.fromRGB(255,235,238),
		SubText = Color3.fromRGB(195,140,148),
	}},
	["Forest"] = { Rainbow = false, Accent = Color3.fromRGB(90,200,120), Colors = {
		Background = Color3.fromRGB(9,12,10), Sidebar = Color3.fromRGB(6,8,7),
		Element = Color3.fromRGB(16,22,18), ElementHover = Color3.fromRGB(26,34,28),
		Border = Color3.fromRGB(45,80,58), Text = Color3.fromRGB(238,255,244),
		SubText = Color3.fromRGB(150,185,160),
	}},
	["Royal"] = { Rainbow = false, Accent = Color3.fromRGB(120,90,255), Colors = {
		Background = Color3.fromRGB(11,10,17), Sidebar = Color3.fromRGB(7,7,12),
		Element = Color3.fromRGB(20,18,32), ElementHover = Color3.fromRGB(32,28,50),
		Border = Color3.fromRGB(75,65,125), Text = Color3.fromRGB(245,242,255),
		SubText = Color3.fromRGB(170,165,210),
	}},
	["Amber"] = { Rainbow = false, Accent = Color3.fromRGB(255,170,50), Colors = {
		Background = Color3.fromRGB(15,12,8), Sidebar = Color3.fromRGB(10,8,5),
		Element = Color3.fromRGB(28,22,14), ElementHover = Color3.fromRGB(42,34,22),
		Border = Color3.fromRGB(105,80,40), Text = Color3.fromRGB(255,248,235),
		SubText = Color3.fromRGB(205,180,140),
	}},
	["Mono"] = { Rainbow = false, Accent = Color3.fromRGB(210,210,210), Colors = {
		Background = Color3.fromRGB(14,14,14), Sidebar = Color3.fromRGB(9,9,9),
		Element = Color3.fromRGB(24,24,24), ElementHover = Color3.fromRGB(34,34,34),
		Border = Color3.fromRGB(70,70,70), Text = Color3.fromRGB(245,245,245),
		SubText = Color3.fromRGB(160,160,160),
	}},
	["Lava"] = { Rainbow = false, Accent = Color3.fromRGB(255,90,30), Colors = {
		Background = Color3.fromRGB(14,8,6), Sidebar = Color3.fromRGB(9,5,4),
		Element = Color3.fromRGB(26,14,10), ElementHover = Color3.fromRGB(40,22,16),
		Border = Color3.fromRGB(100,45,30), Text = Color3.fromRGB(255,240,230),
		SubText = Color3.fromRGB(200,150,130),
	}},
	["Mint"] = { Rainbow = false, Accent = Color3.fromRGB(80,240,190), Colors = {
		Background = Color3.fromRGB(9,14,13), Sidebar = Color3.fromRGB(6,10,9),
		Element = Color3.fromRGB(16,26,24), ElementHover = Color3.fromRGB(24,38,35),
		Border = Color3.fromRGB(45,95,85), Text = Color3.fromRGB(235,255,250),
		SubText = Color3.fromRGB(145,190,180),
	}},
	["Peach"] = { Rainbow = false, Accent = Color3.fromRGB(255,155,120), Colors = {
		Background = Color3.fromRGB(16,12,11), Sidebar = Color3.fromRGB(11,8,7),
		Element = Color3.fromRGB(30,22,20), ElementHover = Color3.fromRGB(44,32,29),
		Border = Color3.fromRGB(110,75,68), Text = Color3.fromRGB(255,245,240),
		SubText = Color3.fromRGB(205,170,160),
	}},
}

Library._confirmOpen = false
Library._buttonPressLock = false

local H_ELEMENT = 38
local H_SLIDER = 46
local H_SECTION = 20
local H_TAB = 34
local TOPBAR_H = 58

--// Lucide Icons + fallback
Library.Lucide = {}
Library.LucideRect = {}
local fallbackIcons = {
	["home"]="rbxassetid://7733960981",["settings"]="rbxassetid://7734053495",
	["settings-2"]="rbxassetid://8997386997",["shield"]="rbxassetid://7734056608",
	["shield-check"]="rbxassetid://7734056411",["key"]="rbxassetid://7733965118",
	["gamepad-2"]="rbxassetid://7733799795",["folder"]="rbxassetid://7733799185",
	["file-text"]="rbxassetid://7733789088",["palette"]="rbxassetid://7734021595",
	["wrench"]="rbxassetid://7743878358",["hammer"]="rbxassetid://7733955511",
	["heart"]="rbxassetid://7733956134",["star"]="rbxassetid://7734068321",
	["check"]="rbxassetid://7733715400",["x"]="rbxassetid://7743878857",
	["search"]="rbxassetid://7734052925",["globe"]="rbxassetid://7733954760",
	["cpu"]="rbxassetid://7733765045",["activity"]="rbxassetid://7733655755",
	["gauge"]="rbxassetid://7733799969",["map-pin"]="rbxassetid://7733992789",
	["eye"]="rbxassetid://7733774602",["eye-off"]="rbxassetid://7733774495",
	["lock"]="rbxassetid://7733992528",["unlock"]="rbxassetid://7743875263",
	["send"]="rbxassetid://7734053039",["message-square"]="rbxassetid://7733993369",
	["download"]="rbxassetid://7733770755",["upload"]="rbxassetid://7743875428",
	["refresh-cw"]="rbxassetid://7734051052",["play"]="rbxassetid://7743871480",
	["pause"]="rbxassetid://7734021897",["music"]="rbxassetid://7734020554",
	["image"]="rbxassetid://7733964126",["camera"]="rbxassetid://7733708692",
	["mail"]="rbxassetid://7733992732",["wifi"]="rbxassetid://7743878148",
	["sun"]="rbxassetid://7734068495",["moon"]="rbxassetid://7743870134",
	["cloud"]="rbxassetid://7733746980",["flame"]="rbxassetid://7733798747",
	["crown"]="rbxassetid://7733765398",["gem"]="rbxassetid://7733942651",
	["banknote"]="rbxassetid://7733674153",["shopping-cart"]="rbxassetid://7734056813",
	["gift"]="rbxassetid://7733946818",["package"]="rbxassetid://7734021469",
	["box"]="rbxassetid://7733917120",["trash-2"]="rbxassetid://7743873772",
	["pencil"]="rbxassetid://7734022107",["clipboard"]="rbxassetid://7733734762",
	["book-open"]="rbxassetid://7733687281",["calendar"]="rbxassetid://7733919198",
	["timer"]="rbxassetid://7743873443",["alarm-clock"]="rbxassetid://7733656100",
	["watch"]="rbxassetid://7743877668",["megaphone"]="rbxassetid://7733993049",
	["monitor"]="rbxassetid://7734002839",["smartphone"]="rbxassetid://7734058979",
	["laptop"]="rbxassetid://7733965386",["database"]="rbxassetid://7743866778",
	["server"]="rbxassetid://7734053426",["link"]="rbxassetid://7733978098",
	["external-link"]="rbxassetid://7743866903",["qr-code"]="rbxassetid://7743871575",
	["scan"]="rbxassetid://8997386861",["flag"]="rbxassetid://7733798691",
	["compass"]="rbxassetid://7733924216",["map"]="rbxassetid://7733992829",
	["navigation"]="rbxassetid://7734020989",["crosshair"]="rbxassetid://7733765307",
	["target"]="rbxassetid://7743872758",["bell"]="rbxassetid://7733911828",
	["bell-ring"]="rbxassetid://7733675275",["info"]="rbxassetid://7733964719",
	["terminal"]="rbxassetid://7743872929",["check-circle"]="rbxassetid://7733919427",
	["x-circle"]="rbxassetid://7743878496",["help-circle"]="rbxassetid://7733956210",
	["user"]="rbxassetid://7743875962",["users"]="rbxassetid://7743876054",
	["chevron-down"]="rbxassetid://7733717447",["chevron-right"]="rbxassetid://7733717755",
	["chevron-left"]="rbxassetid://7733717651",["chevron-up"]="rbxassetid://7733919605",
	["log-out"]="rbxassetid://7733992677",["log-in"]="rbxassetid://7733992604",
	["power"]="rbxassetid://7734042493",["toggle-left"]="rbxassetid://7734091286",
	["toggle-right"]="rbxassetid://7743873539",["type"]="rbxassetid://7743874740",
	["menu"]="rbxassetid://7733993211",["layout-dashboard"]="rbxassetid://7733970318",
	["grid"]="rbxassetid://7733955179",["sidebar"]="rbxassetid://7734058260",
	["shovel"]="rbxassetid://7734056878",["sliders"]="rbxassetid://7734058803",
	["coin"]="rbxassetid://7743866529",["wallet"]="rbxassetid://7743877573",
	["piggy-bank"]="rbxassetid://7734034513",["ticket"]="rbxassetid://7734086558",
	["badge-check"]="rbxassetid://7743875503",["badge"]="rbxassetid://7733692043",
	["award"]="rbxassetid://7733673987",["battery"]="rbxassetid://7733674820",
	["battery-charging"]="rbxassetid://7733674402",["lightbulb"]="rbxassetid://7733975185",
	["locate"]="rbxassetid://7733992469",["locate-fixed"]="rbxassetid://7733992424",
	["house"]="rbxassetid://7733960981",["gear"]="rbxassetid://7734053495",
	["dashboard"]="rbxassetid://7733970318",["sliders-horizontal"]="rbxassetid://7734058803",
	["sparkles"]="rbxassetid://7734068321",["droplet"]="rbxassetid://7734021595",
	["border-all"]="rbxassetid://7733955179",["border-inner"]="rbxassetid://7734058260",
	["clock"]="rbxassetid://7743873443",["save"]="rbxassetid://7733770755",
	["load"]="rbxassetid://7743875428",["theme"]="rbxassetid://7734021595",
	["layers"]="rbxassetid://7733917120",["copy"]="rbxassetid://7733734762",
	["list"]="rbxassetid://7733789088",
	-- V5.5 new icons
	["zap"]="rbxassetid://7733799795",["rocket"]="rbxassetid://7733798747",
	["footprints"]="rbxassetid://7733655755",["shield-alert"]="rbxassetid://7734056608",
	["loader"]="rbxassetid://7734051052",["skip-forward"]="rbxassetid://7743871480",
	["grip-vertical"]="rbxassetid://7734058803",["move"]="rbxassetid://7733924216",
	["hash"]="rbxassetid://7743874740",["at-sign"]="rbxassetid://7733992732",
	["server-cog"]="rbxassetid://7734053426",["gamepad"]="rbxassetid://7733799795",
	["timer-off"]="rbxassetid://7743873443",["activity"]="rbxassetid://7733655755",
	["signal"]="rbxassetid://7743878148",["wifi-off"]="rbxassetid://7743878148",
	["circle-dot"]="rbxassetid://7733942651",["square"]="rbxassetid://7733917120",
	["minimize-2"]="rbxassetid://7733717651",["maximize-2"]="rbxassetid://7733717755",
	["chevrons-up-down"]="rbxassetid://7733717447",
}
for name, asset in pairs(fallbackIcons) do
	Library.Lucide[name] = asset
end

local IconCache = (type(Env) == "table" and Env.ZethHubIconCache) or { Loaded = false, Lucide = {}, Rect = {} }
if type(Env) == "table" then Env.ZethHubIconCache = IconCache end
for name, asset in pairs(IconCache.Lucide) do Library.Lucide[name] = asset end
for name, rect in pairs(IconCache.Rect) do Library.LucideRect[name] = rect end

local function fetchRayfieldIconSource()
	local url = "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua"
	local ok, body = pcall(function() return game:HttpGet(url) end)
	if ok and type(body) == "string" and #body > 0 then return body end
	local requestFunc = (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request) or http_request or request
	if requestFunc then
		local okReq, res = pcall(function() return requestFunc({ Url = url, Method = "GET" }) end)
		if okReq and type(res) == "table" and type(res.Body) == "string" and #res.Body > 0 then return res.Body end
	end
	return nil
end

local function loadRayfieldIcons()
	if IconCache.Loaded then return end
	IconCache.Loaded = true
	local source = fetchRayfieldIconSource()
	if not source then warn("[ZethHub] Gagal memuat Rayfield icons.lua, memakai fallback icon.") return end
	local ok, Icons = pcall(function() return loadstring(source)() end)
	if not ok or type(Icons) ~= "table" then warn("[ZethHub] Rayfield icons.lua gagal dieksekusi.") return end
	local iconTable = Icons["48px"] or Icons
	for name, data in pairs(iconTable) do
		if type(name) == "string" and type(data) == "table" then
			local assetId, rectSize, rectOffset = data[1], data[2], data[3]
			if type(assetId) == "number" and type(rectSize) == "table" and type(rectOffset) == "table"
				and rectSize[1] and rectSize[2] and rectOffset[1] and rectOffset[2] then
				local asset = "rbxassetid://" .. assetId
				local rect = { ImageRectOffset = Vector2.new(rectOffset[1], rectOffset[2]), ImageRectSize = Vector2.new(rectSize[1], rectSize[2]) }
				IconCache.Lucide[name] = asset; IconCache.Rect[name] = rect
				Library.Lucide[name] = asset; Library.LucideRect[name] = rect
			end
		end
	end
end
loadRayfieldIcons()

local function resolveIcon(icon)
	if icon == nil or icon == false or icon == 0 or icon == "" then return nil, nil, nil end
	if type(icon) == "number" then return "rbxassetid://" .. icon, nil, nil end
	if type(icon) == "string" then
		if icon:sub(1,12)=="rbxassetid://" or icon:sub(1,10)=="rbxasset://" or icon:sub(1,11)=="rbxthumb://"
			or icon:sub(1,7)=="http://" or icon:sub(1,8)=="https://" then return icon, nil, nil end
		local key = string.match(string.lower(icon), "^%s*(.-)%s*$")
		local asset = Library.Lucide[key]; local rect = Library.LucideRect[key]
		if not asset or asset == "" then asset = Library.Lucide["info"]; rect = Library.LucideRect["info"] end
		return asset, rect and rect.ImageRectOffset, rect and rect.ImageRectSize
	end
	return nil, nil, nil
end

local function setIcon(instance, icon)
	if not instance or not (instance:IsA("ImageLabel") or instance:IsA("ImageButton")) then return end
	local asset, offset, size = resolveIcon(icon)
	instance.Image = asset or ""
	if offset and size then instance.ImageRectOffset = offset; instance.ImageRectSize = size
	else instance.ImageRectOffset = Vector2.new(0,0); instance.ImageRectSize = Vector2.new(0,0) end
end

local function makeIcon(parent, icon, size, pos, color)
	local asset, offset, rectSize = resolveIcon(icon)
	if not asset or asset == "" then return nil end
	local im = Instance.new("ImageLabel")
	im.Name = "Icon"; im.Size = size or UDim2.new(0,16,0,16)
	im.Position = pos or UDim2.new(0,12,0.5,-8)
	im.BackgroundTransparency = 1; im.Image = asset; im.ImageColor3 = color or Theme.Text
	if offset and rectSize then im.ImageRectOffset = offset; im.ImageRectSize = rectSize end
	im.Parent = parent; return im
end

local function Tween(obj, dur, props, style, dir)
	local speed = math.max(0.05, tonumber(Library.AnimationSpeed) or 1)
	local info = TweenInfo.new((dur or .3)/speed, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
	local tw = TweenService:Create(obj, info, props); tw:Play(); return tw
end
local function Corner(p, r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 7); c.Parent=p; return c end
local function Stroke(p, col, th) local s=Instance.new("UIStroke"); s.Color=col or Theme.Border; s.Thickness=th or Theme.BorderThickness; s.Transparency=Theme.BorderTransparency or 0; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=p; return s end
local function Pad(p, t, l, b, r) local d=Instance.new("UIPadding"); d.PaddingTop=UDim.new(0,t or 0); d.PaddingLeft=UDim.new(0,l or 0); d.PaddingBottom=UDim.new(0,b or 0); d.PaddingRight=UDim.new(0,r or 0); d.Parent=p; return d end

local function isPressInput(inp)
	return inp ~= nil and (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch)
end

local function playCloseBlur(btn, overlay, scale, lines, pressColor, textColor)
	if not btn or not btn.Parent then return end
	if overlay and overlay.Parent then
		overlay.Visible = true; overlay.Size = UDim2.new(0,0,0,0)
		overlay.BackgroundColor3 = pressColor or Theme.ClosePressed; overlay.BackgroundTransparency = 0.12
		Tween(overlay, 0.34, {Size=UDim2.new(0,76,0,76), BackgroundTransparency=1}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		task.delay(0.35, function() if overlay and overlay.Parent then overlay.Visible = false end end)
	end
	if scale and scale.Parent then Tween(scale, 0.08, {Scale=0.82}, Enum.EasingStyle.Back, Enum.EasingDirection.In) end
	Tween(btn, 0.08, {BackgroundColor3 = pressColor or Theme.ClosePressed})
	if lines then for _, l in ipairs(lines) do if l and l.Parent then Tween(l, 0.08, {BackgroundColor3 = textColor or Theme.CloseText}) end end end
end

local function Connect(signal, callback, owner)
	local conn
	conn = signal:Connect(function(...)
		if Library._destroyed or (type(Env)=="table" and Env.ZethHubGeneration ~= Library.Generation) then
			pcall(function() if conn then conn:Disconnect() end end); return
		end
		if owner and owner._destroyed then pcall(function() if conn then conn:Disconnect() end end); return end
		callback(...)
	end)
	table.insert(Library._connections, conn)
	if owner and owner._connections then table.insert(owner._connections, conn) end
	return conn
end

function Library:GetFlag(flag) return Library.Flags[flag] end

--// FPS / Ping global
local fpsFrames, fpsLast = 0, os.clock()
Connect(RunService.RenderStepped, function() fpsFrames += 1 end)
local currentFps, currentPing = 0, 0
local sessionStart = os.clock()
task.spawn(function()
	while true do
		task.wait(1)
		if Library._destroyed or (type(Env)=="table" and Env.ZethHubGeneration ~= Library.Generation) then return end
		local now = os.clock()
		currentFps = math.floor(fpsFrames / math.max(now - fpsLast, 0.0001))
		fpsFrames, fpsLast = 0, now
		pcall(function() currentPing = math.floor(LocalPlayer:GetNetworkPing() * 1000) end)
	end
end)

--// Theme / RGB Rainbow Engine
local ThemeManager = { Mode = Library.Rainbow and "RGB Rainbow" or "Solid", Time = 0, Dirty = true, Gradients = {}, Strokes = {}, _onChangeCallbacks = {} }
local function rainbowSeq()
	return ColorSequence.new{
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
		ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255,150,0)),
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,120)),
		ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,200,255)),
		ColorSequenceKeypoint.new(0.66, Color3.fromRGB(80,80,255)),
		ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,200)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,0)),
	}
end
local function accentSeq(c)
	c = (typeof(c)=="Color3" and c) or Color3.new(1,1,1)
	return ColorSequence.new{
		ColorSequenceKeypoint.new(0, c:Lerp(Color3.new(0,0,0),.45)),
		ColorSequenceKeypoint.new(.5, c:Lerp(Color3.new(1,1,1),.2)),
		ColorSequenceKeypoint.new(1, c:Lerp(Color3.new(0,0,0),.45)),
	}
end
local function currentRainbowColor(offset)
	offset = tonumber(offset) or 0
	local speed = tonumber(Theme.RainbowSpeed) or 0.12
	local hue = ((ThemeManager.Time * speed) + offset) % 1
	return Color3.fromHSV(hue, 1, 1)
end
function ThemeManager:GetColor(offset)
	if ThemeManager.Mode == "RGB Rainbow" then return currentRainbowColor(offset) end
	return Library.Accent
end
local function refreshRGBColors()
	for i = #ThemeManager.Gradients, 1, -1 do
		local g = ThemeManager.Gradients[i]
		if g and g.Parent then g.Color = ThemeManager.Mode=="RGB Rainbow" and rainbowSeq() or accentSeq(Library.Accent)
		else table.remove(ThemeManager.Gradients, i) end
	end
end
function ThemeManager:NotifyWindows()
	for _, w in ipairs(Library._windows) do
		if w and not w._destroyed then
			w.accent = Library.Accent
			if type(w.listeners)=="table" then for _, fn in ipairs(w.listeners) do pcall(fn, w.accent) end end
		end
	end
end
function ThemeManager:RefreshWindows()
	for _, w in ipairs(Library._windows) do
		if w and not w._destroyed and type(w.ApplyTheme)=="function" then pcall(function() w:ApplyTheme() end) end
	end
end
-- V5.5: fire theme-change callbacks (loading screen, quick bar, particles, etc.)
function ThemeManager:FireChange()
	for _, fn in ipairs(ThemeManager._onChangeCallbacks) do pcall(fn) end
end
function ThemeManager:OnChange(fn) table.insert(ThemeManager._onChangeCallbacks, fn) end
function ThemeManager:Update()
	if ThemeManager.Mode == "RGB Rainbow" then
		Library.Accent = currentRainbowColor(0)
		refreshRGBColors(); ThemeManager:NotifyWindows(); ThemeManager.Dirty = false
	elseif ThemeManager.Dirty then
		refreshRGBColors(); ThemeManager:NotifyWindows(); ThemeManager.Dirty = false
	end
end
function ThemeManager:SetMode(mode)
	ThemeManager.Mode = mode; Library.Rainbow = (mode == "RGB Rainbow")
	if not Library.Rainbow and typeof(Library.Accent) ~= "Color3" then Library.Accent = Color3.new(1,1,1) end
	ThemeManager.Dirty = true; ThemeManager:Update(); ThemeManager:FireChange()
end
local function registerRGB(parent)
	if not parent then return nil end
	if parent:IsA("UIStroke") then
		local data = { obj = parent, offset = math.random() }
		table.insert(ThemeManager.Strokes, data)
		parent.Color = ThemeManager.Mode=="RGB Rainbow" and currentRainbowColor(data.offset) or Library.Accent
		return parent
	end
	local g = Instance.new("UIGradient")
	g.Color = ThemeManager.Mode=="RGB Rainbow" and rainbowSeq() or accentSeq(Library.Accent)
	g.Rotation = 35; g.Parent = parent; table.insert(ThemeManager.Gradients, g); return g
end
local strokeAcc, gradientAcc, accentAcc = 0, 0, 0
Connect(RunService.RenderStepped, function(dt)
	dt = tonumber(dt) or 0.016; ThemeManager.Time += dt
	strokeAcc += dt
	if strokeAcc >= 0.03 then
		strokeAcc = 0
		for i = #ThemeManager.Strokes, 1, -1 do
			local data = ThemeManager.Strokes[i]
			if data.obj and data.obj.Parent then
				data.obj.Color = ThemeManager.Mode=="RGB Rainbow" and currentRainbowColor(data.offset + ThemeManager.Time*0.08) or Library.Accent
			else table.remove(ThemeManager.Strokes, i) end
		end
	end
	gradientAcc += dt
	if gradientAcc >= 0.04 then
		gradientAcc = 0
		local off = (ThemeManager.Time * 0.18) % 1
		local rot = 35 + math.sin(ThemeManager.Time * 0.7) * 12
		for i = #ThemeManager.Gradients, 1, -1 do
			local g = ThemeManager.Gradients[i]
			if g and g.Parent then g.Offset = Vector2.new(off,0); g.Rotation = rot
			else table.remove(ThemeManager.Gradients, i) end
		end
	end
	accentAcc += dt
	if accentAcc >= 0.10 then accentAcc = 0; ThemeManager:Update() end
end)
function Library:SetRainbow(on) ThemeManager:SetMode(on and "RGB Rainbow" or "Solid") end
function Library:SetAccent(c)
	if typeof(c) ~= "Color3" then return end
	Library.Accent = c; ThemeManager.Dirty = true
	if ThemeManager.Mode ~= "RGB Rainbow" then ThemeManager:Update() end
	ThemeManager:FireChange()
end
function Library:SetTheme(name)
	local preset = Theme.Presets[name]
	if not preset then return false end
	if type(preset.Colors)=="table" then for k,v in pairs(preset.Colors) do Theme[k]=v end end
	if preset.Accent then Library.Accent = preset.Accent end
	if preset.Rainbow ~= nil then ThemeManager:SetMode(preset.Rainbow and "RGB Rainbow" or "Solid")
	else ThemeManager.Dirty = true; ThemeManager:Update() end
	ThemeManager:RefreshWindows()
	ThemeManager:FireChange() -- V5.5: propagate to particles, loading screen, quick bar
	return true
end

--// Moving Particle Background (V5.5: follows theme accent + background)
local function createParticleBackground(parent, count, owner)
	if not Library.Effects.Particles then return nil end
	count = math.clamp(tonumber(count) or Theme.ParticleCount or 28, 0, 80)
	if count == 0 then return nil end
	local layer = Instance.new("Frame")
	layer.Name = "ParticleBackground"; layer.Size = UDim2.new(1,0,1,0)
	layer.BackgroundTransparency = 1; layer.BorderSizePixel = 0; layer.ClipsDescendants = true
	layer.ZIndex = 40; layer.Parent = parent
	local particles = {}
	for _ = 1, count do
		local size = math.random(2,6)
		local p = Instance.new("Frame")
		p.Name = "Particle"; p.AnchorPoint = Vector2.new(0.5,0.5)
		p.Size = UDim2.new(0,size,0,size); p.Position = UDim2.new(math.random(),0,math.random(),0)
		p.BackgroundColor3 = Library.Accent; p.BackgroundTransparency = math.random(55,88)/100
		p.BorderSizePixel = 0; p.ZIndex = 40; p.Active = false; p.Parent = layer
		Corner(p, 99)
		table.insert(particles, { f=p, x=nil, y=nil, initialized=false,
			vx=(math.random()-0.5)*18, vy=(math.random()-0.5)*18,
			baseT=p.BackgroundTransparency, phase=math.random()*math.pi*2,
			speed=0.8+math.random()*1.2, hueOffset=math.random() })
	end
	local lastColorUpdate = 0
	Connect(RunService.RenderStepped, function(dt)
		if not layer or not layer.Parent then return end
		dt = tonumber(dt) or 0.016
		local sz = layer.AbsoluteSize; if sz.X<=1 or sz.Y<=1 then return end
		local t = os.clock(); local updateColor = false
		if t - lastColorUpdate > 0.10 then updateColor = true; lastColorUpdate = t end
		for _, d in ipairs(particles) do
			if d.f and d.f.Parent then
				if not d.initialized then d.x=math.random()*sz.X; d.y=math.random()*sz.Y; d.initialized=true end
				d.x += d.vx*dt; d.y += d.vy*dt
				if d.x<-12 then d.x=sz.X+12 elseif d.x>sz.X+12 then d.x=-12 end
				if d.y<-12 then d.y=sz.Y+12 elseif d.y>sz.Y+12 then d.y=-12 end
				d.f.Position = UDim2.new(0,d.x,0,d.y)
				local pulse = 0.5+0.5*math.sin(t*d.speed+d.phase)
				d.f.BackgroundTransparency = math.clamp(d.baseT - pulse*0.18, 0.05, 0.95)
				if updateColor then
					d.f.BackgroundColor3 = ThemeManager.Mode=="RGB Rainbow" and currentRainbowColor(d.hueOffset) or Library.Accent
				end
			end
		end
	end, owner)
	-- V5.5: react to theme change immediately
	ThemeManager:OnChange(function()
		if not layer or not layer.Parent then return end
		for _, d in ipairs(particles) do
			if d.f and d.f.Parent then
				d.f.BackgroundColor3 = ThemeManager.Mode=="RGB Rainbow" and currentRainbowColor(d.hueOffset) or Library.Accent
			end
		end
	end)
	return layer
end

--// Search Registry
function Library:_RegisterSearch(data)
	if Library._destroyed then return end
	data.Index = #Library._searchIndex + 1; data._removed = false
	table.insert(Library._searchIndex, data)
end
function Library:Search(query)
	query = string.lower(tostring(query or "")); local out = {}
	if query == "" then return out end
	for _, item in ipairs(Library._searchIndex) do
		if not item._removed then
			if item.Window and item.Window._destroyed then -- skip
			elseif item.Frame and not item.Frame.Parent then -- skip
			else
				local keywords = ""
				if type(item.Keywords)=="table" then for _, v in ipairs(item.Keywords) do keywords = keywords.." "..tostring(v) end end
				local hay = string.lower(table.concat({ tostring(item.Name or""), tostring(item.Type or""), tostring(item.TabName or""), tostring(item.Flag or""), keywords }, " "))
				if string.find(hay, query, 1, true) then table.insert(out, item) end
			end
		end
	end
	table.sort(out, function(a,b) return string.len(tostring(a.Name or"")) < string.len(tostring(b.Name or"")) end)
	return out
end
local function registerElement(windowRef, tabRef, tabName, frameRef, cfgRef, elementType, objRef)
	cfgRef = cfgRef or {}
	local displayName = cfgRef.Name or cfgRef.Title or elementType
	local flag = cfgRef.Flag
	if flag and flag ~= "" then
		Library._elements[flag] = { Type=elementType, Object=objRef, Name=displayName, Tab=tabRef, TabName=tabName, Frame=frameRef, Window=windowRef, Config=cfgRef }
	end
	Library:_RegisterSearch({ Name=displayName, Type=elementType, Tab=tabRef, TabName=tabName, Frame=frameRef, Flag=flag, Keywords=cfgRef.Keywords, Window=windowRef })
	return objRef
end

--// Save / Load System
local SAVE_FOLDER = "ZethHub/Saves"
local function sanitizeFileName(name)
	name = tostring(name or "autosave"); name = name:gsub("[^%w_%-%.]","_"); name = name:gsub("^_+",""):gsub("_+$","")
	if name=="" then name="autosave" end; if #name>64 then name=name:sub(1,64) end; return name
end
local function saveFilePath(name) return SAVE_FOLDER.."/"..sanitizeFileName(name)..".json" end
local function ensureFolder() if typeof(makefolder)=="function" then pcall(makefolder, SAVE_FOLDER) end end
local function listSaveFiles()
	local files = {}; if typeof(listfiles)~="function" then return files end
	ensureFolder(); local ok,res = pcall(listfiles, SAVE_FOLDER)
	if ok and type(res)=="table" then for _,v in ipairs(res) do local s=tostring(v); local name=s:match("([^/\\]+)%.json$") or s:match("^([%w_%-%.]+)%.json$"); if name then files[#files+1]=name end end end
	table.sort(files); return files
end
local function getSaveOptions() local files=listSaveFiles(); if #files==0 then return {"(no saves)"} end; return files end
local function writeSaveRaw(name, text)
	if typeof(writefile)~="function" then return false,"writefile tidak tersedia." end
	ensureFolder(); local ok=pcall(writefile, saveFilePath(name), text); return ok, ok and nil or "Gagal menulis file."
end
local function readSaveRaw(name)
	if typeof(readfile)~="function" then return nil,"readfile tidak tersedia." end
	if typeof(isfile)=="function" then local ok,exists=pcall(isfile, saveFilePath(name)); if not ok or not exists then return nil,"File tidak ditemukan." end end
	local ok,content=pcall(readfile, saveFilePath(name))
	if ok and type(content)=="string" and #content>0 then return content end; return nil,"Gagal membaca file."
end
local function encodeValue(v)
	if typeof(v)=="Color3" then return {__type="Color3", R=v.R, G=v.G, B=v.B}
	elseif typeof(v)=="EnumItem" and v.EnumType==Enum.KeyCode then return {__type="KeyCode", Name=v.Name} end
	return v
end
local function decodeValue(v)
	if type(v)=="table" then
		if v.__type=="Color3" then return Color3.new(v.R or 1, v.G or 1, v.B or 1)
		elseif v.__type=="KeyCode" then return Enum.KeyCode[v.Name] or Enum.KeyCode.Unknown end
	end; return v
end
function Library:SaveToFile(name)
	name = sanitizeFileName(name); local values = {}
	for flag,val in pairs(Library.Flags) do values[flag]=encodeValue(val) end
	local placeId=0; pcall(function() placeId=game.PlaceId end)
	local payload = { Meta={Library="ZethHub",Version=5.5,SavedAt=os.time(),PlaceId=placeId,FileName=name}, Values=values }
	local okEnc,encoded = pcall(function() return HttpService:JSONEncode(payload) end)
	if not okEnc then return false,"Gagal encode JSON." end; return writeSaveRaw(name, encoded)
end
function Library:LoadFromFile(name)
	name = sanitizeFileName(name); local raw,err = readSaveRaw(name)
	if not raw then return false,err end
	local ok,data = pcall(function() return HttpService:JSONDecode(raw) end)
	if not ok or type(data)~="table" then return false,"File save rusak." end
	Library._loading = true
	for flag,encoded in pairs(data.Values or {}) do
		local value = decodeValue(encoded); Library.Flags[flag] = value
		local el = Library._elements[flag]
		if el and el.Object then pcall(function()
			if el.Type=="toggle" or el.Type=="slider" then el.Object:Set(value)
			elseif el.Type=="textbox" or el.Type=="input" or el.Type=="dropdown" then el.Object:Set(tostring(value or ""))
			elseif el.Type=="multidropdown" then el.Object:Set(value)
			elseif el.Type=="keybind" then local kc=value; if typeof(kc)=="string" then kc=Enum.KeyCode[kc] or Enum.KeyCode.Unknown end; if typeof(kc)=="EnumItem" and kc.EnumType==Enum.KeyCode then el.Object:SetKey(kc) end
			elseif el.Type=="colorpicker" then if typeof(value)=="Color3" then el.Object:Set(value) end end
		end) end
	end
	Library._loading = false; Library._saveFile = name; return true
end
function Library:DeleteSave(name)
	name = sanitizeFileName(name); local del = nil
	if typeof(delfile)=="function" then del=delfile elseif typeof(deletefile)=="function" then del=deletefile end
	if not del then return false,"delfile/deletefile tidak tersedia." end
	local ok=pcall(del, saveFilePath(name)); return ok, ok and nil or "Gagal menghapus file."
end
task.spawn(function()
	local timer=0
	while true do
		task.wait(1)
		if Library._destroyed or (type(Env)=="table" and Env.ZethHubGeneration~=Library.Generation) then return end
		if Library.AutoSave.Enabled then
			timer+=1; local interval=math.max(5,tonumber(Library.AutoSave.Interval) or 60)
			if timer>=interval then timer=0; pcall(function() Library:SaveToFile(Library._saveFile or Library.AutoSave.File or "autosave") end) end
		else timer=0 end
	end
end)

--// Notification settings
Library.NotificationWidth = Library.NotificationWidth or 320
Library.NotificationRightOffset = Library.NotificationRightOffset or 16
Library.NotificationTopOffset = Library.NotificationTopOffset or 12
Library.MiniSafeMargin = Library.MiniSafeMargin or 8

--// Notification GUI
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "ZethNotifies"; NotifGui.ResetOnSpawn = false; NotifGui.DisplayOrder = 9999
NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; NotifGui.IgnoreGuiInset = true
pcall(function() NotifGui.Parent = game:GetService("CoreGui") end)
if not NotifGui.Parent then pcall(function() NotifGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end) end
local notifyContainer, notifyList
local function rebuildNotifyContainer()
	if not NotifGui or not NotifGui.Parent then
		NotifGui = Instance.new("ScreenGui"); NotifGui.Name="ZethNotifies"; NotifGui.ResetOnSpawn=false
		NotifGui.DisplayOrder=999; NotifGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; NotifGui.IgnoreGuiInset=true
		pcall(function() NotifGui.Parent=game:GetService("CoreGui") end)
		if not NotifGui.Parent then pcall(function() NotifGui.Parent=LocalPlayer:WaitForChild("PlayerGui") end) end
	end
	if not notifyContainer or not notifyContainer.Parent then
		notifyContainer = Instance.new("Frame"); notifyContainer.Name="NotifyContainer"
		notifyContainer.Size=UDim2.new(0,Library.NotificationWidth,1,-24)
		notifyContainer.Position=UDim2.new(1,-(Library.NotificationWidth+Library.NotificationRightOffset),0,Library.NotificationTopOffset)
		notifyContainer.BackgroundTransparency=1; notifyContainer.BorderSizePixel=0; notifyContainer.Parent=NotifGui
		notifyList=Instance.new("UIListLayout"); notifyList.SortOrder=Enum.SortOrder.LayoutOrder
		notifyList.Padding=UDim.new(0,8); notifyList.HorizontalAlignment=Enum.HorizontalAlignment.Center
		notifyList.VerticalAlignment=Enum.VerticalAlignment.Top; notifyList.Parent=notifyContainer
	end
end
rebuildNotifyContainer()
local function notifyToText(value)
	if type(value)=="table" then return table.concat(value,"\n") end; return tostring(value or "")
end
function Library:Notify(...)
	if Library._destroyed then return end
	local first = ...; local cfg
	if type(first)=="table" then cfg=first
	else cfg={Content=first, Duration=select(2,...), Title=select(3,...), Image=select(4,...)} end
	local content = notifyToText(cfg.Content or cfg.Text or cfg.Message or "")
	local title = notifyToText(cfg.Title or cfg.title or "")
	local image = cfg.Image or cfg.Icon or cfg.icon
	if image==nil and (title~="" or content~="") then image="info" end
	local duration = tonumber(cfg.Duration or cfg.duration) or 5; if duration<0.1 then duration=0.1 end
	local accent = cfg.Color or cfg.Accent or Library.Accent; if typeof(accent)~="Color3" then accent=Library.Accent end
	local hasTitle=title~=""; local hasContent=content~=""; local hasIcon=image~=nil and image~="" and image~=0
	if not hasTitle and not hasContent and not hasIcon then return end
	Library._notifyOrder = (Library._notifyOrder or 0) - 1; local order = Library._notifyOrder
	task.spawn(function()
		if Library._destroyed then return end
		rebuildNotifyContainer()
		local holder=Instance.new("Frame"); holder.Name="NotifyHolder"; holder.Size=UDim2.new(1,0,0,0)
		holder.AutomaticSize=Enum.AutomaticSize.Y; holder.BackgroundTransparency=1; holder.BorderSizePixel=0
		holder.ClipsDescendants=true; holder.LayoutOrder=order; holder.Parent=notifyContainer
		local n=Instance.new("Frame"); n.Name="Notification"; n.Size=UDim2.new(1,0,0,0)
		n.AutomaticSize=Enum.AutomaticSize.Y; n.BackgroundColor3=Theme.Element; n.BackgroundTransparency=1
		n.BorderSizePixel=0; n.ClipsDescendants=true; n.Position=UDim2.new(1,36,0,0); n.Parent=holder
		Corner(n,10); local stroke=Stroke(n,Color3.new(1,1,1),1.5); stroke.Transparency=1; registerRGB(stroke)
		local nPad=Instance.new("UIPadding"); nPad.PaddingTop=UDim.new(0,12); nPad.PaddingLeft=UDim.new(0,12)
		nPad.PaddingBottom=UDim.new(0,10); nPad.PaddingRight=UDim.new(0,12); nPad.Parent=n
		local nList=Instance.new("UIListLayout"); nList.SortOrder=Enum.SortOrder.LayoutOrder; nList.Padding=UDim.new(0,8)
		nList.HorizontalAlignment=Enum.HorizontalAlignment.Center; nList.VerticalAlignment=Enum.VerticalAlignment.Top; nList.Parent=n
		local row=Instance.new("Frame"); row.Name="Row"; row.Size=UDim2.new(1,0,0,0); row.AutomaticSize=Enum.AutomaticSize.Y
		row.BackgroundTransparency=1; row.BorderSizePixel=0; row.LayoutOrder=1; row.Parent=n
		local rowLayout=Instance.new("UIListLayout"); rowLayout.FillDirection=Enum.FillDirection.Horizontal
		rowLayout.SortOrder=Enum.SortOrder.LayoutOrder; rowLayout.Padding=UDim.new(0,10)
		rowLayout.HorizontalAlignment=Enum.HorizontalAlignment.Left; rowLayout.VerticalAlignment=Enum.VerticalAlignment.Center; rowLayout.Parent=row
		local icon
		if hasIcon then icon=Instance.new("ImageLabel"); icon.Name="Icon"; icon.Size=UDim2.new(0,32,0,32)
			icon.BackgroundTransparency=1; icon.ImageTransparency=1; icon.ImageColor3=accent; icon.LayoutOrder=1; icon.Parent=row; setIcon(icon,image) end
		local textBox=Instance.new("Frame"); textBox.Name="TextBox"; textBox.Size=UDim2.new(1,hasIcon and -42 or 0,0,0)
		textBox.AutomaticSize=Enum.AutomaticSize.Y; textBox.BackgroundTransparency=1; textBox.BorderSizePixel=0
		textBox.LayoutOrder=2; textBox.Parent=row
		local textList=Instance.new("UIListLayout"); textList.SortOrder=Enum.SortOrder.LayoutOrder; textList.Padding=UDim.new(0,3)
		textList.HorizontalAlignment=Enum.HorizontalAlignment.Left; textList.VerticalAlignment=Enum.VerticalAlignment.Top; textList.Parent=textBox
		local titleLbl, contentLbl
		if hasTitle then titleLbl=Instance.new("TextLabel"); titleLbl.Name="Title"; titleLbl.Size=UDim2.new(1,0,0,0)
			titleLbl.AutomaticSize=Enum.AutomaticSize.Y; titleLbl.BackgroundTransparency=1; titleLbl.Text=title
			titleLbl.TextColor3=accent; titleLbl.TextSize=14; titleLbl.Font=Enum.Font.GothamBold
			titleLbl.TextXAlignment=Enum.TextXAlignment.Left; titleLbl.TextYAlignment=Enum.TextYAlignment.Top
			titleLbl.TextWrapped=true; titleLbl.TextTransparency=1; titleLbl.LayoutOrder=1; titleLbl.Parent=textBox end
		if hasContent then contentLbl=Instance.new("TextLabel"); contentLbl.Name="Content"; contentLbl.Size=UDim2.new(1,0,0,0)
			contentLbl.AutomaticSize=Enum.AutomaticSize.Y; contentLbl.BackgroundTransparency=1; contentLbl.Text=content
			contentLbl.TextColor3=Color3.fromRGB(232,232,232); contentLbl.TextSize=12; contentLbl.Font=Enum.Font.Gotham
			contentLbl.TextXAlignment=Enum.TextXAlignment.Left; contentLbl.TextYAlignment=Enum.TextYAlignment.Top
			contentLbl.TextWrapped=true; contentLbl.TextTransparency=1; contentLbl.LayoutOrder=2; contentLbl.Parent=textBox end
		local track=Instance.new("Frame"); track.Name="ProgressTrack"; track.Size=UDim2.new(1,0,0,4)
		track.BackgroundColor3=Color3.fromRGB(45,45,45); track.BackgroundTransparency=0.25; track.BorderSizePixel=0
		track.ClipsDescendants=true; track.LayoutOrder=2; track.Parent=n; Corner(track,99)
		local fill=Instance.new("Frame"); fill.Name="ProgressFill"; fill.Size=UDim2.new(1,0,1,0)
		fill.BackgroundColor3=accent; fill.BorderSizePixel=0; fill.Parent=track; Corner(fill,99)
		task.wait()
		Tween(n,0.35,{Position=UDim2.new(0,0,0,0),BackgroundTransparency=0},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
		Tween(stroke,0.35,{Transparency=0})
		if icon then Tween(icon,0.28,{ImageTransparency=0}) end
		if titleLbl then Tween(titleLbl,0.28,{TextTransparency=0}) end
		if contentLbl then Tween(contentLbl,0.28,{TextTransparency=0}) end
		Tween(fill,duration,{Size=UDim2.new(0,0,1,0)},Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
		task.delay(duration, function()
			if not holder or not holder.Parent then return end
			Tween(n,0.3,{Position=UDim2.new(1,36,0,0),BackgroundTransparency=1},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
			Tween(stroke,0.3,{Transparency=1})
			if icon then Tween(icon,0.25,{ImageTransparency=1}) end
			if titleLbl then Tween(titleLbl,0.25,{TextTransparency=1}) end
			if contentLbl then Tween(contentLbl,0.25,{TextTransparency=1}) end
			task.delay(0.32, function() if holder and holder.Parent then holder:Destroy() end end)
		end)
	end)
end

-- ============================================================
-- V5.5 NEW: GAME CHECKER / DETECTION
-- ============================================================
local GameChecker = {
	PlaceId = 0,
	GameName = "Unknown",
	IsKnown = false,
	KnownGames = {
		[1537690966] = "Survive The Swarm",
		[1002272261] = "Survive The Swarm",
		[7568841079] = "Da Hood",
		[606849621] = "Brookhaven RP",
		[920459837] = "Adopt Me!",
		[275399554] = "Murder Mystery 2",
		[1427300201] = "Tower of Hell",
		[1544301257] = "Natural Disaster Survival",
		[6516141725] = "Sol's RNG",
		[8737602449] = "Steal a Brainrot",
	}
}
pcall(function() GameChecker.PlaceId = game.PlaceId end)
pcall(function() GameChecker.GameName = game.Name end)
if GameChecker.KnownGames[GameChecker.PlaceId] then
	GameChecker.GameName = GameChecker.KnownGames[GameChecker.PlaceId]
	GameChecker.IsKnown = true
end

-- ============================================================
-- V5.5 NEW: LOADING SCREEN (like Dek Dev Hub screenshot 3)
-- ============================================================
local LoadingScreen = { Gui = nil, Done = false, Progress = 0 }
local function createLoadingScreen()
	if not Library.LoadingScreen.Enabled then LoadingScreen.Done = true; return end
	local gui = Instance.new("ScreenGui")
	gui.Name = "ZethLoadingScreen"; gui.ResetOnSpawn = false; gui.DisplayOrder = 10000
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.IgnoreGuiInset = true
	pcall(function() gui.Parent = game:GetService("CoreGui") end)
	if not gui.Parent then pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end) end
	LoadingScreen.Gui = gui

	-- Full dark overlay
	local overlay = Instance.new("Frame")
	overlay.Name = "Overlay"; overlay.Size = UDim2.new(1,0,1,0)
	overlay.BackgroundColor3 = Color3.fromRGB(0,0,0); overlay.BackgroundTransparency = 0.25
	overlay.BorderSizePixel = 0; overlay.ZIndex = 1; overlay.Parent = gui

	-- Center card
	local card = Instance.new("Frame")
	card.Name = "LoadingCard"; card.AnchorPoint = Vector2.new(0.5,0.5)
	card.Position = UDim2.new(0.5,0,0.5,0); card.Size = UDim2.new(0,380,0,160)
	card.BackgroundColor3 = Theme.Background; card.BackgroundTransparency = 0.08
	card.BorderSizePixel = 0; card.ZIndex = 2; card.Parent = overlay
	Corner(card, 14)
	local cardStroke = Stroke(card, Library.Accent, 2); cardStroke.Transparency = 0.3
	registerRGB(cardStroke)
	if Library.Effects.Shadow then
		pcall(function() local sh=Instance.new("UIDropShadow"); sh.Color=Color3.new(0,0,0); sh.Transparency=0.4; sh.Size=UDim2.new(0,30,0,30); sh.Offset=Vector2.new(0,8); sh.Parent=card end)
	end

	-- Icon
	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.new(0,52,0,52); iconFrame.Position = UDim2.new(0,18,0,18)
	iconFrame.BackgroundColor3 = Theme.Element; iconFrame.BorderSizePixel = 0; iconFrame.ZIndex = 3; iconFrame.Parent = card
	Corner(iconFrame, 12)
	registerRGB(Stroke(iconFrame, Color3.new(1,1,1), 1.5))
	local hubIcon = makeIcon(iconFrame, "zap", UDim2.new(0,28,0,28), UDim2.new(0.5,-14,0.5,-14), Library.Accent)
	if hubIcon then hubIcon.ZIndex = 4 end

	-- Title
	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1,-80,0,22); titleLbl.Position = UDim2.new(0,78,0,18)
	titleLbl.BackgroundTransparency = 1; titleLbl.Text = Library.LoadingScreen.HubName or "ZETHUB"
	titleLbl.TextColor3 = Theme.Text; titleLbl.TextSize = 18; titleLbl.Font = Enum.Font.GothamBlack
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.TextYAlignment = Enum.TextYAlignment.Center
	titleLbl.ZIndex = 3; titleLbl.Parent = card

	-- Game name subtitle
	local gameLbl = Instance.new("TextLabel")
	gameLbl.Size = UDim2.new(1,-80,0,16); gameLbl.Position = UDim2.new(0,78,0,40)
	gameLbl.BackgroundTransparency = 1; gameLbl.Text = GameChecker.GameName
	gameLbl.TextColor3 = Theme.SubText; gameLbl.TextSize = 12; gameLbl.Font = Enum.Font.Gotham
	gameLbl.TextXAlignment = Enum.TextXAlignment.Left; gameLbl.TextYAlignment = Enum.TextYAlignment.Center
	gameLbl.TextTruncate = Enum.TextTruncate.AtEnd; gameLbl.ZIndex = 3; gameLbl.Parent = card

	-- Progress label
	local progLbl = Instance.new("TextLabel")
	progLbl.Name = "ProgressLabel"; progLbl.Size = UDim2.new(1,-36,0,14); progLbl.Position = UDim2.new(0,18,0,78)
	progLbl.BackgroundTransparency = 1; progLbl.Text = "Building menu..."
	progLbl.TextColor3 = Theme.SubText; progLbl.TextSize = 11; progLbl.Font = Enum.Font.GothamMedium
	progLbl.TextXAlignment = Enum.TextXAlignment.Left; progLbl.ZIndex = 3; progLbl.Parent = card

	-- Progress track
	local progTrack = Instance.new("Frame")
	progTrack.Size = UDim2.new(1,-36,0,6); progTrack.Position = UDim2.new(0,18,0,96)
	progTrack.BackgroundColor3 = Theme.Border; progTrack.BackgroundTransparency = 0.4
	progTrack.BorderSizePixel = 0; progTrack.ZIndex = 3; progTrack.Parent = card
	Corner(progTrack, 99)
	local progFill = Instance.new("Frame")
	progFill.Name = "ProgressFill"; progFill.Size = UDim2.new(0,0,1,0)
	progFill.BackgroundColor3 = Library.Accent; progFill.BorderSizePixel = 0; progFill.ZIndex = 4; progFill.Parent = progTrack
	Corner(progFill, 99)
	window_onAccent_ref = function(c) if progFill and progFill.Parent then progFill.BackgroundColor3 = c end end
	-- register accent listener via ThemeManager
	ThemeManager:OnChange(function()
		if progFill and progFill.Parent then
			progFill.BackgroundColor3 = ThemeManager.Mode=="RGB Rainbow" and currentRainbowColor(0) or Library.Accent
		end
		if cardStroke and cardStroke.Parent then
			cardStroke.Color = ThemeManager.Mode=="RGB Rainbow" and currentRainbowColor(0.5) or Library.Accent
		end
	end)

	-- Version label
	local verLbl = Instance.new("TextLabel")
	verLbl.Size = UDim2.new(0.5,0,0,14); verLbl.Position = UDim2.new(0,18,1,-24)
	verLbl.BackgroundTransparency = 1; verLbl.Text = Library.LoadingScreen.Version or "V5.5"
	verLbl.TextColor3 = Theme.SubText; verLbl.TextSize = 10; verLbl.Font = Enum.Font.Gotham
	verLbl.TextXAlignment = Enum.TextXAlignment.Left; verLbl.ZIndex = 3; verLbl.Parent = card

	-- Skip button
	local skipBtn = Instance.new("TextButton")
	skipBtn.Size = UDim2.new(0,60,0,24); skipBtn.Position = UDim2.new(1,-78,1,-30)
	skipBtn.BackgroundColor3 = Theme.Element; skipBtn.BackgroundTransparency = 0.2
	skipBtn.BorderSizePixel = 0; skipBtn.Text = "Skip"; skipBtn.TextColor3 = Theme.SubText
	skipBtn.TextSize = 12; skipBtn.Font = Enum.Font.GothamBold; skipBtn.AutoButtonColor = false
	skipBtn.ZIndex = 3; skipBtn.Parent = card; Corner(skipBtn, 6)
	skipBtn.MouseEnter:Connect(function() Tween(skipBtn,.15,{BackgroundTransparency=0,TextColor3=Theme.Text}) end)
	skipBtn.MouseLeave:Connect(function() Tween(skipBtn,.15,{BackgroundTransparency=0.2,TextColor3=Theme.SubText}) end)

	local function finishLoading()
		if LoadingScreen.Done then return end
		LoadingScreen.Done = true
		Tween(progFill, 0.3, {Size=UDim2.new(1,0,1,0)}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		progLbl.Text = "Done!"
		task.delay(0.5, function()
			Tween(overlay, 0.4, {BackgroundTransparency=1}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			Tween(card, 0.4, {BackgroundTransparency=1}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			task.delay(0.45, function() pcall(function() gui:Destroy() end) end)
		end)
	end
	skipBtn.MouseButton1Click:Connect(finishLoading)
	LoadingScreen.Finish = finishLoading
	LoadingScreen.SetProgress = function(pct, text)
		pct = math.clamp(tonumber(pct) or 0, 0, 1)
		progFill.Size = UDim2.new(pct, 0, 1, 0)
		if text then progLbl.Text = tostring(text) end
	end
	LoadingScreen.SetStatus = function(text) if text then progLbl.Text = tostring(text) end end
	return gui
end
createLoadingScreen()

-- PART 1 END
-- JANGAN JALANKAN SENDIRI. LANJUTKAN DENGAN PART 2
-- ============================================================
-- PART 2 : MOVEMENT ENGINE + QUICK BAR + INFO PANEL + WINDOW(P1) + TAB ELEMENTS
-- ============================================================

--// ---------- Movement Engine (dipakai Quick Bar) ----------
local Move = { WS = 16, JP = 50, InfJump = false, WSEnabled = false, JPEnabled = false }
_G.ZethMove = Move
local function getHum()
	local c = LocalPlayer.Character
	return c and c:FindFirstChildOfClass("Humanoid")
end
local function applyWS() local h = getHum(); if h and Move.WSEnabled then h.WalkSpeed = Move.WS end end
local function applyJP() local h = getHum(); if h and Move.JPEnabled then h.UseJumpPower = true; h.JumpPower = Move.JP end end
local function resetMove()
	local h = getHum(); if not h then return end
	h.WalkSpeed = 16; h.UseJumpPower = true; h.JumpPower = 50
end
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5); applyWS(); applyJP() end)
UserInputService.JumpRequest:Connect(function()
	if not Move.InfJump then return end
	local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

--// ---------- Clipboard / Rejoin / Format helpers ----------
local function copyText(t)
	t = tostring(t or "")
	local ok = false
	if typeof(setclipboard) == "function" then ok = pcall(setclipboard, t) end
	if not ok and typeof(toclipboard) == "function" then ok = pcall(toclipboard, t) end
	if not ok and typeof(Synapse) == "table" and Synapse.zlib then ok = pcall(function() Synapse.zlib.setclipboard(t) end) end
	return ok
end
local function rejoinServer()
	local TS = game:GetService("TeleportService")
	pcall(function() TS:Teleport(game.PlaceId, LocalPlayer) end)
end
local function fmtDur(sec)
	sec = math.floor(tonumber(sec) or 0)
	local h = math.floor(sec / 3600); local m = math.floor((sec % 3600) / 60); local s = sec % 60
	return string.format("%dh %02dm %02ds", h, m, s)
end

-- ============================================================
-- V5.5 NEW : QUICK BAR (mengambang, draggable, ikut theme)
-- ============================================================
local QB = { Gui = nil, Root = nil, Content = nil, Visible = true, Collapsed = false, refs = {}, rows = {} }
Library._quickBar = QB
local qbBuilt = false

local function qbAccent() return ThemeManager:GetColor(0) end
local function qbApplyTheme()
	if not QB.Root or not QB.Root.Parent then return end
	QB.Root.BackgroundColor3 = Theme.Background
	if QB.stroke then QB.stroke.Color = qbAccent() end
	if QB.title then QB.title.TextColor3 = Theme.Text end
	if QB.sub then QB.sub.TextColor3 = Theme.SubText end
	if QB.collapseArrow then QB.collapseArrow.TextColor3 = Theme.SubText end
	if QB.hideBtn then QB.hideBtn.TextColor3 = Theme.SubText end
	for _, r in ipairs(QB.refs) do
		if r.obj and r.obj.Parent then pcall(function() r.obj[r.prop] = r.get() end) end
	end
end
ThemeManager:OnChange(qbApplyTheme)

local function qbAddRef(obj, prop, getter) table.insert(QB.refs, { obj = obj, prop = prop, get = getter }) end

-- baris slider mini
local function qbSliderRow(name, icon, min, max, default, fmt, onChange)
	local row = Instance.new("Frame")
	row.Name = "Row_" .. name; row.Size = UDim2.new(1, 0, 0, 40)
	row.BackgroundTransparency = 1; row.BorderSizePixel = 0; row.Parent = QB.Content
	local ic = makeIcon(row, icon, UDim2.new(0, 14, 0, 14), UDim2.new(0, 2, 0, 3), Theme.SubText)
	if ic then qbAddRef(ic, "ImageColor3", function() return Theme.SubText end) end
	local nl = Instance.new("TextLabel")
	nl.Size = UDim2.new(0.6, -20, 0, 14); nl.Position = UDim2.new(0, 20, 0, 2)
	nl.BackgroundTransparency = 1; nl.Text = name; nl.TextColor3 = Theme.Text
	nl.TextSize = 12; nl.Font = Enum.Font.GothamMedium; nl.TextXAlignment = Enum.TextXAlignment.Left
	nl.Parent = row; qbAddRef(nl, "TextColor3", function() return Theme.Text end)
	local vl = Instance.new("TextLabel")
	vl.Size = UDim2.new(0.4, -4, 0, 14); vl.Position = UDim2.new(0.6, 0, 0, 2)
	vl.BackgroundTransparency = 1; vl.Text = fmt(default); vl.TextColor3 = qbAccent()
	vl.TextSize = 12; vl.TextSize = 12; vl.Font = Enum.Font.GothamBold; vl.TextXAlignment = Enum.TextXAlignment.Right
	vl.Parent = row
	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -4, 0, 5); track.Position = UDim2.new(0, 2, 0, 26)
	track.BackgroundColor3 = Theme.Border; track.BorderSizePixel = 0; track.Parent = row
	Corner(track, 99); qbAddRef(track, "BackgroundColor3", function() return Theme.Border end)
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0); fill.BackgroundColor3 = qbAccent(); fill.BorderSizePixel = 0; fill.Parent = track
	Corner(fill, 99)
	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 10, 0, 10); knob.BackgroundColor3 = Color3.new(1, 1, 1); knob.BorderSizePixel = 0; knob.Parent = track
	Corner(knob, 99); local ks = Stroke(knob, qbAccent(), 1.5)
	local value = default
	local function setV(v, fire)
		value = math.clamp(v, min, max)
		local rel = (value - min) / math.max(0.0001, max - min)
		fill.Size = UDim2.new(rel, 0, 1, 0); knob.Position = UDim2.new(rel, -5, 0.5, -5)
		vl.Text = fmt(value)
		if fire and onChange then onChange(value) end
	end
	setV(default, false)
	local hit = Instance.new("TextButton")
	hit.Size = UDim2.new(1, -4, 0, 16); hit.Position = UDim2.new(0, 2, 0, 22)
	hit.BackgroundTransparency = 1; hit.Text = ""; hit.AutoButtonColor = false; hit.Parent = row
	local sliding = false
	hit.InputBegan:Connect(function(inp)
		if isPressInput(inp) then sliding = true; setV(min + (max - min) * math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1), true) end
	end)
	Connect(UserInputService.InputChanged, function(inp)
		if sliding and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			setV(min + (max - min) * math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1), true)
		end
	end, nil)
	Connect(UserInputService.InputEnded, function(inp) if isPressInput(inp) then sliding = false end end, nil)
	local obj = { Set = function(_, v) setV(v, true) end, Get = function() return value end, accentRefs = { vl, fill } }
	qbAddRef(vl, "TextColor3", qbAccent); qbAddRef(fill, "BackgroundColor3", qbAccent); qbAddRef(ks, "Color", qbAccent)
	return obj
end

-- baris toggle mini
local function qbToggleRow(name, icon, default, onChange)
	local row = Instance.new("Frame")
	row.Name = "Row_" .. name; row.Size = UDim2.new(1, 0, 0, 24)
	row.BackgroundTransparency = 1; row.BorderSizePixel = 0; row.Parent = QB.Content
	local ic = makeIcon(row, icon, UDim2.new(0, 14, 0, 14), UDim2.new(0, 2, 0.5, -7), Theme.SubText)
	if ic then qbAddRef(ic, "ImageColor3", function() return Theme.SubText end) end
	local nl = Instance.new("TextLabel")
	nl.Size = UDim2.new(1, -64, 1, 0); nl.Position = UDim2.new(0, 20, 0, 0)
	nl.BackgroundTransparency = 1; nl.Text = name; nl.TextColor3 = Theme.Text
	nl.TextSize = 12; nl.Font = Enum.Font.GothamMedium; nl.TextXAlignment = Enum.TextXAlignment.Left
	nl.TextYAlignment = Enum.TextYAlignment.Center; nl.Parent = row
	qbAddRef(nl, "TextColor3", function() return Theme.Text end)
	local sw = Instance.new("TextButton")
	sw.Size = UDim2.new(0, 34, 0, 16); sw.Position = UDim2.new(1, -38, 0.5, -8)
	sw.BackgroundColor3 = Theme.Border; sw.BorderSizePixel = 0; sw.Text = ""; sw.AutoButtonColor = false; sw.Parent = row
	Corner(sw, 99); qbAddRef(sw, "BackgroundColor3", function() return Theme.Border end)
	local cir = Instance.new("Frame")
	cir.Size = UDim2.new(0, 12, 0, 12); cir.Position = UDim2.new(0, 2, 0.5, -6)
	cir.BackgroundColor3 = Theme.SubText; cir.BorderSizePixel = 0; cir.Parent = sw; Corner(cir, 99)
	qbAddRef(cir, "BackgroundColor3", function() return Theme.SubText end)
	local on = default and true or false
	local function upd(fire)
		if on then Tween(sw, .18, {BackgroundColor3 = qbAccent()}); Tween(cir, .18, {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Color3.new(1,1,1)})
		else Tween(sw, .18, {BackgroundColor3 = Theme.Border}); Tween(cir, .18, {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Theme.SubText}) end
		if fire and onChange then onChange(on) end
	end
	upd(false); sw.MouseButton1Click:Connect(function() on = not on; upd(true) end)
	local obj = { Set = function(_, v) on = v and true or false; upd(true) end, Get = function() return on end }
	qbAddRef(sw, "BackgroundColor3", function() return on and qbAccent() or Theme.Border end)
	return obj
end

function Library:BuildQuickBar()
	if qbBuilt or not Library.QuickBar.Enabled then return end
	qbBuilt = true
	local gui = Instance.new("ScreenGui")
	gui.Name = "ZethQuickBar"; gui.ResetOnSpawn = false; gui.DisplayOrder = 997
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.IgnoreGuiInset = true
	pcall(function() gui.Parent = game:GetService("CoreGui") end)
	if not gui.Parent then pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end) end
	QB.Gui = gui

	local root = Instance.new("Frame")
	root.Name = "QuickBar"; root.Size = UDim2.new(0, 220, 0, 0); root.AutomaticSize = Enum.AutomaticSize.Y
	root.Position = UDim2.new(0, Library.QuickBar.Position.X, 0, Library.QuickBar.Position.Y)
	root.BackgroundColor3 = Theme.Background; root.BorderSizePixel = 0; root.ClipsDescendants = true; root.Parent = gui
	Corner(root, 10); QB.Root = root
	QB.stroke = Stroke(root, qbAccent(), 1.6); QB.stroke.Transparency = 0.15
	if Library.Effects.Shadow then pcall(function() local sh = Instance.new("UIDropShadow"); sh.Color = Color3.new(0,0,0); sh.Transparency = 0.45; sh.Size = UDim2.new(0,20,0,20); sh.Offset = Vector2.new(0,6); sh.Parent = root end) end

	-- title bar (draggable + collapse + hide)
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 26); titleBar.BackgroundTransparency = 1; titleBar.BorderSizePixel = 0; titleBar.Parent = root
	local tic = makeIcon(titleBar, "zap", UDim2.new(0, 14, 0, 14), UDim2.new(0, 8, 0.5, -7), qbAccent())
	QB.title = Instance.new("TextLabel")
	QB.title.Size = UDim2.new(1, -64, 1, 0); QB.title.Position = UDim2.new(0, 26, 0, 0)
	QB.title.BackgroundTransparency = 1; QB.title.Text = "Quick Bar"; QB.title.TextColor3 = Theme.Text
	QB.title.TextSize = 12; QB.title.Font = Enum.Font.GothamBold; QB.title.TextXAlignment = Enum.TextXAlignment.Left
	QB.title.TextYAlignment = Enum.TextYAlignment.Center; QB.title.Parent = titleBar
	QB.collapseArrow = Instance.new("TextButton")
	QB.collapseArrow.Size = UDim2.new(0, 18, 0, 18); QB.collapseArrow.Position = UDim2.new(1, -40, 0.5, -9)
	QB.collapseArrow.BackgroundTransparency = 1; QB.collapseArrow.Text = "v"; QB.collapseArrow.TextColor3 = Theme.SubText
	QB.collapseArrow.TextSize = 12; QB.collapseArrow.Font = Enum.Font.GothamBold; QB.collapseArrow.AutoButtonColor = false; QB.collapseArrow.Parent = titleBar
	QB.hideBtn = Instance.new("TextButton")
	QB.hideBtn.Size = UDim2.new(0, 18, 0, 18); QB.hideBtn.Position = UDim2.new(1, -22, 0.5, -9)
	QB.hideBtn.BackgroundTransparency = 1; QB.hideBtn.Text = "x"; QB.hideBtn.TextColor3 = Theme.SubText
	QB.hideBtn.TextSize = 13; QB.hideBtn.Font = Enum.Font.GothamBold; QB.hideBtn.AutoButtonColor = false; QB.hideBtn.Parent = titleBar

	-- content
	QB.Content = Instance.new("Frame")
	QB.Content.Size = UDim2.new(1, -16, 0, 0); QB.Content.AutomaticSize = Enum.AutomaticSize.Y
	QB.Content.Position = UDim2.new(0, 8, 0, 28); QB.Content.BackgroundTransparency = 1; QB.Content.BorderSizePixel = 0; QB.Content.Parent = root
	local cl = Instance.new("UIListLayout"); cl.SortOrder = Enum.SortOrder.LayoutOrder; cl.Padding = UDim.new(0, 2); cl.Parent = QB.Content
	local cp = Instance.new("UIPadding"); cp.PaddingBottom = UDim.new(0, 6); cp.Parent = QB.Content

	-- rows
	QB.rows.ws = qbSliderRow("WalkSpeed", "gauge", 0, 5000, 16, function(v) return tostring(math.floor(v)) end, function(v) Move.WS = v; applyWS() end)
	QB.rows.wsT = qbToggleRow("WS Active", "toggle-right", false, function(v) Move.WSEnabled = v; if v then applyWS() else local h = getHum(); if h then h.WalkSpeed = 16 end end end)
	QB.rows.jp = qbSliderRow("JumpPower", "chevron-up", 0, 5000, 50, function(v) return tostring(math.floor(v)) end, function(v) Move.JP = v; applyJP() end)
	QB.rows.jpT = qbToggleRow("JP Active", "toggle-right", false, function(v) Move.JPEnabled = v; if v then applyJP() else local h = getHum(); if h then h.UseJumpPower = true; h.JumpPower = 50 end end end)
	QB.rows.inf = qbToggleRow("Inf Jump", "activity", false, function(v) Move.InfJump = v end)

	-- interactions
	QB.collapseArrow.MouseButton1Click:Connect(function()
		QB.Collapsed = not QB.Collapsed
		QB.Content.Visible = not QB.Collapsed
		Tween(QB.collapseArrow, .2, {Rotation = QB.Collapsed and -90 or 0})
	end)
	QB.hideBtn.MouseButton1Click:Connect(function() QB.Visible = false; gui.Enabled = false end)

	local dragging, ds, doff = false, nil, nil
	titleBar.InputBegan:Connect(function(inp) if isPressInput(inp) then dragging = true; ds = inp.Position; doff = root.Position end end)
	Connect(UserInputService.InputChanged, function(inp)
		if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			local d = inp.Position - ds
			root.Position = UDim2.new(doff.X.Scale, doff.X.Offset + d.X, doff.Y.Scale, doff.Y.Offset + d.Y)
		end
	end, nil)
	Connect(UserInputService.InputEnded, function(inp) if isPressInput(inp) then dragging = false end end, nil)

	function QB:SetVisible(v)
		QB.Visible = v and true or false
		if gui then gui.Enabled = QB.Visible end
	end
	qbApplyTheme()
	Library:Notify("Quick Bar aktif — geser title bar untuk memindahkan.", 4, "Quick Bar", "zap")
end

-- ============================================================
-- V5.5 NEW : INFO PANEL (gaya Dek Dev Hub, ikut theme)
-- ============================================================
local IC = { Gui = nil, Root = nil, Visible = true, refs = {}, bars = {} }
Library._infoCard = IC
local icBuilt = false
local function icAccent() return ThemeManager:GetColor(0) end
local function icAddRef(obj, prop, getter) if obj then table.insert(IC.refs, { obj = obj, prop = prop, get = getter }) end end
local function icApplyTheme()
	if not IC.Root or not IC.Root.Parent then return end
	IC.Root.BackgroundColor3 = Theme.Background
	if IC.stroke then IC.stroke.Color = icAccent() end
	if IC.title then IC.title.TextColor3 = icAccent() end
	if IC.sub then IC.sub.TextColor3 = Theme.SubText end
	for _, r in ipairs(IC.refs) do if r.obj and r.obj.Parent then pcall(function() r.obj[r.prop] = r.get() end) end end
end
ThemeManager:OnChange(icApplyTheme)

-- mini bar chart
local function makeBars(parent, n)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, 26); holder.BackgroundTransparency = 1; holder.BorderSizePixel = 0; holder.Parent = parent
	local gl = Instance.new("UIGridLayout"); gl.CellSize = UDim2.new(1 / n, -1, 1, 0); gl.CellPadding = UDim2.new(0, 1, 0, 0); gl.SortOrder = Enum.SortOrder.LayoutOrder; gl.Parent = holder
	local frames = {}; local hist = {}
	for i = 1, n do
		local f = Instance.new("Frame")
		f.AnchorPoint = Vector2.new(0, 1); f.Position = UDim2.new(0, 0, 1, 0)
		f.BackgroundColor3 = icAccent(); f.BorderSizePixel = 0; f.LayoutOrder = i; f.Parent = holder
		Corner(f, 2); frames[i] = f; hist[i] = 0
		icAddRef(f, "BackgroundColor3", icAccent)
	end
	return { Push = function(_, v, mx)
		table.remove(hist, 1); table.insert(hist, math.clamp(tonumber(v) or 0, 0, mx))
		for i = 1, n do local h = math.clamp(hist[i] / math.max(1, mx), 0.04, 1); frames[i].Size = UDim2.new(1, 0, h, 0) end
	end }
end

-- card builder
local function icCard(parent, order, titleText, titleColorGetter)
	local c = Instance.new("Frame")
	c.Size = UDim2.new(0.5, -6, 0, 0); c.AutomaticSize = Enum.AutomaticSize.Y
	c.BackgroundColor3 = Theme.Element; c.BorderSizePixel = 0; c.LayoutOrder = order; c.Parent = parent
	Corner(c, 8); local st = Stroke(c, Theme.Border, 1); st.Transparency = 0.2
	icAddRef(c, "BackgroundColor3", function() return Theme.Element end); icAddRef(st, "Color", function() return Theme.Border end)
	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.new(1, -16, 0, 14); tl.Position = UDim2.new(0, 8, 0, 6)
	tl.BackgroundTransparency = 1; tl.Text = string.upper(titleText); tl.TextColor3 = titleColorGetter and titleColorGetter() or Theme.SubText
	tl.TextSize = 10; tl.Font = Enum.Font.GothamBold; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.Parent = c
	if titleColorGetter then icAddRef(tl, "TextColor3", titleColorGetter) end
	local body = Instance.new("Frame")
	body.Size = UDim2.new(1, -16, 0, 0); body.AutomaticSize = Enum.AutomaticSize.Y
	body.Position = UDim2.new(0, 8, 0, 22); body.BackgroundTransparency = 1; body.BorderSizePixel = 0; body.Parent = c
	local bl = Instance.new("UIListLayout"); bl.SortOrder = Enum.SortOrder.LayoutOrder; bl.Padding = UDim.new(0, 3); bl.Parent = body
	return c, body
end
local function icLabel(parent, text, colorGetter, size, font, order)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, (size or 12) + 4); l.BackgroundTransparency = 1; l.Text = text
	l.TextColor3 = colorGetter and colorGetter() or Theme.Text; l.TextSize = size or 12; l.Font = font or Enum.Font.Gotham
	l.TextXAlignment = Enum.TextXAlignment.Left; l.TextYAlignment = Enum.TextYAlignment.Center
	l.TextTruncate = Enum.TextTruncate.AtEnd; l.LayoutOrder = order or 1; l.Parent = parent
	if colorGetter then icAddRef(l, "TextColor3", colorGetter) end
	return l
end
local function icMiniBtn(parent, text, order, onClick)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0.5, -3, 0, 20); b.BackgroundColor3 = Theme.ElementHover; b.BackgroundTransparency = 0.2
	b.BorderSizePixel = 0; b.Text = text; b.TextColor3 = Theme.SubText; b.TextSize = 10; b.Font = Enum.Font.GothamBold
	b.AutoButtonColor = false; b.LayoutOrder = order; b.Parent = parent; Corner(b, 5)
	icAddRef(b, "BackgroundColor3", function() return Theme.ElementHover end); icAddRef(b, "TextColor3", function() return Theme.SubText end)
	b.MouseEnter:Connect(function() Tween(b, .14, {BackgroundTransparency = 0, TextColor3 = Theme.Text}) end)
	b.MouseLeave:Connect(function() Tween(b, .14, {BackgroundTransparency = 0.2, TextColor3 = Theme.SubText}) end)
	b.MouseButton1Click:Connect(onClick)
	return b
end

function Library:BuildInfoCard()
	if icBuilt or not Library.InfoPanel or Library.InfoPanel.Enabled == false then return end
	icBuilt = true
	local gui = Instance.new("ScreenGui")
	gui.Name = "ZethInfoCard"; gui.ResetOnSpawn = false; gui.DisplayOrder = 996
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.IgnoreGuiInset = true
	pcall(function() gui.Parent = game:GetService("CoreGui") end)
	if not gui.Parent then pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end) end
	IC.Gui = gui

	local root = Instance.new("Frame")
	root.Name = "InfoPanel"; root.Size = UDim2.new(0, 470, 0, 320); root.AutomaticSize = Enum.AutomaticSize.None
	root.Position = UDim2.new(1, -486, 0, 60)
	root.BackgroundColor3 = Theme.Background; root.BorderSizePixel = 0; root.ClipsDescendants = true; root.Parent = gui
	Corner(root, 12); IC.Root = root
	IC.stroke = Stroke(root, icAccent(), 1.8); IC.stroke.Transparency = 0.1
	if Library.Effects.Shadow then pcall(function() local sh = Instance.new("UIDropShadow"); sh.Color = Color3.new(0,0,0); sh.Transparency = 0.45; sh.Size = UDim2.new(0,24,0,24); sh.Offset = Vector2.new(0,8); sh.Parent = root end) end

	-- header
	local hdr = Instance.new("Frame")
	hdr.Size = UDim2.new(1, 0, 0, 34); hdr.BackgroundTransparency = 1; hdr.BorderSizePixel = 0; hdr.Parent = root
	local hic = makeIcon(hdr, "server", UDim2.new(0, 18, 0, 18), UDim2.new(0, 10, 0.5, -9), icAccent())
	IC.title = Instance.new("TextLabel")
	IC.title.Size = UDim2.new(0.6, 0, 0, 16); IC.title.Position = UDim2.new(0, 34, 0, 5)
	IC.title.BackgroundTransparency = 1; IC.title.Text = (Library.LoadingScreen and Library.LoadingScreen.HubName) or "ZETHUB"
	IC.title.TextColor3 = icAccent(); IC.title.TextSize = 14; IC.title.Font = Enum.Font.GothamBlack; IC.title.TextXAlignment = Enum.TextXAlignment.Left; IC.title.Parent = hdr
	IC.sub = Instance.new("TextLabel")
	IC.sub.Size = UDim2.new(0.6, 0, 0, 12); IC.sub.Position = UDim2.new(0, 34, 0, 20)
	IC.sub.BackgroundTransparency = 1; IC.sub.Text = GameChecker.GameName .. "  ·  " .. ((Library.LoadingScreen and Library.LoadingScreen.Version) or "V5.5")
	IC.sub.TextColor3 = Theme.SubText; IC.sub.TextSize = 10; IC.sub.Font = Enum.Font.Gotham; IC.sub.TextXAlignment = Enum.TextXAlignment.Left; IC.sub.TextTruncate = Enum.TextTruncate.AtEnd; IC.sub.Parent = hdr
	IC.sub = IC.sub
	local hideBtn = Instance.new("TextButton")
	hideBtn.Size = UDim2.new(0, 22, 0, 22); hideBtn.Position = UDim2.new(1, -28, 0.5, -11)
	hideBtn.BackgroundTransparency = 1; hideBtn.Text = "x"; hideBtn.TextColor3 = Theme.SubText; hideBtn.TextSize = 14; hideBtn.Font = Enum.Font.GothamBold; hideBtn.AutoButtonColor = false; hideBtn.Parent = hdr
	hideBtn.MouseButton1Click:Connect(function() IC.Visible = false; gui.Enabled = false end)

	-- body grid 2 kolom
	local body = Instance.new("Frame")
	body.Size = UDim2.new(1, -20, 1, -44); body.Position = UDim2.new(0, 10, 0, 38)
	body.BackgroundTransparency = 1; body.BorderSizePixel = 0; body.Parent = root
	local bg = Instance.new("UIGridLayout"); bg.CellSize = UDim2.new(0.5, -5, 0, 0); bg.CellPadding = UDim2.new(0, 10, 0, 8); bg.SortOrder = Enum.SortOrder.LayoutOrder; bg.Parent = body
	-- pakai UIListLayout horizontal-wrap tidak ada; jadi kita manual 2 kolom via frame kolom
	bg:Destroy()
	local colL = Instance.new("Frame"); colL.Size = UDim2.new(0.5, -5, 1, 0); colL.Position = UDim2.new(0, 0, 0, 0); colL.BackgroundTransparency = 1; colL.BorderSizePixel = 0; colL.Parent = body
	local colR = Instance.new("Frame"); colR.Size = UDim2.new(0.5, -5, 1, 0); colR.Position = UDim2.new(0.5, 5, 0, 0); colR.BackgroundTransparency = 1; colR.BorderSizePixel = 0; colR.Parent = body
	local ll = Instance.new("UIListLayout"); ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.Padding = UDim.new(0, 8); ll.Parent = colL
	local lr = Instance.new("UIListLayout"); lr.SortOrder = Enum.SortOrder.LayoutOrder; lr.Padding = UDim.new(0, 8); lr.Parent = colR

	-- OPERATOR card (kiri)
	local _, opBody = icCard(colL, 1, "Operator", function() return Color3.fromRGB(46, 230, 110) end)
	local av = Instance.new("ImageLabel"); av.Size = UDim2.new(0, 30, 0, 30); av.BackgroundColor3 = Theme.Element; av.BorderSizePixel = 0; av.LayoutOrder = 0; av.Parent = opBody; Corner(av, 99)
	av.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
	icAddRef(av, "BackgroundColor3", function() return Theme.Element end)
	local dn = icLabel(opBody, LocalPlayer.DisplayName, function() return Theme.Text end, 12, Enum.Font.GothamBold, 1)
	local un = icLabel(opBody, "@" .. LocalPlayer.Name .. "   UserId " .. LocalPlayer.UserId, function() return Theme.SubText end, 10, Enum.Font.Gotham, 2)
	local opBtn = Instance.new("Frame"); opBtn.Size = UDim2.new(1, 0, 0, 20); opBtn.BackgroundTransparency = 1; opBtn.BorderSizePixel = 0; opBtn.LayoutOrder = 3; opBtn.Parent = opBody
	local opl = Instance.new("UIListLayout"); opl.FillDirection = Enum.FillDirection.Horizontal; opl.Padding = UDim.new(0, 4); opl.SortOrder = Enum.SortOrder.LayoutOrder; opl.Parent = opBtn
	icMiniBtn(opBtn, "Copy UserId", 1, function() if copyText(LocalPlayer.UserId) then Library:Notify("UserId disalin.", 2, "Operator", "check") end end)
	icMiniBtn(opBtn, "Copy Name", 2, function() if copyText(LocalPlayer.Name) then Library:Notify("Nama disalin.", 2, "Operator", "check") end end)

	-- PLACE card (kanan)
	local _, plBody = icCard(colR, 1, "Place", function() return Color3.fromRGB(170, 90, 255) end)
	icLabel(plBody, GameChecker.GameName, function() return Theme.Text end, 12, Enum.Font.GothamBold, 1)
	icLabel(plBody, "PLACE " .. GameChecker.PlaceId, function() return Theme.SubText end, 10, Enum.Font.Gotham, 2)
	local plBtn = Instance.new("Frame"); plBtn.Size = UDim2.new(1, 0, 0, 20); plBtn.BackgroundTransparency = 1; plBtn.BorderSizePixel = 0; plBtn.LayoutOrder = 3; plBtn.Parent = plBody
	local pll = Instance.new("UIListLayout"); pll.FillDirection = Enum.FillDirection.Horizontal; pll.Padding = UDim.new(0, 4); pll.SortOrder = Enum.SortOrder.LayoutOrder; pll.Parent = plBtn
	icMiniBtn(plBtn, "Rejoin Server", 1, function() rejoinServer() end)
	icMiniBtn(plBtn, "Copy Job ID", 2, function() local j = ""; pcall(function() j = game.JobId end); if copyText(j) then Library:Notify("JobId disalin.", 2, "Place", "check") end end)

	-- FRAME RATE (kiri)
	local _, frBody = icCard(colL, 2, "Frame Rate", function() return Color3.fromRGB(46, 230, 110) end)
	local frVal = icLabel(frBody, currentFps .. " FPS", function() return Color3.fromRGB(46, 230, 110) end, 16, Enum.Font.GothamBlack, 1)
	IC.bars.fps = makeBars(frBody, 14); IC.bars.fps._order = 2
	-- atur order bar
	for _, ch in ipairs(frBody:GetChildren()) do if ch:IsA("Frame") and ch ~= frVal then end end

	-- NETWORK PING (kanan)
	local _, npBody = icCard(colR, 2, "Network Ping", function() return Color3.fromRGB(60, 170, 255) end)
	local npVal = icLabel(npBody, currentPing .. " ms", function() return Color3.fromRGB(60, 170, 255) end, 16, Enum.Font.GothamBlack, 1)
	IC.bars.ping = makeBars(npBody, 14)

	-- SESSION INFO (kiri)
	local _, seBody = icCard(colL, 3, "Session Info", function() return Theme.SubText end)
	local sePlayers = icLabel(seBody, "Players: 0/0", function() return Theme.Text end, 11, Enum.Font.GothamMedium, 1)
	local seUp = icLabel(seBody, "Server up: 0h 00m 00s", function() return Theme.SubText end, 10, Enum.Font.Gotham, 2)
	local seSess = icLabel(seBody, "Session: 0h 00m 00s", function() return Theme.SubText end, 10, Enum.Font.Gotham, 3)

	-- KEY STATUS (kanan)
	local _, ksBody = icCard(colR, 3, "Key Status", function() return Color3.fromRGB(46, 230, 110) end)
	local ksTitle = (Library.KeyStatus and Library.KeyStatus.Title) or "No key required"
	local ksSub = (Library.KeyStatus and Library.KeyStatus.Sub) or "This script is free"
	icLabel(ksBody, ksTitle, function() return Color3.fromRGB(46, 230, 110) end, 13, Enum.Font.GothamBold, 1)
	icLabel(ksBody, ksSub, function() return Theme.SubText end, 10, Enum.Font.Gotham, 2)

	-- live updater
	task.spawn(function()
		while IC.Gui and IC.Gui.Parent do
			task.wait(1)
			if Library._destroyed or (type(Env) == "table" and Env.ZethHubGeneration ~= Library.Generation) then return end
			if frVal and frVal.Parent then frVal.Text = math.min(currentFps, 999) .. " FPS" end
			if npVal and npVal.Parent then npVal.Text = currentPing .. " ms" end
			if IC.bars.fps then IC.bars.fps:Push(currentFps, 120) end
			if IC.bars.ping then IC.bars.ping:Push(currentPing, 300) end
			local pc = 0; pcall(function() pc = #Players:GetPlayers() end)
			local mx = 0; pcall(function() mx = game.MaxPlayers end)
			if sePlayers and sePlayers.Parent then sePlayers.Text = "Players: " .. pc .. "/" .. (mx > 0 and mx or "?") end
			local up = os.clock() - sessionStart
			if seUp and seUp.Parent then seUp.Text = "Server up: " .. fmtDur(up) end
			if seSess and seSess.Parent then seSess.Text = "Session: " .. fmtDur(up) end
		end
	end)

	-- drag header
	local dragging, ds, doff = false, nil, nil
	hdr.InputBegan:Connect(function(inp) if isPressInput(inp) then dragging = true; ds = inp.Position; doff = root.Position end end)
	Connect(UserInputService.InputChanged, function(inp)
		if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			local d = inp.Position - ds
			root.Position = UDim2.new(doff.X.Scale, doff.X.Offset + d.X, doff.Y.Scale, doff.Y.Offset + d.Y)
		end
	end, nil)
	Connect(UserInputService.InputEnded, function(inp) if isPressInput(inp) then dragging = false end end, nil)

	function IC:SetVisible(v) IC.Visible = v and true or false; if gui then gui.Enabled = IC.Visible end end
	icApplyTheme()
end

-- ============================================================
-- WINDOW (bagian 1) + CreateTab (semua elemen)
-- ============================================================
function Library:CreateWindow(config)
	if Library._destroyed or (type(Env) == "table" and Env.ZethHubGeneration ~= Library.Generation) then return nil end
	config = config or {}
	local title = config.Title or "ZETHUB"
	local subtitle = config.Subtitle or "V5.5 • Quick Bar / Info Panel"
	local OPEN_SIZE = UDim2.new(0, 560, 0, 420)
	local gui = Instance.new("ScreenGui")
	gui.Name = "ZethHubV5"; gui.ResetOnSpawn = false; gui.DisplayOrder = 998; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	pcall(function() gui.Parent = game:GetService("CoreGui") end)
	if not gui.Parent then pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end) end

	local themeRefs = {}
	local function registerThemeRef(obj, prop, key) if obj then table.insert(themeRefs, { obj = obj, prop = prop, key = key }) end end

	local main = Instance.new("Frame")
	main.Name = "Main"; main.AnchorPoint = Vector2.new(0.5, 0.5); main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.Size = OPEN_SIZE; main.BackgroundColor3 = Theme.Background; main.BorderSizePixel = 0; main.ClipsDescendants = true
	main.Active = true; main.ZIndex = 40; main.Parent = gui
	Corner(main, 12); registerThemeRef(main, "BackgroundColor3", "Background")
	local mainStroke = Stroke(main, Color3.new(1, 1, 1), Theme.MainBorderThickness); registerRGB(mainStroke)
	local mainGlow
	if Theme.BorderGlow and Library.Effects.Glow then
		mainGlow = Instance.new("UIStroke"); mainGlow.Name = "MainBorderGlow"; mainGlow.Thickness = Theme.MainBorderThickness + 2.2
		mainGlow.Transparency = Theme.GlowTransparency or 0.68; mainGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual; mainGlow.Parent = main; registerRGB(mainGlow)
	end
	if Library.Effects.Shadow then pcall(function() local sh = Instance.new("UIDropShadow"); sh.Color = Color3.new(0,0,0); sh.Transparency = 0.45; sh.Size = UDim2.new(0,28,0,28); sh.Offset = Vector2.new(0,10); sh.Parent = main end) end
	local particleLayer = createParticleBackground(main, Theme.ParticleCount, nil)

	-- Tooltip
	local Tooltip, ttText
	Tooltip = Instance.new("Frame"); Tooltip.Size = UDim2.new(0, 10, 0, 22); Tooltip.BackgroundColor3 = Color3.fromRGB(5,5,5)
	Tooltip.BorderSizePixel = 0; Tooltip.ZIndex = 200; Tooltip.Visible = false; Tooltip.Parent = gui; Corner(Tooltip, 4)
	Stroke(Tooltip, Color3.fromRGB(255,255,255), 1).Transparency = 0.8
	ttText = Instance.new("TextLabel"); ttText.Size = UDim2.new(1, -10, 1, 0); ttText.Position = UDim2.new(0, 5, 0, 0)
	ttText.BackgroundTransparency = 1; ttText.TextColor3 = Color3.fromRGB(255,255,255); ttText.TextSize = 11; ttText.Font = Enum.Font.Gotham
	ttText.TextXAlignment = Enum.TextXAlignment.Left; ttText.Parent = Tooltip
	local function ShowTooltip(text) ttText.Text = text; Tooltip.Size = UDim2.new(0, ttText.TextBounds.X + 12, 0, 22); Tooltip.Visible = true end
	local function HideTooltip() Tooltip.Visible = false end
	local function addTooltip(obj, text) if text then obj.MouseEnter:Connect(function() ShowTooltip(text) end); obj.MouseLeave:Connect(function() HideTooltip() end) end end
	Connect(RunService.RenderStepped, function() if Tooltip.Visible then local m = UserInputService:GetMouseLocation(); Tooltip.Position = UDim2.new(0, m.X + 15, 0, m.Y + 15) end end, nil)

	-- Topbar
	local topbar = Instance.new("Frame"); topbar.Size = UDim2.new(1, 0, 0, TOPBAR_H); topbar.BackgroundTransparency = 1; topbar.ZIndex = 45; topbar.Parent = main
	local titleRow = Instance.new("Frame"); titleRow.Size = UDim2.new(1, -110, 0, 24); titleRow.Position = UDim2.new(0, 16, 0, 7)
	titleRow.BackgroundTransparency = 1; titleRow.ZIndex = 46; titleRow.Active = false; titleRow.Parent = topbar
	local titleLayout = Instance.new("UIListLayout"); titleLayout.FillDirection = Enum.FillDirection.Horizontal; titleLayout.SortOrder = Enum.SortOrder.LayoutOrder
	titleLayout.Padding = UDim.new(0, 8); titleLayout.VerticalAlignment = Enum.VerticalAlignment.Center; titleLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left; titleLayout.Parent = titleRow
	local titleLbl = Instance.new("TextLabel"); titleLbl.Size = UDim2.new(0, 0, 0, 18); titleLbl.AutomaticSize = Enum.AutomaticSize.X
	titleLbl.BackgroundTransparency = 1; titleLbl.Text = title; titleLbl.TextColor3 = Theme.Text; titleLbl.TextSize = 15; titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.LayoutOrder = 1; titleLbl.ZIndex = 47; titleLbl.Parent = titleRow; registerThemeRef(titleLbl, "TextColor3", "Text")
	local subLbl = Instance.new("TextLabel"); subLbl.Size = UDim2.new(0.6, 0, 0, 14); subLbl.Position = UDim2.new(0, 16, 0, 31)
	subLbl.BackgroundTransparency = 1; subLbl.Text = subtitle; subLbl.TextColor3 = Theme.SubText; subLbl.TextSize = 11; subLbl.Font = Enum.Font.Gotham
	subLbl.TextXAlignment = Enum.TextXAlignment.Left; subLbl.ZIndex = 46; subLbl.Parent = topbar; registerThemeRef(subLbl, "TextColor3", "SubText")
	local tagRow = Instance.new("Frame"); tagRow.Size = UDim2.new(0, 0, 0, 22); tagRow.AutomaticSize = Enum.AutomaticSize.X; tagRow.BackgroundTransparency = 1
	tagRow.ZIndex = 47; tagRow.Active = false; tagRow.LayoutOrder = 2; tagRow.Parent = titleRow
	local tagLayout = Instance.new("UIListLayout"); tagLayout.FillDirection = Enum.FillDirection.Horizontal; tagLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tagLayout.Padding = UDim.new(0, 6); tagLayout.VerticalAlignment = Enum.VerticalAlignment.Center; tagLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left; tagLayout.Parent = tagRow

	local window
	local function getCloseColor() return (window and window.closeColor) or Library.CloseColor or Theme.Close end
	local function getCloseHoverColor() return (window and window.closeHoverColor) or Library.CloseHoverColor or Theme.CloseHover end
	local function getClosePressedColor() return (window and window.closePressedColor) or Library.ClosePressedColor or Theme.ClosePressed end
	local function getCloseTextColor() return (window and window.closeTextColor) or Theme.CloseText end
	local function iconButton(xoff, kind)
		local b = Instance.new("TextButton"); b.Size = UDim2.new(0, 26, 0, 26); b.Position = UDim2.new(1, xoff, 0.5, -13)
		b.BackgroundColor3 = Theme.Element; b.BorderSizePixel = 0; b.Text = ""; b.AutoButtonColor = false; b.ZIndex = 48; b.Parent = topbar; Corner(b, 6)
		registerThemeRef(b, "BackgroundColor3", "Element")
		local scale = Instance.new("UIScale"); scale.Parent = b
		local lines = {}; local overlay
		if kind == "close" then
			overlay = Instance.new("Frame"); overlay.Name = "CloseBlur"; overlay.AnchorPoint = Vector2.new(0.5, 0.5); overlay.Position = UDim2.new(0.5, 0, 0.5, 0)
			overlay.Size = UDim2.new(0, 0, 0, 0); overlay.BackgroundColor3 = getCloseColor(); overlay.BackgroundTransparency = 1; overlay.BorderSizePixel = 0
			overlay.ZIndex = 48; overlay.Visible = false; overlay.Parent = b; Corner(overlay, 99)
			for _, rot in ipairs({ 45, -45 }) do
				local l = Instance.new("Frame"); l.Size = UDim2.new(0, 12, 0, 2); l.Position = UDim2.new(0.5, -6, 0.5, -1); l.Rotation = rot
				l.BackgroundColor3 = Theme.SubText; l.BorderSizePixel = 0; l.ZIndex = 49; l.Parent = b; table.insert(lines, l); registerThemeRef(l, "BackgroundColor3", "SubText")
			end
			b.MouseEnter:Connect(function() if Library._confirmOpen then return end; Tween(b, .2, { BackgroundColor3 = getCloseHoverColor() }); for _, l in ipairs(lines) do Tween(l, .2, { BackgroundColor3 = getCloseTextColor() }) end end)
			b.MouseLeave:Connect(function() Tween(b, .2, { BackgroundColor3 = Theme.Element }); for _, l in ipairs(lines) do Tween(l, .2, { BackgroundColor3 = Theme.SubText }) end end)
		else
			local l = Instance.new("Frame"); l.Size = UDim2.new(0, 12, 0, 2); l.Position = UDim2.new(0.5, -6, 0.5, -1); l.BackgroundColor3 = Theme.SubText
			l.BorderSizePixel = 0; l.ZIndex = 49; l.Parent = b; table.insert(lines, l); registerThemeRef(l, "BackgroundColor3", "SubText")
			b.MouseEnter:Connect(function() if Library._confirmOpen then return end; Tween(b, .2, { BackgroundColor3 = Theme.ElementHover }); for _, line in ipairs(lines) do Tween(line, .2, { BackgroundColor3 = Theme.Text }) end end)
			b.MouseLeave:Connect(function() Tween(b, .2, { BackgroundColor3 = Theme.Element }); for _, line in ipairs(lines) do Tween(line, .2, { BackgroundColor3 = Theme.SubText }) end end)
		end
		b.InputBegan:Connect(function(inp) if isPressInput(inp) then Library._buttonPressLock = true; if kind == "close" then playCloseBlur(b, overlay, scale, lines, getClosePressedColor(), getCloseTextColor()) else Tween(scale, .08, { Scale = .86 }, Enum.EasingStyle.Back, Enum.EasingDirection.In); Tween(b, .08, { BackgroundColor3 = Theme.ElementHover }); for _, line in ipairs(lines) do Tween(line, .08, { BackgroundColor3 = Theme.Text }) end end end end)
		b.InputEnded:Connect(function(inp) if isPressInput(inp) then if not Library._confirmOpen then Library._buttonPressLock = false end; local hovered = false; pcall(function() hovered = b:IsHovered() end); if kind == "close" then Tween(b, .16, { BackgroundColor3 = hovered and getCloseHoverColor() or Theme.Element }); for _, l in ipairs(lines) do Tween(l, .16, { BackgroundColor3 = hovered and getCloseTextColor() or Theme.SubText }) end else Tween(b, .16, { BackgroundColor3 = hovered and Theme.ElementHover or Theme.Element }); for _, l in ipairs(lines) do Tween(l, .16, { BackgroundColor3 = hovered and Theme.Text or Theme.SubText }) end end; if scale and scale.Parent then Tween(scale, .14, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out) end end end)
		return b, { btn = b, lines = lines, overlay = overlay, scale = scale }
	end
	local minimizeBtn, minimizeBtnData = iconButton(-62, "min")
	local closeBtn, closeBtnData = iconButton(-32, "close")

	window = {
		accent = config.Accent or Library.Accent,
		closeColor = config.CloseColor or Library.CloseColor or Theme.Close,
		closeHoverColor = config.CloseHoverColor or Library.CloseHoverColor or Theme.CloseHover,
		closePressedColor = config.ClosePressedColor or Library.ClosePressedColor or Theme.ClosePressed,
		closeTextColor = config.CloseTextColor or Theme.CloseText,
		listeners = {}, offset = Vector2.new(0, 0), _connections = {}, _destroyed = false, _gui = gui,
		_closeConfirmCleanup = nil, _closeButtonData = nil, _minimizeButtonData = nil, _themeRefs = themeRefs,
	}
	window._closeButtonData = closeBtnData; window._minimizeButtonData = minimizeBtnData
	if config.Accent and typeof(config.Accent) == "Color3" then Library.Accent = config.Accent; ThemeManager.Dirty = true end
	function window:ApplyTheme()
		if self._destroyed then return end
		for _, ref in ipairs(themeRefs) do if ref.obj and ref.obj.Parent then local c = Theme[ref.key]; if c then pcall(function() ref.obj[ref.prop] = c end) end end end
		refreshRGBColors()
	end
	function window:Destroy()
		if self._destroyed then return end
		self._destroyed = true
		if self._closeConfirmCleanup then pcall(self._closeConfirmCleanup) end
		for _, conn in ipairs(self._connections) do pcall(function() conn:Disconnect() end) end
		self._connections = {}; self.listeners = {}; self._themeRefs = {}
		local removeFlags = {}
		for flag, el in pairs(Library._elements) do if el.Window == self then removeFlags[#removeFlags + 1] = flag end end
		for _, flag in ipairs(removeFlags) do Library._elements[flag] = nil end
		for _, item in ipairs(Library._searchIndex) do if item.Window == self then item._removed = true end end
		pcall(function() gui:Destroy() end)
		for i, w in ipairs(Library._windows) do if w == self then table.remove(Library._windows, i); break end end
		if #Library._windows == 0 then Library.Open = false end
	end
	table.insert(Library._windows, window)
	function window:onAccent(fn) table.insert(self.listeners, fn); fn(self.accent) end
	function window:SetCloseColor(color, hover, pressed, text)
		if typeof(color) == "Color3" then self.closeColor = color end
		if typeof(hover) == "Color3" then self.closeHoverColor = hover end
		if typeof(pressed) == "Color3" then self.closePressedColor = pressed end
		if typeof(text) == "Color3" then self.closeTextColor = text end
	end
	function window:AddTag(cfg)
		cfg = cfg or {}
		local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0, 0, 0, 22); lbl.AutomaticSize = Enum.AutomaticSize.X
		lbl.BackgroundColor3 = cfg.Color or window.accent; lbl.BorderSizePixel = 0; lbl.Text = cfg.Text or cfg.Name or cfg.Title or "Tag"
		lbl.TextColor3 = cfg.TextColor or cfg.TextColor3 or Color3.fromRGB(0, 0, 0); lbl.TextSize = 11; lbl.Font = Enum.Font.GothamBold
		lbl.TextXAlignment = Enum.TextXAlignment.Center; lbl.TextWrapped = false; lbl.ZIndex = 47; lbl.Active = false; lbl.Parent = tagRow; Corner(lbl, 99); Pad(lbl, 0, 10, 0, 10)
		if cfg.FollowAccent then window:onAccent(function(c) lbl.BackgroundColor3 = c end) end
		return lbl
	end
	local tagCount = 0
	local function addConfigTag(v)
		tagCount += 1; local index = tagCount
		if type(v) == "string" then v = { Text = v } end
		local bg = v.Color or v.BackgroundColor3; local followAccent = false
		if not bg then if index == 1 then bg = Color3.fromRGB(255, 204, 0) elseif index == 2 then bg = Color3.fromRGB(46, 230, 110) else bg = window.accent; followAccent = true end end
		local tc = v.TextColor or v.TextColor3
		if not tc then local bright = (bg.R + bg.G + bg.B) / 3; tc = bright > 0.62 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255) end
		window:AddTag({ Text = v.Text or v.Name or v.Title or "Tag", Color = bg, TextColor = tc, FollowAccent = followAccent })
	end
	local tagsConfig = config.Tags
	if tagsConfig == nil then tagsConfig = { { Text = "V5.5", Color = Color3.fromRGB(255, 204, 0), TextColor = Color3.fromRGB(0, 0, 0) }, { Text = "Quick Bar", Color = Color3.fromRGB(46, 230, 110), TextColor = Color3.fromRGB(0, 0, 0) } } end
	if tagsConfig ~= false and type(tagsConfig) == "table" then
		if tagsConfig.Text or tagsConfig.Name or tagsConfig.Title then addConfigTag(tagsConfig) else for _, v in ipairs(tagsConfig) do addConfigTag(v) end end
	end

	-- Resize + Drag
	local resizeHandle = Instance.new("TextButton"); resizeHandle.Size = UDim2.new(0, 14, 0, 14); resizeHandle.Position = UDim2.new(1, -15, 1, -15)
	resizeHandle.BackgroundTransparency = 1; resizeHandle.Text = ""; resizeHandle.AutoButtonColor = false; resizeHandle.ZIndex = 50; resizeHandle.Parent = main
	for i = 0, 2 do local d = Instance.new("Frame"); d.Size = UDim2.new(0, 2 + i * 4, 0, 2); d.AnchorPoint = Vector2.new(1, 1); d.Position = UDim2.new(1, -2, 1, -2 - i * 4)
		d.BackgroundColor3 = Theme.SubText; d.BorderSizePixel = 0; d.ZIndex = 51; d.Parent = resizeHandle; registerThemeRef(d, "BackgroundColor3", "SubText") end
	local resizing, resizeStart, resizeOrig = false, nil, nil
	local function getInputPosition(inp) if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.MouseButton1 then return inp.Position end return nil end
	Connect(resizeHandle.InputBegan, function(inp) if Library._confirmOpen or Library._buttonPressLock then return end; if isPressInput(inp) then resizing = true; resizeStart = getInputPosition(inp); resizeOrig = main.Size end end, window)
	Connect(UserInputService.InputChanged, function(inp) if Library._confirmOpen or Library._buttonPressLock then resizing = false; return end; if resizing then local pos = getInputPosition(inp); if pos and resizeStart then local d = pos - resizeStart; main.Size = UDim2.new(0, math.clamp(resizeOrig.X.Offset + d.X, 460, 1100), 0, math.clamp(resizeOrig.Y.Offset + d.Y, 340, 760)) end end end, window)
	Connect(UserInputService.InputEnded, function(inp) if isPressInput(inp) then resizing = false; if not Library._confirmOpen then Library._buttonPressLock = false end end end, window)
	local dragging, dragStart, dragOrig
	Connect(topbar.InputBegan, function(inp) if Library._confirmOpen or Library._buttonPressLock then return end; if isPressInput(inp) then dragging = true; dragStart = inp.Position; dragOrig = window.offset end end, window)
	Connect(UserInputService.InputEnded, function(inp) if isPressInput(inp) then dragging = false; if not Library._confirmOpen then Library._buttonPressLock = false end end end, window)
	Connect(UserInputService.InputChanged, function(inp) if Library._confirmOpen or Library._buttonPressLock then dragging = false; return end; if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then local d = inp.Position - dragStart; local vp = workspace.CurrentCamera.ViewportSize; local x = math.clamp(dragOrig.X + d.X, -(vp.X / 2 - 80), vp.X / 2 - 80); local y = math.clamp(dragOrig.Y + d.Y, -(vp.Y / 2 - 60), vp.Y / 2 - 60); window.offset = Vector2.new(x, y); main.Position = UDim2.new(0.5, x, 0.5, y) end end, window)

	-- Sidebar (search sticky + tab scrollable)
	local SIDE_PAD = 8; local SEARCH_H = 34
	local sidebar = Instance.new("Frame"); sidebar.Size = UDim2.new(0, 150, 1, -TOPBAR_H); sidebar.Position = UDim2.new(0, 0, 0, TOPBAR_H)
	sidebar.BackgroundColor3 = Theme.Sidebar; sidebar.BorderSizePixel = 0; sidebar.ClipsDescendants = true; sidebar.ZIndex = 41; sidebar.Parent = main; Corner(sidebar, 10)
	registerThemeRef(sidebar, "BackgroundColor3", "Sidebar")
	local sideStroke = Stroke(sidebar, Theme.Border, 1.2); sideStroke.Transparency = 0.35; registerThemeRef(sideStroke, "Color", "Border")
	local searchBar = Instance.new("Frame"); searchBar.Name = "SearchBar"; searchBar.Size = UDim2.new(1, -(SIDE_PAD * 2), 0, SEARCH_H); searchBar.Position = UDim2.new(0, SIDE_PAD, 0, SIDE_PAD)
	searchBar.BackgroundColor3 = Theme.Element; searchBar.BackgroundTransparency = 0.08; searchBar.BorderSizePixel = 0; searchBar.ZIndex = 43; searchBar.Parent = sidebar; Corner(searchBar, 8)
	registerThemeRef(searchBar, "BackgroundColor3", "Element")
	local searchStroke = Stroke(searchBar, Theme.Border, 1.4); registerThemeRef(searchStroke, "Color", "Border")
	local searchIcon = makeIcon(searchBar, "search", UDim2.new(0, 14, 0, 14), UDim2.new(0, 10, 0.5, -7), Theme.SubText)
	if searchIcon then registerThemeRef(searchIcon, "ImageColor3", "SubText") end
	local searchIconOffset = searchIcon and 32 or 12
	local searchInput = Instance.new("TextBox"); searchInput.Name = "SearchInput"; searchInput.Size = UDim2.new(1, -(searchIconOffset + 10), 0, 26); searchInput.Position = UDim2.new(0, searchIconOffset, 0.5, -13)
	searchInput.BackgroundTransparency = 1; searchInput.BorderSizePixel = 0; searchInput.PlaceholderText = "Search..."; searchInput.PlaceholderColor3 = Theme.SubText
	searchInput.Text = ""; searchInput.TextColor3 = Theme.Text; searchInput.TextSize = 12; searchInput.Font = Enum.Font.GothamMedium
	searchInput.TextXAlignment = Enum.TextXAlignment.Left; searchInput.TextYAlignment = Enum.TextYAlignment.Center; searchInput.ClearTextOnFocus = false; searchInput.ZIndex = 44; searchInput.Parent = searchBar
	registerThemeRef(searchInput, "TextColor3", "Text"); registerThemeRef(searchInput, "PlaceholderColor3", "SubText")
	local tabScroll = Instance.new("ScrollingFrame"); tabScroll.Name = "TabScroll"; tabScroll.Size = UDim2.new(1, -(SIDE_PAD * 2), 1, -(SEARCH_H + SIDE_PAD * 2 + 6)); tabScroll.Position = UDim2.new(0, SIDE_PAD, 0, SEARCH_H + SIDE_PAD + 6)
	tabScroll.BackgroundTransparency = 1; tabScroll.BorderSizePixel = 0; tabScroll.ScrollBarThickness = 3; tabScroll.ScrollBarImageColor3 = window.accent
	tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0); tabScroll.ScrollingDirection = Enum.ScrollingDirection.Y; tabScroll.ElasticBehavior = Enum.ElasticBehavior.Always; tabScroll.ZIndex = 42; tabScroll.Parent = sidebar
	window:onAccent(function(c) tabScroll.ScrollBarImageColor3 = c end)
	local sideList = Instance.new("UIListLayout"); sideList.SortOrder = Enum.SortOrder.LayoutOrder; sideList.Padding = UDim.new(0, 5); sideList.Parent = tabScroll
	local sidePad = Instance.new("UIPadding"); sidePad.PaddingTop = UDim.new(0, 2); sidePad.PaddingBottom = UDim.new(0, 14); sidePad.PaddingLeft = UDim.new(0, 0); sidePad.PaddingRight = UDim.new(0, 4); sidePad.Parent = tabScroll

	-- Content
	local content = Instance.new("ScrollingFrame"); content.Size = UDim2.new(1, -150, 1, -TOPBAR_H); content.Position = UDim2.new(0, 150, 0, TOPBAR_H)
	content.BackgroundTransparency = 1; content.BorderSizePixel = 0; content.ScrollBarThickness = 3; content.ScrollBarImageColor3 = window.accent
	content.AutomaticCanvasSize = Enum.AutomaticSize.Y; content.CanvasSize = UDim2.new(0, 0, 0, 0); content.ZIndex = 41; content.Parent = main
	window:onAccent(function(c) content.ScrollBarImageColor3 = c end)
	local container = Instance.new("Frame"); container.Size = UDim2.new(1, -24, 0, 0); container.Position = UDim2.new(0, 12, 0, 10); container.BackgroundTransparency = 1; container.AutomaticSize = Enum.AutomaticSize.Y; container.Parent = content
	local containerList = Instance.new("UIListLayout"); containerList.SortOrder = Enum.SortOrder.LayoutOrder; containerList.Padding = UDim.new(0, 8); containerList.Parent = container
	local containerPad = Instance.new("UIPadding"); containerPad.PaddingTop = UDim.new(0, 0); containerPad.PaddingBottom = UDim.new(0, 16); containerPad.PaddingLeft = UDim.new(0, 0); containerPad.PaddingRight = UDim.new(0, 0); containerPad.Parent = container
	local spacer = Instance.new("Frame"); spacer.Size = UDim2.new(1, 0, 0, 2); spacer.BackgroundTransparency = 1; spacer.Parent = container
	local info = nil

	-- Search Results popup
	local searchResults = Instance.new("ScrollingFrame"); searchResults.Name = "SearchResults"; searchResults.Size = UDim2.new(0, 220, 0, 0); searchResults.Position = UDim2.new(0, 0, 0, 0)
	searchResults.BackgroundColor3 = Theme.Element; searchResults.BackgroundTransparency = 0.02; searchResults.BorderSizePixel = 0; searchResults.ScrollBarThickness = 2; searchResults.ScrollBarImageColor3 = Theme.Border
	searchResults.AutomaticCanvasSize = Enum.AutomaticSize.Y; searchResults.CanvasSize = UDim2.new(0, 0, 0, 0); searchResults.Visible = false; searchResults.ZIndex = 250; searchResults.Parent = gui; Corner(searchResults, 8)
	registerThemeRef(searchResults, "BackgroundColor3", "Element")
	local searchResStroke = Stroke(searchResults, Theme.Border, 1.5); registerThemeRef(searchResStroke, "Color", "Border"); Pad(searchResults, 4, 4, 4, 4)
	local searchResultList = Instance.new("UIListLayout"); searchResultList.SortOrder = Enum.SortOrder.LayoutOrder; searchResultList.Padding = UDim.new(0, 4); searchResultList.Parent = searchResults
	local function clearSearchResults() for _, c in ipairs(searchResults:GetChildren()) do if c:IsA("TextButton") or c.Name == "EmptyResult" then c:Destroy() end end end
	local function closeSearchResults() searchResults.Visible = false; searchResults.Size = UDim2.new(0, 0, 0, 0) end
	local function pulseFrame(f) if not f or not f.Parent or window._destroyed then return end; local st = Instance.new("UIStroke"); st.Name = "SearchPulse"; st.Color = window.accent; st.Thickness = 2.5; st.Transparency = 0; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; st.Parent = f; Tween(st, .7, { Transparency = 1 }); task.delay(.72, function() if st and st.Parent then st:Destroy() end end) end
	local function scrollToFrame(f) if not f or not f.Parent or not content or not content.Parent then return end; task.delay(0.08, function() if not f.Parent or not content.Parent then return end; local targetY = f.AbsolutePosition.Y - content.AbsolutePosition.Y + content.CanvasPosition.Y - 70; content.CanvasPosition = Vector2.new(0, math.max(0, targetY)) end) end
	local function addSearchResult(item)
		local b = Instance.new("TextButton"); b.Name = "SearchResult"; b.Size = UDim2.new(1, 0, 0, 32); b.BackgroundColor3 = Theme.Element; b.BackgroundTransparency = 0.18
		b.BorderSizePixel = 0; b.Text = ""; b.AutoButtonColor = false; b.ZIndex = 251; b.Parent = searchResults; Corner(b, 6)
		local nameLabel = Instance.new("TextLabel"); nameLabel.Name = "Name"; nameLabel.Size = UDim2.new(1, -58, 1, 0); nameLabel.Position = UDim2.new(0, 8, 0, 0)
		nameLabel.BackgroundTransparency = 1; nameLabel.Text = item.Name or "Unknown"; nameLabel.TextColor3 = Theme.Text; nameLabel.TextSize = 12; nameLabel.Font = Enum.Font.GothamMedium
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left; nameLabel.TextYAlignment = Enum.TextYAlignment.Center; nameLabel.TextTruncate = Enum.TextTruncate.AtEnd; nameLabel.ZIndex = 252; nameLabel.Parent = b
		local typeLabel = Instance.new("TextLabel"); typeLabel.Name = "Type"; typeLabel.Size = UDim2.new(0, 48, 1, 0); typeLabel.Position = UDim2.new(1, -54, 0, 0)
		typeLabel.BackgroundTransparency = 1; typeLabel.Text = string.upper(tostring(item.Type or "?"):sub(1, 4)); typeLabel.TextColor3 = window.accent; typeLabel.TextSize = 10; typeLabel.Font = Enum.Font.GothamBold
		typeLabel.TextXAlignment = Enum.TextXAlignment.Right; typeLabel.TextYAlignment = Enum.TextYAlignment.Center; typeLabel.ZIndex = 252; typeLabel.Parent = b
		b.MouseEnter:Connect(function() Tween(b, .14, { BackgroundTransparency = .08 }); Tween(typeLabel, .14, { TextColor3 = window.accent }) end)
		b.MouseLeave:Connect(function() Tween(b, .14, { BackgroundTransparency = .18 }) end)
		b.MouseButton1Click:Connect(function() closeSearchResults(); pcall(function() searchInput:ReleaseFocus() end); if item.Window and item.Window._destroyed then return end; if item.Tab and item.Tab.Activate then item.Tab:Activate() end; if item.Frame then scrollToFrame(item.Frame); pulseFrame(item.Frame) end end)
	end
	local function updateSearchResults()
		clearSearchResults(); local query = searchInput.Text or ""
		if #query < 1 then closeSearchResults(); return end
		local matches = Library:Search(query); local shown = 0; local width = math.max(210, searchBar.AbsoluteSize.X)
		for _, item in ipairs(matches) do if shown >= 12 then break end; addSearchResult(item); shown += 1 end
		if shown == 0 then
			local empty = Instance.new("TextLabel"); empty.Name = "EmptyResult"; empty.Size = UDim2.new(1, 0, 0, 28); empty.BackgroundTransparency = 1; empty.Text = "No results"
			empty.TextColor3 = Theme.SubText; empty.TextSize = 12; empty.Font = Enum.Font.Gotham; empty.TextXAlignment = Enum.TextXAlignment.Center; empty.TextYAlignment = Enum.TextYAlignment.Center; empty.ZIndex = 251; empty.Parent = searchResults
			searchResults.Size = UDim2.new(0, width, 0, 36); searchResults.Visible = true
		else searchResults.Size = UDim2.new(0, width, 0, math.min(230, shown * 36 + 8)); searchResults.Visible = true end
	end
	Connect(searchInput:GetPropertyChangedSignal("Text"), updateSearchResults, window)
	Connect(RunService.RenderStepped, function() if searchResults.Visible and searchBar and searchBar.Parent then searchResults.Position = UDim2.new(0, searchBar.AbsolutePosition.X, 0, searchBar.AbsolutePosition.Y + searchBar.AbsoluteSize.Y + 4) end end, window)
	Connect(UserInputService.InputBegan, function(inp, gp) if gp then return end; if inp.KeyCode == Enum.KeyCode.Escape then closeSearchResults(); pcall(function() searchInput:ReleaseFocus() end) end end, window)

	-- Keybind List
	local kbEnabled = true; local kbRows = 0; local windowOpen = true
	local KeybindList = Instance.new("Frame"); KeybindList.AnchorPoint = Vector2.new(1, 1); KeybindList.Position = UDim2.new(1, -12, 1, -12); KeybindList.Size = UDim2.new(0, 176, 0, 30)
	KeybindList.BackgroundColor3 = Theme.Background; KeybindList.BackgroundTransparency = 0.1; KeybindList.BorderSizePixel = 0; KeybindList.ZIndex = 100; KeybindList.AutomaticSize = Enum.AutomaticSize.Y; KeybindList.Visible = false; KeybindList.Parent = gui; Corner(KeybindList, 8)
	registerThemeRef(KeybindList, "BackgroundColor3", "Background"); registerRGB(Stroke(KeybindList, Color3.new(1, 1, 1), 2.2))
	local kbIcon = makeIcon(KeybindList, "key", UDim2.new(0, 14, 0, 14), UDim2.new(0, 9, 0, 7), Theme.Text); if kbIcon then registerThemeRef(kbIcon, "ImageColor3", "Text") end
	local kbTitle = Instance.new("TextLabel"); kbTitle.Size = UDim2.new(1, -32, 0, 28); kbTitle.Position = UDim2.new(0, 27, 0, 0); kbTitle.BackgroundTransparency = 1; kbTitle.Text = "KEYBINDS"
	kbTitle.TextColor3 = Theme.Text; kbTitle.TextSize = 10; kbTitle.Font = Enum.Font.GothamBold; kbTitle.TextXAlignment = Enum.TextXAlignment.Left; kbTitle.TextYAlignment = Enum.TextYAlignment.Center; kbTitle.Parent = KeybindList; registerThemeRef(kbTitle, "TextColor3", "Text")
	local kbRowsFrame = Instance.new("Frame"); kbRowsFrame.Size = UDim2.new(1, -12, 0, 0); kbRowsFrame.Position = UDim2.new(0, 6, 0, 28); kbRowsFrame.BackgroundTransparency = 1; kbRowsFrame.AutomaticSize = Enum.AutomaticSize.Y; kbRowsFrame.Parent = KeybindList
	local kbRowList = Instance.new("UIListLayout"); kbRowList.SortOrder = Enum.SortOrder.LayoutOrder; kbRowList.Padding = UDim.new(0, 3); kbRowList.Parent = kbRowsFrame
	local kbBottomPad = Instance.new("UIPadding"); kbBottomPad.PaddingBottom = UDim.new(0, 8); kbBottomPad.Parent = KeybindList
	local function refreshKbVis() KeybindList.Visible = windowOpen and kbEnabled and kbRows > 0 end
	function window:ToggleKeybindList(state) kbEnabled = (state == nil) and not kbEnabled or state; refreshKbVis() end
	function window:AddKeybind(name, keyName)
		kbRows += 1
		local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, 16); row.BackgroundTransparency = 1; row.Parent = kbRowsFrame
		local nLbl = Instance.new("TextLabel"); nLbl.Size = UDim2.new(1, -62, 1, 0); nLbl.BackgroundTransparency = 1; nLbl.Text = name; nLbl.TextColor3 = Theme.SubText; nLbl.TextSize = 11; nLbl.Font = Enum.Font.Gotham
		nLbl.TextXAlignment = Enum.TextXAlignment.Left; nLbl.TextYAlignment = Enum.TextYAlignment.Center; nLbl.TextTruncate = Enum.TextTruncate.AtEnd; nLbl.Parent = row; registerThemeRef(nLbl, "TextColor3", "SubText")
		local kLbl = Instance.new("TextLabel"); kLbl.Size = UDim2.new(0, 58, 1, 0); kLbl.Position = UDim2.new(1, -58, 0, 0); kLbl.BackgroundTransparency = 1; kLbl.Text = keyName; kLbl.TextColor3 = window.accent; kLbl.TextSize = 11; kLbl.Font = Enum.Font.GothamBold
		kLbl.TextXAlignment = Enum.TextXAlignment.Right; kLbl.TextYAlignment = Enum.TextYAlignment.Center; kLbl.Parent = row; window:onAccent(function(c) kLbl.TextColor3 = c end)
		refreshKbVis()
		return { Set = function(self, k) kLbl.Text = k end }
	end

	-- ================= CREATE TAB + ELEMEN =================
	function window:CreateTab(name, icon)
		local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, 0, 0, H_TAB); btn.BackgroundColor3 = window.accent; btn.BackgroundTransparency = 1
		btn.BorderSizePixel = 0; btn.Text = ""; btn.AutoButtonColor = false; btn.ZIndex = 42; btn.Parent = tabScroll; Corner(btn, 7)
		local ind = Instance.new("Frame"); ind.Size = UDim2.new(0, 3, 0, 16); ind.Position = UDim2.new(0, 6, 0.5, -8); ind.BackgroundColor3 = window.accent; ind.BackgroundTransparency = 1; ind.BorderSizePixel = 0; ind.ZIndex = 43; ind.Parent = btn; Corner(ind, 2)
		local tabIcon = makeIcon(btn, icon, UDim2.new(0, 16, 0, 16), UDim2.new(0, 14, 0.5, -8), Theme.SubText); if tabIcon then tabIcon.ZIndex = 43; registerThemeRef(tabIcon, "ImageColor3", "SubText") end
		local labelX = tabIcon and 36 or 14
		local tabLbl = Instance.new("TextLabel"); tabLbl.Size = UDim2.new(1, -(labelX + 8), 1, 0); tabLbl.Position = UDim2.new(0, labelX, 0, 0); tabLbl.BackgroundTransparency = 1; tabLbl.Text = name
		tabLbl.Font = Enum.Font.GothamMedium; tabLbl.TextSize = 13; tabLbl.TextColor3 = Theme.SubText; tabLbl.TextXAlignment = Enum.TextXAlignment.Left; tabLbl.TextYAlignment = Enum.TextYAlignment.Center; tabLbl.TextTruncate = Enum.TextTruncate.AtEnd; tabLbl.ZIndex = 43; tabLbl.Parent = btn; registerThemeRef(tabLbl, "TextColor3", "SubText")
		local tabContent = Instance.new("Frame"); tabContent.Size = UDim2.new(1, 0, 0, 0); tabContent.BackgroundTransparency = 1; tabContent.AutomaticSize = Enum.AutomaticSize.Y; tabContent.Visible = false; tabContent.LayoutOrder = btn.LayoutOrder; tabContent.Parent = container
		local tabList = Instance.new("UIListLayout"); tabList.SortOrder = Enum.SortOrder.LayoutOrder; tabList.Padding = UDim.new(0, 8); tabList.Parent = tabContent
		local tab = { content = tabContent, btn = btn, ind = ind, window = window, name = name }
		local function curAccent() return window.accent end
		local function setActive(on)
			if on then Tween(btn, .2, { BackgroundColor3 = curAccent(), BackgroundTransparency = .84 }); Tween(tabLbl, .2, { TextColor3 = Theme.Text }); Tween(ind, .2, { BackgroundTransparency = 0 }); if tabIcon then Tween(tabIcon, .2, { ImageColor3 = curAccent() }) end
			else Tween(btn, .2, { BackgroundTransparency = 1 }); Tween(tabLbl, .2, { TextColor3 = Theme.SubText }); Tween(ind, .2, { BackgroundTransparency = 1 }); if tabIcon then Tween(tabIcon, .2, { ImageColor3 = Theme.SubText }) end end
		end
		function tab:Activate()
			if window.currentTab == tabContent then return end
			if window.currentTab then window.currentTab.Visible = false; if window.currentTabData then window.currentTabData.setActive(false) end end
			tabContent.Visible = true; setActive(true); window.currentTab = tabContent; window.currentTabData = { setActive = setActive }; content.CanvasPosition = Vector2.new(0, 0)
		end
		btn.MouseEnter:Connect(function() if window.currentTab ~= tabContent then Tween(tabLbl, .2, { TextColor3 = Theme.Text }); Tween(btn, .2, { BackgroundTransparency = .93 }) end end)
		btn.MouseLeave:Connect(function() if window.currentTab ~= tabContent then Tween(tabLbl, .2, { TextColor3 = Theme.SubText }); Tween(btn, .2, { BackgroundColor3 = curAccent(), BackgroundTransparency = 1 }) end end)
		Connect(btn.MouseButton1Click, function() tab:Activate() end, window)
		window:onAccent(function(c) ind.BackgroundColor3 = c; if window.currentTab == tabContent then btn.BackgroundColor3 = c end end)
		if not window.currentTab then tab:Activate() end
		local function elementFrame(h)
			local f = Instance.new("Frame"); f.Size = UDim2.new(1, 0, 0, h); f.BackgroundColor3 = Theme.Element; f.BorderSizePixel = 0; f.Parent = tabContent; Corner(f, 8)
			registerThemeRef(f, "BackgroundColor3", "Element"); local s = Stroke(f, Theme.Border, Theme.ElementBorderThickness); registerThemeRef(s, "Color", "Border"); return f, s
		end
		local function hoverBorder(f, s, colFn)
			f.MouseEnter:Connect(function() Tween(f, .18, { BackgroundColor3 = Theme.ElementHover }); Tween(s, .18, { Color = (colFn and colFn()) or window.accent, Thickness = Theme.ElementBorderThickness + 0.4 }) end)
			f.MouseLeave:Connect(function() Tween(f, .18, { BackgroundColor3 = Theme.Element }); Tween(s, .18, { Color = Theme.Border, Thickness = Theme.ElementBorderThickness }) end)
		end
		function tab:CreateSection(text)
			local holder = Instance.new("Frame"); holder.Size = UDim2.new(1, 0, 0, H_SECTION); holder.BackgroundTransparency = 1; holder.Parent = tabContent
			local bar = Instance.new("Frame"); bar.Size = UDim2.new(0, 3, 0, 12); bar.Position = UDim2.new(0, 2, 0.5, -6); bar.BackgroundColor3 = window.accent; bar.BorderSizePixel = 0; bar.Parent = holder; Corner(bar, 2)
			local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -14, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = tostring(text or ""):upper()
			lbl.TextColor3 = Theme.SubText; lbl.TextSize = 11; lbl.Font = Enum.Font.GothamBold; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextYAlignment = Enum.TextYAlignment.Center; lbl.Parent = holder; registerThemeRef(lbl, "TextColor3", "SubText")
			window:onAccent(function(c) bar.BackgroundColor3 = c end); return holder
		end
		function tab:CreateLabel(text)
			text = tostring(text or "")
			local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, 0, 0, 18); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = Theme.Text; lbl.TextSize = 12; lbl.Font = Enum.Font.Gotham
			lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextYAlignment = Enum.TextYAlignment.Center; lbl.TextWrapped = true; lbl.Parent = tabContent; registerThemeRef(lbl, "TextColor3", "Text")
			local obj = { Set = function(self, t) lbl.Text = tostring(t or "") end }
			registerElement(window, tab, name, lbl, { Name = text, Keywords = { "label", "text", "info" } }, "label", obj); return obj
		end
		function tab:CreateParagraph(cfg)
			cfg = cfg or {}
			local function toText(v) if type(v) == "table" then return table.concat(v, "\n") end; return tostring(v or "") end
			local titleText = toText(cfg.Title); local contentText = toText(cfg.Content); local hasTitle = titleText ~= ""; local hasContent = contentText ~= ""
			local f = Instance.new("Frame"); f.Size = UDim2.new(1, 0, 0, 0); f.AutomaticSize = Enum.AutomaticSize.Y; f.BackgroundColor3 = Theme.Element; f.BackgroundTransparency = 0; f.BorderSizePixel = 0; f.Parent = tabContent; Corner(f, 8)
			registerThemeRef(f, "BackgroundColor3", "Element"); local s = Stroke(f, Theme.Border, Theme.ElementBorderThickness); registerThemeRef(s, "Color", "Border")
			local pad = Instance.new("UIPadding"); pad.PaddingTop = UDim.new(0, 12); pad.PaddingLeft = UDim.new(0, 12); pad.PaddingBottom = UDim.new(0, 12); pad.PaddingRight = UDim.new(0, 12); pad.Parent = f
			local layout = Instance.new("UIListLayout"); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0, 0); layout.Parent = f
			local sizeConstraint = Instance.new("UISizeConstraint"); sizeConstraint.MinSize = Vector2.new(0, 58); sizeConstraint.MaxSize = Vector2.new(999999, 999999); sizeConstraint.Parent = f
			local titleRow = Instance.new("Frame"); titleRow.Size = UDim2.new(1, 0, 0, 0); titleRow.AutomaticSize = Enum.AutomaticSize.Y; titleRow.BackgroundTransparency = 1; titleRow.LayoutOrder = 1; titleRow.Parent = f
			local rowLayout = Instance.new("UIListLayout"); rowLayout.FillDirection = Enum.FillDirection.Horizontal; rowLayout.SortOrder = Enum.SortOrder.LayoutOrder; rowLayout.Padding = UDim.new(0, 8); rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center; rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left; rowLayout.Parent = titleRow
			local iconOffset = 0
			if cfg.Icon and cfg.Icon ~= "" then local asset, offset, rectSize = resolveIcon(cfg.Icon); if asset and asset ~= "" then local icon = Instance.new("ImageLabel"); icon.Size = UDim2.new(0, 18, 0, 18); icon.BackgroundTransparency = 1; icon.Image = asset; if offset and rectSize then icon.ImageRectOffset = offset; icon.ImageRectSize = rectSize end; icon.ImageColor3 = window.accent; icon.LayoutOrder = 1; icon.Parent = titleRow; window:onAccent(function(c) if icon.Parent then icon.ImageColor3 = c end end); iconOffset = 26 end end
			local titleObj = Instance.new("TextLabel"); titleObj.Size = UDim2.new(1, -iconOffset, 0, 0); titleObj.AutomaticSize = Enum.AutomaticSize.Y; titleObj.BackgroundTransparency = 1; titleObj.Text = titleText; titleObj.TextColor3 = Theme.Text; titleObj.TextSize = 13; titleObj.Font = Enum.Font.GothamBold; titleObj.TextXAlignment = Enum.TextXAlignment.Left; titleObj.TextYAlignment = Enum.TextYAlignment.Top; titleObj.TextWrapped = true; titleObj.LayoutOrder = 2; titleObj.Visible = hasTitle; titleObj.Parent = titleRow; registerThemeRef(titleObj, "TextColor3", "Text")
			titleRow.Visible = (iconOffset > 0) or hasTitle
			local titleSpacer = Instance.new("Frame"); titleSpacer.Name = "TitleSpacer"; titleSpacer.Size = UDim2.new(1, 0, 0, 10); titleSpacer.BackgroundTransparency = 1; titleSpacer.BorderSizePixel = 0; titleSpacer.LayoutOrder = 2; titleSpacer.Visible = hasTitle and hasContent; titleSpacer.Parent = f
			local divider = Instance.new("Frame"); divider.Name = "Divider"; divider.Size = UDim2.new(1, 0, 0, 2); divider.BackgroundColor3 = window.accent; divider.BackgroundTransparency = 0.25; divider.BorderSizePixel = 0; divider.LayoutOrder = 3; divider.Visible = hasTitle and hasContent; divider.Parent = f; Corner(divider, 1)
			window:onAccent(function(c) if divider and divider.Parent then divider.BackgroundColor3 = c; divider.BackgroundTransparency = 0.25 end end)
			local dividerSpacer = Instance.new("Frame"); dividerSpacer.Name = "DividerSpacer"; dividerSpacer.Size = UDim2.new(1, 0, 0, 10); dividerSpacer.BackgroundTransparency = 1; dividerSpacer.BorderSizePixel = 0; dividerSpacer.LayoutOrder = 4; dividerSpacer.Visible = hasTitle and hasContent; dividerSpacer.Parent = f
			local contentObj = Instance.new("TextLabel"); contentObj.Size = UDim2.new(1, 0, 0, 0); contentObj.AutomaticSize = Enum.AutomaticSize.Y; contentObj.BackgroundTransparency = 1; contentObj.Text = contentText; contentObj.TextColor3 = Theme.SubText; contentObj.TextSize = 12; contentObj.Font = Enum.Font.Gotham; contentObj.TextXAlignment = Enum.TextXAlignment.Left; contentObj.TextYAlignment = Enum.TextYAlignment.Top; contentObj.TextWrapped = true; contentObj.LayoutOrder = 5; contentObj.Visible = hasContent; contentObj.Parent = f; registerThemeRef(contentObj, "TextColor3", "SubText")
			hoverBorder(f, s, function() return window.accent end)
			local para = {}
			function para:Set(newCfg)
				if type(newCfg) == "table" then
					if newCfg.Title ~= nil then titleText = toText(newCfg.Title); hasTitle = titleText ~= ""; titleObj.Text = titleText; titleObj.Visible = hasTitle; titleRow.Visible = (iconOffset > 0) or hasTitle end
					if newCfg.Content ~= nil then contentText = toText(newCfg.Content); hasContent = contentText ~= ""; contentObj.Text = contentText; contentObj.Visible = hasContent end
				else contentText = toText(newCfg); hasContent = contentText ~= ""; contentObj.Text = contentText; contentObj.Visible = hasContent end
				local showLine = hasTitle and hasContent; titleSpacer.Visible = showLine; divider.Visible = showLine; dividerSpacer.Visible = showLine
			end
			registerElement(window, tab, name, f, cfg, "paragraph", para); return para
		end
		function tab:CreateToggle(cfg)
			cfg = cfg or {}; local col = cfg.Color; local f, s = elementFrame(H_ELEMENT)
			local hasIcon = makeIcon(f, cfg.Icon); if hasIcon then registerThemeRef(hasIcon, "ImageColor3", "Text") end
			local lx = hasIcon and 34 or 12
			local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -(lx + 56), 1, 0); lbl.Position = UDim2.new(0, lx, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = cfg.Name or cfg.Title or "Toggle"; lbl.TextColor3 = Theme.Text; lbl.TextSize = 13; lbl.Font = Enum.Font.Gotham; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextYAlignment = Enum.TextYAlignment.Center; lbl.Parent = f; registerThemeRef(lbl, "TextColor3", "Text")
			local switch = Instance.new("TextButton"); switch.Size = UDim2.new(0, 40, 0, 20); switch.Position = UDim2.new(1, -52, 0.5, -10); switch.BackgroundColor3 = Theme.Border; switch.BorderSizePixel = 0; switch.Text = ""; switch.AutoButtonColor = false; switch.Parent = f; Corner(switch, 99); registerThemeRef(switch, "BackgroundColor3", "Border")
			local circle = Instance.new("Frame"); circle.Size = UDim2.new(0, 14, 0, 14); circle.Position = UDim2.new(0, 3, 0.5, -7); circle.BackgroundColor3 = Theme.SubText; circle.BorderSizePixel = 0; circle.Parent = switch; Corner(circle, 99); registerThemeRef(circle, "BackgroundColor3", "SubText")
			local enabled = cfg.Default or false
			local function accent() return col or window.accent end
			local function update()
				if enabled then Tween(switch, .2, { BackgroundColor3 = accent() }); Tween(circle, .2, { Position = UDim2.new(1, -17, 0.5, -7), BackgroundColor3 = Color3.new(1, 1, 1) })
				else Tween(switch, .2, { BackgroundColor3 = Theme.Border }); Tween(circle, .2, { Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Theme.SubText }) end
				if cfg.Flag then Library.Flags[cfg.Flag] = enabled end
			end
			update(); window:onAccent(function() update() end); hoverBorder(f, s, accent)
			switch.MouseButton1Click:Connect(function() enabled = not enabled; update(); if cfg.Callback then task.spawn(cfg.Callback, enabled) end end)
			addTooltip(f, cfg.Tooltip)
			local obj = { Set = function(self, v) enabled = v; update(); if cfg.Callback then task.spawn(cfg.Callback, enabled) end end }
			registerElement(window, tab, name, f, cfg, "toggle", obj); return obj
		end
		function tab:CreateSlider(cfg)
			cfg = cfg or {}; local min, max = cfg.Min or 0, cfg.Max or 100; local value = cfg.Default or min; local col = cfg.Color; local f, s = elementFrame(H_SLIDER)
			local hasIcon = makeIcon(f, cfg.Icon, UDim2.new(0, 16, 0, 16), UDim2.new(0, 12, 0, 7)); if hasIcon then registerThemeRef(hasIcon, "ImageColor3", "Text") end
			local lx = hasIcon and 34 or 12
			local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.6, -lx, 0, 16); lbl.Position = UDim2.new(0, lx, 0, 7); lbl.BackgroundTransparency = 1; lbl.Text = cfg.Name or cfg.Title or "Slider"; lbl.TextColor3 = Theme.Text; lbl.TextSize = 13; lbl.Font = Enum.Font.Gotham; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextYAlignment = Enum.TextYAlignment.Center; lbl.Parent = f; registerThemeRef(lbl, "TextColor3", "Text")
			local val = Instance.new("TextLabel"); val.Size = UDim2.new(0.4, -12, 0, 16); val.Position = UDim2.new(0.6, 0, 0, 7); val.BackgroundTransparency = 1; val.Text = tostring(value); val.TextColor3 = col or window.accent; val.TextSize = 13; val.Font = Enum.Font.GothamBold; val.TextXAlignment = Enum.TextXAlignment.Right; val.TextYAlignment = Enum.TextYAlignment.Center; val.Parent = f
			local track = Instance.new("Frame"); track.Size = UDim2.new(1, -24, 0, 6); track.Position = UDim2.new(0, 12, 0, 30); track.BackgroundColor3 = Theme.Border; track.BorderSizePixel = 0; track.Parent = f; Corner(track, 99); registerThemeRef(track, "BackgroundColor3", "Border")
			local fill = Instance.new("Frame"); fill.BackgroundColor3 = col or window.accent; fill.BorderSizePixel = 0; fill.Parent = track; Corner(fill, 99)
			local knob = Instance.new("Frame"); knob.Size = UDim2.new(0, 12, 0, 12); knob.BackgroundColor3 = Color3.new(1, 1, 1); knob.BorderSizePixel = 0; knob.Parent = track; Corner(knob, 99); local knobStroke = Stroke(knob, col or window.accent, 2)
			local hit = Instance.new("TextButton"); hit.Size = UDim2.new(1, -24, 0, 18); hit.Position = UDim2.new(0, 12, 0, 24); hit.BackgroundTransparency = 1; hit.Text = ""; hit.AutoButtonColor = false; hit.Parent = f
			local step = tonumber(cfg.Step) or 1; if step <= 0 then step = 1 end
			local function snap(x) if step >= 1 then return math.floor(x + 0.0001) else return math.floor((x / step) + 0.5) * step end end
			local function apply(v, fire)
				value = math.clamp(snap(v), min, max); local range = math.max(0.0001, max - min); local rel = (value - min) / range
				fill.Size = UDim2.new(rel, 0, 1, 0); knob.Position = UDim2.new(rel, -6, 0.5, -6)
				if cfg.Format then val.Text = cfg.Format(value) elseif step < 1 then val.Text = string.format("%.2f", value) else val.Text = tostring(value) end
				if cfg.Flag then Library.Flags[cfg.Flag] = value end
				if fire and cfg.Callback then task.spawn(cfg.Callback, value) end
			end
			apply(value, false); window:onAccent(function(c) if not col then val.TextColor3 = c; fill.BackgroundColor3 = c; knobStroke.Color = c end end)
			local sliding = false
			hit.InputBegan:Connect(function(inp) if isPressInput(inp) then sliding = true; local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1); apply(min + (max - min) * rel, true) end end)
			Connect(UserInputService.InputChanged, function(inp) if sliding and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1); apply(min + (max - min) * rel, true) end end, window)
			Connect(UserInputService.InputEnded, function(inp) if isPressInput(inp) then sliding = false end end, window)
			hoverBorder(f, s, function() return col or window.accent end); addTooltip(f, cfg.Tooltip)
			local obj = { Set = function(self, v) apply(v, true) end }
			registerElement(window, tab, name, f, cfg, "slider", obj); return obj
		end
		function tab:CreateButton(cfg)
			cfg = cfg or {}; local col = cfg.Color; local f, s = elementFrame(H_ELEMENT)
			local hasIcon = makeIcon(f, cfg.Icon); if hasIcon then registerThemeRef(hasIcon, "ImageColor3", "Text") end
			local lx = hasIcon and 34 or 12
			local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -(lx + 24), 1, 0); lbl.Position = UDim2.new(0, lx, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = cfg.Name or cfg.Title or "Button"; lbl.TextColor3 = Theme.Text; lbl.TextSize = 13; lbl.Font = Enum.Font.GothamMedium; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextYAlignment = Enum.TextYAlignment.Center; lbl.Parent = f; registerThemeRef(lbl, "TextColor3", "Text")
			local arrow = Instance.new("TextLabel"); arrow.Size = UDim2.new(0, 20, 1, 0); arrow.Position = UDim2.new(1, -28, 0, 0); arrow.BackgroundTransparency = 1; arrow.Text = "›"; arrow.TextColor3 = col or window.accent; arrow.TextSize = 18; arrow.Font = Enum.Font.GothamBold; arrow.TextYAlignment = Enum.TextYAlignment.Center; arrow.Parent = f
			window:onAccent(function(c) if not col then arrow.TextColor3 = c end end)
			hoverBorder(f, s, function() return col or window.accent end)
			local click = Instance.new("TextButton"); click.Size = UDim2.new(1, 0, 1, 0); click.BackgroundTransparency = 1; click.Text = ""; click.AutoButtonColor = false; click.Parent = f
			click.MouseButton1Click:Connect(function()
				if Library.Effects.Ripple then f.ClipsDescendants = true; local ripple = Instance.new("Frame"); ripple.Name = "Ripple"; ripple.AnchorPoint = Vector2.new(0.5, 0.5); ripple.Position = UDim2.new(0.5, 0, 0.5, 0); ripple.Size = UDim2.new(0, 0, 0, 0); ripple.BackgroundColor3 = col or window.accent; ripple.BackgroundTransparency = 0.55; ripple.BorderSizePixel = 0; ripple.ZIndex = (f.ZIndex or 1) + 1; ripple.Parent = f; Corner(ripple, 99); Tween(ripple, .45, { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out); task.delay(.46, function() if ripple and ripple.Parent then ripple:Destroy() end end) end
				Tween(f, .1, { Size = UDim2.new(1, -6, 0, H_ELEMENT - 2) }, Enum.EasingStyle.Back); task.delay(.12, function() if f.Parent then Tween(f, .15, { Size = UDim2.new(1, 0, 0, H_ELEMENT) }, Enum.EasingStyle.Back) end end)
				if cfg.Callback then task.spawn(cfg.Callback) end
			end)
			addTooltip(f, cfg.Tooltip); registerElement(window, tab, name, f, cfg, "button", nil); return f
		end
		function tab:CreateTextbox(cfg)
			cfg = cfg or {}; local col = cfg.Color; local f, s = elementFrame(H_ELEMENT)
			local hasIcon = makeIcon(f, cfg.Icon); if hasIcon then registerThemeRef(hasIcon, "ImageColor3", "Text") end
			local lx = hasIcon and 34 or 12
			local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -(lx + 150), 1, 0); lbl.Position = UDim2.new(0, lx, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = cfg.Name or cfg.Title or "Textbox"; lbl.TextColor3 = Theme.Text; lbl.TextSize = 13; lbl.Font = Enum.Font.Gotham; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextYAlignment = Enum.TextYAlignment.Center; lbl.Parent = f; registerThemeRef(lbl, "TextColor3", "Text")
			local box = Instance.new("TextBox"); box.Size = UDim2.new(0, 140, 0, 24); box.Position = UDim2.new(1, -152, 0.5, -12); box.BackgroundColor3 = Theme.Background; box.BorderSizePixel = 0; box.PlaceholderText = cfg.PlaceholderText or cfg.Placeholder or "Type here..."; box.PlaceholderColor3 = Theme.SubText; box.Text = cfg.Default or ""; box.TextColor3 = col or window.accent; box.TextSize = 12; box.Font = Enum.Font.Gotham; box.Parent = f; Corner(box, 6)
			registerThemeRef(box, "BackgroundColor3", "Background"); registerThemeRef(box, "PlaceholderColor3", "SubText"); local boxStroke = Stroke(box, Theme.Border, 1); registerThemeRef(boxStroke, "Color", "Border"); Pad(box, 0, 8, 0, 8)
			if cfg.Flag then Library.Flags[cfg.Flag] = box.Text end
			window:onAccent(function(c) if not col then box.TextColor3 = c end end)
			box:GetPropertyChangedSignal("Text"):Connect(function() if cfg.Flag then Library.Flags[cfg.Flag] = box.Text end; if cfg.Callback then task.spawn(cfg.Callback, box.Text) end end)
			hoverBorder(f, s, function() return col or window.accent end); addTooltip(f, cfg.Tooltip)
			local obj = { Set = function(self, t) box.Text = tostring(t or "") end, Get = function() return box.Text end }
			registerElement(window, tab, name, f, cfg, "textbox", obj); return obj
		end
		function tab:CreateInput(cfg)
			cfg = cfg or {}; local col = cfg.Color; local value = cfg.CurrentValue or cfg.Default or ""; local f, s = elementFrame(H_ELEMENT)
			local hasIcon = makeIcon(f, cfg.Icon); if hasIcon then registerThemeRef(hasIcon, "ImageColor3", "Text") end
			local lx = hasIcon and 34 or 12
			local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -(lx + 150), 1, 0); lbl.Position = UDim2.new(0, lx, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = cfg.Name or cfg.Title or "Input"; lbl.TextColor3 = Theme.Text; lbl.TextSize = 13; lbl.Font = Enum.Font.Gotham; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextYAlignment = Enum.TextYAlignment.Center; lbl.Parent = f; registerThemeRef(lbl, "TextColor3", "Text")
			local box = Instance.new("TextBox"); box.Size = UDim2.new(0, 140, 0, 24); box.Position = UDim2.new(1, -152, 0.5, -12); box.BackgroundColor3 = Theme.Background; box.BorderSizePixel = 0; box.PlaceholderText = cfg.PlaceholderText or cfg.Placeholder or "Input here..."; box.PlaceholderColor3 = Theme.SubText; box.Text = value; box.TextColor3 = col or window.accent; box.TextSize = 12; box.Font = Enum.Font.Gotham; box.Parent = f; Corner(box, 6)
			registerThemeRef(box, "BackgroundColor3", "Background"); registerThemeRef(box, "PlaceholderColor3", "SubText"); local boxStroke = Stroke(box, Theme.Border, 1); registerThemeRef(boxStroke, "Color", "Border"); Pad(box, 0, 8, 0, 8)
			if cfg.Flag then Library.Flags[cfg.Flag] = value end
			local suppress = false
			window:onAccent(function(c) if not col then box.TextColor3 = c end end)
			box:GetPropertyChangedSignal("Text"):Connect(function() if suppress then return end; value = box.Text; if cfg.Flag then Library.Flags[cfg.Flag] = value end; if cfg.Callback then task.spawn(cfg.Callback, value) end end)
			box.FocusLost:Connect(function() if cfg.RemoveTextAfterFocusLost then suppress = true; box.Text = ""; suppress = false end end)
			hoverBorder(f, s, function() return col or window.accent end); addTooltip(f, cfg.Tooltip)
			local obj = { Set = function(self, t) value = tostring(t or ""); box.Text = value; if cfg.Flag then Library.Flags[cfg.Flag] = value end end, Get = function() return value end }
			registerElement(window, tab, name, f, cfg, "input", obj); return obj
		end
		function tab:CreateDropdown(cfg)
			cfg = cfg or {}; local options = cfg.Options or {}; local col = cfg.Color; local TextService = game:GetService("TextService")
			local headerH = H_ELEMENT; local gap = 4; local listH = math.min(#options * 30, 150); local openH = headerH + gap + listH + 6
			local f, s = elementFrame(headerH); f.ClipsDescendants = true
			local hasIcon = makeIcon(f, cfg.Icon, UDim2.new(0, 16, 0, 16), UDim2.new(0, 12, 0, 11), Theme.SubText); if hasIcon then registerThemeRef(hasIcon, "ImageColor3", "SubText") end
			local lx = hasIcon and 34 or 12
			local function fitText(textObj, fullText)
				if not textObj or not textObj.Parent then return end; fullText = tostring(fullText or ""); local w = textObj.AbsoluteSize.X
				if w <= 1 then textObj.Text = ""; return end; w = w - 2; local big = Vector2.new(999999, 999999)
				local b0 = TextService:GetTextSize(fullText, textObj.TextSize, textObj.Font, big); if b0.X <= w then textObj.Text = fullText; return end
				local lo, hi, best = 1, #fullText, ""
				while lo <= hi do local mid = math.floor((lo + hi) / 2); local cand = string.sub(fullText, 1, mid) .. "..."; local bb = TextService:GetTextSize(cand, textObj.TextSize, textObj.Font, big); if bb.X <= w then best = cand; lo = mid + 1 else hi = mid - 1 end end
				if best == "" then best = "..." end; textObj.Text = best
			end
			local nameFull = cfg.Name or cfg.Title or "Dropdown"
			local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.5, -lx - 10, 0, headerH); lbl.Position = UDim2.new(0, lx, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = ""; lbl.TextColor3 = Theme.SubText; lbl.TextSize = 13; lbl.Font = Enum.Font.Gotham; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextYAlignment = Enum.TextYAlignment.Center; lbl.TextTruncate = Enum.TextTruncate.AtEnd; lbl.Parent = f; registerThemeRef(lbl, "TextColor3", "SubText")
			local valueFull = tostring(cfg.Default or (options[1] or "..."))
			local val = Instance.new("TextLabel"); val.Size = UDim2.new(0.5, -40, 0, headerH); val.Position = UDim2.new(0.5, 6, 0, 0); val.BackgroundTransparency = 1; val.Text = ""; val.TextColor3 = Theme.Text; val.TextSize = 13; val.Font = Enum.Font.GothamMedium; val.TextXAlignment = Enum.TextXAlignment.Right; val.TextYAlignment = Enum.TextYAlignment.Center; val.TextTruncate = Enum.TextTruncate.AtEnd; val.Parent = f; registerThemeRef(val, "TextColor3", "Text")
			local function refreshLbl() fitText(lbl, nameFull) end local function refreshVal() fitText(val, valueFull) end
			task.spawn(function() task.wait(); refreshLbl(); refreshVal() end)
			Connect(lbl:GetPropertyChangedSignal("AbsoluteSize"), refreshLbl, window); Connect(val:GetPropertyChangedSignal("AbsoluteSize"), refreshVal, window)
			if cfg.Flag then Library.Flags[cfg.Flag] = valueFull end
			local arrow = Instance.new("TextLabel"); arrow.Size = UDim2.new(0, 16, 0, 16); arrow.Position = UDim2.new(1, -26, 0, 11); arrow.BackgroundTransparency = 1; arrow.Text = "›"; arrow.TextColor3 = Theme.SubText; arrow.TextSize = 16; arrow.Font = Enum.Font.GothamBold; arrow.Rotation = 90; arrow.Parent = f; registerThemeRef(arrow, "TextColor3", "SubText")
			local list = Instance.new("ScrollingFrame"); list.Size = UDim2.new(1, -12, 0, 0); list.Position = UDim2.new(0, 6, 0, headerH + gap); list.BackgroundTransparency = 1; list.BorderSizePixel = 0; list.ScrollBarThickness = 2; list.ScrollBarImageColor3 = Theme.Border; list.AutomaticCanvasSize = Enum.AutomaticSize.Y; list.CanvasSize = UDim2.new(0, 0, 0, 0); list.Parent = f
			local listLayout = Instance.new("UIListLayout"); listLayout.SortOrder = Enum.SortOrder.LayoutOrder; listLayout.Padding = UDim.new(0, 2); listLayout.Parent = list
			local isOpen = false
			local function toggleOpen() isOpen = not isOpen; if isOpen then Tween(f, .3, { Size = UDim2.new(1, 0, 0, openH) }); Tween(list, .3, { Size = UDim2.new(1, -12, 0, listH) }); Tween(arrow, .3, { Rotation = -90, TextColor3 = col or window.accent }) else Tween(f, .3, { Size = UDim2.new(1, 0, 0, headerH) }); Tween(list, .3, { Size = UDim2.new(1, -12, 0, 0) }); Tween(arrow, .3, { Rotation = 90, TextColor3 = Theme.SubText }) end end
			local function setValue(t) valueFull = tostring(t or ""); refreshVal(); if cfg.Flag then Library.Flags[cfg.Flag] = valueFull end end
			local function addOption(opt)
				opt = tostring(opt or ""); local o = Instance.new("TextButton"); o.Size = UDim2.new(1, 0, 0, 28); o.BackgroundColor3 = Color3.new(1, 1, 1); o.BackgroundTransparency = 1; o.BorderSizePixel = 0; o.Text = opt; o.TextColor3 = Theme.SubText; o.TextSize = 12; o.Font = Enum.Font.Gotham; o.TextXAlignment = Enum.TextXAlignment.Left; o.TextYAlignment = Enum.TextYAlignment.Center; o.TextTruncate = Enum.TextTruncate.AtEnd; o.AutoButtonColor = false; o.Parent = list; Corner(o, 5); Pad(o, 0, 8, 0, 8)
				o.MouseEnter:Connect(function() Tween(o, .15, { BackgroundTransparency = .85, BackgroundColor3 = col or window.accent, TextColor3 = Theme.Text }) end)
				o.MouseLeave:Connect(function() Tween(o, .15, { BackgroundTransparency = 1, TextColor3 = Theme.SubText }) end)
				o.MouseButton1Click:Connect(function() setValue(opt); toggleOpen(); if cfg.Callback then task.spawn(cfg.Callback, opt) end end)
			end
			for _, opt in ipairs(options) do addOption(opt) end
			local head = Instance.new("TextButton"); head.Size = UDim2.new(1, 0, 0, headerH); head.BackgroundTransparency = 1; head.Text = ""; head.AutoButtonColor = false; head.Parent = f; head.MouseButton1Click:Connect(toggleOpen)
			hoverBorder(f, s, function() return col or window.accent end); addTooltip(f, cfg.Tooltip)
			local obj = { Refresh = function(self, newOpts) for _, c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end; options = newOpts or {}; listH = math.min(#options * 30, 150); openH = headerH + gap + listH + 6; for _, opt in ipairs(options) do addOption(opt) end; refreshVal(); if isOpen then Tween(f, .25, { Size = UDim2.new(1, 0, 0, openH) }); Tween(list, .25, { Size = UDim2.new(1, -12, 0, listH) }) end end, Set = function(self, t) setValue(t); if cfg.Callback then task.spawn(cfg.Callback, valueFull) end end, Get = function() return valueFull end }
			registerElement(window, tab, name, f, cfg, "dropdown", obj); return obj
		end
		function tab:CreateMultiDropdown(cfg)
			cfg = cfg or {}; local options = {}; for _, v in ipairs(cfg.Options or {}) do table.insert(options, tostring(v)) end
			local col = cfg.Color; local TextService = game:GetService("TextService")
			local headerH = H_ELEMENT; local gap = 4; local actionH = 30; local optH = 30; local maxList = 180
			local selected = {}; local selectedMap = {}
			local function initSelected(def)
				selected = {}; selectedMap = {}
				if type(def) == "table" then for _, v in ipairs(def) do local sv = tostring(v); if not selectedMap[sv] then selectedMap[sv] = true; table.insert(selected, sv) end end
				elseif type(def) == "string" and def ~= "" then for part in def:gmatch("[^,]+") do local sv = part:gsub("^%s*(.-)%s*$", "%1"); if sv ~= "" and not selectedMap[sv] then selectedMap[sv] = true; table.insert(selected, sv) end end end
			end
			initSelected(cfg.Default)
			local listH = math.min(#options * optH + actionH, maxList); local openH = headerH + gap + listH + 6
			local f, s = elementFrame(headerH); f.ClipsDescendants = true
			local hasIcon = makeIcon(f, cfg.Icon, UDim2.new(0, 16, 0, 16), UDim2.new(0, 12, 0, 11), Theme.SubText); if hasIcon then registerThemeRef(hasIcon, "ImageColor3", "SubText") end
			local lx = hasIcon and 34 or 12
			local function fitText(textObj, fullText)
				if not textObj or not textObj.Parent then return end; fullText = tostring(fullText or ""); local w = textObj.AbsoluteSize.X
				if w <= 1 then textObj.Text = ""; return end; w = w - 2; local big = Vector2.new(999999, 999999)
				local b0 = TextService:GetTextSize(fullText, textObj.TextSize, textObj.Font, big); if b0.X <= w then textObj.Text = fullText; return end
				local lo, hi, best = 1, #fullText, ""
				while lo <= hi do local mid = math.floor((lo + hi) / 2); local cand = string.sub(fullText, 1, mid) .. "..."; local bb = TextService:GetTextSize(cand, textObj.TextSize, textObj.Font, big); if bb.X <= w then best = cand; lo = mid + 1 else hi = mid - 1 end end
				if best == "" then best = "..." end; textObj.Text = best
			end
			local nameFull = cfg.Name or cfg.Title or "Multi Select"
			local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.5, -lx - 10, 0, headerH); lbl.Position = UDim2.new(0, lx, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = ""; lbl.TextColor3 = Theme.SubText; lbl.TextSize = 13; lbl.Font = Enum.Font.Gotham; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextYAlignment = Enum.TextYAlignment.Center; lbl.TextTruncate = Enum.TextTruncate.AtEnd; lbl.Parent = f; registerThemeRef(lbl, "TextColor3", "SubText")
			local val = Instance.new("TextLabel"); val.Size = UDim2.new(0.5, -40, 0, headerH); val.Position = UDim2.new(0.5, 6, 0, 0); val.BackgroundTransparency = 1; val.Text = ""; val.TextColor3 = Theme.Text; val.TextSize = 13; val.Font = Enum.Font.GothamMedium; val.TextXAlignment = Enum.TextXAlignment.Right; val.TextYAlignment = Enum.TextYAlignment.Center; val.TextTruncate = Enum.TextTruncate.AtEnd; val.Parent = f; registerThemeRef(val, "TextColor3", "Text")
			local function formatValue() if cfg.Format then return tostring(cfg.Format(selected)) end; local n = #selected; if n == 0 then return cfg.Placeholder or "None" elseif n == 1 then return selected[1] else return n .. " selected" end end
			local function refreshLbl() fitText(lbl, nameFull) end local function refreshVal() fitText(val, formatValue()) end
			task.spawn(function() task.wait(); refreshLbl(); refreshVal() end)
			Connect(lbl:GetPropertyChangedSignal("AbsoluteSize"), refreshLbl, window); Connect(val:GetPropertyChangedSignal("AbsoluteSize"), refreshVal, window)
			if cfg.Flag then Library.Flags[cfg.Flag] = table.clone(selected) end
			local arrow = Instance.new("TextLabel"); arrow.Size = UDim2.new(0, 16, 0, 16); arrow.Position = UDim2.new(1, -26, 0, 11); arrow.BackgroundTransparency = 1; arrow.Text = "›"; arrow.TextColor3 = Theme.SubText; arrow.TextSize = 16; arrow.Font = Enum.Font.GothamBold; arrow.Rotation = 90; arrow.Parent = f; registerThemeRef(arrow, "TextColor3", "SubText")
			local list = Instance.new("ScrollingFrame"); list.Size = UDim2.new(1, -12, 0, 0); list.Position = UDim2.new(0, 6, 0, headerH + gap); list.BackgroundTransparency = 1; list.BorderSizePixel = 0; list.ScrollBarThickness = 2; list.ScrollBarImageColor3 = Theme.Border; list.AutomaticCanvasSize = Enum.AutomaticSize.Y; list.CanvasSize = UDim2.new(0, 0, 0, 0); list.Parent = f
			local listLayout = Instance.new("UIListLayout"); listLayout.SortOrder = Enum.SortOrder.LayoutOrder; listLayout.Padding = UDim.new(0, 2); listLayout.Parent = list
			local actionBar = Instance.new("Frame"); actionBar.Size = UDim2.new(1, 0, 0, actionH - 4); actionBar.BackgroundTransparency = 1; actionBar.BorderSizePixel = 0; actionBar.LayoutOrder = 0; actionBar.Parent = list
			local actionLayout = Instance.new("UIListLayout"); actionLayout.FillDirection = Enum.FillDirection.Horizontal; actionLayout.SortOrder = Enum.SortOrder.LayoutOrder; actionLayout.Padding = UDim.new(0, 6); actionLayout.VerticalAlignment = Enum.VerticalAlignment.Center; actionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left; actionLayout.Parent = actionBar
			local function actionButton(text, order, fn)
				local b = Instance.new("TextButton"); b.Size = UDim2.new(0.5, -3, 1, -4); b.BackgroundColor3 = Theme.ElementHover; b.BackgroundTransparency = 0.25; b.BorderSizePixel = 0; b.Text = text; b.TextColor3 = Theme.SubText; b.TextSize = 11; b.Font = Enum.Font.GothamBold; b.AutoButtonColor = false; b.LayoutOrder = order; b.Parent = actionBar; Corner(b, 5)
				b.MouseEnter:Connect(function() Tween(b, .14, { BackgroundTransparency = 0, TextColor3 = Theme.Text }) end); b.MouseLeave:Connect(function() Tween(b, .14, { BackgroundTransparency = 0.25, TextColor3 = Theme.SubText }) end); b.MouseButton1Click:Connect(fn); return b
			end
			local optionRows = {}
			local function contrastColor(bg) local bright = (bg.R + bg.G + bg.B) / 3; return bright > 0.6 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255) end
			local function refreshRowVisual(opt)
				local row = optionRows[opt]; if not row then return end; local isOn = selectedMap[opt] == true; local ac = col or window.accent
				if isOn then Tween(row.box, .15, { BackgroundColor3 = ac }); row.check.ImageTransparency = 0; row.check.ImageColor3 = contrastColor(ac); Tween(row.lbl, .15, { TextColor3 = Theme.Text }); Tween(row.row, .15, { BackgroundTransparency = 0.9 })
				else Tween(row.box, .15, { BackgroundColor3 = Color3.fromRGB(0, 0, 0) }); row.box.BackgroundTransparency = 0.4; row.check.ImageTransparency = 1; Tween(row.lbl, .15, { TextColor3 = Theme.SubText }); Tween(row.row, .15, { BackgroundTransparency = 1 }) end
			end
			local function refreshAllVisuals() for opt in pairs(optionRows) do refreshRowVisual(opt) end; refreshVal() end
			local function commit(fire) if cfg.Flag then Library.Flags[cfg.Flag] = table.clone(selected) end; refreshVal(); if fire and cfg.Callback and not Library._loading then task.spawn(cfg.Callback, table.clone(selected)) end end
			local function toggleOption(opt) opt = tostring(opt); if selectedMap[opt] then selectedMap[opt] = nil; for i = #selected, 1, -1 do if selected[i] == opt then table.remove(selected, i); break end end else selectedMap[opt] = true; table.insert(selected, opt) end; refreshRowVisual(opt); commit(true) end
			local function selectAll() selected = {}; selectedMap = {}; for _, opt in ipairs(options) do selectedMap[opt] = true; table.insert(selected, opt) end; refreshAllVisuals(); commit(true) end
			local function clearAll() selected = {}; selectedMap = {}; refreshAllVisuals(); commit(true) end
			actionButton("Select All", 1, selectAll); actionButton("Clear All", 2, clearAll)
			local function addOption(opt, order)
				opt = tostring(opt or ""); local row = Instance.new("TextButton"); row.Size = UDim2.new(1, 0, 0, optH); row.BackgroundColor3 = Color3.new(1, 1, 1); row.BackgroundTransparency = 1; row.BorderSizePixel = 0; row.Text = ""; row.AutoButtonColor = false; row.LayoutOrder = order; row.Parent = list; Corner(row, 5); Pad(row, 0, 8, 0, 8)
				local box = Instance.new("Frame"); box.AnchorPoint = Vector2.new(0, 0.5); box.Size = UDim2.new(0, 16, 0, 16); box.Position = UDim2.new(0, 0, 0.5, 0); box.BackgroundColor3 = Color3.fromRGB(0, 0, 0); box.BackgroundTransparency = 0.4; box.BorderSizePixel = 0; box.Parent = row; Corner(box, 4); Stroke(box, Theme.Border, 1.2)
				local check = Instance.new("ImageLabel"); check.AnchorPoint = Vector2.new(0.5, 0.5); check.Size = UDim2.new(0, 12, 0, 12); check.Position = UDim2.new(0.5, 0, 0.5, 0); check.BackgroundTransparency = 1; check.ImageTransparency = 1; check.ImageColor3 = Color3.fromRGB(255, 255, 255); check.Parent = box; setIcon(check, "check")
				local lblOpt = Instance.new("TextLabel"); lblOpt.Size = UDim2.new(1, -28, 1, 0); lblOpt.Position = UDim2.new(0, 24, 0, 0); lblOpt.BackgroundTransparency = 1; lblOpt.Text = opt; lblOpt.TextColor3 = Theme.SubText; lblOpt.TextSize = 12; lblOpt.Font = Enum.Font.Gotham; lblOpt.TextXAlignment = Enum.TextXAlignment.Left; lblOpt.TextYAlignment = Enum.TextYAlignment.Center; lblOpt.TextTruncate = Enum.TextTruncate.AtEnd; lblOpt.Parent = row
				row.MouseEnter:Connect(function() if not selectedMap[opt] then Tween(row, .14, { BackgroundTransparency = 0.9 }) end end); row.MouseLeave:Connect(function() if not selectedMap[opt] then Tween(row, .14, { BackgroundTransparency = 1 }) end end); row.MouseButton1Click:Connect(function() toggleOption(opt) end)
				optionRows[opt] = { row = row, box = box, check = check, lbl = lblOpt }; refreshRowVisual(opt)
			end
			for i, opt in ipairs(options) do addOption(opt, i) end
			local isOpen = false
			local function toggleOpen() isOpen = not isOpen; if isOpen then listH = math.min(#options * optH + actionH, maxList); openH = headerH + gap + listH + 6; Tween(f, .3, { Size = UDim2.new(1, 0, 0, openH) }); Tween(list, .3, { Size = UDim2.new(1, -12, 0, listH) }); Tween(arrow, .3, { Rotation = -90, TextColor3 = col or window.accent }) else Tween(f, .3, { Size = UDim2.new(1, 0, 0, headerH) }); Tween(list, .3, { Size = UDim2.new(1, -12, 0, 0) }); Tween(arrow, .3, { Rotation = 90, TextColor3 = Theme.SubText }) end end
			local head = Instance.new("TextButton"); head.Size = UDim2.new(1, 0, 0, headerH); head.BackgroundTransparency = 1; head.Text = ""; head.AutoButtonColor = false; head.Parent = f; head.MouseButton1Click:Connect(toggleOpen)
			hoverBorder(f, s, function() return col or window.accent end); addTooltip(f, cfg.Tooltip); window:onAccent(function() refreshAllVisuals() end)
			local obj = { Refresh = function(self, newOpts) for _, c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end; optionRows = {}; options = {}; for _, v in ipairs(newOpts or {}) do table.insert(options, tostring(v)) end; local newMap = {}; local newArr = {}; for _, opt in ipairs(options) do newMap[opt] = true end; for _, opt in ipairs(selected) do if newMap[opt] then table.insert(newArr, opt) end end; selected = newArr; selectedMap = {}; for _, opt in ipairs(selected) do selectedMap[opt] = true end; for i, opt in ipairs(options) do addOption(opt, i) end; refreshAllVisuals(); if isOpen then listH = math.min(#options * optH + actionH, maxList); openH = headerH + gap + listH + 6; Tween(f, .25, { Size = UDim2.new(1, 0, 0, openH) }); Tween(list, .25, { Size = UDim2.new(1, -12, 0, listH) }) end end, Set = function(self, t) initSelected(t); refreshAllVisuals(); commit(true) end, Get = function() return table.clone(selected) end, GetString = function(sep) return table.concat(selected, sep or ", ") end }
			registerElement(window, tab, name, f, cfg, "multidropdown", obj); return obj
		end
		function tab:CreateKeybind(cfg)
			cfg = cfg or {}; local col = cfg.Color; local f, s = elementFrame(H_ELEMENT)
			local hasIcon = makeIcon(f, cfg.Icon); if hasIcon then registerThemeRef(hasIcon, "ImageColor3", "Text") end
			local lx = hasIcon and 34 or 12
			local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -(lx + 90), 1, 0); lbl.Position = UDim2.new(0, lx, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = cfg.Name or cfg.Title or "Keybind"; lbl.TextColor3 = Theme.Text; lbl.TextSize = 13; lbl.Font = Enum.Font.Gotham; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextYAlignment = Enum.TextYAlignment.Center; lbl.Parent = f; registerThemeRef(lbl, "TextColor3", "Text")
			local badge = Instance.new("TextButton"); badge.Size = UDim2.new(0, 78, 0, 22); badge.Position = UDim2.new(1, -90, 0.5, -11); badge.BackgroundColor3 = Theme.Background; badge.BorderSizePixel = 0; badge.TextColor3 = col or window.accent; badge.TextSize = 11; badge.Font = Enum.Font.GothamBold; badge.AutoButtonColor = false; badge.Parent = f; Corner(badge, 5); registerThemeRef(badge, "BackgroundColor3", "Background"); local badgeStroke = Stroke(badge, Theme.Border, 1); registerThemeRef(badgeStroke, "Color", "Border")
			local current = cfg.CurrentKeybind or cfg.Default or Enum.KeyCode.Unknown; if type(current) == "string" then current = Enum.KeyCode[current] or Enum.KeyCode.Unknown end
			local hold = cfg.HoldToInteract or false; local binding, holding = false, false
			badge.Text = (current ~= Enum.KeyCode.Unknown) and current.Name or "None"
			if cfg.Flag then Library.Flags[cfg.Flag] = current.Name end
			local kbRow = window:AddKeybind(cfg.Name or cfg.Title or "Keybind", (current ~= Enum.KeyCode.Unknown) and current.Name or "None")
			local function setKey(k) current = k; badge.Text = (current ~= Enum.KeyCode.Unknown) and current.Name or "None"; kbRow:Set((current ~= Enum.KeyCode.Unknown) and current.Name or "None"); if cfg.Flag then Library.Flags[cfg.Flag] = current.Name end end
			window:onAccent(function(c) if not col and not binding then badge.TextColor3 = c end end)
			badge.MouseButton1Click:Connect(function() binding = true; badge.Text = "..."; badge.TextColor3 = col or window.accent end)
			Connect(UserInputService.InputBegan, function(inp, gp) if gp then return end; if binding and inp.UserInputType == Enum.UserInputType.Keyboard then binding = false; setKey(inp.KeyCode); badge.TextColor3 = col or window.accent; if cfg.Callback then task.spawn(cfg.Callback, current) end elseif not binding and current ~= Enum.KeyCode.Unknown and inp.KeyCode == current then if hold then holding = true; if cfg.Callback then task.spawn(cfg.Callback, true) end else if cfg.Callback then task.spawn(cfg.Callback, current) end end end end, window)
			Connect(UserInputService.InputEnded, function(inp) if holding and inp.KeyCode == current then holding = false; if cfg.Callback then task.spawn(cfg.Callback, false) end end end, window)
			hoverBorder(f, s, function() return col or window.accent end); addTooltip(f, cfg.Tooltip)
			local obj = { SetKey = function(self, k) setKey(k) end, GetKey = function() return current end }
			registerElement(window, tab, name, f, cfg, "keybind", obj); return obj
		end
		function tab:CreateColorPicker(cfg)
			cfg = cfg or {}; local TextService = game:GetService("TextService")
			local function fitText(textObj, fullText)
				if not textObj or not textObj.Parent then return end; fullText = tostring(fullText or ""); local w = textObj.AbsoluteSize.X
				if w <= 1 then textObj.Text = ""; return end; w = w - 2; local big = Vector2.new(999999, 999999)
				local b0 = TextService:GetTextSize(fullText, textObj.TextSize, textObj.Font, big); if b0.X <= w then textObj.Text = fullText; return end
				local lo, hi, best = 1, #fullText, ""
				while lo <= hi do local mid = math.floor((lo + hi) / 2); local cand = string.sub(fullText, 1, mid) .. "..."; local bb = TextService:GetTextSize(cand, textObj.TextSize, textObj.Font, big); if bb.X <= w then best = cand; lo = mid + 1 else hi = mid - 1 end end
				if best == "" then best = "..." end; textObj.Text = best
			end
			local startCol = (typeof(cfg.Default) == "Color3" and cfg.Default) or Color3.fromRGB(255, 80, 80)
			local h0, s0, v0 = startCol:ToHSV(); local hue, sat, val = h0, s0, v0; local col = Color3.fromHSV(hue, sat, val)
			local f, s = elementFrame(H_ELEMENT); f.ClipsDescendants = true
			local hasIcon = makeIcon(f, cfg.Icon, UDim2.new(0, 16, 0, 16), UDim2.new(0, 12, 0, 11), Theme.SubText); if hasIcon then registerThemeRef(hasIcon, "ImageColor3", "SubText") end
			local lx = hasIcon and 34 or 12
			local nameFull = cfg.Name or cfg.Title or "Color Picker"
			local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -(lx + 78), 0, H_ELEMENT); lbl.Position = UDim2.new(0, lx, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = ""; lbl.TextColor3 = Theme.Text; lbl.TextSize = 13; lbl.Font = Enum.Font.Gotham; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextYAlignment = Enum.TextYAlignment.Center; lbl.TextTruncate = Enum.TextTruncate.AtEnd; lbl.Parent = f; registerThemeRef(lbl, "TextColor3", "Text")
			local function refreshLbl() fitText(lbl, nameFull) end task.spawn(function() task.wait(); refreshLbl() end); Connect(lbl:GetPropertyChangedSignal("AbsoluteSize"), refreshLbl, window)
			local swatch = Instance.new("TextButton"); swatch.Size = UDim2.new(0, 42, 0, 20); swatch.Position = UDim2.new(1, -54, 0, 9); swatch.BackgroundColor3 = col; swatch.BorderSizePixel = 0; swatch.Text = ""; swatch.AutoButtonColor = false; swatch.Parent = f; Corner(swatch, 5); Stroke(swatch, Color3.new(1, 1, 1), 1).Transparency = .75
			local padTop = H_ELEMENT + 6; local svH = 84; local hueH = 12; local gridCell = 20; local gridPad = 4; local gridCols = 6
			local presets = { Color3.fromRGB(255,70,70),Color3.fromRGB(255,120,60),Color3.fromRGB(255,170,50),Color3.fromRGB(255,215,60),Color3.fromRGB(220,240,60),Color3.fromRGB(150,235,70),Color3.fromRGB(80,230,110),Color3.fromRGB(50,225,160),Color3.fromRGB(50,220,210),Color3.fromRGB(60,180,240),Color3.fromRGB(70,130,255),Color3.fromRGB(110,90,255),Color3.fromRGB(150,80,255),Color3.fromRGB(190,80,250),Color3.fromRGB(230,80,220),Color3.fromRGB(255,80,170),Color3.fromRGB(255,90,130),Color3.fromRGB(255,255,255),Color3.fromRGB(200,200,210),Color3.fromRGB(150,150,160),Color3.fromRGB(110,110,120),Color3.fromRGB(70,70,80),Color3.fromRGB(40,40,48),Color3.fromRGB(15,15,20) }
			local gridRows = math.ceil(#presets / gridCols); local gridH = gridRows * (gridCell + gridPad) - gridPad
			local openH = padTop + svH + 6 + hueH + 6 + gridH + 8
			local svPad = Instance.new("Frame"); svPad.Size = UDim2.new(1, -16, 0, svH); svPad.Position = UDim2.new(0, 8, 0, padTop); svPad.BackgroundColor3 = Color3.fromHSV(hue, 1, 1); svPad.BorderSizePixel = 0; svPad.Parent = f; Corner(svPad, 6)
			local satLayer = Instance.new("Frame"); satLayer.Size = UDim2.new(1, 0, 1, 0); satLayer.BackgroundColor3 = Color3.new(1, 1, 1); satLayer.BorderSizePixel = 0; satLayer.Parent = svPad
			local satGrad = Instance.new("UIGradient"); satGrad.Color = ColorSequence.new(Color3.new(1, 1, 1)); satGrad.Transparency = NumberSequence.new{ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }; satGrad.Rotation = 0; satGrad.Parent = satLayer
			local valLayer = Instance.new("Frame"); valLayer.Size = UDim2.new(1, 0, 1, 0); valLayer.BackgroundColor3 = Color3.new(0, 0, 0); valLayer.BorderSizePixel = 0; valLayer.Parent = satLayer
			local valGrad = Instance.new("UIGradient"); valGrad.Color = ColorSequence.new(Color3.new(0, 0, 0)); valGrad.Transparency = NumberSequence.new{ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }; valGrad.Rotation = 90; valGrad.Parent = valLayer
			local svPointer = Instance.new("Frame"); svPointer.AnchorPoint = Vector2.new(0.5, 0.5); svPointer.Size = UDim2.new(0, 12, 0, 12); svPointer.Position = UDim2.new(sat, 0, 1 - val, 0); svPointer.BackgroundColor3 = Color3.new(1, 1, 1); svPointer.BorderSizePixel = 0; svPointer.ZIndex = 2; svPointer.Parent = valLayer; Corner(svPointer, 99); Stroke(svPointer, Color3.new(0, 0, 0), 1.5)
			local hueY = padTop + svH + 6
			local hueBar = Instance.new("Frame"); hueBar.Size = UDim2.new(1, -16, 0, hueH); hueBar.Position = UDim2.new(0, 8, 0, hueY); hueBar.BackgroundColor3 = Color3.new(1, 1, 1); hueBar.BorderSizePixel = 0; hueBar.Parent = f; Corner(hueBar, 99)
			local hueGrad = Instance.new("UIGradient"); hueGrad.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255,150,0)), ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,120)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,200,255)), ColorSequenceKeypoint.new(0.66, Color3.fromRGB(80,80,255)), ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,200)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,0)) }; hueGrad.Rotation = 0; hueGrad.Parent = hueBar
			local huePointer = Instance.new("Frame"); huePointer.AnchorPoint = Vector2.new(0.5, 0.5); huePointer.Size = UDim2.new(0, 10, 0, hueH + 4); huePointer.Position = UDim2.new(hue, 0, 0.5, 0); huePointer.BackgroundColor3 = Color3.new(1, 1, 1); huePointer.BorderSizePixel = 0; huePointer.ZIndex = 2; huePointer.Parent = hueBar; Corner(huePointer, 99)
			local gridY = hueY + hueH + 6
			local gridFrame = Instance.new("Frame"); gridFrame.Size = UDim2.new(1, -16, 0, gridH); gridFrame.Position = UDim2.new(0, 8, 0, gridY); gridFrame.BackgroundTransparency = 1; gridFrame.BorderSizePixel = 0; gridFrame.Parent = f
			local grid = Instance.new("UIGridLayout"); grid.CellSize = UDim2.new(0, gridCell, 0, gridCell); grid.CellPadding = UDim2.new(0, gridPad, 0, gridPad); grid.SortOrder = Enum.SortOrder.LayoutOrder; grid.Parent = gridFrame
			local isOpen = false
			local function applyVisuals(fire)
				col = Color3.fromHSV(hue, sat, val); svPad.BackgroundColor3 = Color3.fromHSV(hue, 1, 1); svPointer.Position = UDim2.new(sat, 0, 1 - val, 0); huePointer.Position = UDim2.new(hue, 0, 0.5, 0); swatch.BackgroundColor3 = col
				if cfg.Flag then Library.Flags[cfg.Flag] = col end
				if fire and cfg.Callback and not Library._loading then task.spawn(cfg.Callback, col) end
			end
			applyVisuals(false)
			local function togglePicker() isOpen = not isOpen; if isOpen then Tween(f, .3, { Size = UDim2.new(1, 0, 0, openH) }) else Tween(f, .3, { Size = UDim2.new(1, 0, 0, H_ELEMENT) }) end end
			local dragSV = false
			local function svFromInput(inp) local abs = svPad.AbsolutePosition; local sz = svPad.AbsoluteSize; if sz.X < 1 or sz.Y < 1 then return end; sat = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1); val = 1 - math.clamp((inp.Position.Y - abs.Y) / sz.Y, 0, 1); applyVisuals(false) end
			svPad.InputBegan:Connect(function(inp) if not isOpen then return end; if isPressInput(inp) then dragSV = true; svFromInput(inp) end end)
			Connect(UserInputService.InputChanged, function(inp) if dragSV and isOpen and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then svFromInput(inp) end end, window)
			Connect(UserInputService.InputEnded, function(inp) if dragSV and isPressInput(inp) then dragSV = false; applyVisuals(true) end end, window)
			local dragHue = false
			local function hueFromInput(inp) local abs = hueBar.AbsolutePosition; local sz = hueBar.AbsoluteSize; if sz.X < 1 then return end; hue = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1); applyVisuals(false) end
			hueBar.InputBegan:Connect(function(inp) if not isOpen then return end; if isPressInput(inp) then dragHue = true; hueFromInput(inp) end end)
			Connect(UserInputService.InputChanged, function(inp) if dragHue and isOpen and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then hueFromInput(inp) end end, window)
			Connect(UserInputService.InputEnded, function(inp) if dragHue and isPressInput(inp) then dragHue = false; applyVisuals(true) end end, window)
			for i, pc in ipairs(presets) do local b = Instance.new("TextButton"); b.Size = UDim2.new(0, gridCell, 0, gridCell); b.BackgroundColor3 = pc; b.BorderSizePixel = 0; b.Text = ""; b.AutoButtonColor = false; b.LayoutOrder = i; b.Parent = gridFrame; Corner(b, 5); b.MouseButton1Click:Connect(function() local hh, ss, vv = pc:ToHSV(); hue, sat, val = hh, ss, vv; applyVisuals(true) end) end
			if cfg.Flag then Library.Flags[cfg.Flag] = col end
			swatch.MouseButton1Click:Connect(togglePicker); hoverBorder(f, s, function() return col end); addTooltip(f, cfg.Tooltip)
			local obj = { Set = function(self, c) if typeof(c) ~= "Color3" then return end; local hh, ss, vv = c:ToHSV(); hue, sat, val = hh, ss, vv; applyVisuals(true) end, Get = function() return col end }
			registerElement(window, tab, name, f, cfg, "colorpicker", obj); return obj
		end
		return tab
	end
-- PART 2 END — LANJUT PART 3 (Mini Toggle, Close Confirm, Info Card attach, Quick Bar attach, Tools Tab [tanpa movement slider], Theme Tab [+toggle Quick Bar/Info Panel], Save/Load Tab, performAutoLoad, return window, return Library)
  -- ============================================================
-- PART 3 : MINI TOGGLE + CLOSE CONFIRM + INFO CARD + TABS + RETURN
-- (masih di dalam function Library:CreateWindow(config))
-- ============================================================

--// ---------- Mini Toggle (hide/show UI) ----------
local MINI_W, MINI_H = 168, 42
local MINI_ICON = 22
local MINI_LINE = 3
local MiniToggle = Instance.new("TextButton")
MiniToggle.Name = "ZethHubMini"
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
miniLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
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
makeMiniLine(-8); makeMiniLine(0); makeMiniLine(8)
local miniSeparator = Instance.new("Frame")
miniSeparator.Size = UDim2.new(0, 1, 0, MINI_ICON)
miniSeparator.BackgroundColor3 = Theme.Border
miniSeparator.BorderSizePixel = 0
miniSeparator.LayoutOrder = 2
miniSeparator.ZIndex = 61
miniSeparator.Parent = MiniToggle
registerThemeRef(miniSeparator, "BackgroundColor3", "Border")
local miniLbl = Instance.new("TextLabel")
miniLbl.Size = UDim2.new(0, 0, 0, MINI_ICON)
miniLbl.AutomaticSize = Enum.AutomaticSize.X
miniLbl.BackgroundTransparency = 1
miniLbl.Text = "Hide UI"
miniLbl.TextColor3 = Theme.Text
miniLbl.TextSize = 12
miniLbl.Font = Enum.Font.GothamBold
miniLbl.TextXAlignment = Enum.TextXAlignment.Left
miniLbl.TextYAlignment = Enum.TextYAlignment.Center
miniLbl.LayoutOrder = 3
miniLbl.ZIndex = 61
miniLbl.Parent = MiniToggle
registerThemeRef(miniLbl, "TextColor3", "Text")
MiniToggle.MouseEnter:Connect(function() Tween(MiniToggle, .2, { BackgroundColor3 = Theme.ElementHover }) end)
MiniToggle.MouseLeave:Connect(function() Tween(MiniToggle, .2, { BackgroundColor3 = Theme.Background }) end)
local function setMiniIcon(open)
	local lineSize = UDim2.new(0, MINI_ICON, 0, MINI_LINE)
	local emptySize = UDim2.new(0, 0, 0, MINI_LINE)
	if open then
		Tween(miniLines[1], .25, { Position = UDim2.new(0.5, 0, 0.5, 0), Rotation = 45, BackgroundTransparency = 0, Size = lineSize })
		Tween(miniLines[2], .25, { Position = UDim2.new(0.5, 0, 0.5, 0), Rotation = -45, BackgroundTransparency = 0, Size = lineSize })
		Tween(miniLines[3], .15, { BackgroundTransparency = 1, Size = emptySize })
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
local mOrigX, mOrigY = 0, 0
Connect(MiniToggle.InputBegan, function(inp)
	if isPressInput(inp) then
		mDrag = true; mMoved = 0; mStart = inp.Position
		local center = MiniToggle.AbsolutePosition + MiniToggle.AbsoluteSize / 2
		mOrigX, mOrigY = center.X, center.Y
	end
end, window)
Connect(UserInputService.InputChanged, function(inp)
	if mDrag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
		local d = inp.Position - mStart
		mMoved = math.max(mMoved, math.abs(d.X) + math.abs(d.Y))
		MiniToggle.Position = UDim2.new(0, mOrigX + d.X, 0, mOrigY + d.Y)
	end
end, window)
Connect(UserInputService.InputEnded, function(inp) if isPressInput(inp) then mDrag = false end end, window)

function window:Toggle(force)
	if window._destroyed then return end
	if window._closeConfirmCleanup then pcall(window._closeConfirmCleanup) end
	closeSearchResults()
	local open = (force ~= nil) and force or not Library.Open
	Library.Open = open
	windowOpen = open
	if info then info.Visible = open end
	if open then
		main.Visible = true
		Tween(main, .35, { Size = OPEN_SIZE }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	else
		Tween(main, .25, { Size = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In).Completed:Connect(function()
			if not Library.Open and not window._destroyed and main.Parent then main.Visible = false end
		end)
	end
	refreshKbVis()
	setMiniIcon(open)
	setMiniLabel(open)
end
MiniToggle.MouseButton1Click:Connect(function()
	if mMoved > 8 then return end
	window:Toggle()
end)
function window:SetInfoCard(vis) if info then info.Visible = vis and windowOpen end end
minimizeBtn.MouseButton1Click:Connect(function() window:Toggle(false) end)

--// ---------- Close Confirmation (cooldown WAIT 3) ----------
local CONFIRM_COOLDOWN = 3
window.confirmTitle = config.ConfirmTitle or "System"
window.confirmSubtitle = config.ConfirmSubtitle or "You are about to close this window. This action cannot be undone and all unsaved changes will be lost."
function window:SetConfirmText(title, subtitle)
	if title ~= nil then self.confirmTitle = tostring(title) end
	if subtitle ~= nil then self.confirmSubtitle = tostring(subtitle) end
end
local confirmModal, confirmBlocker = nil, nil
local function destroyCloseConfirm()
	if confirmBlocker and confirmBlocker.Parent then pcall(function() confirmBlocker:Destroy() end) end
	if confirmModal and confirmModal.Parent then pcall(function() confirmModal:Destroy() end) end
	confirmModal = nil; confirmBlocker = nil
	Library._confirmOpen = false; Library._buttonPressLock = false
	if window and not window._destroyed then window._closeConfirmCleanup = nil end
end
window._closeConfirmCleanup = destroyCloseConfirm
local function showCloseConfirmation()
	destroyCloseConfirm()
	Library._confirmOpen = true; Library._buttonPressLock = true
	dragging = false; resizing = false
	closeSearchResults()
	local cd = window._closeButtonData
	if cd and cd.btn and cd.btn.Parent then
		pcall(function() Tween(cd.btn, .15, { BackgroundColor3 = Theme.Element }) end)
		if cd.lines then for _, l in ipairs(cd.lines) do pcall(function() Tween(l, .15, { BackgroundColor3 = Theme.SubText }) end) end end
	end
	local closeColor = window.closeColor or Theme.Close
	local closeHover = window.closeHoverColor or Theme.CloseHover
	local closeText = window.closeTextColor or Theme.CloseText
	confirmBlocker = Instance.new("Frame")
	confirmBlocker.Name = "CloseConfirmBlocker"
	confirmBlocker.Size = UDim2.new(1, 0, 1, 0)
	confirmBlocker.BackgroundTransparency = 1
	confirmBlocker.BorderSizePixel = 0
	confirmBlocker.ZIndex = 9998
	confirmBlocker.Active = true
	confirmBlocker.Parent = main
	confirmModal = Instance.new("Frame")
	confirmModal.Name = "CloseConfirmModal"
	confirmModal.AnchorPoint = Vector2.new(0.5, 0.5)
	confirmModal.Position = UDim2.new(0.5, 0, 0.5, 0)
	confirmModal.Size = UDim2.new(0, 360, 0, 210)
	confirmModal.BackgroundColor3 = Theme.ConfirmBackground
	confirmModal.BackgroundTransparency = 0.18
	confirmModal.BorderSizePixel = 0
	confirmModal.ClipsDescendants = false
	confirmModal.ZIndex = 9999
	confirmModal.Parent = main
	Corner(confirmModal, 12)
	local modalStroke = Stroke(confirmModal, closeColor, 1.6); modalStroke.Transparency = 0.45
	local modalScale = Instance.new("UIScale"); modalScale.Scale = 0.88; modalScale.Parent = confirmModal
	Tween(modalScale, .22, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	Tween(confirmModal, .18, { BackgroundTransparency = 0 })
	Tween(modalStroke, .22, { Transparency = 0.18 })
	local header = Instance.new("Frame")
	header.Name = "Header"; header.Size = UDim2.new(1, -28, 0, 40); header.Position = UDim2.new(0, 14, 0, 14)
	header.BackgroundTransparency = 1; header.ZIndex = 10000; header.Parent = confirmModal
	local headerLayout = Instance.new("UIListLayout")
	headerLayout.FillDirection = Enum.FillDirection.Horizontal; headerLayout.SortOrder = Enum.SortOrder.LayoutOrder
	headerLayout.Padding = UDim.new(0, 10); headerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	headerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left; headerLayout.Parent = header
	local headIcon = Instance.new("ImageLabel")
	headIcon.Size = UDim2.new(0, 22, 0, 22); headIcon.BackgroundTransparency = 1; headIcon.ImageColor3 = closeColor
	headIcon.LayoutOrder = 1; headIcon.ZIndex = 10001; headIcon.Parent = header; setIcon(headIcon, "x-circle")
	local cTitle = Instance.new("TextLabel")
	cTitle.Size = UDim2.new(1, -32, 0, 22); cTitle.BackgroundTransparency = 1
	cTitle.Text = tostring(window.confirmTitle or "System"); cTitle.TextColor3 = Theme.ConfirmText
	cTitle.TextTransparency = 1; cTitle.TextSize = 17; cTitle.Font = Enum.Font.GothamBlack
	cTitle.TextXAlignment = Enum.TextXAlignment.Left; cTitle.TextYAlignment = Enum.TextYAlignment.Center
	cTitle.LayoutOrder = 2; cTitle.ZIndex = 10001; cTitle.Parent = header
	Tween(cTitle, .22, { TextTransparency = 0 })
	local cDiv = Instance.new("Frame")
	cDiv.Size = UDim2.new(1, -28, 0, 1); cDiv.Position = UDim2.new(0, 14, 0, 58)
	cDiv.BackgroundColor3 = closeColor; cDiv.BackgroundTransparency = 0.55; cDiv.BorderSizePixel = 0
	cDiv.ZIndex = 10000; cDiv.Parent = confirmModal; Corner(cDiv, 99)
	local divGrad = Instance.new("UIGradient")
	divGrad.Transparency = NumberSequence.new{ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.12, 0), NumberSequenceKeypoint.new(0.88, 0), NumberSequenceKeypoint.new(1, 1) }
	divGrad.Parent = cDiv
	local cSub = Instance.new("TextLabel")
	cSub.Size = UDim2.new(1, -28, 0, 56); cSub.Position = UDim2.new(0, 14, 0, 68)
	cSub.BackgroundTransparency = 1; cSub.Text = tostring(window.confirmSubtitle or "")
	cSub.TextColor3 = Theme.ConfirmSubText; cSub.TextTransparency = 1; cSub.TextSize = 12; cSub.Font = Enum.Font.Gotham
	cSub.TextXAlignment = Enum.TextXAlignment.Left; cSub.TextYAlignment = Enum.TextYAlignment.Top
	cSub.TextWrapped = true; cSub.ZIndex = 10000; cSub.Parent = confirmModal
	Tween(cSub, .26, { TextTransparency = 0 })
	local btnContainer = Instance.new("Frame")
	btnContainer.Size = UDim2.new(1, -28, 0, 40); btnContainer.Position = UDim2.new(0, 14, 1, -54)
	btnContainer.BackgroundTransparency = 1; btnContainer.ZIndex = 10000; btnContainer.Parent = confirmModal
	local blayout = Instance.new("UIListLayout")
	blayout.FillDirection = Enum.FillDirection.Horizontal; blayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	blayout.VerticalAlignment = Enum.VerticalAlignment.Center; blayout.Padding = UDim.new(0, 12); blayout.Parent = btnContainer
	local noBtn = Instance.new("TextButton")
	noBtn.Size = UDim2.new(0, 100, 0, 36); noBtn.BackgroundColor3 = Theme.Neutral; noBtn.Text = "NO"
	noBtn.TextColor3 = Theme.ConfirmText; noBtn.TextSize = 14; noBtn.Font = Enum.Font.GothamMedium
	noBtn.AutoButtonColor = false; noBtn.ZIndex = 10001; noBtn.Parent = btnContainer; Corner(noBtn, 7)
	noBtn.MouseEnter:Connect(function() Tween(noBtn, .15, { BackgroundColor3 = Theme.NeutralHover }) end)
	noBtn.MouseLeave:Connect(function() Tween(noBtn, .15, { BackgroundColor3 = Theme.Neutral }) end)
	noBtn.MouseButton1Click:Connect(destroyCloseConfirm)
	local yesBtn = Instance.new("TextButton")
	yesBtn.Size = UDim2.new(0, 100, 0, 36); yesBtn.BackgroundColor3 = closeColor; yesBtn.Text = "YES"
	yesBtn.TextColor3 = closeText; yesBtn.TextSize = 14; yesBtn.Font = Enum.Font.GothamBold
	yesBtn.AutoButtonColor = false; yesBtn.ZIndex = 10001; yesBtn.Parent = btnContainer; Corner(yesBtn, 7)
	local canClickYes = false
	yesBtn.MouseEnter:Connect(function() if canClickYes then Tween(yesBtn, .15, { BackgroundColor3 = closeHover }) end end)
	yesBtn.MouseLeave:Connect(function() if canClickYes then Tween(yesBtn, .15, { BackgroundColor3 = closeColor }) end end)
	task.spawn(function()
		yesBtn.BackgroundColor3 = Theme.Disabled; yesBtn.TextColor3 = Theme.DisabledText
		for i = CONFIRM_COOLDOWN, 1, -1 do
			if not yesBtn.Parent then break end
			yesBtn.Text = "WAIT (" .. i .. ")"; task.wait(1)
		end
		if yesBtn.Parent then
			yesBtn.Text = "YES"; yesBtn.BackgroundColor3 = window.closeColor or closeColor
			yesBtn.TextColor3 = window.closeTextColor or closeText; canClickYes = true
		end
	end)
	yesBtn.MouseButton1Click:Connect(function()
		if canClickYes then destroyCloseConfirm(); window:Destroy()
		else
			Tween(yesBtn, .07, { Rotation = -5 })
			task.delay(.07, function() if yesBtn.Parent then Tween(yesBtn, .07, { Rotation = 5 }) end end)
			task.delay(.14, function() if yesBtn.Parent then Tween(yesBtn, .07, { Rotation = 0 }) end end)
		end
	end)
	Connect(main:GetPropertyChangedSignal("Visible"), function() if not main.Visible then destroyCloseConfirm() end end, window)
	Connect(main:GetPropertyChangedSignal("Size"), function() if main.Size.X.Offset < 80 or main.Size.Y.Offset < 80 then destroyCloseConfirm() end end, window)
end
closeBtn.MouseButton1Click:Connect(showCloseConfirmation)
Connect(UserInputService.InputBegan, function(inp, gp)
	if gp then return end
	if Library._confirmOpen then return end
	if inp.KeyCode == Library.ToggleKey then window:Toggle() end
end, window)

--// ---------- Info Card kecil (avatar + FPS/Ping, kiri-bawah dalam gui) ----------
info = Instance.new("Frame")
info.Size = UDim2.new(0, 230, 0, 74)
info.Position = UDim2.new(0, 12, 1, -86)
info.BackgroundColor3 = Theme.Background
info.BackgroundTransparency = 0.1
info.BorderSizePixel = 0
info.ZIndex = 55
info.Parent = gui
info.Visible = Library.Open
Corner(info, 10)
registerThemeRef(info, "BackgroundColor3", "Background")
local infoStroke = Stroke(info, Theme.Border, 1); registerThemeRef(infoStroke, "Color", "Border")
local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.new(0, 48, 0, 48); avatar.Position = UDim2.new(0, 13, 0.5, -24)
avatar.BackgroundColor3 = Theme.Element; avatar.BorderSizePixel = 0; avatar.Parent = info; Corner(avatar, 99)
registerThemeRef(avatar, "BackgroundColor3", "Element")
registerRGB(Stroke(avatar, Color3.new(1, 1, 1), 2))
avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"
local nameLbl = Instance.new("TextLabel")
nameLbl.Size = UDim2.new(1, -74, 0, 18); nameLbl.Position = UDim2.new(0, 70, 0, 11)
nameLbl.BackgroundTransparency = 1; nameLbl.Text = LocalPlayer.DisplayName; nameLbl.TextColor3 = Theme.Text
nameLbl.TextSize = 13; nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextXAlignment = Enum.TextXAlignment.Left
nameLbl.TextYAlignment = Enum.TextYAlignment.Center; nameLbl.TextTruncate = Enum.TextTruncate.AtEnd; nameLbl.Parent = info
registerThemeRef(nameLbl, "TextColor3", "Text")
local userLbl = Instance.new("TextLabel")
userLbl.Size = UDim2.new(1, -74, 0, 14); userLbl.Position = UDim2.new(0, 70, 0, 29)
userLbl.BackgroundTransparency = 1; userLbl.Text = "@" .. LocalPlayer.Name; userLbl.TextColor3 = Theme.SubText
userLbl.TextSize = 10; userLbl.Font = Enum.Font.Gotham; userLbl.TextXAlignment = Enum.TextXAlignment.Left
userLbl.TextYAlignment = Enum.TextYAlignment.Center; userLbl.TextTruncate = Enum.TextTruncate.AtEnd; userLbl.Parent = info
registerThemeRef(userLbl, "TextColor3", "SubText")
local statsLbl = Instance.new("TextLabel")
statsLbl.Size = UDim2.new(1, -74, 0, 14); statsLbl.Position = UDim2.new(0, 70, 0, 45)
statsLbl.BackgroundTransparency = 1; statsLbl.Text = "FPS -- | Ping --ms"; statsLbl.TextColor3 = window.accent
statsLbl.TextSize = 10; statsLbl.Font = Enum.Font.GothamMedium; statsLbl.TextXAlignment = Enum.TextXAlignment.Left
statsLbl.TextYAlignment = Enum.TextYAlignment.Center; statsLbl.Parent = info
window:onAccent(function(c) statsLbl.TextColor3 = c end)
task.spawn(function()
	while info and info.Parent do
		task.wait(1)
		if window._destroyed or Library._destroyed or (type(Env) == "table" and Env.ZethHubGeneration ~= Library.Generation) then return end
		statsLbl.Text = "FPS: " .. math.min(currentFps, 999) .. " | Ping: " .. currentPing .. "ms"
	end
end)
setMiniIcon(true); setMiniLabel(true)

--// ---------- Auto Load ----------
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
		for _, f in ipairs(files) do if f == target then found = true; break end end
		if not found then target = files[1] end
		local ok = Library:LoadFromFile(target)
		if ok then Library._saveFile = target; Library:Notify("Auto load: " .. target, 3, "Loader Information", "upload") end
	end)
end

--// ---------- Bangun Overlay (Quick Bar + Info Panel) & selesaikan Loading ----------
task.spawn(function()
	task.wait(0.2)
	if Library._destroyed or window._destroyed then return end
	pcall(function() Library:BuildQuickBar() end)
	pcall(function() Library:BuildInfoCard() end)
end)

-- ============================================================
-- BUILT-IN TOOLS TAB  (V5.5: Movement slider/InfJump DIHAPUS,
-- sudah pindah ke Quick Bar. Diganti section kontrol overlay.)
-- ============================================================
if config.ToolsTab ~= false then
	local ToolsTab = window:CreateTab("Tools", "wrench")
	ToolsTab.btn.LayoutOrder = 9997
	ToolsTab.content.LayoutOrder = 9997
	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

	-- [V5.5] Section pengganti Movement → kontrol Quick Bar / Info Panel / reset
	ToolsTab:CreateSection("Quick Bar & Overlays")
	ToolsTab:CreateParagraph({
		Title = "Movement Controls",
		Content = "WalkSpeed, JumpPower & Infinite Jump kini berada di Quick Bar mengambang. Gunakan panel di samping untuk mengatur visibilitas & reset.",
		Icon = "zap",
	})
	ToolsTab:CreateToggle({
		Name = "Quick Bar Visible",
		Default = (QB.Visible == true),
		Flag = "ZethHub_QuickBarVis",
		Icon = "layout-dashboard",
		Tooltip = "Tampilkan / sembunyikan Quick Bar",
		Callback = function(v) if QB and QB.SetVisible then QB:SetVisible(v) end end,
	})
	ToolsTab:CreateToggle({
		Name = "Info Panel Visible",
		Default = (IC.Visible == true),
		Flag = "ZethHub_InfoPanelVis",
		Icon = "info",
		Tooltip = "Tampilkan / sembunyikan Info Panel (Dek Dev Hub style)",
		Callback = function(v) if IC and IC.SetVisible then IC:SetVisible(v) end end,
	})
	ToolsTab:CreateButton({
		Name = "Reset Movement (WS / JP / InfJump)",
		Icon = "refresh-cw",
		Tooltip = "Kembalikan nilai movement ke default & matikan semua",
		Callback = function()
			Move.WS = 16; Move.JP = 50; Move.InfJump = false; Move.WSEnabled = false; Move.JPEnabled = false
			resetMove()
			if QB and QB.rows then
				if QB.rows.ws then pcall(function() QB.rows.ws:Set(16) end) end
				if QB.rows.jp then pcall(function() QB.rows.jp:Set(50) end) end
				if QB.rows.wsT then pcall(function() QB.rows.wsT:Set(false) end) end
				if QB.rows.jpT then pcall(function() QB.rows.jpT:Set(false) end) end
				if QB.rows.inf then pcall(function() QB.rows.inf:Set(false) end) end
			end
			Library:Notify("Movement direset ke default.", 3, "Quick Bar", "check-circle")
		end,
	})

	-- External Scripts
	ToolsTab:CreateSection("External Scripts")
	ToolsTab:CreateParagraph({ Title = "System Information", Content = "All these scripts work with all games", Icon = "shield" })
	local TOOL_SCRIPT_OPTIONS = {
		"♾️ Infinite Yield",
		"🖥️ Executor Editor [BETA]",
		"📌 Waypoint Manager [S.W.P]",
		"🛡️ Anti-Fling [Protection]",
		"🎭 Animation Roblox [Working]",
		"👁️ Esp Monster [Beta]",
	}
	local TOOL_SCRIPT_URLS = {
		["♾️ Infinite Yield"] = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source",
		["🖥️ Executor Editor [BETA]"] = "https://raw.githubusercontent.com/zeutronxsite/nf5guunQd-exec/refs/heads/main/executor.luau",
		["📌 Waypoint Manager [S.W.P]"] = "https://raw.githubusercontent.com/Uo2iQnNhD/Maintenance/refs/heads/main/xtvqz7us-Waypoint.lua",
		["🛡️ Anti-Fling [Protection]"] = "https://pastebin.com/raw/MhJDcWjR",
		["🎭 Animation Roblox [Working]"] = "https://raw.githubusercontent.com/Bac0nHck/Scripts/refs/heads/main/BundleAnimations.lua",
		["👁️ Esp Monster [Beta]"] = "https://raw.githubusercontent.com/Uo2iQnNhD/Maintenance/refs/heads/main/aXXcS4rE-Esp%20Monster.lua",
	}
	local selectedToolScripts = {}
	ToolsTab:CreateMultiDropdown({
		Name = "Select Scripts", Icon = "layers", Options = TOOL_SCRIPT_OPTIONS, Default = {},
		Placeholder = "None selected", Flag = "ToolsScriptMulti", Tooltip = "Select one or more external scripts",
		Callback = function(list)
			if type(list) == "string" then selectedToolScripts = { list }
			elseif type(list) == "table" then selectedToolScripts = list
			else selectedToolScripts = {} end
		end,
	})
	ToolsTab:CreateButton({
		Name = "Execute Selected Scripts", Icon = "play", Tooltip = "Run all selected external scripts",
		Callback = function()
			if type(selectedToolScripts) ~= "table" or #selectedToolScripts == 0 then
				Library:Notify("Please select at least one script!", 5, "Error", "x-circle"); return
			end
			local count = #selectedToolScripts
			Library:Notify("Executing " .. count .. " script(s)...", 4, "Status", "check")
			task.spawn(function()
				for i, scriptName in ipairs(selectedToolScripts) do
					local url = TOOL_SCRIPT_URLS[scriptName]
					if url then
						if type(executeRemoteScript) == "function" then
							executeRemoteScript(url, scriptName)
						else
							local ok, source = pcall(function() return game:HttpGet(url) end)
							if ok and source and source ~= "" then
								local chunk, loadErr = loadstring(source)
								if chunk then task.spawn(chunk)
								else Library:Notify("Load error: " .. tostring(scriptName) .. "\n" .. tostring(loadErr), 5, "Error", "x-circle") end
							else Library:Notify("Failed to fetch: " .. tostring(scriptName), 5, "Error", "x-circle") end
						end
					else Library:Notify("URL not found: " .. tostring(scriptName), 5, "Error", "x-circle") end
					if i < count then task.wait(1.2) end
				end
				Library:Notify("All selected scripts executed.", 4, "Done", "check-circle")
			end)
		end,
	})

	ToolsTab:CreateSection("More Tools")

	-- Player Join/Leave Notification
	_G.JoinLeaveEnabled = false
	local function removeOldJoinLeaveGui()
		local parents = { PlayerGui }
		if typeof(gethui) == "function" then local ok, hui = pcall(gethui); if ok and hui then table.insert(parents, hui) end end
		local okCore, CoreGui = pcall(function() return game:GetService("CoreGui") end)
		if okCore and CoreGui then table.insert(parents, CoreGui) end
		for _, parent in ipairs(parents) do
			if parent then for _, child in ipairs(parent:GetChildren()) do
				if child:IsA("ScreenGui") and child.Name == "JoinLeaveNotificationGui" then pcall(function() child:Destroy() end) end
			end end
		end
	end
	removeOldJoinLeaveGui()
	local NotificationGui = Instance.new("ScreenGui")
	NotificationGui.Name = "JoinLeaveNotificationGui"; NotificationGui.ResetOnSpawn = false
	NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; NotificationGui.IgnoreGuiInset = true; NotificationGui.DisplayOrder = 999999
	local notifParent = PlayerGui
	if typeof(gethui) == "function" then local ok, hui = pcall(gethui); if ok and hui then notifParent = hui end end
	NotificationGui.Parent = notifParent
	local activeNotifications = {}
	local notificationQueue = {}
	local isProcessingQueue = false
	local processNotificationQueue, showPlayerNotification
	local function getAvatarUrl(userId)
		if not userId or userId == 0 then return "rbxasset://textures/ui/GuiImagePlaceholder.png" end
		return "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=150&height=150&format=png"
	end
	local function getCurrentTime()
		local success, time = pcall(function() return os.date("*t") end)
		if success and time then return string.format("%02d:%02d:%02d", time.hour, time.min, time.sec) end
		return "00:00:00"
	end
	local function updateNotificationPositions()
		for i, frame in ipairs(activeNotifications) do
			if frame.Parent then
				local cnt = #activeNotifications
				local yOffset = -(100 + (cnt - i) * 90)
				TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(1, -340, 1, yOffset) }):Play()
			end
		end
	end
	showPlayerNotification = function(playerName, userId, isJoining)
		local themeColor = isJoining and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(255, 80, 80)
		local actionText = isJoining and "Joined the Server" or "Left the Server"
		local notifFrame = Instance.new("Frame")
		notifFrame.Name = "PlayerNotification"; notifFrame.Size = UDim2.new(0, 320, 0, 80)
		notifFrame.Position = UDim2.new(1, 20, 1, 20); notifFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
		notifFrame.BorderSizePixel = 0; notifFrame.Parent = NotificationGui
		Corner(notifFrame, 10)
		local stroke = Instance.new("UIStroke"); stroke.Color = themeColor; stroke.Thickness = 2; stroke.Parent = notifFrame
		local avatarImage = Instance.new("ImageLabel")
		avatarImage.Size = UDim2.new(0, 50, 0, 50); avatarImage.Position = UDim2.new(0, 12, 0, 15)
		avatarImage.BackgroundColor3 = Color3.fromRGB(40, 40, 45); avatarImage.BorderSizePixel = 0
		avatarImage.Image = getAvatarUrl(userId); avatarImage.Parent = notifFrame
		Corner(avatarImage, 99)
		local titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.new(1, -75, 0, 20); titleLabel.Position = UDim2.new(0, 72, 0, 12)
		titleLabel.BackgroundTransparency = 1; titleLabel.Text = actionText; titleLabel.TextColor3 = themeColor
		titleLabel.TextSize = 14; titleLabel.Font = Enum.Font.GothamBold; titleLabel.TextXAlignment = Enum.TextXAlignment.Left; titleLabel.Parent = notifFrame
		local pNameLabel = Instance.new("TextLabel")
		pNameLabel.Size = UDim2.new(1, -75, 0, 20); pNameLabel.Position = UDim2.new(0, 72, 0, 30)
		pNameLabel.BackgroundTransparency = 1; pNameLabel.Text = playerName; pNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		pNameLabel.TextSize = 15; pNameLabel.Font = Enum.Font.GothamBold; pNameLabel.TextXAlignment = Enum.TextXAlignment.Left; pNameLabel.Parent = notifFrame
		local currentPlayers = #Players:GetPlayers()
		if not isJoining then currentPlayers = math.max(0, currentPlayers - 1) end
		local maxPlayers = 99
		local success, result = pcall(function() return game.MaxPlayers end)
		if success and type(result) == "number" and result > 0 then maxPlayers = result end
		local infoLabel = Instance.new("TextLabel")
		infoLabel.Size = UDim2.new(1, -75, 0, 18); infoLabel.Position = UDim2.new(0, 72, 0, 50)
		infoLabel.BackgroundTransparency = 1; infoLabel.Text = string.format("Players: %d/%d | Time: %s", currentPlayers, maxPlayers, getCurrentTime())
		infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150); infoLabel.TextSize = 11; infoLabel.Font = Enum.Font.Gotham
		infoLabel.TextXAlignment = Enum.TextXAlignment.Left; infoLabel.Parent = notifFrame
		table.insert(activeNotifications, notifFrame); updateNotificationPositions()
		task.delay(4, function()
			if not notifFrame.Parent then return end
			TweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(1, 20, 1, 20), BackgroundTransparency = 1 }):Play()
			TweenService:Create(avatarImage, TweenInfo.new(0.5), { ImageTransparency = 1 }):Play()
			TweenService:Create(titleLabel, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
			TweenService:Create(pNameLabel, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
			TweenService:Create(infoLabel, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
			task.wait(0.5); notifFrame:Destroy()
			for idx, frame in ipairs(activeNotifications) do if frame == notifFrame then table.remove(activeNotifications, idx); break end end
			updateNotificationPositions()
		end)
	end
	processNotificationQueue = function()
		if isProcessingQueue or #notificationQueue == 0 then return end
		isProcessingQueue = true
		local data = table.remove(notificationQueue, 1)
		if type(showPlayerNotification) == "function" then showPlayerNotification(data.playerName, data.userId, data.isJoining) end
		task.delay(0.5, function() isProcessingQueue = false; if type(processNotificationQueue) == "function" then processNotificationQueue() end end)
	end
	Players.PlayerAdded:Connect(function(player)
		if not _G.JoinLeaveEnabled then return end
		table.insert(notificationQueue, { playerName = player.Name, userId = player.UserId, isJoining = true })
		if type(processNotificationQueue) == "function" then processNotificationQueue() end
	end)
	Players.PlayerRemoving:Connect(function(player)
		if not _G.JoinLeaveEnabled then return end
		table.insert(notificationQueue, { playerName = player.Name, userId = player.UserId, isJoining = false })
		if type(processNotificationQueue) == "function" then processNotificationQueue() end
	end)
	ToolsTab:CreateToggle({
		Name = "Player Notification", Default = false, Flag = "JoinLeaveNotifToggle", Icon = "users",
		Tooltip = "Show player join/leave notifications",
		Callback = function(value)
			_G.JoinLeaveEnabled = value
			if value then
				local pName = (LocalPlayer and LocalPlayer.Name) or "Unknown"
				local pId = (LocalPlayer and LocalPlayer.UserId) or 0
				table.insert(notificationQueue, { playerName = pName .. " (You)", userId = pId, isJoining = true })
				if type(processNotificationQueue) == "function" then processNotificationQueue() else warn("[ZethHub] processNotificationQueue is nil!") end
			end
		end,
	})

	-- ESP Player
	local espEnabled = false
	local espObjects = {}
	local espCharacterConnections = {}
	local updateConnection = nil
	local function collectKeys(tbl) local keys = {} for key in pairs(tbl) do table.insert(keys, key) end return keys end
	local function getTeamColor(player)
		local team = nil; pcall(function() team = player.Team end)
		local teamName = (team and team.Name) or ""
		local teamColorMap = {
			["Fugitive"] = Color3.fromRGB(255, 50, 50), ["Prison"] = Color3.fromRGB(255, 150, 0),
			["Police"] = Color3.fromRGB(0, 100, 255), ["Civilian"] = Color3.fromRGB(50, 255, 50),
			["Hostage"] = Color3.fromRGB(255, 0, 255), ["Choosing"] = Color3.fromRGB(0, 255, 255),
			["ADMIN"] = Color3.fromRGB(255, 215, 0), ["Red"] = Color3.fromRGB(255, 50, 50),
			["Blue"] = Color3.fromRGB(50, 100, 255), ["Green"] = Color3.fromRGB(50, 255, 50),
			["Yellow"] = Color3.fromRGB(255, 255, 50), ["Purple"] = Color3.fromRGB(200, 50, 255),
			["White"] = Color3.fromRGB(255, 255, 255), ["Black"] = Color3.fromRGB(50, 50, 50),
		}
		for name, color in pairs(teamColorMap) do if string.lower(teamName) == string.lower(name) then return color end end
		local teamColor = nil; pcall(function() teamColor = team and team.TeamColor and team.TeamColor.Color end)
		return teamColor or Color3.fromRGB(255, 255, 255)
	end
	local function clearPlayerESP(player)
		local data = espObjects[player]
		if data then
			pcall(function() if data.billboard then data.billboard:Destroy() end end)
			pcall(function() if data.highlight then data.highlight:Destroy() end end)
			espObjects[player] = nil
		end
		local conn = espCharacterConnections[player]
		if conn then pcall(function() conn:Disconnect() end); espCharacterConnections[player] = nil end
	end
	local function clearAllESP()
		for _, player in ipairs(collectKeys(espObjects)) do clearPlayerESP(player) end
		for _, player in ipairs(collectKeys(espCharacterConnections)) do clearPlayerESP(player) end
		espObjects = {}
	end
	local function createESP(targetPlayer)
		if targetPlayer == LocalPlayer then return end
		local function setupESP(char)
			if not char then return end
			local head = char:WaitForChild("Head", 5)
			local hum = char:WaitForChild("Humanoid", 5)
			local hrp = char:WaitForChild("HumanoidRootPart", 5)
			if not head or not hum or not hrp then return end
			local teamColor = getTeamColor(targetPlayer)
			if head:FindFirstChild("PlayerESP_GUI") then head.PlayerESP_GUI:Destroy() end
			if char:FindFirstChild("PlayerESP_HL") then char.PlayerESP_HL:Destroy() end
			local highlight = Instance.new("Highlight"); highlight.Name = "PlayerESP_HL"
			pcall(function() highlight.FillColor = teamColor; highlight.OutlineColor = Color3.fromRGB(0, 0, 0); highlight.FillTransparency = 0.7; highlight.OutlineTransparency = 0; highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end)
			highlight.Adornee = char; highlight.Parent = char
			local billboard = Instance.new("BillboardGui"); billboard.Name = "PlayerESP_GUI"; billboard.Adornee = head
			billboard.Size = UDim2.new(0, 140, 0, 60); billboard.StudsOffset = Vector3.new(0, 3, 0); billboard.AlwaysOnTop = true
			billboard.ResetOnSpawn = false; billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; billboard.Parent = head
			local eName = Instance.new("TextLabel"); eName.Name = "NameLabel"; eName.Size = UDim2.new(1, 0, 0, 14); eName.Position = UDim2.new(0, 0, 0, 0)
			eName.BackgroundTransparency = 1; eName.Text = targetPlayer.Name; eName.TextColor3 = teamColor; eName.TextStrokeTransparency = 0
			eName.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); eName.Font = Enum.Font.GothamBold; eName.TextSize = 12; eName.Parent = billboard
			local eDist = Instance.new("TextLabel"); eDist.Name = "DistanceLabel"; eDist.Size = UDim2.new(1, 0, 0, 12); eDist.Position = UDim2.new(0, 0, 0, 13)
			eDist.BackgroundTransparency = 1; eDist.Text = "[0m]"; eDist.TextColor3 = Color3.fromRGB(255, 255, 255); eDist.TextStrokeTransparency = 0
			eDist.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); eDist.Font = Enum.Font.GothamBold; eDist.TextSize = 11; eDist.Parent = billboard
			local hpBg = Instance.new("Frame"); hpBg.Name = "HealthBg"; hpBg.Size = UDim2.new(0, 120, 0, 6); hpBg.Position = UDim2.new(0.5, -60, 0, 26)
			hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40); hpBg.BorderSizePixel = 0; hpBg.Parent = billboard; Corner(hpBg, 3)
			local hpFill = Instance.new("Frame"); hpFill.Name = "HealthFill"; hpFill.Size = UDim2.new(1, 0, 1, 0); hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0); hpFill.BorderSizePixel = 0; hpFill.Parent = hpBg; Corner(hpFill, 3)
			local hpLabel = Instance.new("TextLabel"); hpLabel.Name = "HPLabel"; hpLabel.Size = UDim2.new(1, 0, 0, 12); hpLabel.Position = UDim2.new(0, 0, 0, 34)
			hpLabel.BackgroundTransparency = 1; hpLabel.Text = "HP: 100/100"; hpLabel.TextColor3 = Color3.fromRGB(255, 255, 255); hpLabel.TextStrokeTransparency = 0
			hpLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); hpLabel.Font = Enum.Font.GothamBold; hpLabel.TextSize = 11; hpLabel.Parent = billboard
			local eTeam = Instance.new("TextLabel"); eTeam.Name = "TeamLabel"; eTeam.Size = UDim2.new(1, 0, 0, 10); eTeam.Position = UDim2.new(0, 0, 0, 46)
			eTeam.BackgroundTransparency = 1; eTeam.Text = "[" .. ((targetPlayer.Team and targetPlayer.Team.Name) or "No Team") .. "]"
			eTeam.TextColor3 = teamColor; eTeam.TextStrokeTransparency = 0; eTeam.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); eTeam.Font = Enum.Font.Gotham; eTeam.TextSize = 10; eTeam.Parent = billboard
			espObjects[targetPlayer] = { billboard = billboard, highlight = highlight, hpFill = hpFill, hpLabel = hpLabel, distanceLabel = eDist, nameLabel = eName, teamLabel = eTeam, humanoid = hum, hrp = hrp, character = char }
		end
		if targetPlayer.Character then setupESP(targetPlayer.Character) end
		if not espCharacterConnections[targetPlayer] then
			espCharacterConnections[targetPlayer] = targetPlayer.CharacterAdded:Connect(function(char) if espEnabled then task.wait(0.5); setupESP(char) end end)
		end
	end
	local function startUpdateLoop()
		if updateConnection then updateConnection:Disconnect(); updateConnection = nil end
		updateConnection = RunService.RenderStepped:Connect(function()
			local myChar = LocalPlayer.Character
			local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
			for player, data in pairs(espObjects) do
				pcall(function()
					local hum = data.humanoid; local hrp = data.hrp; local fill = data.hpFill; local hpLabel = data.hpLabel; local distLabel = data.distanceLabel
					if hum and fill and hpLabel and hum.Parent then
						local currentHP = math.floor(hum.Health); local maxHP = math.floor(hum.MaxHealth)
						local percent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
						fill.Size = UDim2.new(percent, 0, 1, 0); hpLabel.Text = string.format("HP: %d/%d", currentHP, maxHP)
						if percent > 0.6 then fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0); hpLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
						elseif percent > 0.3 then fill.BackgroundColor3 = Color3.fromRGB(255, 200, 0); hpLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
						else fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0); hpLabel.TextColor3 = Color3.fromRGB(255, 0, 0) end
					end
					if myHRP and hrp and hrp.Parent and distLabel then
						local distance = (myHRP.Position - hrp.Position).Magnitude
						distLabel.Text = string.format("[%dm]", math.floor(distance))
						if distance < 15 then distLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
						elseif distance < 40 then distLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
						else distLabel.TextColor3 = Color3.fromRGB(255, 255, 255) end
					end
				end)
			end
		end)
	end
	local function toggleESP(state)
		espEnabled = state
		if state then
			for _, player in ipairs(Players:GetPlayers()) do if player ~= LocalPlayer then createESP(player) end end
			startUpdateLoop()
		else
			if updateConnection then updateConnection:Disconnect(); updateConnection = nil end
			clearAllESP()
		end
	end
	Players.PlayerAdded:Connect(function(player) if espEnabled and player ~= LocalPlayer then createESP(player) end end)
	Players.PlayerRemoving:Connect(clearPlayerESP)
	ToolsTab:CreateToggle({ Name = "ESP Player", Default = false, Flag = "ESPPlayerToggle", Icon = "eye", Tooltip = "Activate ESP players with HP, distance, and team", Callback = function(value) toggleESP(value) end })
	ToolsTab:CreateButton({
		Name = "Korblox & Headless", Icon = "gem", Tooltip = "This script is client only And Not real",
		Callback = function()
			if type(executeRemoteScript) == "function" then
				executeRemoteScript("https://raw.githubusercontent.com/Uo2iQnNhD/Maintenance/refs/heads/main/SYtg4g76-Korblox%20%26%20Headless.lua", "Korblox & Headless")
			else
				Library:Notify("executeRemoteScript tidak tersedia.", 4, "Error", "x-circle")
			end
		end,
	})
end

-- ============================================================
-- BUILT-IN THEME TAB  (V5.5: + toggle overlay ikut theme)
-- ============================================================
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
		Default = ThemeManager.Mode == "RGB Rainbow" and "RGB Rainbow" or "Solid",
		Flag = "ZethHub_ThemePreset", Icon = "palette",
		Callback = function(v)
			Library:SetTheme(v)
			local rb = Library._elements["ZethHub_Rainbow"]
			if rb and rb.Object and not Library._loading then rb.Object:Set(ThemeManager.Mode == "RGB Rainbow") end
		end,
	})
	themeTab:CreateToggle({ Name = "RGB Rainbow", Flag = "ZethHub_Rainbow", Default = Library.Rainbow, Icon = "activity", Callback = function(v) Library:SetRainbow(v) end })
	themeTab:CreateColorPicker({ Name = "Accent Color", Default = Library.Accent, Flag = "ZethHub_Accent", Icon = "droplet", Callback = function(c) Library:SetAccent(c) end })
	themeTab:CreateSlider({ Name = "Rainbow Speed", Min = 0.02, Max = 0.5, Default = Theme.RainbowSpeed, Step = 0.01, Flag = "ZethHub_RainbowSpeed", Icon = "activity", Format = function(v) return string.format("%.2f", v) end, Callback = function(v) Theme.RainbowSpeed = v end })
	themeTab:CreateSlider({ Name = "Main Border Thickness", Min = 1, Max = 6, Default = Theme.MainBorderThickness, Step = 0.1, Flag = "ZethHub_MainBorderThickness", Icon = "border-all", Format = function(v) return string.format("%.1f", v) end, Callback = function(v) Theme.MainBorderThickness = v; if mainStroke then mainStroke.Thickness = v end; if mainGlow then mainGlow.Thickness = v + 2.2 end end })
	themeTab:CreateSlider({ Name = "Element Border Thickness", Min = 0.5, Max = 4, Default = Theme.ElementBorderThickness, Step = 0.1, Flag = "ZethHub_ElementBorderThickness", Icon = "border-inner", Format = function(v) return string.format("%.1f", v) end, Callback = function(v) Theme.ElementBorderThickness = v; Theme.BorderThickness = v end })
	themeTab:CreateToggle({ Name = "Moving Particles", Flag = "ZethHub_Particles", Default = Library.Effects.Particles, Icon = "sparkles", Callback = function(v) Library.Effects.Particles = v; if particleLayer then particleLayer.Visible = v end end })
	themeTab:CreateToggle({ Name = "Border Glow", Flag = "ZethHub_Glow", Default = Library.Effects.Glow and Theme.BorderGlow, Icon = "sun", Callback = function(v) Theme.BorderGlow = v; Library.Effects.Glow = v; if mainGlow then mainGlow.Visible = v end end })
	themeTab:CreateSlider({ Name = "Animation Speed", Min = 0.25, Max = 2, Default = Library.AnimationSpeed, Step = 0.05, Flag = "ZethHub_AnimationSpeed", Icon = "gauge", Format = function(v) return string.format("%.2fx", v) end, Callback = function(v) Library.AnimationSpeed = v end })

	-- [V5.5] Section Overlays — Quick Bar & Info Panel mengikuti theme
	themeTab:CreateSection("Overlays")
	themeTab:CreateToggle({ Name = "Quick Bar Enabled", Flag = "ZethHub_QuickBar", Default = Library.QuickBar.Enabled, Icon = "layout-dashboard", Tooltip = "Master switch Quick Bar (WalkSpeed/JumpPower/InfJump)", Callback = function(v) Library.QuickBar.Enabled = v; if QB and QB.SetVisible then QB:SetVisible(v) end end })
	themeTab:CreateToggle({ Name = "Info Panel Enabled", Flag = "ZethHub_InfoPanel", Default = (not Library.InfoPanel) or Library.InfoPanel.Enabled ~= false, Icon = "info", Tooltip = "Master switch Info Panel (Dek Dev Hub style)", Callback = function(v) Library.InfoPanel = Library.InfoPanel or {}; Library.InfoPanel.Enabled = v; if IC and IC.SetVisible then IC:SetVisible(v) end end })
	themeTab:CreateParagraph({ Title = "Theme Sync", Content = "Saat preset theme diubah, background & border Quick Bar / Info Panel / Loading ikut berubah otomatis.", Icon = "palette" })

	themeTab:CreateSection("Settings")
	themeTab:CreateButton({ Name = "Go Back to Zeutron Hub", Icon = "home", Callback = function() Library:Notify("Zeutron Hub Maintenance is not possible", 3, "Navigation", "x") task.wait(1) end })
	themeTab:CreateButton({
		Name = "Destroy Interface", Icon = "trash-2",
		Callback = function()
			Library:Notify("Self-destructing in 7 seconds...", 7, "Warning", "shield-alert")
			task.wait(7)
			if type(Library.Destroy) == "function" then Library:Destroy()
			else for _, w in ipairs(Library._windows or {}) do if type(w.Destroy) == "function" then w:Destroy() end end end
		end,
	})
end

-- ============================================================
-- BUILT-IN SAVE / LOAD TAB
-- ============================================================
if config.SaveLoad ~= false then
	local systemTab = window:CreateTab("Save / Load", "database")
	systemTab.btn.LayoutOrder = 9999
	systemTab.content.LayoutOrder = 9999
	systemTab:CreateSection("File Manager")
	local fileNameInput = systemTab:CreateInput({ Name = "File Name", Flag = "ZethHub_FileName", CurrentValue = Library._saveFile or "autosave", PlaceholderText = "autosave", Icon = "file-text" })
	local fileDropdown = systemTab:CreateDropdown({ Name = "Saved Files", Options = getSaveOptions(), Flag = "ZethHub_SelectedSave", Icon = "folder" })
	systemTab:CreateButton({ Name = "Refresh Saves", Icon = "refresh-cw", Callback = function() fileDropdown:Refresh(getSaveOptions()); Library:Notify("Daftar save diperbarui.", 3, "Save/Load", "refresh-cw") end })
	systemTab:CreateButton({
		Name = "Save Current Config", Icon = "download",
		Callback = function()
			local fname = fileNameInput:Get()
			if fname == "" then fname = Library._saveFile or "autosave" end
			local ok, err = Library:SaveToFile(fname)
			if ok then Library._saveFile = fname; fileDropdown:Refresh(getSaveOptions()); fileDropdown:Set(fname); Library:Notify("Berhasil menyimpan: " .. fname, 4, "Saved", "check-circle")
			else Library:Notify(err or "Gagal menyimpan file.", 4, "Error", "x-circle") end
		end,
	})
	systemTab:CreateButton({
		Name = "Load Selected File", Icon = "upload",
		Callback = function()
			local fname = fileDropdown:Get()
			if not fname or fname == "" or fname == "(no saves)" then fname = fileNameInput:Get() end
			if not fname or fname == "" or fname == "(no saves)" then Library:Notify("Pilih file save terlebih dahulu.", 4, "Load", "info"); return end
			local ok, err = Library:LoadFromFile(fname)
			if ok then fileNameInput:Set(fname); Library:Notify("Berhasil load: " .. fname, 4, "Loaded", "check-circle")
			else Library:Notify(err or "Gagal load file.", 4, "Error", "x-circle") end
		end,
	})
	systemTab:CreateButton({
		Name = "Delete Selected File", Icon = "trash-2",
		Callback = function()
			local fname = fileDropdown:Get()
			if not fname or fname == "" or fname == "(no saves)" then Library:Notify("Tidak ada file yang dipilih.", 4, "Delete", "info"); return end
			local ok, err = Library:DeleteSave(fname)
			if ok then fileDropdown:Refresh(getSaveOptions()); Library:Notify("File dihapus: " .. fname, 4, "Deleted", "trash-2")
			else Library:Notify(err or "Gagal menghapus file.", 4, "Error", "x-circle") end
		end,
	})
	systemTab:CreateSection("Automation")
	systemTab:CreateToggle({ Name = "Auto Save", Flag = "ZethHub_AutoSave", Default = Library.AutoSave.Enabled, Icon = "timer", Callback = function(v) Library.AutoSave.Enabled = v end })
	systemTab:CreateSlider({ Name = "Auto Save Interval (sec)", Min = 10, Max = 600, Default = Library.AutoSave.Interval, Step = 1, Flag = "ZethHub_AutoSaveInterval", Icon = "clock", Callback = function(v) Library.AutoSave.Interval = v end })
	systemTab:CreateToggle({ Name = "Auto Load On Start", Flag = "ZethHub_AutoLoad", Default = Library.AutoLoad.Enabled, Icon = "power", Callback = function(v) Library.AutoLoad.Enabled = v; if v then performAutoLoad(0.3) end end })
end

if Library.AutoLoad.Enabled then performAutoLoad(1.5) end

--// Selesaikan loading screen setelah seluruh UI & tab siap
task.delay(0.6, function()
	if LoadingScreen and LoadingScreen.Finish and not LoadingScreen.Done then
		pcall(function() LoadingScreen.Finish() end)
	end
end)

return window
end -- ===== akhir function Library:CreateWindow =====

-- ============================================================
-- LIBRARY-LEVEL DESTROY + EXPORT
-- ============================================================
function Library:Destroy()
	if self._destroyed then return end
	self._destroyed = true
	for _, w in ipairs(self._windows or {}) do if type(w.Destroy) == "function" then pcall(function() w:Destroy() end) end end
	self._windows = {}
	for _, conn in ipairs(self._connections or {}) do pcall(function() conn:Disconnect() end) end
	self._connections = {}
	pcall(function() if NotifGui and NotifGui.Parent then NotifGui:Destroy() end end)
	pcall(function() if QB and QB.Gui and QB.Gui.Parent then QB.Gui:Destroy() end end)
	pcall(function() if IC and IC.Gui and IC.Gui.Parent then IC.Gui:Destroy() end end)
	pcall(function() if LoadingScreen and LoadingScreen.Gui and LoadingScreen.Gui.Parent then LoadingScreen.Gui:Destroy() end end)
	if type(Env) == "table" then Env.ZethHubLibrary = nil end
end

if type(Env) == "table" then
	Env.ZethHubLibrary = Library
end
return Library
-- ===== END OF ZETHUB V5.5 (Part 3/3) =====
