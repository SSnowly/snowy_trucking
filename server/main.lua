
lib.callback.register("snowy_trucker:server:isAdmin", function(source)
    return IsAdmin(source)
end)
lib.callback.register("snowy_trucker:server:getJobs", function(source)
    if not IsAdmin(source) then
        lib.notify(source, {
            title = "No Permission",
            description = "You do not have permission to view jobs",
            duration = 5000,
            position = "bottom-right"
        })
        return false
    end
    local jobs = MySQL.query.await([[
        SELECT * FROM `trucker_jobs`
    ]])
    return jobs
end)

lib.callback.register("snowy_trucker:server:getJob", function(source, jobId)
    if source then return end
    local job = MySQL.query.await([[
        SELECT * FROM `trucker_jobs` WHERE `id` = @jobId
    ]], { ["@jobId"] = jobId })
    return job
end)
lib.callback.register("snowy_trucker:server:createJob", function(source, data)
    if not IsAdmin(source) then
        lib.notify(source, {
            title = "No Permission",
            description = "You do not have permission to create jobs",
            duration = 5000,
            position = "bottom-right"
        })
        return false
    end
    MySQL.insert.await([[
        INSERT INTO `trucker_jobs` (`data`) VALUES (@data)
    ]], { ["@data"] = json.encode(data) })
    return true
end)

lib.callback.register("snowy_trucking:server:createTrailer", function(source, data)
    if not IsAdmin(source) then
        lib.notify(source, {
            title = "No Permission",
            description = "You do not have permission to create trailers",
            duration = 5000,
            position = "bottom-right"
        })
        return false
    end
    print("creating trailer")
    MySQL.insert.await([[
        INSERT INTO `trucker_data_trailers` (`data`) VALUES (@data)
    ]], { ["@data"] = json.encode(data) })
    return true
end)

lib.callback.register("snowy_trucking:server:getTrailers", function(source)
    if not IsAdmin(source) then
        return false
    end
    local trailers = MySQL.query.await([[
        SELECT * FROM `trucker_data_trailers`
    ]])
    return trailers
end)

lib.callback.register("snowy_trucker:server:getTrailer", function(source, trailerID)
    print("getting trailer with id: "..trailerID)
    local trailer = MySQL.query.await([[
        SELECT * FROM `trucker_data_trailers` WHERE `id` = @trailerID
    ]], { ["@trailerID"] = trailerID })
    print(json.encode(trailer, {indent = true}))
    return trailer
end)

lib.callback.register("snowy_trucking:server:getAvailableJobs", function(source)
    local jobs = MySQL.query.await([[
        SELECT * FROM `trucker_jobs`
    ]])
    return jobs
end)

