minetest.register_chatcommand("mosaic_mts", {
	description = "Mosaic map schematics together for UBC campus",
	privs = {interact=true},
	func = function(name, param)
		-- manually define tile numbers because searching files on disk with lua is stupid
		local tiles = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28}
		local coords = {}
		for xx=0,2500,500 do 
			for yy=1,7 do
				y = 3500-(yy*500)
				table.insert(coords, {xx,y})
			end
		end
		for _,v in pairs(tiles) do
			coord = coords[v]
			-- y must always be -3 because the schematic pos starts here
			-- this maintains the true elevations across the map
			-- place terrain first
			minetest.place_schematic({ x = coord[1], y = -3, z = coord[2] }, minetest.get_modpath("mosaic_mts").."/schems/ubc_blocks_"..tostring(v)..".mts", "0", nil, false)
			minetest.chat_send_all("Placed terrain tile "..tostring(v))
			-- place trees second
			minetest.place_schematic({ x = coord[1], y = -3, z = coord[2] }, minetest.get_modpath("mosaic_mts").."/schems/ubc_trees_"..tostring(v)..".mts", "0", nil, false)
			minetest.chat_send_all("Placed trees tile "..tostring(v))
			-- place urban third
			minetest.place_schematic({ x = coord[1], y = -3, z = coord[2] }, minetest.get_modpath("mosaic_mts").."/schems/ubc_urban_"..tostring(v)..".mts", "0", nil, false)
			minetest.chat_send_all("Placed urban tile "..tostring(v))
			-- place unbreakable map barrier last
			minetest.place_schematic({ x = coord[1], y = -3, z = coord[2] }, minetest.get_modpath("mosaic_mts").."/schems/ubc_unbreakable_map_barrier_"..tostring(v)..".mts", "0", nil, false)
			minetest.chat_send_all("Placed unbreakable map barrier tile "..tostring(v))
		end
	end
})