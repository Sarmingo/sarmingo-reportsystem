fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'
author 'Sarmingooo#0850'

shared_script {
    '@es_extended/locale.lua',
    '@mysql-async/lib/MySQL.lua',
    'locales/*.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts{
'server/server.lua'
}

client_scripts{
'client/client.lua'
}

dependencies {
    'ox_lib'
}
