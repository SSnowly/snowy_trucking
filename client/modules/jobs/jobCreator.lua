local shared = require 'configs.shared'

local PreviewJob = function(job)
    local isAdmin = lib.callback.await("snowy_trucker:server:isAdmin", false)
    if not isAdmin then
        return lib.notify({
            title = "No Permission",
            description = "You do not have permission to view jobs",
            duration = 5000,
            position = "bottom-right"
        })
    end
    DoScreenFadeOut(500)
    Wait(700)
    local jobData = job.data
    local trailerPosition = jobData.trailerPosition
    local endingPosition = jobData.endingPosition
    local depoLocation = shared.depoLocations[jobData.depoLocation].position
    local previewing = true
    lib.showTextUI("[X] Exit\n\n[←] Previous Point | [→] Next Point")
    local previewPosition = 1
    local maxPreviewPoints = 3
    local lastPreviewPosition = 1
    local PlayerLastPosition = GetEntityCoords(PlayerPedId())
    SetEntityVisible(PlayerPedId(), false, false)
    Wait(700)
    DoScreenFadeIn(500)
    while previewing do
        if previewPosition > maxPreviewPoints then
            previewPosition = 1
        elseif previewPosition < 1 then
            previewPosition = maxPreviewPoints
        end
        if previewPosition == 1 then
            DrawMarker(0, depoLocation.x, depoLocation.y, depoLocation.z+3.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.5, 2.5, 2.5, 0, 255, 0, 100, false, false, 2, false, nil, nil, false)
            DrawMarker(1, trailerPosition.x, trailerPosition.y, trailerPosition.z-2.75, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.5, 2.5, 2.5, 255, 255, 255, 100, false, false, 2, false, nil, nil, false)
            DrawMarker(4, endingPosition.x, endingPosition.y, endingPosition.z+1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.5, 2.5, 2.5, 255, 255, 255, 100, false, false, 2, false, nil, nil, false)
            if lastPreviewPosition ~= previewPosition then
                DoScreenFadeOut(300)
                Wait(300)
                exports['fivem-freecam']:SetPosition(depoLocation.x+3.0, depoLocation.y+3.0, depoLocation.z+3.0)
                SetEntityCoords(PlayerPedId(), depoLocation.x+3.0, depoLocation.y+3.0, depoLocation.z+3.0, true, false, false, false)
                DoScreenFadeIn(300)
            end
        end
        if previewPosition == 2 then
            DrawMarker(0, depoLocation.x, depoLocation.y, depoLocation.z+3.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.5, 2.5, 2.5, 255, 255, 255, 100, false, false, 2, false, nil, nil, false)
            DrawMarker(1, trailerPosition.x, trailerPosition.y, trailerPosition.z-2.75, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.5, 2.5, 2.5, 0, 255, 0, 100, false, false, 2, false, nil, nil, false)
            DrawMarker(4, endingPosition.x, endingPosition.y, endingPosition.z+1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.5, 2.5, 2.5, 255, 255, 255, 100, false, false, 2, false, nil, nil, false)

            if lastPreviewPosition ~= previewPosition then
                DoScreenFadeOut(300)
                Wait(300)
                exports['fivem-freecam']:SetPosition(trailerPosition.x+3.0, trailerPosition.y+3.0, trailerPosition.z+3.0)
                SetEntityCoords(PlayerPedId(), trailerPosition.x, trailerPosition.y, trailerPosition.z, true, false, false, false)
                DoScreenFadeIn(300)
            end
        end
        if previewPosition == 3 then
            DrawMarker(0, depoLocation.x, depoLocation.y, depoLocation.z+3.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.5, 2.5, 2.5, 255, 255, 255, 100, false, false, 2, false, nil, nil, false)
            DrawMarker(1, trailerPosition.x, trailerPosition.y, trailerPosition.z-2.75, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.5, 2.5, 2.5, 255, 255, 255, 100, false, false, 2, false, nil, nil, false)
            DrawMarker(4, endingPosition.x, endingPosition.y, endingPosition.z+1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.5, 2.5, 2.5, 0, 255, 0, 100, false, false, 2, false, nil, nil, false)
            if lastPreviewPosition ~= previewPosition then
                DoScreenFadeOut(300)
                Wait(300)
                exports['fivem-freecam']:SetPosition(endingPosition.x+3.0, endingPosition.y+3.0, endingPosition.z+3.0)
                SetEntityCoords(PlayerPedId(), endingPosition.x, endingPosition.y, endingPosition.z, true, false, false, false)
                DoScreenFadeIn(300)
            end
        end
        lastPreviewPosition = previewPosition
        if IsDisabledControlJustPressed(0, 175) then
            previewPosition += 1
        end
        if IsDisabledControlJustPressed(0, 174) then
            previewPosition -= 1
        end
        if IsDisabledControlJustPressed(0, 73) then
            previewing = false
            DoScreenFadeOut(300)
        end
        Wait(0)
    end
    Wait(300)
    exports['fivem-freecam']:SetActive(false)
    SetEntityCoords(PlayerPedId(), PlayerLastPosition.x, PlayerLastPosition.y, PlayerLastPosition.z, true, false, false, false)
    SetEntityVisible(PlayerPedId(), true, false)
    lib.hideTextUI()
    Wait(700)
    DoScreenFadeIn(300)
