--[[ Loading the ox_lib locales ]]--
lib.locale()

--[[ Define locals ]]--
local IsDead = false
local StatusReload = false
local IsBleeding = false
local secondsRemaining = config.bleedoutTimer

local TimerDeath = 0
local TimerDeathMax = globalState.timer * 1000 * 60
local TimerAddedPerTick = 1000
local ems = AddBlipForCoord(config.blipsHospital.position.x, config.blipsHospital.position.y, config.blipsHospital.position.z)

--[[ Load ESX ]]--
ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    while (ESX == nil) do Citizen.Wait(100) end
    PlayerData = xPlayer
    --FreezeEntityPosition(PlayerPedId(), false)
end)

AddEventHandler('esx:onPlayerSpawn', function()
    local playerPed = PlayerPedId()
    if GetEntityHealth(playerPed) ~=  200 then
        SetEntityMaxHealth(playerPed, 200)
        SetEntityHealth(playerPed, 200)
    end
	FreezeEntityPosition(PlayerPedId(), false)
end)

Citizen.CreateThread(function()
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
    if ESX.IsPlayerLoaded() then
        ESX.PlayerData = ESX.GetPlayerData()
    end

    Wait(1000)

    ESX.TriggerServerCallback('nl_interactions:getDeathStatus', function(isDead)
        if isDead  then
            IsDead = true
        else
            IsDead = false
        end
    end)

    SetBlipSprite(ems, config.blipsHospital.sprite)
    SetBlipDisplay(ems, config.blipsHospital.display)
    SetBlipScale(ems, config.blipsHospital.scale)
    SetBlipColour(ems, config.blipsHospital.colour)
    SetBlipAsShortRange(ems, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(config.blipsHospital.title)
    EndTextCommandSetBlipName(ems)
    RequestModel(config.pedModelPharma)

    while (not HasModelLoaded(config.pedModelPharma)) do
        Wait(1)
    end

    local PharmaShop = CreatePed(1, config.pedModelPharma, config.shopPharmacieCoords.x, config.shopPharmacieCoords.y, config.shopPharmacieCoords.z, config.shopPharmacieCoords.w, false, true)
    SetEntityInvincible(PharmaShop, true)
    SetBlockingOfNonTemporaryEvents(PharmaShop, true)
    FreezeEntityPosition(PharmaShop, true)
end)

--[[ Death screen ]]--
function SetDisplay(bool)
    SendNUIMessage({
        type = "show",
        status = bool,
        time = globalState.timer,
    })

    SendNUIMessage({action = 'starttimer', value = globalState.timer})
    SendNUIMessage({action = 'showbutton'})
    SetNuiFocus(bool, bool)
end

-- [[ Overwrite esx on player death functino ]]--
AddEventHandler('esx:onPlayerDeath', function(data)
    if not IsBleeding then
        IsBleeding = true
        if GetEntityHealth(PlayerPedId()) <= 105 then
            local WeaponKiller = GetPedCauseOfDeath(PlayerPedId())
            local WeapKoIs = false
			--[[
            for k,v in pairs(config.ceapKo) do
                if WeaponKiller == joaat(v) then
                    WeapKoIs = true
                end
            end
			]]--

            if WeapKoIs and IsBleeding then
                IsBleeding = true
                SetEnableHandcuffs(ped, true)
                -- exports.spawnmanager:setAutoSpawn(false)
                -- loadAnimDict( "random@dealgonewrong" )
                -- TaskPlayAnim(PlayerPedId(), "random@dealgonewrong", "idle_a", 1.0, 1.0, -1, 1, 0, 0, 0, 0)
                if secondsRemaining == 0 then
                    secondsRemaining = config.bleedoutTimer
                end
                --  print(secondsRemaining)
                while IsBleeding do
                    text(locale('revive_msg', secondsRemaining))
                    Wait(0)
                    if secondsRemaining == 0 then
                        IsBleeding = false
                        RespawnPed(PlayerPedId(), GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()))
                        secondsRemaining = config.bleedoutTimer
                    end
                end

            else
                SetDisplay(true)
                IsDead = true
                StatusReload = true
                TriggerServerEvent('nl_interactions:setDeathStatus', true)

                while TimerDeath < TimerDeathMax do
                    Wait(TimerAddedPerTick)
                    if IsDead then
                        ClearPedTasks(PlayerPedId())
                        TimerDeath = TimerDeath + TimerAddedPerTick
                    else
                        TimerDeath = 0
                        break
                    end
                end
                TimerDeath = 0

                -- Wait(globalState.timer * 60 * 1000)

                if IsDead then
                    Respawn()
                    IsDead = false
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        if IsPedDeadOrDying(PlayerPedId()) then
            Wait(1000)
            if secondsRemaining > 0 and IsBleeding then
                secondsRemaining = secondsRemaining -1
            end
        else
            Wait(1000)
        end

    end
end)

