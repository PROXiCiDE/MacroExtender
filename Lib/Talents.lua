ME_Talents = {}

function ME_GetTalentRankInfo( talent )
        talent = ME_StringLower(talent)
        if ME_Talents[talent] then
                return ME_Talents[talent].currRank,ME_Talents[talent].maxRank
        end
        return 0,0
end

function ME_UpdateTalentPoints( ... )
        if UnitLevel("player") < 10 then return end
        ME_Talents = WipeTable(ME_Talents)
        
        for t=1, GetNumTalentTabs() do
                for i=1, GetNumTalents(t) do
                        local name, icon, tier, column, currRank, maxRank = GetTalentInfo(t, i)
                        local parentTab, parentName = GetTalentTabInfo(t,i)
                        if name then
                                local name_l = ME_StringLower(name)
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