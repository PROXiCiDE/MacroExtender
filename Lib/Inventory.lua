ME_Inventory = {}

local ME_InventorySlot = {
        ammoslot = 0,
        headslot = 1,
        neckslot = 2,
        shoulderslot = 3,
        shirtslot = 4,
        chestslot = 5,
        waistslot = 6,
        legsslot = 7,
        feetslot = 8,
        wristslot = 9,
        handsslot = 10,
        finger0slot = 11,
        finger1slot = 12,
        trinket0slot = 13,
        trinket1slot = 14,
        backslot = 15,
        mainhandslot = 16,
        offhandslot = 17,
        secondaryhandslot = 17,
        rangedslot = 18,
        tabardslot = 19,
        bag0slot = 20,
        bag1slot = 21,
        bag2slot = 22,
        bag3slot = 23
}

local ME_InventoryEquippable = {
        armor=true,
        container=true,
        projectile=true,
        quiver=true,
        weapon=true,
}

function ME_GetItemQualityColor(itemQuality)
        local color_t = {
                [0] = "ff9d9d9d",
                [1] = "ffffffff",
                [2] = "ff1eff00",
                [3] = "ff0070dd",
                [4] = "ffa335ee",
                [5] = "ffff8000",
                [6] = "ffffcc9d",
        }
        
        return color_t[itemQuality]
end

function ME_IsRedText(text)
        if text and text:GetText() then
                local r,g,b = text:GetTextColor()
                return math.floor(r*256) == 255 and math.floor(g*256) == 32 and math.floor(b*256) == 32
        end
end

function ME_IsEquippedItemType( itemType )
        itemType = ME_StringLower(itemType)
        if ME_Inventory[itemType] then
                return true
        else
                local slot
                if IsString(itemType) then
                        slot = ME_InventorySlot[itemType]
                        if not slot then
                                return ME_HasInventory(itemType) ~= nil
                        end
                else
                        slot = tonumber(itemType)
                end
                
                if slot then
                        if GetInventoryItemLink("player", slot) then
                                return true
                        end
                end
        end
        return false
end

function ME_IsEquippableByClass( name )    
        local found, item = ME_HasItem(name)
        if found and item then
                if item.link then
                        ME_InvTooltip:SetOwner(UIParent,"ANCHOR_NONE")
                        
                        ME_InvTooltip:ClearLines()
                        ME_InvTooltip:SetHyperlink('item:'..item.id)
                        
                        for i=1,ME_InvTooltip:NumLines() do
                                if ME_IsRedText(getglobal("ME_InvTooltipTextLeft"..i)) or ME_IsRedText(getglobal("ME_InvTooltipTextRight"..i)) then
                                        return false
                                end
                        end
                end
        else
                return false
        end
        return true
end

function ME_IsEquippableItem( name )
        local found, item = ME_HasItem(name)
        if found and item then
                
                if not ME_IsEquippableByClass(name) then
                        return false
                end
                
                local itemType,itemSubType = GetItemInfoType(item.id)
                itemType = ME_StringLower(itemType)
                if not ME_InventoryEquippable[itemType] then
                        return false
                end
        else
                return false
        end
        return true
end

function ME_GetInventoryItemInfo( slot )
        local itemLink = GetInventoryItemLink("player", slot)
        if itemLink then
                local i_id,i_name = ME_GetLinkInfo(itemLink)
                return i_id,i_name,itemLink
        end
        return nil
end

-- function ME_GetItemQuality( link )
--         local id = ME_GetInventoryItemInfo() 
-- end

--Returns SlotID,ItemID,ItemName or nil not found
function ME_HasInventory( name )
        if name then
                name = ME_StringLower(name)
                for i=0,19 do
                        local i_id,i_name = ME_GetInventoryItemInfo(i)
                        if i_id and i_id > 0 then
                                i_name = ME_StringLower(i_name)
                                if string.find(i_name,name) then
                                        return i
                                end
                        end
                end
        end
        return nil
end


--PaperDollFrame
function ME_EquipSaveMacro( name, deleteDup )
        deleteDup = deleteDup or false
        local equipList = {}
        local texture
        for i=0,19 do
                local itemLink = GetInventoryItemLink("player", i)
                if itemLink then
                        local id,name = ME_GetLinkInfo(itemLink)
                        texture = Select(10,GetItemInfo(id))
                        if id and id>0 and name then
                                table.insert(equipList,name)
                        end
                end
        end
        
        local found = GetMacroIndexByName(name)
        if found > 0 and deleteDup ~= false then
                DeleteMacro(found)
        end
        
        local eqString = "/equip " .. table.concat(equipList,",")
        CreateMacro(name,texture,eqString,nil,nil)
