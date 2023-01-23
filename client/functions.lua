RegisterNetEvent('nl_interactions:repairVehicle')
AddEventHandler('nl_interactions:repairVehicle', function(data)
    local itemCount = exports['nl_interactions']:itemCount('repairkit')
    if itemCount ~= 0 then
        local vehicle, distance = ESX.Game.GetClosestVehicle()
        if (vehicle ~= nil and distance < 2.0) then
            TriggerServerEvent('bixbi_core:removeItem', nil, 'repairkit', 1)

            exports['nl_interactions']:Loading(10000, 'Repariere Fahrzeug')
            exports['nl_interactions']:playAnim(PlayerPedId(), 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer', -1, false)
            Citizen.Wait(10000)

            SetVehicleFixed(vehicle)
            SetVehicleDeformationFixed(vehicle)
            SetVehicleUndriveable(vehicle, false)
            notify('success', locale('vahicle_repaired'), 2000)
        end
    end
end)

--[[
RegisterNetEvent('nl_interactions:hospital')
AddEventHandler('nl_interactions:hospital', function(data)
-- [[ CHANGE
    --local dialog = exports['zf_dialog']:DialogInput({
        header = "Send to Hospital", 
        rows = {
            {
                id = 0, 
                txt = "Length (1 = 1 Minute)"
            },
            {
                id = 1, 
                txt = "Location (P = Pillbox, S = Sandy, B = Paleto Bay)"
            },
        }
    })
    if dialog ~= nil then
        if dialog[1].input == nil or dialog[2].input == nil then return end
        TriggerServerEvent('nl_interactions:hospital', GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)), tonumber(dialog[1].input), dialog[2].input)
    end
end)
]]--

RegisterNetEvent('nl_interactions:bandage')
AddEventHandler('nl_interactions:bandage', function(data)
    local playerPed = PlayerPedId()
    local distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(data.entity))
    if (distance > 3.0) then return end
    
    ESX.TriggerServerCallback('nl_interactions:itemCount', function(quantity)
        if quantity > 0 then
            local health = GetEntityHealth(NetworkGetPlayerIndexFromPed(data.entity))

            if health > 0 then
                TriggerEvent('nl_interactions:Loading', 10000, 'Verbinde...')
                TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
                Citizen.Wait(10000)
                ClearPedTasks(playerPed)
				
				-- INSERT HEAL and ITEM
                --TriggerServerEvent('esx_ambulancejob:removeItem', 'bandage')
                --TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)), 'big')
                notify('success', locale('wound_wrapped'), 2000)
            else
                notify('warning', locale('revive_needed'), 2000)
            end
        else
            notify('warning', locale('no_bandages'), 2000)
        end
    end, 'bandage')
end)

--[[
RegisterNetEvent('bixbi_target:Prison')
AddEventHandler('bixbi_target:Prison', function(data)
    local dialog = exports['zf_dialog']:DialogInput({
        header = "Send to Prison", 
        rows = {
            {
                id = 0, 
                txt = "Length (1 = 1 Minute)"
            },
            {
                id = 1, 
                txt = "Reason"
            }
        }
    })
    if dialog ~= nil then
        if dialog[1].input == nil or dialog[2].input == nil then return end
        TriggerServerEvent('bixbi_prison:JailPlayer', GetPlayerServerId(PlayerId()), GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)), dialog[1].input, dialog[2].input)
    end
end)
]]--

local isDragged = false
draggingEntity = nil
RegisterNetEvent('nl_interactions:dragStart')
AddEventHandler('nl_interactions:dragStart', function(data)
    draggingEntity = data.entity
    TriggerServerEvent('nl_interactions:dragServer', GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)))
end)

