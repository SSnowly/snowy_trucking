local shared = require "configs.shared"
local targetId, ped, clipboard = {}, {}, {}
Blips = {}
local NpcInteraction = function()
    if shared.Features.NpcTalk and ped then
        exports.mt_lib:showDialogue({
            ped = ped,
            label = "Mister Benjamin",
            speech = "Hello, how can I help you today?",
            options = {
                {
                    id = 1,
                    label = "I want to open the truck menu",
                    close = true,
                    icon = "fa-solid fa-truck",
                    action = function()
                        lib.notify({
                            title = "Not Implemented",
                            description = "This feature is not implemented yet, sorry!",
                            duration = 5000,
                            position = "bottom-right",
                        })
                    end
                },
                {
                    id = 2,
                    label = "Nevermind",
                    close = true,
                    icon = "fa-solid fa-xmark",
                }
            },
        })
    else
        lib.notify({
            title = "Not Implemented",
            description = "This feature is not implemented yet, sorry!",
            duration = 5000,
            position = "bottom-right",
        })
    end
end

local createBlip = function(name, blipData)
    print(json.encode(blipData, {indent = true}))
    local dblip = AddBlipForCoord(blipData.Position.x, blipData.Position.y, blipData.Position.z)
    SetBlipSprite(dblip, blipData.Sprite)
    SetBlipColour(dblip, blipData.Color)
    SetBlipScale(dblip, blipData.Scale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipData.Name)
    EndTextCommandSetBlipName(dblip)

    Blips[name] = name
end

local createDepot = function(name, depot)
    createBlip(name, depot.blip)
    if shared.Features.UseCreatePed then
        ped[name] = CreateDPed(vector4(depot.position.x, depot.position.y, depot.position.z - 1.0, depot.position.w), shared.DepotPed.Ped, shared.DepotPed.Anim)
        lib.requestModel("p_amb_clipboard_01", 10000)
        clipboard[name] = CreateObject("p_amb_clipboard_01", depot.position.x, depot.position.y, depot.position.z, true, true, false)
        SetModelAsNoLongerNeeded("p_amb_clipboard_01")
        AttachEntityToEntity(clipboard[name], ped[name], GetPedBoneIndex(ped[name], 36029), 0.160000, 0.080000, 0.100000, -130.000000, -50.000000, 0.000000, true, true, false, true, 1, true)
        if shared.Features.UseTarget then
            targetId[name] = exports.ox_target:addLocalEntity(ped[name], {
                {
                    name = "trucker_menu",
                    icon = "fa-solid fa-truck",
                    label = "Trucker Menu",
                    onSelect = function()
                        NpcInteraction()
                    end,
                    distance = 2.0,
                }
            })
        else 
            interact.addLocalEntity({
                id = "trucker_entity",
                entity = ped[name],
                options = {
                    {
                        label = "Open trucker menu",
                        icon = "fa-solid fa-truck",
                        onSelect =  function() 
                            if #(GetEntityCoords(PlayerPedId()) - vec3(depot.Position.x, depot.Position.y, depot.Position.z)) > 2.3 then
                                return
                            end
                            NpcInteraction() 
                        end,
                    }
                },
                renderDistance = 10.0,
                activeDistance = 2.3,
                cooldown = 1500
            
            })
        end
    else
        if shared.Features.UseTarget then
            targetId[name] = exports.ox_target:addSphereZone({
                    coords = depot.Position,
                    radius = 1.0,
                    debug = false,
                    options = {
                        {
                            name = "trucker_menu",
                            icon = "fa-solid fa-truck",
                            label = "Trucker Menu",
                            onSelect = function()
                                NpcInteraction()
                            end
                        }
                    },
                    distance = 2.0,
                })
        else
            interact.addCoords({
                id = "trucker_entity",
                    coords = vec3(depot.Position.x, depot.Position.y, depot.Position.z),
                    options = {
                        {
                            label = "Open trucker menu",
                            icon = "fa-solid fa-truck",
                            onSelect =  function() 
                                if #(GetEntityCoords(PlayerPedId()) - vec3(depot.Position.x, depot.Position.y, depot.Position.z)) > 2.3 then
                                    return
                                end
                                NpcInteraction()
                            end,
                        }
                    },
                    renderDistance = 10.0,
                    activeDistance = 2.3,
                    cooldown = 1500
                })
        end
    end
end
local Init = function()
    for _, depot in pairs(shared.depoLocations) do
        createDepot(_, depot)
    end
end

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end
    Init()
end)


AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end
    for _, id in pairs(targetId) do
        exports.ox_target:remove(id)
    end
    for _, ped in pairs(ped) do
        DeleteEntity(ped)
    end
    for _, clipboard in pairs(clipboard) do
        DeleteObject(clipboard)
    end
end)
