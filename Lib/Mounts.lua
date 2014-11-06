local L = ME_GetLocale()
ME_Mounts = {}

-- Support added for Qiraji Mounts
-- Changed the way Class mounts are stored

function ME_CallMount( action )
        if not ME_Mounts then return end
        
        local function UseMount( tbl )
                --default, incase it does not have any requirements
                local results = true
                
                --Cuts down on the repetive If statements
                local function BooleanCheck( option,  condition )
                        if option then
                                if condition then
                                        results = true
                                else
                                        results = false
                                end
                        end
                end
                
                if tbl then
                        if not tbl.spell then
                                
                                BooleanCheck(tbl.playerLevel, tbl.playerLevel and (UnitLevel("player") >= tbl.playerLevel))
                                BooleanCheck(tbl.skillRiding, tbl.skillRiding and (GetRidingSkill() >= tbl.skillRiding))
                                BooleanCheck(tbl.qiraji, tbl.qiraji and (GetZoneText() == "Ahn'Qiraj"))
                                
                                
                                if results then
                                        UseContainerItem(tbl.bag,tbl.slot)
                                        return true
                                end
                                
                        else
                                CastSpellByName(tbl.spell)
                                return true
                        end
                end
                
                return
        end
        
        if action then
                action = ME_StringLower(action)
                if action == "random" then
                        local i = math.random(1,ME_Mounts.count)
                        if ME_Mounts[i] then
                                UseMount(ME_Mounts[i])
                        end
                else
                        for i=1, table.getn(ME_Mounts) do
                                if ME_Mounts[i] then
                                        local l_name = ME_StringLower(ME_Mounts[i].name)
                                        if string.find(l_name,action) then
                                                if UseMount(ME_Mounts[i]) then
                                                        break
                                                end
                                        end
                                end
                        end
                end
        else
                UseMount(ME_Mounts[1])
        end
end

--Was changed for Spell Texture, should help with Localization issues
local ME_MountSpells = {
        ["PALADIN"] = {
                ["Ability_Mount_Charger"] = 150,
                ["Spell_Nature_Swiftness"] = 75,
        },
        ["WARLOCK"] = {
                ["Ability_Mount_Dreadsteed"] = 150,
                ["Spell_Nature_Swiftness"] = 75
        },
}

function ME_UpdateMounts( ... )
        ME_Mounts = WipeTable(ME_Mounts)
        ME_Mounts.count = 0
        
        ME_InvTooltip:SetOwner(UIParent,"ANCHOR_NONE")
        local class = Select(2,UnitClass("player"))
        
        local function item_filterFN(itemName, id, bag, slot, itemLink, itemQuality,itemLevel,itemMinLevel,itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice)
                local texture = Select(9,GetItemInfo(id))
                if texture then
                        ME_InvTooltip:ClearLines()
                        ME_InvTooltip:SetHyperlink('item:'..id)
                        
                        if string.find(texture,"_Mount_",1,true) or string.find(texture,"_QirajiCrystal_",1,true) then
                                local skill,skillLevel,playerLevel
                                local qiraji, pvp
                                
                                if string.find(texture,"_QirajiCrystal_",1,true) then
                                        qiraji = true
                                end
                                
                                for i=1,ME_InvTooltip:NumLines() do
                                        local tip = getglobal("ME_InvTooltipTextLeft"..i)
                                        if tip and tip:IsShown() then
                                                local _,_,requires = string.find(tip:GetText(),"Requires (.+)")
                                                if requires then
                                                        local _,_,r_skill,r_skillLevel = string.find(requires,"(.+) %((%d+)%)")
                                                        local _,_,r_playerLevel = string.find(requires,"Level (%d+)")
                                                        if r_skillLevel then
                                                                skill = r_skill
                                                                skillLevel  = tonumber(r_skillLevel)
                                                        elseif r_playerLevel then
                                                                playerLevel = tonumber(r_playerLevel)
                                                        end
                                                end
                                        end
                                end
                                
                                ME_Mounts.count = ME_Mounts.count + 1
                                
                                table.insert(ME_Mounts, { 
                                                link = itemLink, 
                                                id = id,
                                                skill = skill,
                                                qiraji = qiraji,
                                                pvp = pvp,
                                                playerLevel = playerLevel,
                                                skillLevel = skillLevel,
                                                name = itemName, 
                                                bag= bag ,
                                                slot= slot
                                })
                        end
                end
        end
        
        local function spell_filterFN(bookType,spellTabName,spellIndex,spellName,rankName,spellCost,spellTexture,spellType,isChanneled)
                spellTexture = Select(3,string.find(spellTexture,"([%w%_]+)$"))
                local skill = ME_MountSpells[class][spellTexture]
                if skill then
                        ME_Mounts.count = ME_Mounts.count + 1
                        table.insert(ME_Mounts, {
                                        spell = spellName,
                                        name = spellName,
                                        skill = skill,
                                        playerLevel = 1
                                        
                        })    
                end
        end
        
        ME_ApplyBagFilter(item_filterFN)
        
        if ME_MountSpells[class] then
                ME_ApplySpellFilter(spell_filterFN,BOOKTYPE_SPELL)
        end
end
