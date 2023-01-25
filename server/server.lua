--[[ Loading the ox_lib locales ]]--
lib.locale()

--[[ Load ESX ]]--
ESX = exports["es_extended"]:getSharedObject()

--[[ Define locals ]]--
local BlipsList = {}
local count = 1

--[[ Server events ]]--
AddEventHandler('onResourceStart', function(resourceName)
    if ( string.find(resourceName, "nl_interactions") ) then
        TriggerEvent('nl_interactions:versionCheck', resourceName, GetResourceMetadata(resourceName, 'version'), GetResourceMetadata(resourceName, 'versioncheck'))
    end
end)

RegisterServerEvent('nl_interactions:dragServer')
AddEventHandler('nl_interactions:dragServer', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    if (xPlayer.job.name ~= 'police' and xPlayer.job.name ~= 'ambulance' or xPlayer.job.name == 'bpc') then return end
    local needsCuff = true
    if (xPlayer.job.name == 'ambulance') then needsCuff = false end
    TriggerClientEvent('nl_interactions:drag', target, source, needsCuff)
end)

RegisterServerEvent('nl_interactions:putInVehicleServer')
AddEventHandler('nl_interactions:putInVehicleServer', function(target, vehicle)
    local xPlayer = ESX.GetPlayerFromId(source)
    if (xPlayer.job.name == 'police' or xPlayer.job.name == 'ambulance' or xPlayer.job.name == 'bpc') then
        TriggerClientEvent('nl_interactions:putInVehicle', target, vehicle)
    end
end)

RegisterServerEvent('nl_interactions:pullOutVehicleServer')
AddEventHandler('nl_interactions:pullOutVehicleServer', function(target, vehicle)
    local xPlayer = ESX.GetPlayerFromId(source)
    if (xPlayer.job.name == 'police' or xPlayer.job.name == 'ambulance' or xPlayer.job.name == 'bpc') then
        TriggerClientEvent('nl_interactions:pullOutVehicle', target, vehicle)
    end
end)

