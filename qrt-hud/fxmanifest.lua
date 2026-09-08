fx_version 'cerulean'
game 'gta5'
description 'qrt-hud'
version '1.0.0'
ui_page 'web/index.html'
files {
    'web/*',
}
client_scripts {
    'client/cl_substances.lua',   -- ✅ اول لود بشه
    'client/client.lua',
    'client/cl_features.lua',
    'client/open_client.lua',
    'client/cl_pursuit.lua',
}
shared_scripts {
    'shared/config.lua',
    'shared/substances_config.lua',  -- ← اضافه شد
}
server_scripts {
    'server/server.lua',
    'server/sv_pursuit.lua',
    'server/sv_substances.lua',  -- ← اضافه شد
}
escrow_ignore {
    'client/open_client.lua',
    'client/cl_features.lua',
    'client/cl_substances.lua',
    'shared/config.lua',
    'shared/substances_config.lua',
    'server/server.lua',
    'server/sv_pursuit.lua',
    'server/sv_substances.lua',
    'client/cl_pursuit.lua'
}