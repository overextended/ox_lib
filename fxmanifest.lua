-- Library
-- Copyright (C) 2021	Linden <https://github.com/thelindat>

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <https://www.gnu.org/licenses/gpl-3.0.html>

--[[ FX Information ]]--
fx_version   'cerulean'
use_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'

--[[ Resource Information ]]--
name         'pe-lualib'
author       'Linden'
version      '1.0.1'
repository   'https://github.com/project-error/pe-lualib'
description  'A library of shared functions to utilise in other resources.'

--[[ Manifest ]]--
dependencies {
    '/onesync',
}

client_scripts {
    'resource/client/**.lua'
}

files {
    'init.lua',
    'imports/**/client.lua',
    'imports/**/shared.lua',
}

server_scripts {
	'version.lua'
}