end 

local ListJobs = function()
    local isAdmin = lib.callback.await("snowy_trucker:server:isAdmin", false)
    if not isAdmin then
        return lib.notify({
            title = "No Permission",
            description = "You do not have permission to view jobs",
            duration = 5000,
            position = "bottom-right"
        })
    end
    local jobs = lib.callback.await("snowy_trucker:server:getJobs")
    local jobFormatted = {}
    if not jobs then
        jobFormatted = {
            {
                title = "No jobs found",
            }
        }
    else
        for _, job in pairs(jobs) do
            job.data = json.decode(job.data)
            table.insert(jobFormatted, {
                title = job.data.name,
                description = string.format(
                    "Description: %s\nJob: %s\nTrailer: %s\nDepo Location: %s\nDistance: %s Miles",
                    job.data.description,
                    shared.jobTypes[job.data.jobType],
                    shared.trailerTypes[job.data.trailerType],
                    shared.depoLocations[job.data.depoLocation].label,
                    job.data.distance
                ),
                onSelect = function()
                    PreviewJob(job)
                end
            })
        end
    end
    
    lib.registerContext({
        id = "trucker_jobs_list",
        title = "Job List",
        options = jobFormatted,
    })
    lib.showContext("trucker_jobs_list")
end

local createPositions = function(input)
    local isAdmin = lib.callback.await("snowy_trucker:server:isAdmin", false)
    if not isAdmin then
        return lib.notify({
            title = "No Permission",
            description = "You do not have permission to view jobs",
            duration = 5000,
            position = "bottom-right"
        })
    end
    ::start::
    DoScreenFadeOut(500)
    Wait(700)
    local trailerType = input[4]
    local depoLocation = input[5]
    local trailerPosition = false
    local rayDistance = 20.0
    local obj = nil
    local objects = {} -- Move this outside to maintain scope
    local result = RaycastEntity(rayDistance)
    if not shared.trailerTypes[trailerType] then
        local fetchTrailer = lib.callback.await("snowy_trucker:server:getTrailer", false, trailerType)
        if not fetchTrailer or #fetchTrailer == 0 then
            return lib.notify({
                title = "Error",
                description = "Failed to fetch trailer data",
                type = "error"
            })
        end
        
        local fetchTrailerData = json.decode(fetchTrailer[1].data)
        local trailerBase = fetchTrailerData.base
        
        -- Request model before creating vehicle
        lib.requestModel(trailerBase, 10000)
        obj = CreateObject(trailerBase, result.endCoords.x, result.endCoords.y, result.endCoords.z, 0.0, true, true)

        if not DoesEntityExist(obj) then
            return lib.notify({
                title = "Error",
                description = "Failed to create trailer base",
                type = "error"
            })
        end
        
        local trailerEntityPos = GetEntityCoords(obj)
        Wait(100)
        
        if fetchTrailerData.objects then
            for _, object in pairs(fetchTrailerData.objects) do
                if object.object then
                    lib.requestModel(object.object, 10000)
                    local obi = CreateObject(object.object, trailerEntityPos.x, trailerEntityPos.y, trailerEntityPos.z, false, false, false)
                    
                    if DoesEntityExist(obi) then
                        AttachEntityToEntity(obi, obj, 0, 
                            object.offset.x, object.offset.y, object.offset.z,
                            object.rotation.x, object.rotation.y, object.rotation.z - 80.0,
                            true, true, true, false, 5, true)
                        SetEntityAlpha(obi, 200, false)
                        table.insert(objects, obi)
                    end
                    
                    SetModelAsNoLongerNeeded(object.object)
                end
            end
        end
    else
        lib.requestModel(trailerType, 10000)
        obj = CreateObject(trailerType, result.endCoords.x, result.endCoords.y, result.endCoords.z, false, true, false)
    end
    exports['fivem-freecam']:SetActive(true)
    FreezeEntityPosition(obj, true)
    SetEntityCollision(obj, false, false)
    SetEntityVisible(PlayerPedId(), false, false)
    lib.showTextUI("[ENTER] Confirm, [X] Cancel")
    Wait(700)
    DoScreenFadeIn(500)
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityVisible(obj, true, false)
    while not trailerPosition do
        result = RaycastEntity(rayDistance)
        
        if result.hit then
            SetEntityCoords(obj, result.endCoords.x, result.endCoords.y, result.endCoords.z, false, true, false, false)
            SetEntityCoords(PlayerPedId(), result.endCoords.x, result.endCoords.y, result.endCoords.z+5.0, false, true, false, false)
            PlaceObjectOnGroundProperly(obj)
        end
        if IsDisabledControlJustPressed(0, 261) then
            SetEntityHeading(obj, GetEntityHeading(obj) + 3)
        end
        if IsDisabledControlJustPressed(0, 262) then
            SetEntityHeading(obj, GetEntityHeading(obj) - 3)
        end
        if IsDisabledControlJustPressed(0, 191) then -- ENTER key
            local objCoords = GetEntityCoords(obj)
            trailerPosition = vec4(objCoords.x , objCoords.y,objCoords.z, GetEntityHeading(obj))
        elseif IsDisabledControlJustPressed(0, 73) then -- X key to cancel
            trailerPosition = true
        end
        Wait(0)
    end
    for _, obj in pairs(objects) do
        if DoesEntityExist(obj) then
            DeleteObject(obj)
        end
    end
    objects = {} -- Clear the table
    if DoesEntityExist(obj) then
        DeleteEntity(obj)
    end
    SetModelAsNoLongerNeeded(trailerType)
    lib.hideTextUI()
    if type(trailerPosition) == "boolean" then
        goto start
    end
    local trailerCheckpoint = CreateCheckpoint(47, trailerPosition.x, trailerPosition.y, trailerPosition.z-2.75, 0.0, 0.0, 0.0, 2.5, 255, 255, 255, 100, true)
    local endingPosition = false
    lib.showTextUI("[ENTER] Confirm, [X] Cancel")
    local heading = 0.0
    while not endingPosition do
        result = RaycastEntity(rayDistance)
        
        if result.hit then
            DrawMarker(4, result.endCoords.x, result.endCoords.y, result.endCoords.z+1.0, 0.0, 0.0, 0.0, 0.0, 0.0, heading, 2.5, 2.5, 2.5, 255, 255, 255, 100, false, false, 2, false, nil, nil, false)
            PlaceObjectOnGroundProperly(obj)
        end
        if IsDisabledControlJustPressed(0, 261) then
            heading += 3
        end
        if IsDisabledControlJustPressed(0, 262) then
            heading -= 3
        end
        if IsDisabledControlJustPressed(0, 191) then -- ENTER key
            endingPosition = vec4(result.endCoords.x, result.endCoords.y, result.endCoords.z, heading)
        elseif IsDisabledControlJustPressed(0, 73) then -- X key to cancel
            endingPosition = true
        end
        Wait(0)
    end
    lib.hideTextUI()
    local alert = lib.alertDialog({
        header = 'Are you Sure?',
        content = 'Are you sure you want to do this, if canceled, you will start over with the placements!',
        centered = true,
        cancel = true
    })
    exports['fivem-freecam']:SetActive(false)
    FreezeEntityPosition(PlayerPedId(), false)  
    SetEntityVisible(PlayerPedId(), true, false)
    if alert == "cancel" then
        DeleteCheckpoint(trailerCheckpoint)
        goto start
        return
    end
    DeleteCheckpoint(trailerCheckpoint)
    return {
        trailerPosition = trailerPosition,
        endingPosition = endingPosition,
    }
