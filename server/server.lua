ESX = nil
ESX = exports["es_extended"]:getSharedObject()

AddEventHandler('onResourceStart', function(resourceName)
	if (GetResourceState('bixbi_core') ~= 'started' ) then
        print('Bixbi_Target - ERROR: Bixbi_Core hasn\'t been found! This could cause errors!')
    end
end)

RegisterServerEvent('bixbi_target:DragServer')
AddEventHandler('bixbi_target:DragServer', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    if (xPlayer.job.name ~= 'police' and xPlayer.job.name ~= 'ambulance') then return end
    local needsCuff = true
    if (xPlayer.job.name == 'ambulance') then needsCuff = false end
    TriggerClientEvent('bixbi_target:Drag', target, source, needsCuff)
end)

RegisterServerEvent('bixbi_target:PutInVehicleServer')
AddEventHandler('bixbi_target:PutInVehicleServer', function(target, vehicle)
    local xPlayer = ESX.GetPlayerFromId(source)
    if (xPlayer.job.name == 'ambulance' or xPlayer.job.name == 'police') then
        TriggerClientEvent('bixbi_target:PutInVehicle', target, vehicle)
    end
end)

RegisterServerEvent('bixbi_target:PullOutVehicleServer')
AddEventHandler('bixbi_target:PullOutVehicleServer', function(target, vehicle)
    local xPlayer = ESX.GetPlayerFromId(source)
    if (xPlayer.job.name == 'ambulance' or xPlayer.job.name == 'police') then
        TriggerClientEvent('bixbi_target:PullOutVehicle', target, vehicle)
    end
end)