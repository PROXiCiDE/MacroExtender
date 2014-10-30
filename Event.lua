ME_EventLog = {}

CreateFrame("Frame","ME_Frame")
ME_Frame:RegisterEvent("")
ME_Frame:RegisterEvent("ADDON_LOADED")
ME_Frame:RegisterEvent("VARIABLES_LOADED")

ME_Frame:RegisterEvent("PLAYER_LOGIN")
ME_Frame:RegisterEvent("PLAYER_DEAD")
ME_Frame:RegisterEvent("PLAYER_ENTERING_WORLD")

ME_Frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
ME_Frame:RegisterEvent("LEARNED_SPELL_IN_TAB")

ME_Frame:RegisterEvent("SPELLS_CHANGED")
ME_Frame:RegisterEvent("SPELLCAST_STOP")
ME_Frame:RegisterEvent("SPELLCAST_INTERRUPTED")
ME_Frame:RegisterEvent("SPELLCAST_FAILED")
ME_Frame:RegisterEvent("SPELLCAST_DELAYED")
ME_Frame:RegisterEvent("SPELLCAST_START")
ME_Frame:RegisterEvent("SPELLCAST_CHANNEL_START")
ME_Frame:RegisterEvent("SPELLCAST_CHANNEL_UPDATE")
ME_Frame:RegisterEvent("SPELLCAST_CHANNEL_STOP")

ME_Frame:RegisterEvent("MIRROR_TIMER_PAUSE")
ME_Frame:RegisterEvent("MIRROR_TIMER_STOP")
ME_Frame:RegisterEvent("MIRROR_TIMER_START")

ME_Frame:RegisterEvent("BAG_UPDATE")
ME_Frame:RegisterEvent("UPDATE_INVENTORY_ALERTS")
ME_Frame:RegisterEvent("UNIT_INVENTORY_CHANGED")

local function ME_FrameOnEvent( ... )
        -- body
        
        if event == "VARIABLES_LOADED" then
                InitAddon()
        end
        
        if event == "ADDON_LOADED" then
                MacroHook()
        end
        
        if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
                ME_UpdateTalentPoints()
                ME_UpdateSpellBook()
                
                ME_UpdateBags()
                ME_InventoryUpdate()
        end
        
        if event == "UPDATE_INVENTORY_ALERTS" then
                if arg1 == "player" then
                        ME_InventoryUpdate()
                end
        end
        if event == "UNIT_INVENTORY_CHANGED" then
                ME_InventoryUpdate()
        end
        
        if event == "PLAYER_ENTERING_WORLD" then
                ME_Print("Has been loaded")
        end
        
        if event == "BAG_UPDATE" then
                ME_UpdateBags()
                ME_UpdateMounts()
        end
        
        if event == "PLAYER_DEAD" then
                ME_EventLog.Swimming = false
        end
        
        if event == "ACTIONBAR_SLOT_CHANGED" then
                
        end
        
        if event == "LEARNED_SPELL_IN_TAB" then
                ME_UpdateTalentPoints()
                ME_UpdateSpellBook()
        end
        
        if event == "PLAYER_LEVEL_UP" or (event == "CHARACTER_POINTS_CHANGED" and arg1 == -1) then
                ME_UpdateTalentPoints()
        end
        
        if event == "LEARNED_SPELL_IN_TAB" or event == "SPELLS_CHANGED" then
                ME_UpdateTalentPoints()
                ME_UpdateSpellBook()
        end
        
        if event == "MIRROR_TIMER_START" then
                if arg1 == "BREATH" then
                        ME_EventLog.Swimming = true
                end
        end
        
        if event == "MIRROR_TIMER_STOP"  then
                if arg1 == "BREATH" then
                        ME_EventLog.Swimming = false
                end
        end
        
        --
        -- Spell Casting / Channel
        --
        if  event == "SPELLCAST_INTERRUPTED" or event == "SPELLCAST_FAILED" or event == "PLAYER_DEAD" then
                ME_EventLog.Casting = false
                ME_EventLog.Channeling = false
                ME_EventLog.Spell = ""
                ME_EventLog.ChannelSpell = ""
        end
        
        if event == "SPELLCAST_START" then
                ME_EventLog.Spell = arg1 or ""
                ME_EventLog.Casting = true
                ME_EventLog.Channeling = false
                ME_EventLog.ChannelSpell = ""
                
        end
        
        if event == "SPELLCAST_CHANNEL_START" then
                ME_EventLog.Casting = false
                ME_EventLog.Channeling = true
                ME_EventLog.ChanDuration = arg1
        end
        
        if event == "SPELLCAST_CHANNEL_UPDATE" then
                if arg1 == 0 then
                        ME_EventLog.Channeling = false
                        ME_EventLog.ChannelSpell = ""
                end
        end
        
        if event == "SPELLCAST_CHANNEL_STOP" then
                ME_EventLog.Channeling = false
                ME_EventLog.ChannelSpell = ""
        end
        
        if event == "SPELLCAST_STOP" then
                ME_EventLog.Casting = false
                if not ME_EventLog.Channeling then
                        ME_EventLog.Spell = ""
                end
        end
        
        -- PXED_PrintArgs({event=event, arg1=arg1, arg2=arg2, arg3=arg3, arg4=arg4, arg5=arg5, arg6=arg6, arg7=arg7, arg8=arg8, arg9=arg9});
end

ME_Frame:SetScript("OnEvent", ME_FrameOnEvent)