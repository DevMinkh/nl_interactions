--[[ FX Information ]]--
fx_version   'cerulean'
use_experimental_fxv2_oal 'yes'
lua54        'yes'
games        { 'rdr3', 'gta5' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

--[[ Resource Information ]]--
name         'nl_interactions WIP'
author       'DevMinkh'
version      '0.00.1'
license      'LGPL-3.0-or-later'
repository   ''
description  'NativeLife - RP | Interactions'

--[[ File Management ]]--
shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
	'shared/config.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server/*.lua'
}

ui_page "web/index.html" 

files {
	'locales/*.json',
	'web/index.html',
	'web/script.js',
	'web/style.css',
	'web/img/*.png',
}

dependencies {
	'ox_lib',
	'ox_target',
	'ox_inventory',
	'roadphone',
}
