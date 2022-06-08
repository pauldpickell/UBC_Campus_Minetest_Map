-- If we have Minetest Classroom world manager installed
if (mc_worldManager) then
    schematicManager.registerSchematicPath("ubc", UBCMap.path .. "/map")
    mc_worldManager.spawnRealmSchematic = "ubc"

    function UBCMap.placeRealm(realm)
        UBCMap.place(realm.StartPos)
    end

    local status = UBCMap.storage:get_string("finishedGenerating")
    if (status == "false" or status == nil) then
        mc_worldManager.GetSpawnRealm()
    end
end



