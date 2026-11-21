--------------------------------------------------
-- SETTINGS
--------------------------------------------------
local LoaderSettings = {
    -- Matching mode:
    -- "GameIdThenPlaceId" => prioritize GameId, fallback to PlaceId
    -- "PlaceIdThenGameId" => prioritize PlaceId, fallback to GameId
    -- "GameIdOnly"        => accept GameId only
    -- "PlaceIdOnly"       => accept PlaceId only
    MatchMode = "GameIdThenPlaceId",

    -- Reject URLs other than http/https
    AllowNonHttps = false,

    -- Show detailed logs
    PrintDetailedLog = true,

    -- If a registered game has no URLs, load universal
    FallbackToUniversalIfNoUrls = true,

    -- If all game scripts fail to load, load universal
    FallbackToUniversalIfSupportedFails = false,
}

--------------------------------------------------
-- GAME CONFIG
--------------------------------------------------
-- I filled GameIds and PlaceIds with the same IDs
-- to remain compatible with your old script.
--
-- If you want stricter matching:
-- - If the ID comes from a Roblox game URL, move it to GameIds only.
-- - If the ID is specific to a certain place, move it to PlaceIds only.
--------------------------------------------------
local LoaderConfig = {
    Universal = {
        Name = "Universal",
        Urls = {
            "https://raw.githubusercontent.com/Uo2iQnNhD/Maintenance/refs/heads/main/L3aun246-Universal.lua"
        }
    },

    Games = {
        {
            Name = "Jailbreak",
            GameIds = {606849621},
            PlaceIds = {606849621},
            Urls = {
                "https://raw.githubusercontent.com/Uo2iQnNhD/Maintenance/refs/heads/main/M6txEKBD-Break.lua"
            }
        },

        {
            Name = "TLK Prison",
            GameIds = {6933626061},
            PlaceIds = {6933626061},
            Urls = {
                "https://raw.githubusercontent.com/IOERHUB/CheckingV2/refs/heads/main/Protection"
            }
        },

        {
            Name = "Steal An Egg",
            GameIds = {107778070777162},
            PlaceIds = {107778070777162},
            Urls = {
                "https://raw.githubusercontent.com/Uo2iQnNhD/Maintenance/refs/heads/main/sAcfzDLt-Steal%20An%20Egg.lua"
            }
        },

        {
            Name = "Area 51 Remake",
            GameIds = {13811085661},
            PlaceIds = {13811085661},
            Urls = {
                "https://raw.githubusercontent.com/Uo2iQnNhD/Maintenance/refs/heads/main/Area-51-Remake.lua"
            }
        },

        {
            Name = "Power Incremental",
            GameIds = {96668710663666},
            PlaceIds = {96668710663666},
            Urls = {
                "https://raw.githubusercontent.com/IOERHUB/Power-Incremental/refs/heads/main/Working"
            }
        },

        {
            Name = "Violence District",
            GameIds = {93978595733734},
            PlaceIds = {93978595733734},
            Urls = {
                "https://raw.githubusercontent.com/Uo2iQnNhD/Maintenance/refs/heads/main/XptC65ba-MainVD.lua"
            }
        },

        {
            Name = "Murderer vs Sheriff Duels",
            GameIds = {12355337193},
            PlaceIds = {12355337193},
            Urls = {
                "https://raw.githubusercontent.com/Uo2iQnNhD/Maintenance/refs/heads/main/eyPSrASq-MVSD.lua"
            }
        },

        {
            Name = "The Hollow: Roblox",
            GameIds = {116463962153167},
            PlaceIds = {116463962153167},
            Urls = {
                "https://raw.githubusercontent.com/Uo2iQnNhD/Maintenance/refs/heads/main/The%20Hollow%3A%20Roblox.lua"
            }
        },
    }
}

