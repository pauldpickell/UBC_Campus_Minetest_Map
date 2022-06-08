-- If we have Minetest Classroom world manager installed
if (mc_worldManager) then
    schematicManager.registerSchematicPath("ubc", UBCMap.path .. "/map")
    mc_worldManager.spawnRealmSchematic = "ubc"

    function UBCMap.placeRealm(realm)
        UBCMap.place(realm.StartPos)
    end


end



