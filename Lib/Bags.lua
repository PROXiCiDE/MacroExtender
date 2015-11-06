local L = ME_GetLocale()

bags = {}
ME_Bags = {}

--Short cuts
ZONE_AV = L["Alterac Valley"]
ZONE_WSG = L["Warsong Gulch"]
ZONE_AB = L["Arathi Basin"]

--Table elements are ordered by Best -> Worst 
local ME_FindBestOf_Restriction_Table = {
        [19068] = ZONE_WSG,  -- Warsong Gulch Silk Bandage
        [19067] = ZONE_WSG,  -- Warsong Gulch Mageweave Bandage
        [19066] = ZONE_WSG,  -- Warsong Gulch Runecloth Bandage
        [20067] = ZONG_AB,  -- Arathi Basin Silk Bandage
        [20244] = ZONG_AB,  -- Highlander's Silk Bandage
        [20235] = ZONG_AB,  -- Defiler's Silk Bandage
        [20065] = ZONG_AB,  -- Arathi Basin Mageweave Bandage
        [20237] = ZONG_AB,  -- Highlander's Mageweave Bandage
        [20232] = ZONG_AB,  -- Defiler's Mageweave Bandage
        [20066] = ZONG_AB,  -- Arathi Basin Runecloth Bandage
        [20243] = ZONG_AB,  -- Highlander's Runecloth Bandage
        [20234] = ZONG_AB,  -- Defiler's Runecloth Bandage
        [19307] = ZONE_AV,  -- Alterac Heavy Runecloth Bandage
} 

