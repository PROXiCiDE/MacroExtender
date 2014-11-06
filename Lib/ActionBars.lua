local oldActionButton_SetTooltip, oldActionButton_OnUpdate, oldActionButton_Update, oldActionButton_UpdateUsable
local oldChatEdit_SendText

local ME_TooltipTimer = 0

local MacroIcon_Update = 0.5

--Tables that get cleared
local MacroIcon_Status = {}
local MacroIcon_Hash = {}
local MacroIcon_Refresh = {}

--Reusable Tables
local MacroIcon_Usable = {}
local MacroIcon_Timers = {}

local MacroIconTimer_Update = 0.2
local ME_ActionButton_OnUpdateTimer = 0

CreateFrame("GameTooltip","ME_ActionBarTooltip",UIParent,'GameTooltipTemplate')
ME_ActionBarTooltip:Hide()
ME_ActionBarTooltip:SetOwner(UIParent,"ANCHOR_NONE")

function ME_EditButtonTexture( texture )
        if not texture then
                return this.texture
        end
        
        local buttonIcon = getglobal(this:GetName().."Icon")
        if buttonIcon then
                buttonIcon:SetTexture(texture)
                buttonIcon:Show()
                this.texture = texture
        end
end

function ME_ButtonSetCount( button, count )
        if ( not button ) then
                return nil
        end
        
        if not count then
                count = 0
        end
        
        count = count
        button.count = count
        if ( count > 1 or (button.isBag and count > 0) ) then
                if ( count > 999 ) then
                        count = "*"
                end
                getglobal(button:GetName().."Count"):SetText(count)
                getglobal(button:GetName().."Count"):Show()
                getglobal(this:GetName().."Name"):Hide()
                return true
        else
                getglobal(button:GetName().."Count"):Hide()
                getglobal(this:GetName().."Name"):Show()
        end
        
        if count >= 1 then
                return true
        end
        
        return nil
end

function ME_IsValidTooltip( tipText )
        if getglobal(tipText):GetText() then
                return true
        end
end

function ME_ActionButton_OnLeave( ... )
        local bID = ActionButton_GetPagedID(this)
        
        isFocused = nil
        this.updateTooltip = nil
        GameTooltipTextLeft2:SetText()
        GameTooltipTextLeft2:SetWidth(100)
        GameTooltip:Hide()
end

function ME_ActionButton_OnEnter( ... )
        local bID = ActionButton_GetPagedID(this)
        MacroIcon_Refresh[bID] = true
        
        ME_ActionButton_SetTooltip()
        isFocused = true
end

local function MacroCommand( line, includeNoCondition )
        local _,_,cmd,conditions = string.find(line,"/(%a+)%s+(.+)")
        if not cmd and includeNoCondition then
                _,_,cmd = string.find(line,"/(%a+)")
        end
        return cmd,conditions
end

function ME_BreakdownMacro( macroBody )
        local ParseableCommands = { cast=true, castx=true, use=true }
        
        local t = {}
        for line in string.gfind(macroBody,"([^\r\n]+)") do
                if line then
                        local byPass
                        
                        local _,_,showType = string.find(line,"^#(.+)")
                        if showType then
                                showType,param1 = strsplit(" ",showType,2)
                                if showType then
                                        if showType == "showtooltip" or showType == "show" then
                                                t[showType] = param1
                                        end
                                end
                        else
                                local cmd,conditions = MacroCommand(line)
                                if conditions then
                                        local action = SecureCmdOptionParseRestrict(conditions)
                                        if action then
                                                if ParseableCommands[cmd] then
                                                        t.action = action
                                                        break
                                                end
                                        end
                                end
                        end
                end
        end
        macroBody = gsub(macroBody, "\n$", "");
        return macroBody, t
end

function ME_GetMacroBody( buttonID )
        local bID = ActionButton_GetPagedID(buttonID)
        local macroName = GetActionText(bID)
        if macroName then
                local macro,_,macroBody = GetMacroInfo(GetMacroIndexByName(macroName))
                if macroBody then
                        local macroItem, showType = ME_BreakdownMacro(macroBody)
                        return macro, macroBody, showType
                end
        end
        return nil
end

