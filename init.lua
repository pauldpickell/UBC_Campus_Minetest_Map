UBCMap = { path = minetest.get_modpath("ubc_campus_minetest_map"), storage = minetest.get_mod_storage() }

function UBCMap:placeSchematic(pos1, pos2, v, rotation, replacement, force_placement)

    -- Read data into LVM
    local vm = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map(pos1, pos2)
    local a = VoxelArea:new {
        MinEdge = emin,
        MaxEdge = emax
    }

    minetest.place_schematic_on_vmanip(vm, pos1, UBCMap.path .. "/schems/ubc_blocks_" .. tostring(v) .. ".mts", rotation, replacement, force_placement)
    minetest.chat_send_all("combined terrain tile " .. tostring(v))
    minetest.place_schematic_on_vmanip(vm, pos1, UBCMap.path .. "/schems/ubc_trees_" .. tostring(v) .. ".mts", rotation, replacement, force_placement)
    minetest.chat_send_all("combined trees tile " .. tostring(v))
    minetest.place_schematic_on_vmanip(vm, pos1, UBCMap.path .. "/schems/ubc_urban_" .. tostring(v) .. ".mts", rotation, replacement, force_placement)
    minetest.chat_send_all("combined urban tile " .. tostring(v))

    --   if (mc_worldManager == nil) then
    -- minetest.place_schematic_on_vmanip(vm, pos1, UBCMap.path .. "/schems/ubc_unbreakable_map_barrier_" .. tostring(v) .. ".mts", rotation, replacement, force_placement)
    --minetest.chat_send_all("combined unbreakable map barrier tile " .. tostring(v))
    --  end


    -- The boolean parameter is whether or not we should update the lighting
    -- It causes a complete remesh; so I want to save this until the player loads into the area...
    vm:write_to_map(false)
end

function UBCMap:calculateLighting(pos1, pos2)

    local function emerge_callback(blockpos, action,
                                   num_calls_remaining, context)

        -- On first call, record number of blocks
        if not context.total_blocks then
            context.total_blocks = num_calls_remaining + 1
            context.loaded_blocks = 0
        end

        -- Increment number of blocks loaded
        context.loaded_blocks = context.loaded_blocks + 1

        if context.total_blocks == context.loaded_blocks then
            minetest.chat_send_all("Finished calculating light for the UBC map!")
        end

        local pos1 = { x = blockpos.x * 16, y = blockpos.y * 16, z = blockpos.z * 16 }
        local pos2 = { x = blockpos.x * 16 + 15, y = blockpos.y * 16 + 15, z = blockpos.z * 16 + 15 }

        minetest.fix_light(pos1, pos2)

        Debug.log("Finished calculating light for chunk: " .. context.loaded_blocks .. "/" .. context.total_blocks)
    end

    local context = {} -- persist data between callback calls
    context.counter = 0
    minetest.emerge_area(pos1, pos2, emerge_callback, context)
end

function UBCMap.place(startPosition, emergeLighting)
    -- GC before we start placing the map
    collectgarbage("collect")

    if (startPosition == nil) then
        startPosition = { x = 0, y = -3, z = 0 }
    else
        startPosition = { x = startPosition.x, y = startPosition.y, z = startPosition.z }
    end

    if (emergeLighting == nil) then
        emergeLighting = true
    end

    UBCMap.storage:set_string("finishedGenerating", "false")
    UBCMap.storage:set_string("placementPos", minetest.serialize(startPosition))

    local coords = {}
    for xx = 0, 2500, 500 do
        for zz = 1, 7 do
            local z = 3500 - (zz * 500)
            table.insert(coords, { xx + startPosition.x, z + startPosition.z })
        end
    end

    -- If we crash during world generation, we'll try again.
    local startingValue = UBCMap.storage:get_int("placementProgress")
    if (startingValue == nil or startingValue == 0) then
        startingValue = 1
        minetest.chat_send_all("Placing UBC Map")
    else
        minetest.chat_send_all("Previous minetest instance crashed while placing UBC Map... Trying again from position: " .. startingValue)
    end

    if (startingValue <= 28) then
        for v = startingValue, 28 do
            --for _, v in pairs(tiles) do
            local coord = coords[v]
            -- y must always be -3 because the schematic pos starts here
            -- this maintains the true elevations across the map
            -- place terrain first


            local startPos = { x = coord[1], y = startPosition.y, z = coord[2] }
            local endPos = { x = startPos.x + 500, y = startPos.y + 500, z = startPos.z + 500 }

            UBCMap:placeSchematic(startPos, endPos, v, "0", nil, false)
            minetest.chat_send_all("Placed combined tile: " .. tostring(v) .. " in world.")

            UBCMap.storage:set_int("placementProgress", v)

            local completion = tonumber(string.format("%.2f", (v / 28) * 100))

            Debug.log(completion .. " % done!")
            minetest.chat_send_all(completion .. " % done!")

            collectgarbage("collect")
        end

        -- Collect garbage again;
        collectgarbage("collect")
    end

    UBCMap.storage:set_string("finishedGenerating", "true")
    UBCMap.storage:set_string("placementPos", "")
    if (emergeLighting) then
        Debug.log("Emerging lighting")
        local startPos = { x = startPosition.x, y = startPosition.y, z = startPosition.z }
        local endPos = { x = startPosition.x + 2500, y = startPosition.y + 250, z = startPosition.z + 3500 }

        UBCMap:calculateLighting(startPos, endPos)
    end

    Debug.log("Finished placing UBC Map!")
    minetest.chat_send_all("Finished generating!")

end

dofile(UBCMap.path .. "/integration.lua")


-- This is a bit hacky, but we can only start placing the ubc map at runtime
-- minetest.register_on_mods_loaded(function()) doesn't work
-- I don't want to use server step as it happens too often (and will stall players to the loading screen in singleplayer);
local triggered = false
minetest.register_on_joinplayer(function(player, last_logon)
    if (triggered == false) then
        triggered = true
        local status = UBCMap.storage:get_string("finishedGenerating")
        if (status == "false") then

            local pos = minetest.deserialize(UBCMap.storage:get_string("placementPos"))
            UBCMap.place(pos)
        end
    end
end)




