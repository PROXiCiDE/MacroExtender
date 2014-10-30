local oldContainerFrameItemButton_OnClick
local oldPaperDollItemSlotButton_OnClick

function CheckMacroSyntax( macro )
        local seps = {}
        local seps_count = 0
        for _,data in splitIter(";",macro) do
                table.insert(seps,data)
                seps_count = seps_count + 1
        end
        
        local is_closed = 0
        local results = false
        local last_sep = seps[seps_count]
        if last_sep then
                last_sep = strtrim(last_sep)
                local l_ch = string.sub(last_sep,-1)
                
                if string.find(last_sep,"%[") then
                        is_closed = string.find(last_sep,"%]")
                end
                
                if l_ch ~= ';' then
                        if  l_ch ~= ']' then
                                results = true
                        end
                end
        end
        
        return results,is_closed == nil
end

function BreakMacro( macro )
        local lines={}
        local count = 0
        for _,data in splitIter("\n",macro) do
                table.insert(lines,data)
                count = count + 1
        end
        
        local cmd,action
        
        local line = lines[count]
        
        if not line then
                line = macro
                lines = nil
                count = 1
        end
        
        if line then
                _,_,cmd,action = string.find(line,"/(%a+) (.+)")
                if not cmd then
                        _,_,cmd = string.find(line,"/(%a+)")
                end     
        end
        
        return cmd,action,line,lines,count
end

function FinishMacro( macro, command, addWhat )
        if string.len(macro) then
        end
        
        local lines={}
        local count = 0
        for _,data in splitIter("\n",macro) do
                table.insert(lines,data)
                count = count + 1
        end
        
        local line = lines[count]
        if not line then
                line = macro
                lines = nil
        end
        
        if line then
                local _,_,cmd,rest = string.find(line,"/(%a+) (.+)")
                if not cmd then
                        _,_,cmd = string.find(line,"/(%a+)")
                        if not cmd then
                                cmd = command or "equip"
                        end
                end
                
                local data = '/'..cmd..' '..(rest or "")
                
                if rest then
                        local r_sep,r_bracket = CheckMacroSyntax(rest)
                        
                        if r_bracket then
                                data = data..']'
                                r_sep = nil
                        end
                        
                        if r_sep then
                                data = data..';'..addWhat
                        else
                                data = data..addWhat
                        end                    
                else
                        data = data..addWhat
                end
                
                if lines then
                        lines[count] = data
                        return table.concat(lines,"\n")
                else
                        return string.gsub(data,"\n","")
                end
        end
        
        return macro..addWhat
end

--Future development
function GetMacroIcon( name )
        local function GetIconPath( icon )
                local _,_,path = string.find(icon,"Interface.Icons.(.+)") or icon
                return "Interface\\Icons\\"..path
        end
        
        local path
        
        local spellTable = ME_GetSpellTable(name)
        if spellTable and spellTable["Rank 1"] then
                path = GetIconPath(spellTable["Rank 1"].spellTexture)
        end
        
        if path then
                for i=1, GetNumMacroIcons() do
                        if GetMacroIconInfo(i) == path then
                                return i
                        end
                end
        end
end

function ME_PaperDollItemSlotButton_OnClick(button, ignoreModifiers)
        if not MacroExtender_Options.MacroUI then
                oldPaperDollItemSlotButton_OnClick(button,ignoreModifiers)
                return
        end
        
        if button == "LeftButton" then
                if not ignoreModifiers then
                        if IsShiftKeyDown() then
                                if IsControlKeyDown() and not IsAltKeyDown()  then
                                        if MacroFrame and MacroFrame:IsVisible() then
                                                local itemLink = GetInventoryItemLink("player", this:GetID());
                                                local itemName = Select(2,ME_GetLinkInfo(itemLink))
                                                if itemName then
                                                        local slot = tostring(this:GetID())
                                                        local macro = MacroFrameText:GetText()
                                                        local equipMacro = '/equip [noequipped:'..slot..']'..itemName
                                                        if macro then
                                                                if BreakMacro(macro) then
                                                                        equipMacro = "\n"..equipMacro
                                                                end
                                                        end
                                                        MacroFrame_AddMacroLine(equipMacro)
                                                end
                                        end
                                else
                                        if MacroFrame and MacroFrame:IsVisible() then
                                                local macro = MacroFrameText:GetText()
                                                if macro then
                                                        macro = FinishMacro(macro,'use',tostring(this:GetID()))
                                                else
                                                        macro = tostring(this:GetID())
                                                end
                                                
                                                MacroFrameText:SetText(macro)
                                        end
                                end
                        end
                end
        end
        
        --prevent character from closing due to dressing room
        if (not IsShiftKeyDown()) and ((not IsControlKeyDown()) or (not IsAltKeyDown())) then
                oldPaperDollItemSlotButton_OnClick(button,ignoreModifiers)
        end
end

function ME_ContainerFrameItemButton_OnClick(button, ignoreModifiers)
        if not MacroExtender_Options.MacroUI then
                oldContainerFrameItemButton_OnClick(button,ignoreModifiers)
                return
        end
        
        local itemCount = nil
        if button == "LeftButton" then
                if IsShiftKeyDown() and (not ignoreModifiers) then
                        if MacroFrame and MacroFrame:IsVisible() then
                                local bag,slot = this:GetParent():GetID(), this:GetID()
                                local itemLink = GetContainerItemLink(bag,slot)
                                local itemName = Select(2,ME_GetLinkInfo(itemLink))
                                if itemName then
                                        -- forgot what i was gonna do with this, lol, keeping for the moment
                                        -- itemCount = Select(2,GetContainerItemInfo(bag,slot))
                                        MacroFrame_AddMacroLine(itemName)
                                end
                        end
                end
        end
        
        --prevent item stack split if macro frame is open
        if (not (MacroFrame and MacroFrame:IsVisible() and IsShiftKeyDown())) then
                oldContainerFrameItemButton_OnClick(button,ignoreModifiers)
        end
end

--TODO
--Implement clicking on a item while TradeSkill frame is open, allow searching skills with materials linked

function MacroHook( ... )
        local temp = ContainerFrameItemButton_OnClick
        if ( ME_HookFunction("ContainerFrameItemButton_OnClick" , "ME_ContainerFrameItemButton_OnClick") ) then
                oldContainerFrameItemButton_OnClick = temp
        end
        
        temp = PaperDollItemSlotButton_OnClick
        if ( ME_HookFunction("PaperDollItemSlotButton_OnClick" , "ME_PaperDollItemSlotButton_OnClick") ) then
                oldPaperDollItemSlotButton_OnClick = temp
        end
end