--Conjured items are seperated incase we accidetly try to feed a hunter pet it...
local ME_FindBestOf_Table = {
        healthpotion = {
                13446,  -- Major Healing Potion
                3928,   -- Superior Healing Potion
                1710,   -- Greater Healing Potion
                929,    -- Healing Potion
                4596,   -- Discolored Healing Potion
                858,    -- Lesser Healing Potion
                118,    -- Minor Healing Potion
        },
        firestone = {
                13701,  -- Major Firestone
                13700,  -- Greater Firestone
                13699,  -- Firestone
                1254,   -- Lesser Firestone
        },
        bandage = {
                19307,  -- Alterac Heavy Runecloth Bandage
                20234,  -- Defiler's Runecloth Bandage
                20243,  -- Highlander's Runecloth Bandage
                20066,  -- Arathi Basin Runecloth Bandage
                20232,  -- Defiler's Mageweave Bandage
                20237,  -- Highlander's Mageweave Bandage
                20065,  -- Arathi Basin Mageweave Bandage
                20235,  -- Defiler's Silk Bandage
                20244,  -- Highlander's Silk Bandage
                20067,  -- Arathi Basin Silk Bandage
                19066,  -- Warsong Gulch Runecloth Bandage
                19067,  -- Warsong Gulch Mageweave Bandage
                19068,  -- Warsong Gulch Silk Bandage
                14530,  -- Heavy Runecloth Bandage
                14529,  -- Runecloth Bandage
                8545,   -- Heavy Mageweave Bandage
                8544,   -- Mageweave Bandage
                6451,   -- Heavy Silk Bandage
                6450,   -- Silk Bandage
                3531,   -- Heavy Wool Bandage
                3530,   -- Wool Bandage
                2581,   -- Heavy Linen Bandage
                1251,   -- Linen Bandage
        },
        food = {
                13933,  -- Lobster Stew
                13935,  -- Baked Salmon
                8957,   -- Spinefin Halibut
                8948,   -- Dried King Bolete
                8932,   -- Alterac Swiss
                8950,   -- Homemade Cherry Pie
                8953,   -- Deep Fried Plantains
                8952,   -- Roasted Quail
                16171,  -- Shinsollo
                9681,   -- Grilled King Crawler Legs
                13930,  -- Filet of Redgill
                6887,   -- Spotted Yellowtail
                16766,  -- Undermine Clam Chowder
                16168,  -- Heaven Peach
                18255,  -- Runn Tum Tuber
                4608,   -- Raw Black Truffle
                4599,   -- Cured Ham Steak
                4602,   -- Moon Harvest Pumpkin
                4601,   -- Soft Banana Bread
                3927,   -- Fine Aged Cheddar
                13546,  -- Bloodbelly Fish
                1707,   -- Stormwind Brie
                4544,   -- Mulgore Spice Bread
                4539,   -- Goldenbark Apple
                3771,   -- Wild Hog Shank
                4607,   -- Delicious Cave Mold
                16169,  -- Wild Ricecake
                8364,   -- Mithril Head Trout
                4594,   -- Rockscale Cod
                4593,   -- Bristle Whisker Catfish
                2685,   -- Succulent Pork Ribs
                5478,   -- Dig Rat Stew
                5526,   -- Clam Chowder
                16170,  -- Steamed Mandu
                4606,   -- Spongy Morel
                3770,   -- Mutton Chop
                4538,   -- Snapvine Watermelon
                4542,   -- Moist Cornbread
                422,    -- Dwarven Mild
                733,    -- Westfall Stew
                2682,   -- Cooked Crab Claw
                5473,   -- Scorpid Surprise
                5525,   -- Boiled Clams
                2684,   -- Coyote Steak
                2683,   -- Crab Cake
                4592,   -- Longjaw Mud Snapper
                5095,   -- Rainbow Fin Albacore
                6316,   -- Loch Frenzy Delight
                6890,   -- Smoked Bear Meat
                4541,   -- Freshly Baked Bread
                414,    -- Dalaran Sharp
                4537,   -- Tel'Abim Banana
                2287,   -- Haunch of Meat
                4605,   -- Red-speckled Mushroom
                16167,  -- Versicolor Treat
                2680,   -- Spiced Wolf Meat
                6290,   -- Brilliant Smallfish
                787,    -- Slitherskin Mackerel
                2681,   -- Roasted Boar Meat
                9681,   -- Charred Wolf Meat
                16166,  -- Bean Soup
                4604,   -- Forest Mushroom Cap
                117,    -- Tough Jerky
                4536,   -- Shiny Red Apple
                4540,   -- Tough Hunk of Bread
                2070,   -- Darnassian Bleu
        },
        ["conjure food"] = {
                8076,   -- Conjured Sweet Roll
                8075,   -- Conjured Sourdough
                1487,   -- Conjured Pumpernickel
                1114,   -- Conjured Rye
                1113,   -- Conjured Bread
                5349,   -- Conjured Muffin
        },
        water = {
                19997,  -- Harvest Nectar
                19318,  -- Bottled Alterac Spring Water
                8766,   -- Morning Glory Dew
                1645,   -- Moonberry Juice
                10841,  -- Goldthorn Tea
                4791,   -- Enchanted Water
                1708,   -- Sweet Nectar
                9451,   -- Bubbling Water
                1205,   -- Melon Juice
                1179,   -- Ice Cold Milk
                159,    -- Refreshing Spring Water
        },
        ["conjure mana"] = {
                8008,   -- Mana Ruby
                8007,   -- Mana Citrine
                5513,   -- Mana Jade
                5514,   -- Mana Agate
        },
        soulstone = {
                16896,  -- Major Soulstone
                16895,  -- Greater Soulstone
                16893,  -- Soulstone
                16892,  -- Lesser Soulstone
                5232,   -- Minor Soulstone
        },
        manapotion = {
                13444,  -- Major Mana Potion
                13443,  -- Superior Mana Potion
                6149,   -- Greater Mana Potion
                3827,   -- Mana Potion
                3385,   -- Lesser Mana Potion
                2455,   -- Minor Mana Potion
        },
        spellstone = {
                13603,  -- Major Spellstone
                13602,  -- Greater Spellstone
                5522,   -- Spellstone
        },
        ["conjure water"] = {
                8079,   -- Conjured Crystal Water
                8078,   -- Conjured Sparkling Water
                8077,   -- Conjured Mineral Water
                3772,   -- Conjured Spring Water
                2136,   -- Conjured Purified Water
                2288,   -- Conjured Fresh Water
                5350,   -- Conjured Water
        },
        healthstone = {
                19013,  -- Rank 2/2 Talent improved Major Healthstone
                19012,  -- Rank 1/2 Talent improved Major Healthstone
                9421,   -- Major Healthstone
                19011,  -- Rank 2/2 Talent improved Greater Healthstone
                19010,  -- Rank 1/2 Talent improved Greater Healthstone
                5510,   -- Greater Healthstone
                19009,  -- Rank 2/2 Talent improved Healthstone
                19008,  -- Rank 1/2 Talent improved Healthstone
                5509,   -- Healthstone
                19007,  -- Rank 2/2 Talent improved Lesser Healthstone
                19006,  -- Rank 1/2 Talent improved Lesser Healthstone
                5511,   -- Lesser Healthstone
                19005,  -- Rank 2/2 Talent improved Minor Healthstone
                19004,  -- Rank 1/2 Talent improved Minor Healthstone
                5512,   -- Minor Healthstone
        },
}

