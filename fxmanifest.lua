name 'ox_lib'
author 'Overextended'
version '3.42.2'
license 'LGPL-3.0-or-later'
fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
games { 'rdr3', 'gta5' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

dependencies {
    '/onesync',
    'require',
}

fx_dependencies {
    'require: 1.0.2',
}

shared_scripts {
    'resource/init.lua',
    'resource/**/shared.lua'
}

client_scripts {
    'resource/**/client.lua',
    'resource/**/client/*.lua'
}

server_scripts {
    'imports/callback/server.lua',
    'imports/hook/shared.lua',
    'imports/registerHook/shared.lua',
    'imports/getFilesInDirectory/server.lua',
    'resource/**/server.lua',
    'resource/**/server/*.lua',
}

client_script 'dist/client.js'
server_script 'dist/dummy.js'

ui_page 'web/build/index.html'

files {
	'init.lua',
	'require.lua',
	'resource/settings.lua',
	'imports/**/client.lua',
	'imports/**/shared.lua',
	'locales/*.json',
	'modules/*.lua',
	'modules/**/*.lua',
	'dist/*.json',
	'web/build/*.html',
	'web/build/assets/*.js',
	'web/build/assets/*.css',
	'web/build/fonts/*.ttf',
}
