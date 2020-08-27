-- Maximum amount of movement tries
local MAX_TRIES = 100

-- Retry delay in seconds
local RETRY_DELAY = 0.5

-- Minimum fuel level to operate
local MIN_FUEL = 400

-- Version header
local version = "Turtle Quarry 1.0 by SteelPhoenix"

-- Turtle label
local label = "Quarry Turtle"

-- Settings
local length = nil -- Quarry length
local width = nil -- Quarry width
local depth = nil -- Quarry depth

-- State
local layers = nil -- Layers mined

---
-- Read user input as number.
-- The question is retried until a valid value is entered.
-- Note that floating point numbers are allowed and don't break the application.
-- @param text Question to ask.
-- @return the number.
function getUserInput(text)
	-- Preconditions
	if text == nil then
		logger.error("Illegal text: '" .. text .. "'.")
		return
	end

	logger.debug("Getting user input for '" .. text .. "'...")

	local input = nil
	local var = nil
	local message = nil

	-- Repeat until a valid value is entered
	while true do
		logger.clearTerminal(version)

		-- If an error message is available
		if message ~= nil then
			logger.log(message)
			message = nil
		end

		logger.log(text)

		-- Read input
		input = read()
		var = tonumber(input)

		logger.debug("Read '" .. input .. "', as number: '" .. var .. "'.")

		-- Not a number
		if var == nil then
			message = "'" .. input .. "' is not a number"

		-- Below lower bound
		elseif var <= 0 then
			message = "Number must be positive"

		-- Valid value so we break the loop
		else
			logger.debug("Value is valid.")
			break
		end
	end

	return var
end

---
-- Save quarry state.
-- This includes current co-ordinates, direction and amount of layers mined.
function save()
	logger.debug("Saving current state...")
	local file = fs.open("./QuarryData/state", "w")
	file.writeLine(layers)
	file.close()
end

---
-- Load existing settings and state if available or request them from the user.
function load()
	-- If no settings exist fetch settings
	if not fs.exists("./QuarryData/settings") then
		control.reset()
		setup()
		return
	end

	logger.debug("Loading saved state...")

	-- Load settings
	local file = fs.open("./QuarryData/settings", "r")
	length = tonumber(file.readLine())
	width = tonumber(file.readLine())
	depth = tonumber(file.readLine())
	file.close()

	-- Load state
	-- We assume a state file is present if a settings file is
	local file = fs.open("./QuarryData/state", "r")
	layers = tonumber(file.readLine())
	file.close()
end

---
-- Get and save quarry settings.
function setup()
	-- Length
	length = getUserInput("What is the dig length?")

	-- Width
	width = getUserInput("What is the dig width?")

	-- Depth
	depth = getUserInput("What is the dig depth?")

	-- Write settings to file
	local file = fs.open("./QuarryData/settings", "w")
	file.writeLine(length)
	file.writeLine(width)
	file.writeLine(depth)
	file.close()

	layers = 0
	save()
end

---
-- If the turtle's inventory is full or fuel levels are getting low we go home and drop off items or refuel, then go back.
-- @return true if the action was successful.
function checkState()
	-- If inventory is full or fuel is too low
	if inventory.isInventoryFull() or turtle.getFuelLevel() < MIN_FUEL then
		logger.debug("Inventory is full or fuel is too low.")

		-- Save current coordinates
		local currentX = control.getX()
		local currentY = control.getY()
		local currentZ = control.getZ()
		local currentHeading = control.getHeading()

		-- Drop items and refuel
		if not goHome() then
			return false
		end

		-- Go back to old location
		if not control.goTo(currentX, currentY, currentZ) then
			return false
		end
		control.turn(currentHeading)
	end
	return true
end

---
-- Go to start position and drop items and refuel.
-- @return true if the action was successful.
function goHome()
	-- Go home
	if not control.goTo(0, 0, 0) then
		return false
	end

	-- Drop items
	control.turn(2)
	local tries = 0
	while true do
		tries = tries + 1
		if inventory.dropAll() then
			break
		else
			sleep(RETRY_DELAY)
			if tries > MAX_TRIES then
				printError("Can't drop items")
				return false
			end
		end
	end

	-- Refuel
	local tries = 0
	while true do
		tries = tries + 1
		repeat
			turtle.refuel()
		until not turtle.suckUp()
		if turtle.getFuelLevel() < MIN_FUEL then
			sleep(RETRY_DELAY)
			if tries > MAX_TRIES then
				printError("Can't refuel enough")
				return false
			end
		else
			return true
		end
	end
end

---
-- Dig layer below the turtle.
-- @return true if the action was successful.
function digLayer()
	-- Go down
	inventory.suckDown()
	if not checkState() or not control.moveDown(1) or not checkState() then
		return false
	end
	control.turn(0)

	-- Dig lines
	for i = 1, width do

		if not digLine() then
			return false
		end

		-- Not last line
		if i ~= width then
			if i % 2 == 0 then
				control.turnLeft()
			else
				control.turnRight()
			end

			inventory.suckForward()
			if not checkState() or not control.moveForward(1) or not checkState() then
				return false
			end

			if i % 2 == 0 then
				control.turnLeft()
			else
				control.turnRight()
			end
		end
	end

	-- Go back to (0, y, 0) and face 0
	-- This is not ideal but it works
	if not control.goTo(0, control.getY(), 0) then
		return false
	end
	control.turn(0)
	return true
end

---
-- Dig line in front of the turtle.
-- When this method is called we assume the turtle is facing the right direction and is in the first spot of the line.
-- This means we mine (length - 1) blocks in front of the turtle.
-- @return true if the action was successful.
function digLine()
	for i = 2, length do
		inventory.suckForward()
		if not checkState() or not control.moveForward(1) or not checkState() then
			return false
		end
	end
	return true
end

---
-- Application entry point.
function run()
	-- Try load the libraries
	if not os.loadAPI("logger") or not os.loadAPI("inventory") or not os.loadAPI("control") then
		-- If the logger module is not found we still want to be able to print
		print("[ERROR] Could not load required libraries.")
		return
	end

	-- Make the data directory if it does not exist
	if not fs.exists("./QuarryData") then
		logger.debug("Making QuarryData directory...")
		fs.makeDir("./QuarryData")
	end

	-- Make boot file if it does not exist
	-- We assume the program is called "quarry"
	if not fs.exists("startup") then
		logger.debug("Creating boot file...")
		local file = fs.open("startup", "w")
		file.writeLine("shell.run(\"quarry\")")
		file.close()
	end

	-- Load quarry data
	load()
	os.setComputerLabel(label)

	logger.clearTerminal(version)

	-- Try to go home
	if not goHome() then
		return
	end

	-- Try to go to the correct layer
	if not control.goTo(0, 0 - layers, 0) then
		return
	end
	control.turn(0)

	-- Quarry
	while depth > layers do
		if not digLayer() then
			return
		end
		layers = layers + 1
		logger.debug("Mined " .. layers .. "layers.")
		save()
	end

	-- Quarry is finished

	-- We go back to home location and drop last blocks
	if not goHome() then
		return
	end
	control.turn(0)

	-- We reset the turtle coordinates so if the turtle is moved after the quarry operation it will create new coordinates
	control.reset()

	-- Delete quarry settings and boot file so it will not think there is an active job
	logger.debug("Deleting quarry state and boot file...")
	fs.delete("./QuarryData/settings")
	fs.delete("startup")

	--
	logger.info("Quarry completed")
end

-- Run the application
run()