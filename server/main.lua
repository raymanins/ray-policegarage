local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-policegarage:server:SaveVehicle', function(plate, vehicle)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    TriggerClientEvent('vehiclekeys:client:SetOwner', src, plate)
end)