RegisterNetEvent('nl_interactions:drag')
AddEventHandler('nl_interactions:drag', function(draggerId, needsCuff)
    local playerPed = PlayerPedId()
	
-- [[CHANGE THIS]] --
    --local isHandcuffed = exports['esx_policejob']:IsHandcuffed()
    if (needsCuff) then
        print('')
        while (isHandcuffed == nil) do
            Citizen.Wait(500)
        end
        print('')
    end

    -- Citizen.Wait(500)
    isDragged = not isDragged

    if (needsCuff and not isHandcuffed) then return end
    if (not isDragged) then return end
    local targetPed = GetPlayerPed(GetPlayerFromServerId(draggerId))
    local distance = #(GetEntityCoords(playerPed) - GetEntityCoords(targetPed))
    if (distance > 3.0) then return end

    Citizen.CreateThread(function()
        while (isDragged) do
            if DoesEntityExist(targetPed) and IsPedOnFoot(targetPed) and not IsPedDeadOrDying(targetPed, true) then
                AttachEntityToEntity(playerPed, targetPed, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            else
                isDragged = false
            end
            Citizen.Wait(1000)
        end
        DetachEntity(playerPed, true, false)
    end)
end)

RegisterNetEvent('nl_interactions:putInVehicleStart')
AddEventHandler('nl_interactions:putInVehicleStart', function(data)
    local distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(draggingEntity))
    if (draggingEntity == nil or distance > 2.0) then
-- [[CHANGE THIS]] --
        notify('error', 'You\'re not dragging anyone.')
        draggingEntity = nil
        return
    end

    local netID = NetworkGetNetworkIdFromEntity(data.entity)
    SetNetworkIdExistsOnAllMachines(netID, true)
    TriggerServerEvent('nl_interactions:putInVehicleServer', GetPlayerServerId(NetworkGetPlayerIndexFromPed(draggingEntity)), netID)
    draggingEntity = nil
end)

RegisterNetEvent('nl_interactions:putInVehicle')
AddEventHandler('nl_interactions:putInVehicle', function(vehicleId)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleId)
    if (IsEntityAVehicle(vehicle)) then
        local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)
        for i=maxSeats - 1, 0, -1 do
            if IsVehicleSeatFree(vehicle, i) then
                freeSeat = i
                break
            end
        end

        if freeSeat then
            TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, freeSeat)
            isDragged = false
        end
    end
end)

RegisterNetEvent('nl_interactions:pullOutVehicleStart')
AddEventHandler('nl_interactions:pullOutVehicleStart', function(data)
    if (IsEntityAVehicle(data.entity)) then
        local netID = NetworkGetNetworkIdFromEntity(data.entity)
        SetNetworkIdExistsOnAllMachines(netID, true)

        for i = 6, 1, -1 do
            local ped = GetPedInVehicleSeat(data.entity, i - 2)
            if (ped ~= 0) then
                local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))
                TriggerServerEvent('nl_interactions:pullOutVehicleServer', playerId, netID)
            end
        end
    end
end)

RegisterNetEvent('nl_interactions:pullOutVehicle')
AddEventHandler('nl_interactions:pullOutVehicle', function(vehicleId)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleId)
    if (IsEntityAVehicle(vehicle)) then
        TaskLeaveVehicle(PlayerPedId(), vehicle, 0)
    end
end)

RegisterNetEvent('nl_interactions:forceOpen')
AddEventHandler('nl_interactions:forceOpen', function(data)
    if GetVehicleDoorLockStatus(data.entity) == 1 or GetVehicleDoorLockStatus(data.entity) == 0 then
-- [[CHANGE THIS]] --
        notify('error', 'Fahrzeug ist nicht verschlossen')
        return
    end
    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
-- [[CHANGE THIS]] --
    loading(20000, 'Knacke Fahrzeug...')
    Citizen.Wait(20000)
    ClearPedTasksImmediately(playerPed)
	TriggerEvent('renzu_garage:lockpick')
-- [[CHANGE THIS]] --
    notify('', 'Fahrzeug geöffnet')
end)

