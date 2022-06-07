-- If we have Minetest Classroom world manager installed
if (mc_worldManager) then
    schematicManager.registerSchematicPath("ubc", UBCMap.path .. "/map")
    mc_worldManager.spawnRealmSchematic = "ubc"
end

function UBCMap.placeRealm(realm)
    UBCMap.place(realm.StartPos)
end

