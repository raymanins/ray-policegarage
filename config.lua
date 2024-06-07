Config = Config or {}

Config.ped = {
    coords = vector4(441.4344, -985.2008, 24.6998, 1.6942),
    model = 'csb_trafficwarden'
}

Config.vehicle = {
    storeCoords = vector3(441.3005, -979.7549, 25.6998), -- Coordinates for storing/deleting vehicles
    storeZoneSize = {length = 5, width = 5, height = 5}, -- Size of the store zone
    storeZoneRotation = 90, -- Rotation of the store zone
    storageRadius = 5.0, -- Radius for storing/deleting vehicles
    spawns = {
        vector4(445.4777, -986.0928, 24.6998, 268.6374),
        vector4(445.4777, -988.8925, 24.6998, 269.5454),
        vector4(445.4777, -991.5878, 24.6998, 271.4887),
        vector4(445.4777, -994.3099, 24.6998, 269.0094),
        vector4(445.4777, -996.9233, 24.6998, 250.4536)
    },
    debugPoly = true -- Set to true to see the debug polygons
}

Config.vehicleImages = {
    pd1 = 'https://cdn.discordapp.com/attachments/1235661828470866016/1245331615199006781/LheKlzT.png?ex=6660eeb2&is=665f9d32&hm=0186b13e9a3432932ab8a4f8cc66f407ffa2e04fab175bb50e7c900fda596bd4&',
    explorer = 'images/car.png',
    zr1rb = 'images/car.png',
    char = 'images/car.png',
    poldemonrb = 'images/car.png',
    mach1rb = 'images/car.png',
    w_bearcat = 'images/car.png'
}
