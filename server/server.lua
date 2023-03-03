ESX = exports['es_extended']:getSharedObject()

ESX.RegisterServerCallback("provjera", function(source, cb)
  local player = ESX.GetPlayerFromId(source)
  if player then
      local playerGroup = player.getGroup()
      if playerGroup then 
          cb(playerGroup)
      else
          cb("user", false)
      end
  else
      cb("user", false)
  end
end)

RegisterServerEvent('obrisirep', function(admin, id, ime, razlog)
  local xPlayer = ESX.GetPlayerFromId(admin) 
  local grupa = xPlayer.getGroup()
  if Config.AllowedGroups[grupa] then 
  MySQL.Sync.execute("DELETE FROM `reportovi` WHERE ajdi = @id AND razlog = @razlog",{
        ["@id"] = id,
        ["@razlog"] = razlog
    })
    reportlogs(_U('delete'), _U('deletelog', GetPlayerName(admin), razlog, ime))
  else 
    DropPlayer(source, 'Protection')
    end
end)

RegisterServerEvent('tp', function(id, brojreportova)
  local admin = ESX.GetPlayerFromId(source)
  local igrac = ESX.GetPlayerFromId(id)
  local igraccoords = igrac.getCoords()
  local grupa = admin.getGroup()
  if Config.AllowedGroups[grupa] then 
  admin.setCoords(igraccoords)
  reportlogs(_U('teleport'), _U('teleportlog2', GetPlayerName(source), GetPlayerName(igrac.source)))
else 
  DropPlayer(source, 'Protection')
  end
end)

RegisterServerEvent('sendcar', function(id, vehicle)
  local xAdmin = ESX.GetPlayerFromId(source)
  local grupa = xAdmin.getGroup()
  if Config.AllowedGroups[grupa] then 
      if id then
        local xIgrac = ESX.GetPlayerFromId(id)
        local grupa = xAdmin.getGroup()
        local getajjeliuauto = GetVehiclePedIsIn(GetPlayerPed(id), false)
                if getajjeliuauto then DeleteEntity(getajjeliuauto) end -- obrisi mu model ako ima vec auto i sjedi u autu da se ne ubaga
                local vozilo = CreateVehicle(GetHashKey(vehicle), GetEntityCoords(GetPlayerPed(id)), GetEntityHeading(GetPlayerPed(id)), true, true)
                while not DoesEntityExist(vozilo) do Wait(500) end -- jeli model postoji?
                SetPedIntoVehicle(GetPlayerPed(id), vozilo, -1)
                TriggerClientEvent('chat:addMessage', xAdmin.source, {
                  args = {_U('sendpersoncar'), _U('succsentcar', GetPlayerName(xIgrac.source))}
                })
  reportlogs(_U('sendcar'), _U('sendcarlog', GetPlayerName(xAdmin.source), vehicle, GetPlayerName(xIgrac.source)))
  else 
  DropPlayer(source, 'Protection')
  end
end
end)

RegisterServerEvent('revive', function(id)
  local xPlayer = ESX.GetPlayerFromId(source)
  local grupa = xPlayer.getGroup()
  if Config.AllowedGroups[grupa] then 
  TriggerClientEvent('esx_ambulancejob:revive', id)
  reportlogs(_('revivetitle'), _U('revivelog', GetPlayerName(source), GetPlayerName(id)))
else 
  DropPlayer(source, 'Protection')
  end
end)

RegisterServerEvent('heal', function(id)
  local igrac = ESX.GetPlayerFromId(id)
  local xPlayer = ESX.GetPlayerFromId(source) 
  local grupa = xPlayer.getGroup()
  if Config.AllowedGroups[grupa] then 
  igrac.triggerEvent('esx_basicneeds:healPlayer')
  reportlogs(_('heal'), _U('heallog', GetPlayerName(source), GetPlayerName(igrac.source)))
else 
  DropPlayer(source, 'Protection')
  end
end)

RegisterServerEvent('bring', function(id)
  local admin = ESX.GetPlayerFromId(source)
  local igrac = ESX.GetPlayerFromId(id)
  local admincoords = admin.getCoords()
  local grupa = admin.getGroup()
  if Config.AllowedGroups[grupa] then 
  igrac.setCoords(admincoords)
  reportlogs(_('teleport'), _U('teleportlog', GetPlayerName(source), GetPlayerName(igrac.source)))
else 
  DropPlayer(source, 'Protection')
  end
end)

RegisterServerEvent('odgovori', function(id, kastm)
    local xPlayer = ESX.GetPlayerFromId(source)
    local grupa = xPlayer.getGroup()
    if Config.AllowedGroups[grupa] then 
    TriggerClientEvent('chat:addMessage', id, {
        args = {_U('answer'), _U('replied', GetPlayerName(xPlayer.source), kastm)}
      })
      reportlogs(_U('answered'), _U('answeredplayerlog', GetPlayerName(source), GetPlayerName(id), kastm))
    else 
      DropPlayer(source, 'Protection')
      end
  end)

  RegisterServerEvent('posalji', function(id, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    local igrac = ESX.GetPlayerFromId(id)
    local grupa = xPlayer.getGroup()
    if Config.AllowedGroups[grupa] then 
    igrac.addInventoryItem(item, 1)
    TriggerClientEvent('chat:addMessage', igrac.source, {
        args = {_U('senditem'), _U('hassended', GetPlayerName(xPlayer.source), item)}
      })
      reportlogs(_U('sendingitems'), _U('hassendedlog', GetPlayerName(source), item, GetPlayerName(igrac.source)))
    else 
      DropPlayer(source, 'Protection')
      end
  end)

local vreme = 0
local check = {}
local wait = 60

RegisterCommand(Config.ReportCommand, function(source, args, rawCommand)
  if (not check[source] or check[source] <= os.time() - wait) then
    check[source] = os.time()
    TriggerClientEvent('chat:addMessage', source, {
      args = {_U('help'), _U('askedforhelp')}
    })
    exports.oxmysql:execute('INSERT INTO reportovi (`ime`, `ajdi`, `razlog`) VALUES(@ime, @ajdi, @razlog)', {
      ['@ime'] = GetPlayerName(source),
      ['@ajdi'] = source,
      ['@razlog'] = table.concat(args, " ")
  })
  reportlogs(_U('report'), _U('reportlog', GetPlayerName(source), table.concat(args, " ")))
    vreme = wait*1000
    local xPlayers = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        local grupa = xPlayer.getGroup()
          if Config.AllowedGroups[grupa] then
              TriggerClientEvent('chat:addMessage', xPlayer.source, {
                args = {_U('help'), _U('askedforhelpadmin', GetPlayerName(source), table.concat(args, " "))}
              })
          end
    end
    while vreme ~= 0 do
      vreme = vreme - 1000
      Wait(1000)
    end
    end
end, false)

ESX.RegisterServerCallback("reportovi", function(source, cb)
	local reportovi = {}
	MySQL.Async.fetchAll("SELECT ime, ajdi, razlog FROM reportovi", function(result)
		for i=1, #result, 1 do
			table.insert(reportovi, {ime = result[i].ime, ajdi = result[i].ajdi, razlog = result[i].razlog})
		end
		cb(reportovi)
	end)
end)

function reportlogs(name, message)
  local vrijeme = os.date('*t')
  local poruka = {
      {
          ["color"] = 2123412,--
          ["title"] = "".. name .."",
          ["description"] = message,
      }
    }
  PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({username = 'Report logs', embeds = poruka, avatar_url = Config.Avatar}), { ['Content-Type'] = 'application/json' })
end