RegisterServerEvent('nl_interactions:heal')
AddEventHandler('nl_interactions:heal', function(target, type)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == config.jobName then
		TriggerClientEvent('nl_interactions:healemsjob', target, type)
		
		if type == 'small' then 
			local count = exports.ox_inventory:Search(source, 'count', 'bandage')
			if count > 0 then 
				exports.ox_inventory:RemoveItem(source, 'bandage', 1)
			else 
				--TriggerClientEvent('okokNotify:Alert', source, 'EMS', 'Vous n\'avez pas assez Bandages Médicale', 5000, 'error')
			end
		elseif type == 'big' then
			local count = exports.ox_inventory:Search(source, 'count', 'bandage')
			if count > 0 then 
				exports.ox_inventory:RemoveItem(source, 'medkit', 1)
			else 
				--TriggerClientEvent('okokNotify:Alert', source, 'EMS', 'Vous n\'avez pas assez Kit Médicale', 5000, 'error')
			end
		end
	else
	-- 	print(('nl_interactions:heal: %s attempted to heal!'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent('nl_interactions:sendDistress')
AddEventHandler('nl_interactions:sendDistress', function()

	local Player = source 
	local Ped = GetPlayerPed(Player)
	local PlayerCoords = GetEntityCoords(Ped)

	TriggerClientEvent('nl_interactions:sendDistress', source, PlayerCoords)

end)

RegisterNetEvent('nl_interactions:revive')
AddEventHandler('nl_interactions:revive', function(playerId)
	playerId = tonumber(playerId)
	if source == '' and GetInvokingResource() == 'monitor' then -- txAdmin support
        local xTarget = ESX.GetPlayerFromId(playerId)
        if xTarget then
            xTarget.triggerEvent('nl_interactions:revive')
        else
            print(locale('console_log_offline'))
        end
	else
		local xPlayer = source and ESX.GetPlayerFromId(source)

		--if xPlayer and xPlayer.job.name == Config.JobName then
		local xTarget = ESX.GetPlayerFromId(playerId)
		local count = exports.ox_inventory:Search(xPlayer.source, 'count', 'reakit')
		if count > 0 then 
			if xTarget then
				local playerMoney  = config.reviveRewardPlayer
				local societyMoney = config.reviveRewardSociety

				TriggerEvent('esx_addonaccount:getSharedAccount', 'society_ambulance', function(account)
					if account then
						if societyMoney >= 0 then
							TriggerClientEvent('nl_interactions:notify', 'success', locale('revive_society_paid', societyMoney), 5000, 'EMS')
							account.addMoney(societyMoney)
						end
						if playerMoney > 0 then
							TriggerClientEvent('nl_interactions:notify', 'success', locale('revive_society_paid', playerMoney), 5000, 'EMS')
							xPlayer.addAccountMoney('bank', playerMoney)
						end
					else
						if playerMoney > 0 then
							TriggerClientEvent('nl_interactions:notify', 'success', locale('revive_society_paid', playerMoney), 5000, 'EMS')
						end
					end
				end)
				
				if config.useRakit == true then
					exports.ox_inventory:RemoveItem(xPlayer.source, 'reakit', 1)
				end
				xTarget.triggerEvent('nl_interactions:revive')
			else
				TriggerClientEvent('nl_interactions:notify', 'warning', locale('no_rakit'), 5000, 'EMS')
			end
		else 
			TriggerClientEvent('nl_interactions:notify', 'error', locale('console_log_offline'), 5000, 'EMS')
		end
		--end
	end
end)

exports('revive', revive)

--[[
RegisterNetEvent('nl_interactions:revive')
AddEventHandler('nl_interactions:revive', function(playerId)
	playerId = tonumber(playerId)
		local xPlayer = source and ESX.GetPlayerFromId(source)

		if xPlayer and xPlayer.job.name == 'ambulance' then
			local xTarget = ESX.GetPlayerFromId(playerId)
			if xTarget then
				if deadPlayers[playerId] then
					if Config.ReviveReward > 0 then
						xPlayer.showNotification(TranslateCap('revive_complete_award', xTarget.name, Config.ReviveReward))
						xPlayer.addMoney(Config.ReviveReward, "Revive Reward")
						xTarget.triggerEvent('nl_interactions:revive')
					else
						xPlayer.showNotification(TranslateCap('revive_complete', xTarget.name))
						xTarget.triggerEvent('nl_interactions:revive')
					end
					local Ambulance = ESX.GetExtendedPlayers("job", "ambulance")

					for _, xPlayer in pairs(Ambulance) do
						if xPlayer.job.name == 'ambulance' then
							xPlayer.triggerEvent('nl_interactions:PlayerNotDead', playerId)
						end
					end
					deadPlayers[playerId] = nil
				else
					xPlayer.showNotification(TranslateCap('player_not_unconscious'))
				end
			else
				xPlayer.showNotification(TranslateCap('revive_fail_offline'))
			end
		end
end)
]]--

RegisterNetEvent('nl_interactions:setDeathStatus')
AddEventHandler('nl_interactions:setDeathStatus', function(isDead)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer ~= nil then
		if type(isDead) == 'boolean' then
			MySQL.Sync.execute('UPDATE users SET is_dead = @isDead WHERE identifier = @identifier', {
				['@identifier'] = xPlayer.identifier,
				['@isDead'] = isDead
			})
		end
	end
end)

ESX.RegisterServerCallback('nl_interactions:getDeathStatus', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer ~= nil then
		MySQL.Async.fetchScalar('SELECT is_dead FROM users WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier
		}, function(isDead)
					
			if isDead then
				print(locale('console_log_death', xPlayer.identifier))
			end

			cb(isDead)
		end)
	else 
		cb(false)
	end
end)

lib.addCommand('group.admin', {'revive'}, function(source, args)
    if args.target ~= nil and args.target > 0 and GetPlayerName(args.target) ~= nil then
		local TargetPlayer = ESX.GetPlayerFromId(args.target)

		TriggerClientEvent('nl_interactions:revive', args.target)
		TriggerClientEvent('nl_interactions:notify', 'success', locale('revive_success_from') .. TargetPlayer.getName(), 5000, 'EMS')
	else 
		
		TriggerClientEvent('nl_interactions:revive', source)
		TriggerClientEvent('nl_interactions:notify', 'success', locale('revive_success'), 5000, 'EMS')
    end
end, {'target:number'})

--[[ CHANGE ]]--
--[[
lib.addCommand('group.admin', {'reviveall'}, function(source, args)
	-- fix this to revive all players
	-- maybe needed at a WL free time
	TriggerClientEvent('nl_interactions:revive', source)
	TriggerClientEvent('nl_interactions:notify', 'success', locale('revive_success'), 5000, 'EMS')
end, {'target:number'})
]]--

RegisterNetEvent("nl_interactions:sendDemande")
AddEventHandler("nl_interactions:sendDemande", function(lastname, firstname, phone, subject, desc)

	if desc == nil or lastname == nil or firstname == nil or phone == nil or subject == nil then 
		--TriggerClientEvent('nl_interactions:notify', source, 'EMS', locale('form_fill_all'), 5000, 'error')	
	else 

		TriggerClientEvent('nl_interactions:envoidemanderendezvous', source)
		
		--SendToDiscordWithSpecialURL("Central EMS","Demande émise par: __"..lastname.." "..firstname.. "__ \n\nTél: **__"..phone.."__**\n\nSujet: **__"..subject.."__**\n\nDemande: "..desc, 2061822, Config.SonnetteWebHook)
	end
	
end)

RegisterServerEvent('nl_interactions:gestionCompteEms')
AddEventHandler('nl_interactions:gestionCompteEms', function(typeEvent, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if typeEvent == "depot" then 
		local cashPlayer = exports.ox_inventory:Search(xPlayer.source, 'count', 'money')
		if cashPlayer >= amount then 
			exports.ox_inventory:RemoveItem(xPlayer.source, 'money', amount)
			TriggerEvent('esx_addonaccount:getSharedAccount', "society_ambulance", function(account)
				account.addMoney(amount)
			end)
			--TriggerClientEvent('nl_interactions:notify', xPlayer.source, 'CusTomoe', 'Vous avez déposer <b style="color:#00FF00;">' .. amount .. ' $</b> sur votre compte entreprise', 5000, 'success')
		else 
            --TriggerClientEvent('nl_interactions:notify', xPlayer.source, 'CusTomoe', 'Vous n\'avez pas assez d\'argent sur vous !', 5000, 'error')
        end
	end

    if typeEvent == "retrait" then 
        local societyAccountSog = nil
			TriggerEvent('esx_addonaccount:getSharedAccount', "society_ambulance", function(account)
				societyAccountSog = account
			end)

		if societyAccountSog.money >= amount then 
            societyAccountSog.removeMoney(amount)
            exports.ox_inventory:AddItem(xPlayer.source, 'money', amount)
            --TriggerClientEvent('nl_interactions:notify', xPlayer.source, 'CusTomoe', 'Vous avez retirer <b style="color:red;">' .. amount .. ' $</b> sur votre compte entreprise', 5000, 'success')
        else 
            --TriggerClientEvent('nl_interactions:notify', xPlayer.source, 'CusTomoe', 'Votre compte entreprise n\'a pas assez !', 5000, 'error')
        end
	end
end)

RegisterServerEvent('nl_interactions:gestionEmployerPatronEms')
AddEventHandler('nl_interactions:gestionEmployerPatronEms', function(typeEvent, target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(target)

    if typeEvent == "recruter" then 
        if xPlayer.job.grade_name == "boss" then
			if xTarget ~= nil then	
				xTarget.setJob(xPlayer.job.name, 0)
				--TriggerClientEvent('nl_interactions:notify', xPlayer.source, 'EMS', 'Vous avez recruter <b style="color:#00FF00;">' .. xTarget.name, 5000, 'success')
				--TriggerClientEvent('nl_interactions:notify', xTarget.source, 'EMS', 'Vous avez été recruter par <b style="color:#00FF00;">' .. xPlayer.name, 5000, 'success')
			else
				--TriggerClientEvent('nl_interactions:notify', xPlayer.source, 'EMS', 'Le Joueur est trop loin !', 5000, 'error')
			end
		end
    end
    if typeEvent == "promouvoir" then 
        if xPlayer.job.grade_name == "boss" then
			if xTarget ~= nil then
				if xTarget.job.grade < 5 then 
					xTarget.setJob(xPlayer.job.name, xTarget.job.grade + 1)
					--TriggerClientEvent('nl_interactions:notify', xPlayer.source, 'EMS', 'Vous avez promu <b style="color:#00FF00;">' .. xTarget.name, 5000, 'success')
					--TriggerClientEvent('nl_interactions:notify', xTarget.source, 'EMS', 'Vous avez été promu par <b style="color:#00FF00;">' .. xPlayer.name, 5000, 'success')
				else 
					--TriggerClientEvent('nl_interactions:notify', xPlayer.source, 'EMS', 'Vous ne pouvez pas promouvoir plus !', 5000, 'error')
				end
			else
				--TriggerClientEvent('nl_interactions:notify', xPlayer.source, 'EMS', 'Le Joueur est trop loin !', 5000, 'error')
			end
        end
    end
    if typeEvent == "virer" then 
        if xPlayer.job.grade_name == "boss" then
			if xTarget ~= nil then
				xTarget.setJob("unemployed", 0)
				--TriggerClientEvent('nl_interactions:notify', xPlayer.source, 'EMS', 'Vous avez virer <b style="color:red;">' .. xTarget.name, 5000, 'success')
				--TriggerClientEvent('nl_interactions:notify', xTarget.source, 'EMS', 'Vous avez été virer par <b style="color:red;">' .. xPlayer.name, 5000, 'success')
			else
				--TriggerClientEvent('nl_interactions:notify', 'error', 'Le Joueur est trop loin !', 5000, 'EMS')
			end
		end
    end
end)

ESX.RegisterServerCallback('nl_interactions:getPhoneNumberBySource', function(source,cb)
	if source ~= nil then 
        number = exports['roadphone']:getPhoneNumber()
		if number ~= nil then 
			cb(number)
		else 
			cb(false)
		end
	end
end)

RegisterNetEvent('nl_interactions:givingWheelChair')
AddEventHandler('nl_interactions:givingWheelChair', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	exports.ox_inventory:AddItem(xPlayer.source, 'wheelchair', 1)
end)

RegisterNetEvent('nl_interactions:demandeAccueil')
AddEventHandler('nl_interactions:demandeAccueil', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()

	for i=1, #xPlayers, 1 do
		local xTarget = ESX.GetPlayerFromId(xPlayers[i])
		if xTarget.job.name == "ambulance" then
-- [[ CHANGE ]] --
			--[[exports["lb-phone"]:SendNotification(xTarget.source, {
                title = "Centrale EMS", -- the title of the notification
                content = xPlayer.getName() .. " sonne a l'accueil !", -- the description of the notification
                icon = "https://i.imgur.com/hsEDihp.png", -- the icon of the notification (optional)
            })
            ]]--
		end
	end
end)

RegisterNetEvent('nl_interactions_ems:demandeDeRendezVous')
AddEventHandler('nl_interactions_ems:demandeDeRendezVous', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()

	for i=1, #xPlayers, 1 do
		local xTarget = ESX.GetPlayerFromId(xPlayers[i])
		if xTarget.job.name == "ambulance" then
-- [[ CHANGE ]] --
			--[[exports["lb-phone"]:SendNotification(xPlayer.source, {
                title = "Centrale EMS", -- the title of the notification
                content = xPlayer.getName() .." a fait une demande de rendez vous !", -- the description of the notification
                icon = "https://i.imgur.com/hsEDihp.png", -- the icon of the notification (optional)
            })]]--
		end
	end
end)

function removeItem(src, item, count, metadata)
    if (src == nil) then src = source end
    if (src == nil) then return end

    if (config.oxInventory) then
        exports.ox_inventory:RemoveItem(src, item, count, metadata)
    else 
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.removeInventoryItem(item, count)
    end
end
exports('removeItem', removeItem)

RegisterServerEvent('nl_interactions:removeItem')
AddEventHandler('nl_interactions:removeItem', function(src, item, count, metadata)
    removeItem(src, item, count, metadata)
end)

function addItem(source, item, count, metadata)
    if (source == nil) then return end
    if (Config.OxInventory) then
        local Inventory = exports.ox_inventory
        local canCarryItem = Inventory:CanCarryItem(source, item, count)
        if (canCarryItem) then
            Inventory:AddItem(source, item, count, metadata)
            return true
        else
-- [[ CHANGE ]] --
            --TriggerClientEvent('bixbi_core:Notify', source, 'error', 'You cannot carry this item')
            return false
        end
    else
        if (xPlayer.canCarryItem(item, count)) then
            xPlayer.addInventoryItem(item, count)
            return true
        else
-- [[ CHANGE ]] --
            --TriggerClientEvent('bixbi_core:Notify', source, 'error', 'You cannot carry this item')
            return false
        end
    end
end
exports('addItem', addItem)

AddEventHandler('nl_interactions:addItem', function(item, count)
    return addItem(source, item, count)
end)

function itemCount(source, item, metadata)
    if (source == nil) then return end
    if (config.cxInventory) then
        local itemCount = exports.ox_inventory:Search(source, 'count', item, metadata)
        if (itemCount == nil) then itemCount = 0 end
		return itemCount
	else
		local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.getInventoryItem(item).count
	end
end
exports('itemCount', itemCount)

ESX.RegisterServerCallback('nl_interactions:itemCount', function(source, cb, item, metadata)
    cb(itemCount(source, item, metadata))
end)
RegisterServerEvent('nl_interactions:itemCount')
AddEventHandler('nl_interactions:itemCount', function(source, item, metadata)
    return itemCount(source, item, metadata)
end)

function canHoldItem(source, item, count)
    if (source == nil) then return end
    if (Config.OxInventory) then
		return exports.ox_inventory:CanCarryItem(source, item, count)
	else
		local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.canCarryItem(item, count)
	end
end
exports('canHoldItem', canHoldItem)

ESX.RegisterServerCallback('nl_interactions:canHoldItem', function(source, cb, item, count)
    cb(canHoldItem(source, item, count))
end)
RegisterServerEvent('nl_interactions:canHoldItem')
AddEventHandler('nl_interactions:canHoldItem', function(source, item, count)
    return canHoldItem(source, item, count)
end)

RegisterServerEvent('nl_interactions:addToInstance')
AddEventHandler('nl_interactions:addToInstance', function(source, instanceId)
    SetPlayerRoutingBucket(source, instanceId)
        if (instanceId == 0) then return end
    SetRoutingBucketEntityLockdownMode(instanceId, 'strict')
    SetRoutingBucketPopulationEnabled(instanceId, false)
end)

RegisterServerEvent('nl_interactions:removeFromInstance')
AddEventHandler('nl_interactions:removeFromInstance', function(source)
    if (GetPlayerRoutingBucket(source) ~= 0) then TriggerEvent('nl_interactions:addToInstance', source, 0) end
end)

ESX.RegisterServerCallback('nl_interactions:removeItemsAfterRPDeath', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if config.oxInventory and config.removeItemsAfterRPDeath then
		exports.ox_inventory:ClearInventory(xPlayer.source)
		return cb()
	end

	if config.removeCashAfterRPDeath then
		if xPlayer.getMoney() > 0 then
			xPlayer.removeMoney(xPlayer.getMoney(), "Death")
		end

		if xPlayer.getAccount('black_money').money > 0 then
			xPlayer.setAccountMoney('black_money', 0, "Death")
		end
	end

	if config.removeItemsAfterRPDeath then
		for i=1, #xPlayer.inventory, 1 do
			if xPlayer.inventory[i].count > 0 then
				xPlayer.setInventoryItem(xPlayer.inventory[i].name, 0)
			end
		end
	end

	if config.oxInventory then return cb() end

	local playerLoadout = {}
	if config.removeWeaponsAfterRPDeath then
		for i=1, #xPlayer.loadout, 1 do
			xPlayer.removeWeapon(xPlayer.loadout[i].name)
		end
	else -- save weapons & restore em' since spawnmanager removes them
		for i=1, #xPlayer.loadout, 1 do
			table.insert(playerLoadout, xPlayer.loadout[i])
		end

		-- give back wepaons after a couple of seconds
		CreateThread(function()
			Wait(5000)
			for i=1, #playerLoadout, 1 do
				if playerLoadout[i].label ~= nil then
					xPlayer.addWeapon(playerLoadout[i].name, playerLoadout[i].ammo)
				end
			end
		end)
	end

	cb()
end)

ESX.RegisterServerCallback('nl_interactions:illegalTaskBlacklist', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    -- var = check (and) true (or) false
    local result = config.illegalTaskBlacklist[xPlayer.job.name] == true and true or false
    cb(result)
end)

ESX.RegisterServerCallback('nl_interactions:jobCount', function(source, cb, job)
    cb(#ESX.GetExtendedPlayers('job', job))
end)