socket = require 'socket'
json = require 'dkjson'
_, config = pcall(dofile, 'conf.lua')

-- !!!!! THIS IS A PIECE OF SHIT MADE BY ME !!!!!

-- #######################
-- ###    FUNCTIONS    ###
-- #######################

function style_ANSI(data, style)
  return '\27[' .. style .. 'm' .. data .. '\27[0m'
end

function style_IRC(data, style)
  return '' .. style .. data .. ''
end

function findbyvalue(list, value)
  for ind, val in ipairs(list) do
    if val == value then
      return ind
    end
  end
  return nil
end

function tokenize(data)
  -- split the message into tokens by spaces, but ignore spaces in between double quotes
  -- e.g. [the quick brown fox jumps over the lazy dog] is 9 tokens, while ["the quick brown fox jumps over the lazy dog"] is only 1 token
  WORD = data
  FROM = 0
  TO = 0
  TOKEN = ''
  TOKEN_LIST = {}

  while true do
    FROM = TO + 1
    TO = WORD:find(' ', FROM + 1) or #WORD + 1
    TOKEN = WORD:sub(FROM, TO - 1)

    if TOKEN:find('"') == 1 then
      FROM = FROM + 1
      TO = WORD:find('"', FROM)
      TOKEN = WORD:sub(FROM, TO - 1)
      TO = TO + 1
    end

    table.insert(TOKEN_LIST, TOKEN)
    if TO == (#WORD + 1) then return TOKEN_LIST end
  end
end

function loadplugins()
  local c = {}
  for value, plugin in ipairs(config.plugins) do
    local success, p = pcall(dofile, 'plugins/' .. plugin)
    
    if success then
      table.insert(c, p)
      
      for index, command in pairs(p.user) do
        print('[' .. style_ANSI('OK', '1;92') .. '] User command loaded: '.. index)
      end
      
      for index, command in pairs(p.oper) do
        print('[' .. style_ANSI('OK', '1;92') .. '] Oper command loaded: '.. index)
      end
      
      for index, command in pairs(p.feedback) do
        print('[' .. style_ANSI('OK', '1;92') .. '] Feedback function loaded: '.. index)
      end
      
      for index, command in pairs(p.tick) do
        print('[' .. style_ANSI('OK', '1;92') .. '] Tick function loaded: '.. index)
      end
      
      print('[' .. style_ANSI('OK', '1;92') .. '] Plugin loaded: '.. plugin)
    else
      print('[' .. style_ANSI('!!', '1;91') .. '] Failed to load plugin: '.. plugin)
    end
  end
  
  return c
end

function editsave(namespace, key, value)
  if not savedata[namespace] then savedata[namespace] = {} end
  savedata[namespace][key] = value
  local f = io.open(config.persistence, 'w')
  f:write(json.encode(savedata, {indent=true}))
  f:close()
end

function touchsave(namespace)
if not savedata[namespace] then savedata[namespace] = {} end
  local f = io.open(config.persistence, 'w')
  f:write(json.encode(savedata, {indent=true}))
  f:close()
  end

function evalAsMessage(data) -- no, you cannot put oper commands through this
  local data2 = tokenize(data)
  
  if tokens[1]:sub(2, -1) == 'version' then
    irc:send(MSGHEAD .. '\001ACTION is running ' .. config.scriptname .. ' version ' .. config.version .. '.\001' .. CR)

  elseif tokens[1]:sub(2, -1) == 'list' then
    loadedplugins = config.plugins[1]

    for plugin=2, #config.plugins do
      loadedplugins = loadedplugins .. ', ' .. config.plugins[plugin]
    end

    irc:send(MSGHEAD .. 'Loaded plugins: ' .. loadedplugins .. CR)

  elseif tokens[1]:sub(2, -1) == 'format' then
    success, echoedtext = pcall(string.format, tokens[2], tostring(tokens[3]), tostring(tokens[4]), tostring(tokens[5]))
    
    if success then
      irc:send(MSGHEAD .. echoedtext .. CR)
    else
      irc:send(MSGHEAD .. '[' .. style_IRC('!!', 4) .. '] The echo command has a limit of 3 parameters.' .. CR)
    end
  end
  
  for index, plugin in ipairs(commands) do
    if plugin.user[data2[1]:sub(2, -1)] then
      success, result = pcall(plugin.user[data2[1]:sub(2, -1)], data2)

      if not success then
        irc:send(MSGHEAD .. '[' .. style_IRC('!!', 4) .. '] An error occurred: ' .. result .. CR)
      end
    end
  end
end

-- ######################
-- ###    PRE-LOOP    ###
-- ######################

if not _ then
  print('[' .. style_ANSI('!!', '1;91') .. '] Missing config.')
  os.exit(1)
end

if not socket or not json then
  if not socket then print('[' .. style_ANSI('!!', '1;91') .. '] Missing luasocket.') end
  if not json then print('[' .. style_ANSI('!!', '1;91') .. '] Missing dkjson.') end
  
  os.exit(2)
end

file = io.open(config.persistence, 'r')
if file then savedata = json.decode(file:read('*a')) else savedata = {} end
if file then file:close() end
print('[' .. style_ANSI('OK', '1;92') .. '] Persistent save data loaded.')

last = {}

-- header and footer variables
CR = '\r\n' -- use at end of all messages sent to server
MSGHEAD = 'PRIVMSG ' .. config.channel .. ' :' -- use at start of all messages sent to channel

commands = loadplugins()

-- connect to the server
irc = assert(socket.connect(config.server, config.port))
irc:settimeout(0)

-- authenticate
irc:send('USER '.. config.botnick .. ' 0 * :' .. config.botdesc .. '\n' .. CR)
irc:send('NICK '.. config.botnick .. CR)

-- ##################
-- ###    LOOP    ###
-- ##################

while true do
  clock = os.clock()
  text, status = irc:receive()
  

  if status ~= 'timeout' then
    print(text)
    parsed_text = tokenize(text)

    -- respond to PINGs to prevent being kicked
    if text:find('PING') == 1 then
      local pong_id = text:match('PING :(.*)')
      
      -- all will suffer from its incessant pinging
      irc:send('PONG '.. pong_id .. CR)
    end
  
    -- join channel after finishing MOTD
    if text:find('376') then
      if config.nsaccount then
        irc:send('PRIVMSG NickServ :IDENTIFY '.. config.nsaccount .. ' ' .. config.nspasswd .. CR)
        
        -- destroy nickserv info so bad actors can't obtain this info through plugins
        config.nsaccount, config.nspasswd = nil
      end
      if config.key then
        irc:send('JOIN '.. config.channel .. ' ' .. config.key .. CR)
      else
        irc:send('JOIN '.. config.channel .. CR)
      end
    end
    
    -- get chanops
    if parsed_text[2] == '353' then
      _, userlist_start = text:find(".*:")
      userlist = tokenize(text:sub(userlist_start + 1, -1))
      operators = {}
    
      for index, nick in ipairs(userlist) do
        if nick:sub(1,1) == '@' then
          table.insert(operators, nick:sub(2, -1))
          print('[' .. style_ANSI('OK', '1;92') .. '] Found operator: ' .. nick)
        end
      end
      in_channel = true
      print('[' .. style_ANSI('OK', '1;92') .. '] Connected.')
    end

    -- find new chanops on +o, and get rid of chanops on -o
    if parsed_text[2] == 'MODE' then
      if parsed_text[4] == '+o' then
        table.insert(operators, parsed_text[5])
        print('[' .. style_ANSI('OK', '1;92') .. '] Found operator: ' .. parsed_text[5])
      elseif parsed_text[4] == '-o' then
        table.remove(operators, findbyvalue(operators, parsed_text[5]))
        print('[' .. style_ANSI('OK', '1;92') .. '] Removed operator: ' .. parsed_text[5])
      end
    end
    
    -- process messages
    if text:find('PRIVMSG '.. config.channel, 1, true) then
      author = {nickname = text:sub(2, text:find('!') - 1), hostmask = parsed_text[1]:sub(text:find('@') + 1, -1)}
      print('author\'s nick: ' .. author.nickname, 'author\'s host: ' .. author.hostmask)
      _, message_start = text:find(":", text:find('PRIVMSG'))
    
      tokens = tokenize(text:sub(message_start + 1, -1))

      if not (findbyvalue(author.nickname) or findbyvalue(author.hostmask)) then
        if tokens[1]:sub(1,1) == config.prefix then
          -- user commands

          if tokens[1]:sub(2, -1) == 'version' then
            irc:send(MSGHEAD .. '\001ACTION is running ' .. config.scriptname .. ' version ' .. config.version .. '.\001' .. CR)

          elseif tokens[1]:sub(2, -1) == 'list' then
          
            if not tokens[2] then
              loadedplugins = config.plugins[1]

              for plugin=2, #config.plugins do
                loadedplugins = loadedplugins .. ', ' .. config.plugins[plugin]
              end
            else
              commandlist ''
              for index, _ in pairs(commands[tokens[2]].user) do
                if commandlist == '' then commandlist = index
                else
                  commandlist = commandlist .. ' ' .. index
                end
              end
              for index, _ in pairs(commands[tokens[2]].oper) do
                commandlist = commandlist .. ' &' .. index
              end
            end
            irc:send(MSGHEAD .. 'Loaded plugins: ' .. loadedplugins .. CR)
  
          elseif tokens[1]:sub(2, -1) == 'format' then
            success, echoedtext = pcall(string.format, tokens[2], tostring(tokens[3]), tostring(tokens[4]), tostring(tokens[5]))
      
            if success then
              irc:send(MSGHEAD .. echoedtext .. CR)
            else
              irc:send(MSGHEAD .. '[' .. style_IRC('!!', 4) .. '] The echo command has a limit of 3 parameters.' .. CR)
            end
          end
      

          for index, plugin in ipairs(commands) do
            if plugin.user[tokens[1]:sub(2, -1)] then
              success, result = pcall(plugin.user[tokens[1]:sub(2, -1)], tokens)

              if not success then
                irc:send(MSGHEAD .. '[' .. style_IRC('!!', 4) .. '] An error occurred: ' .. result .. CR)
              end
            end
          end
  
        elseif tokens[1]:sub(1,1) == config.operfix then
          -- oper commands
          if findbyvalue(operators, author.nickname) or findbyvalue(config.masters, author.hostmask) then
            if author.hostmask == config.owner and tokens[1]:sub(2, -1) == 'reload' then
              success = pcall(dofile, 'conf.lua')

              if not success then
                irc:send(MSGHEAD .. '[' .. style_IRC('!!', 4) .. '] This config has errors.' .. CR)
              else
                config = dofile 'conf.lua'
            
                -- destroy nickserv info so bad actors can't obtain this info through plugins
                config.nsaccount, config.nspasswd = nil
                success, commands = pcall(loadplugins)
                irc:send(MSGHEAD .. '[' .. style_IRC('OK', 9) .. '] Success.' .. CR)
              end
            end

            for index, plugin in ipairs(commands) do -- if all goes well, do an oper command
              if plugin.oper[tokens[1]:sub(2, -1)] then
                success, result = pcall(plugin.oper[tokens[1]:sub(2, -1)], tokens)

                if not success then
                  irc:send(MSGHEAD .. '[' .. style_IRC('!!', 4) .. '] An error occurred: ' .. result .. CR)
                end
              end
            end
          end
        else -- execute feedback functions
          for index, plugin in ipairs(commands) do
            for index, func in pairs(plugin.feedback) do
              success, result = pcall(func, tokens)

              if not success then
                irc:send(MSGHEAD .. '[' .. style_IRC('!!', 4) .. '] An error occurred: ' .. result .. CR)
              end
            end
          end
        end
        last[author.nickname] = text:sub(message_start + 1, -1)
      end
    end
    if in_channel then -- also tick upon receiving a message
      for index, plugin in ipairs(commands) do
        for index, func in pairs(plugin.tick) do
          success, result = pcall(func)

          if not success then
            print('[' .. style_ANSI('!!', '1;91') .. '] An error occurred: '.. result) -- prints to terminal instead of sending to server because i don't wanna flood the server
          end
        end
      end
      
    end

  elseif status == 'timeout' then -- run every tick function every time the loop runs
    if in_channel then
      for index, plugin in ipairs(commands) do
        for index, func in pairs(plugin.tick) do
          success, result = pcall(func)

          if not success then
            print('[' .. style_ANSI('!!', '1;91') .. '] An error occurred: '.. result) -- prints to terminal instead of sending to server because i don't wanna flood the server
          end
        end
      end
    end
  end
end