RegisterNetEvent('nl_interactions:lockpick')
AddEventHandler('nl_interactions:lockpick', function(data)
    if GetVehicleDoorLockStatus(data.entity) == 1 or GetVehicleDoorLockStatus(data.entity) == 0 then
-- [[CHANGE THIS]] --
        notify('error', 'Fahrzeug ist nicht verschlossen')
        return
    end

    local itemCount = exports['bixbi_core']:itemCount('lockpick')
    while (itemCount == nil) do
        Citizen.Wait(100)
    end
    if (itemCount == 0) then
-- [[CHANGE THIS]] --
        notify('error', 'Du benötigst einen Dietrich')
        return 
    end

    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
    TriggerServerEvent('nl_interactions:removeItem', nil, 'lockpick', 1)
-- [[CHANGE THIS]] --
    loading(20000, 'Knacke Fahrzeug...')
    Citizen.Wait(20000)
    ClearPedTasksImmediately(playerPed)

    math.randomseed(GetGameTimer())
    local random = math.random(1, 3)
    if (random == 1) then
-- [[CHANGE THIS]] --
        notify('error', 'Du hast beim Knacken versagt...')
    else
        SetVehicleDoorsLocked(data.entity, 1)
        SetVehicleDoorsLockedForAllPlayers(data.entity, false)
        notify('info', 'Fahrzeug geöffnet')
    end
end)

RegisterNetEvent('nl_interactions:CleanVehicle')
AddEventHandler('nl_interactions:CleanVehicle', function(data)
    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_MAID_CLEAN', 0, true)
-- [[CHANGE THIS]] --
    loading(10000, 'Reinige Fahrzeug...')
    Citizen.Wait(10000)

    ClearPedTasksImmediately(playerPed)
    SetVehicleDirtLevel(data.entity, 0)
	
-- [[CHANGE THIS]] --
    notify('info', 'Fahrzeug gesäubert')
end)

RegisterNetEvent('nl_interactions:EscortToggle')
AddEventHandler('nl_interactions:EscortToggle', function(data)
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 2.0 then
        TriggerServerEvent('nl_interactions:DragServer', GetPlayerServerId(closestPlayer))
    end
end)

function RevivePlayer(closestPlayer)
    local closestPlayerPed = GetPlayerPed(closestPlayer)
    if closestPlayer ~= nil and closestPlayer > 0 and IsPedDeadOrDying(closestPlayerPed, true) then
        local playerPed = PlayerPedId()
        local lib, anim = 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest'
		
-- [[CHANGE THIS]] --        
        notify('alert', 'Réanimation en cours ...', 8000, 'ems')
        for i=1, 15 do
            Citizen.Wait(900)

            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0.0, false, false, false)
            end)
        end

        -- On enlève les trace de sangs / blessures visuelles
        ClearPedBloodDamage(closestPlayerPed)
        ResetPedVisibleDamage(closestPlayerPed)

        for i = 0, 5 do
            ClearPedDamageDecalByZone(closestPlayerPed, i, "ALL")
            Wait(1)
        end

        
        -- On le Réanime
        TriggerServerEvent('nl_interactions:reviveems', GetPlayerServerId(closestPlayer))
    else
-- [[CHANGE THIS]] --
		notify('info', 'Kein Bürger gefunden')
    end
end

function PulseState(Ped, Message)
    local PedPlayer = GetPlayerPed(Ped)
    local HealthPlayer = GetEntityHealth(PedPlayer)
    local Pulse = 0 

    if HealthPlayer > 0 then
        Pulse = (HealthPlayer / 4 + math.random(19,28))
    else 
        Pulse = 0
    end

    if Pulse ~= nil then 
        if Pulse >= 0 then 
            if Pulse == 0 then 
                Pulse = math.random(5,15)
            end
            if Pulse < 30 then 
-- [[CHANGE THIS]] --
                notify('error', 'Pouls faible Total : ' .. Pulse, 8000, 'Puls')
            elseif Pulse > 30 and Pulse < 60 then 
-- [[CHANGE THIS]] --
                notify('warning', 'Pouls moyen Total : ' .. Pulse, 8000, 'Puls')
            elseif Pulse > 60 and Pulse < 80 then 
-- [[CHANGE THIS]] --
                notify('success', 'Pouls normal Total : ' .. Pulse, 8000, 'Puls')
            elseif Pulse > 80 then 
-- [[CHANGE THIS]] --
                notify('error', 'Pouls élevé Total : ' .. Pulse, 8000, 'Puls')
            end
        end
    end
    if Message ~= nil then
        Wait(1500)
-- [[CHANGE THIS]] --
        notify('warning', Message, 8000, 'Etat Visuel')
    else
-- [[CHANGE THIS]] --
        notify('warning', 'Aucun Signe visuel de blessures', 8000, 'Etat Visuel')
    end
end


