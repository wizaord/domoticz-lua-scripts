--
-- Librairie pour interagir avec la PAC Fujitsu via le JAR fujitsu-heat-pump-cli.
-- Le JAR communique en local avec l'adaptateur WiFi AirStage (UTY-TFSXH3), sans cloud.
--
-- Dependances : lib_conf.lua doit etre charge avant (pour FUJITSU_PAC_SALON_IP et FUJITSU_JAR_PATH)
--

-- Construit la commande de base : java -jar <jar> --ip <ip>
local function fujitsuCmd(ip)
    return 'java -jar ' .. FUJITSU_JAR_PATH .. ' --ip ' .. ip
end

-- Recupere le statut courant de la PAC.
-- Retourne 'On' ou 'Off'
function getFujitsuPacStatus(ip)
    print('[FUJITSU-PAC] Recuperation du statut courant de la PAC (' .. ip .. ')...')
    local handle = io.popen(fujitsuCmd(ip) .. ' status 2>&1')
    local output = handle:read('*a')
    handle:close()
    print('[FUJITSU-PAC] Reponse status JAR : ' .. output)
    if output:match('Alimentation%s*:%s*ON') then
        print('[FUJITSU-PAC] Statut PAC : On')
        return 'On'
    end
    print('[FUJITSU-PAC] Statut PAC : Off')
    return 'Off'
end

-- Allume la PAC
function startFujitsuPac(ip)
    print('[FUJITSU-PAC] Envoi commande ON (' .. ip .. ')...')
    os.execute(fujitsuCmd(ip) .. ' on')
    print('[FUJITSU-PAC] Commande ON envoyee')
end

-- Eteint la PAC
function stopFujitsuPac(ip)
    print('[FUJITSU-PAC] Envoi commande OFF (' .. ip .. ')...')
    os.execute(fujitsuCmd(ip) .. ' off')
    print('[FUJITSU-PAC] Commande OFF envoyee')
end
