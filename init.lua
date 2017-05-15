--[[
                    .__       .___        __
__  _  _____________|  |    __| _/_______/  |_  ________________     ____   ____
\ \/ \/ /  _ \_  __ \  |   / __ |/  ___/\   __\/  _ \_  __ \__  \   / ___\_/ __ \
 \     (  <_> )  | \/  |__/ /_/ |\___ \  |  | (  <_> )  | \// __ \_/ /_/  >  ___/
  \/\_/ \____/|__|  |____/\____ /____  > |__|  \____/|__|  (____  /\___  / \___  >
                               \/    \/                         \//_____/      \/
--]]

local load_time_start = os.clock()
local modname = minetest.get_current_modname()


worldstorage = {}

local modstorage = core.get_mod_storage()

local activated = false
function worldstorage.is_activated()
	return activated
end

local activate_functions = {}
function worldstorage.register_on_activate(f)
	activate_functions[#activate_functions+1] = f
end

local worldname
local worldname_length
local function set_worldname(name)
	worldname = name.."/"
	worldname_length = #worldname
	for i = 1, #activate_functions do
		activate_functions[i]()
	end
	activated = true
	return "Worldname set to "..name.."."
end

minetest.register_on_connect(function()
	minetest.show_formspec("worldstorage_worldname",
			"field[worldname;Enter the current worldname:;]")
end)

minetest.register_on_formspec_input(function(formname, fields)
	if formname ~= "worldstorage_worldname" then
		return
	end
	if not fields.worldname then
		minetest.display_chat_message("You can still set the worldname with "..
				"the chatcommand.")
		return true
	end
	local msg = set_worldname(fields.worldname)
	minetest.display_chat_message(msg)
	return true
end)

minetest.register_chatcommand("worldname", {
    params = "set <name> / get",
    description = "",
    func = function(param)
		if param == "get" then
			if not worldstorage.is_activated() then
				return false, "No worldname set."
			end
			return true, worldstorage.get_current_worldname()
		elseif param:sub(1, 4) == "set " then
			param = param:sub(5)
		end
		return true, set_worldname(param)
    end,
})

worldstorage.register_on_activate(function()
	function worldstorage.get_current_worldname()
		return worldname:sub(1, -2)
	end

	function worldstorage.get_int(key)
		return modstorage:get_int(worldname..key)
	end

	function worldstorage.set_int(key, value)
		modstorage:set_int(worldname..key)
	end

	function worldstorage.get_float(key)
		return modstorage:get_float(worldname..key)
	end

	function worldstorage.set_float(key, value)
		modstorage:set_float(worldname..key)
	end

	function worldstorage.get_string(key)
		return modstorage:get_string(worldname..key)
	end

	function worldstorage.set_string(key, value)
		modstorage:set_string(worldname..key)
	end

	function worldstorage.to_table()
		local t = modstorage:to_table()
		for k,_ in pairs(t) do
			if k:sub(worldname_length) ~= worldname then
				t[k] = nil
			end
		end
		return t
	end

	function worldstorage.from_table(values)
		local t = modstorage:to_table()
		for k,_ in pairs(t) do
			if k:sub(worldname_length) == worldname then
				t[k] = nil
			end
		end
		for k, v in pairs(values) do
			t[worldname..k] = v
		end
		modstorage:from_table(t)
	end
end)


local time = math.floor(tonumber(os.clock()-load_time_start)*100+0.5)/100
local msg = "["..modname.."] loaded after ca. "..time
if time > 0.05 then
	print(msg)
else
	minetest.log("info", msg)
end
