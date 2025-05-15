Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(level, _)
    local assigned = Ext.Vars.GetModVariables(ModuleUUID).AssignedSubclasses or {}
    Ext.Vars.GetModVariables(ModuleUUID).AssignedSubclasses = assigned

    for _, entity in ipairs(Ext.Entity.GetAllEntitiesWithComponent("ServerCharacter")) do
        local charID = entity.Uuid and entity.Uuid.EntityUuid or entity
        if charID then

        for class, data in pairs(ClassData) do
            if data.MainPassive and Osi.HasPassive(charID, data.MainPassive) == 1 then
                local charLevel = Osi.GetLevel(charID)
                local unlockLevel = data.SubclassUnlockLevel or 3

                if charLevel >= unlockLevel then
                    local stored = assigned[charID]
                    local charName = Osi.GetDisplayName(charID) or "Unknown"

                    local found
                    for _, subclass in ipairs(data.SubclassTable) do
                        if Osi.HasPassive(charID, subclass) == 1 then
                            found = subclass
                            break
                        end
                    end

                    if stored and found and stored ~= found then
                        assigned[charID] = found
                        Ext.Utils.Print(string.format("[SUBCLASS] Mismatch for %s (%s). Updated stored subclass to: %s", charName, charID, found))

                    elseif stored and not found then
                        Osi.AddPassive(charID, stored)
                        Ext.Utils.Print(string.format("[SUBCLASS] Reapplied stored subclass to %s (%s): %s", charName, charID, stored))

                    elseif not stored and found then
                        assigned[charID] = found
                        Ext.Utils.Print(string.format("[SUBCLASS] Found subclass on %s (%s), storing: %s", charName, charID, found))

                    elseif not stored and not found then
                        local roll = math.random(1, #data.SubclassTable)
                        local selected = data.SubclassTable[roll]
                        assigned[charID] = selected
                        Osi.AddPassive(charID, selected)
                        Ext.Utils.Print(string.format("[SUBCLASS] Assigned new subclass to %s (%s): %s", charName, charID, selected))
                    end
                end
            end
        end
    end
end)