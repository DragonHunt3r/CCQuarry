-- Maximum amount of movement tries
local MAX_TRIES = 100

-- Retry delay in seconds
local RETRY_DELAY = 0.5

-- State
local xCoord = 0 -- Current X
local yCoord = 0 -- Current Y
local zCoord = 0 -- Current Z
local heading = 0 -- Current heading

---
-- Get the relative X coordinate.
function getX()
	return xCoord
end

---
-- Get the relative Y coordinate.
function getY()
	return yCoord
end

---
-- Get the relative Z coordinate.
function getZ()
	return zCoord
end

---
-- Get the relative heading.
function getHeading()
	return heading
end

---
-- Turn left.
function turnLeft()
	turtle.turnLeft()

	heading = heading - 1
	if heading == -1 then
		heading = 3
	end
	logger.debug("Turning left. New heading: " .. heading .. ".")

	save()
end

---
-- Turn right.
function turnRight()
	turtle.turnRight()

	heading = heading + 1
	if heading == 4 then
		heading = 0
	end
	logger.debug("Turning right. New heading: " .. heading .. ".")

	save()
end

---
-- Turn around.
function turnAround()
	turnRight()
	turnRight()
end

---
-- Turn the turtle to the given heading.
-- @param orientation The orientation.
function turn(orientation)
	-- Preconditions
	if orientation == nil or orientation < 0 or orientation > 3 then
		logger.error("Illegal orientation: '" .. orientation .. "'.")
		return
	end

	logger.debug("Turning to " .. orientation .. "...")

	-- Correct heading
	if orientation == heading then
		return
	end

	-- Get the heading from a rotation left
	local leftHeading = heading - 1
	if leftHeading == -1 then
		leftHeading = 3
	end

	if orientation == leftHeading then
		turnLeft()
		return
	end

	-- Turn right until right heading
	while orientation ~= heading do
		turnRight()
	end
end

---
-- Move the turtle forward.
-- Note that the turtle will attempt to dig or kill if it cannot move forward.
-- @param blocks Amount of blocks to move forward by.
-- @return true if the turtle could successfully move forward.
function moveForward(blocks)
	-- Preconditions
	if blocks == nil or blocks < 0 then
		logger.error("Illegal block amount: '" .. blocks .. "'.")
		return false
	end

	logger.debug("Moving " .. blocks .. " blocks forward...")

	-- For amount of blocks to move
	for i = 1, blocks do

		-- Try to go forward
		local tries = -1
		while true do
			-- If we can move update position and break
			if turtle.forward() then
				if heading == 0 then
					xCoord = xCoord + 1
				elseif heading == 1 then
					zCoord = zCoord + 1
				elseif heading == 2 then
					xCoord = xCoord - 1
				elseif heading == 3 then
					zCoord = zCoord - 1
				end
				logger.debug("Moving forward. New coordinates: (" .. xCoord .. ", " .. yCoord .. ", " .. zCoord .. ").")

				save()
				break

			-- If we cannot move try to dig block or kill entity
			else
				turtle.dig()
				turtle.attack()

				-- Increment tries
				tries = tries + 1

				logger.debug("Could not move forward (try " .. tries .. ").")

				-- Don't sleep on first try because we try moving before first dig/attack
				if tries ~= 0 then
					sleep(RETRY_DELAY)
				end

				-- Failure
				if tries > MAX_TRIES then
					logger.error("Can't move forward.")
					return false
				end
			end
		end
	end

	return true
end

---
-- Move the turtle forward.
-- Note that the turtle will attempt to dig or kill if it cannot move forward.
-- @param blocks Amount of blocks to move forward by.
-- @return true if the turtle could successfully move forward.
function moveBack(blocks)
	-- Preconditions
	if blocks == nil or blocks < 0 then
		logger.error("Illegal block amount: '" .. blocks .. "'.")
		return false
	end

	logger.debug("Moving " .. blocks .. " blocks back...")

	-- For amount of blocks to move
	for i = 1, blocks do

		-- Try to go forward
		local tries = 0
		while true do
			-- If we can move update position and break
			if turtle.back() then
				if heading == 0 then
					xCoord = xCoord - 1
				elseif heading == 1 then
					zCoord = zCoord - 1
				elseif heading == 2 then
					xCoord = xCoord + 1
				elseif heading == 3 then
					zCoord = zCoord + 1
				end
				logger.debug("Moving back. New coordinates: (" .. xCoord .. ", " .. yCoord .. ", " .. zCoord .. ").")

				save()
				break

			-- If we cannot move we can only retry because we are moving backwards
			else

				-- Increment tries
				tries = tries + 1

				logger.debug("Could not move back (try " .. tries .. ").")

				sleep(RETRY_DELAY)

				-- Failure
				if tries > MAX_TRIES then
					logger.error("Can't move forward.")
					return false
				end
			end
		end
	end

	return true
end

