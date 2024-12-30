--
-- Ce script va s'executer toutes les 5 minutes
-- Il appelle l'API TUYA pour récupérer le retour JSON de TUYA.
-- On fait appel à un script bash car compliqué le chiffrement de tuya (je verrai un jour pour le faire en lua)
-- Cette réponse est ensuite interprétéé pour mettre à jour domoticz
--
package.path = package.path .. ';' .. '/home/wizaord/domoticz/scripts/lua/?.lua'
require("lib_conf")

local json = require("dkjson")

currentTime = os.time()
currentDate = os.date("*t", currentTime)

commandArray = {}

function isTimeToCallTuya()
    -- call tuya every 5 minutes
    return currentDate.min % 5 == 0
end

function extractValueFromTuyaResponse(jsonData, code)
    for _, property in ipairs(jsonData.result.properties) do
        if property.code == code then
            return tonumber(property.value)
        end
    end
    return nil
end

if (isTimeToCallTuya()) then
    print("PANNEAUX : Time to fetch TUYA to get the solar value")
    local clientId=TUYA_CLIEND_ID
    local clientSecret=TUYA_CLIENT_SECRET
    local solarPanelDeviceId="bffcf08195a7696fb32jzh"
    local command = "./scripts/lua/scripts/getPanneauxSolaireTuyaValues.bash " .. clientId .. " " .. clientSecret .. " " .. solarPanelDeviceId
    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()
    print("DEBUG " .. result)
    local jsonData, pos, err = json.decode(result, 1, nil)
    if err then
        print("Error:", err)
    else
        -- Extract the cur_current value
        local out_power_in_watt = extractValueFromTuyaResponse(jsonData, "out_power") / 100
        local energy_in_kwh = extractValueFromTuyaResponse(jsonData, "energy")
        local temperature = extractValueFromTuyaResponse(jsonData, "temperature") / 10
        print("PANNEAUX : out_power_in_watt:" .. out_power_in_watt)
        print("PANNEAUX : energy_in_kwh:" .. energy_in_kwh)
        local panneauSolaireId = 40
        commandArray[1] = {['UpdateDevice'] = panneauSolaireId .. "|0|" .. out_power_in_watt}
        commandArray[2] = {['UpdateDevice'] = 42 .. "|0|" .. out_power_in_watt .. ";" .. energy_in_kwh}
        local panneauSolaireTemperatureId = 41
        commandArray[3] = {['UpdateDevice'] = panneauSolaireTemperatureId .. "|0|" .. temperature}
    end
end

return commandArray
