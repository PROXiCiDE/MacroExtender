ME_Spells = {
        Casting = false,
        Channeling = false,
        ChannelSpell = "",
        Spell = "",
        ChanDuration = nil,
        Swimming = false,
}

--Split the spell and rank, incase the player includes the rank of the spell in /castx
function ME_SpellSplitRank( spell, ignoreCap )
        local found, f_spell, f_rank = nil,nil,nil
        if spell then
                found,_,f_spell,f_rank = string.find(spell,"([%a%s]+)%s*(%b())")
                if found then
                        f_rank = strtrim(string.sub(f_rank,2,-2))
                        spell = strtrim(f_spell)
                else
                        local SPLIT_Pattern = {
                                {"(conjure mana) (%a+)"}
                        }
                        for k,v in pairs(SPLIT_Pattern) do
                                local pat = v[1]
                                if pat then
                                        found,_,f_spell,f_rank = string.find(spell,v[1])
                                        if found then
                                                spell = f_spell
                                                break
                                        end
                                end
                        end
                        
                end
                if found and f_rank and (not ignoreCap) then
                        f_rank = string.gsub(f_rank,"(%a)(.*)", function (a,b) return string.upper(a)..b end)
                end
        end
        return spell,f_rank
end

--allows akward spells execution with macro without (rank)()
function ME_SpellHasAkwardRank( spell )
        local f_spell, f_rank = ME_SpellSplitRank(spell,true)
        if f_rank ~= nil and not string.find(f_rank,"rank") then
                if f_spell == "conjure mana" then
                        return true,f_rank,f_spell..' '..f_rank
                else
                        return true,f_rank,f_spell..' ('..f_rank..')'..'()'
                end
        end
        return false,f_rank,f_spell
end

function ME_GetSpellTable(spell, rankOnly)
        rankOnly = rankOnly or false
        local f_spell,f_rank = ME_SpellSplitRank(string.lower(spell))
        
        if ME_SpellHasAkwardRank(spell) then
                f_spell = f_spell..' '..'('..string.lower(f_rank)..')'
        end
        
        if ME_Spells[f_spell] then
                if f_rank and rankOnly then
                        if ME_Spells[f_spell][f_rank] then
                                return ME_Spells[f_spell][f_rank]
                        end
                else
                        return ME_Spells[f_spell]
                end
        end
        return nil
end

function ME_GetSpellID(spell, rank)
        spell = string.lower(spell)
        if not ME_Spells[spell] then
                return nil
        end
        
        if (not rank) or type(rank) == "number" then
                rank = rank or ME_Spells[spell].maxRanks
                if ME_Spells[spell].maxRanks >= rank then
                        rank = ME_Spells[spell].maxRanks
                end
                
                return ME_Spells[spell]["Rank "..rank].id        
        else
                rank = rank or ("Rank "..ME_Spells[spell].maxRanks)      
                if ME_Spells[spell][rank] then
                        return ME_Spells[spell][rank].id
                end
        end
        
        return nil
end

function ME_GetSpellEfficencay( spell )
        local spellTable = ME_GetSpellTable(spell)
        local found = false
        
        if spellTable then
                local l_spell = string.lower(spell)
                if string.find(l_spell,"life tap")  then
                        if Select(2,UnitClass("player")) == "WARLOCK" and UnitManaPct("player") < 100 then
                                local scale = 563
                                local mult = 1.2
                                local rank_mult = {0.38,0.68,0.8,0.8,0.8,0.8}
                                local base_damage = {30,75,140,220,310,424}
                                
                                for i=spellTable.maxRanks,1,-1 do
                                        local rankTable = spellTable['Rank '..i]
                                        if rankTable then
                                                local formula = (base_damage[i] + rank_mult[i] * scale)
                                                if ((UnitHealth("player") >= formula) and ((UnitManaMax("player") - UnitMana("player")) >= (formula * mult))) then
                                                        return "Life Tap(Rank "..i..")", true
                                                end
                                        end
                                end
                        else
                                return nil,found
                        end
                else
                        for i=spellTable.maxRanks,1,-1 do
                                local rankTable = spellTable['Rank '..i]
                                if rankTable then
                                        local mana_cost = rankTable.spellCost
                                        if found == false and (UnitMana("player") > (mana_cost*(1-rankTable.rank/100))) then
                                                if ME_SpellHasAkwardRank(rankTable.spellName) then
                                                        spell=rankTable.spellName
                                                else
                                                        spell=rankTable.spellName .. "(Rank "..i..")"
                                                end
                                                found = true
                                                break
                                        end 
                                end
                        end
                end
        end
        return spell,found
