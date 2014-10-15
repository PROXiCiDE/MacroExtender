local L = ME_GetLocale()

--TODO: Implement help / settings to control Macro Extender
--Currently being used for debugging
local function ProxMacro_Handler(msg,editbox)
        if  msg or msg ~= "" then
                local args = {};
                local word;
                
                for word in string.gfind(msg, "[^%s]+") do
                        table.insert(args, word);
                end
                
                if args[1] then
                        local cmd = string.lower(args[1])
                        if cmd == "buff" then
                                local i = 0
                                while GetPlayerBuff(i) >= 0 do
                                        local id,cancel = GetPlayerBuff(i,"HELPFUL|HARMFUL|PASSIVE")
                                        if(id > -1) then
                                                ME_Print("%d,%s",id,GetPlayerBuffTexture(id))
                                        end
                                        i = i + 1
                                end
                        end
                end
        end
end


SLASH_PXMACRO1 = "/pxmacro"
SlashCmdList["PXMACRO"] = ProxMacro_Handler


-- Macros
SLASH_PXCASTX1 = "/castx"
SLASH_PXCASTX2 = "/use"
SlashCmdList["PXCASTX"] = function (msg,editbox)
        if  msg or msg ~= "" then
                ME_CastSpell(msg)
        end
end

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

SLASH_PXPICK1 = "/pick"
SlashCmdList["PXPICK"] = function (msg,editbox)
        if  msg or msg ~= "" then
                ME_PickItem(msg)
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