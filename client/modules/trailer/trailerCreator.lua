local shared = require 'configs.shared'

local selectTrailer = function()
    local isAdmin = lib.callback.await("snowy_trucker:server:isAdmin", false)
    if not isAdmin then
        return lib.notify({
            title = "No Permission",
            description = "You do not have permission to view trailers",
            duration = 5000,
            position = "bottom-right"
        })
    end
    lib.notify({
        title = "READ ME!",
        description = "The model hash is the hash of the object you want to spawn to place on top of the trailer, you can find the hashes here: https://forge.plebmasters.de/objects.",
        duration = 15000,
        position = "right",
        type = "error",
    })
    local input = lib.inputDialog("Select Object", {
        { type = "input", label = "Object Hash Code", description = "Hash code of object."},
    })
    if not input then return end
    return input[1]
end

local trailerMaker = function(input)
    local isAdmin = lib.callback.await("snowy_trucker:server:isAdmin", false)
    if not isAdmin then
        return lib.notify({
            title = "No Permission",
            description = "You do not have permission to view trailers",
            duration = 5000,
            position = "bottom-right"
        })
    end
    ::start::
    local trailerData = {}
    local tempData = {}
    local rayDistance = 20.0
    local result = RaycastEntity(rayDistance)
    lib.requestModel(input[2], 10000)
    print("hey!")
    SetEntityCoords(PlayerPedId(), shared.trailerCreator.position.x, shared.trailerCreator.position.y, shared.trailerCreator.position.z+2.0, true, false, false, false)
    local trailer = CreateVehicle(input[2], shared.trailerCreator.position.x, shared.trailerCreator.position.y, shared.trailerCreator.position.z, shared.trailerCreator.position.w, true, true)
    SetModelAsNoLongerNeeded(input[2])
    ::objectSelect::
    print("triggering input")
    local currentObject = selectTrailer()
    print("input done!")
    if not IsModelValid(currentObject) then
        lib.notify({
            title = "Invalid Model",
            description = "The model you selected is not valid, please try again!",
            duration = 5000,
            position = "right",
            type = "error",
        })
        goto objectSelect
    end
    lib.requestModel(currentObject, 10000)
    local isCurrentObjectPlaced = false
    local entityDimensions = GetModelDimensions(currentObject)
    local offset = (entityDimensions.z / 2) + 0.0
    local obj = CreateObject(currentObject, result.endCoords.x, result.endCoords.y, result.endCoords.z+offset, false, true, false)
    SetEntityCollision(obj, false, false)
    SetEntityAlpha(obj, 200, false)
    lib.notify({
        title = "READ ME!",
        description = "When you place an object, the distance between the trailer and your object when you place it will be calculated as offset from the trailer entity, which means that if you place it far from it it will be offset that far when its spawned. For best experience place the object on top of the trailer.",
        duration = 15000,
        position = "right",
        type = "error",
    })
    lib.showTextUI("[ENTER] Confirm, [X] Cancel")
    exports['fivem-freecam']:SetActive(true)
    SetEntityVisible(PlayerPedId(), false, false)
    while not isCurrentObjectPlaced do
        result = RaycastEntity(rayDistance)
        if result.hit then
            SetEntityCoords(obj, result.endCoords.x, result.endCoords.y, result.endCoords.z+offset, false, true, false)
            if IsDisabledControlJustPressed(0, 261) then
                SetEntityHeading(obj, GetEntityHeading(obj) + 3)
            end
            if IsDisabledControlJustPressed(0, 262) then
                SetEntityHeading(obj, GetEntityHeading(obj) - 3)
            end
            if IsDisabledControlJustPressed(0, 191) then -- ENTER key
                local offset = GetOffsetFromEntityGivenWorldCoords(trailer, result.endCoords.x, result.endCoords.y, result.endCoords.z+offset)
                trailerData[#trailerData+1] = {
                    object = currentObject,
                    offset = { x = offset.x, y = offset.y, z = offset.z },
                    rotation = GetEntityRotation(obj),
                }
                SetEntityAlpha(obj, 255, false)
                tempData[#tempData+1] = {
                    object = obj,
                }
                isCurrentObjectPlaced = true
            elseif IsDisabledControlJustPressed(0, 73) then -- X key to cancel
                isCurrentObjectPlaced = true
                DeleteEntity(obj)
                goto objectSelect
            end
        end
        Wait(0)
    end
    SetModelAsNoLongerNeeded(currentObject)
    
    lib.hideTextUI()
    local alert = lib.alertDialog({
        header = 'Do you want to add more objects?',
        content = 'You want to add more items, or create this trailer!',
        centered = true,
        cancel = true,
        labels = {
            cancel = "Yes, Add More",
            confirm = "No, Create Trailer",
        }
    })
    if alert == "cancel" then
        goto objectSelect
        return
    end
    SetEntityVisible(PlayerPedId(), true, false)
    exports['fivem-freecam']:SetActive(false)
    for _, data in pairs(tempData) do
        print(data.object)
        if DoesEntityExist(data.object) then
            DeleteObject(data.object)
        end
    end
    print("tempData deleted")
    tempData = {}
    if DoesEntityExist(trailer) then
        DeleteEntity(trailer)
    end
    trailer = nil
    return {
        trailerData = trailerData,
    }
end
RegisterCommand("trailerjob", function()
    local isAdmin = lib.callback.await("snowy_trucker:server:isAdmin", false)
    if not isAdmin then
        return lib.notify({
            title = "No Permission",
            description = "You do not have permission to view trailers",
            duration = 5000,
            position = "bottom-right"
        })
    end
    lib.showContext("trucker_trailer_creator")
end)
local CreateTrailer = function()
    local isAdmin = lib.callback.await("snowy_trucker:server:isAdmin", false)
    if not isAdmin then
        lib.notify({
            title = "No Permission",
            description = "You do not have permission to view trailers",
            duration = 5000,
            position = "bottom-right"
        })
    end
    local formattedTrailerBases = {}
    for key, value in pairs(shared.TrailerBases) do
        formattedTrailerBases[#formattedTrailerBases+1] = {
            label = value,
            value = key
        }
    end
    local input = lib.inputDialog("Create Trailer", {
        { type = "input", label = "Trailer Name", description = "Display Name for the trailer" },
        { type = "select", label = "Trailer Base", options = formattedTrailerBases },
        { type = "number", label = "Trailer Price", description = "Price of the trailer" },
    })
    if not input then return end
    local data = trailerMaker(input)
    local newData = {
        name = input[1],
        base = input[2],
        price = input[3],
        objects = data.trailerData,
    }
    lib.callback.await("snowy_trucking:server:createTrailer", false, newData)
end

local Init = function()
    lib.registerContext({
        id = "trucker_trailer_creator",
        title = "Trailer Creator",
        options = {
            {
                title = "Create Trailer",
                icon = "fa-solid fa-plus",
                onSelect = function()
                    CreateTrailer()
                end
            },
            {
                title = "All Trailers",
                icon = "fa-solid fa-list",
                onSelect = function()
                    ListTrailers()
                end
            }
        }
    })
end

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end
    Init()
end)
