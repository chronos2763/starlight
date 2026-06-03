-- note to FUCKING self
-- PLEASE. PLEASE REMEMBER TO PUT COMMAS.

module = {
-- CONNECTIONS - DOES NOT RELOAD
  server = 'irc.libera.chat', -- the server the bot will connect to
  port = 6667, -- port the server is listening on
  channel = 'change me', -- channel for the bot to join
  key = nil, -- key for the channel to join if it's +k, leave nil to disable

-- DISPLAY - DOES NOT RELOAD
  botnick = 'starlight', -- the bot's name
  botdesc = 'generic starlight bot', -- the bot's description, appears in the bot's WHOIS
  nsaccount = 'change me', -- only if the bot's nick is NickServ registered, set to nil if not
  nspasswd = 'change me', -- set to nil if not NickServ registered

-- COMMANDS
  prefix = ';', -- prefix for commands that are used by the general public
  operfix = '&', -- prefix for operator commands
  plugins = {'oper.lua', 'quotes.lua', 'karma.lua'}, -- plugins to load. if the main file is inside another folder, write it like this: someplugin/main.lua
  masters = {}, -- people to be considered channel operators even when -o, i can't be fucked to have it based on what ChanServ says
  owner = 'change me', -- the one and only person able to use the reload command (takes the owner's host rather than the nickname)

-- MISCELLANEOUS
  scriptname = 'starlight', -- what the bot script is called, changing is useful for forks
  version = '1.0.0', -- the version of the bot script
  persistence = 'savedata.json', -- file to use as persistent data, do not edit said file by hand
  ignore = {}, -- list of users to ignore messages from (can take hosts or nicknames)
}

return module
