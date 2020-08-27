---
-- Get the total item count in the turtle's inventory.
-- @return the amount of items.
function getItemCount()
	logger.debug("Getting item count...")
	local count = 0
	for i = 1, 16 do
		local items = turtle.getItemCount(i)
		logger.debug("Found " .. items .. " items in slot " .. i .. ".")
		count = count + items
	end
	logger.debug("Found " .. count .. " items.")
	return count
end

---
-- Check if the turtle's inventory is full.
-- @return false if at least one slot has 0 items in it.
function isInventoryFull()
	logger.debug("Finding empty slot...")
  	for i = 1, 16 do
		if turtle.getItemCount(i) == 0 then
			logger.debug("Found empty slot: " .. i .. ".")
			return false
		end
	end
	logger.debug("Found no empty slot.")
	return true
end

---
-- Refuel the turtle using items from the turtle's inventory.
-- The turtle's cursor position is returned to its previous slot.
function refuel()
	logger.debug("Refueling from turtle inventory...")
	local slot = turtle.getSelectedSlot()
	for i = 1, 16 do
		turtle.select(i)
		turtle.refuel()
	end
	turtle.select(slot)
end

---
-- Grab as many items as we can from in front of the turtle.
function suckForward()
	local before = getItemCount()
	repeat
		before = getItemCount()
		turtle.suck()
	until before == getItemCount()
end

---
-- Grab as many items as we can from above the turtle.
function suckUp()
	local before = getItemCount()
	repeat
		before = getItemCount()
		turtle.suckUp()
	until before == getItemCount()
end

---
-- Grab as many items as we can from below the turtle.
function suckDown()
	local before = getItemCount()
	repeat
		before = getItemCount()
		turtle.suckDown()
	until before == getItemCount()
end

---
-- Try to drop all items in front of the turtle.
-- @return true if all items could be dropped successfully.
function dropAll()
	logger.debug("Dropping items...")
	local slot = turtle.getSelectedSlot()
	local success = true
	for i = 1, 16 do
		turtle.select(i)
		if not turtle.drop() and turtle.getItemCount() ~= 0 then
			logger.debug("Could not drop item in slot " .. i .. ".")
			success = false
		end
    end
	turtle.select(slot)
	return success
end

---
-- Try to drop all items above the turtle.
-- @return true if all items could be dropped successfully
function dropAllUp()
	logger.debug("Dropping items above turtle...")
	local slot = turtle.getSelectedSlot()
	local success = true
	for i = 1, 16 do
		turtle.select(i)
		if not turtle.dropUp() and turtle.getItemCount() ~= 0 then
			logger.debug("Could not drop item in slot " .. i .. ".")
			success = false
		end
    end
	turtle.select(slot)
	return success
end

---
-- Try to drop all items below the turtle.
-- @return true if all items could be dropped successfully
function dropAllDown()
	logger.debug("Dropping items below turtle...")
	local slot = turtle.getSelectedSlot()
	local success = true
	for i = 1, 16 do
		turtle.select(i)
		if not turtle.dropDown() and turtle.getItemCount() ~= 0 then
			logger.debug("Could not drop item in slot " .. i .. ".")
			success = false
		end
    end
	turtle.select(slot)
	return success
end