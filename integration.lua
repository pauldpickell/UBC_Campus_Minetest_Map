-- If we have Minetest Classroom world manager installed
if (mc_worldManager) then
    schematicManager.registerSchematicPath("ubc", UBCMap.path .. "/map")
    --  mc_worldManager.spawnRealmSchematic = "ubc"

    function UBCMap.placeRealm(realm)
        UBCMap.place(realm.StartPos, false)
    end
else

    Debug = {}
    function Debug.log(message)
        minetest.debug(message)
    end

    -- We'll register this command if we're not using the realm system from MC_worldmanager so that the map can still be placed.
    -- If we are using the realm system, we don't want this command as it can and will interfere.
    minetest.register_chatcommand("mosaic_mts", {
        description = "Mosaic map schematics together for UBC campus",
        privs = { server = true },
        func = function(x, y)
            UBCMap.place()
        end
    })
end



