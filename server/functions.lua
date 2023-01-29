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
ESX.RegisterUsableItem('wheelchair', function(playerId)

    local xPlayer = ESX.GetPlayerFromId(playerId)
	local count = exports.ox_inventory:Search(xPlayer.source, 'count', 'wheelchair')

	if count ~= nil and count > 0 then
		exports.ox_inventory:RemoveItem(xPlayer.source, 'wheelchair', 1)
		
		TriggerClientEvent('nl_interactions:createWheelChair', playerId)
	end
end)

-- [[ Versioncheck ]]--
AddEventHandler('nl_interactions:versionCheck', function(resourceName, currentVersion, url)
    if (currentVersion == nil or url == nil) then return end
    CreateThread(function()
        Citizen.Wait(10000)

        local latestVersion = nil
        local outdated = '^3[' .. resourceName .. ']^7 - You can upgrade to ^2v%s^7 (currently using ^1v%s^7)'
        PerformHttpRequest(url, function (errorCode, resultData, resultHeaders)
            if errorCode ~= 200 then print("Returned error code:" .. tostring(errorCode)) else
                local data, version = tostring(resultData)
                for line in data:gmatch("([^\n]*)\n?") do
                    if line:find('^version ') then version = line:sub(10, (line:len(line) - 1)) break end
                end         
                latestVersion = version
                if latestVersion and currentVersion ~= latestVersion then 
                    print(outdated:format(latestVersion, currentVersion))
                end
            end
        end)
    end)
end)
