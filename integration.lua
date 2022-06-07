-- If we have Minetest Classroom world manager installed
if (mc_worldManager) then
    function UBCMap.placeRealm(realm)
        UBCMap.place(realm.StartPos)
    end

    schematicManager.registerSchematicPath("ubc", UBCMap.path .. "/map.conf")
    mc_worldManager.spawnRealmSchematic = "ubc"
end

