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
    for _, status in ipairs(jsonData.result[1].status) do
        if status.code == code then
            return tonumber(status.value)
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
        local cur_current = extractValueFromTuyaResponse(jsonData, "cur_current")
        local cur_voltage = extractValueFromTuyaResponse(jsonData, "cur_voltage")
        local cur_power = extractValueFromTuyaResponse(jsonData, "cur_power")
        print("PANNEAUX : cur_power:" .. cur_power)
        print("PANNEAUX : cur_voltage:" .. cur_voltage)
        print("PANNEAUX : cur_current:" .. cur_current)
        local panneauSolaireId = 40
        commandArray[1] = {['UpdateDevice'] = panneauSolaireId .. "|0|" .. cur_current}
    end
end

return commandArray
