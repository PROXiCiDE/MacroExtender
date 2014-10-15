local L = ME_GetLocale()
ME_CastSequenceList ={}

local function SecureCmdOptionEval(val, desired)
        if ( desired ) then
                return (val == desired)
        else
                if type(val) == "boolean" then
                        return val == true
                else
                        return (val > 0)
                end
        end
end

local SecureCmdOptionHandlers = {  
        --  
        -- WOW Conditions 
        --
        combat = function(target, desired)
                return SecureCmdOptionEval(UnitAffectingCombat("player") or UnitAffectingCombat("pet") or 0, tonumber(desired))
        end,
        
        exists = function(target, desired)
                return SecureCmdOptionEval(UnitExists(target) or 0, tonumber(desired))
        end,
        
        help = function(target, desired)
                return SecureCmdOptionEval(UnitCanAssist("player",target) or 0, tonumber(desired))
        end,
        
        harm = function(target, desired)
                return SecureCmdOptionEval(UnitCanAttack("player",target) or 0, tonumber(desired))
        end,
        
        party = function(target, desired)
                return SecureCmdOptionEval(UnitPlayerOrPetInParty(target) or 0, tonumber(desired))
        end,
        
        raid = function(target, desired)
                return SecureCmdOptionEval(UnitPlayerOrPetInParty(target) or UnitPlayerOrPetInRaid(target) or 0, tonumber(desired))
        end,
        
        dead = function(target, desired)
                return SecureCmdOptionEval(UnitIsDead(target) or UnitIsGhost(target) or 0, tonumber(desired))
        end,
        
        -- indoors = function(target, desired)
        --         return SecureCmdOptionEval(IsIndoors() or 0, tonumber(desired))
        -- end,
        
        -- outdoors = function(target, desired)
        --         return SecureCmdOptionEval(IsOutdoors() or 0, tonumber(desired))
        -- end,
        
        --Swimming is very limited, only able to detect when the player is submerged and
        --does not have Aquatic Form or specific water breathing buff
        swimming = function(target, desired)
                return SecureCmdOptionEval(IsSwimming() or 0, tonumber(desired))
        end,
        
        mounted = function(target, desired)
                return SecureCmdOptionEval(IsMounted() or 0, tonumber(desired))
        end,
        
        
        stealth = function(target, desired)
                return SecureCmdOptionEval(IsStealthed() or 0, tonumber(desired))
        end,
        
        group = function(target, ...)
                local n = table.getn(arg)
                if ( n > 0 ) then
                        for i=1, n do
                                local desired = string.lower(arg[i])
                                if ( desired == "party" ) then
                                        if ( GetNumPartyMembers() > 0 ) then
                                                return true
                                        end
                                elseif ( desired == "raid" ) then
                                        if ( GetNumRaidMembers() > 0 ) then
                                                return true
                                        end
                                end
                        end
                else
                        return (GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)
                end
        end,
        
        stance = function(target, ...)
                local stance = GetShapeshiftForm(true)
                local n = table.getn(arg)
                if ( n > 0 ) then
                        for i=1, n do
                                local desired = tonumber(arg[i])
                                if ( desired == stance ) then
                                        return true
                                end
                        end
                else
                        return (stance > 0)
                end
        end,
        
        pet = function(target, ...)
                if ( not UnitExists("pet") ) then
                        return false
                end
                local n = table.getn(arg)
                if ( n > 0 ) then
                        local name = UnitName("pet")
                        local family = UnitCreatureFamily("pet") or ""
                        name, family = string.lower(name), string.lower(family)
                        for i=1, n do
                                local desired = string.lower(arg[i])
                                if ( desired == name or desired == family ) then
                                        return true
                                end
                        end
                else
                        return true
                end
        end,
        
        equipped = function(target, ...)
                local n = table.getn(arg)
                if ( n > 0 ) then
                        for i=1, n do
                                local type = string.lower(arg[i])
                                if ME_IsEquippedItemType(type) then
                                        return true
                                end
                        end
                end
                return false
        end,
        
        mod = function(target, ...)
                local n = table.getn(arg)
                if ( n > 0 ) then
                        for i=1, n do
                                local key = string.lower(arg[i])
                                if ( (key == "shift" and IsShiftKeyDown()) or
                                        (key == "ctrl" and IsControlKeyDown()) or
                                        (key == "alt" and IsAltKeyDown()) ) then
                                        return true
                                end
                        end
                else
                        return (IsShiftKeyDown() or IsControlKeyDown() or IsAltKeyDown())
                end
        end,
        
        channeling = function(target, ...)
                return ME_EventLog.Channeling == true
        end,
        
        --
        --Non WOW Conditions
        --
        pethappy = function (target,...) 
                if ( not UnitExists("pet") or (Select(2,UnitClass("player")) ~= "HUNTER") ) then
                        return false
                end
                
                return SecureCmdOptionEval((Select(1,GetPetHappiness()) == 3) or 0, tonumber(desired))
        end,
        
        petloyalty = function (target,...) 
                if ( not UnitExists("pet") or (Select(2,UnitClass("player")) ~= "HUNTER") ) then
                        return false
                end
                
                local loyalty = GetPetLoyalty()
                if loyalty then
                        local prank = tonumber(string.find(loyalty,"(%d+)"))
                        
                        local n = table.getn(arg)
                        if ( n > 0 ) then
                                if loyalty then
                                        for i=1, n do
                                                local desired = tonumber(arg[i])
                                                if desired == prank then
                                                        return true
                                                end
                                        end
                                end
                        else
                                return prank > 0
                        end
                else
                        return false
                end
        end,
        
        buff = function(target, desired)
                if desired ~= nil and desired ~= "" and string.find(desired,"([%w%_]+)") then
                        if (UnitExists(target) and HasBuff(desired,target)) then
                                return true
                        end
                end
                return false    
        end,
        
        debuff = function(target, desired)
                if desired ~= nil and desired ~= "" and string.find(desired,"([%w%_]+)") then
                        if (UnitExists(target) and HasDebuff(desired,target)) then
                                return true
                        end
                end
                return false    
        end,
        
        shadowform = function(target, desired)
                return SecureCmdOptionEval(IsShadowform() or 0, tonumber(desired))
        end,
        
}

