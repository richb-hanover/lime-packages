#!/usr/bin/lua

local config = require("lime.config")

tl_wdr3600 = {}

function tl_wdr3600.clean()
	if not tl_wdr3600.board_match() then return end

	config.init_batch()
	for _, section in pairs({"radio0", "radio1", "eth0", "eth0.1", "eth0.2"}) do
		if config.autogenerable(section) then
			config.delete(section)
		end
	end
	config.end_batch()
end

function tl_wdr3600.detect_hardware()
	if not tl_wdr3600.board_match() then return end

	config.init_batch()

	for _, radioName in pairs({"radio0", "radio1"}) do
		if config.autogenerable(radioName) then
			config.set(radioName, "wifi")
			config.set(radioName, "autogenerated", "true")

			for option_name, value in pairs(config.get_all("wifi")) do
				if (option_name:sub(1,1) ~= ".") then
					if ( type(value) ~= "table" ) then value = tostring(value) end
					config.set(radioName, option_name, value)
				end
			end

			if (radioName == "radio0") then
				config.set(radioName, "modes", {"ap"})
			elseif (radioName == "radio1") then
				config.set(radioName, "modes", {"ap", "adhoc"})
			end
		end
	end

	if config.autogenerable("eth0") then
		config.set("eth0", "net")
		config.set("eth0", "autogenerated", "true")
		config.set("eth0", "protocols", {"switch"})
		config.set("eth0", "linux_name", "eth0")
	end

	if config.autogenerable("eth0vlan1") then
		protos = {}
		for _, proto in pairs(config.get("network", "protocols")) do
			if (proto ~= "wan") then table.insert(protos, proto) end
		end
		config.set("eth0vlan1", "net")
		config.set("eth0vlan1", "autogenerated", "true")
		config.set("eth0vlan1", "protocols", protos)
		config.set("eth0vlan1", "linux_name", "eth0.1")
	end

	if config.autogenerable("eth0vlan2") then
		protos = {}
		for _, proto in pairs(config.get("network", "protocols")) do
			if (proto ~= "lan") then table.insert(protos, proto) end
		end
		config.set("eth0vlan2", "net")
		config.set("eth0vlan2", "autogenerated", "true")
		config.set("eth0vlan2", "protocols", protos)
		config.set("eth0vlan2", "linux_name", "eth0.2")
	end

	config.end_batch()
end

function tl_wdr3600.board_match()
	local f = io.open("/proc/cpuinfo", "r")
	local b = f:read("*all")
	f:close()
	return (b:find("TP%-LINK") and ( b:find("TL%-WDR3600") or b:find("TL%-WDR4300") or b:find("TL%-WDR4310")))
end

return tl_wdr3600
