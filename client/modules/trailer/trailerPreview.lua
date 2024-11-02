local shared = require "configs.shared"

local PreviewTrailer = function(trailer)
    
    local isAdmin = lib.callback.await("snowy_trucker:server:isAdmin", false)
    if not isAdmin then
        return lib.notify({
            title = "No Permission",
            description = "You do not have permission to view trailers",
            duration = 5000,
            position = "bottom-right"
        })
    end
    local trailerData = trailer.data
    local trailerObjects = trailerData.objects
    local trailerBase = trailerData.base
    DoScreenFadeOut(500)
    Wait(700)
    lib.requestModel(trailerBase, 10000)
    local trailerEntity = CreateVehicle(trailerBase, shared.trailerCreator.position.x, shared.trailerCreator.position.y, shared.trailerCreator.position.z, shared.trailerCreator.position.w, true, true)
    local trailerEntityPos = GetEntityCoords(trailerEntity)
    local playerPos = GetEntityCoords(PlayerPedId())
    Wait(100)
    local objects = {}
    for _, object in pairs(trailerObjects) do
        lib.requestModel(object.object, 10000)
        local obj = CreateObject(object.object, trailerEntityPos.x, trailerEntityPos.y, trailerEntityPos.z, false, false, false)
        AttachEntityToEntity(obj, trailerEntity, 0, object.offset.x, object.offset.y, object.offset.z, object.rotation.x, object.rotation.y, object.rotation.z - 80.0, true, true, true, false, 5, true)
        objects[#objects+1] = obj
        SetModelAsNoLongerNeeded(object.object)
    end
    SetEntityCoords(PlayerPedId(), GetEntityCoords(trailerEntity), true, false, false, false)
    SetModelAsNoLongerNeeded(trailerBase)
    lib.showTextUI("[X] Quit Preview")
    Wait(200)
    exports['fivem-freecam']:SetActive(true)
    SetEntityVisible(PlayerPedId(), false, false)
    Wait(700)
    DoScreenFadeIn(500)
    local previewing = true
    while previewing do
        if IsDisabledControlJustPressed(0, 73) then
            previewing = false
        end
        Wait(0)
    end
    DoScreenFadeOut(500)
    Wait(700)
    exports['fivem-freecam']:SetActive(false)
    SetEntityVisible(PlayerPedId(), true, false)
    for _, obj in pairs(objects) do
        if DoesEntityExist(obj) then
            DeleteObject(obj)
        end
    end
    if DoesEntityExist(trailerEntity) then
        DeleteEntity(trailerEntity)
    end
    lib.hideTextUI()
    SetEntityCoords(PlayerPedId(), playerPos.x, playerPos.y, playerPos.z, false, false, false, false)
    Wait(700)
    DoScreenFadeIn(500)
end

ListTrailers = function()
    local isAdmin = lib.callback.await("snowy_trucker:server:isAdmin", false)
    if not isAdmin then
        return lib.notify({
            title = "No Permission",
            description = "You do not have permission to view trailers",
            duration = 5000,
            position = "bottom-right"
        })
    end
    local trailers = lib.callback.await("snowy_trucking:server:getTrailers", false)
    local formattedTrailers = {}
    for _, trailer in pairs(trailers) do
        trailer.data = json.decode(trailer.data)
        formattedTrailers[#formattedTrailers+1] = {
            title = trailer.data.name,
            description = "Price: $" .. (trailer.data.price or 0).. "\n\n Click to Preview",
            icon = "fa-solid fa-truck-trailer",
            onSelect = function()
                PreviewTrailer(trailer)
            end
        }
    end
    lib.registerContext({
        id = "trucker_trailer_list",
        title = "Trailer List",
        options = formattedTrailers
    })
    lib.showContext("trucker_trailer_list")
end