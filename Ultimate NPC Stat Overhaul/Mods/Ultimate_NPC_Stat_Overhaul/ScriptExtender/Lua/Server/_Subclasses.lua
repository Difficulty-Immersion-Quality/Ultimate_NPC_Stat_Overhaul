local ModTable = "Ultimate_NPC_Stat_Overhaul"

if Mods == nil then Mods = {} end
if Mods[ModTable] == nil then Mods[ModTable] = {} end
if Mods[ModTable].PersistentVars == nil then Mods[ModTable].PersistentVars = {} end

Mods[ModTable].ClassData = {
    Barbarian = {
        MainPassive = "CX_Barbarian_Boost",
        SubclassTable = {
            "CX_Barbarian_Berserker_Boost",
            "CX_Barbarian_WildMagic_Boost",
            "CX_Barbarian_Wildheart_Boost"
        },
        SubclassUnlockLevel = 3
    },
    Bard = {
        MainPassive = "CX_Bard_Boost",
        SubclassTable = {
            "CX_Bard_Lore_Boost",
            "CX_Bard_Swords_Boost",
            "CX_Bard_Valor_Boost"
        },
        SubclassUnlockLevel = 3
    },
    Cleric = {
        MainPassive = "CX_Cleric_Boost",
        SubclassTable = {
            "CX_Cleric_Knowledge_Boost",
            "CX_Cleric_Life_Boost",
            "CX_Cleric_Light_Boost",
            "CX_Cleric_Nature_Boost",
            "CX_Cleric_Trickery_Boost",
            "CX_Cleric_Tempest_Boost",
            "CX_Cleric_War_Boost"
        },
        SubclassUnlockLevel = 1
    },
    Druid = {
        MainPassive = "CX_Druid_Boost",
        SubclassTable = {
            "CX_Druid_Land_Boost",
            "CX_Druid_Moon_Boost",
            "CX_Druid_Spores_Boost"
        },
        SubclassUnlockLevel = 2
    },
    Fighter = {
        MainPassive = "CX_Fighter_Boost",
        SubclassTable = {
            "CX_Fighter_BattleMaster_Boost",
            "CX_Fighter_Champion_Boost",
            "CX_Fighter_EldritchKnight_Boost"
        },
        SubclassUnlockLevel = 3
    },
    Monk = {
        MainPassive = "CX_Monk_Boost",
        SubclassTable = {
            "CX_Monk_FourElements_Boost",
            "CX_Monk_OpenHand_Boost",
            "CX_Monk_Shadow_Boost"
        },
        SubclassUnlockLevel = 3
    },
    Paladin = {
        MainPassive = "CX_Paladin_Boost",
        SubclassTable = {
            "CX_Paladin_Ancients_Boost",
            "CX_Paladin_Devotion_Boost",
            "CX_Paladin_Vengeance_Boost",
            "CX_Paladin_Oathbreaker_Boost"
        },
        SubclassUnlockLevel = 1
    },
    Ranger = {
        MainPassive = "CX_Ranger_Boost",
        SubclassTable = {
            "CX_Ranger_BeastMaster_Boost",
            "CX_Ranger_GloomStalker_Boost",
            "CX_Ranger_Hunter_Boost"
        },
        SubclassUnlockLevel = 3
    },
    Rogue = {
        MainPassive = "CX_Rogue_Boost",
        SubclassTable = {
            "CX_Rogue_ArcaneTrickster_Boost",
            "CX_Rogue_Assassin_Boost",
            "CX_Rogue_Thief_Boost"
        },
        SubclassUnlockLevel = 3
    },
    Sorcerer = {
        MainPassive = "CX_Sorcerer_Boost",
        SubclassTable = {
            "CX_Sorcerer_DraconicBloodline_Boost",
            "CX_Sorcerer_WildMagic_Boost",
            "CX_Sorcerer_StormSorcery_Boost"
        },
        SubclassUnlockLevel = 1
    },
    Warlock = {
        MainPassive = "CX_Warlock_Boost",
        SubclassTable = {
            "CX_Warlock_Archfey_Boost",
            "CX_Warlock_Fiend_Boost",
            "CX_Warlock_GreatOldOne_Boost"
        },
        SubclassUnlockLevel = 1
    },
    Wizard = {
        MainPassive = "CX_Wizard_Boost",
        SubclassTable = {
            "CX_Wizard_Abjuration_Boost",
            "CX_Wizard_Conjuration_Boost",
            "CX_Wizard_Divination_Boost",
            "CX_Wizard_Enchantment_Boost",
            "CX_Wizard_Evocation_Boost",
            "CX_Wizard_Illusion_Boost",
            "CX_Wizard_Necromancy_Boost",
            "CX_Wizard_Transmutation_Boost"
        },
        SubclassUnlockLevel = 2
    }
}

Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(level, _)
    for _, entity in ipairs(Ext.Entity.GetAllEntitiesWithComponent("ServerCharacter")) do
        local charID = entity.Uuid and entity.Uuid.EntityUuid or entity
        if charID then
            for class, data in pairs(Mods[ModTable].ClassData) do
                if data.MainPassive and Osi.HasPassive(charID, data.MainPassive) == 1 then
                    local charLevel = Osi.GetLevel(charID)
                    local unlockLevel = data.SubclassUnlockLevel or 3

                    if charLevel >= unlockLevel then
                        Mods[ModTable].PersistentVars.AssignedSubclasses = Mods[ModTable].PersistentVars.AssignedSubclasses or {}
                        local stored = Mods[ModTable].PersistentVars.AssignedSubclasses[charID]
                        local charName = Osi.GetDisplayName(charID) or "Unknown"

                        -- Detect the actual subclass passive currently applied
                        local found
                        for _, subclass in ipairs(data.SubclassTable) do
                            if Osi.HasPassive(charID, subclass) == 1 then
                                found = subclass
                                break
                            end
                        end

                        if stored and found then
                            if stored ~= found then
                                -- Mismatch detected — update PersistentVars to match backend
                                Mods[ModTable].PersistentVars.AssignedSubclasses[charID] = found
                                Ext.Utils.Print("[SUBCLASS] Mismatch detected for " .. charName .. " (" .. charID .. "). Updated stored subclass to: " .. found)
                            end
                        elseif stored and not found then
                            -- Stored but missing on character — reapply
                            Osi.AddPassive(charID, stored)
                            Ext.Utils.Print("[SUBCLASS] Reapplied stored subclass to " .. charName .. " (" .. charID .. "): " .. stored)
                        elseif not stored and found then
                            -- Passive present but not stored — store it
                            Mods[ModTable].PersistentVars.AssignedSubclasses[charID] = found
                            Ext.Utils.Print("[SUBCLASS] Found subclass on " .. charName .. " (" .. charID .. "), storing: " .. found)
                        else
                            -- No stored or found subclass — roll and assign new one
                            local roll = math.random(1, #data.SubclassTable)
                            local selectedSubclass = data.SubclassTable[roll]
                            Mods[ModTable].PersistentVars.AssignedSubclasses[charID] = selectedSubclass
                            Osi.AddPassive(charID, selectedSubclass)
                            Ext.Utils.Print("[SUBCLASS] Assigned new subclass to " .. charName .. " (" .. charID .. "): " .. selectedSubclass)
                        end
                    end
                end
            end
        end
    end
end)

