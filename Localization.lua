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
        
        L["ENABLED"] = "ENABLED"
        L["DISABLED"] = "DISABLED"
        L["is currently"] = "is currently"
        L["interface improvement"] = "interface improvement"
        
        --Errors
        L["Unknown Option"] = "Unknown Option"
        L["Syntax Error"] = "Syntax Error"
        L["Usage"] = "Usage"
        
        --Mount Information
        L["Requires Riding %((%d+)%)"] = "Requires Riding %((%d+)%)"
        L["Increases speed by (%d+)%%."] = "Increases speed by (%d+)%%."
        
        L["Summon Warhorse"] = "Summon Warhorse"
        L["Summon Charger"] = "Summon Charger"
        L["Summon Dreadsteed"] = "Summon Dreadsteed"
        L["Summon Felsteed"] = "Summon Felsteed"
        
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