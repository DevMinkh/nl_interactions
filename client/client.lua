-- Load the locale module
lib.locale()

-- Load ESX
ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    while (ESX == nil) do Citizen.Wait(100) end
    PlayerData = xPlayer
    FreezeEntityPosition(PlayerPedId(), false)
end)

AddEventHandler('esx:onPlayerSpawn', function()
    local playerPed = PlayerPedId()
    if GetEntityHealth(playerPed) ~=  200 then
        SetEntityMaxHealth(playerPed, 200)
        SetEntityHealth(playerPed, 200)
    end
end)

-- Define locals
local IsDead = false
local StatusReload = false
local IsBleeding = false
local secondsRemaining = config.bleedoutTimer

local TimerDeath = 0
local TimerDeathMax = 720000
local TimerAddedPerTick = 1000

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

    local ems = AddBlipForCoord(Config.BlipsHospital.position.x, Config.BlipsHospital.position.y, Config.BlipsHospital.position.z)

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

-- Death screen
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

-- On player death function
AddEventHandler('esx:onPlayerDeath', function(data)
    if not IsBleeding then
        IsBleeding = true
        if GetEntityHealth(PlayerPedId()) <= 105 then
            local WeaponKiller = GetPedCauseOfDeath(PlayerPedId())
            local WeapKoIs = false
            for k,v in pairs(Config.WeapKo) do
                if WeaponKiller == joaat(v) then
                    WeapKoIs = true
                end
            end

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
                    -- [[CHANGE THIS]] --
                    --text("~r~Vous êtes KO. Vous allez vous relever dans ~b~"..secondsRemaining.."~r~ secondes.")
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
                    TriggerEvent("esx_status:set", "hunger", 500000)
                    TriggerEvent("esx_status:set", "thirst", 500000)
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
    -- [[CHANGE THIS]] --
    --[[
	local anonym = false
	local coords = GetEntityCoords(PlayerPedId())
	local position = {x = coords.x, y = coords.y, z = coords.z - 1}
	local jobreceived = JOBNAME
	local message = MESSAGE
	
	TriggerServerEvent('roadphone:sendDispatch', GetPlayerServerId(PlayerId()), message, jobreceived, position, anonym)
	]]--
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

RegisterNetEvent('nl_interactions:reviveems')
AddEventHandler('nl_interactions:reviveems', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    TriggerServerEvent('nl_interactions:setDeathStatus', false)

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
    -- [[CHANGE THIS]] --
    --exports['okokNotify']:Alert('EMS', 'Vous avez était Réanimer...', 5000, 'success')

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

            exports.scully_emotemenu:Play(EmoteData, EmoteData.Variant)
            -- [[CHANGE THIS]] --
            --exports['okokNotify']:Alert('Lit', 'Pour sortir du lit, Appuyez sur [X]', 8000, 'warning')
        else
        -- [[CHANGE THIS]] --
        --exports['okokNotify']:Alert('Lit', 'Veuillez réessayer une erreur est survenu !', 8000, 'error')
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
        -- [[CHANGE THIS]] --
        --exports['okokNotify']:Alert('Lit', 'Pour sortir du lit, Appuyez sur [X]', 8000, 'warning')
    else
    -- [[CHANGE THIS]] --
    --exports['okokNotify']:Alert('Lit', 'Veuillez réessayer une erreur est survenu !', 8000, 'error')
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
        -- [[CHANGE THIS]] --
        --exports['okokNotify']:Alert('Lit', 'Pour sortir du lit, Appuyez sur [X]', 8000, 'warning')
    else
    -- [[CHANGE THIS]] --
    --exports['okokNotify']:Alert('Lit', 'Veuillez réessayer une erreur est survenu !', 8000, 'error')
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
        -- [[CHANGE THIS]] --
        --exports['okokNotify']:Alert('Lit', 'Pour sortir du lit, Appuyez sur [X]', 8000, 'warning')
    else
    -- [[CHANGE THIS]] --
    --exports['okokNotify']:Alert('Lit', 'Veuillez réessayer une erreur est survenu !', 8000, 'error')
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
        -- [[CHANGE THIS]] --
        --exports['okokNotify']:Alert('Lit', 'Pour sortir du lit, Appuyez sur [X]', 8000, 'warning')
    else
    -- [[CHANGE THIS]] --
    --exports['okokNotify']:Alert('Lit', 'Veuillez réessayer une erreur est survenu !', 8000, 'error')
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
            TriggerServerEvent('nl_interactions:newCall', 'Coma' , 'Une personne est tombé dans le coma.', StreetName, Coords, PhoneNumber)
        else
            TriggerServerEvent('nl_interactions:newCall', 'Coma' , 'Une personne est tombé dans le coma.', StreetName, Coords, 000000)
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
            exports['okokNotify']:Alert('EMS', 'Vous avez été soigné', 8000, 'success')
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
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Verletzung des linken Schlüsselbeins')
                end
                if Bone == 45509 then
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Oberarmverletzung links')
                end
                if Bone == 61163 then
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Verletzung des linken Unterarms')
                end
                if Bone == 18905 then
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Verletzung der linken Hand')
                end
                if Bone == 10706 then
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Verletzung des rechten Schlüsselbeins')
                end
                if Bone == 40269 then
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Oberarmverletzung rechts')
                end
                if Bone == 28252 then
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Verletzung des rechten Unterarms')
                end
                if Bone == 57005 then
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Verletzung der rechten Hand')
                end
                if Bone == 31086 then
                    -- head
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Kopfverletzung')
                end
                if Bone == 39317 then
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Nackenverletzung')
                end
                if Bone == 51826 then
                    -- legs
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Rechte Oberschenkelverletzung')
                end
                if Bone == 36864 then
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Rechte Wadenverletzung')
                end
                if Bone == 52301 then
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Verletzung des rechten Fußes')
                end
                if Bone == 20781 then
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Verletzung der rechten Zehen')
                end
                if Bone == 58271 then
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Linke Oberschenkelverletzung')
                end
                if Bone == 63931 then
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Linke Wadenverletzung')
                end
                if Bone == 14201 then
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Verletzung des linken Fußes')
                end
                if Bone == 2108 then
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Verletzung der linken Zehen')
                end
                -- body
                if Bone == 23553 then
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Brustverletzung')
                end
                if Bone == 24816 then
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Bauchverletzung')
                end
                if Bone == 24817 then
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Brust- und/oder Rückenverletzung')
                end
                if Bone == 24818 then
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Brustverletzung')
                end
                if Bone == 57597 then
                    -- [[CHANGE THIS]] --
                    PulseState(PlayerPedClose, 'Verletzung des Beckens und/oder des unteren Rückens')
                end
            else
            -- [[CHANGE THIS]] --
            --PulseState('Keine Sichtverletzung')
            end

            local TypeKilledPlayer = WeaponHashEqualCauseOfDeath(WeaponKillPlayer)

            if TypeKilledPlayer ~= nil then
                Wait(2000)
                -- [[CHANGE THIS]] --
                --exports['okokNotify']:Alert('Analyse des Blessures', 'Type de blessure/munitions qui on causé les blessure : <b>' .. TypeKilledPlayer, 8000, 'warning')
            end

            TaskPlayAnim(cache.ped,"amb@code_human_wander_clipboard@male@base","static",8.0, 8.0, -1, 49, 1, 0, 0, 0)

            local coords = GetEntityCoords(cache.ped)
            local prop = CreateObject(GetHashKey("p_cs_clipboard"), coords.x, coords.y, coords.z, true, true, true)

            AttachEntityToEntity(prop, cache.ped, GetPedBoneIndex(cache.ped, 18905), 0.2, 0.1, 0.05, -130.0, -45.0, 0.0, true, true, false, false, 1, true)
            Wait(3000)

            ClearPedTasks(cache.ped)
            DeleteObject(prop)

        else
        -- [[CHANGE THIS]] --
        --exports['okokNotify']:Alert('EMS', 'Kein Spieler in der Nähe', 8000, 'error')
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
                if Bone == 64729 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure a la Clavicule Gauche')
                end
                if Bone == 45509 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure Haut du bras Gauche')
                end
                if Bone == 61163 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure Avant bras Gauche')
                end
                if Bone == 18905 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure a la Mains Gauche')
                end
                if Bone == 10706 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure a la Clavicule Droite')
                end
                if Bone == 40269 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure Haut du Bras Droit')
                end
                if Bone == 28252 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure Avant Bras Droit')
                end
                if Bone == 57005 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure a la Mains Droite')
                end
                if Bone == 31086 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure a la Tête')
                end
                if Bone == 39317 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure au Cou')
                end
                if Bone == 51826 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure a la Cuisse Droite')
                end
                if Bone == 36864 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure a la Mollet Droite')
                end
                if Bone == 52301 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure a la Pied Droite')
                end
                if Bone == 20781 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure au doigts Pied Droit')
                end
                if Bone == 58271 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure a la Cuisse Gauche')
                end
                if Bone == 63931 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure a la Mollet Gauche')
                end
                if Bone == 14201 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure a la Pied Gauche')
                end
                if Bone == 2108 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure au doigts Pied Gauche')
                end
                if Bone == 23553 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure a la Poitrine')
                end
                if Bone == 24816 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure au Ventre')
                end
                if Bone == 24817 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure au Torse et/ou Dos')
                end
                if Bone == 24818 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure a la Poitrine')
                end
                if Bone == 57597 then
                -- [[CHANGE THIS]] --
                --PulseState(PlayerPedClose, 'Blessure au Bassin et/ou Bas du Dos')
                end
            else
            -- [[CHANGE THIS]] --
            --PulseState('Aucune Blessure Visuel')
            end

            TaskPlayAnim(cache.ped,"amb@code_human_wander_clipboard@male@base","static",8.0, 8.0, -1, 49, 1, 0, 0, 0)

            local coords = GetEntityCoords(cache.ped)
            local prop = CreateObject(GetHashKey("p_cs_clipboard"), coords.x, coords.y, coords.z, true, true, true)

            AttachEntityToEntity(prop, cache.ped, GetPedBoneIndex(cache.ped, 18905), 0.2, 0.1, 0.05, -130.0, -45.0, 0.0, true, true, false, false, 1, true)
            Wait(3000)

            ClearPedTasks(cache.ped)
            DeleteObject(prop)

        else
        -- [[CHANGE THIS]] --
        --exports['okokNotify']:Alert('EMS', 'Kein Spieler in der Nähe', 8000, 'error')
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
            TriggerServerEvent('nl_interactions:healems', GetPlayerServerId(closestPlayer), 'big')
        end
end)

AddEventHandler('nl_interactions:blessureLegerePlayerEMS', function (data)
    local ped = GetEntityCoords(cache.ped)
    local closestPlayer = lib.getClosestPlayer(ped, 2, false)
    if closestPlayer ~= nil then
        TriggerServerEvent('nl_interactions:healems', GetPlayerServerId(closestPlayer), 'small')
    end
end)

-- [[CHANGE THIS]] --
--[[
exports['qtarget']:Player({
    options = {
        {
            icon = 'fas fa-diagnoses',
            label = 'Analysieren Sie den Körper des Patienten',
            job = {['ambulance'] = 0},
            canInteract = function(entity)

                if IsPedAPlayer(entity) and IsPedDeadOrDying(entity) then
                    return true
                end

            end,
            event = "nl_interactions:AnalysePlayerEMS",
        },
        {
            icon = 'fas fa-diagnoses',
            label = 'Analysieren Sie Patienten und Verletzungen',
            job = {['ambulance'] = 0},
            canInteract = function(entity)

                if IsPedAPlayer(entity) and IsPedDeadOrDying(entity) == false then
                    return true
                end

            end,
            event = "nl_interactions:AnalysePulsePlayerEMS",
        },
        {
            icon = 'fas fa-hand-holding-medical',
            label = 'Führen Sie eine Wiederbelebung durch',
            -- job = {['ambulance'] = 0},
            canInteract = function(entity)

                if IsPedAPlayer(entity) and IsPedDeadOrDying(entity, true) then


                    local ItemNeeded = exports.ox_inventory:Search('count', 'reakit')

                    if ItemNeeded > 0 then
                        return true
                    end

                end
            end,
            event = "nl_interactions:ReanimationPlayerEMS",
        },
        {
            icon = 'fas fa-medkit',
            label = 'Führe schwere Heilung durch',
            -- job = {['ambulance'] = 0},
            canInteract = function(entity)

                if IsPedAPlayer(entity) then


                    local ItemNeeded = exports.ox_inventory:Search('count', 'medkit')
                    local HealthPlayer = GetEntityHealth(entity)

                    -- print(HealthPlayer, GetEntityMaxHealth(entity))
                    
                    if IsPedMale(entity) then
                        if HealthPlayer < 150 and HealthPlayer > 101 and ItemNeeded > 0 then
                            return true
                        end
                    else 
                        if HealthPlayer < 50 and HealthPlayer > 1 and ItemNeeded > 0 then
                            return true
                        end
                    end
                end
            end,
            event = "nl_interactions:BlessureLourdePlayerEMS",
        },
        {
            icon = 'fas fa-pump-medical',
            label = 'Leichte Pflege durchführen',
            -- job = {['ambulance'] = 0},
            canInteract = function(entity)

                if IsPedAPlayer(entity) then


                    local ItemNeeded = exports.ox_inventory:Search('count', 'bandageems')
                    local HealthPlayer = GetEntityHealth(entity)
                    

                    if IsPedMale(entity) then
                        if HealthPlayer < 201 and HealthPlayer >= 150 and ItemNeeded > 0 then
                            return true
                        end
                    else 
                        if HealthPlayer < 101 and HealthPlayer >= 50 and ItemNeeded > 0 then
                            return true
                        end
                    end

                end
            end,
            event = "nl_interactions:BlessureLegerePlayerEMS",
        },
    },
    distance = 2.0
})
]]--

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
                    -- [[CHANGE THIS]] --
                    --ShowNotification("~r~Le Fauteil Roulant a eu un problème.")
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