CreateThread(function()
    while true do
        if IsPedDeadOrDying(PlayerPedId()) then
            if IsPedDeadOrDying(PlayerPedId()) and IsDead then
                ClearPedTasksImmediately(PlayerPedId())
                FreezeEntityPosition(PlayerPedId(), true)
            end
        end
        Wait(30000)
    end
end)

AddEventHandler('playerSpawned', function(spawn)
    ESX.TriggerServerCallback('nl_interactions:getDeathStatus', function(isDead)

            if isDead and IsDead then
                SetDisplay(true)
                Wait(5000)
                SetEntityHealth(ESX.PlayerData.ped, 0)
            else
                if StatusReload then
                    TriggerEvent("esx_status:set", "hunger", 1000000)
                    TriggerEvent("esx_status:set", "thirst", 1000000)
					if config.useRenzuHud then
						TriggerEvent("esx_status:set", "stress",  200000)
						TriggerEvent("esx_status:set", "energy", 1000000)
						TriggerEvent("esx_status:set", "pee", 1000000)
						TriggerEvent("esx_status:set", "poop", 1000000)
						TriggerEvent("esx_status:set", "hygiene", 1000000)
						
						TriggerEvent("esx_status:set", "fever", 0)
					end
                end
                SetDisplay(false)
                StatusReload = false
                IsDead = false
                if IsDead then
                    IsDead = false
                end

                TriggerServerEvent('nl_interactions:setDeathStatus', false)

                local playerPed = PlayerPedId()

                FreezeEntityPosition(playerPed, false)
                ClearPedTasks(playerPed)
                ClearPedSecondaryTask(playerPed)
                ClearAllPedProps(playerPed)

                EnableControlAction(0, 288, true)
                EnableControlAction(0, 289, true)
            end

    end)
end)