local function SecureCmdOptionCheckOptions(o, ...)
        for i=1, table.getn(arg) do
                local option = strtrim(arg[i])
                if ( option ~= "" ) then
                        local invert = false
                        local args
                        option, args = strsplit(':', option)
                        option = string.lower(option)
                        if ( string.find(option, "^no") ) then
                                invert = true
                                option = string.sub(option, 3)
                        end
                        local handler = SecureCmdOptionHandlers[option]
                        if ( handler ) then
                                if ( args ) then
                                        if ( string.find(args, '/', 1, true) ) then
                                                if ( invert ) then
                                                        table.insert(o, function(target)
                                                                        return not handler(target, strsplit('/', args))
                                                        end)
                                                else
                                                        table.insert(o, function(target)
                                                                        return handler(target, strsplit('/', args))
                                                        end)
                                                end
                                        else
                                                if ( invert ) then
                                                        table.insert(o, function(target)
                                                                        return not handler(target, args)
                                                        end)
                                                else
                                                        table.insert(o, function(target)
                                                                        return handler(target, args)
                                                        end)
                                                end
                                        end
                                else
                                        if ( invert ) then
                                                table.insert(o, function(target)
                                                                return not handler(target)
                                                end)
                                        else
                                                table.insert(o, handler)
                                        end
                                end
                        else
                                ME_Print(L["Unknown Option"]..": "..option)
                        end
                end
        end
end

local function SecureCmdOptionCheckTarget(options)
        local target;
        local smartcast = false
        options = strtrim(string.sub(options,2,-2))
        local found,_, temp = string.find(options, "target=([^,]+)")
        if ( found ) then
                options = string.gsub(options, "target=[^,]+,?", "");
                target = temp
        end
        
        if string.find(options,"smartcast") then
                options = string.gsub(options, "smartcast,?", "");
                smartcast = true
        end
        
        return options, target, smartcast;
