local QBCore = exports['qb-core']:GetCoreObject()
local isOnJob = false
local workTruck = nil
local currentTool = nil
local jobsCompleted = 0
local participants = {}

-- Function to start the construction job
function StartConstructionJob()
    if not isOnJob then
        isOnJob = true
        SpawnWorkTruck()
        Notify("Construction Job", "Job started. Use the UI to equip
tools.")
        UpdateUI({ jobStatus = "In Progress", currentTool = "None" })
        TriggerServerEvent('construction:startJob')
    else
        Notify("Construction Job", "You are already on a job.", 'error')
    end
end

-- Function to spawn the work truck
function SpawnWorkTruck()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    workTruck = CreateVehicle(GetHashKey("flatbed"), playerCoords.x,
playerCoords.y, playerCoords.z, GetEntityHeading(playerPed), true, false)
    SetVehicleOnGroundProperly(workTruck)
    Notify("Construction Job", "Work truck spawned. Protect it!")
end

-- Function to equip a tool
function EquipTool(toolName)
    if isOnJob and Items[toolName] then
        if currentTool then
            DeleteObject(currentTool)
        end
        currentTool = CreateObject(GetHashKey(Items[toolName].model),
GetEntityCoords(PlayerPedId()), true, true, true)
        AttachEntityToEntity(currentTool, PlayerPedId(),
GetPedBoneIndex(PlayerPedId(), 57005), 0.12, 0.028, 0.001, 10.0, 175.0, 0.0,
true, true, false, true, 1, true)
        Notify("Construction Job", "Equipped " .. Items[toolName].name ..
".")
        UpdateUI({ jobStatus = "In Progress", currentTool =
Items[toolName].name })
    else
        Notify("Construction Job", "Invalid tool or job not started.",
'error')
    end
end

-- Function to notify the player
function Notify(title, message, type)
    exports['okokNotify']:Alert(title, message, 5000, type)
end

-- Event to handle player death
RegisterNetEvent('playerDied')
AddEventHandler('playerDied', function()
    if isOnJob then
        StopConstructionJob()
    end
end)

-- Event to handle vehicle destruction
RegisterNetEvent('vehicleDestroyed')
AddEventHandler('vehicleDestroyed', function(vehicle)
    if isOnJob and workTruck == vehicle then
        StopConstructionJob()
    end
end)

-- Function to stop the construction job
function StopConstructionJob()
    if isOnJob then
        isOnJob = false
        if workTruck then
            DeleteVehicle(workTruck)
        end
        if currentTool then
            DeleteObject(currentTool)
        end
        Notify("Construction Job", "Job stopped due to truck destruction or
player death.", 'error')
        UpdateUI({ jobStatus = "Not Started", currentTool = "None" })
        TriggerServerEvent('construction:stopJob')
    end
end

-- Function to complete the construction job
function CompleteConstructionJob()
    if isOnJob then
        isOnJob = false
        if workTruck then
            DeleteVehicle(workTruck)
        end
        if currentTool then
            DeleteObject(currentTool)
        end
        Notify("Construction Job", "Job completed successfully.")
        UpdateUI({ jobStatus = "Not Started", currentTool = "None" })
        jobsCompleted = jobsCompleted + 1
        TriggerServerEvent('construction:completeJob', jobsCompleted)
    end
end

-- Function to update the UI
function UpdateUI(data)
    SendNUIMessage({
        type = 'updateUI',
        jobStatus = data.jobStatus,
        currentTool = data.currentTool
    })
end

-- Command to start the construction job
RegisterCommand('startconstruction', function()
    StartConstructionJob()
end)

-- Command to equip a tool
RegisterCommand('equip', function(source, args)
    if #args > 0 then
        EquipTool(args[1])
    else
        Notify("Construction Job", "Usage: /equip <tool>", 'error')
    end
end)

-- NUI Callback to start the job
RegisterNUICallback('startJob', function(data, cb)
    StartConstructionJob()
    cb('ok')
end)

-- NUI Callback to equip a tool
RegisterNUICallback('equipTool', function(data, cb)
    EquipTool(data.tool)
    cb('ok')
end)

-- NUI Callback to complete the job
RegisterNUICallback('completeJob', function(data, cb)
    CompleteConstructionJob()
    cb('ok')
end)

-- Event to update participants
RegisterNetEvent('construction:updateParticipants')
AddEventHandler('construction:updateParticipants', function(newParticipants)
    participants = newParticipants
end)
