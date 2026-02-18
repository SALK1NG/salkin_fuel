fx_version 'cerulean'
game 'gta5'

author 'SALKIN.G'
version '1.0'
description 'Modernes Tankstellen Script'


ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

client_scripts {
    '@ox_lib/init.lua',
    'client.lua',
    'config.lua'
}

server_scripts {
    'server.lua',
    'config.lua'
}

dependencies {
    'es_extended',
    'ox_target',
    'ox_lib'
}