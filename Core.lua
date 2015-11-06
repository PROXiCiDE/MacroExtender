local L = ME_GetLocale()

MacroExtender_Options = nil
MacroExtender_OptionsDefaults = {
        MacroUI = true,
        ActionBars = true,
        Inventory = true
}

local ME_OptionOps = {
        ['+d'] = function(str) return string.find(str,"%d+") end,
        ['+a'] = function(str) return string.find(str,"%a+") end,
        ['+w'] = function(str) return string.find(str,"%w+") end,
}


--TODO: Implement help / settings to control Macro Extender
--Currently being used for debugging
--Do not use these

local function IsOptionEnabled( option )
        if option then
                return L["ENABLED"]
        end
        return L["DISABLED"]
end

function InitAddon( ... )
        if not MacroExtender_Options then
                MacroExtender_Options = ME_ShallowCopy(MacroExtender_OptionsDefaults)
        end
end

function CheckOptionSyntax(args, params)
        if not args then return end
        
        local count = 0
        for k,v in splitIter(",", params) do
                count = count + 1
        end
        
        local argc = (table.getn(args) - 1)
        if  argc < count then
                return false
        end
        
        local i = 2
        local found = 0
        local num_params = 0
        local invalidArgs = { index = {}, args = {}}
        for k,v in splitIter(",", params) do
                local option = args[i]
                if option then
                        if ME_OptionOps[v] then
                                if ME_OptionOps[v](option) then
                                        found = found + 1
                                else
                                        table.insert(invalidArgs["index"], i - 1)
                                        table.insert(invalidArgs["args"], option)
                                end
                        else
                                local correct_arg
                                if string.find(v,"/") then
                                        for _,y in splitIter("/",v) do
                                                if y == option then
                                                        found = found + 1
                                                        correct_arg = true
                                                end
                                        end
                                        
                                        if not correct_arg then
                                                table.insert(invalidArgs["index"], i - 1)
                                                table.insert(invalidArgs["args"], option)
                                        end
                                end
                        end
                else
                        break
                end
                i = i + 1
                num_params = num_params + 1
        end
        
        return found == count, invalidArgs, num_params
end

function ME_Usage( args, help, usage, params, option)
        if not args then return end
        
        local function UnpackArgs( tbl, num_params )
                local t={}
                num_params = num_params or table.getn(tbl)
                for i=2, num_params + 1 do
                        if not tbl[i] then
                                break
                        end
                        table.insert(t,tbl[i])
                end
                
                return unpack(t)
        end
        
        if type(help) == "table" then
                -- future development? May not be worth doing
        else
                if not args[2] then
                        ME_Print(help)
                        ME_Print(L["Usage"]..": /%s %s",args[1], usage)
                        return nil
                else
                        local results, invalidArgs, numArgs = CheckOptionSyntax(args,params)
                        if not results then
                                if invalidArgs then
                                        local param_idx, param_args = invalidArgs["index"][1],invalidArgs["args"][1]
                                        if table.getn(invalidArgs["index"]) > 1 then
                                                param_idx = table.concat(invalidArgs["index"],", ")
                                                param_args = table.concat(invalidArgs["args"],", ")
                                        else
                                        end
                                        ME_Print("")
                                        ME_Print(L["Usage"]..": /%s %s",args[1], usage)
                                        ME_Print(L["Unknown Option"]..": Args(%s) -> %s",param_idx,param_args)
                                end
                        end
                        return UnpackArgs(args, numArgs)
                end
        end
        return nil
end

