local function versionCheckPrint(_type, log)
    local color = _type == 'success' and '^2' or '^1'
    print(('^5[%s]%s %s^7'):format(GetCurrentResourceName(), color, log))
end

local function CheckVersion()
    PerformHttpRequest('https://raw.githubusercontent.com/Rexshack-RedM/rsg-moonshiner/main/version.txt', function(err, text, headers)
        local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')
        if not text then 
            versionCheckPrint('error', 'Currently unable to run a version check.')
            return 
        end
        if text == currentVersion then
            versionCheckPrint('success', 'You are running the latest version.')
        else
            versionCheckPrint('error', ('You are currently running an outdated version, please update to version %s'):format(text))
        end
    end)
end

-- CheckVersion()
