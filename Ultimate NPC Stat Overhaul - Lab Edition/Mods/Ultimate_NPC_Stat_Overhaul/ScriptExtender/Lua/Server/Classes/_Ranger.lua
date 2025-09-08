-- Under construction

RangerLevelBoosts = {}

-- Dynamically get subclass names from ClassData
subclasses = {}
for _, subclassPassive in ipairs(ClassData.Ranger.SubclassTable) do
    local name = subclassPassive:match("CX_Ranger_(.-)_Boost")
    table.insert(subclasses, name or subclassPassive)
end

for level = 1, 20 do
    subclassPassives = {}
    for _, subclass in ipairs(subclasses) do
        subclassPassives[subclass] = {
            PassivePools = { { Passives = {}, Quantity = 0 }, },
            SpellPools   = { { Spells = {}, Quantity = 0 }, },
            SkillPools   = { { Skills = {}, Quantity = 0 }, },
        }
    end

    RangerLevelBoosts[level] = {
        PassivePools = { { Passives = {}, Quantity = 0 }, },
        SpellPools   = { { Spells = {}, Quantity = 0 }, },
        SkillPools   = { { Skills = {}, Quantity = 0 }, },
        SubclassPassives = subclassPassives
    }
end

-- Now, just override the levels you want with real data:
RangerLevelBoosts[2].PassivePools[1] = { Passives = {}, Quantity = 0 }
RangerLevelBoosts[3].SubclassPassives.BeastMaster.PassivePools[1] = { Passives = {}, Quantity = 0 }
-- ...and so on for any level/subclass you want to define!