local isInSafeZone = false
local currentSafeZone = nil

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local inSafeZone = false
        local safeZoneData = nil

        for _, zone in pairs(SafeZoneConfig.SafeZones) do
            local distance = #(coords - zone.coord)
            if distance < zone.radius then
                inSafeZone = true
                safeZoneData = zone
            end
        end

        if inSafeZone then
            if not isInSafeZone then
                isInSafeZone = true
                currentSafeZone = safeZoneData

                if currentSafeZone.SpeedLimit > 0 then
                    local vehicle = GetVehiclePedIsIn(ped, false)
                    if vehicle and vehicle ~= 0 then
                        local currentSpeed = GetEntitySpeed(vehicle) * 3.6
                        if currentSpeed > currentSafeZone.SpeedLimit then
                            SetEntityMaxSpeed(vehicle, currentSafeZone.SpeedLimit / 3.6)
                        end
                    end
                end

                if currentSafeZone.VDM then
                    local vehicleList = GetGamePool('CVehicle')
                    for _, vehicle in pairs(vehicleList) do
                        if vehicle ~= 0 then
                            local dist = #(GetEntityCoords(vehicle) - GetEntityCoords(ped))
                            if dist < 5.0 then
                                SetEntityInvincible(vehicle, true)
                                SetEntityCollision(vehicle, false, false)
                            else
                                SetEntityInvincible(vehicle, false)
                                SetEntityCollision(vehicle, true, true)
                            end
                        end
                    end
                end

                if currentSafeZone.Weapons then
                    SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
                end
            end
        else
            if isInSafeZone then
                isInSafeZone = false
                currentSafeZone = nil

                local vehicle = GetVehiclePedIsIn(ped, false)
                if vehicle and vehicle ~= 0 then
                    ResetEntityMaxSpeed(vehicle)
                end

                local vehicleList = GetGamePool('CVehicle')
                for _, vehicle in pairs(vehicleList) do
                    SetEntityInvincible(vehicle, false)
                    SetEntityCollision(vehicle, true, true)
                end

                SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
            end
        end

        Wait(0)
    end
end)
