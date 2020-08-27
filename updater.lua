-- Github repository url
-- We assume this does not change
local URL = "https://raw.githubusercontent.com/DragonHunt3r/CCQuarry/master/"

---
-- Download a program from the given URL.
-- Note that this overwrites existing files.
-- @param url URL to download from.
-- @param name Name for the program.
-- @return true if the program was downloaded successfully.
function download(url, name)
	-- Preconditions
	if url == nil then
		print("[ERROR] Illegal url: '" .. url .. "'.")
		return false
	end
	if name == nil then
		print("[ERROR] Illegal name: '" .. name .. "'.")
		return false
	end

	print("[INFO] Downloading '" .. name .. "'.")
	local response = http.get(url)

	-- Failure
	if response == nil then
		print("[ERROR] Failed to send GET request to '" .. url .. "'.")
		return false
	end

	-- Write to file
	local file = fs.open(name, "w")
	file.write(response.readAll())
	file.close()

	print("[INFO] Successfully downloaded '" .. name .. "'.")
	return true
end

---
-- Application entry point
function run()
	if download(URL .. "control.lua", "control") and download(URL .. "inventory.lua", "inventory") and download(URL .. "logger.lua", "logger") and download(URL .. "quarry.lua", "quarry") then
		print("[INFO] Downloaded all modules successfully.")
		print("[INFO] Type 'quarry' to get started.")
	end	
end

-- Run the application
run()