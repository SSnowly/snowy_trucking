local InJob, JobData, TrailerData = false, nil, nil
local shared = require 'configs.shared'

local TakeJob = function(job)
    lib.callback.await("snowy_trucking:server:startedJob", false, job.id)
    local endingPosition = job.data.endingPosition
    local trailerPosition = job.data.trailerPosition
    local jobId = job.id  -- Store the job ID
    local vehicle = nil
    local objects = {}
    if not shared.trailerTypes[job.data.trailerType] then
        local fetchTrailer = lib.callback.await("snowy_trucker:server:getTrailer", false, job.data.trailerType)
        local fetchTrailerData = json.decode(fetchTrailer[1].data)
        local trailerBase = fetchTrailerData.base
        
        -- Request model before creating vehicle
        lib.requestModel(trailerBase, 10000)
        vehicle = CreateVehicle(trailerBase, trailerPosition.x, trailerPosition.y, trailerPosition.z, 0.0, true, true)

        if not DoesEntityExist(vehicle) then
            return lib.notify({
                title = "Error",
                description = "Failed to create trailer base",
                type = "error"
            })
        end
        
        local trailerEntityPos = GetEntityCoords(vehicle)
        Wait(100)
        if fetchTrailerData.objects then
            for _, object in pairs(fetchTrailerData.objects) do
                if object.object then
                    lib.requestModel(object.object, 10000)
                    local obi = CreateObject(object.object, trailerEntityPos.x, trailerEntityPos.y, trailerEntityPos.z, false, false, false)
                    
                    if DoesEntityExist(obi) then
                        SetEntityCollision(obi, false, false)
                        AttachEntityToEntity(obi, vehicle, 0, 
                            object.offset.x, object.offset.y, object.offset.z,
                            object.rotation.x, object.rotation.y, object.rotation.z - 80.0,
                            true, true, true, false, 5, true)
                        SetEntityAlpha(obi, 255, false)
                        table.insert(objects, obi)
                    end
                    
                    SetModelAsNoLongerNeeded(object.object)
                end
            end
        end
    else
        local entity = lib.requestModel(job.data.trailerType, 20000)
        vehicle = CreateVehicle(entity, trailerPosition.x, trailerPosition.y, trailerPosition.z-1.0, trailerPosition.w, true, true)
        SetVehicleNumberPlateText(vehicle, "POSTOP")
        SetModelAsNoLongerNeeded(entity)
    end
    local blip = CreateBlip(endingPosition, 1, 1, 0.8)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, 3)
    lib.notify({
        title = "Job Started",
        description = "Deliver the trailer to the destination",
        duration = 5000,
        position = "bottom-right"
    })
    InJob = true
    local dim = GetModelDimensions(GetEntityModel(vehicle))
    local inside = {
        vector2(endingPosition.x + dim.x, endingPosition.y + dim.y) + vector2(1.0, 1.0), -- First corner
        vector2(endingPosition.x - dim.x, endingPosition.y - dim.y) + vector2(1.0, 1.0)  -- Opposite corner
    }
    local zoneWidth = math.abs(inside[1].x - inside[2].x) + 1.0
    local zoneLength = math.abs(inside[1].y - inside[2].y) + 1.0
    print(json.encode(inside))
    
    while InJob do
        if #(GetEntityCoords(vehicle) - vector3(endingPosition.x, endingPosition.y, endingPosition.z)) > 50.0 then
            Wait(0)
        end
        local vehiclePos = GetEntityCoords(vehicle)
        local vehicleHeading = GetEntityHeading(vehicle)
        local trailerPos2D = vector2(vehiclePos.x, vehiclePos.y)
        local targetPos2D = vector2(endingPosition.x, endingPosition.y)
        
        -- Calculate smallest angle difference accounting for 0-360 wrap-around
        local headingDiff = math.abs(vehicleHeading - endingPosition.w)
        if headingDiff > 180 then
            headingDiff = 360 - headingDiff
        end
        -- Check if vehicle is within position bounds and has correct heading (within 15 degrees)
        local isInside = (
            trailerPos2D.x >= math.min(inside[1].x, inside[2].x) and
            trailerPos2D.x <= math.max(inside[1].x, inside[2].x) and
            trailerPos2D.y >= math.min(inside[1].y, inside[2].y) and
            trailerPos2D.y <= math.max(inside[1].y, inside[2].y) and
            headingDiff < 40.0
        )

        -- Debug print with proper concatenation
        lib.print.warn(string.format("Pos: %.2f, %.2f | Bounds: %.2f-%.2f, %.2f-%.2f | Heading: %.2f/%.2f | Heading Diff: %.2f", 
            vehiclePos.x, vehiclePos.y,
            math.min(inside[1].x, inside[2].x), math.max(inside[1].x, inside[2].x),
            math.min(inside[1].y, inside[2].y), math.max(inside[1].y, inside[2].y),
            vehicleHeading, endingPosition.w,
            headingDiff
        ))
        if not isInside or GetEntitySpeed(vehicle) > 0.3 then
            DrawMarker(30, endingPosition.x, endingPosition.y, endingPosition.z, 0, 0, 0, 90.0, 0, 0, zoneWidth, 0.2, zoneLength, 25, 255, 255, 200, false, false, 0, false)

        end
        if isInside and GetEntitySpeed(vehicle) <= 0.3 then
            DrawMarker(30, endingPosition.x, endingPosition.y, endingPosition.z, 0, 0, 0, 90.0, 0, 0, zoneWidth, 0.2, zoneLength, 0, 255, 0, 200, false, false, 0, false)
            if not lib.isTextUIOpen() then
                lib.showTextUI("[E] - Complete Job")
            end
            if IsControlJustReleased(0, 38) then
                InJob = false
                DeleteEntity(vehicle)
                for _, object in pairs(objects) do
                    DeleteEntity(object)
                end
                RemoveBlip(blip)
                lib.notify({
                    title = "Job Completed",
                    description = "You have successfully delivered the trailer",
                    duration = 5000,
                    position = "bottom-right"
                })
                lib.hideTextUI()
                lib.callback.await("snowy_trucking:server:completeJob", false, jobId)
            end
        end
        Wait(0)
    end
end
local JobMenu = function()
    local jobs = lib.callback.await("snowy_trucking:server:getAvailableJobs", false)
    local formattedJobs = {}
    for _, job in pairs(jobs) do
        job.data = json.decode(job.data)
        local display = nil
        if not shared.trailerTypes[job.data.trailerType] then
            local trailer = lib.callback.await("snowy_trucker:server:getTrailer", false, job.data.trailerType)
            display = json.decode(trailer[1].data).name
        else
            display = shared.trailerTypes[job.data.trailerType]
        end
        formattedJobs[#formattedJobs+1] = {
            title = job.name,
            description = string.format(
                "Description: %s\nJob: %s\nTrailer: %s\nDepo Location: %s\nDistance: %s Miles \n\n Click to Take",
                job.data.description,
                shared.jobTypes[job.data.jobType],
                display,
                shared.depoLocations[job.data.depoLocation].label,
                job.data.distance
            ),
            onSelect = function()
                TakeJob(job)
            end
        }
    end
    lib.registerContext({
        id = "trucker_job_player",
        title = "Available Jobs",
        options = formattedJobs
    })
    lib.showContext("trucker_job_player")
end
RegisterCommand("availablejobs", JobMenu)
local Init = function()
    InJob = false
    JobData = nil
    TrailerData = nil
end

AddEventHandler("onResourceStart", function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Init()
end)
