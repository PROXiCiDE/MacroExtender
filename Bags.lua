ME_Bags = {}

function ME_IsItemInBags( name )
        if name then
                if string.find(name,"item:(%d+)") then
                        _, name = ME_GetLinkInfo(name)
                end
                name = string.lower(name)
                if ME_Bags[name] then
                        return true, ME_Bags[name]
                end
        end
        return nil
end

function ME_GetBagItemInfo( name )
        local found, item = ME_IsItemInBags(name)
        if found and item then
                return GetItemInfo(item.id)
        end
        return nil
end

function ME_UseItemByName( name, target )
        local found, item = ME_IsItemInBags(name)
        if not item[1].bag then
                return
        end
        if found then
                if item[1].slot then
                        UseContainerItem(item[1].bag,item[1].slot,target)
                else
                        UseIventoryItem(item[1].bag)
                end
        end
end

function ME_PickItemByName( name )
        local found, item = ME_IsItemInBags(name)
        if not item[1].bag then
                return
        end
        if found and item then
                PickupContainerItem(item[1].bag,item[1].slot)
        end
end

function ME_UpdateBags( ... )
        WipeTable(ME_Bags)
        
        if not ME_Bags then
                ME_Bags = {}
        end
        
        for i = 0, 4 do
                for j = 1, GetContainerNumSlots(i) do
                        local itemLink = GetContainerItemLink(i, j)
                        
                        if itemLink then
                                local id,name = ME_GetLinkInfo(itemLink)
                                if id>0 and name ~= nil then
                                        name = string.lower(name)
                                        
                                        if not ME_Bags[name] then
                                                ME_Bags[name] = { link = itemLink, id = id, name = name }
                                        end
                                        
                                        table.insert(ME_Bags[name],{ bag=i, slot=j })
                                end
                        end
                end
        end
end