--------------------------------------------------
-- UTILITIES
--------------------------------------------------
local function countKeys(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

local function isFinitePositiveInteger(value)
    if type(value) ~= "number" then
        return false
    end

    -- NaN check
    if value ~= value then
        return false
    end

    -- Infinity check
    if value == math.huge or value == -math.huge then
        return false
    end

    -- Must be positive and an integer
    if value <= 0 then
        return false
    end

    return value == math.floor(value)
end

local function normalizeUrl(url)
    if type(url) ~= "string" then
        return ""
    end

    -- Remove leading/trailing spaces
    url = url:gsub("^%s+", ""):gsub("%s+$", "")

    -- Remove BOM if accidentally attached to URL string
    url = url:gsub("^\239\187\191", "")

    return url
end

local function isHttpUrl(url)
    return type(url) == "string" and url:match("^https?://") ~= nil
end

--------------------------------------------------
-- LOGGING
--------------------------------------------------
local function logInfo(message)
    if LoaderSettings.PrintDetailedLog then
        print("ℹ️ | " .. message)
    end
end

local function logSuccess(message)
    if LoaderSettings.PrintDetailedLog then
        print("✅ | " .. message)
    end
end

local function logWarn(message)
    warn("❌ | " .. message)
end

--------------------------------------------------
-- BUILD INDEX CHECKER
--------------------------------------------------
local gameIndex = {}
local placeIndex = {}

local function registerIndex(index, id, entry, idKind)
    if not isFinitePositiveInteger(id) then
        logWarn(string.format(
            "Invalid ID for %s (%s): %s",
            tostring(entry.Name),
            idKind,
            tostring(id)
        ))
        return false
    end

    if index[id] ~= nil then
        logWarn(string.format(
            "Duplicate %s %d for %s. The last entry will be used",
            idKind,
            id,
            tostring(entry.Name)
        ))
    end

    index[id] = entry
    return true
end

-- Validate and build indexes once when the script starts
for i, entry in ipairs(LoaderConfig.Games) do
    if type(entry) == "table" then
        entry.Name = entry.Name or ("Game #" .. i)
        entry.GameIds = entry.GameIds or {}
        entry.PlaceIds = entry.PlaceIds or {}
        entry.Urls = entry.Urls or {}

        for _, id in ipairs(entry.GameIds) do
            registerIndex(gameIndex, id, entry, "GameId")
        end

        for _, id in ipairs(entry.PlaceIds) do
            registerIndex(placeIndex, id, entry, "PlaceId")
        end
    else
        logWarn("Game entry #" .. i .. " is not a table and was skipped")
    end
end

--------------------------------------------------
-- SAFE LOADER
--------------------------------------------------
local loadedUrls = {}
local loadFunction = loadstring or load

local function loadRemoteScript(url, label)
    url = normalizeUrl(url)

    if url == "" then
        logWarn(label .. ": Empty URL")
        return false
    end

    if not LoaderSettings.AllowNonHttps and not isHttpUrl(url) then
        logWarn(label .. ": URL is not http/https: " .. url)
        return false
    end

    -- Avoid reloading the same URL
    local previousStatus = loadedUrls[url]
    if previousStatus ~= nil then
        if previousStatus then
            logSuccess(label .. ": URL has already been successfully loaded, skipped")
        else
            logWarn(label .. ": URL previously failed, not retrying")
        end

        return previousStatus
    end

    -- Download
    local fetchOk, body = pcall(function()
        return game:HttpGet(url)
    end)

    if not fetchOk then
        loadedUrls[url] = false
        logWarn(string.format(
            "%s: download failed. Error: %s",
            label,
            tostring(body)
        ))
        return false
    end

    if type(body) ~= "string" then
        loadedUrls[url] = false
        logWarn(label .. ": downloaded content is not a string.")
        return false
    end

    -- Remove UTF-8 BOM from the beginning of script content
    body = body:gsub("^\239\187\191", "")

    if body == "" then
        loadedUrls[url] = false
        logWarn(label .. ": script content is empty.")
        return false
    end

    if type(loadFunction) ~= "function" then
        loadedUrls[url] = false
        logWarn(label .. ": loadstring/load is unavailable.")
        return false
    end

    -- Compile
    local compileOk, compiled, compileError = pcall(loadFunction, body)

    if not compileOk then
        loadedUrls[url] = false
        logWarn(string.format(
            "%s: loadstring error. Detail: %s",
            label,
            tostring(compiled)
        ))
        return false
    end

    if compiled == nil then
        loadedUrls[url] = false
        logWarn(string.format(
            "%s: script failed to compile. Detail: %s",
            label,
            tostring(compileError)
        ))
        return false
    end

    -- Execute
    local runOk, runError = pcall(compiled)
    loadedUrls[url] = runOk

    if runOk then
        logSuccess(label .. ": loaded and executed successfully.")
    else
        logWarn(string.format(
            "%s: runtime error. Detail: %s",
            label,
            tostring(runError)
        ))
    end

    return runOk
end

local function loadUrlList(urls, baseName)
    if type(urls) ~= "table" then
        return 0, 0
    end

    local total = #urls
    local successCount = 0

    for i = 1, total do
        local label = string.format("%s [%d/%d]", baseName, i, total)

        local ok = loadRemoteScript(urls[i], label)

        if ok then
            successCount = successCount + 1
        end
    end

    return successCount, total
end

--------------------------------------------------
-- FAST CHECKER
--------------------------------------------------
local function getIndexValue(index, id)
    if isFinitePositiveInteger(id) then
        return index[id]
    end

    return nil
end

local function getMatchedGame()
    local mode = LoaderSettings.MatchMode
    local gameId = game.GameId
    local placeId = game.PlaceId

    local entry
    local source

    if mode == "GameIdOnly" then
        entry = getIndexValue(gameIndex, gameId)
        source = "GameId"

    elseif mode == "PlaceIdOnly" then
        entry = getIndexValue(placeIndex, placeId)
        source = "PlaceId"

    elseif mode == "PlaceIdThenGameId" then
        entry = getIndexValue(placeIndex, placeId)
        source = "PlaceId"

        if not entry then
            entry = getIndexValue(gameIndex, gameId)
            source = "GameId"
        end

    else
        -- Default: GameIdThenPlaceId
        entry = getIndexValue(gameIndex, gameId)
        source = "GameId"

        if not entry then
            entry = getIndexValue(placeIndex, placeId)
            source = "PlaceId"
        end
    end

    if entry then
        return entry, source
    end

    return nil, nil
end

--------------------------------------------------
-- UNIVERSAL FALLBACK
--------------------------------------------------
local function loadUniversal(reason)
    if reason then
        warn(reason)
    end

    print("⏳ Loading Universal...")

    if type(LoaderConfig.Universal) ~= "table" then
        warn("💀 LoaderConfig.Universal is missing.")
        return 0, 0
    end

    local universalName = LoaderConfig.Universal.Name or "Universal"

    local loaded, total = loadUrlList(
        LoaderConfig.Universal.Urls,
        universalName
    )

    return loaded, total
end

--------------------------------------------------
-- MAIN
--------------------------------------------------
print("==================================================")
print("🚀 Starting Clean Script Loader...")
print(string.format(
    "🎮 GameId: %s | PlaceId: %s",
    tostring(game.GameId),
    tostring(game.PlaceId)
))
print(string.format(
    "🔎 MatchMode: %s",
    LoaderSettings.MatchMode
))
print(string.format(
    "📚 Registered: GameId: %d, PlaceId: %d",
    countKeys(gameIndex),
    countKeys(placeIndex)
))
print("==================================================")

local matched, matchedBy = getMatchedGame()

if matched then
    print(string.format(
        "SUPPORTED | Game Detected: %s (matched by %s)",
        matched.Name,
        tostring(matchedBy)
    ))

    local loaded, total = loadUrlList(matched.Urls, matched.Name)

    if total == 0 then
        warn(string.format(
            "[!] %s is registered but has no URLs.",
            matched.Name
        ))

        if LoaderSettings.FallbackToUniversalIfNoUrls then
            loadUniversal("⏳ Falling back to Universal because supported game has no URLs")
        end
    else
        print(string.format(
            "🎉 Finished! %d/%d modules loaded for %s.",
            loaded,
            total,
            matched.Name
        ))

        if loaded == 0 and LoaderSettings.FallbackToUniversalIfSupportedFails then
            loadUniversal("⏳ Falling back to Universal because all game scripts failed")
        end
    end
else
    warn(string.format(
        "⚠️ UNIVERSAL | Game is not registered. GameId: %s, PlaceId: %s",
        tostring(game.GameId),
        tostring(game.PlaceId)
    ))

    loadUniversal()
end