-- Debug print to verify initialization
print("[DEBUG] SubclassTables initialized:", Mods[ModTable].SubclassTables)


-- Utility stuff
-- function GoonPrintAllStoredSubclasses()
--     print("[DEBUG] Printing all stored subclass assignments:")
--     for charGUID, data in pairs(Mods[ModTable].PersistentVars) do
--         print("Character GUID:", charGUID)
--         for key, value in pairs(data) do
--             print(" -", key, "=", value)
--         end
--     end
-- end

-- function GoonResetAllStoredSubclasses()
--     print("[DEBUG] Resetting all stored subclass assignments.")
--     for charGUID, data in pairs(Mods[ModTable].PersistentVars) do
--         for class, _ in pairs(Mods[ModTable].SubclassTables) do
--             local key = "AssignedSubclass_" .. class
--             if data[key] then
--                 data[key] = nil
--                 print(string.format(" - Cleared %s for %s", key, charGUID))
--             end
--         end
--     end
-- end

-- function GoonResetSubclassForCharacter(charGUID)
--     print(string.format("[DEBUG] Resetting subclass assignments for %s", charGUID))
--     local data = Mods[ModTable].PersistentVars[charGUID]
--     if data then
--         for class, _ in pairs(Mods[ModTable].SubclassTables) do
--             local key = "AssignedSubclass_" .. class
--             if data[key] then
--                 data[key] = nil
--                 print(string.format(" - Cleared %s", key))
--             end
--         end
--     else
--         print(" - No subclass data found for", charGUID)
--     end
-- end

-- Ext.Osiris.RegisterConsoleCommand("print_subclasses", GoonPrintAllStoredSubclasses)
-- Ext.Osiris.RegisterConsoleCommand("reset_subclasses", GoonResetAllStoredSubclasses)
-- Ext.Osiris.RegisterConsoleCommand("reset_subclass_for", function(cmd, charGUID) GoonResetSubclassForCharacter(charGUID)
-- end)
