fx_version  'cerulean'
game        'gta5'
lua54       'cuh'

name        'Advanced Trucking Simulator'
description 'An advnaced trucking simulator job, with convoys and more.'
author      'Project 7'
version     'Alpha-1b'

shared_scripts {
    '@ox_lib/init.lua',
    'configs/shared.lua'
}

client_scripts {
    'client/**/*.lua',
    'configs/client.lua',
    '@sleepless_interact/init.lua'
}
server_scripts {
    'server/main.lua',
    'server/storage.lua',
    'configs/server.lua',
    '@oxmysql/lib/MySQL.lua'
}
dependencies {
    'ox_lib',
    'ox_target', --uncomment if you want to use ox_target
    'oxmysql',
    'sleepless_interact', --uncomment if you want to use sleepless_interact
    'fivem-freecam'
}