--
-- Librairie pour interagir avec les PAC Atlantic via le JAR atlantic-heat-pump-cli.
-- Le JAR communique avec le cloud Atlantic/CozyTouch (login/password + device-url par piece).
--
-- Dependances : lib_conf.lua doit etre charge avant (pour ATLANTIC_LOGIN, ATLANTIC_PASSWORD, ATLANTIC_JAR_PATH)
--

-- Construit la commande de base : java -jar <jar> --login <login> --password <pwd>
local function atlanticCmd()
    return 'java -jar ' .. ATLANTIC_JAR_PATH
        .. " --login '" .. ATLANTIC_LOGIN .. "'"
        .. " --password '" .. ATLANTIC_PASSWORD .. "'"
end

-- Recupere le statut courant de la PAC.
-- Retourne 'On' ou 'Off' en parsant "Power      : ON"
function getAtlanticPacStatus(deviceUrl)
    print('[ATLANTIC-PAC] Recuperation du statut courant de la PAC (' .. deviceUrl .. ')...')
    local cmd = atlanticCmd() .. ' status --device ' .. deviceUrl
    local handle = io.popen(cmd .. ' 2>&1')
    local output = handle:read('*a')
    handle:close()
    print('[ATLANTIC-PAC] Reponse status JAR : ' .. output)
    if output:match('Power%s*:%s*ON') then
        print('[ATLANTIC-PAC] Statut PAC : On')
        return 'On'
    end
    print('[ATLANTIC-PAC] Statut PAC : Off')
    return 'Off'
end

-- Allume la PAC
function startAtlanticPac(deviceUrl)
    print('[ATLANTIC-PAC] Envoi commande ON (' .. deviceUrl .. ')...')
    os.execute(atlanticCmd() .. ' power on --device ' .. deviceUrl)
    print('[ATLANTIC-PAC] Commande ON envoyee')
end

-- Eteint la PAC
function stopAtlanticPac(deviceUrl)
    print('[ATLANTIC-PAC] Envoi commande OFF (' .. deviceUrl .. ')...')
    os.execute(atlanticCmd() .. ' power off --device ' .. deviceUrl)
    print('[ATLANTIC-PAC] Commande OFF envoyee')
end

-- Recupere la temperature courante mesuree par la PAC.
-- Retourne la temperature (nombre) ou nil en cas d'erreur.
function getAtlanticTemperature(deviceUrl)
    print('[ATLANTIC-PAC] Recuperation de la temperature courante (' .. deviceUrl .. ')...')
    local cmd = atlanticCmd() .. ' status --device ' .. deviceUrl
    local handle = io.popen(cmd .. ' 2>&1')
    local output = handle:read('*a')
    handle:close()
    local temp = output:match('Current%s*:%s*([%d%.]+)')
    if temp then
        print('[ATLANTIC-PAC] Temperature courante : ' .. temp .. '°C')
        return tonumber(temp)
    end
    print('[ATLANTIC-PAC] Impossible de parser la temperature courante')
    return nil
end

-- Fonction generique pour les scripts device.
-- Verifie si le device a change, compare avec le statut reel de la PAC,
-- et envoie la commande uniquement si necessaire.
function handleAtlanticRadiateur(deviceName, deviceUrl)
    if (devicechanged[deviceName]) then
        local newStatus = devicechanged[deviceName]
        print('[' .. deviceName .. '] Changement demande : ' .. newStatus)
        local currentStatus = getAtlanticPacStatus(deviceUrl)
        if (newStatus == currentStatus) then
            print('[' .. deviceName .. '] Statut identique (' .. currentStatus .. '), aucune action necessaire')
        else
            print('[' .. deviceName .. '] Changement de statut : ' .. currentStatus .. ' --> ' .. newStatus)
            if (newStatus == 'On') then
                startAtlanticPac(deviceUrl)
            else
                stopAtlanticPac(deviceUrl)
            end
        end
    end
end
