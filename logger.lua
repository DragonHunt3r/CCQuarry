local debugging = false

---
-- If debug messages are printed.
-- @return true if debug messages are printed.
function isDebug()
	return debugging
end

---
-- Enable or disable debug messages.
-- @param enabled If debug messages are printed.
function setDebug(enabled)
	debugging = enabled
end

---
-- Clear the terminal and write a header.
-- @param header Header to write or nil for no header.
function clearTerminal(header)
	term.clear()
	term.setCursorPos(1, 1)

	-- If a header is specified
	if header ~= nil then
		log(header)
	end
end


---
-- Print a message.
-- @param text Message to print.
function log(text)
	-- Preconditions
	if text == nil then
		error("No text specified")
	end

	print(text)
end

---
-- Print a message with debug level.
-- @param text Message to print.
function debug(text)
	-- Preconditions
	if text == nil then
		error("No text specified")
	end

	-- If debug is enabled
	if isDebug() then
		log("[DEBUG] " .. text)
	end
end

---
-- Print a message with info level.
-- @param text Message to print.
function info(text)
	-- Preconditions
	if text == nil then
		error("No text specified")
	end

	log("[INFO] " .. text)
end


---
-- Print a message with error level.
-- @param text Message to print.
function error(text)
	-- Preconditions
	if text == nil then
		error("No text specified")
	end

	log("[ERROR] " .. text)
end