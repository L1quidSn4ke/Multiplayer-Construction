local QBCore = exports['qb-core']:GetCoreObject()
local activeJobs = {}
local participants = {}

-- Event to handle player death
RegisterServerEvent('playerDied')
AddEventHandler('playerDied', function()
    TriggerClientEvent('playerDied', source)
end)

-- Event to handle vehicle destruction
RegisterServerEvent('vehicleDestroyed')
AddEventHandler('vehicleDestroyed', function(vehicle)
    TriggerClientEvent('vehicleDestroyed', source, vehicle)
end)

-- Event to start the construction job
RegisterServerEvent('construction:startJob')
AddEventHandler('construction:startJob', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)

    if not activeJobs[src] then
        activeJobs[src] = true
        participants[src] = player.PlayerData.name
        TriggerClientEvent('construction:updateParticipants', -1,
participants)
    end
end)

-- Event to stop the construction job
RegisterServerEvent('construction:stopJob')
AddEventHandler('construction:stopJob', function()
    local src = source
    if activeJobs[src] then
        activeJobs[src] = nil
        participants[src] = nil
        TriggerClientEvent('construction:updateParticipants', -1,
participants)
    end
end)

-- Event to complete the construction job
RegisterServerEvent('construction:completeJob')
AddEventHandler('construction:completeJob', function(jobsCompleted)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)

    if activeJobs[src] then
        activeJobs[src] = nil
        participants[src] = nil
        TriggerClientEvent('construction:updateParticipants', -1,
participants)

        local participantCount = #participants
        local baseReward = 500
        local bonusPerParticipant = 100
        local bonusPerJob = 50

        local totalReward = baseReward + (participantCount *
bonusPerParticipant) + (jobsCompleted * bonusPerJob)

        for _, participant in pairs(participants) do
            local participantPlayer =
QBCore.Functions.GetPlayerByCitizenId(participant)
            if participantPlayer then
                participantPlayer.Functions.AddMoney('bank', totalReward /
participantCount)
                TriggerClientEvent('QBCore:Notify',
participantPlayer.PlayerData.source, "You received $" .. totalReward /
participantCount .. " for completing the construction job.", 'success')
            end
        end
    end
end)