end


function ME_CastSpell( macro )
        local action, target, smartcast = SecureCmdOptionParse(macro)
        local selfcast = 0
        
        if target and target == "player" then
                selfcast = 1
        end
        
        if action then
                ME_CastOrUseItem(action,selfcast,smartcast)
        end
end

function ME_CastSequence( macro )
        local action, target, smartcast = SecureCmdOptionParse(macro)
        local selfcast = 0
        if action then
                if string.find(macro,"reset=([^%s]+)%s*%b[]") then
                        ME_Print("/castsequence "..L["Syntax Error"])
                        ME_Print("/castsequence [condition] reset=options spell,spell,spell")
                        ME_Print("/castsequence [pet] reset=target corruption,curse of agony,immolate,shadow bolt,shadow bolt,shadow bolt")
                        return
                end
        end
        if target and target == "player" then
                selfcast = 1
        end
        
        if action then
                ExecuteCastSequence(action,selfcast,smartcast)
        end
end

function ME_CastRandom( macro )
        local function GetRandomArgument(...)
                local n = table.getn(arg)
                return arg[math.random(1,n)]
        end
        
        local actions, target, smartcast = SecureCmdOptionParse(macro)
        local selfcast = 0
        
        if target and target == "player" then
                selfcast = 1
        end
        
        if actions then
                ME_CastOrUseItem(GetRandomArgument(strsplit(",",actions)),selfcast,smartcast)
        end
end

