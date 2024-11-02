local shared = require "configs.shared"
local Injobs = {}
local multiplier = 1.4
lib.callback.register("snowy_trucking:server:startedJob", function(source, jobId)
    local src = source
    Injobs[src] = jobId
    lib.print.warn("Job Started: " .. jobId)
    return true
end)

lib.callback.register("snowy_trucking:server:completeJob", function(source, jobId)
    local src = source
    if not jobId then 
        lib.print.warn("No job ID provided for completion")
        return false
    end
    
    lib.print.warn("Job Checking: " .. jobId)
    if Injobs[src] == jobId then
        local job = MySQL.query.await('SELECT * FROM trucker_jobs WHERE id = ?', {jobId})
        if job and job[1] then
            local jobData = json.decode(job[1].data)
            local money = (jobData.distance * shared.incomePerMiles) * multiplier
            exports.ox_inventory:AddItem(src, "money", money)
            Injobs[src] = nil
            lib.print.warn("Job Completed: " .. jobId)
            return true
        end
    end    
    lib.print.warn("Job Not Found: " .. jobId)
    return false
end)

