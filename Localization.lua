local L = setmetatable({}, { __index = function(t, k)
                        local v = tostring(k)
                        rawset(t, k, v)
                        return v
end })

local LOCALE = GetLocale()

function ME_GetLocale( ... )
	return L,LOCALE
end

if string.find(LOCALE,"^en") then return end

if LOCALE == "esES" or LOCALE == "esMX" then
        -- Spanish translations go here
        L["Increases speed by (%d+)%%."] = "Increases speed by (%d+)%%."
        L["Invalid argument's for condition Buff"] = "Invalid argument's for condition Buff"
        L["Invalid argument's for condition Debuff"] = "Invalid argument's for condition Debuff"
        L["Unknown Option"] = "Unknown Option"
return end

if LOCALE == "deDE" then
        -- German translations go here
return end

if LOCALE == "frFR" then
        -- French translations go here
return end

if LOCALE == "ptBR" then
        -- Brazilian Portuguese translations go here
return end

if LOCALE == "ruRU" then
        -- Russian translations go here
return end

if LOCALE == "koKR" then
        -- Korean translations go here
return end

if LOCALE == "zhCN" then
        -- Simplified Chinese translations go here
return end

if LOCALE == "zhTW" then
        -- Traditional Chinese translations go here
return end