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
            image = Config.vehicleImages.pd1,
            event = 'qb-policegarage:client:spawnvehicle',
            args = { vehicle = 'pd1', CopGrade = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9} }
        },
        {
            title = 'Ford Explorer',
            image = Config.vehicleImages.explorer,
            event = 'qb-policegarage:client:spawnvehicle',
            args = { vehicle = 'explorer', CopGrade = {1, 2, 3, 4, 5, 6, 7, 8, 9} }
        },
        {
            title = 'Corvette',
            image = Config.vehicleImages.zr1rb,
            event = 'qb-policegarage:client:spawnvehicle',
            args = { vehicle = 'zr1rb', CopGrade = {5, 6, 7, 8, 9} }
        },
        {
            title = 'Dodge Charger',
            image = Config.vehicleImages.char,
            event = 'qb-policegarage:client:spawnvehicle',
            args = { vehicle = 'char', CopGrade = {2, 3, 4, 5, 6, 7, 8, 9} }
        },
        {
            title = 'Dodge Demon',
            image = Config.vehicleImages.poldemonrb,
            event = 'qb-policegarage:client:spawnvehicle',
            args = { vehicle = 'poldemonrb', CopGrade = {4, 5, 6, 7, 8, 9} }
        },
        {
            title = 'Ford Mustang',
            image = Config.vehicleImages.mach1rb,
            event = 'qb-policegarage:client:spawnvehicle',
            args = { vehicle = 'mach1rb', CopGrade = {4, 5, 6, 7, 8, 9} }
        },
        {
            title = 'Bearcat',
            image = Config.vehicleImages.w_bearcat,
            event = 'qb-policegarage:client:spawnvehicle',
            args = { vehicle = 'w_bearcat', CopGrade = {7, 8, 9} }
        }
    }
})

RegisterNetEvent('qb-policegarage:client:OpenMenu', function()
    lib.showContext('policegarage_menu')
end)

RegisterNetEvent('qb-policegarage:client:spawnvehicle', function(data)
    local Grades = QBCore.Functions.GetPlayerData().job.grade.level
    local CopGrade = data.CopGrade
    local vehicle = data.vehicle

    for _, v in ipairs(CopGrade) do
        if Grades == v then
            local input = lib.inputDialog('Enter License Plate', {
                {type = 'input', label = 'License Plate', description = 'Enter a custom license plate for your vehicle.', required = true, max = 8}
            })

            if not input or not input[1] then
                lib.notify({title = 'Garage', description = 'License plate input canceled.', type = 'error'})
                return
            end

            local customPlate = input[1]

            for _, spawn in ipairs(Config.vehicle.spawns) do
                local isused = QBCore.Functions.SpawnClear(vector3(spawn.x, spawn.y, spawn.z), Config.vehicle.storageRadius)

                if isused then
                    QBCore.Functions.SpawnVehicle(vehicle, function(veh)
                        SetVehicleNumberPlateText(veh, customPlate)
                        SetEntityHeading(veh, spawn.w)
                        SetVehicleModKit(veh, 0)
                        TriggerEvent("vehiclekeys:client:SetOwner", customPlate) --QB GIVE KEYS
                        --exports['Renewed-Vehiclekeys']:addKey(source,customPlate) -- RENEWED GIVE KEYS
                        --exports['Renewed-Vehiclekeys']:addKey(customPlate)

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

local isInStoreZone = false
local isCooldown = false -- Add cooldown flag
local policeVehicles = {
    'pd1',
    'explorer',
    'zr1rb',
    'char',
    'poldemonrb',
    'mach1rb',
    'w_bearcat'
}

-- Function to handle vehicle deletion
local function handleVehicleDeletion()
    if isCooldown then return end -- Exit if cooldown is active

    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local vehicleDeleted = false -- Flag to indicate if the vehicle was deleted

    if vehicle ~= 0 then
        local model = GetEntityModel(vehicle)
        local vehicleName = GetDisplayNameFromVehicleModel(model)

        for _, v in ipairs(policeVehicles) do
            if string.lower(vehicleName) == string.lower(v) then
                DeleteVehicle(vehicle)
                vehicleDeleted = true -- Set flag to true if vehicle is deleted
                lib.notify({title = 'Garage', description = 'Vehicle stored successfully.', type = 'success'})
                isInStoreZone = false
                lib.hideTextUI() -- Hide text UI after vehicle is deleted
                break -- Exit the loop as we've found and deleted the vehicle
            end
        end

        if not vehicleDeleted then
            lib.notify({title = 'Garage', description = 'This is not a police vehicle.', type = 'error'})
        end
    else
        lib.notify({title = 'Garage', description = 'You are not in a vehicle.', type = 'error'})
    end

    -- Only run cooldown and hide TextUI if vehicle was deleted
    if vehicleDeleted then
        lib.hideTextUI()
    end

    -- Activate cooldown
    isCooldown = true
    Citizen.SetTimeout(2000, function() -- Cooldown duration in milliseconds
        isCooldown = false
    end)
end

-- Define the box zone using coordinates from the config
local storeZone = Config.vehicle.storeCoords
local storeZoneSize = vec3(Config.vehicle.storeZoneSize.length, Config.vehicle.storeZoneSize.width, Config.vehicle.storeZoneSize.height)
local storeZoneRotation = Config.vehicle.storeZoneRotation

-- Adding the box zone using ox_lib text UI
CreateThread(function()
    local zone = lib.zones.box({
        coords = storeZone,
        size = storeZoneSize,
        rotation = storeZoneRotation,
        debug = Config.vehicle.debugPoly,
        inside = function()
            isInStoreZone = true
            lib.showTextUI('[E] Store vehicle', {
                position = "right-center",
                icon = "fas fa-warehouse"
            })

            CreateThread(function()
                while isInStoreZone do
                    Wait(0)
                    if IsControlJustReleased(0, 38) then -- E key
                        handleVehicleDeletion()
                    end
                end
            end)
        end,
        onExit = function()
            isInStoreZone = false
            lib.hideTextUI()
        end
    })
end)