end

local CreateJob = function()
    local isAdmin = lib.callback.await("snowy_trucker:server:isAdmin", false)
    if not isAdmin then
        lib.notify({
            title = "No Permission",
            description = "You do not have permission to view jobs",
            duration = 5000,
            position = "bottom-right"
        })
    end
    local jobTypesFormatted = {}
    for _, jobType in pairs(shared.jobTypes) do
        jobTypesFormatted[#jobTypesFormatted + 1] = {
            value = _,
            label = jobType,
        }
    end
    local depoLocationsFormatted = {}
    for _, depoLocation in pairs(shared.depoLocations) do
        depoLocationsFormatted[#depoLocationsFormatted + 1] = {
            value = _,
            label = depoLocation.label,
        }
    end
    local trailerTypesFormatted = {}
    for _, trailerType in pairs(shared.trailerTypes) do
        trailerTypesFormatted[#trailerTypesFormatted + 1] = {
            value = _,
            label = trailerType,
        }
    end
    local trailers = lib.callback.await("snowy_trucking:server:getTrailers", false)
    for _, trailer in pairs(trailers) do
        trailer.data = json.decode(trailer.data)
        trailerTypesFormatted[#trailerTypesFormatted+1] = {
            value = trailer.id,
            label = trailer.data.name,
        }
    end
    local input = lib.inputDialog("Create Job", {
        { type = "input", label = "Job Name", placeholder = "Enter job name", required = true },
        { type = "input", label = "Job Description", placeholder = "Enter job description", required = true },
        { type = "select", label = "Job Type", options = jobTypesFormatted, required = true },
        { type = "select", label = "Trailer Type", options = trailerTypesFormatted, required = true },
        { type = "select", label = "Depo Location", options = depoLocationsFormatted, required = true },
    })
    if not input then return end
    local data = createPositions(input)
    local sentData = {
        trailerPosition = data.trailerPosition,
        endingPosition = data.endingPosition,
        name = input[1],
        description = input[2],
        jobType = input[3],
        trailerType = input[4],
        depoLocation = input[5],
        distance = math.floor(#(data.trailerPosition - data.endingPosition)*1.33)/1000,
    }
    lib.callback.await("snowy_trucker:server:createJob", false, sentData)
end


RegisterCommand("truckerjob", function()
    local isAdmin = lib.callback.await("snowy_trucker:server:isAdmin", false)
    if not isAdmin then
        return lib.notify({
            title = "No Permission",
            description = "You do not have permission to view jobs",
            duration = 5000,
            position = "bottom-right"
        })
    end
    lib.showContext("trucker_jobs")
end)

local Init = function()
    
    lib.registerContext({
        id = "trucker_jobs",
        title = "Job Creator",
        options = {
            {
                title = "Create Job",
                icon = "fa-solid fa-plus",
                onSelect = function()
                    CreateJob()
                end
            },
            {
                title = "All Jobs",
                icon = "fa-solid fa-list",
                onSelect = function()
                    ListJobs()
                end
            }
        },
    })
end



AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end
    Init()
end)