end

function ME_InventoryUpdate( ... )
        ME_Inventory = WipeTable(ME_Inventory)
        
        for i=0,19 do
                local itemLink = GetInventoryItemLink("player", i)
                if itemLink then
                        local id,name = ME_GetLinkInfo(itemLink)
                        if id and id>0 and name then
                                local itemType,itemSubType = GetItemInfoType(id)
                                itemType = ME_StringLower(itemType)
                                itemSubType = ME_StringLower(itemSubType)
                                
                                if itemType then
                                        if not ME_Inventory[itemType] then
                                                ME_Inventory[itemType] = { count = 1}
                                        else
                                                ME_Inventory[itemType].count = ME_Inventory[itemType].count + 1
                                        end
                                end
                                
                                if itemSubType then
                                        if not ME_Inventory[itemSubType] then
                                                ME_Inventory[itemSubType] = { count = 1}
                                        else
                                                ME_Inventory[itemSubType].count = ME_Inventory[itemSubType].count + 1
                                        end
                                end
                        end
                end
        end
end

local ME_BorderFrames = {}
function CreateBorder( frame, point )
        local bc
        
        if not frame:IsObjectType("Frame") then
                bc = this:GetParent():CreateTexture(nil,"OVERLAY")
        else
                bc = this:CreateTexture(nil,"OVERLAY")
        end
        
        if bc then
                bc:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
                bc:SetBlendMode("ADD")
                bc:SetWidth(70)
                bc:SetHeight(70)
                bc:SetAlpha(0.8)
                bc:SetPoint("CENTER", point or frame)
                bc:Hide()
        end
        
        return bc
end

local ME_CharacterSlots = {
        "CharacterHeadSlot",
        "CharacterNeckSlot",
        "CharacterShoulderSlot",
        "CharacterShirtSlot",
        "CharacterChestSlot",
        "CharacterWaistSlot",
        "CharacterLegsSlot",
        "CharacterFeetSlot",
        "CharacterWristSlot",
        "CharacterHandsSlot",
        "CharacterFinger0Slot",
        "CharacterFinger1Slot",
        "CharacterTrinket0Slot",
        "CharacterTrinket1Slot",
        "CharacterBackSlot",
        "CharacterMainHandSlot",
        "CharacterSecondaryHandSlot",
        [19] = "CharacterTabardSlot",
}

function ME_CharacterFrame_OnShow()
        
        if not MacroExtender_Options.Inventory then
                ME_CharacterFrame_OnHide()
                return
        end
        
        if CharacterFrame:IsShown() then
                for key, slot in pairs(ME_CharacterSlots) do
                        local slotFrame = getglobal(slot)
                        local itemLink = GetInventoryItemLink("player", key)
                        if slotFrame then
                                local bc = ME_BorderFrames[key]
                                if bc then
                                        if itemLink then
                                                local id = ME_GetInventoryItemInfo(key)
                                                _,_,itemQuality = GetItemInfo(id)
                                                
                                                if itemQuality > 1 then
                                                        local r,g,b = GetItemQualityColor(itemQuality)
                                                        bc:SetVertexColor(r,g,b)
                                                        bc:Show()
                                                else
                                                        bc:Hide()
                                                end
                                        else
                                                bc:Hide()
                                        end
                                end
                        end
                end
        end
end

function ME_CharacterFrame_OnHide()
        for key, slot in pairs(ME_CharacterSlots) do
                local bc = ME_BorderFrames[key]
                if bc then
                        bc:Hide()
                end
        end 
end

function PaperDollHook( ... )
        PaperDollFrame:SetFrameStrata("LOW")
        
        for key, slot in pairs(ME_CharacterSlots) do
                local slotFrame = getglobal(slot)
                local bc = CreateBorder(slotFrame)
                if bc then
                        if not ME_BorderFrames[key] then
                                ME_BorderFrames[key] = bc
                        end
                end
        end
end

local hook = CreateFrame("Frame")
hook:SetParent("CharacterFrame")
hook:SetScript("OnShow", ME_CharacterFrame_OnShow)
hook:SetScript("OnHide", ME_CharacterFrame_OnHide)
hook:RegisterEvent("UNIT_INVENTORY_CHANGED")
hook:SetScript("OnEvent", function()
                if arg1 == "player" then
                        ME_CharacterFrame_OnShow()
                end
end)