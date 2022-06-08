UBCMap = { path = minetest.get_modpath("ubc_campus_minetest_map"), storage = minetest.get_mod_storage() }

function UBCMap:placeSchematic(pos1, pos2, schematic, rotation, replacement, force_placement)

    -- Read data into LVM
    local vm = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map(pos1, pos2)
    local a = VoxelArea:new {
        MinEdge = emin,
        MaxEdge = emax
    }

    minetest.place_schematic_on_vmanip(vm, pos1, schematic, rotation, replacement, force_placement)
    vm:write_to_map(true)
end

function UBCMap.place(startPosition)
    if (startPosition == nil) then
        startPosition = { x = 0, y = -3, z = 0 }
    else
        startPosition = { x = startPosition.x, y = startPosition.y, z = startPosition.z }
    end
    -- manually define tile numbers because searching files on disk with lua is stupid
    local tiles = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28 }

    local coords = {}
    for xx = 0, 2500, 500 do
        for yy = 1, 7 do
            y = 3500 - (yy * 500) + startPosition.y
            table.insert(coords, { xx + startPosition.x, y + startPosition.z })
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

    for v = startingValue, 28 do
        --for _, v in pairs(tiles) do
        coord = coords[v]
        -- y must always be -3 because the schematic pos starts here
        -- this maintains the true elevations across the map
        -- place terrain first


        local startPos = { x = coord[1], y = startPosition.y, z = coord[2] }
        local endPos = { x = startPos.x + 500, y = startPos.y + 500, z = startPos.z + 500 }

        UBCMap:placeSchematic(startPos, endPos, UBCMap.path .. "/schems/ubc_blocks_" .. tostring(v) .. ".mts", "0", nil, false)
        minetest.chat_send_all("Placed terrain tile " .. tostring(v))


        -- place trees second
        UBCMap:placeSchematic(startPos, endPos, UBCMap.path .. "/schems/ubc_trees_" .. tostring(v) .. ".mts", "0", nil, false)
        minetest.chat_send_all("Placed trees tile " .. tostring(v))

        -- place urban third
        UBCMap:placeSchematic(startPos, endPos, UBCMap.path .. "/schems/ubc_urban_" .. tostring(v) .. ".mts", "0", nil, false)
        minetest.chat_send_all("Placed urban tile " .. tostring(v))

        -- place unbreakable map barrier last
        if (mc_worldManager == nil) then
            UBCMap:placeSchematic(startPos, endPos, UBCMap.path .. "/schems/ubc_unbreakable_map_barrier_" .. tostring(v) .. ".mts", "0", nil, false)
            minetest.chat_send_all("Placed unbreakable map barrier tile " .. tostring(v))
        end

        UBCMap.storage:set_int("placementProgress", v)

        local completion = tonumber(string.format("%.2f", (v / 28) * 100))

        minetest.chat_send_all(completion .. " % done!")
    end

    UBCMap.storage:set_string("finishedGenerating", "true")
end

dofile(UBCMap.path .. "/integration.lua")