function ME_ActionButton_SetTooltip( ... )
        oldActionButton_SetTooltip()
        
        if not MacroExtender_Options.ActionBars then
                return
        end
        
        local function ColorRank(rank, color)
                color = color or "ff00ffff"
                if not rank then
                        local tipText = GameTooltipTextRight1:GetText()
                        if tipText then
                                GameTooltipTextRight1:SetText("|c"..color..tipText.."|r")
                        end
                else
                        GameTooltipTextRight1:SetText("|c"..color..rank.."|r")
                        GameTooltipTextRight1:Show()
                        GameTooltip:Show()
                end
        end
        
        local bID = ActionButton_GetPagedID(this)
        local macroName, _, showType = ME_GetMacroBody(this)
        local macroItem
        if showType then
                if showType.showtooltip then
                        macroItem = showType.showtooltip
                elseif showType.action then
                        macroItem = showType.action
                end
        end
        
        ME_ActionButton_SetIcon()
        
        if macroName and (macroItem and macroItem ~= "") then
                local spellTable = ME_GetSpellTable(macroItem)
                if spellTable then
                        local rank = spellTable.maxRanks or 1
                        local spell = spellTable["Rank "..rank]
                        if spell then
                                GameTooltip:SetSpell(spell.id,spellTable.bookType)
                                MacroIcon_Timers[bID].timer = MacroIconTimer_Update
                                if spell.rankName and not spellTable.akwardSpell then
                                        ColorRank(spell.rankName)
                                end
                        end
                else
                        local found, itemTable = ME_HasItem(macroItem)
                        local bag, slot
                        if found and itemTable then
                                if itemTable[1].bag then
                                        bag = itemTable[1].bag
                                        slot = itemTable[1].slot
                                end
                        end
                        
                        if bag then
                                GameTooltip:SetBagItem(bag,slot)
                                MacroIcon_Timers[bID].timer = MacroIconTimer_Update
                        else 
                                if not slot then
                                        slot = ME_HasInventory(macroItem)
                                end
                                
                                if slot then
                                        GameTooltip:SetInventoryItem("player", slot)
                                        MacroIcon_Timers[bID].timer = MacroIconTimer_Update
                                end
                        end
                end
                return
        end
        ColorRank()
end

--Updating the icon was a pain in the ass
function ME_ActionButton_SetIcon( eraseStatus )
        if not MacroExtender_Options.ActionBars then
                return
        end
        
        local function EditMacroIcon( macroName, macroItem, forceTexture)
                local index = GetMacroIndexByName(macroName)
                local icon, texture = ME_GetMacroIcon( macroItem )
                if index and texture then                        
                        if forceTexture then
                                ME_EditButtonTexture(texture)
                        elseif icon then
                                name, _, body, isLocal = GetMacroInfo(index)
                                EditMacro(index, name, icon, body, isLocal, 1)
                        end
                end
                
                return icon, texture
        end
        
        local bID = ActionButton_GetPagedID(this)
        
        if eraseStatus then
                MacroIcon_Status[bID] = nil
                MacroIcon_Hash[bID] = nil
        end
        
        if not MacroIcon_Timers[bID] then
                MacroIcon_Timers[bID] = {timer = 0}
        end
        
        if HasAction(bID) and MacroIcon_Usable[bID] then
                if not MacroIcon_Status[bID] then
                        ME_EditButtonTexture(GetActionTexture(bID))
                end
        end
        
        local macroName, macroBody, showType = ME_GetMacroBody(this)
        local macroItem
        if showType then
                if showType.show then
                        macroItem = showType.show
                elseif showType.action then
                        macroItem = showType.action
                end
        else
                
                return
        end
        
        if macroName and (macroItem and macroItem ~= "") then
                if HasAction(bID) then
                        local byPass
                        local hashString = macroItem .. bID
                        
                        local itemCount = ME_GetItemCount(macroItem)
                        if itemCount then
                                hashString = hashString .. itemCount
                        else
                                hashString = hashString
                        end
                        
                        if thisTexture then
                                hashString = hashString .. thisTexture
                        end
                        
                        local hash = ME_StringHash(hashString)
                        if MacroIcon_Hash[bID] then
                                if MacroIcon_Hash[bID].hash ~= hash then
                                        MacroIcon_Hash[bID] = nil
                                        return
                                end
                        else
                                MacroIcon_Hash[bID] = { hash = hash, macroItem = macroItem }
                        end
                        
                        if not itemCount then
                                if showType.action and not ME_GetSpellTable(macroItem) then
                                        macroItem = showType.action
                                end
                        end
                        
                        local texture
                        if not MacroIcon_Status[bID] then
                                _,texture = EditMacroIcon(macroName,macroItem,1)
                                
                                MacroIcon_Status[bID] = { 
                                        texture = texture,
                                        itemCount = itemCount,
                                        macroItem = macroItem,
                                }
                                
                        end
                        
                        if not ME_ButtonSetCount(this, itemCount) then
                                MacroIcon_Status[bID] = nil
                        end
                end
        end