local function ProxMacro_Handler(msg,editbox)
        if  msg or msg ~= "" then
                local args = {};
                local word;
                
                for word in string.gfind(msg, "[^%s]+") do
                        table.insert(args, word);
                end
                
                local cmd = ME_StringLower(args[1])
                
                if cmd == "macroui" then
                        local option = ME_Usage(args, "MacroUI "..L["interface improvement"], "on/off","on/off", MacroExtender_Options.MacroUI)
                        if option then
                                local option = ME_StringLower(option)
                                
                                local show = true
                                if option == "on" then
                                        MacroExtender_Options.MacroUI = true
                                elseif option == "off" then
                                        MacroExtender_Options.MacroUI = nil
                                end
                        else
                                ME_Print("MacroUI "..L["is currently"].." %s",IsOptionEnabled(MacroExtender_Options.MacroUI))
                        end
                elseif cmd == "actionbars" then
                        local option = ME_Usage(args, "ActionBars "..L["interface improvement"], "on/off","on/off", MacroExtender_Options.ActionBars)
                        if option then
                                local option = ME_StringLower(option)
                                
                                local show = true
                                if option == "on" then
                                        MacroExtender_Options.ActionBars = true
                                elseif option == "off" then
                                        MacroExtender_Options.ActionBars = nil
                                end
                        else
                                ME_Print("ActionBars "..L["is currently"].." %s",IsOptionEnabled(MacroExtender_Options.ActionBars))
                        end
                elseif cmd == "inventory" then
                        local option = ME_Usage(args, "InventorySlots "..L["interface improvement"], "on/off","on/off", MacroExtender_Options.Inventory)
                        if option then
                                local option = ME_StringLower(option)
                                
                                local show = true
                                if option == "on" then
                                        MacroExtender_Options.Inventory = true
                                elseif option == "off" then
                                        MacroExtender_Options.Inventory = nil
                                end
                        else
                                ME_Print("InventorySlots "..L["is currently"].." %s",IsOptionEnabled(MacroExtender_Options.Inventory))
                        end
                end
        end
end        

SLASH_PXMACRO1 = "/mex"
SlashCmdList["PXMACRO"] = ProxMacro_Handler

--Save the old cast macro command
SLASH_PXOLDCAST1 = "/oldcast"
SlashCmdList["PXOLDCAST"] = SlashCmdList["CAST"]

-- Macros
-- /castx will remain stay for compatability issues
SLASH_PXCASTX1 = "/castx"
SLASH_PXCASTX2 = "/use"
SlashCmdList["PXCASTX"] = function (msg,editbox)
        if  msg or msg ~= "" then
                ME_CastSpell(msg)
        end
end

-- Replace the old /cast with the new casting spell
SlashCmdList["CAST"] = SlashCmdList["PXCASTX"]

SLASH_PXCASTSEQUENCE1 = "/castsequence"
SLASH_PXCASTSEQUENCE2 = "/castseq"
SlashCmdList["PXCASTSEQUENCE"] = function (msg,editbox)
        if  msg or msg ~= "" then
                ME_CastSequence(msg)
        end
end

SLASH_PXCASTRANDOM1 = "/castrandom"
SLASH_PXCASTRANDOM2 = "/userandom"
SlashCmdList["PXCASTRANDOM"] = function (msg,editbox)
        if  msg or msg ~= "" then
                ME_CastRandom(msg)
        end
end

SLASH_PXCLICK1 = "/click"
SlashCmdList["PXCLICK"] = function (msg,editbox)
        if  msg or msg ~= "" then
                ME_Click(msg)
        end
end

SLASH_PXPICK1 = "/pick"
SlashCmdList["PXPICK"] = function (msg,editbox)
        if  msg or msg ~= "" then
                ME_PickItem(msg)
        end
end

SLASH_PXEQUIP1 = "/equip"
SLASH_PXEQUIP2 = "/eq"
SlashCmdList["PXEQUIP"] = function (msg,editbox)
        if  msg or msg ~= "" then
                ME_EquipItem(msg)
        end
end

SLASH_PXDISMOUNT1 = "/dismount"
SlashCmdList["PXDISMOUNT"] = function (msg,editbox)
        if  msg or msg ~= "" then
                ME_GenericFunction(msg,function() 
                                Dismount()
                end)
        else
                Dismount()
        end
end

SLASH_PXCANCELFORM1 = "/cancelform"
SlashCmdList["PXCANCELFORM"] = function (msg,editbox)
        if  msg or msg ~= "" then
                ME_GenericFunction(msg,function() 
                                CancelForm()
                end)
        else
                CancelForm()
        end
