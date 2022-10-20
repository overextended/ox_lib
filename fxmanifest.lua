--[[ FX Information ]]--
fx_version   'cerulean'
use_experimental_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'

--[[ Resource Information ]]--
name         'ox_lib'
author       'Linden'
version      '2.14.1'
license      'LGPL-3.0-or-later'
repository   'https://github.com/overextended/ox_lib'
description  'A library of shared functions to utilise in other resources.'

--[[ Manifest ]]--
dependencies {
	'/server:5104',
    '/onesync',
}

ui_page 'web/build/index.html'

files {
    'init.lua',
    'imports/**/client.lua',
    'imports/**/shared.lua',
    'web/build/index.html',
    'web/build/**/*',
	'locales/*.json',
}

shared_script 'resource/main.lua'

shared_scripts {
    'resource/**/shared.lua',
    'resource/**/shared/*.lua'
}

client_scripts {
	'imports/callback/client.lua',
    'resource/**/client.lua',
    'resource/**/client/*.lua'
}

server_scripts {
	'imports/callback/server.lua',
    'resource/**/server.lua',
    'resource/**/server/*.lua'
}

