local QBCore = exports['qb-core']:GetCoreObject()

-- Create Ped
Citizen.CreateThread(function()
    RequestModel(Config.ped.model)
    while not HasModelLoaded(Config.ped.model) do
        Wait(0)
    end

    local ped = CreatePed(0, Config.ped.model, Config.ped.coords.x, Config.ped.coords.y, Config.ped.coords.z, Config.ped.coords.w, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_CLIPBOARD', true)

    -- Adding target options using ox_target
    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'policegarage',
            icon = 'fas fa-warehouse',
            label = 'Police Garage',
            groups = 'police',
            onSelect = function()
                TriggerEvent('qb-policegarage:client:OpenMenu')
            end
        }
    })
end)

-- Registering the menu with ox_lib
lib.registerContext({
    id = 'policegarage_menu',
    title = 'Police Garage 🚓',
    options = {
        {
            title = 'Ford Crown Victoria',
            event = 'qb-policegarage:client:spawnvehicle',
            args = { vehicle = 'pd1', CopGrade = {0, 1, 2, 3, 4, 5, 6, 7, 8} }
        },
        {
            title = 'Ford Explorer',
            event = 'qb-policegarage:client:spawnvehicle',
            args = { vehicle = 'explorer', CopGrade = {1, 2, 3, 4, 5, 6, 7, 8} }
        },
        {
            title = 'Corvette',
            event = 'qb-policegarage:client:spawnvehicle',
            args = { vehicle = 'zr1rb', CopGrade = {3, 4, 5, 6, 7, 8} }
        },
        {
            title = 'Dodge Charger',
            event = 'qb-policegarage:client:spawnvehicle',
            args = { vehicle = 'char', CopGrade = {3, 4, 5, 6, 7, 8} }
        },
        {
            title = 'Dodge Demon',
            event = 'qb-policegarage:client:spawnvehicle',
            args = { vehicle = 'poldemonrb', CopGrade = {3, 4, 5, 6, 7, 8} }
        }
    }
})

RegisterNetEvent('qb-policegarage:client:OpenMenu', function()
    lib.showContext('policegarage_menu')
end)

RegisterNetEvent('qb-policegarage:client:spawnvehicle', function(dacca)
    local Grades = QBCore.Functions.GetPlayerData().job.grade.level
    local CopGrade = dacca.CopGrade
    local vehicle = dacca.vehicle

    for _, v in ipairs(CopGrade) do
        if Grades == v then
            for _, spawn in ipairs(Config.vehicle.spawns) do
                local isused = QBCore.Functions.SpawnClear(vector3(spawn.x, spawn.y, spawn.z), Config.vehicle.Coordsradius)

                if isused then
                    QBCore.Functions.SpawnVehicle(vehicle, function(veh)
                        local plate = QBCore.Functions.GetPlate(veh)
                        SetEntityHeading(veh, spawn.w)
                        SetVehicleModKit(veh, 0)
                        TriggerEvent("vehiclekeys:client:SetOwner", plate)
                        TriggerServerEvent('qb-policegarage:server:SaveVehicle', plate, vehicle)

                        -- Set fuel to 100
                        Entity(veh).state.fuel = 100

                        -- Place the player in the driver's seat of the vehicle
                        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)

                        -- Teleport the vehicle to the spawn coordinates
                        SetEntityCoords(veh, spawn.x, spawn.y, spawn.z, false, false, false, true)
                        SetEntityHeading(veh, spawn.w)
                    end, vector3(spawn.x, spawn.y, spawn.z), true)
                    return
                end
            end
            lib.notify({title = 'Garage', description = 'No available spawn points.', type = 'error'})
            return
        end
    end

    lib.notify({title = 'Garage', description = 'You do not have the required grade to access this vehicle', type = 'error'})
end)
