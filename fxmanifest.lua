--[[ FX Information ]]--
fx_version   'cerulean'
use_experimental_fxv2_oal 'yes'
lua54        'yes'
games        { 'rdr3', 'gta5' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

--[[ Resource Information ]]--
name         'ox_lib'
author       'Overextended'
version      '3.17.0'
license      'LGPL-3.0-or-later'
repository   'https://github.com/overextended/ox_lib'
description  'A library of shared functions to utilise in other resources.'

--[[ Manifest ]]--
dependencies {
	'/server:7290',
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

shared_script 'resource/init.lua'

shared_scripts {
    'resource/**/shared.lua',
    -- 'resource/**/shared/*.lua'
}

client_scripts {
    'resource/**/client.lua',
    'resource/**/client/*.lua'
}

server_scripts {
	'imports/callback/server.lua',
    'resource/**/server.lua',
    'resource/**/server/*.lua',
}

