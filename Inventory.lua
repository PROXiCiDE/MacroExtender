ME_Inventory = {}

function ME_IsEquippedItemType( itemType )
        itemType = string.lower(itemType)
        if ME_Inventory[itemType] then
                return true
        end
        return false
end

function ME_InventoryUpdate( ... )
        WipeTable(ME_Inventory)
        if not ME_Inventory then
                ME_Inventory = {}
        end
        
        for i=1,19 do
                local itemLink = GetInventoryItemLink("player", i)
                if itemLink then
                        local id,name = ME_GetLinkInfo(itemLink)
                        if id>0 and name then
                                local itemType,itemSubType = GetItemInfoType(id)
                                itemType = string.lower(itemType or "")
                                itemSubType = string.lower(itemSubType or "")
                                
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