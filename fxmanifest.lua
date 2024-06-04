fx_version 'adamant'

game 'gta5'

description 'Made By raymans'

shared_script {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
	'client/main.lua'
}

server_scripts {
	'server/main.lua',
	'@oxmysql/lib/MySQL.lua',
	'config.lua'
}

lua54 'yes'