end

local function SecureCmdOptionBuildTable(tbl, optionSet)
        local t = {}
        for options in string.gfind(optionSet, "(%b[])") do
                local o = {}
                local target
                options, target, smartcast = SecureCmdOptionCheckTarget(options)
                SecureCmdOptionCheckOptions(o, strsplit(',', options))
                o.target = target
                o.smartcast = smartcast
                table.insert(t, o)
        end
        tbl[optionSet] = t
        return t
end

local OptionSetCache = setmetatable({}, {
                __index = SecureCmdOptionBuildTable
})


function SecureCmdOptionParseArgs(...)
        for i=1, table.getn(arg) do
                local cmd = arg[i]
                local _, start, options = string.find(cmd, "(%[.*%])");
                local action = string.sub(cmd, (start or 0)+1);
                local valid = true;
                local target;
                local smartcast = false
                if ( options ) then
                        local set = OptionSetCache[options];
                        local i = 1;
                        valid = false;
                        while ( not valid and i <= table.getn(set) ) do
                                local o = set[i];
                                local j = 1;
                                target = o.target;
                                smartcast = o.smartcast
                                valid = true;
                                while ( valid and j <= table.getn(o) ) do
                                        valid = o[j](target or "target");
                                        j = j + 1;
                                end
                                i = i + 1;
                        end
                end
                if ( valid ) then
                        return strtrim(action), target, smartcast
                end
        end
end

function SecureCmdOptionParseConditionsOnlyArgs(...)
        for i=1, table.getn(arg) do
                local cmd = arg[i]
                local _, start, options = string.find(cmd, "(%[.*%])")
                local valid = true
                local target
                if ( options ) then
                        local set = OptionSetCache[options]
                        local i = 1
                        
                        valid = false
                        while ( not valid and i <= table.getn(set) ) do
                                local o = set[i]
                                local j = 1
                                target = o.target
                                valid = true
                                while ( valid and j <= table.getn(o) ) do
                                        valid = o[j](target or "target")
                                        j = j + 1
                                end
                                i = i + 1
                        end
                end
                if ( valid ) then
                        return true
                end
        end
        return false
end

function SecureCmdItemParse(item)
        if not item then
                return nil, nil, nil
        end
        
        local found,_,bag, slot = string.find(item, "^(%d+)%s+(%d+)$")
        if not found then
                found,_, slot = string.find(item, "^(%d+)$")
        end
        
        if bag then
                item = GetContainerItemLink(bag, slot)
        elseif slot then
                item = GetInventoryItemLink("player", slot)
        end
        
        return item, bag, slot
end

function SecureCmdUseItem(name, bag, slot, target)
        if bag then
                UseContainerItem(bag, slot, target)
        elseif slot then
                UseInventoryItem(slot)
        else
                ME_UseItemByName(name, target)
        end
end

function SecureCmdOptionParseConditions(args)
        return SecureCmdOptionParseConditionsOnlyArgs(strsplit(';', args));
end

function SecureCmdOptionParse(args)
        return SecureCmdOptionParseArgs(strsplit(';', args))
end


local function SetCastSequenceIndex(entry, index)
        entry.index = index
end

local function ResetCastSequence(sequence, entry)
        SetCastSequenceIndex(entry, 1)
        ME_CastSequenceList[sequence] = nil
end

local function SetNextCastSequence(sequence, entry)
        if ( entry.index == table.getn(entry.spells) ) then
                ResetCastSequence(sequence, entry)
        else
                SetCastSequenceIndex(entry, entry.index + 1)
        end
end

local function CreateCastSquenceActions( tbl, ... )
        tbl.spells = {}
        tbl.items = {}
        for i=1, table.getn(arg) do
                local action = strtrim(arg[i])
                if (ME_GetBagItemInfo(action) or Select(3,SecureCmdItemParse(action))) then
                        tbl.items[i] = action
                        tbl.spells[i] = action
                else
                        tbl.spells[i] = action
                end
        end
end