function ME_GetLinkInfo( link )
        local name
        if not link then
                return ""
        end
        for id, name in string.gfind(link, "|c%x+|Hitem:(%d+):%d+:%d+:%d+|h%[(.-)%]|h|r$") do
                return tonumber(id), name
        end
        return nil
end

function ME_HasItem( name )
        if name then
                if string.find(name,"item:(%d+)") then
                        _, name = ME_GetLinkInfo(name)
                else
                        local item,bag,slot = SecureCmdItemParse(name)
                        if item and bag and slot then
                                _, name = ME_GetLinkInfo(item)
                        end
                end
                
                if name then
                        name = ME_StringLower(name)
                        if ME_Bags[name] then
                                return true, ME_Bags[name]
                        end
                end
        end
        return nil
end

local iii = 0
function ME_GetItemCount( itemName )
        if not itemName then return nil end
        local stackCount, itemCount
        local found, item = ME_HasItem(itemName)
        if found and item then
                itemCount = item.count
                stackCount = Select(7, GetItemInfo(item.id))
        else 
                itemName = ME_StringLower(itemName)
                for container = 0, 4 do
                        for slot = 1, GetContainerNumSlots(container) do
                                itemLink = GetContainerItemLink(container, slot)
                                if itemLink then
                                        local id, name = ME_GetLinkInfo(itemLink)
                                        if id and name then
                                                if ME_StringLower(name) == itemName then
                                                        local thisCount = Select(2,GetContainerItemInfo(container, slot))
                                                        if not stackCount then
                                                                stackCount = Select(7, GetItemInfo(id))
                                                        end
                                                        if not itemCount then
                                                                itemCount = 0
                                                        end
                                                        itemCount = itemCount + thisCount
                                                end
                                        end
                                end
                        end
                end
                for slot = 0, 19 do
                        itemLink = GetInventoryItemLink("player", slot)
                        if itemLink then
                                local id, name = ME_GetLinkInfo(itemLink)
                                if id and name then
                                        if ME_StringLower(name) == itemName then
                                                if not stackCount then
                                                        stackCount = Select(7, GetItemInfo(id))
                                                end
                                                if not itemCount then
                                                        itemCount = 0
                                                end
                                                itemCount = itemCount + GetInventoryItemCount("player", slot)
                                        end
                                end
                        end
                end
        end
        
        return itemCount, stackCount
end

function ME_GetItemInfo( name, smartcast )
        if smartcast then
                name = ME_FindBestItemOf(name)
        end
        local found, item = ME_HasItem(name)
        if found and item then
                return GetItemInfo(item.id)
        end
        return nil
end

function ME_UseItemByName( name, target, smartcast )
        if smartcast then
                name = ME_FindBestItemOf(name)
        end
        local found, item = ME_HasItem(name)
        if not item[1].bag then
                return
        end
        
        if found then
                if item[1].slot then
                        UseContainerItem(item[1].bag,item[1].slot,target)
                else
                        local slot = ME_HasInventory(name)
                        if slot then
                                UseIventoryItem(slot)
                        else
                                UseIventoryItem(item[1].bag)
                        end
                end
        end
end

