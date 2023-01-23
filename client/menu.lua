local emsTag = "[EMS] "
local pdTag = "[PD] "
local mechTag = "[MECH] "

exports['qtarget']:Vehicle({
    options = {
        {
            event = "nl_interactions:putInVehicleStart",
            icon = "fas fa-car-side",
            label = "[PD] Ins Fahrzeug setzen",
            job = "police",
            canInteract = function(entity)
                if (draggingEntity == nil) then return false end
                return true
            end,
        },
        {
            event = "nl_interactions:pullOutVehicleStart",
            icon = "fas fa-user-minus",
            label = "[PD] Aus dem Fahrzeug holen",
            job = "police"
        },
        {
            event = "nl_interactions:forceOpen",
            icon = "fas fa-file-invoice-dollar",
            label = "[PD] Fahrzeug öffnen",
            job = "police"
        },
        {
            event = "nl_interactions:putInVehicleStart",
            icon = "fas fa-car-side",
            label = "[BPC] Ins Fahrzeug setzen",
            job = "bpc",
            canInteract = function(entity)
                if (draggingEntity == nil) then return false end
                return true
            end,
        },
        {
            event = "nl_interactions:pullOutVehicleStart",
            icon = "fas fa-user-minus",
            label = "[BPC] Aus dem Fahrzeug holen",
            job = "bpc"
        },
        {
            event = "nl_interactions:forceOpen",
            icon = "fas fa-file-invoice-dollar",
            label = "[BPC] Fahrzeug öffnen",
            job = "bpc"
        },
        {
            event = "nl_interactions:putInVehicleStart",
            icon = "fas fa-car-side",
            label = "[EMS] Ins Fahrzeug setzen",
            job = "ambulance",
            canInteract = function(entity)
                if (draggingEntity == nil) then return false end
                return true
            end,
        },
        {
            event = "nl_interactions:pullOutVehicleStart",
            icon = "fas fa-user-minus",
            label = "[EMS] Aus dem Fahrzeug holen",
            job = "ambulance"
        },
        {
            event = "nl_interactions:repairVehicle",
            icon = "fas fa-toolbox",
            label = "[MECH] Fahrzeug reparieren",
            item = 'repairkit',
            job = "mechanic"
        },
        {
            event = "nl_interactions:cleanVehicle",
            icon = "fas fa-hand-sparkles",
            label = "[MECH] Fahrzeug säubern",
            job = "mechanic"
        },
        {
            event = "nl_interactions:forceOpen",
            icon = "fas fa-unlock",
            label = "[MECH] Fahrzeug öffnen",
            job = "mechanic"
        },
        {
            event = "nl_interactions:repairVehicle",
            icon = "fas fa-toolbox",
            label = "[FNL] Fahrzeug reparieren",
            item = 'repairkit',
            job = "fnl"
        },
        {
            event = "nl_interactions:cleanVehicle",
            icon = "fas fa-hand-sparkles",
            label = "[FNL] Fahrzeug säubern",
            job = "fnl"
        },
        {
            event = "nl_interactions:forceOpen",
            icon = "fas fa-unlock",
            label = "[FNL] Fahrzeug öffnen",
            job = "fnl"
        },
    --[[
        {
            event = "nl_interactions:lockpick",
            icon = "fas fa-unlock",
            item = 'lockpick',
            label = 'Fahrzeug knacken',
            canInteract = function(entity)
            if (ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'mechanic' or ESX.PlayerData.job.name == 'fnl' or ESX.PlayerData.job.name == 'bpc') then return false end
                return true
            end,
        },
        ]]--
    },
    distance = 2.0
})

