local vehicleBlipRoot = createElement("vehicleBlipRoot", "vehicleBlipRoot")

--This function creates a blip for all currently streamed-in vehicles when the resource starts.
local function resourceStart()
	for _, vehicle in ipairs(getElementsByType("vehicle"), root, true) do
		if vehicle ~= getPedOccupiedVehicle(localPlayer) then
			local blip = createBlipAttachedTo(vehicle, 0, 1, 150, 150, 150, 255, -10, 300)
			setElementParent(blip, vehicleBlipRoot)
		end
	end
end
addEventHandler("onClientResourceStart", root, resourceStart)

--This function destroys a vehicle's blip when it streams out.
local function streamOut()
	for _, blip in ipairs(getElementChildren(vehicleBlipRoot)) do
		if getElementAttachedTo(blip) == source then
			destroyElement(blip)
		end
	end
	removeEventHandler("onClientElementStreamOut", source, streamOut)
	removeEventHandler("onClientElementDestroy", source, streamOut)
end

--This function creates a blip when a vehicle streams in.
local function streamIn()
	if getElementType(source) ~= "vehicle" then
		return
	end
	
	--Check if the vehicle already has a blip.
	for _, blip in ipairs(getElementChildren(vehicleBlipRoot)) do
		if getElementAttachedTo(blip) == source then
			return
		end
	end
	
	local blip = createBlipAttachedTo(source, 0, 1, 150, 150, 150, 255, -10, 300)
	setElementParent(blip, vehicleBlipRoot)
	addEventHandler("onClientElementStreamOut", source, streamOut)
	addEventHandler("onClientElementDestroy", source, streamOut)
end
addEventHandler("onClientElementStreamIn", root, streamIn)
