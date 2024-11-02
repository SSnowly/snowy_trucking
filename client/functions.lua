-- functions file, mostly shouldn't edit but, eh.

CreateBlip = function(position, sprite, color, scale)
    local blip = AddBlipForCoord(position.x, position.y, position.z)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipScale(blip, scale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Destination")
    EndTextCommandSetBlipName(blip)
    return blip
end

RotationToDirection = function(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

RaycastEntity = function(distance)
    local cameraRotation = exports['fivem-freecam']:GetRotation() or vec3(0.0, 0.0, 0.0)
    local cameraCoord = exports['fivem-freecam']:GetPosition() or vec3(0.0, 0.0, 0.0)
    local direction = RotationToDirection(cameraRotation)
    local destination =
    {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local _, hit, endCoords, surfaceNormal,materialHash,  entityHit = GetShapeTestResultIncludingMaterial(
    StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1,
        PlayerPedId(), 0))
    return {
        hit = hit,
        endCoords = endCoords,
        surfaceNormal = surfaceNormal,
        materialHash = materialHash,
        entityHit = entityHit
    }
end