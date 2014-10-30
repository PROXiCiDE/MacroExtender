local L = ME_GetLocale()
ME_Mounts = {}

--TODO: Add Class ME_Mounts
function ME_CallMount( action )
        if not ME_Mounts then return end
        
        local function UseMount( tbl )
                --default, incase it does not have any requirements
                local results = true
                
                --Cuts down on the repetive If statements
                local function BooleanCheck( condition )
                        if condition then
                                results = true
                        else
                                results = false
                        end
                end
                
                if tbl then
                        if not tbl.spell then
                                BooleanCheck(tbl.playerLevel and (UnitLevel("player") >= tbl.playerLevel))
                                BooleanCheck(tbl.skillLevel and (GetRidingSkill() >= tbl.skillLevel))
                                
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
                action = string.lower(action)
                if action == "random" then
                        local i = math.random(1,ME_Mounts.count)
                        if ME_Mounts[i] then
                                UseMount(ME_Mounts[i])
                        end
                else
                        for i=1, table.getn(ME_Mounts) do
                                if ME_Mounts[i] then
                                        local l_name = string.lower(ME_Mounts[i].name)
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

local ME_MountSpells = {
        ["PALADIN"] = {
                ["Summon Warhorse"] = 150,
                ["Summon Charger"] = 75,
        },
        ["WARLOCK"] = {
                ["Summon Dreadsteed"] = 150,
                ["Summon Felsteed"] = 75
        },
}

function ME_UpdateMounts( ... )
        ME_Mounts = WipeTable(ME_Mounts)
        ME_Mounts.count = 0
        
        ME_InvTooltip:SetOwner(UIParent,"ANCHOR_NONE")
        local class = Select(2,UnitClass("player"))
        
        local function item_filterFN(itemLink,id,name,bag,slot)
                local texture = Select(9,GetItemInfo(id))
                if texture then
                        local skill,skillLevel,playerLevel
                        
                        ME_InvTooltip:ClearLines()
                        ME_InvTooltip:SetHyperlink('item:'..id)
                        
                        for i=1,ME_InvTooltip:NumLines() do
                                local tip = getglobal("ME_InvTooltipTextLeft"..i)
                                if tip and tip:IsShown() then
                                        local _,_,requires = string.find(tip:GetText(),"Requires (.+)")
                                        if requires then
                                                _,_,skill,skillLevel = string.find(requires,"(.+) %((%d+)%)")
                                                _,_,playerLevel = string.find(requires,"Level (%d+)")
                                                if skillLevel then
                                                        skillLevel  = tonumber(skillLevel)
                                                elseif playerLevel then
                                                        playerLevel  = tonumber(playerLevel)
                                                end
                                        end
                                end
                        end
                        
                        
                        
                        if string.find(texture,"Ability_Mount") and skillLevel > 0 then
                                ME_Mounts.count = ME_Mounts.count + 1
                                table.insert(ME_Mounts, { 
                                                link = itemLink, 
                                                id = id,
                                                skill = skill,
                                                playerLevel = playerLevel,
                                                skillLevel = skillLevel,
                                                name = name, 
                                                bag= bag ,
                                                slot= slot
                                })
                        end
                end
        end
        
        local function spell_filterFN(spellTabName,spellIndex,spellName,rankName,spellCost,spellTexture,spellType,isChanneled)
                local skill = ME_MountSpells[class][spellName]
                if skill then
                        ME_Mounts.count = ME_Mounts.count + 1
                        table.insert(ME_Mounts, {
                                        spell = spellName,
                                        name = spellName,
                                        skill = skill,
                        })    
                end
        end
        
        ME_ApplyBagFilter(item_filterFN)
        
        if ME_MountSpells[class] then
                ME_ApplySpellFilter(spell_filterFN,BOOKTYPE_SPELL)
        end
end
