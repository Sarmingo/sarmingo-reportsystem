if Config.UsingLegacy then
ESX = exports['es_extended']:getSharedObject()
else
    ESX = nil
    Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)
    end
lib.locale()



RegisterCommand(Config.CommandToOpenList, function()
    ESX.TriggerServerCallback('provjera', function(grupa) 
            if Config.AllowedGroups[grupa] then 
            TriggerEvent('povuci')
            else
                ESX.ShowNotification(_U('donthaveperm'))
            end
        end)
end)

RegisterNetEvent('povuci', function()
    ESX.TriggerServerCallback('reportovi', function(rep) 
        local report = {}
        for k,v in pairs(rep) do 
            report[#report + 1] = {
                title = '[ID : ' ..v.ajdi.. ' - ' ..v.ime.. ']',
                description = v.razlog,
                args= {ime = v.ime, id = v.ajdi, razlog = v.razlog},
                event = 'funkcije'
            }
            lib.registerContext({
                id = 'report',
                title = _U('reports'),
                options = report
            })
            lib.showContext('report')
            end
        end)
end)
    
    RegisterNetEvent('funkcije', function(reportic)
        lib.registerContext({
            id = 'reports',
            title = reportic.ime.. ' : ' ..reportic.id,
            options = {
                {
                    title = _U('deleterep'),
                    icon = Config.Icons["deletereport"].icon,
                    onSelect = function()
                        TriggerServerEvent('obrisirep', GetPlayerServerId(PlayerId()), reportic.id, reportic.ime, reportic.razlog)
                        ESX.ShowNotification(_U('deleted'))
                    end,    
                },
                {
                    title = _U('tptotheperson'),
                    icon = Config.Icons["tptoperson"].icon,
                    onSelect = function()
                        TriggerServerEvent('tp', reportic.id)
                        ESX.ShowNotification(_U('successfullyteleported', reportic.ime))
                    end, 
                },
                {
                    title = _U('bringperson'),
                    icon = Config.Icons["bringperson"].icon,
                    onSelect = function()
                        TriggerServerEvent('bring', reportic.id)
                        ESX.ShowNotification(_U('succtepplayer', reportic.ime))
                    end, 
                },
                {
                    title = _U('replyperson'),
                    icon = Config.Icons["reply"].icon,
                    onSelect = function()
                        local input = lib.inputDialog(_U('answerperson', reportic.ime), {_U('yourreply')})
    
                        if not input then return end
                        local odgovor = input[1]
    
                        TriggerServerEvent('odgovori', reportic.id, odgovor)
                        ESX.ShowNotification(_U('succanswered', reportic.ime, odgovor))
                    end, 
                },
                {
                    title = _U('sendpersonmed'),
                    icon = Config.Icons["medkit"].icon,
                    onSelect = function()
                        TriggerServerEvent('posalji', reportic.id, Config.MedkitName)
                        ESX.ShowNotification(_U('succsentmed', reportic.ime))
                    end, 
                },
                {
                    title = _U('sendpersontool'),
                    icon = Config.Icons["tools"].icon,
                    onSelect = function()
                        TriggerServerEvent('posalji', reportic.id, Config.FixKitName)
                        ESX.ShowNotification(_U('succsenttool', reportic.ime))
                    end, 
                },
                {
                    title = _U('sendpersoncar'),
                    icon = Config.Icons["sendcar"].icon,
                    onSelect = function()
                        TriggerServerEvent('sendcar', reportic.id, Config.CarSpawn)
                        ESX.ShowNotification(_U('succsentcar', reportic.ime))
                    end, 
                },
                {
                    title = _U('sendpersonmotorcycle'),
                    icon = Config.Icons["sendmotorcycle"].icon,
                    onSelect = function()
                        TriggerServerEvent('sendcar', reportic.id, Config.MotorcycleSpawn)
                        ESX.ShowNotification(_U('succsentmotorcycle', reportic.ime))
                    end, 
                },
                {
                    title = _U('revive'),
                    icon = Config.Icons["revive"].icon,
                    onSelect = function()
                        TriggerServerEvent('revive', reportic.id)
                        ESX.ShowNotification(_U('succrevive', reportic.ime))
                    end, 
                },
                {
                    title = _U('healperson'),
                    icon = Config.Icons["heal"].icon,
                    onSelect = function()
                        TriggerServerEvent('heal', reportic.id)
                        ESX.ShowNotification(_U('succheal', reportic.ime))
                    end, 
                },
            },
        })
        lib.showContext('reports')
    end)