local function ME_CastSequenceManagerOnEvent( ... )
        local reset = nil
        
        
        if event == "PLAYER_ENTERING_WORLD" then
                for sequence,entry in pairs(ME_CastSequenceList) do
                        SetCastSequenceIndex(entry,entry.index)
                end
                return
        end
        
        if event == "PLAYER_DEAD" then
                for sequence,entry in pairs(ME_CastSequenceList) do
                        ResetCastSequence(sequence,entry)
                end
                return
        end
        
        if event == "SPELLCAST_STOP" or event == "SPELLCAST_CHANNEL_STOP" then
                for sequence,entry in pairs(ME_CastSequenceList) do
                        SetNextCastSequence(sequence,entry)
                end
                return
        end
        
        if event == "PLAYER_TARGET_CHANGED" then
                reset = "target"
        elseif event == "PLAYER_REGEN_ENABLED" then
                reset = "combat"
        end
        
        
        if reset ~= nil then
                for sequence,entry in pairs(ME_CastSequenceList) do
                        if string.find(entry.reset,reset,1,true) then
                                ResetCastSequence(sequence,entry)
                        end
                end
        end
end

local function ME_CastSequenceManagerOnUpdate( ... )
        local elapsed = this.elapsed + arg1
        if elapsed < 1 then
                this.elapsed = elapsed
                return
        end
        
        for sequence,entry in pairs(ME_CastSequenceList) do
                if entry.timeout then
                        if elapsed >= entry.timeout then
                                ResetCastSequence(sequence,entry)
                        else
                                entry.timeout = entry.timeout - elapsed
                        end
                end
        end
        this.elapsed = 0
end

function ExecuteCastSequence( sequence, target )
        if not ME_CastSequenceManager then
                ME_CastSequenceManager = CreateFrame("Frame")
                ME_CastSequenceManager.elapsed = 0
                ME_CastSequenceManager:RegisterEvent("PLAYER_DEAD")
                ME_CastSequenceManager:RegisterEvent("PLAYER_ENTERING_WORLD")
                ME_CastSequenceManager:RegisterEvent("PLAYER_REGEN_ENABLED")
                ME_CastSequenceManager:RegisterEvent("PLAYER_TARGET_CHANGED")
                ME_CastSequenceManager:RegisterEvent("SPELLCAST_STOP")
                ME_CastSequenceManager:RegisterEvent("SPELLCAST_CHANNEL_STOP")
                ME_CastSequenceManager:SetScript("OnEvent",ME_CastSequenceManagerOnEvent)
                ME_CastSequenceManager:SetScript("OnUpdate",ME_CastSequenceManagerOnUpdate)
        end
        
        local entry = ME_CastSequenceList[sequence]
        if not entry then
                local found,_,reset, spells = string.find(sequence, "^reset=([^%s]+)%s*(.*)")
                if not found then
                        spells = sequence
                end
                entry = {}
                CreateCastSquenceActions(entry,strsplit(",",spells))
                entry.reset = string.lower(reset or "")
                ME_CastSequenceList[sequence] = entry
                entry.index = 1
        end
        
        local found, _, timeout = string.find(entry.reset,"(%d+)")
        if found then
                entry.timeout = ME_CastSequenceManager.elapsed + tonumber(timeout)
        end
        
        if (string.find(entry.reset,"shift",1,true) or string.find(entry.reset,"ctrl",1,true) or string.find(entry.reset,"alt",1,true)) and IsModifierKeyDown() then
                SetCastSequenceIndex(entry,1)
        end
        
        local item,spell = entry.items[entry.index], entry.spells[entry.index]
        if item then
                local name,bag,slot = SecureCmdItemParse(item)
                if slot then
                        if name then
                                spell = ME_GetBagItemInfo(name) or ""
                        else
                                spells = ""
                        end
                        entry.spells[entry.index] = spell
                end
                SecureCmdUseItem(name, bag, slot, target)
        else
                CastSpellByName(spell,target)
        end
        
        if spell == "" then
                SetNextCastSequence(sequence,entry)
        end
end