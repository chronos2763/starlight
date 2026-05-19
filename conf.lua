-- note to FUCKING self
-- PLEASE. PLEASE REMEMBER TO PUT COMMAS.

module = {
-- CONNECTIONS - DOES NOT RELOAD
  server = 'irc.change.me', -- the server the bot will connect to
  port = 6667, -- port the server is listening on
  channel = '##change-me', -- channel for the bot to join
  key = nil, -- key for the channel to join if it's +k, leave nil to disable

-- DISPLAY - DOES NOT RELOAD
  botnick = 'CHANGE-ME', -- the bot's name
  botdesc = 'generic starlight bot', -- the bot's description, appears in the bot's WHOIS
  nsaccount = nil, -- only if the bot's nick is NickServ registered, set to nil if not
  nspasswd = nil, -- set to nil if not NickServ registered

-- COMMANDS
  prefix = ';', -- prefix for commands that are used by the general public
  operfix = '&', -- prefix for operator commands
  plugins = {'oper.lua'}, -- plugins to load. if the main file is inside another folder, write it like this: someplugin/main.lua
  masters = {}, -- people to be considered channel operators even when -o, i can't be fucked to have it based on what ChanServ says
  owner = 'CHANGE-ME', -- the one and only person able to use the reload command

-- MISCELLANEOUS
  scriptname = 'starlight', -- what the bot script is called, changing is useful for forks
  version = 'DEV', -- the version of the bot script
  persistence = 'savedata.json', -- file to use as persistent data, do not edit said file by hand
}

return module