function ME_PickItemByName( name )
        local f_name = ME_FindBestItemOf(name)
        if f_name then
                name = f_name
        end
        local _, item = ME_HasItem(name)
        if not item then
                return
        else
                PickupContainerItem(item[1].bag,item[1].slot)
        end
end

function ME_FindItemByID( id )
        for k,v in pairs(ME_Bags) do
                if v.id == id then
                        return true, ME_GetItemCount(v.name)
                end
        end
        return false,0
end

function ME_IsItemOfType( id, itemType )
        if id and id>0 then
                local t_list = ME_FindBestOf_Table[itemType]
                if t_list then
                        for k,v in pairs(t_list) do
                                if id == v then
                                        return true
                                end
                        end
                end
        end
        
        return
end

--Return name,id,link
function ME_FindBestItemOf( name )
        name = ME_StringLower(name)
        local t_list = ME_FindBestOf_Table[name]
        if t_list then
                for k,v in pairs(t_list) do
                        local i_name,i_link,_,i_level = GetItemInfo(v)
                        if i_name then
                                local found, item = ME_HasItem(i_name)
                                if found and item and item.id == v then
                                        local r_zone = ME_FindBestOf_Restriction_Table[item.id]
                                        if r_zone and GetZoneText() ~= r_zone then
                                                -- skip
                                        else
                                                return i_name,v,item.link
                                        end
                                end
                        end
                end
        end
        
        return name
end

function ME_CastOrUseItem(action, selfcast, smartcast)
        local name, bag, slot = SecureCmdItemParse(action)
        if slot or ME_GetItemInfo(name, smartcast) then
                SecureCmdUseItem(name,bag,slot,selfcast, smartcast)
        else
                if smartcast then
                        action = Select(1,ME_GetSpellEfficencay(action))
                end
                
                if action then
                        local spellTable = ME_GetSpellTable(action)
                        if spellTable then
                                if spellTable.isChanneled then
                                        ME_Spells.ChannelSpell = action
                                end
                        end
                        
                        CastSpellByName(action,selfcast)
                end
        end
end

function ME_PickItem( macro )
        local action = SecureCmdOptionParse(macro)
        
        if action then
                local name, bag, slot = SecureCmdItemParse(action)
                if bag and slot then
                        PickupContainerItem(bag,slot)
                else
                        ME_PickItemByName(action)
                end
        end
end

function ME_EquipItem( macro )
        local function EquipFromList( smartcast, ... )
                for i=1,table.getn(arg) do
                        local item = arg[i]
                        if item then
                                local name, bag, slot = SecureCmdItemParse(item)
                                local item = ME_GetItemInfo(name, smartcast) or name
                                if slot or item then
                                        if ME_IsEquippableByClass(item) then
                                                SecureCmdUseItem(name,bag,slot,false,smartcast)
                                        end
                                end
                        end
                end
        end
        
        local actions,target,smartcast = SecureCmdOptionParse(macro)
        if actions then
                EquipFromList(smartcast,strsplit(",",actions))
        end
end

function ME_TradeItem( macro )
        local actions,target,smartcast = SecureCmdOptionParse(macro)
        ME_Print(actions)
        for b=0,4 do 
                for s=1,GetContainerNumSlots(b) do
                        local n=GetContainerItemLink(b,s)
                        if n and string.find(n,actions) then
                                PickupContainerItem(b,s)
                                DropItemOnUnit("target")
                                break
                        end
                end
        end
end

function ME_UpdateBags( ... )
        ME_Bags = WipeTable(ME_Bags)
        
        local function item_filterFN(itemName, id, bag, slot, itemLink, itemQuality,itemLevel,itemMinLevel,itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice)
                local l_name = ME_StringLower(itemName)
                if not ME_Bags[l_name] then
                        ME_Bags[l_name] = { 
                                link = itemLink, 
                                id = id, 
                                name = itemName,
                                count = 1,
                                itemTexture = itemTexture 
                        }
                else
                        ME_Bags[l_name].count = ME_Bags[l_name].count + 1
                end
                table.insert(ME_Bags[l_name],{ bag=bag, slot=slot })
        end
        
        ME_ApplyBagFilter(item_filterFN)
end