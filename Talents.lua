ME_Talents = {}

function ME_GetTalentRankInfo( talent )
        talent = string.lower(talent)
        if ME_Talents[talent] then
                return ME_Talents[talent].currRank,ME_Talents[talent].maxRank
        end
        return 0,0
end

function ME_UpdateTalentPoints( ... )
        if UnitLevel("player") < 10 then return end
        WipeTable(ME_Talents)
        
        if not ME_Talents then
                ME_Talents = {}
        end
        
        for t=1, GetNumTalentTabs() do
                for i=1, GetNumTalents(t) do
                        local name, icon, tier, column, currRank, maxRank = GetTalentInfo(t, i)
                        local parentTab, parentName = GetTalentTabInfo(t,i)
                        if name then
                                local name_l = string.lower(name)
                                if not ME_Talents[name_l] then
                                        ME_Talents[name_l] = {
                                                name = name,
                                                currRank = currRank, 
                                                maxRank = maxRank,
                                                parentName = parentName,
                                                parentTab = parentTab
                                        }
                                else
                                        local oldRank = ME_Talents[name_l].currRank
                                        if (not oldRank or (currRank > oldRank)) then
                                                ME_Talents[name_l].currRank = currRank
                                        end
                                end
                        end
                end
        end
end