exports['qtarget']:Player({
    options = {
        {
            icon = "fak fa-handcuffs",
            label = "[PD] Handschellen",
            job = "police",
            action = function(entity)
            -- INSERT CUFF
            --TriggerServerEvent('esx_policejob:handcuff', GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)))
            end,
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    return (not IsPedDeadOrDying(entity, 1))
                end
            end
        },
        {
            icon = "fas fa-briefcase",
            label = "[PD] Durchsuchen",
            job = "police",
            action = function(entity)
                exports.ox_inventory:OpenNearbyInventory()
            end,
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                    return (Player(targetId).state.handsup or Player(targetId).state.handcuffed or Player(targetId).state.ziptied)
                end
            end
        },
        {
            event = "nl_interactions:dragStart",
            icon = "fas fa-users",
            label = "[PD] Eskortieren",
            job = "police",
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                    return (Player(targetId).state.handcuffed and not IsPedDeadOrDying(entity, 1) or Player(targetId).state.ziptied)
                end
            end
        },
        --[[
        {
            event = "nl_interactions:prison",
            icon = "fas fa-house-user",
            label = "[PD] Gefängnis",
            job = "police",
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                    return (Player(targetId).state.handcuffed and not IsPedDeadOrDying(entity, 1))
                end
            end
        },
		]]--
        {
            event = "nl_interactions:dragStart",
            icon = "fas fa-users",
            label = "[EMS] Eskortieren",
            job = "ambulance",
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    return (not IsPedDeadOrDying(entity, 1))
                end
            end,
        },
        {
            event = "nl_interactions:revive",
            icon = "fas fa-hand-holding-medical",
            label = "[EMS] Wiederbeleben",
            job = "ambulance",
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    return (IsPedDeadOrDying(entity, 1))
                end
            end,
            action = function(entity)
            -- INSERT REVIVE
            --exports['esx_ambulancejob']:revivePlayer(NetworkGetPlayerIndexFromPed(entity))
            end
        },
        {
            event = "nl_interactions:bandage",
            icon = "fas fa-prescription-bottle",
            label = "[EMS] Verbinden",
            job = "ambulance",
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    return (GetPedMaxHealth(entity) ~= GetEntityHealth(entity) and not IsPedDeadOrDying(entity, 1))
                end
            end,
        },
        {
            icon = "fak fa-handcuffs",
            label = "[BPC] Handschellen",
            job = "bpc",
            action = function(entity)
            -- INSERT CUFF
            --TriggerServerEvent('esx_policejob:handcuff', GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)))
            end,
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    return (not IsPedDeadOrDying(entity, 1))
                end
            end
        },
        {
            icon = "fas fa-briefcase",
            label = "[BPC] Durchsuchen",
            job = "bpc",
            action = function(entity)
                exports.ox_inventory:OpenNearbyInventory()
            end,
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                    return (Player(targetId).state.handsup or Player(targetId).state.handcuffed or Player(targetId).state.ziptied)
                end
            end
        },
        {
            event = "nl_interactions:dragStart",
            icon = "fas fa-users",
            label = "[BPC] Eskortieren",
            job = "bpc",
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                    return (Player(targetId).state.handcuffed and not IsPedDeadOrDying(entity, 1) or Player(targetId).state.ziptied)
                end
            end
        },
        {
            event = "nl_interactions:openTargetInventory",
            icon = "fa-solid fa-sack-dollar",
            label = "Ausrauben",
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    if (ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'ambulance' or ESX.PlayerData.job.name == 'bpc') then return false end
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                    return ((Player(targetId).state.handsup or Player(targetId).state.ziptied) and (IsPedArmed(PlayerPedId(), 4) or IsPedArmed(PlayerPedId(), 1)))
                end
            end,
            action = function(entity)
                exports.ox_inventory:OpenNearbyInventory()
            end
        },
        {
            icon = "fas fa-user-ninja",
            label = "Geisel nehmen",
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    if (ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'ambulance' or ESX.PlayerData.job.name == 'bpc') then return false end
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                    return ((Player(targetId).state.handsup or Player(targetId).state.ziptied) and (IsPedArmed(PlayerPedId(), 4) or IsPedArmed(PlayerPedId(), 1)) and not IsPedDeadOrDying(entity, 1))
                end
            end,
            action = function(entity)
            -- [[ CHANGE ]]--
            --TriggerEvent('TakeHostage:Start', GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)))
            end
        },
		--[[ EMS actions ]]--
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
            event = "nl_interactions:analysePulsePlayerEMS",
        },
        {
            icon = 'fas fa-hand-holding-medical',
            label = 'Führen Sie eine Wiederbelebung durch',
            job = {['ambulance'] = 0},
            canInteract = function(entity)

                if IsPedAPlayer(entity) and IsPedDeadOrDying(entity, true) then


                    local ItemNeeded = exports.ox_inventory:Search('count', 'reakit')

                    if ItemNeeded > 0 then
                        return true
                    end

                end
            end,
            event = "nl_interactions:reanimationPlayerEMS",
        },
        {
            icon = 'fas fa-medkit',
            label = 'Führe schwere Heilung durch',
            job = {['ambulance'] = 0},
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
            event = "nl_interactions:blessureLourdePlayerEMS",
        },
        {
            icon = 'fas fa-pump-medical',
            label = 'Leichte Pflege durchführen',
            job = {['ambulance'] = 0},
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
            event = "nl_interactions:blessureLegerePlayerEMS",
        },
    },
    distance = 2.0
})