---
-- Move the turtle up.
-- Note that the turtle will attempt to dig or kill if it cannot move up.
-- @param blocks Amount of blocks to move up by.
-- @return true if the turtle could successfully move up.
function moveUp(blocks)
	-- Preconditions
	if blocks == nil or blocks < 0 then
		logger.error("Illegal block amount: '" .. blocks .. "'.")
		return false
	end

	logger.debug("Moving " .. blocks .. " blocks up...")

	-- For amount of blocks to move
	for i = 1, blocks do

		-- Try to go up
		local tries = -1
		while true do
			-- If we can move update position and break
			if turtle.up() then
				yCoord = yCoord + 1
				logger.debug("Moving up. New coordinates: (" .. xCoord .. ", " .. yCoord .. ", " .. zCoord .. ").")

				save()
				break

			-- If we cannot move try to dig block or kill entity
			else
				turtle.digUp()
				turtle.attackUp()

				-- Increment tries
				tries = tries + 1

				logger.debug("Could not move up (try " .. tries .. ").")

				-- Don't sleep on first try because we try moving before first dig/attack
				if tries ~= 0 then
					sleep(RETRY_DELAY)
				end

				-- Failure
				if tries > MAX_TRIES then
					logger.error("Can't move up.")
					return false
				end
			end
		end
	end

	return true
end

---
-- Move the turtle down.
-- Note that the turtle will attempt to dig or kill if it cannot move down.
-- @param blocks Amount of blocks to move down by.
-- @return true if the turtle could successfully move down.
function moveDown(blocks)
	-- Preconditions
	if blocks == nil or blocks < 0 then
		logger.error("Illegal block amount: '" .. blocks .. "'.")
		return false
	end

	logger.debug("Moving " .. blocks .. " blocks down...")

	-- For amount of blocks to move
	for i = 1, blocks do

		-- Try to go up
		local tries = -1
		while true do
			-- If we can move update position and break
			if turtle.down() then
				yCoord = yCoord - 1
				logger.debug("Moving down. New coordinates: (" .. xCoord .. ", " .. yCoord .. ", " .. zCoord .. ").")

				save()
				break

			-- If we cannot move try to dig block or kill entity
			else
				turtle.digDown()
				turtle.attackDown()

				-- Increment tries
				tries = tries + 1

				logger.debug("Could not move up (try " .. tries .. ").")

				-- Don't sleep on first try because we try moving before first dig/attack
				if tries ~= 0 then
					sleep(RETRY_DELAY)
				end

				-- Failure
				if tries > MAX_TRIES then
					logger.error("Can't move down.")
					return false
				end
			end
		end
	end

	return true
end

---
-- Move to a given location.
-- Note that this changes the turtle's heading.
-- @param x Target X coordinate.
-- @param y Target Y coordinate.
-- @param z Target Z coordinate.
-- @return true if the target location could be reached successfully, else false
function goTo(x, y, z)
	logger.debug("Moving to (" .. x .. ", " .. y .. ", " .. z .. ")...")

	-- Change X position
	local dx = 0
	if x > xCoord then
		turn(0) -- Positive X
		dx = x - xCoord
	elseif x < xCoord then
		turn(2) -- Negative X
		dx = xCoord - x
	end
	if not moveForward(dx) then
		return false
	end

	-- Change Y position
	local dy = 0
	if y > yCoord then
		if not moveUp(y - yCoord) then
			return false
		end
	elseif y < yCoord then
		if not moveDown(yCoord - y) then
			return false
		end
	end

	-- Change Z position
	local dz = 0
	if z > zCoord then
		turn(1) -- Positive Z
		dz = z - zCoord
	elseif z < zCoord then
		turn(3) -- Negative Z
		dz = zCoord - z
	end
	if not moveForward(dz) then
		return false
	end

	return true
end

---
-- Delete saved state and reset coordinates.
function reset()
	logger.debug("Resetting state...")
	if fs.exists("./ControlData/state") then
		logger.debug("Deleting saved state...")
		fs.delete("./ControlData/state")
	end
	xCoord = 0
	yCoord = 0
	zCoord = 0
	heading = 0
end

---
-- Save coordinates to the given file.
-- @param file File to save to.
function save()
	logger.debug("Saving current state...")
	local file = fs.open("./ControlData/state", "w")
	file.writeLine(xCoord)
	file.writeLine(yCoord)
	file.writeLine(zCoord)
	file.writeLine(heading)
	file.close()
end

---
-- Application entry point.
-- We load last state if available (turtle coordinates).
-- We assume that the state file is formatted correctly.
function run()
	-- Make the data directory if it does not exist
	if not fs.exists("./ControlData") then
		logger.debug("Creating ControlData directory...")
		fs.makeDir("./ControlData")
	end

	-- If state exists
	if fs.exists("./ControlData/state") then
		logger.debug("Loading saved state...")
		local file = fs.open("./ControlData/state", "r")
		xCoord = tonumber(file.readLine())
		yCoord = tonumber(file.readLine())
		zCoord = tonumber(file.readLine())
		heading = tonumber(file.readLine())
		file.close()
	end
end

-- Run the application
run()