end

--Used for updating equipped items, showing in the action bar to highlight
function ME_ActionButton_Update( ... )
        oldActionButton_Update()
        
        if not MacroExtender_Options.ActionBars then
                return
        end
        
        local itemID
        
        local function ColorItem( id )
                local border = getglobal(this:GetName().."Border")
                if id and id > 0 then
                        _,_,itemQuality = GetItemInfo(id)
                        if itemQuality then
                                local r,g,b = GetItemQualityColor(itemQuality)
                                border:SetVertexColor(r,g,b,0.7)
                                border:Show()
                        end
                else
                        border:Hide()
                end
        end
        
        local macroName, _, showType = ME_GetMacroBody(this)
        local macroItem
        if showType and showType.action then
                macroItem = showType.show
        end
        
        local bID = ActionButton_GetPagedID(this)
        
        if MacroIcon_Status[bID] and not HasAction(bID) then
                MacroIcon_Status[bID] = nil
                MacroIcon_Hash[bID] = nil
        end
        
        local bag, slot
        if macroName and (macroItem and macroItem ~= "") then
                local found, itemTable = ME_HasItem(macroItem)
                if found and itemTable then
                        bag = itemTable[1].bag
                        slot = itemTable[1].slot
                        itemID = itemTable.id
                else
                        slot = ME_HasInventory(macroItem)
                        if not slot then
                                _,bag,slot = SecureCmdItemParse(macroItem)
                                
                        end
                        
                        if bag then
                        elseif slot then
                                itemID = ME_GetInventoryItemInfo(slot)
                        end
                end
                
                ColorItem(itemID)
        else
                if HasAction(bID) then
                        ME_ActionBarTooltip:SetAction(bID)
                        local tipText = ME_ActionBarTooltipTextLeft1:GetText()
                        if tipText then
                                local found, itemTable = ME_HasItem(tipText)
                                if found and itemTable then
                                        ColorItem(itemTable.id)
                                end
                        end
                end
        end
end

function ME_ActionButton_OnUpdate( elapsed )
        oldActionButton_OnUpdate(elapsed)
        
        if not MacroExtender_Options.ActionBars then
                return
        end
        
        if ME_MacroFrame_Saved then
                MacroIcon_Status = WipeTable(MacroIcon_Status)
                ME_MacroFrame_Saved = nil
        end
        
        local bID = ActionButton_GetPagedID(this)
        if not MacroIcon_Timers[bID] then
                MacroIcon_Timers[bID] = {timer = 0}
        end
        
        if isFocused then
                if GameTooltip:IsOwned(this) then
                        ActionButton_SetTooltip()
                end  
        else
                if ME_ActionButton_OnUpdateTimer < MacroIcon_Update then
                        ME_ActionButton_OnUpdateTimer = ME_ActionButton_OnUpdateTimer + arg1
                        ME_ActionButton_UpdateUsable()
                else
                        ME_ActionButton_OnUpdateTimer = 0
                end
                
                if MacroIcon_Refresh[bID] then
                        MacroIcon_Refresh[bID] = nil
                end
                
                if not MacroIcon_Timers[bID].timer then
                        return
                end
                
                MacroIcon_Timers[bID].timer = MacroIcon_Timers[bID].timer - arg1
                if MacroIcon_Timers[bID].timer > 0 then
                        MacroIcon_Timers[bID].timer = nil
                        MacroIcon_Timers[bID].countUpdate = true
                end
        end
end

