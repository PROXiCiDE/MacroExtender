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

function ME_GetBagItemInfo( name, smartcast )
        if smartcast then
                name = ME_FindAwkwardItem(name)
        end
        local found, item = ME_IsItemInBags(name)
        if found and item then
                return GetItemInfo(item.id)
        end
        return nil
end

function ME_UseItemByName( name, target, smartcast )
        if smartcast then
                name = ME_FindAwkwardItem(name)
        end
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

function ME_ItemHasAkwardRank( spell )
        local f_spell, f_rank = ME_SpellSplitRank(spell)
        
        local ITEM_LevelRanks = {
                firestone = true,
                soulstone = true,
                spellstone = true,
                healthstone = true,
                ["conjure mana"] = true,
        }
        
        if ITEM_LevelRanks[f_spell] then
                return true,f_spell,f_rank
        end
        
        return false,f_spell,f_rank
end
--/use [smartcast]firestone
--/eq [smartcast]firestone
--used for finding akward ranked items, such as Healthstone, will compare levels between which is found and use higher level
function ME_FindAwkwardItem( name )
        local AKWARD_WarlockTable = {
                [1] = "major",
                [2] = "greater",
                [3] = "lesser",
                [4] = "minor",
        }
        
        local AKWARD_MageTable = {
                [1] = "ruby",
                [2] = "citrine",
                [3] = "jade",
                [4] = "agate",
        }
        
        local function GrabCorrectTable( spell )
                local ITEM_Table = {
                        ["conjure mana"] = {switch=true,item="mana",table=AKWARD_MageTable}
                }
                
                for k,v in pairs(ITEM_Table) do
                        if k == spell then
                                return v.item,v.table,v.switch
                        end
                end
                return spell,AKWARD_WarlockTable,false
        end
        
        local name = string.lower(name or "")
        if ME_ItemHasAkwardRank(name) then
                --Find comparison if found because normal names are usually higher than lesser / minor items
                local item_name,item_table,item_switch = GrabCorrectTable(name)
                local p_level = UnitLevel("player")
                local c_level = 0
                
                local c_found, c_item = ME_IsItemInBags(name)
                if c_found then
                        _,_,_,c_level = GetItemInfo(c_item.id)
                end
                
                for i=1,4 do
                        local i_name
                        if item_switch then
                                i_name = item_name..' '..item_table[i]
                        else
                                i_name = item_table[i] ..' '.. item_name
                        end
                        
                        
                        
                        local i_found, i_item = ME_IsItemInBags(i_name)
                        if i_found then
                                
                                local _,_,_,i_level = GetItemInfo(i_item.id)
                                if i_level <= p_level and i_level >= c_level then
                                        return i_name
                                end
                        end
                end
        end
        
        return name
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