RegisterNUICallback("button", function(data)
    SendNUIMessage({action = 'hidebutton'})
    TriggerServerEvent('nl_interactions:sendDistressEms')
    SetNuiFocus(false, false)
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

--[[ Revive function ]]--
RegisterNetEvent('nl_interactions:revive')
AddEventHandler('nl_interactions:revive', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    TriggerServerEvent('nl_interactions:setDeathStatus', false)
	TriggerEvent('esx:onPlayerSpawn')

    DoScreenFadeOut(800)

    while not IsScreenFadedOut() do
        Citizen.Wait(50)
    end

    local formattedCoords = {
        x = ESX.Math.Round(coords.x, 1),
        y = ESX.Math.Round(coords.y, 1),
        z = ESX.Math.Round(coords.z, 1)
    }

    RespawnPed(playerPed, formattedCoords, 0.0)
    IsBleeding = false
    StopScreenEffect('DeathFailOut')
    DoScreenFadeIn(800)

    ClearPedBloodDamage(PlayerPedId())
    ResetPedVisibleDamage(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)

    for i = 0, 5 do
        ClearPedDamageDecalByZone(PlayerPedId(), i, "ALL")
        Wait(1)
    end
	notify('success', locale('revive_success'), 5000, 'EMS')
end)

AddEventHandler('nl_interactions:ems_interaction_bed_client', function (data)

        if DoesEntityExist(data.entity) then
            local entityPos = GetEntityCoords(data.entity)
            local entityHeading = GetEntityHeading(data.entity)
            local newEntyPosY = entityPos.y
            local newEntyPosZ = entityPos.z
            local newEntyPosX = entityPos.x

            if data.typeLit == "big" then
                entityHeading = entityHeading + 180.0
                newEntyPosY = entityPos.y
            end
            if data.typeLit == "little" then
                entityHeading = entityHeading + 90.0
                newEntyPosY = entityPos.y
            end
            if data.typeLit == "morgue" then
                entityHeading = entityHeading + 180.0
                newEntyPosY = entityPos.y - 0.40
            end
            if data.typeLit == "morguelittle" then
                entityHeading = entityHeading
                newEntyPosY = entityPos.y + 0.10
                newEntyPosZ = entityPos.z + 0.60
            end
            if data.typeLit == "echo" then
                entityHeading = entityHeading + 90.0
                newEntyPosY = entityPos.y + 0.15
                newEntyPosX = entityPos.x + 0.15
            end

            SetEntityHeading(cache.ped, entityHeading)
            SetEntityCoords(cache.ped, newEntyPosX, newEntyPosY, newEntyPosZ, true, false, false, false)
            LoadAnim("anim@gangops@morgue@table@")
            --TaskPlayAnim(cache.ped, "anim@gangops@morgue@table@", "body_search", 8.0, 8.0, -1, 1, 0, false, false, false)

            local EmoteData = {
                Label = 'Passout 3',
                Command = 'passout3',
                Animation = 'body_search',
                Dictionary = 'anim@gangops@morgue@table@',
                Options = {
                    Flags = {
                        Loop = true
                    },
                }
            }
-- [[ CHANGE ]] --
            --exports.scully_emotemenu:Play(EmoteData, EmoteData.Variant)
			notify('warning', locale('leave_bed'), 8000, locale('bed'))
        else
			notify('error', locale('try_again'), 8000, locale('bed'))
        end
end)

AddEventHandler('nl_interactions:ems_interaction_bed_client_echo', function (data)
    --print(json.encode(data, {indent=true}))

    if DoesEntityExist(data.entity) then
        local entityPos = GetEntityCoords(data.entity)
        local entityHeading = GetEntityHeading(data.entity)
        local newEntyPosY = entityPos.y
        local newEntyPosZ = entityPos.z
        local newEntyPosX = entityPos.x
        local newEntyPosHeading = entityHeading + 180.0

        SetEntityHeading(cache.ped, newEntyPosHeading)
        SetEntityCoords(cache.ped, newEntyPosX, newEntyPosY, newEntyPosZ, true, false, false, false)
        LoadAnim("anim@gangops@morgue@table@")
        local EmoteData = {
            Label = 'Passout 3',
            Command = 'passout3',
            Animation = 'body_search',
            Dictionary = 'anim@gangops@morgue@table@',
            Options = {
                Flags = {
                    Loop = true
                },
            }
        }

        exports.scully_emotemenu:Play(EmoteData, EmoteData.Variant)
		notify('warning', locale('leave_bed'), 8000, locale('bed'))
    else
		notify('error', locale('try_again'), 8000, locale('bed'))
    end
end)

AddEventHandler('nl_interactions:ems_interaction_bed_client_ope_one', function (data)
    --print(json.encode(data, {indent=true}))

    if DoesEntityExist(data.entity) then
        local entityPos = GetEntityCoords(data.entity)
        local entityHeading = GetEntityHeading(data.entity)
        local newEntyPosY = entityPos.y
        local newEntyPosZ = entityPos.z
        local newEntyPosX = entityPos.x
        local newEntyPosHeading = entityHeading + 90.0

        SetEntityHeading(cache.ped, newEntyPosHeading)
        SetEntityCoords(cache.ped, newEntyPosX, newEntyPosY, newEntyPosZ, true, false, false, false)
        LoadAnim("anim@gangops@morgue@table@")
        local EmoteData = {
            Label = 'Passout 3',
            Command = 'passout3',
            Animation = 'body_search',
            Dictionary = 'anim@gangops@morgue@table@',
            Options = {
                Flags = {
                    Loop = true
                },
            }
        }

        exports.scully_emotemenu:Play(EmoteData, EmoteData.Variant)
        notify('warning', locale('leave_bed'), 8000, locale('bed'))
    else
		notify('error', locale('try_again'), 8000, locale('bed'))
    end
end)

AddEventHandler('nl_interactions:ems_interaction_bed_client_ope_two', function (data)
    --print(json.encode(data, {indent=true}))

    if DoesEntityExist(data.entity) then
        local entityPos = GetEntityCoords(data.entity)
        local entityHeading = GetEntityHeading(data.entity)
        local newEntyPosY = entityPos.y
        local newEntyPosZ = entityPos.z
        local newEntyPosX = entityPos.x
        local newEntyPosHeading = entityHeading + 90.0

        SetEntityHeading(cache.ped, newEntyPosHeading)
        SetEntityCoords(cache.ped, newEntyPosX, newEntyPosY, newEntyPosZ, true, false, false, false)
        LoadAnim("anim@gangops@morgue@table@")
        local EmoteData = {
            Label = 'Passout 3',
            Command = 'passout3',
            Animation = 'body_search',
            Dictionary = 'anim@gangops@morgue@table@',
            Options = {
                Flags = {
                    Loop = true
                },
            }
        }

        exports.scully_emotemenu:Play(EmoteData, EmoteData.Variant)
        notify('warning', locale('leave_bed'), 8000, locale('bed'))
    else
		notify('error', locale('try_again'), 8000, locale('bed'))
    end
end)

AddEventHandler('nl_interactions:ems_interaction_bed_client_oscu_one', function (data)
    --print(json.encode(data, {indent=true}))

    if DoesEntityExist(data.entity) then
        local entityPos = GetEntityCoords(data.entity)
        local entityHeading = GetEntityHeading(data.entity)
        local newEntyPosY = entityPos.y
        local newEntyPosZ = entityPos.z
        local newEntyPosX = entityPos.x
        local newEntyPosHeading = entityHeading + 90.0

        SetEntityHeading(cache.ped, newEntyPosHeading)
        SetEntityCoords(cache.ped, newEntyPosX, newEntyPosY, newEntyPosZ, true, false, false, false)
        LoadAnim("anim@gangops@morgue@table@")
        local EmoteData = {
            Label = 'Passout 3',
            Command = 'passout3',
            Animation = 'body_search',
            Dictionary = 'anim@gangops@morgue@table@',
            Options = {
                Flags = {
                    Loop = true
                },
            }
        }

        exports.scully_emotemenu:Play(EmoteData, EmoteData.Variant)
        notify('warning', locale('leave_bed'), 8000, locale('bed'))
    else
		notify('error', locale('try_again'), 8000, locale('bed'))
    end
end)

local OptionsInteractionBed = {
    {
        name = 'ems_interaction_bed_big',
        event = 'nl_interactions:ems_interaction_bed_client',
        icon = 'fas fa-bed',
        label = 'Intéraction lit',
        typeLit = "big",
        canInteract = function(entity, distance, coords, name)

            if distance < 2 then
                return true
            end
            return false
        end
    }
}

local OptionsInteractionBedLittle = {
    {
        name = 'ems_interaction_bed_little',
        event = 'nl_interactions:ems_interaction_bed_client',
        icon = 'fas fa-bed',
        label = 'Intéraction lit',
        typeLit = "little",
        canInteract = function(entity, distance, coords, name)

            if distance < 2 then
                return true
            end
            return false
        end
    }
}


local OptionsInteractionMorgue = {
    {
        name = 'ems_interaction_bed_morgue',
        event = 'nl_interactions:ems_interaction_bed_client',
        icon = 'fas fa-bed',
        label = 'Intéraction Lit',
        typeLit = "morgue",
        canInteract = function(entity, distance, coords, name)
            if distance < 2 then
                return true
            end
            return false
        end
    }
}

local OptionsInteractionLittleMorgue = {
    {
        name = 'ems_interaction_bed_morgue_little',
        event = 'nl_interactions:ems_interaction_bed_client',
        icon = 'fas fa-bed',
        label = 'Intéraction Lit',
        typeLit = "morguelittle",
        canInteract = function(entity, distance, coords, name)
            if distance < 2 then
                return true
            end
            return false
        end
    }
}

local OptionsInteractionEcho = {
    coords = vec3(-661.3483, 335.9867, 88.0),
    size = vec3(1, 2, 1),
    rotation = 351,
    debug = false,
    options = {
        {
            name = 'ems_interaction_bed_echo',
            event = 'nl_interactions:ems_interaction_bed_client_echo',
            icon = 'fas fa-bed',
            label = 'Intéraction Lit',
            canInteract = function(entity, distance, coords, name)
                if distance < 2 then
                    return true
                end
                return false
            end
        }
    }
}


local OptionsInteractionOpeOne = {
    coords = vec3(-648.4824, 326.5388, 88.2),
    size = vec3(1, 2, 1),
    rotation = 356.6061,
    debug = false,
    options = {
        {
            name = 'ems_interaction_bed_echo',
            event = 'nl_interactions:ems_interaction_bed_client_ope_one',
            icon = 'fas fa-bed',
            label = 'Intéraction Lit',
            canInteract = function(entity, distance, coords, name)
                if distance < 2 then
                    return true
                end
                return false
            end
        }
    }
}

local OptionsInteractionOpeTwo = {
    coords = vec3(-649.3101, 318.5507, 88.2),
    size = vec3(1, 2, 1),
    rotation = 171.5,
    debug = false,
    options = {
        {
            name = 'ems_interaction_bed_echo',
            event = 'nl_interactions:ems_interaction_bed_client_ope_two',
            icon = 'fas fa-bed',
            label = 'Intéraction Lit',
            canInteract = function(entity, distance, coords, name)
                if distance < 2 then
                    return true
                end
                return false
            end
        }
    }
}


local OptionsInteractionOscuOne = {
    coords = vec3(-669.7316, 336.1655, 88.25),
    size = vec3(1, 2, 1),
    rotation = 3.08,
    debug = false,
    options = {
        {
            name = 'ems_interaction_bed_echo',
            event = 'nl_interactions:ems_interaction_bed_client_oscu_one',
            icon = 'fas fa-bed',
            label = 'Intéraction Lit',
            canInteract = function(entity, distance, coords, name)
                if distance < 2 then
                    return true
                end
                return false
            end
        }
    }
}

exports.ox_target:addModel(config.modelLitsBig, OptionsInteractionBed)
exports.ox_target:addModel(config.modelLits, OptionsInteractionBedLittle)
exports.ox_target:addModel(config.modelLitsMorgue, OptionsInteractionMorgue)
exports.ox_target:addModel(config.modelLitsMorgueLittle, OptionsInteractionLittleMorgue)
exports.ox_target:addBoxZone(OptionsInteractionEcho)
exports.ox_target:addBoxZone(OptionsInteractionOpeOne)
exports.ox_target:addBoxZone(OptionsInteractionOpeTwo)
exports.ox_target:addBoxZone(OptionsInteractionOscuOne)

LoadAnim = function(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(1)
    end
end

-- [[CHANGE THIS]] --
RegisterNetEvent('nl_interactions:sendDistressEms')
AddEventHandler('nl_interactions:sendDistressEms', function(Coords)
    if Coords ~= nil then
        local PhoneNumber = ""

        ESX.TriggerServerCallback('nl_interactions:getPhoneNumberBySource',function(number)
            if PhoneNumber ~= nil then
                PhoneNumber = number
            end
        end)

        local StreetHash = GetStreetNameAtCoord(Coords.x, Coords.y, Coords.z)
        local StreetName = ""
        if StreetHash ~= nil then
            local StreetName = GetStreetNameFromHashKey(StreetHash)
        else
            local StreetName = "Inconnu"
        end
        if PhoneNumber ~= nil then
-- [[ CHANGE ]] --
			--notify('warning', locale('send_distress'), 8000, locale('coma'))
            --TriggerServerEvent('nl_interactions:newCall', 'Coma' , 'Une personne est tombé dans le coma.', StreetName, Coords, PhoneNumber)
        else
-- [[ CHANGE ]] --
			--notify('warning', locale('reason_of_harm') .. TypeKilledPlayer, 8000, locale('harm_check'))
            --TriggerServerEvent('nl_interactions:newCall', 'Coma' , 'Une personne est tombé dans le coma.', StreetName, Coords, 000000)
        end

    end
end)

RegisterNetEvent('nl_interactions:healemsjob')
AddEventHandler('nl_interactions:healemsjob', function(healType, quiet)

	local playerPed = cache.ped
	local maxHealth = GetEntityMaxHealth(playerPed)

	if healType == 'small' then
		SetEntityHealth(playerPed, maxHealth)
	elseif healType == 'big' then
		SetEntityHealth(playerPed, maxHealth)
	end

	ClearPedBloodDamage(playerPed)
	ResetPedVisibleDamage(playerPed)

	for i = 0, 5 do
		ClearPedDamageDecalByZone(playerPed, i, "ALL")
		Wait(1)
	end

	if not quiet then
		notify('success', locale('healed'), 8000, 'EMS')
	end
end)

AddEventHandler('nl_interactions:analysePlayerEMS', function (data, player)

	local PlayerCoords = GetEntityCoords(cache.ped) -- Récupère les coordonnées du joueur
	local closePlayer = lib.getClosestPlayer(PlayerCoords, 2, false) -- Récupère le joueur le plus proche

	if closePlayer ~= nil then  -- Si un joueur est proche
		local PlayerPedClose = GetPlayerPed(closePlayer) -- Récupère le ped du joueur
		local Hit,Bone = GetPedLastDamageBone(PlayerPedClose)
		local WeaponKillPlayer = GetPedCauseOfDeath(PlayerPedClose)

		print(Hit,Bone)


		while (not HasAnimDictLoaded("amb@code_human_wander_clipboard@male@base")) do
			RequestAnimDict("amb@code_human_wander_clipboard@male@base")
			Citizen.Wait(0)
		end

		if Hit then
			-- arms
			if Bone == 64729 then
				PulseState(PlayerPedClose, locale('harm_arm_l_shoulder'))
			end
			if Bone == 45509 then
				PulseState(PlayerPedClose, locale('harm_arm_l_upper'))
			end
			if Bone == 61163 then
				PulseState(PlayerPedClose, locale('harm_arm_l_lower'))
			end
			if Bone == 18905 then
				PulseState(PlayerPedClose, locale('harm_hand_l'))
			end
			if Bone == 10706 then
				PulseState(PlayerPedClose, locale('harm_arm_r_shoulder'))
			end
			if Bone == 40269 then
				PulseState(PlayerPedClose, locale('harm_arm_r_upper'))
			end
			if Bone == 28252 then
				PulseState(PlayerPedClose, locale('harm_arm_r_lower'))
			end
			if Bone == 57005 then
				PulseState(PlayerPedClose, locale('harm_hand_r'))
			end
			
			-- Head
			if Bone == 31086 then
				PulseState(PlayerPedClose, locale('harm_head'))
			end
			if Bone == 39317 then
				PulseState(PlayerPedClose, locale('harm_neck'))
			end
			
			-- legs
			if Bone == 51826 then
				PulseState(PlayerPedClose, locale('harm_leg_r_upper'))
			end
			if Bone == 36864 then
				PulseState(PlayerPedClose, locale('harm_leg_r_lower'))
			end
			if Bone == 52301 then
				PulseState(PlayerPedClose, locale('harm_foot_r'))
			end
			if Bone == 20781 then
				PulseState(PlayerPedClose, locale('harm_toes_r'))
			end
			if Bone == 58271 then
				PulseState(PlayerPedClose, locale('harm_leg_l_upper'))
			end
			if Bone == 63931 then
				PulseState(PlayerPedClose, locale('harm_leg_l_lower'))
			end
			if Bone == 14201 then
				PulseState(PlayerPedClose, locale('harm_foot_l'))
			end
			if Bone == 2108 then
				PulseState(PlayerPedClose, locale('harm_toes_l'))
			end
			
			-- Body
			if Bone == 23553 then
				PulseState(PlayerPedClose, locale('harm_chest'))
			end
			if Bone == 24816 then
				PulseState(PlayerPedClose, locale('harm_belly'))
			end
			if Bone == 24817 then
				PulseState(PlayerPedClose, locale('harm_chest_back'))
			end
			if Bone == 24818 then
				PulseState(PlayerPedClose, locale('harm_chest'))
			end
			if Bone == 57597 then
				PulseState(PlayerPedClose, locale('harm_pelvis_lower_back'))
			end
		else
			PulseState(locale('harm_no_visual'))
		end

		local TypeKilledPlayer = WeaponHashEqualCauseOfDeath(WeaponKillPlayer)

		if TypeKilledPlayer ~= nil then
			Wait(2000)
			notify('warning', locale('reason_of_harm') .. TypeKilledPlayer, 8000, locale('harm_check'))
		end

		TaskPlayAnim(cache.ped,"amb@code_human_wander_clipboard@male@base","static",8.0, 8.0, -1, 49, 1, 0, 0, 0)

		local coords = GetEntityCoords(cache.ped)
		local prop = CreateObject(GetHashKey("p_cs_clipboard"), coords.x, coords.y, coords.z, true, true, true)

		AttachEntityToEntity(prop, cache.ped, GetPedBoneIndex(cache.ped, 18905), 0.2, 0.1, 0.05, -130.0, -45.0, 0.0, true, true, false, false, 1, true)
		Wait(3000)

		ClearPedTasks(cache.ped)
		DeleteObject(prop)

	else
		notify('error', locale('no_player_nearby') .. TypeKilledPlayer, 8000, 'EMS')
	end
end)

AddEventHandler('nl_interactions:analysePulsePlayerEMS', function (data, player)

	local PlayerCoords = GetEntityCoords(cache.ped)
	local closePlayer = lib.getClosestPlayer(PlayerCoords, 2, false)

	if closePlayer ~= nil then
		local PlayerPedClose = GetPlayerPed(closePlayer)
		local Hit,Bone = GetPedLastDamageBone(PlayerPedClose)

		print(Hit,Bone)
		if Hit then
			-- arms
			if Bone == 64729 then
				PulseState(PlayerPedClose, locale('harm_arm_l_shoulder'))
			end
			if Bone == 45509 then
				PulseState(PlayerPedClose, locale('harm_arm_l_upper'))
			end
			if Bone == 61163 then
				PulseState(PlayerPedClose, locale('harm_arm_l_lower'))
			end
			if Bone == 18905 then
				PulseState(PlayerPedClose, locale('harm_hand_l'))
			end
			if Bone == 10706 then
				PulseState(PlayerPedClose, locale('harm_arm_r_shoulder'))
			end
			if Bone == 40269 then
				PulseState(PlayerPedClose, locale('harm_arm_r_upper'))
			end
			if Bone == 28252 then
				PulseState(PlayerPedClose, locale('harm_arm_r_lower'))
			end
			if Bone == 57005 then
				PulseState(PlayerPedClose, locale('harm_hand_r'))
			end
			
			-- Head
			if Bone == 31086 then
				PulseState(PlayerPedClose, locale('harm_head'))
			end
			if Bone == 39317 then
				PulseState(PlayerPedClose, locale('harm_neck'))
			end
			
			-- legs
			if Bone == 51826 then
				PulseState(PlayerPedClose, locale('harm_leg_r_upper'))
			end
			if Bone == 36864 then
				PulseState(PlayerPedClose, locale('harm_leg_r_lower'))
			end
			if Bone == 52301 then
				PulseState(PlayerPedClose, locale('harm_foot_r'))
			end
			if Bone == 20781 then
				PulseState(PlayerPedClose, locale('harm_toes_r'))
			end
			if Bone == 58271 then
				PulseState(PlayerPedClose, locale('harm_leg_l_upper'))
			end
			if Bone == 63931 then
				PulseState(PlayerPedClose, locale('harm_leg_l_lower'))
			end
			if Bone == 14201 then
				PulseState(PlayerPedClose, locale('harm_foot_l'))
			end
			if Bone == 2108 then
				PulseState(PlayerPedClose, locale('harm_toes_l'))
			end
			
			-- Body
			if Bone == 23553 then
				PulseState(PlayerPedClose, locale('harm_chest'))
			end
			if Bone == 24816 then
				PulseState(PlayerPedClose, locale('harm_belly'))
			end
			if Bone == 24817 then
				PulseState(PlayerPedClose, locale('harm_chest_back'))
			end
			if Bone == 24818 then
				PulseState(PlayerPedClose, locale('harm_chest'))
			end
			if Bone == 57597 then
				PulseState(PlayerPedClose, locale('harm_pelvis_lower_back'))
			end
		else
			PulseState(locale('harm_no_visual'))
		end

		TaskPlayAnim(cache.ped,"amb@code_human_wander_clipboard@male@base","static",8.0, 8.0, -1, 49, 1, 0, 0, 0)

		local coords = GetEntityCoords(cache.ped)
		local prop = CreateObject(GetHashKey("p_cs_clipboard"), coords.x, coords.y, coords.z, true, true, true)

		AttachEntityToEntity(prop, cache.ped, GetPedBoneIndex(cache.ped, 18905), 0.2, 0.1, 0.05, -130.0, -45.0, 0.0, true, true, false, false, 1, true)
		Wait(3000)

		ClearPedTasks(cache.ped)
		DeleteObject(prop)

	else
		notify('error', locale('no_player_nearby') .. TypeKilledPlayer, 8000, 'EMS')
	end
end)


AddEventHandler('nl_interactions:reanimationPlayerEMS', function (data, player)

        local PlayerCoords = GetEntityCoords(cache.ped)
        local closePlayer = lib.getClosestPlayer(PlayerCoords, 2, false)
        local PlayerPed = GetPlayerPed(closePlayer)
        if closePlayer ~= nil and closePlayer > 0 and IsPedDeadOrDying(PlayerPed, true) then
            RevivePlayer(closePlayer)
            IsBleeding = false
        end
end)

AddEventHandler('nl_interactions:blessureLourdePlayerEMS', function (data, player)

        local ped = GetEntityCoords(cache.ped)
        local closestPlayer = lib.getClosestPlayer(ped, 2, false)

        if closestPlayer ~= nil then
            TriggerServerEvent('nl_interactions:heal', GetPlayerServerId(closestPlayer), 'big')
        end
end)

AddEventHandler('nl_interactions:blessureLegerePlayerEMS', function (data)
    local ped = GetEntityCoords(cache.ped)
    local closestPlayer = lib.getClosestPlayer(ped, 2, false)
    if closestPlayer ~= nil then
        TriggerServerEvent('nl_interactions:heal', GetPlayerServerId(closestPlayer), 'small')
    end
end)

RegisterNetEvent('nl_interactions:createWheelChair')
AddEventHandler('nl_interactions:createWheelChair', function()

	local MyPed = PlayerPedId()
	local ModelHash = 'iak_wheelchair'
	local CoordPed = GetEntityCoords(MyPed)

	VehicleHash = GetHashKey(ModelHash)

	RequestModel(VehicleHash)

	Citizen.CreateThread(function()
		local waiting = 0
		while not HasModelLoaded(VehicleHash) do
			waiting = waiting + 100
			Citizen.Wait(100)
			if waiting > 5000 then
				notify('info', locale('wheelchair_defect'))
				break
			end
		end
		local WheelChair = CreateVehicle(VehicleHash, CoordPed.x, CoordPed.y, CoordPed.z, GetEntityHeading(MyPed), 1, 0)
		TaskWarpPedIntoVehicle(MyPed, WheelChair, -1)
	end)
end)

AddEventHandler('nl_interactions_ems:getWheelChair', function(data)
    if DoesEntityExist(data.entity) then
        ESX.Game.DeleteVehicle(data.entity)
    end
end)

local optionsWheelChair = {
    {
        name = 'getWheelChair',
        event = 'nl_interactions:getWheelChair',
        icon = 'fa-solid fa-road',
        label = 'Ranger le fauteil',
        canInteract = function(entity, distance, coords, name, bone)
            local EntityVeh = GetEntityModel(entity)
            if EntityVeh == GetHashKey('iak_wheelchair') then
                return true
            end
            return false
        end
    }
}

exports.ox_target:addGlobalVehicle(optionsWheelChair)


-- Test Animation : 

-- RegisterCommand('testanimnl_interactions', function ()
--     if lib.progressCircle({
--         duration = 2000,
--         position = 'bottom',
--         useWhileDead = false,
--         canCancel = true,
--         disable = {
--             car = true,
--         },
--         anim = {
--             dict = 'mini@cpr@char_a@cpr_str',
--             clip = 'cpr_pumpchest' 
--         },
--     }) then 
--         print('Do stuff when complete') 
--     else 
--         print('Do stuff when cancelled') 
--     end
    
-- end)

-- RegisterCommand('testanimnl_interactions2', function ()
--     if lib.progressCircle({
--         duration = 2000,
--         position = 'bottom',
--         useWhileDead = false,
--         canCancel = true,
--         disable = {
--             car = true,
--         },
--         anim = {
--             dict = 'mini@cpr@char_a@cpr_str',
--             clip = 'cpr_kol' 
--         },
--     }) then print('Do stuff when complete') else print('Do stuff when cancelled') end
-- end)

-- RegisterCommand('testanimnl_interactions4', function ()
--     if lib.progressCircle({
--         duration = 2000,
--         position = 'bottom',
--         useWhileDead = false,
--         canCancel = true,
--         disable = {
--             car = true,
--         },
--         anim = {
--             dict = 'missheistfbi3b_ig8_2',
--             clip = 'cpr_loop_paramedic' 
--         },
--     }) then print('Do stuff when complete') else print('Do stuff when cancelled') end
-- end)

-- RegisterCommand('testanimnl_interactions5', function ()
--     local playerPed = cache.ped
-- 	while (not HasAnimDictLoaded("amb@code_human_wander_clipboard@male@base")) do
-- 		RequestAnimDict("amb@code_human_wander_clipboard@male@base")
-- 		Citizen.Wait(0) 
-- 	end
-- 	TaskPlayAnim(playerPed,"amb@code_human_wander_clipboard@male@base","static",8.0, 8.0, -1, 49, 1, 0, 0, 0)

-- 	local coords = GetEntityCoords(ped)
-- 	prop = CreateObject(GetHashKey("p_cs_clipboard"), coords, true, true, true)

-- 	AttachEntityToEntity(prop, cache.ped, GetPedBoneIndex(cache.ped, 18905), 0.2, 0.1, 0.05, -130.0, -45.0, 0.0, true, true, false, false, 1, true)
--     Wait(3500)

--     ClearPedTasks(cache.ped)
--     DeleteObject(prop)
-- end)