function ME_ActionButton_UpdateUsable( ... )
        oldActionButton_UpdateUsable()
        
        if not MacroExtender_Options.ActionBars then
                return
        end
        
        ME_ActionButton_SetIcon()
        
        local icon = getglobal(this:GetName().."Icon")
        local normalTexture = getglobal(this:GetName().."NormalTexture")
        
        local macroName, _, showType = ME_GetMacroBody(this)
        local macroItem
        if showType then
                if showType.show then
                        macroItem = showType.show
                elseif showType.action then
                        macroItem = showType.action
                end
        end
        
        local isUsable
        local bID = ActionButton_GetPagedID(this)
        
        if macroName and (macroItem and macroItem ~= "") then
                if not ME_GetItemCount(macroItem) and not ME_GetSpellTable(macroItem) then
                        if showType.action then
                                macroItem = showType.action
                        end
                end
                
                local spellTable = ME_GetSpellTable(macroItem)
                if spellTable then
                        local rank = spellTable.maxRanks or 1
                        local spell = spellTable["Rank "..rank]
                        if spell and spell.spellCost then
                                if UnitMana("player") >= spell.spellCost then
                                        isUsable = true
                                end
                        end
                else
                        local found, itemTable = ME_HasItem(macroItem)
                        if found and itemTable then
                                isUsable = true
                        else
                                item,_,slot = SecureCmdItemParse(macroItem)
                                if item and slot and ME_GetInventoryItemInfo(slot) then
                                        isUsable = true
                                end
                        end
                end
                
                if isUsable then
                        icon:SetVertexColor(1.0, 1.0, 1.0)
                        normalTexture:SetVertexColor(1.0, 1.0, 1.0)
                else
                        icon:SetVertexColor(0.4, 0.4, 0.4)
                        normalTexture:SetVertexColor(1.0, 1.0, 1.0)
                end
        end
        
        MacroIcon_Usable[bID] = isUsable
end

function ME_ChatParse( editBox )
        local text = editBox:GetText()
        if ( strlen(text) <= 0 ) then
                return
        end
        
        if string.find(text,"#[sS][hH][oO][wW]") then
                return
        end
        
        local stopMacro
        local cmd,cond = MacroCommand(text,1)
        if cmd then
                if cmd == "stopmacro" then
                        stopMacro = true
                        if cond then
                                if SecureCmdOptionParse(cond) then
                                        stopMacro = true
                                else
                                        stopMacro = nil
                                end
                        end
                end
        end
        
        if stopMacro then
                return
        end
        
        return true
end

--Prevents #show, #showtooltip from being displayed in chat channel etc
function ME_ChatEdit_SendText(editBox, addHistory)
        if not MacroExtender_Options.ActionBars then
                oldChatEdit_SendText(editBox, addHistory)
                return
        end
        
        if not ME_ChatParse(editBox) then
                return
        end
        
        oldChatEdit_SendText(editBox, addHistory)
end

function ME_UpdateActionBars( ... )
        local actionFrames = {
                "ActionButton%d", "MultiBarBottomLeftButton%d", "MultiBarBottomRightButton%d", "MultiBarRightButton%d",
                "MultiBarLeftButton%d", "BonusActionButton%d"
        }
        
        for _,v in pairs(actionFrames) do
                for i=1,12 do
                        local str = format(v,i)
                        getglobal(str):SetScript("OnLeave", ME_ActionButton_OnLeave)
                        getglobal(str):SetScript("OnEnter", ME_ActionButton_OnEnter)
                end
        end
end

function ActionBarHook( ... )
        ME_UpdateActionBars()
        local temp = ActionButton_SetTooltip
        if ( ME_HookFunction("ActionButton_SetTooltip", "ME_ActionButton_SetTooltip") ) then
                oldActionButton_SetTooltip = temp
        end
        local temp = ActionButton_Update
        if ( ME_HookFunction("ActionButton_Update", "ME_ActionButton_Update") ) then
                oldActionButton_Update = temp
        end
        local temp = ActionButton_OnUpdate
        if ( ME_HookFunction("ActionButton_OnUpdate", "ME_ActionButton_OnUpdate") ) then
                oldActionButton_OnUpdate = temp
        end
        local temp = ActionButton_UpdateUsable
        if ( ME_HookFunction("ActionButton_UpdateUsable", "ME_ActionButton_UpdateUsable") ) then
                oldActionButton_UpdateUsable = temp
        end
        
        local temp = ChatEdit_SendText
        if ( ME_HookFunction("ChatEdit_SendText", "ME_ChatEdit_SendText") ) then
                oldChatEdit_SendText = temp
        end
end