--[[ esx_society register event ]]
TriggerEvent('esx_society:registerSociety', 'ambulance', 'EMS', 'society_ambulance', 'society_ambulance', 'society_ambulance', {type = 'public'})

--[[ Define locals ]]--
local BlipsList = {}
local count = 1

--[[ Discord webhook ]]--
function SendToDiscordWithSpecialURL(name,message,color,url)
    local DiscordWebHook = url
	local embeds = {
		{
			["title"]=message,
			["type"]="rich",
			["color"] =color,
			["footer"]=  {
				["text"]= "",
			},
		}
	}
    if message == nil or message == '' then return FALSE end
    PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end

-- [[ Register item ]]--
ESX.RegisterUsableItem('wheelchairitem', function(playerId)

    local xPlayer = ESX.GetPlayerFromId(playerId)
	local count = exports.ox_inventory:Search(xPlayer.source, 'count', 'wheelchair')

	if count ~= nil and count > 0 then
		exports.ox_inventory:RemoveItem(xPlayer.source, 'wheelchair', 1)
		
		-- CHANGE THIS
		TriggerClientEvent('nl_interactions:createWheelChair', playerId)
	end
end)