function WeaponHashEqualCauseOfDeath(hashWeapon)
    local result = nil
    for k,v in pairs(Config.WeaponList) do 
        if hashWeapon == v then 
            result = k
            break
        end
    end

    if result ~= nil then 
        if string.find(result, "balle9mm") then 
-- [[CHANGE THIS]] --
            --return "9MM"
        elseif string.find(result, "balle50acp") then
-- [[CHANGE THIS]] --
            --return "50ACP"
        elseif string.find(result, "balle44") then
-- [[CHANGE THIS]] --
            --return "44MM"
        elseif string.find(result, "balle45acp") then
-- [[CHANGE THIS]] --
            --return "45ACP"
        elseif string.find(result, "balle556") then
-- [[CHANGE THIS]] --
            --return "5.56MM"
        elseif string.find(result, "balle12G") then
-- [[CHANGE THIS]] --
            --return "12G"
        elseif string.find(result, "balleplomb") then
-- [[CHANGE THIS]] --
            --return "Plomb"
        elseif string.find(result, "griffe") then
-- [[CHANGE THIS]] --
            --return "Griffes et Bleu - Armes Blanches"
        elseif string.find(result, "coupure") then
-- [[CHANGE THIS]] --
            --return "Coupure - Armes Blanches"
        elseif string.find(result, "bleu") then
-- [[CHANGE THIS]] --
            --return "Gros Ematome et Bleu - Armes Blanches"
        elseif string.find(result, "brulure") then
-- [[CHANGE THIS]] --
            --return "Brulure"
        elseif string.find(result, "balle762") then
-- [[CHANGE THIS]] --
            --return "7.62MM"
        elseif string.find(result, "balle762NATO") then
-- [[CHANGE THIS]] --
            --return "7.62MM NATO"
        elseif string.find(result, "poing") then 
-- [[CHANGE THIS]] --
            --return "Mains nues"
        else 
-- [[CHANGE THIS]] --
            --return "Inconnu"
        end
    else 
-- [[CHANGE THIS]] --
        --return "Inconnu"
    end
    
end

function RevivePlayer(closestPlayer)
    local closestPlayerPed = GetPlayerPed(closestPlayer)
    if closestPlayer ~= nil and closestPlayer > 0 and IsPedDeadOrDying(closestPlayerPed, true) then
        local playerPed = PlayerPedId()
        local lib, anim = 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest'
-- [[CHANGE THIS]] --
        notify('info', 'Réanimation en cours ...', 8000, 'Reanimation')
        for i=1, 15 do
            Citizen.Wait(900)

            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0.0, false, false, false)
            end)
        end

        -- On enlève les trace de sangs / blessures visuelles
        ClearPedBloodDamage(closestPlayerPed)
        ResetPedVisibleDamage(closestPlayerPed)

        for i = 0, 5 do
            ClearPedDamageDecalByZone(closestPlayerPed, i, "ALL")
            Wait(1)
        end

        
        -- On le Réanime
        TriggerServerEvent('nl_interactions:revive', GetPlayerServerId(closestPlayer))
    else
        notify('warning', locale('revive_not_needed'), 8000, 'EMS')
    end
end

function Respawn()
    SetDisplay(false, false)
	
	SetEntityCoordsNoOffset(PlayerPedId(), globalState.respawnCoords.x, globalState.respawnCoords.y, globalState.respawnCoords.z, false, false, false, true)
    NetworkResurrectLocalPlayer(globalState.respawnCoords.x, globalState.respawnCoords.y, globalState.respawnCoords.z, globalState.respawnHeading, true, false)
	
	SetPlayerInvincible(PlayerPedId(), false)
	
	TriggerServerEvent('esx:onPlayerSpawn')
	TriggerEvent('esx:onPlayerSpawn')
    TriggerEvent('playerSpawned', GlobalState.RespawnCoords.x, GlobalState.RespawnCoords.y, GlobalState.RespawnCoords.z)
	ClearPedBloodDamage(PlayerPedId())
    IsDead = false
    IsBleeding = false
end

