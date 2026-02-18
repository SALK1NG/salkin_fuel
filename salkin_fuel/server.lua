local ESX = exports["es_extended"]:getSharedObject()

-- Tankstellen Abrechnung
RegisterNetEvent('salkin_fuel:payFinal', function(method, amount)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    
    local finalAmount = math.ceil(amount * Config.Fuel.PricePerLiter)

    if method == "cash" then
        if xPlayer.getMoney() >= finalAmount then
            xPlayer.removeMoney(finalAmount)
            xPlayer.showNotification('Du hast $'..finalAmount..' bar bezahlt.', 'success')
        else
            xPlayer.showNotification('Nicht genug Bargeld, die Rechnung wird vom Konto abgebucht.', 'info')
            xPlayer.removeAccountMoney('bank', finalAmount)
        end
    else
        if xPlayer.getAccount('bank').money >= finalAmount then
            xPlayer.removeAccountMoney('bank', finalAmount)
            xPlayer.showNotification('$'..finalAmount..' wurden vom Konto abgebucht.', 'success')
        else
            xPlayer.showNotification('Nicht genug Guthaben auf dem Konto!', 'error')
        end
    end
end)

-- Kanister Kauf/Refill
RegisterNetEvent('salkin_fuel:fuelCan', function(isRefill)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local price = isRefill and Config.Fuel.PetrolCan.refillPrice or Config.Fuel.PetrolCan.price

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        exports.ox_inventory:AddItem(src, 'WEAPON_PETROLCAN', 1)
        xPlayer.showNotification('Vorgang abgeschlossen!', 'success')
    else
        xPlayer.showNotification('Nicht genug Geld!', 'error')
    end
end)