end

SLASH_PXSTOPCASTING1 = "/stopcasting"
SlashCmdList["PXSTOPCASTING"] = function (msg,editbox)
        if  msg or msg ~= "" then
                ME_GenericFunction(msg,function() 
                                SpellStopCasting()
                end)
        else
                SpellStopCasting()
        end
end

SLASH_PXMACRORELOADUI1 = "/reload"
SlashCmdList["PXMACRORELOADUI"] = function (msg,editbox)
        ReloadUI()
end

--- PET
SLASH_PXPETASSIST1 = "/petassist"
SlashCmdList["PXPETASSIST"] = function (msg,editbox)
        if  msg or msg ~= "" then
                ME_GenericFunction(msg,function() if UnitExists("pet") then AssistUnit("pet") end end)
        end
end

SLASH_PXPETATTACK1 = "/petattack"
SlashCmdList["PXPETATTACK"] = function (msg,editbox)
        if  msg or msg ~= "" then
                ME_GenericFunction(msg,function() if UnitExists("pet") then PetAttack() end end)
        end
end

SLASH_PXPETPASSIVE1 = "/petpassive"
SlashCmdList["PXPETPASSIVE"] = function (msg,editbox)
        if  msg or msg ~= "" then
                ME_GenericFunction(msg,function() if UnitExists("pet") then PetPassiveMode() end end)
        end
end

SLASH_PXPETDEFENSIVE1 = "/petdefensive"
SlashCmdList["PXPETDEFENSIVE"] = function (msg,editbox)
        if  msg or msg ~= "" then
                ME_GenericFunction(msg,function() if UnitExists("pet") then PetDefensiveMode() end end)
        end
end

SLASH_PXPETAGGRESSIVE1 = "/petaggressive"
SlashCmdList["PXPETAGGRESSIVE"] = function (msg,editbox)
        if  msg or msg ~= "" then
                ME_GenericFunction(msg,function() if UnitExists("pet") then PetAggressiveMode() end end)
        end
end

SLASH_PXPETFOLLOW1 = "/petfollow"
SlashCmdList["PXPETFOLLOW"] = function (msg,editbox)
        if  msg or msg ~= "" then
                ME_GenericFunction(msg,function() if UnitExists("pet") then PetFollow() end end)
        end
end

SLASH_PXPETSTAY1 = "/petstay"
SlashCmdList["PXPETSTAY"] = function (msg,editbox)
        if  msg or msg ~= "" then
                ME_GenericFunction(msg,function() if UnitExists("pet") then PetWait() end end)
        end
end

SLASH_PXHEARTHSTONE1 = "/hearth"
SlashCmdList["PXHEARTHSTONE"] = function (msg,editbox)
        if  msg or msg ~= "" then
                ME_GenericFunction(msg,function() 
                                local found,item = ME_HasItem("hearthstone")
                                if found and item then
                                        local startTime = GetContainerItemCooldown(item[1].bag,item[1].slot)
                                        if startTime == 0 then
                                                UseContainerItem(item[1].bag,item[1].slot)
                                        else
                                                Stuck()
                                        end
                                end
                end)
        end
end

SLASH_PXMOUNT1 = "/mount"
SlashCmdList["PXMOUNT"] = function (msg,editbox)
        if  msg or msg ~= "" then
                ME_GenericFunction(msg,function(action)
                                ME_CallMount(action)
                end)
        end
end

SLASH_PXTRADEITEM1 = "/tradeitem"
SlashCmdList["PXTRADEITEM"] = function (msg,editbox)
        if  msg or msg ~= "" then
                ME_TradeItem(msg)
        end
end

SLASH_PXSTOPMACRO1 = "/stopmacro"
SlashCmdList["PXSTOPMACRO"] = function (msg,editbox)
       -- This is a dummy macro all work is done via Chat Hook
       -- Not implemented yet
end