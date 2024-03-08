fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'arlenbales'
lua54 'yes'

shared_script '@ox_lib/init.lua'

server_scripts {
	'@mysql-async/lib/MySQL.lua',

	'config.lua',
	'server/main.lua'
}

client_scripts {
	'config.lua',
	'client/main.lua'
}


