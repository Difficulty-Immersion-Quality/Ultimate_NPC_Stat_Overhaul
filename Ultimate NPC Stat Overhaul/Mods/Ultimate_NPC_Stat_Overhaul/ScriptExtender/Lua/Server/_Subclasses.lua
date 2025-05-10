-- Map all subclass tables to their respective classes
Mods[ModTable].SubclassTables = {
    Barbarian = BarbarianSubclassTable,
    Bard = BardSubclassTable,
    Cleric = ClericSubclassTable,
    Druid = DruidSubclassTable,
    Fighter = FighterSubclassTable,
    Monk = MonkSubclassTable,
    Paladin = PaladinSubclassTable,
    Ranger = RangerSubclassTable,
    Rogue = RogueSubclassTable,
    Sorcerer = SorcererSubclassTable,
    Warlock = WarlockSubclassTable,
    Wizard = WizardSubclassTable
}

Mods[ModTable].SubclassUnlockLevel = {
    Barbarian = 3,
    Bard = 3,
    Cleric = 1,
    Druid = 2,
    Fighter = 3,
    Monk = 3,
    Paladin = 3,
    Ranger = 3,
    Rogue = 3,
    Sorcerer = 1,
    Warlock = 1,
    Wizard = 2
}

Mods[ModTable].BarbarianSubclassTable = {
    "CX_Barbarian_Berserker_Boost",
    "CX_Barbarian_WildMagic_Boost",
    "CX_Barbarian_Wildheart_Boost"
}

Mods[ModTable].BardSubclassTable = {
    "CX_Bard_Lore_Boost",
    "CX_Bard_Swords_Boost",
    "CX_Bard_Valor_Boost"
}

Mods[ModTable].ClericSubclassTable = {
    "CX_Cleric_Life_Boost",
    "CX_Cleric_Light_Boost",
    "CX_Cleric_Knowledge_Boost",
    "CX_Cleric_Nature_Boost",
    "CX_Cleric_War_Boost",
    "CX_Cleric_Trickery_Boost",
    "CX_Cleric_Tempest_Boost"
}

Mods[ModTable].DruidSubclassTable = {
    "CX_Druid_Land_Boost",
    "CX_Druid_Moon_Boost",
    "CX_Druid_Spores_Boost"
}

Mods[ModTable].FighterSubclassTable = {
    "CX_Fighter_BattleMaster_Boost",
    "CX_Fighter_EldritchKnight_Boost",
    "CX_Fighter_Champion_Boost"
}

Mods[ModTable].MonkSubclassTable = {
    "CX_Monk_FourElements_Boost",
    "CX_Monk_OpenHand_Boost",
    "CX_Monk_Shadow_Boost"

}

Mods[ModTable].PaladinSubclassTable = {
    "CX_Paladin_Ancients_Boost",
    "CX_Paladin_Devotion_Boost",
    "CX_Paladin_Vengeance_Boost",
    "CX_Paladin_Oathbreaker_Boost"
}

Mods[ModTable].RangerSubclassTable = {
    "CX_Ranger_Hunter_Boost",
    "CX_Ranger_GloomStalker_Boost",
    "CX_Ranger_BeastMaster_Boost"
}

Mods[ModTable].RogueSubclassTable = {
    "CX_Rogue_ArcaneTrickster_Boost",
    "CX_Rogue_Assassin_Boost",
    "CX_Rogue_Thief_Boost"
}

Mods[ModTable].SorcererSubclassTable = {
    "CX_Sorcerer_DraconicBloodline_Boost",
    "CX_Sorcerer_WildMagic_Boost",
    "CX_Sorcerer_StormSorcery_Boost"
}

Mods[ModTable].WarlockSubclassTable = {
    "CX_Warlock_Archfey_Boost",
    "CX_Warlock_Fiend_Boost",
    "CX_Warlock_GreatOldOne_Boost"
}

Mods[ModTable].WizardSubclassTable = {
    "CX_Wizard_Abjuration_Boost",
    "CX_Wizard_Conjuration_Boost",
    "CX_Wizard_Divination_Boost",
    "CX_Wizard_Enchantment_Boost",
    "CX_Wizard_Evocation_Boost",
    "CX_Wizard_Illusion_Boost",
    "CX_Wizard_Necromancy_Boost",
    "CX_Wizard_Transmutation_Boost"
}

---@param levelName string
---@param isEditorMode integer
function Osi.LevelGameplayStarted(levelName, isEditorMode)
    for _, character in pairs(Osi["DB_PartyCharacters"]:Get(nil)) do
        local charGUID = character[1]

        -- Skip dead or invalid characters
        if Osi.IsDead(charGUID) == 0 and Osi.IsPlayer(charGUID) == 1 then
            for class, subclassTable in pairs(Mods[ModTable].SubclassTables) do
                local mainPassive = "CX_" .. class .. "_ClassPassive"  -- Example: "CX_Barbarian_ClassPassive"
                local storedVarKey = "AssignedSubclass_" .. class

                -- Check if character has the class passive
                if Osi.HasPassive(charGUID, mainPassive) == 1 then
                    -- Check level requirement per class
                    local level = tonumber(Osi.GetLevel(charGUID))
                    local requiredLevel = Mods[ModTable].SubclassUnlockLevel[class] or 3  -- Default to level 3
                    if level >= requiredLevel then
                        -- Check PersistentVars if a subclass is already assigned
                        local stored = Mods[ModTable].PersistentVars[charGUID] and Mods[ModTable].PersistentVars[charGUID][storedVarKey]
                        if not stored then
                            -- Check if any subclass is already applied
                            local alreadyHasSubclass = false
                            for _, subclassPassive in ipairs(subclassTable) do
                                if Osi.HasPassive(charGUID, subclassPassive) == 1 then
                                    alreadyHasSubclass = true
                                    break
                                end
                            end

                            if not alreadyHasSubclass then
                                -- Assign a random subclass
                                local randomIndex = math.random(1, #subclassTable)
                                local chosenPassive = subclassTable[randomIndex]
                                Osi.AddPassive(charGUID, chosenPassive, 1)

                                -- Store in persistent vars
                                Mods[ModTable].PersistentVars[charGUID] = Mods[ModTable].PersistentVars[charGUID] or {}
                                Mods[ModTable].PersistentVars[charGUID][storedVarKey] = chosenPassive

                                print(string.format("[DEBUG] Assigned subclass '%s' to %s", chosenPassive, charGUID))
                            end
                        end
                    end
                end
            end
        end
    end
end



-- Debug print to verify initialization
print("[DEBUG] SubclassTables initialized:", Mods[ModTable].SubclassTables)