function ME_UpdateSpellBook( ... )
        WipeTable(ME_Spells)
        if not ME_Spells then
                ME_Spells = {}
        end
        
        local manaTable = {}        
        ME_SpellTooltip:SetOwner(UIParent,"ANCHOR_NONE")
        
        for i = 1, GetNumSpellTabs() do
                local name, texture, offset, numSpells = GetSpellTabInfo(i)
                local spellCost = 0
                
                if not name then  
                        break
                end   
                
                for s = offset + 1, offset + numSpells do
                        local spellName, rankName = GetSpellName(s, BOOKTYPE_SPELL)
                        local spellTexture = GetSpellTexture(s, BOOKTYPE_SPELL)
                        spellTexture = Select(3,string.find(spellTexture,"([%w%_]+)$"))
                        
                        ME_SpellTooltip:ClearLines()
                        ME_SpellTooltip:SetSpell(s,BOOKTYPE_SPELL)
                        
                        local tooltipText3 = ME_SpellTooltipTextLeft3:GetText()
                        local isChanneled = (ME_SpellTooltip:NumLines()>=3 and ME_SpellTooltipTextLeft3:IsShown() and ME_SpellTooltipTextLeft3:GetText() == "Channeled") 
                        
                        
                        local tt_found,_,powerCost,powerType
                        if ME_SpellTooltipTextLeft2:IsShown() then
                                tt_found,_,powerCost,powerType = string.find(ME_SpellTooltipTextLeft2:GetText(),"(%d+)(.*)")
                                if tt_found then
                                        spellCost = tonumber(powerCost)
                                        if powerType ~= nil or powerType ~= "" then
                                                powerType = strtrim(powerType)
                                        end
                                end
                        end
                        
                        --
                        --Reserved for reading the spell reagents
                        --
                        -- if ME_SpellTooltipTextLeft4:IsShown() then
                        -- end
                        
                        rank = tonumber(Select(3,string.find(rankName, "(%d+)$")))                 
                        local l_spell = string.lower(spellName)
                        
                        if not rank then
                                rank = 1
                                rankName = "Rank 1"
                        end
                        
                        
                        --
                        -- Akward Ranks, check for them
                        --
                        local ak_found, _, akwardSpell = ME_SpellHasAkwardRank(l_spell)
                        local spellManaIndex = spellCost
                        if ak_found == false then
                                ak_found = (
                                        (string.find(l_spell,"create%s+") and (Select(2,UnitClass("player")) == "WARLOCK")) or
                                        (string.find(l_spell,"conjure mana%s+") and (Select(2,UnitClass("player")) == "MAGE"))
                                )
                        end
                        
                        
                        -- Soulstone was a pain, only way to diff from rank is to get the health restored
                        if ak_found and string.find(l_spell,"soulstone") then
                                if ME_SpellTooltipTextLeft5:IsShown() then
                                        local h_found,_,h_restore = string.find(ME_SpellTooltipTextLeft5:GetText(),"(%d+)")
                                        if h_found then
                                                spellManaIndex = tonumber(h_restore)
                                        end
                                end
                        end
                        
                        
                        
                        if ak_found then
                                l_spell,l_rank = ME_SpellSplitRank(l_spell,true)
                                spellName = akwardSpell
                                
                                --make a creation spell for conjured items
                                if string.find(l_spell,"conjure %a+") then
                                        l_spell = "create "..l_spell
                                end
                                
                                if not manaTable[l_spell] then
                                        manaTable[l_spell] = {  
                                                akwardSpell = ak_found,
                                                powerType = powerType, 
                                                maxRanks = 1, 
                                                isChanneled = isChanneled,
                                                powerCost = {}
                                        }
                                else
                                        manaTable[l_spell].maxRanks = manaTable[l_spell].maxRanks + 1
                                end
                                
                                if not manaTable[l_spell]["powerCost"][spellManaIndex] then
                                        manaTable[l_spell]["powerCost"][spellManaIndex] = {
                                                id = tonumber(s),
                                                spellName = spellName,
                                                spellCost = spellCost,
                                                rankName = rankName,
                                                rank = 0, 
                                                spellTexture = spellTexture,
                                        }
                                end
                        else
                                --make a creation spell for conjured items
                                if string.find(l_spell,"conjure %a+") then
                                        l_spell = "create "..l_spell
                                end
                                
                                if not ME_Spells[l_spell] then
                                        ME_Spells[l_spell] = {  
                                                akwardSpell = ak_found,
                                                powerType = powerType, 
                                                maxRanks = rank, 
                                                isChanneled = isChanneled
                                        }
                                else
                                        local oldMaxRank = ME_Spells[l_spell].maxRanks
                                        if (not oldMaxRank or (rank > oldMaxRank)) then
                                                ME_Spells[l_spell].maxRanks = rank
                                        end
                                end
                                
                                if not ME_Spells[l_spell][rankName] then
                                        ME_Spells[l_spell][rankName] = {
                                                id = tonumber(s),
                                                spellName = spellName,
                                                spellCost = spellCost, 
                                                rank = rank, 
                                                rankName = rankName,
                                                spellTexture = spellTexture,
                                        }
                                end
                        end
                end
        end
        
        -- Sorts out the Ranks for Warlock akward ranks, such as [minor,lessor,greater,major] for smartcast
        -- This has been a real pain in the ass, but finaly works
        for spellName,v in pairs(manaTable) do
                if type(v) == "table" then
                        if not ME_Spells[spellName] then
                                ME_Spells[spellName] = {}
                        end
                        for k,x in pairs(v) do
                                if type(x) ~= "table" then
                                        ME_Spells[spellName][k] = x
                                else
                                        local temp_x = ME_SortNumTable(x,true)
                                        for d,f in pairs(temp_x) do
                                                if type(x[f]) == "table" then
                                                        if not ME_Spells[spellName]['Rank '..d] then
                                                                ME_Spells[spellName]['Rank '..d] = {}
                                                        end
                                                        for c,b in pairs(x[f]) do
                                                                if c == "rank" then
                                                                        b = d
                                                                end
                                                                ME_Spells[spellName]['Rank '..d][c] = b
                                                        end
                                                end
                                        end
                                end
                        end
                end
        end
end