function RespawnPed(ped, coords, heading)
    TriggerServerEvent('nl_interactions:setDeathStatus', false)
	
    SetDisplay(false, false)
	
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
	SetPlayerInvincible(ped, false)
	
	TriggerServerEvent('esx:onPlayerSpawn')
	TriggerEvent('esx:onPlayerSpawn')
    TriggerEvent('playerSpawned', coords.x, coords.y, coords.z)
	
	ClearPedBloodDamage(ped)
    IsDead = false
    IsBleeding = false
end

--[[
function RespawnPed(ped, coords, heading)
  SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
  NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
  SetPlayerInvincible(ped, false)
  ClearPedBloodDamage(ped)

  TriggerServerEvent('esx:onPlayerSpawn')
  TriggerEvent('esx:onPlayerSpawn')
  TriggerEvent('playerSpawned') -- compatibility with old scripts, will be removed soon
end
]]--


function ResetSonnette()
    FirstName = nil 
    LastName = nil
    Subject = nil
    Desc = nil
    Tel = nil
    CanSend = false
end

function InputGestionComptePatron()
    local input = lib.inputDialog(locale('account_management'), {locale('ammount')})
	
    if not input then return end
    local quantity = tonumber(input[1])
    if quantity ~= nil and quantity > 0 then 
        return quantity
    else
        notify('error', locale('account_not'), 5000, locale('account_management'))
    end
end

function ClosePlayerForGestionEmployees()
    local PlayerCoords = GetEntityCoords(PlayerPedId())
    local ClosePlayer = lib.getClosestPlayer(PlayerCoords, 5, false)
    return ClosePlayer
end

function loadAnimDict(dict)
    RequestAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do        
        Citizen.Wait(1)
    end
end

function text(text)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(0.5, 0.5)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextOutline()
	SetTextJustification(0)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.5, 0.9, 0.5, 0.5, 0.4, 255, 255, 255, 255)
end

function notify(type, msg, duration, title)
	if (duration == nil) then duration = 1000 end
	if (title == nil) then title = '' end
	lib.defaultNotify({
		title = title,
		description = msg,
		position = 'top',
		duration = duration,
		status = type
	})
end
exports('notify', notify)

RegisterNetEvent('nl_interactions:notify')
AddEventHandler('nl_interactions:notify', function(type, msg, duration, title)
	notify(type, msg, duration, title)
end) 

function loading(time, text)
	if lib.progressBar({
		duration = time,
		label = text,
		disable = {
			move = false,
			car = false,
			combat = false,
			mouse = false,
		},
	}) then print('okay') else print('fail') end
end
exports('loading', loading)

RegisterNetEvent('nl_interactions:loading')
AddEventHandler('nl_interactions:loading', function(time, text)
	loading(time, text)
end) 

function playAnim(ped, animDict, animName, duration, emoteMoving, playbackRate)
	local movingType = 49
	if (emoteMoving == true) then 
		movingType = 49
	elseif (emoteMoving == false) then
		movingType = 0
	end
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Citizen.Wait(100) end

	local playbackSpeed = playbackRate or 0
    -- TaskPlayAnim(ped, animDict, animName, 1.0, -1.0, duration, movingType, 1, false, false, false)
	TaskPlayAnim(ped, animDict, animName, 2.0, 2.0, duration, movingType, playbackSpeed, false, false, false)
    RemoveAnimDict(animDict)
end

function addProp(ped, prop1, bone, off1, off2, off3, rot1, rot2, rot3, timer)
	local x,y,z = table.unpack(GetEntityCoords(ped))
	if not HasModelLoaded(prop1) then LoadPropDict(prop1) end
  
	prop = CreateObject(GetHashKey(prop1), x, y, z+0.2,  true,  true, true)
	AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, bone), off1, off2, off3, rot1, rot2, rot3, true, true, false, true, 1, true)
	SetModelAsNoLongerNeeded(prop1)
	Citizen.Wait(timer)
	DeleteEntity(prop)
end

function itemCount(item, metadata)
	return exports.ox_inventory:Search(1, item, metadata)
end
exports('itemCount', itemCount)

AddEventHandler('nl_interactions:itemCount', function(item, metadata)
	return itemCount(item, metadata)
end)

RegisterNetEvent('nl_interactions:useCommand')
AddEventHandler('nl_interactions:useCommand', function(cmd)
	ExecuteCommand(cmd)
end)
