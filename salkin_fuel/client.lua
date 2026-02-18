local ESX = exports["es_extended"]:getSharedObject()
local isFueling = false
local currentVehicle = nil
local chosenMethod = nil
local addedLiters = 0

-- Animation Funktion
local function playFuelingAnim()
    local ped = PlayerPedId()
    local animDict = "timetable@gardener@filling_can"
    local animName = "gar_ig_5_filling_can"
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(10) end
    TaskPlayAnim(ped, animDict, animName, 8.0, 1.0, -1, 49, 0, 0, 0, 0)
end

-- ox_target: Zwei Optionen (Tanken & Kanister)
Citizen.CreateThread(function()
    exports.ox_target:addModel({'prop_gas_pump_1d', 'prop_gas_pump_1a', 'prop_gas_pump_1b', 'prop_gas_pump_1c', 'prop_vintage_pump'}, {
        {
            name = 'fuel_ui',
            label = 'Fahrzeug tanken',
            icon = 'fas fa-gas-pump',
            onSelect = function() openGasMenu() end
        },
        {
            name = 'fuel_can',
            label = 'Kanister kaufen/füllen',
            icon = 'fas fa-fill-drip',
            onSelect = function(data) buyOrRefillCan(data.coords) end
        }
    })
end)

-- Tasten-Sperre (TAB & Angriff deaktiviert beim Tanken)
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        if IsNuiFocused() or isFueling then
            sleep = 0
            DisableControlAction(0, 37, true) -- TAB
            DisableControlAction(0, 24, true) -- Angriff
        end
        Wait(sleep)
    end
end)

-- Kanister Logik
function buyOrRefillCan(coords)
    local ped = PlayerPedId()
    local hasCan = exports.ox_inventory:GetItemCount('WEAPON_PETROLCAN') > 0

    if lib.progressCircle({
        duration = Config.Fuel.PetrolCan.duration,
        label = hasCan and 'Kanister auffüllen...' or 'Kanister kaufen...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = 'timetable@gardener@filling_can', clip = 'gar_ig_5_filling_can', flags = 49 }
    }) then
        TriggerServerEvent('salkin_fuel:fuelCan', hasCan)
    else
        ESX.ShowNotification('Abgebrochen!', 'error')
    end
    ClearPedTasks(ped)
end

-- Fahrzeug UI Logik
function openGasMenu()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        ESX.ShowNotification('Steig aus dem Auto aus!', 'error')
        return 
    end

    local vehicle = lib.getClosestVehicle(GetEntityCoords(ped), 5.0, false)
    if vehicle and vehicle ~= 0 then
        currentVehicle = vehicle
        addedLiters = 0
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "open",
            price = Config.Fuel.PricePerLiter,
            currentFuel = GetVehicleFuelLevel(vehicle)
        })
    else
        ESX.ShowNotification('Kein Fahrzeug in der Nähe gefunden!', 'error')
    end
end

RegisterNUICallback('startWithMethod', function(data, cb)
    chosenMethod = data.method
    isFueling = true
    playFuelingAnim()

    CreateThread(function()
        while isFueling do
            Wait(250)
            if not isFueling then break end
            if currentVehicle and DoesEntityExist(currentVehicle) then
                local fuel = GetVehicleFuelLevel(currentVehicle)
                if fuel < 99.8 then
                    local increment = 0.5
                    addedLiters = addedLiters + increment
                    SetVehicleFuelLevel(currentVehicle, fuel + increment)
                    SendNUIMessage({ type = "update", fuel = fuel + increment, added = addedLiters })
                else
                    isFueling = false
                    ClearPedTasks(PlayerPedId())
                    ESX.ShowNotification('Vollgetankt!', 'success')
                    break
                end
            else
                isFueling = false
                break
            end
        end
    end)
    cb('ok')
end)

RegisterNUICallback('closeAndPay', function(data, cb)
    isFueling = false
    SetNuiFocus(false, false)
    ClearPedTasks(PlayerPedId())
    if addedLiters > 0 and chosenMethod ~= nil then
        TriggerServerEvent('salkin_fuel:payFinal', chosenMethod, addedLiters)
    end
    addedLiters = 0
    currentVehicle = nil
    cb('ok')
end)